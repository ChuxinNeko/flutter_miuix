// Miuix Flutter 移植版 - Surface
// 源自 compose-miuix-ui/miuix 的 Surface.kt。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../foundation/miuix_content_color.dart';
import '../foundation/miuix_squircle.dart';
import '../theme/miuix_theme.dart';

/// Miuix 风格的 Surface。对应 Kotlin `Surface`。
///
/// 提供背景色、内容色、边框、阴影，并向下传递 [MiuixContentColor]。
/// 默认形状为矩形；传入 [cornerRadius] 时使用 squircle 圆角。
class MiuixSurface extends StatelessWidget {
  const MiuixSurface({
    super.key,
    this.color,
    this.contentColor,
    this.cornerRadius = 0,
    this.squircleEnabled = true,
    this.border,
    this.shadowElevation = 0,
    this.onPressed,
    this.enabled = true,
    required this.child,
  });

  /// 背景色，默认 `MiuixTheme.colors.surface`。
  final Color? color;

  /// 内容色，默认 `MiuixTheme.colors.onSurface`。
  final Color? contentColor;

  /// 圆角半径，0 表示直角。
  final double cornerRadius;

  /// 是否启用 squircle 圆角。
  final bool squircleEnabled;

  /// 边框。
  final Border? border;

  /// 阴影高度（逻辑像素）。
  final double shadowElevation;

  /// 点击回调，非 null 时 Surface 可点击。
  final VoidCallback? onPressed;

  /// 是否启用点击。
  final bool enabled;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final bgColor = color ?? theme.colors.surface;
    final txtColor = contentColor ?? theme.colors.onSurface;
    final shape = MiuixSquircleBorder(
      cornerRadius: cornerRadius,
      enabled: squircleEnabled && cornerRadius > 0,
      side: border?.top ?? BorderSide.none,
    );

    Widget content = DecoratedBox(
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
      child: child,
    );

    content = MiuixContentColor(color: txtColor, child: content);

    if (onPressed != null) {
      return GestureDetector(
        onTap: enabled ? onPressed : null,
        child: content,
      );
    }
    return content;
  }
}
