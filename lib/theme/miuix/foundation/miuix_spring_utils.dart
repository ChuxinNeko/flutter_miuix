// Miuix Flutter 移植版 - 弹簧与阻尼工具
// 源自 compose-miuix-ui/miuix 的 utils/SpringUtils.kt。
// 用纯数学复刻阻尼位移换算与临界阻尼欧拉弹簧引擎。
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// 对应 Kotlin `SpringMath` 里的常量集合。
class MiuixSpringDefaults {
  MiuixSpringDefaults._();

  /// 单帧最大步长（秒）。
  static const double maxFrameDeltaSeconds = 0.016;

  /// 单帧最小步长（秒）。
  static const double minFrameDeltaSeconds = 0.001;

  /// 高初速度阈值，超过后使用较慢自然周期。
  static const double highVelocityThreshold = 5000.0;

  /// 临界阻尼比。
  static const double criticalDampingRatio = 1.0;

  /// 标准自然周期（秒）。
  static const double standardSpringPeriod = 0.4;

  /// 高速时使用的自然周期（秒）。
  static const double slowerSpringPeriodForHighVelocity = 0.55;
}

/// 对应 Kotlin `SpringMath.obtainDampingDistance`。
///
/// 阻尼公式为 `x - x² + x³/3`；[normalizedInput] 会先夹取到 0..1。
double obtainDampingDistance(double normalizedInput, double range) {
  final x = normalizedInput.clamp(0.0, 1.0);
  final dampedFactor = x - math.pow(x, 2) + math.pow(x, 3) / 3;
  return dampedFactor * range;
}

/// 对应 Kotlin `SpringMath.obtainTouchDistance`，把阻尼位移还原为触摸位移。
///
/// 还原公式为 `range - range^(2/3) * (range - 3*offset)^(1/3)`。
double obtainTouchDistance(double currentPixelOffset, double range) {
  var absoluteOffset = currentPixelOffset.abs();
  final maximumOffset = obtainDampingDistance(1, range).abs();
  if (absoluteOffset <= 0) return 0;
  if (absoluteOffset >= maximumOffset) absoluteOffset = maximumOffset;

  final base = range - 3 * absoluteOffset;
  final signedCubeRoot = base.sign * math.pow(base.abs(), 1 / 3);
  final part2 = math.pow(range, 2 / 3) * signedCubeRoot;
  return range - part2;
}

/// 对应 Kotlin `SpringOperator`，以显式欧拉法计算下一帧速度。
@immutable
class MiuixSpringOperator {
  MiuixSpringOperator({
    required double dampingRatio,
    required double naturalPeriod,
  })  : assert(naturalPeriod > 0),
        _dampingCoefficient =
            2 * dampingRatio * (2 * math.pi / naturalPeriod),
        _stiffnessOverMass = math.pow(2 * math.pi / naturalPeriod, 2).toDouble();

  final double _dampingCoefficient;
  final double _stiffnessOverMass;

  /// 根据当前位置、目标位置和帧间隔计算新速度。
  double updateVelocity({
    required double currentVelocity,
    required double deltaTime,
    required double currentPosition,
    required double targetPosition,
  }) {
    final velocityDecayFactor = 1 - _dampingCoefficient * deltaTime;
    final springIncrease =
        _stiffnessOverMass * (targetPosition - currentPosition) * deltaTime;
    return currentVelocity * velocityDecayFactor + springIncrease;
  }
}

/// 对应 Kotlin `SpringEngine` 的临界阻尼逐帧引擎。
///
/// 可手动调用 [start]/[step]，也可通过 [runSettleAnimation] 使用 Flutter
/// [Ticker] 驱动，行为与源端 `withFrameNanos` 循环一致。
class MiuixSpringEngine {
  MiuixSpringOperator? _springOperator;
  double _targetPosition = 0;
  double _initialPosition = 0;
  double _initialVelocity = 0;

  /// 当前速度。
  double velocity = 0;

  /// 当前位置。
  double currentPosition = 0;

  bool _isAtEquilibrium() {
    if (_initialPosition < _targetPosition &&
        currentPosition > _targetPosition) {
      return true;
    }
    if (_initialPosition <= _targetPosition ||
        currentPosition >= _targetPosition) {
      return (_initialPosition == _targetPosition &&
              _initialVelocity.sign != currentPosition.sign) ||
          (currentPosition - _targetPosition).abs() < 1;
    }
    return true;
  }

  /// 初始化一次从 [startValue] 到 [targetValue] 的弹簧运动。
  void start({
    required double startValue,
    required double targetValue,
    required double initialVelocity,
  }) {
    currentPosition = startValue;
    _initialPosition = startValue;
    _targetPosition = targetValue;
    velocity = initialVelocity;
    _initialVelocity = initialVelocity;
    _springOperator = MiuixSpringOperator(
      dampingRatio: MiuixSpringDefaults.criticalDampingRatio,
      naturalPeriod:
          initialVelocity.abs() > MiuixSpringDefaults.highVelocityThreshold
              ? MiuixSpringDefaults.slowerSpringPeriodForHighVelocity
              : MiuixSpringDefaults.standardSpringPeriod,
    );
  }

  /// 推进一帧；返回 true 表示已到达平衡位置。
  bool step(double deltaTime) {
    final operator = _springOperator;
    if (operator == null) return false;
    final dt = deltaTime.clamp(
      MiuixSpringDefaults.minFrameDeltaSeconds,
      MiuixSpringDefaults.maxFrameDeltaSeconds,
    );
    velocity = operator.updateVelocity(
      currentVelocity: velocity,
      deltaTime: dt,
      currentPosition: currentPosition,
      targetPosition: _targetPosition,
    );
    currentPosition += dt * velocity;
    if (_isAtEquilibrium()) {
      currentPosition = _targetPosition;
      velocity = 0;
      return true;
    }
    return false;
  }

  /// 使用 [Ticker] 驱动到平衡，并在每帧调用 [onFrame]。
  ///
  /// [onSettle] 无论正常结束还是 [Ticker] 被取消都会在清理阶段调用。
  Future<void> runSettleAnimation({
    required TickerProvider vsync,
    required double startValue,
    double targetValue = 0,
    required double initialVelocity,
    required ValueChanged<double> onFrame,
    VoidCallback? onSettle,
  }) async {
    start(
      startValue: startValue,
      targetValue: targetValue,
      initialVelocity: initialVelocity,
    );
    final completer = Completer<void>();
    Duration? previousElapsed;
    late final Ticker ticker;
    ticker = vsync.createTicker((elapsed) {
      final previous = previousElapsed;
      previousElapsed = elapsed;
      if (previous == null) return;
      final finished = step(
        (elapsed - previous).inMicroseconds / Duration.microsecondsPerSecond,
      );
      onFrame(currentPosition);
      if (finished) {
        ticker.stop();
        if (!completer.isCompleted) completer.complete();
      }
    });
    ticker.start();
    try {
      await completer.future;
    } finally {
      ticker.dispose();
      onSettle?.call();
    }
  }
}
