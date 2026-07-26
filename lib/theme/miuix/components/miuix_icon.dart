// Miuix Flutter 移植版 - Icon
// 源自 compose-miuix-ui/miuix 的 Icon.kt。
// 用 Flutter 的 Icon(IconData) / ColorFiltered(BlendMode.srcIn) 复刻 Compose 的 ImageVector + ColorFilter.tint。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../foundation/miuix_content_color.dart';
import '../foundation/miuix_vector_icon.dart';

/// 哨兵色值，表示"不上色"（用于多色图标），对应 Compose 的 `Color.Unspecified`。
///
/// 通过 `identical` 判等：只有传入此常量本身才被视为"无 tint"，
/// 渲染时不套用任何 `ColorFilter`，保留图标自身的多色外观。
const Color kMiuixTintUnspecified = Color(0x00000001);

/// Icon 默认值。对应 Kotlin `Icon.kt` 中的 `DefaultIconSizeModifier`。
class MiuixIconDefaults {
  MiuixIconDefaults._();

  /// 默认图标尺寸（逻辑像素），对应 Kotlin `Modifier.size(24.dp)`。
  static const double defaultSize = 24;
}

/// Miuix 风格的图标。对应 Kotlin `Icon`。
///
/// 单色图标通过 [tint] 上色（默认取自 `MiuixContentColor`）；
/// 多色图标传 [kMiuixTintUnspecified] 以禁用上色，或直接通过 [child] 传入自定义 Widget。
///
/// [icon] 与 [child] 二选一：[icon] 用于 Material 图标字体字形（对应 Kotlin
/// `ImageVector`/`ImageBitmap` 输入），[child] 用于任意自定义 Widget（对应 Kotlin
/// `Painter` 输入，如多色 `Image`）。
class MiuixIcon extends StatelessWidget {
  const MiuixIcon({
    super.key,
    this.icon,
    this.vector,
    this.child,
    this.tint,
    this.contentDescription,
    this.size,
  }) : assert(
          (icon != null ? 1 : 0) +
                  (vector != null ? 1 : 0) +
                  (child != null ? 1 : 0) ==
              1,
          'MiuixIcon: icon / vector / child 必须三选一',
        );

  /// Material 图标数据。对应 Kotlin `ImageVector` / `ImageBitmap` 输入。
  final IconData? icon;

  /// Miuix 矢量图标（内置 basic / 扩展图标）。对应 Kotlin `ImageVector` 输入。
  final MiuixVectorIcon? vector;

  /// 自定义图标 Widget（多色图标等）。对应 Kotlin `Painter` 输入。
  final Widget? child;

  /// 上色颜色。`null` 时取 `MiuixContentColor.of(context)`；
  /// 传 [kMiuixTintUnspecified] 时不应用任何 tint（多色图标）。
  ///
  /// 对应 Compose `tint: Color = LocalContentColor.current`，
  /// `Color.Unspecified` 表示不上色。
  final Color? tint;

  /// 无障碍描述。`null` 时不包裹 `Semantics`（装饰性图标）。
  /// 对应 Kotlin `contentDescription`。
  final String? contentDescription;

  /// 图标尺寸。`null` 时 [icon] 路径回退到 [MiuixIconDefaults.defaultSize]，
  /// [child] 路径保留自身尺寸。对应 Kotlin `defaultSizeFor` 逻辑。
  final double? size;

  @override
  Widget build(BuildContext context) {
    final bool noTint = identical(tint, kMiuixTintUnspecified);
    final Color? resolvedTint =
        noTint ? null : (tint ?? MiuixContentColor.of(context));

    if (icon != null) {
      // Material 的 Icon 已通过 SrcIn 上色、默认 24、并在 semanticLabel 非空时
      // 发出 image 语义，与 miuix Icon.kt 完全一致。
      return Icon(
        icon,
        color: resolvedTint,
        size: size ?? MiuixIconDefaults.defaultSize,
        semanticLabel: contentDescription,
      );
    }

    if (vector != null) {
      // 矢量图标：目标框为显式 size（正方形）或矢量 intrinsic size；
      // FittedBox 把视口坐标系的绘制等比缩放进目标框（ContentScale.Fit）。
      // tint 语义与 Icon.kt 一致：kMiuixTintUnspecified 不上色，否则整幅 SrcIn。
      final Size box =
          size != null ? Size.square(size!) : vector!.intrinsicSize;
      Widget result = SizedBox.fromSize(
        size: box,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox.fromSize(
            size: vector!.viewport,
            child: CustomPaint(
              size: vector!.viewport,
              painter: MiuixVectorIconPainter(vector!, tint: resolvedTint),
            ),
          ),
        ),
      );
      if (contentDescription != null) {
        result = Semantics(label: contentDescription, image: true, child: result);
      }
      return result;
    }

    // child 路径：任意 Widget（如多色 Image）。
    Widget result = child!;
    if (size != null) {
      // ContentScale.Fit -> BoxFit.contain，仅在显式给尺寸时约束。
      result = SizedBox(
        width: size,
        height: size,
        child: FittedBox(fit: BoxFit.contain, child: result),
      );
    }
    if (!noTint) {
      // ColorFilter.tint(color) 默认 BlendMode.SrcIn。
      result = ColorFiltered(
        colorFilter: ColorFilter.mode(resolvedTint!, BlendMode.srcIn),
        child: result,
      );
    }
    if (contentDescription != null) {
      // Role.Image -> image: true；contentDescription 为 null 时不包裹。
      result = Semantics(label: contentDescription, image: true, child: result);
    }
    return result;
  }
}
