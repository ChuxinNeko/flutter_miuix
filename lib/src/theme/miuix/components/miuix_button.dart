// Miuix Flutter 移植版 - Button
// 源自 compose-miuix-ui/miuix 的 Button.kt。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../foundation/miuix_content_color.dart';
import '../foundation/miuix_pressable.dart';
import '../foundation/miuix_squircle.dart';
import '../theme/miuix_text_styles.dart';
import '../theme/miuix_theme.dart';

/// Button 颜色配置。对应 Kotlin `ButtonColors`。
@immutable
class MiuixButtonColors {
  const MiuixButtonColors({
    required this.color,
    required this.disabledColor,
    required this.contentColor,
    required this.disabledContentColor,
  });

  final Color color;
  final Color disabledColor;
  final Color contentColor;
  final Color disabledContentColor;
}

/// Button 默认值。对应 Kotlin `ButtonDefaults`。
class MiuixButtonDefaults {
  MiuixButtonDefaults._();

  static const double minWidth = 58;
  static const double minHeight = 40;
  static const double cornerRadius = 16;
  static const EdgeInsets insideMargin =
      EdgeInsets.symmetric(horizontal: 16, vertical: 13);

  /// 默认次级按钮颜色。
  static MiuixButtonColors buttonColors(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    return MiuixButtonColors(
      color: c.secondaryVariant,
      disabledColor: c.disabledSecondaryVariant,
      contentColor: c.onSecondaryVariant,
      disabledContentColor: c.disabledOnSecondaryVariant,
    );
  }

  /// 主色按钮颜色。
  static MiuixButtonColors buttonColorsPrimary(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    return MiuixButtonColors(
      color: c.primary,
      disabledColor: c.disabledPrimaryButton,
      contentColor: c.onPrimary,
      disabledContentColor: c.disabledOnPrimaryButton,
    );
  }
}

/// Miuix 风格的按钮。对应 Kotlin `Button`。
class MiuixButton extends StatelessWidget {
  const MiuixButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.enabled = true,
    this.cornerRadius = MiuixButtonDefaults.cornerRadius,
    this.minWidth = MiuixButtonDefaults.minWidth,
    this.minHeight = MiuixButtonDefaults.minHeight,
    this.colors,
    this.insideMargin = MiuixButtonDefaults.insideMargin,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool enabled;
  final double cornerRadius;
  final double minWidth;
  final double minHeight;
  final MiuixButtonColors? colors;
  final EdgeInsetsGeometry insideMargin;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final c = colors ?? MiuixButtonDefaults.buttonColors(context);
    final effectiveEnabled = enabled && onPressed != null;
    final containerColor =
        effectiveEnabled ? c.color : c.disabledColor;
    final txtColor =
        effectiveEnabled ? c.contentColor : c.disabledContentColor;
    final shape = MiuixSquircleBorder(cornerRadius: cornerRadius);
    final radius = BorderRadius.circular(cornerRadius);

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight),
      child: Padding(
        padding: insideMargin,
        child: DefaultTextStyle.merge(
          textAlign: TextAlign.center,
          // 显式注入 txtColor，使 Flutter 内置 Text 也能正确取色。
          // MiuixContentColor 仅对 MiuixText / MiuixIcon 生效，对 Text 无效，
          // 不在此 merge 会导致 disabled 态文字色不变（与 enabled 难以区分）。
          style: theme.textStyles.button
              .copyWith(color: txtColor)
              .withMiuixWeight(theme.fontWeightAdjustment),
          child: child,
        ),
      ),
    );

    content = MiuixContentColor(
      color: txtColor,
      child: DecoratedBox(
        decoration: ShapeDecoration(color: containerColor, shape: shape),
        // factor=1：贴内容尺寸（对应 Compose defaultMinSize 语义；不设 factor
        // 时 Center 在有界宽松约束下会把按钮撑满可用宽度）。
        child: Center(widthFactor: 1, heightFactor: 1, child: content),
      ),
    );

    return MiuixPressable(
      onPressed: effectiveEnabled ? onPressed : null,
      enabled: effectiveEnabled,
      borderRadius: radius,
      child: content,
    );
  }
}

/// 文本按钮。对应 Kotlin `TextButton`。
class MiuixTextButton extends StatelessWidget {
  const MiuixTextButton(
    this.text, {
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.cornerRadius = MiuixButtonDefaults.cornerRadius,
    this.minWidth = MiuixButtonDefaults.minWidth,
    this.minHeight = MiuixButtonDefaults.minHeight,
    this.colors,
    this.insideMargin = MiuixButtonDefaults.insideMargin,
    this.textStyle,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final double cornerRadius;
  final double minWidth;
  final double minHeight;
  final MiuixButtonColors? colors;
  final EdgeInsetsGeometry insideMargin;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    return MiuixButton(
      onPressed: onPressed,
      enabled: enabled,
      cornerRadius: cornerRadius,
      minWidth: minWidth,
      minHeight: minHeight,
      colors: colors,
      insideMargin: insideMargin,
      child: Text(
        text,
        style: (textStyle ?? theme.textStyles.button)
            .withMiuixWeight(theme.fontWeightAdjustment),
      ),
    );
  }
}
