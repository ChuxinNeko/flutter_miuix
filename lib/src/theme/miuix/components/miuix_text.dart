// Miuix Flutter 移植版 - Text
// 源自 compose-miuix-ui/miuix 的 Text.kt。
// 默认使用 `main` 文本样式，颜色取自 [MiuixContentColor]。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../foundation/miuix_content_color.dart';
import '../theme/miuix_text_styles.dart';
import '../theme/miuix_theme.dart';

/// Miuix 风格的文本。对应 Kotlin `Text`。
///
/// 默认 [style] 为 `MiuixTheme.textStyles.main`，颜色取自 [MiuixContentColor]，
/// 显式 [color] 优先级最高。
class MiuixText extends StatelessWidget {
  const MiuixText(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.letterSpacing,
    this.fontStyle,
    this.decoration,
    this.textAlign,
    this.height,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.style,
  });

  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final double? letterSpacing;
  final FontStyle? fontStyle;
  final TextDecoration? decoration;
  final TextAlign? textAlign;
  final double? height;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  /// 基础样式。默认 `MiuixTheme.textStyles.main`。
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final base = style ?? theme.textStyles.main;
    final resolvedColor =
        color ?? base.color ?? MiuixContentColor.of(context);
    // 跟随系统字重：把偏移应用到最终字重（未指定按 w400 处理）。
    final resolvedWeight = adjustFontWeight(
        fontWeight ?? base.fontWeight, theme.fontWeightAdjustment);
    return Text(
      text,
      style: base.copyWith(
        color: resolvedColor,
        fontSize: fontSize,
        fontWeight: resolvedWeight,
        fontFamily: fontFamily == null ? null : TextStyle(fontFamily: fontFamily).fontFamily,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
        decoration: decoration,
        height: height,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
