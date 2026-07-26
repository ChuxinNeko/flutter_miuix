// Miuix Flutter 移植版 - 动效系统
// 源自 compose-miuix-ui/miuix 的 anim/ 目录（folmeSpring + 自定义 Easing）。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// 由阻尼比 [damping] 与响应时间 [response]（秒）构造一个 SpringDescription。
///
/// 对应 Kotlin 端的 `folmeSpring`：stiffness = (2π/response)²。
SpringDescription folmeSpring({
  required double damping,
  required double response,
}) {
  final stiffness = math.pow(2.0 * math.pi / response, 2).toDouble();
  // SpringDescription 用 dampingRatio + stiffness 推导 mass/damping。
  return SpringDescription.withDampingRatio(
    mass: 1.0,
    stiffness: stiffness,
    ratio: damping,
  );
}

/// 加速曲线。对应 Kotlin `AccelerateEasing`。
///
/// factor=1 时为 y=x²；factor 越大，缓入越夸张。
class AccelerateEasing extends Curve {
  const AccelerateEasing([this.factor = 1.0]) : assert(factor >= 0);

  final double factor;

  @override
  double transformInternal(double t) {
    if (factor == 1.0) return t * t;
    return math.pow(t, 2 * factor).toDouble();
  }
}

/// 减速曲线。对应 Kotlin `DecelerateEasing`。
///
/// factor=1 时为 1-(1-x)²；factor 越大，缓出越夸张。
class DecelerateEasing extends Curve {
  const DecelerateEasing([this.factor = 1.0]) : assert(factor >= 0);

  final double factor;

  @override
  double transformInternal(double t) {
    final inv = 1.0 - t;
    if (factor == 1.0) return 1.0 - inv * inv;
    return 1.0 - math.pow(inv, 2 * factor).toDouble();
  }
}

/// 正弦缓出曲线。对应 Kotlin `SinOutEasing`：sin(t·π/2)。
class SinOutEasing extends Curve {
  const SinOutEasing();

  @override
  double transformInternal(double t) => math.sin(t * math.pi / 2);
}

/// Miuix 常用动效曲线集合，按 HyperOS 交互习惯分类。
class MiuixMotion {
  MiuixMotion._();

  /// 标准缓出，用于进场/出现。
  static const Curve standardDecelerate = DecelerateEasing(1.0);

  /// 标准缓入，用于退场/消失。
  static const Curve standardAccelerate = AccelerateEasing(1.0);

  /// 正弦缓出，用于柔和的位移/缩放。
  static const Curve sinOut = SinOutEasing();

  /// 通用按压/状态切换的 spring（临界阻尼，无过冲，快速响应）。
  static SpringDescription get pressSpring =>
      folmeSpring(damping: 1.0, response: 0.35);

  /// 弹性切换 spring（轻微欠阻尼，有自然回弹）。
  static SpringDescription get bouncySpring =>
      folmeSpring(damping: 0.85, response: 0.45);
}
