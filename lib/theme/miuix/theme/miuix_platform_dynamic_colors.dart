// Miuix Flutter 移植版 - 平台动态取色
// 源自 compose-miuix-ui/miuix 的 theme/DynamicColors.kt（expect）与
// DynamicColors.android.kt / DynamicColors.skiko.kt（actual）。
// Android：用 dynamic_color 读系统壁纸取色种子（platformDynamicColors 的 Android 路径）。
// 其他平台 / 读取失败：回退固定种子 monetSystemColors（对应 skiko 实现）。
// SPDX-License-Identifier: Apache-2.0

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'miuix_colors.dart';
import 'miuix_dynamic_colors.dart';

/// 平台动态取色。对应 Kotlin `expect fun platformDynamicColors(dark)`。
///
/// Android（及支持的平台）：通过 [DynamicColorPlugin.getAccentColor] 读系统壁纸/主题
/// 种子色，非空则用 [miuixColorsFromSeed]（TonalSpot + Spec2021，与原版壁纸路径一致）。
/// 其他平台或读取失败：回退 [miuixMonetSystemColors]（固定种子 `0xFF6750A4`），
/// 对应原版 skiko 的 `= monetSystemColors(dark)`。
///
/// 注意：与 Compose 同步的 `@Composable` 不同，平台通道是**异步**，故本函数返回
/// [Future]。UI 层（[MiuixThemeController]）在结果就绪前用 [miuixMonetSystemColors]
/// 占位，避免闪烁。
Future<MiuixColors> miuixPlatformDynamicColors({required bool dark}) async {
  try {
    final Color? seed = await DynamicColorPlugin.getAccentColor();
    if (seed != null) {
      return miuixColorsFromSeed(
        seed: seed,
        colorSpec: MiuixThemeColorSpec.spec2021,
        paletteStyle: MiuixThemePaletteStyle.tonalSpot,
        dark: dark,
      );
    }
  } catch (_) {
    // 平台不支持 / 通道异常：走下方固定种子回退。
  }
  return miuixMonetSystemColors(dark: dark);
}
