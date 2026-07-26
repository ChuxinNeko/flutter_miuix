// Miuix Flutter 移植版 - SmallTitle
// 源自 compose-miuix-ui/miuix 的 SmallTitle.kt。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../theme/miuix_theme.dart';
import 'miuix_text.dart';

/// 小标题。对应 Kotlin `SmallTitle`。
///
/// 使用 `subtitle` 样式（14sp 加粗），默认颜色 `onBackgroundVariant`，
/// 内边距 28dp × 8dp。
class MiuixSmallTitle extends StatelessWidget {
  const MiuixSmallTitle(
    this.text, {
    super.key,
    this.textColor,
    this.insideMargin = const EdgeInsets.symmetric(
      horizontal: 28,
      vertical: 8,
    ),
  });

  final String text;

  /// 文字颜色，默认 `MiuixTheme.colors.onBackgroundVariant`。
  final Color? textColor;

  /// 内边距，默认 28dp 水平 + 8dp 垂直。
  final EdgeInsetsGeometry insideMargin;

  @override
  Widget build(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return Padding(
      padding: insideMargin,
      child: MiuixText(
        text,
        style: MiuixTheme.of(context).textStyles.subtitle,
        color: textColor ?? colors.onBackgroundVariant,
      ),
    );
  }
}
