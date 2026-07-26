// Miuix Flutter 移植版 - ProgressIndicator
// 源自 compose-miuix-ui/miuix 的 ProgressIndicator.kt。
// 使用 CustomPainter 与线性循环控制器复刻三种进度指示器。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/miuix_theme.dart';

/// 进度指示器颜色配置。对应 Kotlin `ProgressIndicatorColors`。
@immutable
class MiuixProgressIndicatorColors {
  const MiuixProgressIndicatorColors({
    required this.foregroundColor,
    required this.disabledForegroundColor,
    required this.backgroundColor,
  });

  /// 启用时的前景色。
  final Color foregroundColor;

  /// 禁用时的前景色。
  final Color disabledForegroundColor;

  /// 轨道背景色。
  final Color backgroundColor;

  /// 根据 [enabled] 返回前景色。
  Color foreground(bool enabled) =>
      enabled ? foregroundColor : disabledForegroundColor;

  /// 返回轨道背景色。
  Color background() => backgroundColor;
}

/// 进度指示器默认值。对应 Kotlin `ProgressIndicatorDefaults`。
class MiuixProgressIndicatorDefaults {
  MiuixProgressIndicatorDefaults._();

  static const double defaultLinearHeight = 6;
  static const double defaultCircularStrokeWidth = 4;
  static const double defaultCircularSize = 30;
  static const double defaultInfiniteStrokeWidth = 2;
  static const double defaultInfiniteOrbitingDotSize = 2;
  static const double defaultInfiniteSize = 20;

  /// 返回线性与圆形进度指示器的默认颜色。
  static MiuixProgressIndicatorColors defaultColors(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return MiuixProgressIndicatorColors(
      foregroundColor: colors.primary,
      disabledForegroundColor: colors.disabledPrimarySlider,
      backgroundColor: colors.secondaryContainer,
    );
  }
}

/// Miuix 风格线性进度指示器。对应 Kotlin `LinearProgressIndicator`。
///
/// [progress] 位于 0 到 1；为 null 时显示 1250ms 线性循环动画。
/// 即使进度为 0，前景仍保留一个高度宽的圆头胶囊。
class MiuixLinearProgressIndicator extends StatefulWidget {
  const MiuixLinearProgressIndicator({
    super.key,
    this.progress,
    this.colors,
    this.height = MiuixProgressIndicatorDefaults.defaultLinearHeight,
  });

  final double? progress;
  final MiuixProgressIndicatorColors? colors;
  final double height;

  @override
  State<MiuixLinearProgressIndicator> createState() =>
      _MiuixLinearProgressIndicatorState();
}

class _MiuixLinearProgressIndicatorState
    extends State<MiuixLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(MiuixLinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.progress == null) != (widget.progress == null)) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.progress == null) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        widget.colors ?? MiuixProgressIndicatorDefaults.defaultColors(context);
    final progress = widget.progress?.clamp(0.0, 1.0).toDouble();
    final paint = CustomPaint(
      painter: _LinearProgressPainter(
        progress: progress,
        foregroundColor: colors.foreground(true),
        backgroundColor: colors.background(),
        animation: _controller,
      ),
      size: Size(double.infinity, widget.height),
    );
    return Semantics(
      label: '进度',
      value: progress == null ? null : '${(progress * 100).round()}%',
      child: SizedBox(
        width: double.infinity,
        height: widget.height,
        child: paint,
      ),
    );
  }
}

class _LinearProgressPainter extends CustomPainter {
  _LinearProgressPainter({
    required this.progress,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.animation,
  }) : super(repaint: animation);

  final double? progress;
  final Color foregroundColor;
  final Color backgroundColor;
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final radius = Radius.circular(size.height / 2);
    final backgroundPaint = Paint()..color = backgroundColor;
    final foregroundPaint = Paint()..color = foregroundColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      backgroundPaint,
    );

    if (progress != null) {
      final minWidth = size.height;
      final width = minWidth + (size.width - minWidth) * progress!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, width, size.height),
          radius,
        ),
        foregroundPaint,
      );
      return;
    }

    for (var i = 0; i < 3; i++) {
      final position = animation.value - i * (0.45 + 0.55);
      final adjustedPosition = ((position % 1) + 1) % 1;
      if (adjustedPosition < 1 - 0.45) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.width * adjustedPosition,
              0,
              size.width * 0.45,
              size.height,
            ),
            radius,
          ),
          foregroundPaint,
        );
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.width * adjustedPosition,
              0,
              size.width * (1 - adjustedPosition),
              size.height,
            ),
            radius,
          ),
          foregroundPaint,
        );
        final remainingWidth = adjustedPosition + 0.45 - 1;
        if (remainingWidth > 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                0,
                0,
                size.width * remainingWidth,
                size.height,
              ),
              radius,
            ),
            foregroundPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_LinearProgressPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      foregroundColor != oldDelegate.foregroundColor ||
      backgroundColor != oldDelegate.backgroundColor;
}

