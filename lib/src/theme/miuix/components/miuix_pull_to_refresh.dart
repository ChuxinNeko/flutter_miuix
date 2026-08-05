// Miuix Flutter 移植版 - PullToRefresh
// 源自 compose-miuix-ui/miuix 的 PullToRefresh.kt。
// 使用 ScrollNotification、阻尼拖拽和临界阻尼弹簧复刻状态机与指示器。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme/miuix_text_styles.dart';
import '../theme/miuix_theme.dart';
import 'miuix_top_app_bar.dart';

/// 下拉刷新指示器的五种视觉状态。
enum MiuixRefreshState {
  idle,
  pulling,
  thresholdReached,
  refreshing,
  refreshComplete,
}

/// 下拉刷新的默认值。
class MiuixPullToRefreshDefaults {
  MiuixPullToRefreshDefaults._();

  /// Compose `Color.Gray` 的精确值。
  static const Color color = Color(0xFF888888);
  static const double circleSize = 20;
  static const double refreshThreshold = 0.25;
  static const List<String> refreshTexts = <String>[
    'Pull down to refresh',
    'Release to refresh',
    'Refreshing...',
    'Refreshed successfully',
  ];
  static const TextStyle refreshTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: color,
  );
}

/// 保存下拉距离、进度和刷新视觉状态的控制器。
///
/// [refreshThreshold] 表示完整阻尼拖拽范围中触发刷新的比例，取值会限制在
/// 0 到 1。刷新业务状态仍应由 [MiuixPullToRefresh.isRefreshing] 提升管理。
class MiuixPullToRefreshController extends ChangeNotifier {
  MiuixPullToRefreshController({
    double refreshThreshold = MiuixPullToRefreshDefaults.refreshThreshold,
  }) : _refreshThreshold = refreshThreshold.clamp(0.0, 1.0);

  double _refreshThreshold;
  double _containerHeight = 0;
  double _maxDragDistance = 0;
  double _fullDragRange = 0;
  double _visualThresholdOffset = 0;
  double _triggerProgressOffset = 0;
  double _dragOffset = 0;
  double _currentTouch = 0;
  double _completeProgress = 1;
  MiuixRefreshState _refreshState = MiuixRefreshState.idle;

  /// 当前刷新视觉状态。
  MiuixRefreshState get refreshState => _refreshState;

  /// 当前阻尼后的下拉距离（逻辑像素）。
  double get dragOffset => _dragOffset;

  /// 相对于有效阈值的进度。
  double get pullProgress {
    final threshold = math.max(_visualThresholdOffset, _triggerProgressOffset);
    return threshold > 0 ? (_dragOffset / threshold).clamp(0.0, 1.0) : 0;
  }

  /// 相对于完整阻尼拖拽范围的进度。
  double get fullDragProgress =>
      _fullDragRange > 0 ? (_dragOffset / _fullDragRange).clamp(0.0, 1.0) : 0;

  /// 指示器从零缩放到完整尺寸的进度。
  double get visualProgress {
    final end = math.min(_visualThresholdOffset, _triggerProgressOffset);
    if (end > 0) return (_dragOffset / end).clamp(0.0, 1.0);
    return _dragOffset > 0 ? 1 : 0;
  }

  /// 触发阈值，取值范围为 0 到 1。
  double get refreshThreshold => _refreshThreshold;

  set refreshThreshold(double value) {
    final next = value.clamp(0.0, 1.0);
    if (next == _refreshThreshold) return;
    _refreshThreshold = next;
    _configure(_containerHeight);
  }

  void _configure(double height) {
    if (!height.isFinite || height <= 0) return;
    _containerHeight = height;
    _maxDragDistance = height;
    _fullDragRange = _obtainDampingDistance(1, height);
    _visualThresholdOffset = height / 24;
    _triggerProgressOffset = _refreshThreshold * _fullDragRange;
    notifyListeners();
  }

  void _applyDrag(double delta) {
    if (delta == 0 || _maxDragDistance <= 0) return;
    _currentTouch = (_currentTouch + delta).clamp(
      -_maxDragDistance,
      _maxDragDistance,
    );
    final normalized = math.min(_currentTouch.abs() / _maxDragDistance, 1.0);
    _setOffset(
      _currentTouch.sign * _obtainDampingDistance(normalized, _maxDragDistance),
      deriveState: true,
    );
  }

  void _setOffset(double value, {bool deriveState = false}) {
    _dragOffset = value;
    if (deriveState) {
      _refreshState = switch (value) {
        > 0 when value >= _triggerProgressOffset =>
          MiuixRefreshState.thresholdReached,
        > 0 => MiuixRefreshState.pulling,
        _ => MiuixRefreshState.idle,
      };
    }
    notifyListeners();
  }

