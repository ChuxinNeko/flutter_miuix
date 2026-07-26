// Miuix Flutter 移植版 - FloatingToolbar
// 源自 compose-miuix-ui/miuix 的 FloatingToolbar.kt。
// 自包含容器：squircle 背景 + 固定几何阴影 + 可选 0.75dp 描边，GestureDetector 消费点击。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../foundation/miuix_squircle.dart';
import '../theme/miuix_theme.dart';

/// FloatingToolbar 默认值。对应 Kotlin `FloatingToolbarDefaults`。
class MiuixFloatingToolbarDefaults {
  MiuixFloatingToolbarDefaults._();

  /// 默认圆角半径（逻辑像素）。cornerRadius=50 配合较矮的工具栏高度会形成胶囊轮廓。
  static const double cornerRadius = 50;

  /// 工具栏外部留白，对应 Kotlin `PaddingValues(12.dp, 8.dp)`。
  static const EdgeInsets outSidePadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 8);

  /// 默认背景色，取自主题的 `surfaceContainer`。
  static Color defaultColor(BuildContext context) =>
      MiuixTheme.of(context).colors.surfaceContainer;
}

/// 悬浮工具栏。对应 Kotlin `FloatingToolbar`。
///
/// 一个自包含容器：内部不安排方向（横/纵由调用方在 [child] 内自行用
/// Row/Column 决定）。结构（外→内）：外边距 [outSidePadding] → squircle
/// 背景（可选 0.75dp `dividerLine` 描边）→ 固定几何阴影 → 内容。
///
/// 阴影几何是**固定**的：blurRadius=10、黑色 alpha=0.10、零偏移、零扩散；
/// [shadowElevation] 仅作为是否显示阴影的开关（>0 显示），不参与缩放，
/// 这与 `MiuixSurface` 的阴影参数不同。
///
/// 通过 [GestureDetector]（opaque 命中行为）消费点击，避免事件穿透到
/// 工具栏背后的组件；工具栏内部的子按钮仍能在 Flutter 命中竞技场中胜出。
class MiuixFloatingToolbar extends StatelessWidget {
  const MiuixFloatingToolbar({
    super.key,
    required this.child,
    this.color,
    this.cornerRadius = MiuixFloatingToolbarDefaults.cornerRadius,
    this.outSidePadding = MiuixFloatingToolbarDefaults.outSidePadding,
    this.shadowElevation = 4,
    this.showDivider = false,
  });

  /// 内容。调用方自行用 Row/Column 等安排布局。
  final Widget child;

  /// 背景色。默认取 [MiuixFloatingToolbarDefaults.defaultColor]。
  final Color? color;

  /// 圆角半径（逻辑像素）。
  final double cornerRadius;

  /// 外部留白。
  final EdgeInsetsGeometry outSidePadding;

  /// 阴影高度。仅作为是否显示阴影的开关（>0 显示），阴影几何固定不变。
  final double shadowElevation;

  /// 是否显示 0.75dp 的 `dividerLine` 描边。
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    final backgroundColor = color ?? MiuixFloatingToolbarDefaults.defaultColor(context);

    final shape = MiuixSquircleBorder(
      cornerRadius: cornerRadius,
      enabled: cornerRadius > 0,
      side: showDivider
          ? BorderSide(color: colors.dividerLine, width: 0.75)
          : BorderSide.none,
    );

    final decoration = ShapeDecoration(
      color: backgroundColor,
      shape: shape,
      shadows: shadowElevation > 0
          ? const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset.zero,
                spreadRadius: 0,
              ),
            ]
          : null,
    );

    return Padding(
      padding: outSidePadding,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: DecoratedBox(
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }
}