/// Miuix 风格圆形进度指示器。对应 Kotlin `CircularProgressIndicator`。
///
/// [progress] 为 null 时，圆弧以 1000ms 周期旋转，并以 1600ms 周期在
/// 30° 与 120° 之间线性往返。
class MiuixCircularProgressIndicator extends StatefulWidget {
  const MiuixCircularProgressIndicator({
    super.key,
    this.progress,
    this.colors,
    this.strokeWidth =
        MiuixProgressIndicatorDefaults.defaultCircularStrokeWidth,
    this.size = MiuixProgressIndicatorDefaults.defaultCircularSize,
  });

  final double? progress;
  final MiuixProgressIndicatorColors? colors;
  final double strokeWidth;
  final double size;

  @override
  State<MiuixCircularProgressIndicator> createState() =>
      _MiuixCircularProgressIndicatorState();
}

class _MiuixCircularProgressIndicatorState
    extends State<MiuixCircularProgressIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _rotation;
  late final AnimationController _sweep;

  @override
  void initState() {
    super.initState();
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _syncAnimations();
  }

  @override
  void didUpdateWidget(MiuixCircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.progress == null) != (widget.progress == null)) {
      _syncAnimations();
    }
  }

  void _syncAnimations() {
    if (widget.progress == null) {
      _rotation.repeat();
      _sweep.repeat();
    } else {
      _rotation.stop();
      _sweep.stop();
    }
  }

  @override
  void dispose() {
    _rotation.dispose();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        widget.colors ?? MiuixProgressIndicatorDefaults.defaultColors(context);
    final progress = widget.progress?.clamp(0.0, 1.0).toDouble();
    return Semantics(
      label: '进度',
      value: progress == null ? null : '${(progress * 100).round()}%',
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(
          painter: _CircularProgressPainter(
            progress: progress,
            foregroundColor: colors.foreground(true),
            backgroundColor: colors.background(),
            strokeWidth: widget.strokeWidth,
            rotation: _rotation,
            sweep: _sweep,
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.rotation,
    required this.sweep,
  }) : super(repaint: Listenable.merge([rotation, sweep]));

  final double? progress;
  final Color foregroundColor;
  final Color backgroundColor;
  final double strokeWidth;
  final Animation<double> rotation;
  final Animation<double> sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final diameter = math.min(size.width, size.height);
    final radius = (diameter - strokeWidth) / 2;
    if (radius < 0) return;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startDegrees = progress == null ? rotation.value * 360 : -90.0;
    final sweepDegrees = progress == null
        ? (sweep.value <= 0.5
            ? 30 + 180 * sweep.value
            : 120 - 180 * (sweep.value - 0.5))
        : 0.1 + (360 - 0.1) * progress!;
    canvas.drawArc(
      rect,
      startDegrees * math.pi / 180,
      sweepDegrees * math.pi / 180,
      false,
      Paint()
        ..color = foregroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      foregroundColor != oldDelegate.foregroundColor ||
      backgroundColor != oldDelegate.backgroundColor ||
      strokeWidth != oldDelegate.strokeWidth;
}

/// 带轨道环与绕行圆点的无限进度指示器。对应 Kotlin `InfiniteProgressIndicator`。
class MiuixInfiniteProgressIndicator extends StatefulWidget {
  const MiuixInfiniteProgressIndicator({
    super.key,
    this.color = const Color(0xFF888888),
    this.size = MiuixProgressIndicatorDefaults.defaultInfiniteSize,
    this.strokeWidth =
        MiuixProgressIndicatorDefaults.defaultInfiniteStrokeWidth,
    this.orbitingDotSize =
        MiuixProgressIndicatorDefaults.defaultInfiniteOrbitingDotSize,
  });

  /// 默认值精确对应 Compose `Color.Gray`，不是 Flutter `Colors.grey`。
  final Color color;
  final double size;
  final double strokeWidth;
  final double orbitingDotSize;

  @override
  State<MiuixInfiniteProgressIndicator> createState() =>
      _MiuixInfiniteProgressIndicatorState();
}

class _MiuixInfiniteProgressIndicatorState
    extends State<MiuixInfiniteProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation;

  @override
  void initState() {
    super.initState();
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '进度',
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(
          painter: _InfiniteProgressPainter(
            color: widget.color,
            indicatorSize: widget.size,
            strokeWidth: widget.strokeWidth,
            orbitingDotSize: widget.orbitingDotSize,
            rotation: _rotation,
          ),
        ),
      ),
    );
  }
}

class _InfiniteProgressPainter extends CustomPainter {
  _InfiniteProgressPainter({
    required this.color,
    required this.indicatorSize,
    required this.strokeWidth,
    required this.orbitingDotSize,
    required this.rotation,
  }) : super(repaint: rotation);

  final Color color;
  final double indicatorSize;
  final double strokeWidth;
  final double orbitingDotSize;
  final Animation<double> rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (indicatorSize - strokeWidth) / 2;
    if (radius < 0) return;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
    final orbitRadius = radius - 2 * orbitingDotSize;
    final angle = rotation.value * 2 * math.pi;
    final dotCenter = center +
        Offset(orbitRadius * math.cos(angle), orbitRadius * math.sin(angle));
    canvas.drawCircle(dotCenter, orbitingDotSize, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_InfiniteProgressPainter oldDelegate) =>
      color != oldDelegate.color ||
      indicatorSize != oldDelegate.indicatorSize ||
      strokeWidth != oldDelegate.strokeWidth ||
      orbitingDotSize != oldDelegate.orbitingDotSize;
}