  void _setState(MiuixRefreshState value) {
    if (_refreshState == value) return;
    _refreshState = value;
    notifyListeners();
  }

  void _setCompleteProgress(double value) {
    _completeProgress = value;
    notifyListeners();
  }

  void _syncTouchToOffset() {
    _currentTouch = _obtainTouchDistance(_dragOffset, _maxDragDistance);
  }
}

/// Miuix 风格下拉刷新容器。
///
/// [child] 应包含一个纵向可滚动组件。短内容若也要接受下拉手势，请为滚动
/// 组件设置 [AlwaysScrollableScrollPhysics]。Flutter 的滚动通知只能观察、不能像
/// Compose `NestedScrollConnection` 一样消费位移；本组件在顶边 overscroll 时驱动
/// 等价状态，并通过增长的头部自然下推内容。
class MiuixPullToRefresh extends StatefulWidget {
  const MiuixPullToRefresh({
    super.key,
    required this.isRefreshing,
    required this.onRefresh,
    required this.child,
    this.controller,
    this.contentPadding = EdgeInsets.zero,
    this.topAppBarScrollBehavior,
    this.color = MiuixPullToRefreshDefaults.color,
    this.circleSize = MiuixPullToRefreshDefaults.circleSize,
    this.refreshTexts = MiuixPullToRefreshDefaults.refreshTexts,
    this.refreshTextStyle = MiuixPullToRefreshDefaults.refreshTextStyle,
    this.onPullProgress,
  }) : assert(circleSize >= 0);

  /// 由调用方提升管理的刷新状态。
  final bool isRefreshing;

  /// 用户越过阈值并松手后调用；应尽快把 [isRefreshing] 设为 true。
  final VoidCallback onRefresh;
  final Widget child;
  final MiuixPullToRefreshController? controller;
  final EdgeInsetsGeometry contentPadding;
  final MiuixScrollBehavior? topAppBarScrollBehavior;
  final Color color;
  final double circleSize;
  final List<String> refreshTexts;
  final TextStyle refreshTextStyle;

  /// 完整阻尼拖拽范围内的实时进度；挂载时也会调用一次。
  final ValueChanged<double>? onPullProgress;

  @override
  State<MiuixPullToRefresh> createState() => _MiuixPullToRefreshState();
}

