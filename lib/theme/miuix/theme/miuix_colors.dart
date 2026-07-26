// Miuix Flutter 移植版 - 颜色系统
// 源自 compose-miuix-ui/miuix 的 Colors.kt，保持 HyperOS 设计 token 一致。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

/// Miuix 颜色方案。对应 Kotlin 端的 `top.yukonga.miuix.kmp.theme.Colors`。
///
/// 所有颜色均可通过 [copy] 覆盖。默认浅色/深色值由 [lightColorScheme] /
/// [darkColorScheme] 工厂提供，与 HyperOS 规范一致。
@immutable
class MiuixColors {
  const MiuixColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryVariant,
    required this.onPrimaryVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.disabledPrimary,
    required this.disabledOnPrimary,
    required this.disabledPrimaryButton,
    required this.disabledOnPrimaryButton,
    required this.disabledPrimarySlider,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryVariant,
    required this.onSecondaryVariant,
    required this.disabledSecondary,
    required this.disabledOnSecondary,
    required this.disabledSecondaryVariant,
    required this.disabledOnSecondaryVariant,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.secondaryContainerVariant,
    required this.onSecondaryContainerVariant,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.tertiaryContainerVariant,
    required this.background,
    required this.onBackground,
    required this.onBackgroundVariant,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceSecondary,
    required this.onSurfaceVariantSummary,
    required this.onSurfaceVariantActions,
    required this.disabledOnSurface,
    required this.surfaceContainer,
    required this.onSurfaceContainer,
    required this.onSurfaceContainerVariant,
    required this.surfaceContainerHigh,
    required this.onSurfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurfaceContainerHighest,
    required this.outline,
    required this.dividerLine,
    required this.windowDimming,
    required this.sliderKeyPoint,
    required this.sliderKeyPointForeground,
    required this.sliderBackground,
  });

  /// 主色。用于 Switch / Button / Slider。
  final Color primary;

  /// 主色上的文字颜色。
  final Color onPrimary;

  /// 主色变体。用于 Card。
  final Color primaryVariant;

  /// 主色变体上的文字颜色。
  final Color onPrimaryVariant;

  /// 错误色。
  final Color error;

  /// 错误色上的文字颜色。
  final Color onError;

  /// 错误容器色。
  final Color errorContainer;

  /// 错误容器上的文字颜色。
  final Color onErrorContainer;

  /// Switch 禁用时的主色。
  final Color disabledPrimary;

  /// Switch 禁用主色上的文字颜色。
  final Color disabledOnPrimary;

  /// Button 禁用时的主色。
  final Color disabledPrimaryButton;

  /// Button 禁用主色上的文字颜色。
  final Color disabledOnPrimaryButton;

  /// Slider 禁用时的主色。
  final Color disabledPrimarySlider;

  /// 主色容器色。
  final Color primaryContainer;

  /// 主色容器上的文字颜色。
  final Color onPrimaryContainer;

  /// 次级色。
  final Color secondary;

  /// 次级色上的文字颜色。
  final Color onSecondary;

  /// 次级色变体。
  final Color secondaryVariant;

  /// 次级色变体上的文字颜色。
  final Color onSecondaryVariant;

  /// 禁用次级色。
  final Color disabledSecondary;

  /// 禁用次级色上的文字颜色。
  final Color disabledOnSecondary;

  /// 禁用次级色变体。
  final Color disabledSecondaryVariant;

  /// 禁用次级色变体上的文字颜色。
  final Color disabledOnSecondaryVariant;

  /// 次级容器色。
  final Color secondaryContainer;

  /// 次级容器上的文字颜色。
  final Color onSecondaryContainer;

  /// 次级容器变体色。
  final Color secondaryContainerVariant;

  /// 次级容器变体上的文字颜色。
  final Color onSecondaryContainerVariant;

  /// 三级容器色。
  final Color tertiaryContainer;

  /// 三级容器上的文字颜色。
  final Color onTertiaryContainer;

  /// 三级容器变体色。
  final Color tertiaryContainerVariant;

  /// 应用背景色。
  final Color background;

  /// 背景上的文字颜色。
  final Color onBackground;

  /// 背景变体上的文字颜色。
  final Color onBackgroundVariant;

  /// Surface 色。
  final Color surface;

  /// Surface 上的文字颜色。
  final Color onSurface;

  /// Surface 变体色。
  final Color surfaceVariant;

  /// Surface 上的次级文字颜色。
  final Color onSurfaceSecondary;

  /// Surface 变体上的摘要文字颜色。
  final Color onSurfaceVariantSummary;

  /// Surface 变体上的操作文字颜色。
  final Color onSurfaceVariantActions;

  /// 禁用 Surface 上的文字颜色。
  final Color disabledOnSurface;

  /// Surface 容器色。
  final Color surfaceContainer;

  /// Surface 容器上的文字颜色。
  final Color onSurfaceContainer;

  /// Surface 容器变体上的文字颜色。
  final Color onSurfaceContainerVariant;

  /// 高 Surface 容器色。
  final Color surfaceContainerHigh;

  /// 高 Surface 容器上的文字颜色。
  final Color onSurfaceContainerHigh;

  /// 最高 Surface 容器色。
  final Color surfaceContainerHighest;

  /// 最高 Surface 容器上的文字颜色。
  final Color onSurfaceContainerHighest;

  /// 描边/边框色。
  final Color outline;

  /// 分隔线色。
  final Color dividerLine;

  /// 窗口遮罩色。用于 Dialog / Dropdown / Spinner / BottomSheet。
  final Color windowDimming;

  /// Slider 关键点色。
  final Color sliderKeyPoint;

  /// Slider 关键点前景色。
  final Color sliderKeyPointForeground;

  /// Slider 背景色。
  final Color sliderBackground;

  /// 复制并覆盖部分颜色。
  MiuixColors copy({
    Color? primary,
    Color? onPrimary,
    Color? primaryVariant,
    Color? onPrimaryVariant,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? disabledPrimary,
    Color? disabledOnPrimary,
    Color? disabledPrimaryButton,
    Color? disabledOnPrimaryButton,
    Color? disabledPrimarySlider,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryVariant,
    Color? onSecondaryVariant,
    Color? disabledSecondary,
    Color? disabledOnSecondary,
    Color? disabledSecondaryVariant,
    Color? disabledOnSecondaryVariant,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? secondaryContainerVariant,
    Color? onSecondaryContainerVariant,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? tertiaryContainerVariant,
    Color? background,
    Color? onBackground,
    Color? onBackgroundVariant,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? onSurfaceSecondary,
    Color? onSurfaceVariantSummary,
    Color? onSurfaceVariantActions,
    Color? disabledOnSurface,
    Color? surfaceContainer,
    Color? onSurfaceContainer,
    Color? onSurfaceContainerVariant,
    Color? surfaceContainerHigh,
    Color? onSurfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? onSurfaceContainerHighest,
    Color? outline,
    Color? dividerLine,
    Color? windowDimming,
    Color? sliderKeyPoint,
    Color? sliderKeyPointForeground,
    Color? sliderBackground,
  }) {
    return MiuixColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      onPrimaryVariant: onPrimaryVariant ?? this.onPrimaryVariant,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      disabledPrimary: disabledPrimary ?? this.disabledPrimary,
      disabledOnPrimary: disabledOnPrimary ?? this.disabledOnPrimary,
      disabledPrimaryButton:
          disabledPrimaryButton ?? this.disabledPrimaryButton,
      disabledOnPrimaryButton:
          disabledOnPrimaryButton ?? this.disabledOnPrimaryButton,
      disabledPrimarySlider:
          disabledPrimarySlider ?? this.disabledPrimarySlider,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryVariant: secondaryVariant ?? this.secondaryVariant,
      onSecondaryVariant: onSecondaryVariant ?? this.onSecondaryVariant,
      disabledSecondary: disabledSecondary ?? this.disabledSecondary,
      disabledOnSecondary: disabledOnSecondary ?? this.disabledOnSecondary,
      disabledSecondaryVariant:
          disabledSecondaryVariant ?? this.disabledSecondaryVariant,
      disabledOnSecondaryVariant:
          disabledOnSecondaryVariant ?? this.disabledOnSecondaryVariant,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      secondaryContainerVariant:
          secondaryContainerVariant ?? this.secondaryContainerVariant,
      onSecondaryContainerVariant:
          onSecondaryContainerVariant ?? this.onSecondaryContainerVariant,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      tertiaryContainerVariant:
          tertiaryContainerVariant ?? this.tertiaryContainerVariant,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      onBackgroundVariant: onBackgroundVariant ?? this.onBackgroundVariant,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceSecondary: onSurfaceSecondary ?? this.onSurfaceSecondary,
      onSurfaceVariantSummary:
          onSurfaceVariantSummary ?? this.onSurfaceVariantSummary,
      onSurfaceVariantActions:
          onSurfaceVariantActions ?? this.onSurfaceVariantActions,
      disabledOnSurface: disabledOnSurface ?? this.disabledOnSurface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      onSurfaceContainer: onSurfaceContainer ?? this.onSurfaceContainer,
      onSurfaceContainerVariant:
          onSurfaceContainerVariant ?? this.onSurfaceContainerVariant,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      onSurfaceContainerHigh:
          onSurfaceContainerHigh ?? this.onSurfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      onSurfaceContainerHighest:
          onSurfaceContainerHighest ?? this.onSurfaceContainerHighest,
      outline: outline ?? this.outline,
      dividerLine: dividerLine ?? this.dividerLine,
      windowDimming: windowDimming ?? this.windowDimming,
      sliderKeyPoint: sliderKeyPoint ?? this.sliderKeyPoint,
      sliderKeyPointForeground:
          sliderKeyPointForeground ?? this.sliderKeyPointForeground,
      sliderBackground: sliderBackground ?? this.sliderBackground,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MiuixColors &&
        other.primary == primary &&
        other.onPrimary == onPrimary &&
        other.primaryVariant == primaryVariant &&
        other.onPrimaryVariant == onPrimaryVariant &&
        other.error == error &&
        other.onError == onError &&
        other.errorContainer == errorContainer &&
        other.onErrorContainer == onErrorContainer &&
        other.disabledPrimary == disabledPrimary &&
        other.disabledOnPrimary == disabledOnPrimary &&
        other.disabledPrimaryButton == disabledPrimaryButton &&
        other.disabledOnPrimaryButton == disabledOnPrimaryButton &&
        other.disabledPrimarySlider == disabledPrimarySlider &&
        other.primaryContainer == primaryContainer &&
        other.onPrimaryContainer == onPrimaryContainer &&
        other.secondary == secondary &&
        other.onSecondary == onSecondary &&
        other.secondaryVariant == secondaryVariant &&
        other.onSecondaryVariant == onSecondaryVariant &&
        other.disabledSecondary == disabledSecondary &&
        other.disabledOnSecondary == disabledOnSecondary &&
        other.disabledSecondaryVariant == disabledSecondaryVariant &&
        other.disabledOnSecondaryVariant == disabledOnSecondaryVariant &&
        other.secondaryContainer == secondaryContainer &&
        other.onSecondaryContainer == onSecondaryContainer &&
        other.secondaryContainerVariant == secondaryContainerVariant &&
        other.onSecondaryContainerVariant == onSecondaryContainerVariant &&
        other.tertiaryContainer == tertiaryContainer &&
        other.onTertiaryContainer == onTertiaryContainer &&
        other.tertiaryContainerVariant == tertiaryContainerVariant &&
        other.background == background &&
        other.onBackground == onBackground &&
        other.onBackgroundVariant == onBackgroundVariant &&
        other.surface == surface &&
        other.onSurface == onSurface &&
        other.surfaceVariant == surfaceVariant &&
        other.onSurfaceSecondary == onSurfaceSecondary &&
        other.onSurfaceVariantSummary == onSurfaceVariantSummary &&
        other.onSurfaceVariantActions == onSurfaceVariantActions &&
        other.disabledOnSurface == disabledOnSurface &&
        other.surfaceContainer == surfaceContainer &&
        other.onSurfaceContainer == onSurfaceContainer &&
        other.onSurfaceContainerVariant == onSurfaceContainerVariant &&
        other.surfaceContainerHigh == surfaceContainerHigh &&
        other.onSurfaceContainerHigh == onSurfaceContainerHigh &&
        other.surfaceContainerHighest == surfaceContainerHighest &&
        other.onSurfaceContainerHighest == onSurfaceContainerHighest &&
        other.outline == outline &&
        other.dividerLine == dividerLine &&
        other.windowDimming == windowDimming &&
        other.sliderKeyPoint == sliderKeyPoint &&
        other.sliderKeyPointForeground == sliderKeyPointForeground &&
        other.sliderBackground == sliderBackground;
  }

  @override
  int get hashCode => Object.hashAll([
        primary, onPrimary, primaryVariant, onPrimaryVariant,
        error, onError, errorContainer, onErrorContainer,
        disabledPrimary, disabledOnPrimary, disabledPrimaryButton,
        disabledOnPrimaryButton, disabledPrimarySlider, primaryContainer,
        onPrimaryContainer, secondary, onSecondary, secondaryVariant,
        onSecondaryVariant, disabledSecondary, disabledOnSecondary,
        disabledSecondaryVariant, disabledOnSecondaryVariant,
        secondaryContainer, onSecondaryContainer, secondaryContainerVariant,
        onSecondaryContainerVariant, tertiaryContainer, onTertiaryContainer,
        tertiaryContainerVariant, background, onBackground, onBackgroundVariant,
        surface, onSurface, surfaceVariant, onSurfaceSecondary,
        onSurfaceVariantSummary, onSurfaceVariantActions, disabledOnSurface,
        surfaceContainer, onSurfaceContainer, onSurfaceContainerVariant,
        surfaceContainerHigh, onSurfaceContainerHigh, surfaceContainerHighest,
        onSurfaceContainerHighest, outline, dividerLine, windowDimming,
        sliderKeyPoint, sliderKeyPointForeground, sliderBackground,
      ]);
}

