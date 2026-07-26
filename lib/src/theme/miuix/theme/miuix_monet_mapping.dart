// Miuix Flutter 移植版 - Monet 角色映射
// 源自 compose-miuix-ui/miuix 的 theme/MonetMapping.kt。
// 把 MD3（Monet）动态配色的 27 个角色扁平化映射为 miuix 的 MiuixColors，
// 并把带透明度的颜色合成到合适的背景上，保证结果全不透明（与原版一致）。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import 'miuix_colors.dart';

/// MD3（Monet）动态配色的角色集合。对应 Kotlin `internal data class MonetRoles`。
///
/// 由 [miuixColorsFromSeed]（或平台壁纸取色）从 [DynamicScheme] 提取后填充，
/// 再交给 [mapMd3RolesToMiuixColors] 转换为 [MiuixColors]。
@immutable
class MiuixMonetRoles {
  const MiuixMonetRoles({
    required this.primary,
    required this.onPrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.outlineVariant,
    required this.onSurfaceVariant,
  });

  final Color primary;
  final Color onPrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color outline;
  final Color outlineVariant;
  final Color onSurfaceVariant;
}
/// 将前景色按 alpha 混合合成到背景色上。对应 Kotlin `compositeOver`。
Color _compositeOver(Color fg, Color bg) {
  final double fa = fg.a;
  final double ba = bg.a;
  final double outA = fa + ba * (1.0 - fa);
  if (outA == 0.0) return const Color(0x00000000);
  final double r = (fg.r * fa + bg.r * ba * (1.0 - fa)) / outA;
  final double g = (fg.g * fa + bg.g * ba * (1.0 - fa)) / outA;
  final double b = (fg.b * fa + bg.b * ba * (1.0 - fa)) / outA;
  return Color.from(alpha: outA, red: r, green: g, blue: b);
}

/// 合成后返回不透明色（丢弃 alpha）。对应 Kotlin `opaqueOver`。
Color _opaqueOver(Color fg, Color bg) {
  final Color c = _compositeOver(fg, bg);
  return Color.from(alpha: 1.0, red: c.r, green: c.g, blue: c.b);
}

/// 确保前景色在背景上不透明。对应 Kotlin `ensureOpaqueOver`。
Color _ensureOpaqueOver(Color fg, Color bg) =>
    fg.a >= 1.0 ? fg : _opaqueOver(fg, bg);