class _MiuixPullToRefreshState extends State<MiuixPullToRefresh>
    with TickerProviderStateMixin {
  late MiuixPullToRefreshController _controller;
  late final AnimationController _spring;
  late final AnimationController _completion;
  late final AnimationController _rotation;

  int _pointerCount = 0;
  bool _isTouching = false;
  bool _isRefreshingInternally = false;
  bool _isProcessingRelease = false;
  bool _isRebounding = false;
  int _animationGeneration = 0;
  double _lastReportedProgress = double.nan;
  bool _hapticArmed = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? MiuixPullToRefreshController();
    _controller.addListener(_handleControllerChange);
    _spring = AnimationController.unbounded(vsync: this)
      ..addListener(_driveSpring);
    _completion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(_driveCompletion);
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: math.Random().nextDouble(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reportProgress(force: true);
      _syncHoistedState();
    });
  }

  @override
  void didUpdateWidget(MiuixPullToRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleControllerChange);
      _controller = widget.controller ?? MiuixPullToRefreshController();
      _controller.addListener(_handleControllerChange);
      _lastReportedProgress = double.nan;
    }
    if (oldWidget.isRefreshing != widget.isRefreshing ||
        oldWidget.controller != widget.controller) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncHoistedState();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _spring.dispose();
    _completion.dispose();
    _rotation.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    _reportProgress();
    final reached =
        _controller.refreshState == MiuixRefreshState.thresholdReached;
    if (reached && _hapticArmed) {
      _hapticArmed = false;
      HapticFeedback.selectionClick();
    } else if (!reached) {
      _hapticArmed = true;
    }
    if (mounted) setState(() {});
  }

  void _reportProgress({bool force = false}) {
    final progress = _controller.fullDragProgress;
    if (force || progress != _lastReportedProgress) {
      _lastReportedProgress = progress;
      widget.onPullProgress?.call(progress);
    }
  }

  void _syncHoistedState() {
    if (!widget.isRefreshing &&
        _controller.refreshState == MiuixRefreshState.refreshing) {
      _finishRefreshing();
    } else if (widget.isRefreshing &&
        _controller.refreshState == MiuixRefreshState.idle) {
      _showRefreshing();
    }
  }

  Future<bool> _animateSpringTo(double target) async {
    final generation = ++_animationGeneration;
    _spring.value = _controller.dragOffset;
    final spring = SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: math.pow(2 * math.pi / 0.4, 2).toDouble(),
      ratio: 1,
    );
    try {
      await _spring
          .animateWith(SpringSimulation(spring, _spring.value, target, 0))
          .orCancel;
    } on TickerCanceled {
      return false;
    }
    if (!mounted || generation != _animationGeneration) return false;
    _controller._setOffset(target);
    _controller._syncTouchToOffset();
    return true;
  }

  void _driveSpring() {
    _controller._setOffset(_spring.value);
    _controller._syncTouchToOffset();
  }

  void _cancelSpring() {
    _animationGeneration++;
    _spring.stop(canceled: true);
  }

  Future<void> _showRefreshing() async {
    if (_isRefreshingInternally ||
        _controller.refreshState != MiuixRefreshState.idle ||
        !widget.isRefreshing) {
      return;
    }
    _isRefreshingInternally = true;
    _controller._setState(MiuixRefreshState.refreshing);
    _rotation.repeat();
    while (mounted &&
        widget.isRefreshing &&
        _controller.refreshState == MiuixRefreshState.refreshing) {
      final target = _controller._visualThresholdOffset;
      await _animateSpringTo(target);
      if ((_controller.dragOffset - _controller._visualThresholdOffset).abs() <
          0.01) {
        break;
      }
    }
    if (mounted && !widget.isRefreshing) _finishRefreshing();
  }

  Future<void> _startRefreshing() async {
    if (_isRefreshingInternally) return;
    _isRefreshingInternally = true;
    final settled = await _animateSpringTo(_controller._visualThresholdOffset);
    if (!mounted) return;
    if (!settled) {
      // 回弹到静止位的过程中被新的下拉取消（_cancelSpring）：释放内部锁，
      // 否则后续所有松手都会因 _isRefreshingInternally 提前返回，
      // 指示器卡在拉长状态永不回弹。
      _isRefreshingInternally = false;
      return;
    }
    if (_isTouching) {
      _isRefreshingInternally = false;
      return;
    }
    _controller._setState(MiuixRefreshState.refreshing);
    _rotation.repeat();
    if (!widget.isRefreshing) widget.onRefresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncHoistedState();
    });
  }

  Future<void> _finishRefreshing() async {
    if (!_isRefreshingInternally || widget.isRefreshing) return;
    _cancelSpring();
    _isRefreshingInternally = false;
    _rotation.stop();
    _controller._setState(MiuixRefreshState.refreshComplete);
    final threshold = _controller._visualThresholdOffset;
    final initial = threshold > 0
        ? 1 - (_controller.dragOffset / threshold).clamp(0.0, 1.0)
        : 1.0;
    _controller._setCompleteProgress(initial);
    _completion.value = initial;
    try {
      await _completion
          .animateTo(1, curve: const Cubic(0, 0, 0, 0.37))
          .orCancel;
    } on TickerCanceled {
      return;
    }
    if (!mounted) return;
    _controller._setOffset(0);
    _controller._syncTouchToOffset();
    _controller._setState(MiuixRefreshState.idle);
  }

  void _driveCompletion() {
    _controller._setCompleteProgress(_completion.value);
    _controller._setOffset(
      _controller._visualThresholdOffset * (1 - _completion.value),
    );
    _controller._syncTouchToOffset();
  }

  Future<void> _handlePointerRelease() async {
    if (_isProcessingRelease || _isRefreshingInternally || _isRebounding) {
      return;
    }
    _isTouching = false;
    _isProcessingRelease = true;
    try {
      if (_controller.dragOffset > 0 &&
          _controller.dragOffset >= _controller._triggerProgressOffset) {
        await _startRefreshing();
      } else {
        _isRebounding = true;
        await _animateSpringTo(0);
        _isRebounding = false;
        if (!_isTouching) {
          _controller._setState(MiuixRefreshState.idle);
        }
      }
    } finally {
      _isRebounding = false;
      _isProcessingRelease = false;
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final state = _controller.refreshState;
    if (state == MiuixRefreshState.idle) {
      final behavior = widget.topAppBarScrollBehavior;
      if (behavior is MiuixExitUntilCollapsedScrollBehavior) {
        behavior.handleScroll(notification);
      }
    }

    if (state == MiuixRefreshState.refreshing ||
        state == MiuixRefreshState.refreshComplete ||
        notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical) {
      return false;
    }

    if (notification is OverscrollNotification) {
      final delta = _pullDownOverscroll(notification);
      if (delta > 0 && notification.metrics.extentBefore == 0) {
        _isTouching = true;
        _cancelSpring();
        _controller._applyDrag(delta);
      }
    } else if (notification is ScrollUpdateNotification &&
        _controller.dragOffset > 0) {
      final delta = _upwardScrollDelta(notification);
      if (delta < 0) {
        _isTouching = true;
        _cancelSpring();
        _controller._applyDrag(delta);
      }
    } else if (notification is ScrollEndNotification &&
        _pointerCount == 0 &&
        (state == MiuixRefreshState.pulling ||
            state == MiuixRefreshState.thresholdReached)) {
      _handlePointerRelease();
    }
    return false;
  }

  double _pullDownOverscroll(OverscrollNotification notification) {
    final value = notification.overscroll;
    return switch (notification.metrics.axisDirection) {
      AxisDirection.down => value < 0 ? -value : 0,
      AxisDirection.up => value > 0 ? value : 0,
      _ => 0,
    };
  }

  double _upwardScrollDelta(ScrollUpdateNotification notification) {
    final value = notification.scrollDelta ?? 0;
    return switch (notification.metrics.axisDirection) {
      AxisDirection.down => value > 0 ? -value : 0,
      AxisDirection.up => value < 0 ? value : 0,
      _ => 0,
    };
  }

  String get _refreshText {
    String at(int index) =>
        index < widget.refreshTexts.length ? widget.refreshTexts[index] : '';
    return switch (_controller.refreshState) {
      MiuixRefreshState.idle => '',
      MiuixRefreshState.pulling =>
        _controller.visualProgress > 0.5 ? at(0) : '',
      MiuixRefreshState.thresholdReached => at(1),
      MiuixRefreshState.refreshing => at(2),
      MiuixRefreshState.refreshComplete => at(3),
    };
  }

  double get _refreshTextAlpha => switch (_controller.refreshState) {
    MiuixRefreshState.idle => 0,
    MiuixRefreshState.pulling =>
      _controller.visualProgress > 0.6
          ? (_controller.visualProgress - 0.5) * 2
          : 0,
    MiuixRefreshState.thresholdReached => 1,
    MiuixRefreshState.refreshing =>
      ((_controller.visualProgress - 0.5) * 2).clamp(0.0, 1.0),
    MiuixRefreshState.refreshComplete =>
      (1 - _controller._completeProgress * 1.95).clamp(0.0, 1.0),
  };

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = widget.contentPadding.resolve(
      Directionality.of(context),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        if ((_controller._containerHeight - height).abs() > 0.01) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _controller._configure(height);
            if (_controller.refreshState == MiuixRefreshState.refreshing &&
                !_spring.isAnimating) {
              _animateSpringTo(_controller._visualThresholdOffset);
            }
          });
        }

        final stretch =
            _controller.dragOffset - _controller._visualThresholdOffset;
        final indicatorHeight =
            _controller.refreshState == MiuixRefreshState.idle
            ? 0.0
            : stretch <= 0
            ? widget.circleSize * _controller.visualProgress
            : widget.circleSize + stretch;
        final headerHeight = _controller.refreshState == MiuixRefreshState.idle
            ? 0.0
            : stretch <= 0
            ? (widget.circleSize + 36) * _controller.visualProgress
            : widget.circleSize + 36 + stretch;
        final semanticValue = _refreshText;

        return Semantics(
          container: true,
          liveRegion:
              _controller.refreshState == MiuixRefreshState.refreshing ||
              _controller.refreshState == MiuixRefreshState.refreshComplete,
          label: '下拉刷新',
          value: semanticValue.isEmpty ? null : semanticValue,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              _pointerCount++;
              _isTouching = true;
            },
            onPointerUp: (_) {
              _pointerCount = math.max(0, _pointerCount - 1);
              if (_pointerCount == 0) _handlePointerRelease();
            },
            onPointerCancel: (_) {
              _pointerCount = math.max(0, _pointerCount - 1);
              if (_pointerCount == 0) _handlePointerRelease();
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: Column(
                children: [
                  Transform.translate(
                    offset: Offset(0, resolvedPadding.top),
                    child: SizedBox(
                      width: double.infinity,
                      height: headerHeight,
                      child: ClipRect(
                        // 刷新头以动画高度渐显，内容（指示圈 + 文案）按自然高度
                        // 布局、顶部锚定，由 ClipRect 裁剪未展开部分；不加
                        // OverflowBox 时 Column 会在受限高度里布局，下拉中段
                        // 触发 RenderFlex 溢出断言（视觉上本就被裁剪）。
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minHeight: 0,
                          maxHeight: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: indicatorHeight,
                                width: double.infinity,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: SizedBox.square(
                                    dimension: widget.circleSize,
                                    child: CustomPaint(
                                      painter: _RefreshIndicatorPainter(
                                        controller: _controller,
                                        color: widget.color,
                                        circleSize: widget.circleSize,
                                        rotation: _rotation,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: _refreshTextAlpha,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _refreshText,
                                    style: widget.refreshTextStyle.copyWith(
                                      color: widget.color,
                                    ).withMiuixWeight(
                                        MiuixTheme.of(context).fontWeightAdjustment),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RefreshIndicatorPainter extends CustomPainter {
  _RefreshIndicatorPainter({
    required this.controller,
    required this.color,
    required this.circleSize,
    required this.rotation,
  }) : super(repaint: Listenable.merge([controller, rotation]));

  final MiuixPullToRefreshController controller;
  final Color color;
  final double circleSize;
  final Animation<double> rotation;

  @override
  void paint(Canvas canvas, Size size) {
    if (circleSize <= 0 || controller.refreshState == MiuixRefreshState.idle) {
      return;
    }
    final strokeWidth = circleSize / 11;
    final radius = math.max(size.shortestSide / 2, circleSize / 3.5);
    final center = Offset(circleSize / 2, circleSize / 1.8);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    switch (controller.refreshState) {
      case MiuixRefreshState.idle:
        return;
      case MiuixRefreshState.pulling:
        if (controller.dragOffset > controller._visualThresholdOffset) {
          _drawThreshold(canvas, center, radius, stroke);
        } else {
          stroke.color = color.withValues(
            alpha: (controller.visualProgress - 0.2).clamp(0.0, 1.0),
          );
          canvas.drawCircle(center, radius, stroke);
        }
      case MiuixRefreshState.thresholdReached:
        _drawThreshold(canvas, center, radius, stroke);
      case MiuixRefreshState.refreshing:
        final alpha = ((controller.visualProgress - 0.2) / 0.8).clamp(0.0, 1.0);
        stroke.color = color.withValues(alpha: color.a * alpha);
        canvas.drawCircle(center, radius, stroke);
        final orbitRadius = radius - 2 * strokeWidth;
        final angle = rotation.value * 2 * math.pi;
        final dot =
            center +
            Offset(
              orbitRadius * math.cos(angle),
              orbitRadius * math.sin(angle),
            );
        canvas.drawCircle(dot, strokeWidth, Paint()..color = stroke.color);
      case MiuixRefreshState.refreshComplete:
        final progress = controller._completeProgress;
        final animatedRadius = radius * math.max(1 - progress, 0.9);
        stroke.color = color.withValues(
          alpha: (1 - progress - 0.35).clamp(0.0, 1.0),
        );
        final y = center.dy - radius - strokeWidth + animatedRadius;
        canvas.drawCircle(Offset(center.dx, y), animatedRadius, stroke);
    }
  }

  void _drawThreshold(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final threshold = controller._visualThresholdOffset;
    final lineLength = (controller.dragOffset - threshold).clamp(
      0.0,
      math.max(0, controller._maxDragDistance - threshold),
    );
    final topY = center.dy;
    final bottomY = topY + lineLength;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, topY), radius: radius),
      math.pi,
      math.pi,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, bottomY), radius: radius),
      0,
      math.pi,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, topY),
      Offset(center.dx - radius, bottomY),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius, topY),
      Offset(center.dx + radius, bottomY),
      paint,
    );
  }

  @override
  bool shouldRepaint(_RefreshIndicatorPainter oldDelegate) =>
      oldDelegate.controller != controller ||
      oldDelegate.color != color ||
      oldDelegate.circleSize != circleSize;
}

double _obtainDampingDistance(double value, double range) {
  if (range <= 0) return 0;
  final x = value.clamp(0.0, 1.0);
  return (x - x * x + x * x * x / 3) * range;
}

double _obtainTouchDistance(double distance, double range) {
  if (range <= 0) return 0;
  final sign = distance.sign;
  final absolute = distance.abs().clamp(0.0, _obtainDampingDistance(1, range));
  final base = range - 3 * absolute;
  final cubeRoot = base == 0
      ? 0.0
      : base.sign * math.pow(base.abs(), 1 / 3).toDouble();
  return sign * (range - math.pow(range, 2 / 3) * cubeRoot);
}
