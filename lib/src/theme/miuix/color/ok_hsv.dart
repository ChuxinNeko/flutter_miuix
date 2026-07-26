// Miuix Flutter 移植版 - OkHSV 颜色空间
// 源自 compose-miuix-ui/miuix 的 color/space/OkHsv.kt。
// 归一化 OkHSV 表示，toColor 直接委托 Transforms.okhsvToColor（不额外裁剪）。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'transforms.dart';

/// 对应 Kotlin `OkHsv`，采用便于用户理解的归一化区间的 OkHSV 表示。
///
/// - [h]：色相，单位度，取值 `[0, 360]`。
/// - [s]：饱和度，百分比，取值 `[0, 100]`。
/// - [v]：明度/亮度，百分比，取值 `[0, 100]`。
@immutable
class OkHsv {
  /// 以色相 [h]（度）、饱和度 [s]（百分比）、明度 [v]（百分比）构造 OkHSV 颜色。
  const OkHsv(this.h, this.s, this.v);

  /// 对应 Kotlin `h`：色相，单位度，取值 `[0, 360]`。
  final double h;

  /// 对应 Kotlin `s`：饱和度，百分比，取值 `[0, 100]`。
  final double s;

  /// 对应 Kotlin `v`：明度/亮度，百分比，取值 `[0, 100]`。
  final double v;

  /// 对应 Kotlin `OkHsv.toColor`，直接委托 [Transforms.okhsvToColor]。
  ///
  /// 与 Kotlin 源保持一致，不对 h/s/v 或 alpha 做额外裁剪，原样传入。
  Color toColor([double alpha = 1.0]) =>
      Transforms.okhsvToColor(h, s, v, alpha);

  /// 返回替换指定分量后的副本，对应 Kotlin data class 的 `copy`。
  OkHsv copyWith({double? h, double? s, double? v}) =>
      OkHsv(h ?? this.h, s ?? this.s, v ?? this.v);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OkHsv && other.h == h && other.s == s && other.v == v;

  @override
  int get hashCode => Object.hash(h, s, v);

  @override
  String toString() => 'OkHsv(h: $h, s: $s, v: $v)';
}
