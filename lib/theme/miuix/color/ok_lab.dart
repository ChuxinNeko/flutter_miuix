// Miuix Flutter 移植版 - OkLab 颜色空间
// 源自 compose-miuix-ui/miuix 的 color/space/OkLab.kt。
// 归一化 OkLab 表示，toColor 经 Transforms.okLabToColor 映射回 sRGB。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'transforms.dart';

/// 对应 Kotlin `OkLab`，采用便于用户理解的归一化区间的 OkLAB 表示。
///
/// - [l]：明度百分比，取值 `0..100`。
/// - [a]：绿-红轴，取值 `-100..100`，映射到内部区间 `[-0.4, 0.4]`。
/// - [b]：蓝-黄轴，取值 `-100..100`，映射到内部区间 `[-0.4, 0.4]`。
@immutable
class OkLab {
  /// 以明度 [l]、绿-红轴 [a]、蓝-黄轴 [b]（均为百分比）构造 OkLab 颜色。
  const OkLab(this.l, this.a, this.b);

  /// 对应 Kotlin `l`：明度百分比，取值 `0..100`。
  final double l;

  /// 对应 Kotlin `a`：绿-红轴，取值 `-100..100`。
  final double a;

  /// 对应 Kotlin `b`：蓝-黄轴，取值 `-100..100`。
  final double b;

  /// 对应 Kotlin `OkLab.toColor`，将 OkLab 转换为 sRGB [Color]。
  ///
  /// 明度按 `l/100` 裁剪到 `[0, 1]`；a、b 先按 `x/100*0.4` 缩放再裁剪到 `[-0.4, 0.4]`，
  /// 随后交由 [Transforms.okLabToColor] 完成色域裁剪与 sRGB 输出。
  Color toColor([double alpha = 1.0]) {
    final lN = (l / 100.0).clamp(0.0, 1.0);
    final aN = (a / 100.0 * 0.4).clamp(-0.4, 0.4);
    final bN = (b / 100.0 * 0.4).clamp(-0.4, 0.4);
    return Transforms.okLabToColor(<double>[lN, aN, bN], alpha);
  }

  /// 返回替换指定分量后的副本，对应 Kotlin data class 的 `copy`。
  OkLab copyWith({double? l, double? a, double? b}) =>
      OkLab(l ?? this.l, a ?? this.a, b ?? this.b);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OkLab && other.l == l && other.a == a && other.b == b;

  @override
  int get hashCode => Object.hash(l, a, b);

  @override
  String toString() => 'OkLab(l: $l, a: $a, b: $b)';
}
