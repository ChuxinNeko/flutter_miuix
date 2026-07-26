// Miuix Flutter 移植版 - VectorIcon（ImageVector 等价物）
// 源自 compose-miuix-ui/miuix 的 icon/basic/*.kt（androidx ImageVector + Icon.kt 的 tint 语义）。
// 用一个不可变数据模型 + CustomPainter 复刻 Compose 的 ImageVector 及
// Icon(imageVector, tint) 的渲染：saveLayer + ColorFilter.tint(SrcIn) 对整幅矢量上色，
// 从而 1:1 支持填充/描边/多图层不同 alpha/group 翻转等所有情况。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

/// 单条矢量路径的绘制描述。对应 Compose `ImageVector` 里的一个 `path { ... }` 节点。
///
/// [style] 为 [PaintingStyle.fill]（填充）或 [PaintingStyle.stroke]（描边）；
/// [color] 是矢量自带的原始颜色（`SolidColor(...)`），仅在**未 tint**时使用——
/// 使用 [MiuixIcon] 上色时会被 `ColorFilter.tint` 整体覆盖（见 [MiuixVectorIconPainter]）。
/// [alpha] 对应 `fillAlpha` / `strokeAlpha`；[strokeWidth]/[strokeCap] 对应描边参数。
/// [groupTransform] 对应包裹该路径的 `group(scaleY = -1, translationY = ...)` 等变换，
/// 在视口坐标系下、绘制路径前施加（如 basic/Sidebar 的整体纵向翻转）。
@immutable
class MiuixVectorPath {
  const MiuixVectorPath({
    required this.build,
    this.style = PaintingStyle.fill,
    this.color = const Color(0xFF000000),
    this.alpha = 1.0,
    this.strokeWidth = 0.0,
    this.strokeCap = StrokeCap.butt,
    this.groupTransform,
  });

  /// 构造路径（视口坐标系）。用回调以便每次绘制得到新的 [Path] 实例，避免共享可变状态。
  final Path Function() build;

  /// 填充或描边。对应有无 `fill` / `stroke`。
  final PaintingStyle style;

  /// 矢量原始颜色（`SolidColor`）。仅在未 tint 时用于绘制。
  final Color color;

  /// 不透明度。对应 `fillAlpha` / `strokeAlpha`。
  final double alpha;

  /// 描边宽度。对应 `strokeLineWidth`（0 表示 1px 发丝线）。
  final double strokeWidth;

  /// 描边线帽。对应 `strokeLineCap`。
  final StrokeCap strokeCap;

  /// 视口坐标系下的组变换（如纵向翻转）。为 null 表示无变换。
  final Matrix4? groupTransform;
}

/// 矢量图标。对应 Compose 的 `ImageVector`。
///
/// [viewport] 为路径坐标所在的视口尺寸（`viewportWidth/Height`）；
/// [intrinsicSize] 为默认渲染尺寸（`defaultWidth/Height`，逻辑像素）——
/// 当 [MiuixIcon] 未显式指定 size 时按此尺寸渲染（对应 Compose 的 intrinsic size 回退）。
@immutable
class MiuixVectorIcon {
  const MiuixVectorIcon({
    required this.name,
    required this.viewport,
    required this.intrinsicSize,
    required this.paths,
  });

  /// 图标名（对应 `ImageVector.Builder(name = ...)`），用于调试与语义回退。
  final String name;

  /// 路径视口尺寸。
  final Size viewport;

  /// 默认渲染尺寸（逻辑像素）。
  final Size intrinsicSize;

  /// 组成该图标的所有路径（按绘制顺序）。
  final List<MiuixVectorPath> paths;
}

/// 将 [MiuixVectorIcon] 绘制到 **视口尺寸** 的画布上；外层缩放交给 [FittedBox]。
///
/// [tint] 非空时以 `ColorFilter.tint`（默认 `BlendMode.srcIn`）对整幅矢量上色，
/// 与 Compose `Icon(painter, colorFilter = ColorFilter.tint(tint))` 一致：
/// 各子路径先按各自 alpha 合成，再被 tint 统一着色（保留分层透明度）。
/// [tint] 为空时按矢量原始颜色绘制（多色/不上色场景）。
class MiuixVectorIconPainter extends CustomPainter {
  const MiuixVectorIconPainter(this.icon, {this.tint});

  final MiuixVectorIcon icon;
  final Color? tint;

  @override
  void paint(Canvas canvas, Size size) {
    final bool tinted = tint != null;
    final Rect bounds = Offset.zero & icon.viewport;

    if (tinted) {
      // 整幅上色：saveLayer + SrcIn，等价 Compose 的 ColorFilter.tint。
      canvas.saveLayer(
        bounds,
        Paint()..colorFilter = ColorFilter.mode(tint!, BlendMode.srcIn),
      );
    }

    for (final spec in icon.paths) {
      canvas.save();
      if (spec.groupTransform != null) {
        canvas.transform(spec.groupTransform!.storage);
      }
      final paint = Paint()
        ..style = spec.style
        // tint 时颜色被 SrcIn 覆盖，仅 alpha（作为覆盖率）有意义；未 tint 时用原始色。
        ..color = spec.color.withValues(alpha: spec.color.a * spec.alpha);
      if (spec.style == PaintingStyle.stroke) {
        paint
          ..strokeWidth = spec.strokeWidth
          ..strokeCap = spec.strokeCap;
      }
      canvas.drawPath(spec.build(), paint);
      canvas.restore();
    }

    if (tinted) canvas.restore();
  }

  @override
  bool shouldRepaint(MiuixVectorIconPainter oldDelegate) =>
      !identical(oldDelegate.icon, icon) || oldDelegate.tint != tint;
}

/// 构造一个带偶数-奇数填充规则的空 [Path]。便于图标定义处链式 `..moveTo(...)`。
Path miuixEvenOddPath() => Path()..fillType = PathFillType.evenOdd;

/// 从 SVG 风格的路径数据字符串解析出 [Path]。
///
/// 用于扩展图标（miuix-icons，156×5 个变体）：Kotlin 端的 `PathNode` 列表在生成时
/// 被压成紧凑字符串，运行时由本函数还原，避免每个图标产出大量 Dart 代码。
///
/// 支持的命令（**仅绝对坐标**，与 miuix 扩展图标一致）：
/// `M x y` 移动、`L x y` 直线、`Q x1 y1 x y` 二次贝塞尔、
/// `C x1 y1 x2 y2 x y` 三次贝塞尔、`Z` 闭合。数字以空白分隔，命令字母单独成 token。
///
/// 注意：Compose 的 `HorizontalTo`/`VerticalTo` 在生成阶段已被展开为完整的 `L x y`
/// （生成器跟踪当前点），因此这里无需处理 H/V。[fillType] 默认非零环绕（NonZero）。
Path miuixParsePath(String data, {PathFillType fillType = PathFillType.nonZero}) {
  final path = Path()..fillType = fillType;
  final tokens = data.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  int i = 0;
  double num() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    final cmd = tokens[i++];
    switch (cmd) {
      case 'M':
        path.moveTo(num(), num());
      case 'L':
        path.lineTo(num(), num());
      case 'Q':
        path.quadraticBezierTo(num(), num(), num(), num());
      case 'C':
        path.cubicTo(num(), num(), num(), num(), num(), num());
      case 'Z':
        path.close();
      default:
        throw FormatException('miuixParsePath: 未知命令 "$cmd"', data);
    }
  }
  return path;
}
