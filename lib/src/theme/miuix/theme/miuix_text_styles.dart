// Miuix Flutter 移植版 - 文本样式
// 源自 compose-miuix-ui/miuix 的 TextStyles.kt。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

/// Miuix 文本样式集。对应 Kotlin 端的 `TextStyles`。
///
/// 所有样式的运行时颜色由 [MiuixTheme] 的 `onBackground` 提供，
/// 这里仅保留字号/字重/行高。
@immutable
class MiuixTextStyles {
  const MiuixTextStyles({
    required this.main,
    required this.paragraph,
    required this.body1,
    required this.body2,
    required this.button,
    required this.footnote1,
    required this.footnote2,
    required this.headline1,
    required this.headline2,
    required this.subtitle,
    required this.title1,
    required this.title2,
    required this.title3,
    required this.title4,
  });

  /// 主文本：17sp。
  final TextStyle main;

  /// 段落：17sp，行高 1.2em。
  final TextStyle paragraph;

  /// 正文 1：16sp。
  final TextStyle body1;

  /// 正文 2：14sp。
  final TextStyle body2;

  /// 按钮：17sp。
  final TextStyle button;

  /// 脚注 1：13sp。
  final TextStyle footnote1;

  /// 脚注 2：11sp。
  final TextStyle footnote2;

  /// 标题行 1：17sp。
  final TextStyle headline1;

  /// 标题行 2：16sp。
  final TextStyle headline2;

  /// 副标题：14sp，加粗。
  final TextStyle subtitle;

  /// 标题 1：32sp。
  final TextStyle title1;

  /// 标题 2：24sp。
  final TextStyle title2;

  /// 标题 3：20sp。
  final TextStyle title3;

  /// 标题 4：18sp。
  final TextStyle title4;

  MiuixTextStyles copy({
    TextStyle? main,
    TextStyle? paragraph,
    TextStyle? body1,
    TextStyle? body2,
    TextStyle? button,
    TextStyle? footnote1,
    TextStyle? footnote2,
    TextStyle? headline1,
    TextStyle? headline2,
    TextStyle? subtitle,
    TextStyle? title1,
    TextStyle? title2,
    TextStyle? title3,
    TextStyle? title4,
  }) {
    return MiuixTextStyles(
      main: main ?? this.main,
      paragraph: paragraph ?? this.paragraph,
      body1: body1 ?? this.body1,
      body2: body2 ?? this.body2,
      button: button ?? this.button,
      footnote1: footnote1 ?? this.footnote1,
      footnote2: footnote2 ?? this.footnote2,
      headline1: headline1 ?? this.headline1,
      headline2: headline2 ?? this.headline2,
      subtitle: subtitle ?? this.subtitle,
      title1: title1 ?? this.title1,
      title2: title2 ?? this.title2,
      title3: title3 ?? this.title3,
      title4: title4 ?? this.title4,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MiuixTextStyles &&
        other.main == main &&
        other.paragraph == paragraph &&
        other.body1 == body1 &&
        other.body2 == body2 &&
        other.button == button &&
        other.footnote1 == footnote1 &&
        other.footnote2 == footnote2 &&
        other.headline1 == headline1 &&
        other.headline2 == headline2 &&
        other.subtitle == subtitle &&
        other.title1 == title1 &&
        other.title2 == title2 &&
        other.title3 == title3 &&
        other.title4 == title4;
  }

  @override
  int get hashCode => Object.hash(
        main, paragraph, body1, body2, button, footnote1, footnote2,
        headline1, headline2, subtitle, title1, title2, title3, title4,
      );
}

/// 按 [adjustment] 偏移字重，对应 Android Compose 平台自动施加的
/// `Configuration.fontWeightAdjustment`（跟随系统字体粗细度）。
///
/// [adjustment] 为权重数值，100 为一档（与 Flutter [FontWeight] 步进一致）：
/// +100 时 w400→w500、w600→w700、w700→w800。[weight] 为 null 时按 w400 处理。
///
/// [adjustment] == 0 时原样返回（含 null），保证零行为回归。
FontWeight? adjustFontWeight(FontWeight? weight, int adjustment) {
  if (adjustment == 0) return weight;
  final base = weight ?? FontWeight.w400;
  final target = base.value + adjustment;
  final idx = ((target / 100).round() - 1).clamp(0, FontWeight.values.length - 1);
  return FontWeight.values[idx];
}

/// 在样式上应用字重偏移的便捷写法。见 [adjustFontWeight]。
extension MiuixFontWeightAdjustment on TextStyle {
  TextStyle withMiuixWeight(int adjustment) =>
      adjustment == 0 ? this : copyWith(fontWeight: adjustFontWeight(fontWeight, adjustment));
}

/// 默认文本样式，与 Miuix 规范一致。字号单位为逻辑像素（Flutter sp 近似）。
MiuixTextStyles defaultTextStyles() => MiuixTextStyles(
      main: const TextStyle(fontSize: 17),
      paragraph: const TextStyle(fontSize: 17, height: 1.2),
      body1: const TextStyle(fontSize: 16),
      body2: const TextStyle(fontSize: 14),
      button: const TextStyle(fontSize: 17),
      footnote1: const TextStyle(fontSize: 13),
      footnote2: const TextStyle(fontSize: 11),
      headline1: const TextStyle(fontSize: 17),
      headline2: const TextStyle(fontSize: 16),
      subtitle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      title1: const TextStyle(fontSize: 32),
      title2: const TextStyle(fontSize: 24),
      title3: const TextStyle(fontSize: 20),
      title4: const TextStyle(fontSize: 18),
    );