/// 把 MD3（Monet）角色映射为 miuix [MiuixColors]。对应 Kotlin
/// `mapMd3RolesToMiuixColorsCommon`。
///
/// 逐字段照搬原版映射；带透明度的 disabled / slider / onSurfaceSecondary 等
/// 通过 [_ensureOpaqueOver] 合成到对应背景上，保证结果全不透明。
MiuixColors mapMd3RolesToMiuixColors(
  MiuixMonetRoles roles, {
  required bool dark,
}) {
  final Color baseSurface = roles.surface;
  final Color baseSurfaceContainerHigh = roles.surfaceContainerHigh;
  final Color onSurfaceSecondaryOpaque =
      _ensureOpaqueOver(roles.onSurface.withValues(alpha: 0.8), baseSurface);
  final Color onSurfaceContainerHighOpaque = _ensureOpaqueOver(
      roles.onSurface.withValues(alpha: 0.8), baseSurfaceContainerHigh);
  final Color sliderBackground =
      _ensureOpaqueOver(roles.primary.withValues(alpha: 0.2), baseSurface);
  final Color disabledPrimaryOpaque =
      _ensureOpaqueOver(roles.primary.withValues(alpha: 0.38), baseSurface);
  final Color disabledOnPrimaryOpaque = _ensureOpaqueOver(
      roles.onPrimary.withValues(alpha: 0.38), disabledPrimaryOpaque);
  final Color disabledPrimaryButtonOpaque =
      _ensureOpaqueOver(roles.primary.withValues(alpha: 0.38), baseSurface);
  final Color disabledOnPrimaryButtonOpaque = _ensureOpaqueOver(
      roles.onPrimary.withValues(alpha: 0.6), disabledPrimaryButtonOpaque);
  final Color disabledPrimarySliderOpaque =
      _ensureOpaqueOver(roles.primary.withValues(alpha: 0.38), baseSurface);
  final Color disabledSecondaryOpaque = _ensureOpaqueOver(
      roles.outlineVariant.withValues(alpha: 0.5), baseSurface);
  final Color disabledOnSecondaryOpaque = _ensureOpaqueOver(
      roles.onSurface.withValues(alpha: 0.38), disabledSecondaryOpaque);
  final Color disabledSecondaryVariantOpaque = _ensureOpaqueOver(
      roles.surfaceContainerHigh.withValues(alpha: 0.6), baseSurface);
  final Color disabledOnSecondaryVariantOpaque = _ensureOpaqueOver(
      roles.onSurface.withValues(alpha: 0.38), disabledSecondaryVariantOpaque);

  return MiuixColors(
    primary: roles.primary,
    onPrimary: roles.onPrimary,
    primaryVariant: roles.primaryFixed,
    onPrimaryVariant: roles.onPrimaryFixed,
    error: roles.error,
    onError: roles.onError,
    errorContainer: roles.errorContainer,
    onErrorContainer: roles.onErrorContainer,
    disabledPrimary: disabledPrimaryOpaque,
    disabledOnPrimary: disabledOnPrimaryOpaque,
    disabledPrimaryButton: disabledPrimaryButtonOpaque,
    disabledOnPrimaryButton: disabledOnPrimaryButtonOpaque,
    disabledPrimarySlider: disabledPrimarySliderOpaque,
    primaryContainer: roles.primaryContainer,
    onPrimaryContainer: roles.onPrimaryContainer,
    secondary: roles.outlineVariant,
    onSecondary: roles.outline,
    secondaryVariant: roles.surfaceContainerHigh,
    onSecondaryVariant: roles.onSurface,
    disabledSecondary: disabledSecondaryOpaque,
    disabledOnSecondary: disabledOnSecondaryOpaque,
    disabledSecondaryVariant: disabledSecondaryVariantOpaque,
    disabledOnSecondaryVariant: disabledOnSecondaryVariantOpaque,
    secondaryContainer: roles.secondaryContainer,
    onSecondaryContainer: roles.onSecondaryContainer,
    secondaryContainerVariant: roles.surfaceContainerHighest,
    onSecondaryContainerVariant: roles.onSurfaceVariant,
    tertiaryContainer: roles.tertiaryContainer,
    onTertiaryContainer: roles.onTertiaryContainer,
    tertiaryContainerVariant: roles.onTertiaryContainer,
    background: roles.background,
    onBackground: roles.onBackground,
    onBackgroundVariant: roles.primary,
    surface: roles.surface,
    onSurface: roles.onSurface,
    surfaceVariant: roles.surfaceVariant,
    onSurfaceSecondary: onSurfaceSecondaryOpaque,
    onSurfaceVariantSummary: roles.onSurfaceVariant,
    onSurfaceVariantActions: roles.onSurfaceVariant,
    disabledOnSurface: roles.onSurface,
    surfaceContainer: roles.surfaceContainer,
    onSurfaceContainer: roles.onSurface,
    onSurfaceContainerVariant: roles.onSurfaceVariant,
    surfaceContainerHigh: roles.surfaceContainerHigh,
    onSurfaceContainerHigh: onSurfaceContainerHighOpaque,
    surfaceContainerHighest: roles.surfaceContainerHighest,
    onSurfaceContainerHighest: roles.onSurface,
    outline: roles.outline,
    dividerLine: roles.outlineVariant,
    windowDimming: dark
        ? const Color(0x99000000) // Black @ 0.6
        : const Color(0x4D000000), // Black @ 0.3
    sliderKeyPoint: roles.primary,
    sliderKeyPointForeground: roles.surfaceContainerHigh,
    sliderBackground: sliderBackground,
  );
}