/// 默认浅色方案，与 HyperOS 规范一致。
MiuixColors lightColorScheme() => const MiuixColors(
      primary: Color(0xFF3482FF),
      onPrimary: Color(0xFFFFFFFF),
      primaryVariant: Color(0xFF3482FF),
      onPrimaryVariant: Color(0xFFAECDFF),
      error: Color(0xFFE94634),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFDF6F4),
      onErrorContainer: Color(0xFF410002),
      disabledPrimary: Color(0xFFC2D9FF),
      disabledOnPrimary: Color(0xFFF3F8FF),
      disabledPrimaryButton: Color(0xFFC2D9FF),
      disabledOnPrimaryButton: Color(0xFFFFFFFF),
      disabledPrimarySlider: Color(0xFFB8CFF5),
      primaryContainer: Color(0xFF5D9BFF),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFFE6E6E6),
      onSecondary: Color(0xFFFFFFFF),
      secondaryVariant: Color(0xFFF0F0F0),
      onSecondaryVariant: Color(0xFF303030),
      disabledSecondary: Color(0xFFF0F0F0),
      disabledOnSecondary: Color(0xFFFCFCFC),
      disabledSecondaryVariant: Color(0xFFF2F2F2),
      disabledOnSecondaryVariant: Color(0xFFB2B2B2),
      secondaryContainer: Color(0xFFF0F0F0),
      onSecondaryContainer: Color(0xFFA9A9A9),
      secondaryContainerVariant: Color(0xFFF0F0F0),
      onSecondaryContainerVariant: Color(0xFFA8A8A8),
      tertiaryContainer: Color(0xFFEAF2FF),
      onTertiaryContainer: Color(0xFF3482FF),
      tertiaryContainerVariant: Color(0xFFEAF2FF),
      background: Color(0xFFFFFFFF),
      onBackground: Color(0xFF000000),
      onBackgroundVariant: Color(0xFF8C93B0),
      surface: Color(0xFFF7F7F7),
      onSurface: Color(0xFF000000),
      surfaceVariant: Color(0xFFFFFFFF),
      onSurfaceSecondary: Color(0xCC000000),
      onSurfaceVariantSummary: Color(0x99000000),
      onSurfaceVariantActions: Color(0x66000000),
      disabledOnSurface: Color(0xFFB2B2B2),
      surfaceContainer: Color(0xFFFFFFFF),
      onSurfaceContainer: Color(0xFF000000),
      onSurfaceContainerVariant: Color(0xFF959595),
      surfaceContainerHigh: Color(0xFFE8E8E8),
      onSurfaceContainerHigh: Color(0xFFA2A2A2),
      surfaceContainerHighest: Color(0xFFE8E8E8),
      onSurfaceContainerHighest: Color(0xFF000000),
      outline: Color(0xFFD9D9D9),
      dividerLine: Color(0xFFE0E0E0),
      windowDimming: Color(0x4D000000),
      sliderKeyPoint: Color(0x4DA3B3CD),
      sliderKeyPointForeground: Color(0xFF6EB5FF),
      sliderBackground: Color(0x0F000000),
    );

