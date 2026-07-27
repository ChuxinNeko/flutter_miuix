// Miuix Flutter 移植版 - FloatingActionButton
// 源自 compose-miuix-ui/miuix 的 FloatingActionButton.kt。
// 用 DecoratedBox+ShapeDecoration 复刻 Surface 的圆形背景与阴影，MiuixPressable 复刻按压遮罩。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../foundation/miuix_content_color.dart';
import '../foundation/miuix_pressable.dart';
import '../theme/miuix_theme.dart';

/// FloatingActionButton 默认值。对应 Kotlin `FloatingActionButtonDefaults`。
class MiuixFloatingActionButtonDefaults {
  MiuixFloatingActionButtonDefaults._();

  /// 默认最小宽度。
  static const double minWidth = 60;

  /// 默认最小高度。
  static const double minHeight = 60;

  /// 默认阴影高度。
  static const double shadowElevation = 4;

  /// 默认形状。对应 Kotlin `CircleShape`（正方形 bounds 下为正圆，矩形下为胶囊）。
  static const ShapeBorder shape = StadiumBorder();
}

/// Miuix 风格的浮动操作按钮。对应 Kotlin `FloatingActionButton`。
///
/// 在 Surface（shape=CircleShape, color=containerColor, shadowElevation）之上
/// 用 `defaultMinSize(60,60)` 的 Box 居中放置内容。Flutter 端用 [DecoratedBox]
/// + [ShapeDecoration] 复刻背景与阴影，[MiuixPressable] 复刻按压遮罩
/// （overlayColor = colors.onBackground，spring enter damping1.0/response0.2，
/// exit damping0.95/response0.35）。
///
/// 内容色注意：与 Kotlin 一致，FAB 不向 Surface 传 contentColor，因此内容色
/// 继承 Surface 默认值 `colors.onSurface`（而非 `onPrimary`），通过
/// [MiuixContentColor] 向下传递，调用方提供的 MiuixIcon 默认会被 tint 成 onSurface。
class MiuixFloatingActionButton extends StatelessWidget {
  const MiuixFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.enabled = true,
    this.shape = MiuixFloatingActionButtonDefaults.shape,
    this.containerColor,
    this.shadowElevation = MiuixFloatingActionButtonDefaults.shadowElevation,
    this.minWidth = MiuixFloatingActionButtonDefaults.minWidth,
    this.minHeight = MiuixFloatingActionButtonDefaults.minHeight,
  });

  /// 点击回调。为 null 时视为禁用。
  final VoidCallback? onPressed;

  /// 子节点。
  final Widget child;

  /// 是否启用。
  final bool enabled;

  /// 形状，默认 [StadiumBorder]（对应 Kotlin `CircleShape`）。
  final ShapeBorder shape;

  /// 容器背景色，默认 `MiuixTheme.colors.primary`。
  final Color? containerColor;

  /// 阴影高度（逻辑像素），默认 4。
  final double shadowElevation;

  /// 最小宽度，默认 60。
  final double minWidth;

  /// 最小高度，默认 60。
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final bgColor = containerColor ?? theme.colors.primary;
    final effectiveEnabled = enabled && onPressed != null;

    // 内容色继承 Surface 默认（onSurface），而非 onPrimary。
    Widget content = MiuixContentColor(
      color: theme.colors.onSurface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          minHeight: minHeight,
        ),
        // factor=1：贴内容尺寸（对应 Compose defaultMinSize 语义）。
        child: Center(widthFactor: 1, heightFactor: 1, child: child),
      ),
    );

    // 按压遮罩：MiuixIndication(color = colors.onBackground)，OVERLAY 类型。
    // MiuixPressable 内部已应用 alpha deltas（press 0.10, hover 0.06, focus 0.08）
    // 与对应的 spring 规格，故此处直接传 overlayColor 即可。
    content = MiuixPressable(
      onPressed: effectiveEnabled ? onPressed : null,
      enabled: effectiveEnabled,
      feedbackType: MiuixPressFeedbackType.none,
      overlayColor: theme.colors.onBackground,
      child: content,
    );

    // 裁剪按压遮罩与内容到 shape；阴影需渲染在裁剪之外，故阴影留在更外层。
    content = ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: content,
    );

    // 外层 DecoratedBox 负责背景色与阴影（复用 MiuixSurface 的阴影公式）。
    return Semantics(
      button: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: bgColor,
          shape: shape,
          shadows: shadowElevation > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: shadowElevation,
                    offset: Offset(0, shadowElevation * 0.5),
                  ),
                ]
              : null,
        ),
        child: content,
      ),
    );
  }
}
