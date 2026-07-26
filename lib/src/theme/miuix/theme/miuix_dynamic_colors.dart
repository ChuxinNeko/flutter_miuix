// Miuix Flutter 移植版 - 动态取色（种子色 → 整套配色）
// 源自 compose-miuix-ui/miuix 的 theme/ThemeController.kt 的算法部分
// （colorsFromSeed / monetSystemColors / 枚举）。
// 用 Google 官方 material_color_utilities（HCT + 9 种 DynamicScheme）替代
// Kotlin 端的 com.materialkolor，行为同源。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import 'miuix_colors.dart';
import 'miuix_monet_mapping.dart';

/// Material 配色规范版本。对应 Kotlin `ThemeColorSpec`。
///
/// 说明：当前依赖的 material_color_utilities 0.13.0 仅实现 SPEC_2021。
/// 该枚举保留以兼容原版 API 与降级逻辑；[spec2025] 在受支持的 palette 上
/// 语义等价请求 2025，但底层实际按 2021 生成（与原版「不支持则降级」路径一致）。
enum MiuixThemeColorSpec {
  spec2021,
  spec2025,
}

/// 动态配色的 palette 风格。对应 Kotlin `ThemePaletteStyle`。
enum MiuixThemePaletteStyle {
  tonalSpot,
  neutral,
  vibrant,
  expressive,
  rainbow,
  fruitSalad,
  monochrome,
  fidelity,
  content,
}

/// 从种子色生成整套 miuix 配色。对应 Kotlin `colorsFromSeed`。
///
/// 按 [paletteStyle] 选择对应的 [DynamicScheme]，用 [MaterialDynamicColors]
/// 提取 27 个 MD3 角色，组成 [MiuixMonetRoles]，再经 [mapMd3RolesToMiuixColors]
/// 得到不透明的 [MiuixColors]。
///
/// [colorSpec] 目前仅影响语义（见 [MiuixThemeColorSpec]）；底层按 SPEC_2021 生成。
MiuixColors miuixColorsFromSeed({
  required Color seed,
  MiuixThemeColorSpec colorSpec = MiuixThemeColorSpec.spec2021,
  MiuixThemePaletteStyle paletteStyle = MiuixThemePaletteStyle.tonalSpot,
  required bool dark,
}) {
  final Hct hct = Hct.fromInt(_argbOf(seed));
  const double contrast = 0.0;

  final DynamicScheme scheme = switch (paletteStyle) {
    MiuixThemePaletteStyle.tonalSpot => SchemeTonalSpot(
        sourceColorHct: hct, isDark: dark, contrastLevel: contrast),
    MiuixThemePaletteStyle.neutral => SchemeNeutral(
        sourceColorHct: hct, isDark: dark, contrastLevel: contrast),
    MiuixThemePaletteStyle.vibrant => SchemeVibrant(
        sourceColorHct: hct, isDark: dark, contrastLevel: contrast),
    MiuixThemePaletteStyle.expressive => SchemeExpressive(
        sourceColorHct: hct, isDark: dark, contrastLevel: contrast),
    MiuixThemePaletteStyle.rainbow => SchemeRainbow(
        sourceColorHct: hct, isDark: dark, contrastLevel: contrast),
    MiuixThemePaletteStyle.fruitSalad => SchemeFruitSalad(
        sourceColorHct: hct, isDark: dark, contrastLevel: contrast),
    MiuixThemePaletteStyle.monochrome => SchemeMonochrome(
        sourceColorHct: hct, isDark: dark, contrastLevel: contrast),
    MiuixThemePaletteStyle.fidelity => SchemeFidelity(
        sourceColorHct: hct, isDark: dark, contrastLevel: contrast),
    MiuixThemePaletteStyle.content => SchemeContent(
        sourceColorHct: hct, isDark: dark, contrastLevel: contrast),
  };

  // MaterialDynamicColors 的角色是静态成员，直接类名访问。
  Color role(DynamicColor c) => Color(c.getArgb(scheme));

  final roles = MiuixMonetRoles(
    primary: role(MaterialDynamicColors.primary),
    onPrimary: role(MaterialDynamicColors.onPrimary),
    primaryFixed: role(MaterialDynamicColors.primaryFixed),
    onPrimaryFixed: role(MaterialDynamicColors.onPrimaryFixed),
    error: role(MaterialDynamicColors.error),
    onError: role(MaterialDynamicColors.onError),
    errorContainer: role(MaterialDynamicColors.errorContainer),
    onErrorContainer: role(MaterialDynamicColors.onErrorContainer),
    primaryContainer: role(MaterialDynamicColors.primaryContainer),
    onPrimaryContainer: role(MaterialDynamicColors.onPrimaryContainer),
    secondary: role(MaterialDynamicColors.secondary),
    onSecondary: role(MaterialDynamicColors.onSecondary),
    secondaryContainer: role(MaterialDynamicColors.secondaryContainer),
    onSecondaryContainer: role(MaterialDynamicColors.onSecondaryContainer),
    tertiaryContainer: role(MaterialDynamicColors.tertiaryContainer),
    onTertiaryContainer: role(MaterialDynamicColors.onTertiaryContainer),
    background: role(MaterialDynamicColors.background),
    onBackground: role(MaterialDynamicColors.onBackground),
    surface: role(MaterialDynamicColors.surface),
    onSurface: role(MaterialDynamicColors.onSurface),
    surfaceVariant: role(MaterialDynamicColors.surfaceVariant),
    surfaceContainer: role(MaterialDynamicColors.surfaceContainer),
    surfaceContainerHigh: role(MaterialDynamicColors.surfaceContainerHigh),
    surfaceContainerHighest:
        role(MaterialDynamicColors.surfaceContainerHighest),
    outline: role(MaterialDynamicColors.outline),
    outlineVariant: role(MaterialDynamicColors.outlineVariant),
    onSurfaceVariant: role(MaterialDynamicColors.onSurfaceVariant),
  );

  return mapMd3RolesToMiuixColors(roles, dark: dark);
}

/// 默认 Monet 配色：固定种子 `0xFF6750A4` + TonalSpot + Spec2021。
/// 对应 Kotlin `monetSystemColors`，也是所有非 Android 平台的 platformDynamicColors 回退。
MiuixColors miuixMonetSystemColors({required bool dark}) => miuixColorsFromSeed(
      seed: const Color(0xFF6750A4),
      colorSpec: MiuixThemeColorSpec.spec2021,
      paletteStyle: MiuixThemePaletteStyle.tonalSpot,
      dark: dark,
    );

/// 取 [Color] 的 ARGB int（0xAARRGGBB），供 MCU 的 [Hct.fromInt] 使用。
int _argbOf(Color c) {
  int ch(double v) => (v * 255.0).round().clamp(0, 255);
  return (ch(c.a) << 24) | (ch(c.r) << 16) | (ch(c.g) << 8) | ch(c.b);
}
