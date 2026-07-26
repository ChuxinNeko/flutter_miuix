// Miuix Flutter 移植版 - OkLCH 颜色空间
// 源自 compose-miuix-ui/miuix 的 color/space/OkLch.kt。
// 归一化 OkLCH 表示，toColor 经 Transforms.oklchToColor 映射回 sRGB。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'transforms.dart';

/// 对应 Kotlin `OkLch`，采用便于用户理解的归一化区间的 OkLCH 表示。
///
/// - [l]：明度百分比，取值 `0..100`。
/// - [c]：色度百分比，取值 `0..100`，映射到内部区间 `[0.0, 0.4]`。
/// - [h]：色相，单位度，取值 `[0, 360]`。
@immutable
class OkLch {
  /// 以明度 [l]、色度 [c]（均为百分比）与色相 [h]（度）构造 OkLCH 颜色。
  const OkLch(this.l, this.c, this.h);

  /// 对应 Kotlin `l`：明度百分比，取值 `0..100`。
  final double l;

  /// 对应 Kotlin `c`：色度百分比，取值 `0..100`。
  final double c;

  /// 对应 Kotlin `h`：色相，单位度，取值 `[0, 360]`。
  final double h;

  /// 对应 Kotlin `OkLch.toColor`，将 OkLCH 转换为 sRGB [Color]。
  ///
  /// 明度按 `l/100` 裁剪到 `[0, 1]`；色度先按 `c/100*0.4` 缩放再裁剪到 `[0, 0.4]`；
  /// 色相规范化到 `[0, 360)`，随后交由 [Transforms.oklchToColor] 完成色域裁剪。
  Color toColor([double alpha = 1.0]) {
    final lN = (l / 100.0).clamp(0.0, 1.0);
    final cN = (c / 100.0 * 0.4).clamp(0.0, 0.4);
    final hDeg = ((h % 360.0) + 360.0) % 360.0;
    return Transforms.oklchToColor(lN, cN, hDeg, alpha);
  }

  /// 返回替换指定分量后的副本，对应 Kotlin data class 的 `copy`。
  OkLch copyWith({double? l, double? c, double? h}) =>
      OkLch(l ?? this.l, c ?? this.c, h ?? this.h);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OkLch && other.l == l && other.c == c && other.h == h;

  @override
  int get hashCode => Object.hash(l, c, h);

  @override
  String toString() => 'OkLch(l: $l, c: $c, h: $h)';
}