/// 默认深色方案，与 HyperOS 规范一致。
MiuixColors darkColorScheme() => const MiuixColors(
      primary: Color(0xFF277AF7),
      onPrimary: Color(0xFFFFFFFF),
      primaryVariant: Color(0xFF0073DD),
      onPrimaryVariant: Color(0xFF99C7F1),
      error: Color(0xFFF12522),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFF2E0603),
      onErrorContainer: Color(0xFFFFDAD6),
      disabledPrimary: Color(0xFF253E64),
      disabledOnPrimary: Color(0xFF677993),
      disabledPrimaryButton: Color(0xFF253E64),
      disabledOnPrimaryButton: Color(0xFF677893),
      disabledPrimarySlider: Color(0xFF44587C),
      primaryContainer: Color(0xFF338FE4),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFF505050),
      onSecondary: Color(0xFFFFFFFF),
      secondaryVariant: Color(0xFF434343),
      onSecondaryVariant: Color(0xFFD9D9D9),
      disabledSecondary: Color(0xFF3F3F3F),
      disabledOnSecondary: Color(0xFF797979),
      disabledSecondaryVariant: Color(0xFF404040),
      disabledOnSecondaryVariant: Color(0xFF707170),
      secondaryContainer: Color(0xFF434343),
      onSecondaryContainer: Color(0xFF7C7C7C),
      secondaryContainerVariant: Color(0xFF4F4F4F),
      onSecondaryContainerVariant: Color(0xFF959595),
      tertiaryContainer: Color(0xFF2B3B54),
      onTertiaryContainer: Color(0xFF4788FF),
      tertiaryContainerVariant: Color(0xFF505050),
      background: Color(0xFF242424),
      onBackground: Color(0xE6FFFFFF),
      onBackgroundVariant: Color(0xFF787E96),
      surface: Color(0xFF000000),
      onSurface: Color(0xFFF2F2F2),
      surfaceVariant: Color(0xFF242424),
      onSurfaceSecondary: Color(0xCCFFFFFF),
      onSurfaceVariantSummary: Color(0x80FFFFFF),
      onSurfaceVariantActions: Color(0x66FFFFFF),
      disabledOnSurface: Color(0xFF666666),
      surfaceContainer: Color(0xFF242424),
      onSurfaceContainer: Color(0xE6FFFFFF),
      onSurfaceContainerVariant: Color(0xFF737373),
      surfaceContainerHigh: Color(0xFF242424),
      onSurfaceContainerHigh: Color(0xFF666666),
      surfaceContainerHighest: Color(0xFF2D2D2D),
      onSurfaceContainerHighest: Color(0xFFE9E9E9),
      outline: Color(0xFF404040),
      dividerLine: Color(0xFF393939),
      windowDimming: Color(0x99000000),
      sliderKeyPoint: Color(0x4D7A8AA6),
      sliderKeyPointForeground: Color(0xFF5DAAFF),
      sliderBackground: Color(0x26FFFFFF),
    );
