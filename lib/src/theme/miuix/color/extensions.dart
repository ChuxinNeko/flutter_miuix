// Miuix Flutter 移植版 - 颜色空间扩展
// 源自 compose-miuix-ui/miuix 的 color/api/Extensions.kt。
// 为 Flutter [Color] 增加转换到归一化 OkLab / HSV / OkLch 的扩展方法。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/painting.dart';

import 'hsv.dart';
import 'ok_lab.dart';
import 'ok_lch.dart';
import 'transforms.dart';

/// 对应 Kotlin `Color` 的颜色空间转换扩展。
extension MiuixColorSpaceExtensions on Color {
  /// 对应 Kotlin `Color.toOkLab`，转换为便于用户理解区间的 [OkLab]。
  ///
  /// 明度按 `l*100` 裁剪到 `[0, 100]`；a、b 先还原为 `x/0.4*100` 再裁剪到 `[-100, 100]`。
  OkLab toOkLab() {
    final lab = Transforms.colorToOkLab(this);
    final l = (lab[0] * 100.0).clamp(0.0, 100.0);
    final a = (lab[1] / 0.4 * 100.0).clamp(-100.0, 100.0);
    final b = (lab[2] / 0.4 * 100.0).clamp(-100.0, 100.0);
    return OkLab(l, a, b);
  }

  /// 对应 Kotlin `Color.toHsv`，转换为便于用户理解区间的 [Hsv]。
  ///
  /// 色相保留度数，饱和度、明度按 `x*100` 裁剪到 `[0, 100]`。
  Hsv toHsv() {
    final hsvArr = Transforms.colorToHsv(this);
    final h = hsvArr[0];
    final s = (hsvArr[1] * 100.0).clamp(0.0, 100.0);
    final v = (hsvArr[2] * 100.0).clamp(0.0, 100.0);
    return Hsv(h, s, v);
  }

  /// 对应 Kotlin `Color.toOkLch`，转换为便于用户理解区间的 [OkLch]。
  ///
  /// 明度按 `l*100` 裁剪到 `[0, 100]`；色度按 `c/0.4*100` 裁剪到 `[0, 100]`；色相已归一化，直接沿用。
  OkLch toOkLch() {
    final lch = Transforms.colorToOklch(this);
    final l = (lch[0] * 100.0).clamp(0.0, 100.0);
    final c = (lch[1] / 0.4 * 100.0).clamp(0.0, 100.0);
    final h = lch[2]; // 度数已在 Transforms 内规范化
    return OkLch(l, c, h);
  }
}
