// Miuix Flutter 移植版 - HSV 颜色空间
// 源自 compose-miuix-ui/miuix 的 color/space/Hsv.kt。
// 直接复刻 Compose `Color.hsv` 的 hsvToRgbComponent 算法，保留浮点精度而非 8 位取整。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// 对应 Kotlin `Hsv`，采用便于用户理解的归一化区间的 HSV 表示。
///
/// - [h]：色相，单位度，取值 `[0, 360]`。
/// - [s]：饱和度，百分比，取值 `[0, 100]`。
/// - [v]：明度/亮度，百分比，取值 `[0, 100]`。
@immutable
class Hsv {
  /// 以色相 [h]（度）、饱和度 [s]（百分比）、明度 [v]（百分比）构造 HSV 颜色。
  const Hsv(this.h, this.s, this.v);

  /// 对应 Kotlin `h`：色相，单位度，取值 `[0, 360]`。
  final double h;

  /// 对应 Kotlin `s`：饱和度，百分比，取值 `[0, 100]`。
  final double s;

  /// 对应 Kotlin `v`：明度/亮度，百分比，取值 `[0, 100]`。
  final double v;

  /// 对应 Kotlin `Hsv.toColor`，将 HSV 转换为 sRGB [Color]。
  ///
  /// 先把色相规范化到 `[0, 360)`、饱和度与明度裁剪到 `[0, 1]`，
  /// 再按 Compose `Color.hsv` 的算法逐分量求值，保留完整浮点精度。
  Color toColor([double alpha = 1.0]) {
    final hue = ((h % 360.0) + 360.0) % 360.0;
    final sN = (s / 100.0).clamp(0.0, 1.0);
    final vN = (v / 100.0).clamp(0.0, 1.0);
    return Color.from(
      alpha: alpha,
      red: _hsvToRgbComponent(5, hue, sN, vN),
      green: _hsvToRgbComponent(3, hue, sN, vN),
      blue: _hsvToRgbComponent(1, hue, sN, vN),
    );
  }

  /// 对应 Compose `hsvToRgbComponent`，返回第 [n] 个 sRGB 分量（0..1）。
  static double _hsvToRgbComponent(int n, double h, double s, double v) {
    final k = (n + h / 60.0) % 6.0;
    return v - v * s * math.max(0.0, math.min(k, math.min(4.0 - k, 1.0)));
  }

  /// 返回替换指定分量后的副本，对应 Kotlin data class 的 `copy`。
  Hsv copyWith({double? h, double? s, double? v}) =>
      Hsv(h ?? this.h, s ?? this.s, v ?? this.v);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hsv && other.h == h && other.s == s && other.v == v;

  @override
  int get hashCode => Object.hash(h, s, v);

  @override
  String toString() => 'Hsv(h: $h, s: $s, v: $v)';
}
