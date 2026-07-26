// Miuix Flutter 移植版 - Slider
// 源自 compose-miuix-ui/miuix 的 Slider.kt。
// 包含水平 Slider、垂直 VerticalSlider、范围 RangeSlider 三个变体。
// 支持步进、关键点显示、磁性吸附、触感反馈、反向方向、禁用态。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme/miuix_theme.dart';

// Compose 的 `spring(dampingRatio:, stiffness:)` 中 dampingRatio 是"阻尼比"（1.0 为
// 临界阻尼），而非 [SpringDescription.damping]（绝对阻尼系数 c）。二者关系为
// c = ratio · 2·√(mass·stiffness)。因此必须用
// [SpringDescription.withDampingRatio] 正确映射，直接把 dampingRatio 当作 damping
// 会导致严重欠阻尼、超调抖动。数值与 Slider.kt 保持一致。

/// 进度动画弹簧（拖拽中）。对应 Kotlin `spring(dampingRatio = 0.9f, stiffness = 1755f)`。
final SpringDescription _sliderProgressSpringDragging =
    SpringDescription.withDampingRatio(mass: 1, stiffness: 1755, ratio: 0.9);

/// 进度动画弹簧（非拖拽/回弹）。对应 Kotlin `spring(dampingRatio = 0.96f, stiffness = 322f)`。
final SpringDescription _sliderProgressSpringSettle =
    SpringDescription.withDampingRatio(mass: 1, stiffness: 322, ratio: 0.96);

/// thumb 缩放弹簧。对应 Kotlin `ThumbScaleAnimationSpec = spring(dampingRatio = 0.6f, stiffness = 987f)`。
final SpringDescription _thumbScaleSpring =
    SpringDescription.withDampingRatio(mass: 1, stiffness: 987, ratio: 0.6);

/// Slider 颜色配置。对应 Kotlin `SliderColors`。
@immutable
class MiuixSliderColors {
  const MiuixSliderColors({
    required this.foregroundColor,
    required this.disabledForegroundColor,
    required this.backgroundColor,
    required this.disabledBackgroundColor,
    required this.thumbColor,
    required this.disabledThumbColor,
    required this.keyPointColor,
    required this.keyPointForegroundColor,
  });

  final Color foregroundColor;
  final Color disabledForegroundColor;
  final Color backgroundColor;
  final Color disabledBackgroundColor;
  final Color thumbColor;
  final Color disabledThumbColor;
  final Color keyPointColor;
  final Color keyPointForegroundColor;

  Color foregroundColorFor(bool enabled) =>
      enabled ? foregroundColor : disabledForegroundColor;
  Color backgroundColorFor(bool enabled) =>
      enabled ? backgroundColor : disabledBackgroundColor;
  Color thumbColorFor(bool enabled) =>
      enabled ? thumbColor : disabledThumbColor;
}

/// Slider 触感反馈类型。对应 Kotlin `SliderHapticEffect`。
enum MiuixSliderHapticEffect {
  /// 无触感反馈。
  none,

  /// 在 0% 和 100% 端点触发。
  edge,

  /// 在步进点触发。
  step,
}

class MiuixSliderDefaults {
  MiuixSliderDefaults._();

  /// Slider / RangeSlider 的最小高度（水平）或宽度（垂直）。
  static const double minHeight = 28;

  /// 关键点半径。
  static const double keyPointRadius = 3.855;

  /// 默认触感反馈类型。
  static const MiuixSliderHapticEffect defaultHapticEffect =
      MiuixSliderHapticEffect.edge;

  /// thumb 在按下/拖拽/悬停时的放大系数。
  static const double thumbScaleActive = 1.127;

  /// thumb 实际半径相对轨道半径的比例。
  static const double thumbRadiusRatio = 0.72;

  /// 拖拽时的背景压暗 alpha。
  static const double dragOverlayAlpha = 0.044;

  static MiuixSliderColors sliderColors(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    return MiuixSliderColors(
      foregroundColor: c.primary,
      disabledForegroundColor: c.disabledPrimarySlider,
      backgroundColor: c.sliderBackground,
      disabledBackgroundColor: c.disabledSecondary,
      thumbColor: c.onPrimary,
      disabledThumbColor: c.disabledOnPrimary,
      keyPointColor: c.sliderKeyPoint,
      keyPointForegroundColor: c.sliderKeyPointForeground,
    );
  }
}

// =============================================================================
// 水平 Slider
// =============================================================================

/// Miuix 风格的水平滑块。对应 Kotlin `Slider`。
class MiuixSlider extends StatefulWidget {
  const MiuixSlider({
    super.key,
    required this.value,
    required this.onValueChanged,
    this.enabled = true,
    this.min = 0.0,
    this.max = 1.0,
    this.steps = 0,
    this.onValueChangeFinished,
    this.reverseDirection = false,
    this.height = MiuixSliderDefaults.minHeight,
    this.colors,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
    this.showKeyPoints = false,
    this.keyPoints,
    this.magnetThreshold = 0.02,
  })  : assert(steps >= 0, 'steps should be >= 0'),
        assert(min < max, 'min should be less than max');

  final double value;
  final ValueChanged<double>? onValueChanged;
  final bool enabled;
  final double min;
  final double max;
  final int steps;
  final VoidCallback? onValueChangeFinished;
  final bool reverseDirection;
  final double height;
  final MiuixSliderColors? colors;
  final MiuixSliderHapticEffect hapticEffect;
  final bool showKeyPoints;
  final List<double>? keyPoints;
  final double magnetThreshold;

  @override
  State<MiuixSlider> createState() => _MiuixSliderState();
}

class _MiuixSliderState extends State<MiuixSlider>
    with TickerProviderStateMixin {
  late final AnimationController _animatedValue;
  late final AnimationController _thumbScale;
  late final AnimationController _dragOverlay;

  // 合并三个控制器的重绘监听，只建一次；否则 build() 每帧（拖拽中父级会每帧
  // 重建本组件）都 new 一个 Listenable.merge，导致监听反复订阅/退订。
  late final Listenable _repaint;

  bool _isDragging = false;
  bool _isHoveringThumb = false;
  bool _isPressed = false;

  final _SliderHapticState _hapticState = _SliderHapticState();

  double _layoutWidth = 0;
  double _layoutHeight = 0;

  @override
  void initState() {
    super.initState();
    _animatedValue = AnimationController.unbounded(
      vsync: this,
      value: _coercedValue,
    );
    _thumbScale = AnimationController.unbounded(vsync: this, value: 1.0);
    _dragOverlay = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: 0.0,
    );
    _repaint = Listenable.merge([_animatedValue, _thumbScale, _dragOverlay]);
  }

  double get _coercedValue => widget.value.clamp(widget.min, widget.max);
  bool get _effectiveEnabled => widget.enabled && widget.onValueChanged != null;

  @override
  void didUpdateWidget(MiuixSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 拖拽中不响应外部 value 回灌——拖拽路径已直接驱动 _animatedValue。
    // 否则父级每帧 setState 会在这里再触发一次 spring，造成双重动画 + 掉帧。
    if (_isDragging) return;
    if (oldWidget.value != widget.value ||
        oldWidget.min != widget.min ||
        oldWidget.max != widget.max) {
      _animateValueTo(_coercedValue);
    }
  }

  @override
  void dispose() {
    _animatedValue.dispose();
    _thumbScale.dispose();
    _dragOverlay.dispose();
    super.dispose();
  }

  void _animateValueTo(double target) {
    final spring = _isDragging
        ? _sliderProgressSpringDragging
        : _sliderProgressSpringSettle;
    _animatedValue.animateWith(
      SpringSimulation(spring, _animatedValue.value, target, 0),
    );
  }

  void _updateThumbScale() {
    final active = _isPressed || _isDragging || _isHoveringThumb;
    final target = active ? MiuixSliderDefaults.thumbScaleActive : 1.0;
    _thumbScale.animateWith(
      SpringSimulation(
        _thumbScaleSpring,
        _thumbScale.value,
        target,
        0,
      ),
    );
  }

  List<double> get _stepFractions => _stepsToTickFractions(widget.steps);

  List<double> get _keyPointFractions => _computeKeyPointFractions(
        widget.keyPoints,
        _stepFractions,
        widget.min,
        widget.max,
        widget.showKeyPoints,
      );

  List<double> get _allKeyPointFractions => _computeAllKeyPointFractions(
        widget.keyPoints,
        _stepFractions,
        widget.min,
        widget.max,
      );

  double _fractionToValue(double fraction) {
    return _resolveValueFromFraction(
      fraction: fraction,
      min: widget.min,
      max: widget.max,
      steps: widget.steps,
      allKeyPointFractions: _allKeyPointFractions,
      magnetThreshold: widget.magnetThreshold,
    );
  }

  double _horizontalVisualFraction(double offsetX) {
    final thumbRadius = _layoutHeight / 2;
    final availableWidth =
        (_layoutWidth - 2 * thumbRadius).clamp(0.0, double.infinity);
    if (availableWidth == 0) return 0;
    return ((offsetX - thumbRadius) / availableWidth).clamp(0.0, 1.0);
  }

  bool get _effectiveReverse {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return isRtl ? !widget.reverseDirection : widget.reverseDirection;
  }

  void _onDragStart(double localX) {
    if (!_effectiveEnabled) return;
    // 直接改字段而非 setState：build() 不读 _isDragging，视觉全靠
    // _thumbScale/_dragOverlay 控制器经 AnimatedBuilder 驱动。避免起手时
    // 多一次无谓的整树重建 + relayout（掉帧主因）。
    _isDragging = true;
    _dragOverlay.animateTo(MiuixSliderDefaults.dragOverlayAlpha);
    _updateThumbScale();

    final visualFraction = _horizontalVisualFraction(localX);
    final fractionForValue =
        _effectiveReverse ? 1 - visualFraction : visualFraction;
    final newValue = _fractionToValue(fractionForValue);
    _hapticState.reset(newValue, widget.min, widget.max, _coercedValue);
    _setValueDuringDrag(newValue);
  }

  // 用指针的绝对本地坐标（与 onDragStart/onTapUp 同坐标系），而非累加
  // details.delta 的每帧增量——后者会导致 thumb 几乎不动、拖不跟手。
  void _onDragUpdate(double localX) {
    if (!_effectiveEnabled) return;
    final visualFraction = _horizontalVisualFraction(localX);
    final fractionForValue =
        _effectiveReverse ? 1 - visualFraction : visualFraction;
    final newValue = _fractionToValue(fractionForValue);
    _hapticState.handleHapticFeedback(
      newValue,
      widget.min,
      widget.max,
      widget.hapticEffect,
      _allKeyPointFractions,
      hasCustomKeyPoints: widget.keyPoints != null,
    );
    _setValueDuringDrag(newValue);
  }

  /// 拖拽中：thumb 直接跟指针（直接赋值，不每帧分配 SpringSimulation），
  /// 再通知父级。thumb 已 1:1 跟手，spring 只留给点击 / 外部值变更。
  void _setValueDuringDrag(double newValue) {
    _animatedValue.value = newValue.clamp(widget.min, widget.max);
    widget.onValueChanged?.call(newValue);
  }

  void _onDragEnd() {
    if (!_effectiveEnabled) return;
    _isDragging = false;
    _dragOverlay.animateTo(0);
    _updateThumbScale();
    widget.onValueChangeFinished?.call();
  }

  void _onHover(double localX) {
    if (!_effectiveEnabled || _layoutWidth == 0) return;
    final thumbRadius = _layoutHeight / 2;
    final availableWidth =
        (_layoutWidth - 2 * thumbRadius).clamp(0.0, double.infinity);
    final knobRadius = thumbRadius * MiuixSliderDefaults.thumbRadiusRatio;
    final hitRadius = knobRadius + thumbRadius * 0.5;

    final fraction =
        (_animatedValue.value - widget.min) / (widget.max - widget.min);
    final effectiveFraction =
        _effectiveReverse ? 1 - fraction : fraction;
    final thumbX = thumbRadius + effectiveFraction * availableWidth;
    final isOver = (localX - thumbX).abs() <= hitRadius;
    if (_isHoveringThumb != isOver) {
      _isHoveringThumb = isOver;
      _updateThumbScale();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixSliderDefaults.sliderColors(context);
    final enabled = _effectiveEnabled;

    return LayoutBuilder(
      builder: (context, constraints) {
        _layoutWidth = constraints.maxWidth;
        _layoutHeight = widget.height;
        return MouseRegion(
          onHover: enabled ? (e) => _onHover(e.localPosition.dx) : null,
          onExit: enabled
              ? (_) {
                  if (_isHoveringThumb) {
                    _isHoveringThumb = false;
                    _updateThumbScale();
                  }
                }
              : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled
                ? (d) {
                    _isPressed = true;
                    _updateThumbScale();
                  }
                : null,
            onTapUp: enabled
                ? (d) {
                    _isPressed = false;
                    _updateThumbScale();
                    _jumpTo(d.localPosition.dx);
                  }
                : null,
            onTapCancel: enabled
                ? () {
                    _isPressed = false;
                    _updateThumbScale();
                  }
                : null,
            onHorizontalDragStart: enabled
                ? (d) => _onDragStart(d.localPosition.dx)
                : null,
            onHorizontalDragUpdate: enabled
                ? (d) => _onDragUpdate(d.localPosition.dx)
                : null,
            onHorizontalDragEnd: enabled ? (_) => _onDragEnd() : null,
            child: SizedBox(
              height: widget.height,
              child: AnimatedBuilder(
                animation: _repaint,
                builder: (context, _) => CustomPaint(
                  painter: _SliderTrackPainter(
                    backgroundColor: colors.backgroundColorFor(enabled),
                    foregroundColor: colors.foregroundColorFor(enabled),
                    thumbColor: colors.thumbColorFor(enabled),
                    keyPointColor: colors.keyPointColor,
                    keyPointForegroundColor: colors.keyPointForegroundColor,
                    value: _animatedValue.value,
                    min: widget.min,
                    max: widget.max,
                    isVertical: false,
                    showKeyPoints: widget.showKeyPoints,
                    stepFractions: _keyPointFractions,
                    thumbScale: _thumbScale.value,
                    reverseDirection: _effectiveReverse,
                    dragOverlayAlpha: _dragOverlay.value,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 单击直接跳转到点击位置（不进入拖拽态）。
  void _jumpTo(double localX) {
    if (!_effectiveEnabled) return;
    final visualFraction = _horizontalVisualFraction(localX);
    final fractionForValue =
        _effectiveReverse ? 1 - visualFraction : visualFraction;
    final newValue = _fractionToValue(fractionForValue);
    widget.onValueChanged?.call(newValue);
    _animateValueTo(newValue);
  }
}

// =============================================================================
// 垂直 VerticalSlider
// =============================================================================

/// Miuix 风格的垂直滑块。对应 Kotlin `VerticalSlider`。
class MiuixVerticalSlider extends StatefulWidget {
  const MiuixVerticalSlider({
    super.key,
    required this.value,
    required this.onValueChanged,
    this.enabled = true,
    this.min = 0.0,
    this.max = 1.0,
    this.steps = 0,
    this.onValueChangeFinished,
    this.reverseDirection = false,
    this.width = MiuixSliderDefaults.minHeight,
    this.colors,
    this.effect = false,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
    this.showKeyPoints = false,
    this.keyPoints,
    this.magnetThreshold = 0.02,
  })  : assert(steps >= 0, 'steps should be >= 0'),
        assert(min < max, 'min should be less than max');

  final double value;
  final ValueChanged<double>? onValueChanged;
  final bool enabled;
  final double min;
  final double max;
  final int steps;
  final VoidCallback? onValueChangeFinished;
  final bool reverseDirection;
  final double width;
  final MiuixSliderColors? colors;

  /// 是否显示 Slider 的额外效果。对应 Kotlin `VerticalSlider` 的 `effect` 参数。
  ///
  /// 与源保持一致：当前上游 Kotlin 实现仅声明该参数、未在布局/绘制中启用任何
  /// 视觉效果，因此这里同样作为保留参数（默认 `false`），以维持 API 1:1 对齐。
  final bool effect;

  final MiuixSliderHapticEffect hapticEffect;
  final bool showKeyPoints;
  final List<double>? keyPoints;
  final double magnetThreshold;

  @override
  State<MiuixVerticalSlider> createState() => _MiuixVerticalSliderState();
}

class _MiuixVerticalSliderState extends State<MiuixVerticalSlider>
    with TickerProviderStateMixin {
  late final AnimationController _animatedValue;
  late final AnimationController _thumbScale;
  late final AnimationController _dragOverlay;

  // 只建一次的合并重绘监听（见水平版说明）。
  late final Listenable _repaint;

  bool _isDragging = false;
  bool _isHoveringThumb = false;
  bool _isPressed = false;

  final _SliderHapticState _hapticState = _SliderHapticState();

  double _layoutWidth = 0;
  double _layoutHeight = 0;

  @override
  void initState() {
    super.initState();
    _animatedValue = AnimationController.unbounded(
      vsync: this,
      value: _coercedValue,
    );
    _thumbScale = AnimationController.unbounded(vsync: this, value: 1.0);
    _dragOverlay = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: 0.0,
    );
    _repaint = Listenable.merge([_animatedValue, _thumbScale, _dragOverlay]);
  }

  double get _coercedValue => widget.value.clamp(widget.min, widget.max);
  bool get _effectiveEnabled => widget.enabled && widget.onValueChanged != null;

  @override
  void didUpdateWidget(MiuixVerticalSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 见水平版说明：拖拽中不响应外部 value 回灌，避免双重动画掉帧。
    if (_isDragging) return;
    if (oldWidget.value != widget.value ||
        oldWidget.min != widget.min ||
        oldWidget.max != widget.max) {
      _animateValueTo(_coercedValue);
    }
  }

  @override
  void dispose() {
    _animatedValue.dispose();
    _thumbScale.dispose();
    _dragOverlay.dispose();
    super.dispose();
  }

  void _animateValueTo(double target) {
    final spring = _isDragging
        ? _sliderProgressSpringDragging
        : _sliderProgressSpringSettle;
    _animatedValue.animateWith(
      SpringSimulation(spring, _animatedValue.value, target, 0),
    );
  }

  void _updateThumbScale() {
    final active = _isPressed || _isDragging || _isHoveringThumb;
    final target = active ? MiuixSliderDefaults.thumbScaleActive : 1.0;
    _thumbScale.animateWith(
      SpringSimulation(
        _thumbScaleSpring,
        _thumbScale.value,
        target,
        0,
      ),
    );
  }

  List<double> get _stepFractions => _stepsToTickFractions(widget.steps);

  List<double> get _keyPointFractions => _computeKeyPointFractions(
        widget.keyPoints,
        _stepFractions,
        widget.min,
        widget.max,
        widget.showKeyPoints,
      );

  List<double> get _allKeyPointFractions => _computeAllKeyPointFractions(
        widget.keyPoints,
        _stepFractions,
        widget.min,
        widget.max,
      );

  double _fractionToValue(double fraction) {
    return _resolveValueFromFraction(
      fraction: fraction,
      min: widget.min,
      max: widget.max,
      steps: widget.steps,
      allKeyPointFractions: _allKeyPointFractions,
      magnetThreshold: widget.magnetThreshold,
    );
  }

  double _verticalVisualFraction(double offsetY) {
    final thumbRadius = _layoutWidth / 2;
    final availableHeight =
        (_layoutHeight - 2 * thumbRadius).clamp(0.0, double.infinity);
    if (availableHeight == 0) return 0;
    return ((offsetY - thumbRadius) / availableHeight).clamp(0.0, 1.0);
  }

  void _onDragStart(double localY) {
    if (!_effectiveEnabled) return;
    // 直接改字段而非 setState（见水平版说明）。
    _isDragging = true;
    _dragOverlay.animateTo(MiuixSliderDefaults.dragOverlayAlpha);
    _updateThumbScale();
    _applyValueAt(localY);
  }

  void _applyValueAt(double localY) {
    final visualFraction = _verticalVisualFraction(localY);
    // 垂直方向默认从下到上递增，因此取 1 - visualFraction
    final fractionForValue =
        widget.reverseDirection ? visualFraction : 1 - visualFraction;
    final newValue = _fractionToValue(fractionForValue);
    _hapticState.handleHapticFeedback(
      newValue,
      widget.min,
      widget.max,
      widget.hapticEffect,
      _allKeyPointFractions,
      hasCustomKeyPoints: widget.keyPoints != null,
    );
    // 拖拽中直接赋值 thumb 位置，不每帧分配 SpringSimulation。
    _animatedValue.value = newValue.clamp(widget.min, widget.max);
    widget.onValueChanged?.call(newValue);
  }

  // 用绝对本地 Y 坐标，而非累加每帧 delta.dy（见水平版说明）。
  void _onDragUpdate(double localY) {
    if (!_effectiveEnabled) return;
    _applyValueAt(localY);
  }

  void _onDragEnd() {
    if (!_effectiveEnabled) return;
    _isDragging = false;
    _dragOverlay.animateTo(0);
    _updateThumbScale();
    widget.onValueChangeFinished?.call();
  }

  void _onHover(double localY) {
    if (!_effectiveEnabled || _layoutHeight == 0) return;
    final thumbRadius = _layoutWidth / 2;
    final availableHeight =
        (_layoutHeight - 2 * thumbRadius).clamp(0.0, double.infinity);
    final knobRadius = thumbRadius * MiuixSliderDefaults.thumbRadiusRatio;
    final hitRadius = knobRadius + thumbRadius * 0.5;

    final fraction =
        (_animatedValue.value - widget.min) / (widget.max - widget.min);
    final effectiveFraction =
        widget.reverseDirection ? fraction : 1 - fraction;
    final thumbY = thumbRadius + effectiveFraction * availableHeight;
    final isOver = (localY - thumbY).abs() <= hitRadius;
    if (_isHoveringThumb != isOver) {
      _isHoveringThumb = isOver;
      _updateThumbScale();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixSliderDefaults.sliderColors(context);
    final enabled = _effectiveEnabled;

    return LayoutBuilder(
      builder: (context, constraints) {
        _layoutWidth = widget.width;
        _layoutHeight = constraints.maxHeight;
        return MouseRegion(
          onHover: enabled ? (e) => _onHover(e.localPosition.dy) : null,
          onExit: enabled
              ? (_) {
                  if (_isHoveringThumb) {
                    _isHoveringThumb = false;
                    _updateThumbScale();
                  }
                }
              : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled
                ? (d) {
                    _isPressed = true;
                    _updateThumbScale();
                  }
                : null,
            onTapUp: enabled
                ? (d) {
                    _isPressed = false;
                    _updateThumbScale();
                    // 单击直接跳转
                    final visualFraction =
                        _verticalVisualFraction(d.localPosition.dy);
                    final fractionForValue = widget.reverseDirection
                        ? visualFraction
                        : 1 - visualFraction;
                    final newValue = _fractionToValue(fractionForValue);
                    widget.onValueChanged?.call(newValue);
                    _animateValueTo(newValue);
                  }
                : null,
            onTapCancel: enabled
                ? () {
                    _isPressed = false;
                    _updateThumbScale();
                  }
                : null,
            onVerticalDragStart: enabled
                ? (d) => _onDragStart(d.localPosition.dy)
                : null,
            onVerticalDragUpdate: enabled
                ? (d) => _onDragUpdate(d.localPosition.dy)
                : null,
            onVerticalDragEnd: enabled ? (_) => _onDragEnd() : null,
            child: SizedBox(
              width: widget.width,
              child: AnimatedBuilder(
                animation: _repaint,
                builder: (context, _) => CustomPaint(
                  painter: _SliderTrackPainter(
                    backgroundColor: colors.backgroundColorFor(enabled),
                    foregroundColor: colors.foregroundColorFor(enabled),
                    thumbColor: colors.thumbColorFor(enabled),
                    keyPointColor: colors.keyPointColor,
                    keyPointForegroundColor: colors.keyPointForegroundColor,
                    value: _animatedValue.value,
                    min: widget.min,
                    max: widget.max,
                    isVertical: true,
                    showKeyPoints: widget.showKeyPoints,
                    stepFractions: _keyPointFractions,
                    thumbScale: _thumbScale.value,
                    reverseDirection: widget.reverseDirection,
                    dragOverlayAlpha: _dragOverlay.value,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// 范围 RangeSlider
// =============================================================================

/// Miuix 风格的范围滑块。对应 Kotlin `RangeSlider`。
class MiuixRangeSlider extends StatefulWidget {
  const MiuixRangeSlider({
    super.key,
    required this.startValue,
    required this.endValue,
    required this.onValueChanged,
    this.enabled = true,
    this.min = 0.0,
    this.max = 1.0,
    this.steps = 0,
    this.onValueChangeFinished,
    this.height = MiuixSliderDefaults.minHeight,
    this.colors,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
    this.showKeyPoints = false,
    this.keyPoints,
    this.magnetThreshold = 0.02,
  })  : assert(steps >= 0, 'steps should be >= 0'),
        assert(min < max, 'min should be less than max');

  final double startValue;
  final double endValue;
  final ValueChanged<(double, double)>? onValueChanged;
  final bool enabled;
  final double min;
  final double max;
  final int steps;
  final VoidCallback? onValueChangeFinished;
  final double height;
  final MiuixSliderColors? colors;
  final MiuixSliderHapticEffect hapticEffect;
  final bool showKeyPoints;
  final List<double>? keyPoints;
  final double magnetThreshold;

  @override
  State<MiuixRangeSlider> createState() => _MiuixRangeSliderState();
}

class _MiuixRangeSliderState extends State<MiuixRangeSlider>
    with TickerProviderStateMixin {
  late final AnimationController _animatedStart;
  late final AnimationController _animatedEnd;
  late final AnimationController _startThumbScale;
  late final AnimationController _endThumbScale;
  late final AnimationController _dragOverlay;

  // 只建一次的合并重绘监听（见水平版说明）。
  late final Listenable _repaint;

  bool _isDraggingStart = false;
  bool _isDraggingEnd = false;
  bool _lastDraggedIsStart = true;

  late double _currentStart;
  late double _currentEnd;

  double _layoutWidth = 0;
  double _layoutHeight = 0;

  final _RangeSliderHapticState _hapticState = _RangeSliderHapticState();

  @override
  void initState() {
    super.initState();
    _currentStart = _coercedStart;
    _currentEnd = _coercedEnd;
    _animatedStart =
        AnimationController.unbounded(vsync: this, value: _currentStart);
    _animatedEnd =
        AnimationController.unbounded(vsync: this, value: _currentEnd);
    _startThumbScale = AnimationController.unbounded(vsync: this, value: 1.0);
    _endThumbScale = AnimationController.unbounded(vsync: this, value: 1.0);
    _dragOverlay = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: 0.0,
    );
    _repaint = Listenable.merge([
      _animatedStart,
      _animatedEnd,
      _startThumbScale,
      _endThumbScale,
      _dragOverlay,
    ]);
  }

  double get _coercedStart => widget.startValue.clamp(widget.min, widget.max);
  double get _coercedEnd => widget.endValue.clamp(widget.min, widget.max);
  bool get _isDragging => _isDraggingStart || _isDraggingEnd;
  bool get _effectiveEnabled => widget.enabled && widget.onValueChanged != null;

  @override
  void didUpdateWidget(MiuixRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 拖拽中不响应外部值回灌——拖拽路径已直接驱动 _animatedStart/End。
    // 否则父级每帧 setState 会再触发 spring，双重动画掉帧。
    if (_isDragging) return;
    _currentStart = _coercedStart;
    _currentEnd = _coercedEnd;
    if (oldWidget.startValue != widget.startValue ||
        oldWidget.min != widget.min ||
        oldWidget.max != widget.max) {
      _animateStartTo(_currentStart);
    }
    if (oldWidget.endValue != widget.endValue ||
        oldWidget.min != widget.min ||
        oldWidget.max != widget.max) {
      _animateEndTo(_currentEnd);
    }
  }

  @override
  void dispose() {
    _animatedStart.dispose();
    _animatedEnd.dispose();
    _startThumbScale.dispose();
    _endThumbScale.dispose();
    _dragOverlay.dispose();
    super.dispose();
  }

  void _animateStartTo(double target) {
    final spring = _isDragging
        ? _sliderProgressSpringDragging
        : _sliderProgressSpringSettle;
    _animatedStart.animateWith(
      SpringSimulation(spring, _animatedStart.value, target, 0),
    );
  }

  void _animateEndTo(double target) {
    final spring = _isDragging
        ? _sliderProgressSpringDragging
        : _sliderProgressSpringSettle;
    _animatedEnd.animateWith(
      SpringSimulation(spring, _animatedEnd.value, target, 0),
    );
  }

  void _updateThumbScale() {
    final startActive = _isDraggingStart;
    final endActive = _isDraggingEnd;
    _startThumbScale.animateWith(
      SpringSimulation(
        _thumbScaleSpring,
        _startThumbScale.value,
        startActive ? MiuixSliderDefaults.thumbScaleActive : 1.0,
        0,
      ),
    );
    _endThumbScale.animateWith(
      SpringSimulation(
        _thumbScaleSpring,
        _endThumbScale.value,
        endActive ? MiuixSliderDefaults.thumbScaleActive : 1.0,
        0,
      ),
    );
  }

  List<double> get _stepFractions => _stepsToTickFractions(widget.steps);

  List<double> get _keyPointFractions => _computeKeyPointFractions(
        widget.keyPoints,
        _stepFractions,
        widget.min,
        widget.max,
        widget.showKeyPoints,
      );

  List<double> get _allKeyPointFractions => _computeAllKeyPointFractions(
        widget.keyPoints,
        _stepFractions,
        widget.min,
        widget.max,
      );

  double _fractionToValue(double fraction) {
    return _resolveValueFromFraction(
      fraction: fraction,
      min: widget.min,
      max: widget.max,
      steps: widget.steps,
      allKeyPointFractions: _allKeyPointFractions,
      magnetThreshold: widget.magnetThreshold,
    );
  }

  double _horizontalVisualFraction(double offsetX) {
    final thumbRadius = _layoutHeight / 2;
    final availableWidth =
        (_layoutWidth - 2 * thumbRadius).clamp(0.0, double.infinity);
    if (availableWidth == 0) return 0;
    return ((offsetX - thumbRadius) / availableWidth).clamp(0.0, 1.0);
  }

  void _onDragStart(double localX) {
    if (!_effectiveEnabled || _layoutWidth == 0) return;
    final thumbRadius = _layoutHeight / 2;
    final availableWidth =
        (_layoutWidth - 2 * thumbRadius).clamp(0.0, double.infinity);
    final knobRadius = thumbRadius * MiuixSliderDefaults.thumbRadiusRatio;
    final hitRadius = knobRadius + thumbRadius * 0.5;

    final startFraction =
        (_currentStart - widget.min) / (widget.max - widget.min);
    final endFraction =
        (_currentEnd - widget.min) / (widget.max - widget.min);
    final startPos = thumbRadius + startFraction * availableWidth;
    final endPos = thumbRadius + endFraction * availableWidth;

    final isOnStart = (localX - startPos).abs() <= hitRadius;
    final isOnEnd = (localX - endPos).abs() <= hitRadius;

    if (isOnStart && !isOnEnd) {
      _isDraggingStart = true;
      _hapticState.resetStart(_coercedStart, widget.min, widget.max);
    } else if (!isOnStart && isOnEnd) {
      _isDraggingEnd = true;
      _hapticState.resetEnd(_coercedEnd, widget.min, widget.max);
    } else if (isOnStart && isOnEnd) {
      if (_lastDraggedIsStart) {
        _isDraggingStart = true;
        _hapticState.resetStart(_coercedStart, widget.min, widget.max);
      } else {
        _isDraggingEnd = true;
        _hapticState.resetEnd(_coercedEnd, widget.min, widget.max);
      }
    } else {
      // 点击在两个 thumb 之外，跳到最近的 thumb
      final diffStart = (localX - startPos).abs();
      final diffEnd = (localX - endPos).abs();
      if (diffStart <= diffEnd) {
        _isDraggingStart = true;
        _hapticState.resetStart(_coercedStart, widget.min, widget.max);
      } else {
        _isDraggingEnd = true;
        _hapticState.resetEnd(_coercedEnd, widget.min, widget.max);
      }
    }

    // 直接改字段而非 setState（见水平版说明）。
    _dragOverlay.animateTo(MiuixSliderDefaults.dragOverlayAlpha);
    _updateThumbScale();
    _applyDragAt(localX);
  }

  void _applyDragAt(double localX) {
    final visualFraction = _horizontalVisualFraction(localX);
    if (_isDraggingStart) {
      final newStart =
          _fractionToValue(visualFraction).clamp(widget.min, _currentEnd);
      _currentStart = newStart;
      _lastDraggedIsStart = true;
      _hapticState.handleStartHapticFeedback(
        newStart,
        widget.min,
        widget.max,
        widget.hapticEffect,
        _allKeyPointFractions,
        hasCustomKeyPoints: widget.keyPoints != null,
      );
      // 拖拽中直接赋值，不每帧分配 SpringSimulation。
      _animatedStart.value = newStart;
      widget.onValueChanged?.call((newStart, _currentEnd));
    } else if (_isDraggingEnd) {
      final newEnd =
          _fractionToValue(visualFraction).clamp(_currentStart, widget.max);
      _currentEnd = newEnd;
      _lastDraggedIsStart = false;
      _hapticState.handleEndHapticFeedback(
        newEnd,
        widget.min,
        widget.max,
        widget.hapticEffect,
        _allKeyPointFractions,
        hasCustomKeyPoints: widget.keyPoints != null,
      );
      _animatedEnd.value = newEnd;
      widget.onValueChanged?.call((_currentStart, newEnd));
    }
  }

  // 用绝对本地 X 坐标，而非累加每帧 delta.dx（见水平 Slider 版说明）。
  void _onDragUpdate(double localX) {
    if (!_effectiveEnabled) return;
    _applyDragAt(localX);
  }

  void _onDragEnd() {
    if (!_effectiveEnabled) return;
    _isDraggingStart = false;
    _isDraggingEnd = false;
    _dragOverlay.animateTo(0);
    _updateThumbScale();
    widget.onValueChangeFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixSliderDefaults.sliderColors(context);
    final enabled = _effectiveEnabled;

    return LayoutBuilder(
      builder: (context, constraints) {
        _layoutWidth = constraints.maxWidth;
        _layoutHeight = widget.height;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: enabled
              ? (d) => _onDragStart(d.localPosition.dx)
              : null,
          onHorizontalDragUpdate: enabled
              ? (d) => _onDragUpdate(d.localPosition.dx)
              : null,
          onHorizontalDragEnd: enabled ? (_) => _onDragEnd() : null,
          child: SizedBox(
            height: widget.height,
            child: AnimatedBuilder(
              animation: _repaint,
              builder: (context, _) => CustomPaint(
                painter: _RangeSliderTrackPainter(
                  backgroundColor: colors.backgroundColorFor(enabled),
                  foregroundColor: colors.foregroundColorFor(enabled),
                  thumbColor: colors.thumbColorFor(enabled),
                  keyPointColor: colors.keyPointColor,
                  keyPointForegroundColor: colors.keyPointForegroundColor,
                  valueStart: _animatedStart.value,
                  valueEnd: _animatedEnd.value,
                  min: widget.min,
                  max: widget.max,
                  showKeyPoints: widget.showKeyPoints,
                  stepFractions: _keyPointFractions,
                  startThumbScale: _startThumbScale.value,
                  endThumbScale: _endThumbScale.value,
                  dragOverlayAlpha: _dragOverlay.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// Painter
// =============================================================================

class _SliderTrackPainter extends CustomPainter {
  _SliderTrackPainter({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.thumbColor,
    required this.keyPointColor,
    required this.keyPointForegroundColor,
    required this.value,
    required this.min,
    required this.max,
    required this.isVertical,
    required this.showKeyPoints,
    required this.stepFractions,
    required this.thumbScale,
    required this.reverseDirection,
    required this.dragOverlayAlpha,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color thumbColor;
  final Color keyPointColor;
  final Color keyPointForegroundColor;
  final double value;
  final double min;
  final double max;
  final bool isVertical;
  final bool showKeyPoints;
  final List<double> stepFractions;
  final double thumbScale;
  final bool reverseDirection;
  final double dragOverlayAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final fraction = (value - min) / (max - min);

    // 背景轨道（圆角矩形填充）
    final bgPaint = Paint()..color = backgroundColor;
    final bgRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(isVertical ? size.width / 2 : size.height / 2),
    );
    // 对应 Kotlin `Canvas(modifier.clip(CircleShape))`：把绘制裁进胶囊轨道内。
    // 前景线用 StrokeCap.round，在 0%/100% 端点（水平非反向 startX=0、反向
    // startX=width，垂直 bottom）圆头半径为 height/2，不裁剪会溢出轨道左/右/下边界。
    canvas.clipRRect(bgRect);
    canvas.drawRRect(bgRect, bgPaint);

    // 拖拽时的压暗叠层
    if (dragOverlayAlpha > 0) {
      canvas.drawRRect(
        bgRect,
        Paint()..color = Colors.black.withValues(alpha: dragOverlayAlpha),
      );
    }

    if (isVertical) {
      final thumbRadius = size.width / 2;
      final availableHeight =
          (size.height - 2 * thumbRadius).clamp(0.0, double.infinity);
      final effectiveFraction = reverseDirection ? fraction : 1 - fraction;
      final centerY = thumbRadius + effectiveFraction * availableHeight;
      final centerX = size.width / 2;

      // 前景线（从底部到 thumb）
      final fgPaint = Paint()
        ..color = foregroundColor
        ..strokeWidth = size.width
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(centerX, size.height),
        Offset(centerX, centerY),
        fgPaint,
      );

      // 关键点
      if (showKeyPoints && stepFractions.isNotEmpty) {
        final kpRadius = size.width / 7.5;
        for (final stepFraction in stepFractions) {
          final effectiveStep =
              reverseDirection ? stepFraction : 1 - stepFraction;
          final y = thumbRadius + effectiveStep * availableHeight;
          final kpColor = y >= centerY
              ? keyPointForegroundColor
              : keyPointColor;
          canvas.drawCircle(
            Offset(centerX, y),
            kpRadius,
            Paint()..color = kpColor,
          );
        }
      }

      // Thumb
      canvas.drawCircle(
        Offset(centerX, centerY),
        thumbRadius * MiuixSliderDefaults.thumbRadiusRatio * thumbScale,
        Paint()..color = thumbColor,
      );
    } else {
      final thumbRadius = size.height / 2;
      final availableWidth =
          (size.width - 2 * thumbRadius).clamp(0.0, double.infinity);
      final effectiveFraction = reverseDirection ? 1 - fraction : fraction;
      final centerX = thumbRadius + effectiveFraction * availableWidth;
      final centerY = size.height / 2;
      final startX = reverseDirection ? size.width : 0.0;

      // 前景线
      final fgPaint = Paint()
        ..color = foregroundColor
        ..strokeWidth = size.height
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(startX, centerY),
        Offset(centerX, centerY),
        fgPaint,
      );

      // 关键点
      if (showKeyPoints && stepFractions.isNotEmpty) {
        final kpRadius = size.height / 7.5;
        for (final stepFraction in stepFractions) {
          final effectiveStep =
              reverseDirection ? 1 - stepFraction : stepFraction;
          final x = thumbRadius + effectiveStep * availableWidth;
          final isSelected = reverseDirection ? x >= centerX : x <= centerX;
          final kpColor = isSelected ? keyPointForegroundColor : keyPointColor;
          canvas.drawCircle(
            Offset(x, centerY),
            kpRadius,
            Paint()..color = kpColor,
          );
        }
      }

      // Thumb
      canvas.drawCircle(
        Offset(centerX, centerY),
        thumbRadius * MiuixSliderDefaults.thumbRadiusRatio * thumbScale,
        Paint()..color = thumbColor,
      );
    }
  }

  @override
  bool shouldRepaint(_SliderTrackPainter oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor ||
      foregroundColor != oldDelegate.foregroundColor ||
      thumbColor != oldDelegate.thumbColor ||
      keyPointColor != oldDelegate.keyPointColor ||
      keyPointForegroundColor != oldDelegate.keyPointForegroundColor ||
      value != oldDelegate.value ||
      min != oldDelegate.min ||
      max != oldDelegate.max ||
      showKeyPoints != oldDelegate.showKeyPoints ||
      thumbScale != oldDelegate.thumbScale ||
      reverseDirection != oldDelegate.reverseDirection ||
      dragOverlayAlpha != oldDelegate.dragOverlayAlpha ||
      !identical(stepFractions, oldDelegate.stepFractions);
}

class _RangeSliderTrackPainter extends CustomPainter {
  _RangeSliderTrackPainter({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.thumbColor,
    required this.keyPointColor,
    required this.keyPointForegroundColor,
    required this.valueStart,
    required this.valueEnd,
    required this.min,
    required this.max,
    required this.showKeyPoints,
    required this.stepFractions,
    required this.startThumbScale,
    required this.endThumbScale,
    required this.dragOverlayAlpha,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color thumbColor;
  final Color keyPointColor;
  final Color keyPointForegroundColor;
  final double valueStart;
  final double valueEnd;
  final double min;
  final double max;
  final bool showKeyPoints;
  final List<double> stepFractions;
  final double startThumbScale;
  final double endThumbScale;
  final double dragOverlayAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    final bgRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    // 对应 Kotlin `Canvas(modifier.clip(CircleShape))`：裁进胶囊轨道，
    // 防止两端 thumb 与前景线圆头 cap 溢出轨道边界。
    canvas.clipRRect(bgRect);
    canvas.drawRRect(bgRect, bgPaint);

    if (dragOverlayAlpha > 0) {
      canvas.drawRRect(
        bgRect,
        Paint()..color = Colors.black.withValues(alpha: dragOverlayAlpha),
      );
    }

    final thumbRadius = size.height / 2;
    final availableWidth =
        (size.width - 2 * thumbRadius).clamp(0.0, double.infinity);
    final startFraction = (valueStart - min) / (max - min);
    final endFraction = (valueEnd - min) / (max - min);
    final startX = thumbRadius + startFraction * availableWidth;
    final endX = thumbRadius + endFraction * availableWidth;
    final centerY = size.height / 2;

    // 前景线（start → end）
    final fgPaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(startX, centerY),
      Offset(endX, centerY),
      fgPaint,
    );

    // 关键点
    if (showKeyPoints && stepFractions.isNotEmpty) {
      for (final stepFraction in stepFractions) {
        final x = thumbRadius + stepFraction * availableWidth;
        final isSelected = x >= startX && x <= endX;
        final kpColor = isSelected ? keyPointForegroundColor : keyPointColor;
        canvas.drawCircle(
          Offset(x, centerY),
          MiuixSliderDefaults.keyPointRadius,
          Paint()..color = kpColor,
        );
      }
    }

    // 两个 Thumb
    canvas.drawCircle(
      Offset(startX, centerY),
      thumbRadius * MiuixSliderDefaults.thumbRadiusRatio * startThumbScale,
      Paint()..color = thumbColor,
    );
    canvas.drawCircle(
      Offset(endX, centerY),
      thumbRadius * MiuixSliderDefaults.thumbRadiusRatio * endThumbScale,
      Paint()..color = thumbColor,
    );
  }

  @override
  bool shouldRepaint(_RangeSliderTrackPainter oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor ||
      foregroundColor != oldDelegate.foregroundColor ||
      thumbColor != oldDelegate.thumbColor ||
      valueStart != oldDelegate.valueStart ||
      valueEnd != oldDelegate.valueEnd ||
      min != oldDelegate.min ||
      max != oldDelegate.max ||
      showKeyPoints != oldDelegate.showKeyPoints ||
      startThumbScale != oldDelegate.startThumbScale ||
      endThumbScale != oldDelegate.endThumbScale ||
      dragOverlayAlpha != oldDelegate.dragOverlayAlpha ||
      !identical(stepFractions, oldDelegate.stepFractions);
}

// =============================================================================
// 触感反馈状态
// =============================================================================

class _SliderHapticState {
  bool _edgeFeedbackTriggered = false;
  double _lastStep = 0;
  bool _isAtKeyPoint = false;

  void reset(
    double currentValue,
    double min,
    double max,
    double previousValue,
  ) {
    final isAtEdge = currentValue == min || currentValue == max;
    _edgeFeedbackTriggered = isAtEdge && previousValue == currentValue;
    _lastStep = currentValue;
    _isAtKeyPoint = false;
  }

  void handleHapticFeedback(
    double currentValue,
    double min,
    double max,
    MiuixSliderHapticEffect hapticEffect,
    List<double> keyPointFractions, {
    bool hasCustomKeyPoints = false,
  }) {
    if (hapticEffect == MiuixSliderHapticEffect.none) return;

    _handleEdgeHaptic(currentValue, min, max);

    if (hapticEffect == MiuixSliderHapticEffect.step) {
      _handleStepHaptic(currentValue, min, max, keyPointFractions,
          hasCustomKeyPoints);
    }
  }

  void _handleEdgeHaptic(double currentValue, double min, double max) {
    final isAtEdge = currentValue == min || currentValue == max;
    if (isAtEdge && !_edgeFeedbackTriggered) {
      HapticFeedback.selectionClick();
      _edgeFeedbackTriggered = true;
    } else if (!isAtEdge) {
      _edgeFeedbackTriggered = false;
    }
  }

  void _handleStepHaptic(
    double currentValue,
    double min,
    double max,
    List<double> keyPointFractions,
    bool hasCustomKeyPoints,
  ) {
    final isNotAtEdge = currentValue != min && currentValue != max;

    if (hasCustomKeyPoints && keyPointFractions.isNotEmpty) {
      _handleKeyPointHaptic(
          currentValue, min, max, keyPointFractions, isNotAtEdge);
    } else if (!isNotAtEdge) {
      _lastStep = currentValue;
    } else if (currentValue != _lastStep && isNotAtEdge) {
      HapticFeedback.selectionClick();
      _lastStep = currentValue;
    }
  }

  void _handleKeyPointHaptic(
    double currentValue,
    double min,
    double max,
    List<double> keyPointFractions,
    bool isNotAtEdge,
  ) {
    final fraction = (currentValue - min) / (max - min);
    const threshold = 0.005;

    var nearestDist = double.maxFinite;
    for (final kp in keyPointFractions) {
      final dist = (kp - fraction).abs();
      if (dist < nearestDist) nearestDist = dist;
    }
    final currentlyAtKeyPoint = nearestDist < threshold;

    if (currentlyAtKeyPoint && !_isAtKeyPoint && isNotAtEdge) {
      HapticFeedback.selectionClick();
    }
    _isAtKeyPoint = currentlyAtKeyPoint;
  }
}

class _RangeSliderHapticState {
  bool _startEdgeTriggered = false;
  bool _endEdgeTriggered = false;
  double _startLastStep = 0;
  double _endLastStep = 0;
  bool _startIsAtKeyPoint = false;
  bool _endIsAtKeyPoint = false;

  void resetStart(double currentValue, double min, double max) {
    _startEdgeTriggered = currentValue == min;
    _startLastStep = currentValue;
    _startIsAtKeyPoint = false;
  }

  void resetEnd(double currentValue, double min, double max) {
    _endEdgeTriggered = currentValue == max;
    _endLastStep = currentValue;
    _endIsAtKeyPoint = false;
  }

  void handleStartHapticFeedback(
    double currentValue,
    double min,
    double max,
    MiuixSliderHapticEffect hapticEffect,
    List<double> keyPointFractions, {
    bool hasCustomKeyPoints = false,
  }) {
    if (hapticEffect == MiuixSliderHapticEffect.none) return;
    _handleEdge(currentValue, min, isStart: true);
    if (hapticEffect == MiuixSliderHapticEffect.step) {
      _handleStep(currentValue, min, max, keyPointFractions,
          hasCustomKeyPoints, isStart: true, edgeValue: min);
    }
  }

  void handleEndHapticFeedback(
    double currentValue,
    double min,
    double max,
    MiuixSliderHapticEffect hapticEffect,
    List<double> keyPointFractions, {
    bool hasCustomKeyPoints = false,
  }) {
    if (hapticEffect == MiuixSliderHapticEffect.none) return;
    _handleEdge(currentValue, max, isStart: false);
    if (hapticEffect == MiuixSliderHapticEffect.step) {
      _handleStep(currentValue, min, max, keyPointFractions,
          hasCustomKeyPoints, isStart: false, edgeValue: max);
    }
  }

  void _handleEdge(double currentValue, double edgeValue,
      {required bool isStart}) {
    final isAtEdge = currentValue == edgeValue;
    if (isStart) {
      if (isAtEdge && !_startEdgeTriggered) {
        HapticFeedback.selectionClick();
        _startEdgeTriggered = true;
      } else if (!isAtEdge) {
        _startEdgeTriggered = false;
      }
    } else {
      if (isAtEdge && !_endEdgeTriggered) {
        HapticFeedback.selectionClick();
        _endEdgeTriggered = true;
      } else if (!isAtEdge) {
        _endEdgeTriggered = false;
      }
    }
  }

  void _handleStep(
    double currentValue,
    double min,
    double max,
    List<double> keyPointFractions,
    bool hasCustomKeyPoints, {
    required bool isStart,
    required double edgeValue,
  }) {
    final isNotAtEdge = currentValue != edgeValue;
    if (hasCustomKeyPoints && keyPointFractions.isNotEmpty) {
      final fraction = (currentValue - min) / (max - min);
      const threshold = 0.005;
      var nearestDist = double.maxFinite;
      for (final kp in keyPointFractions) {
        final dist = (kp - fraction).abs();
        if (dist < nearestDist) nearestDist = dist;
      }
      final currentlyAtKeyPoint = nearestDist < threshold;
      if (isStart) {
        if (currentlyAtKeyPoint && !_startIsAtKeyPoint && isNotAtEdge) {
          HapticFeedback.selectionClick();
        }
        _startIsAtKeyPoint = currentlyAtKeyPoint;
      } else {
        if (currentlyAtKeyPoint && !_endIsAtKeyPoint && isNotAtEdge) {
          HapticFeedback.selectionClick();
        }
        _endIsAtKeyPoint = currentlyAtKeyPoint;
      }
    } else {
      if (isStart) {
        if (!isNotAtEdge) {
          _startLastStep = currentValue;
        } else if (currentValue != _startLastStep) {
          HapticFeedback.selectionClick();
          _startLastStep = currentValue;
        }
      } else {
        if (!isNotAtEdge) {
          _endLastStep = currentValue;
        } else if (currentValue != _endLastStep) {
          HapticFeedback.selectionClick();
          _endLastStep = currentValue;
        }
      }
    }
  }
}

// =============================================================================
// 辅助函数
// =============================================================================

/// 将 steps 转换为归一化的刻度分数列表（含 0 和 1 端点）。
/// 对应 Kotlin `stepsToTickFractions`。
List<double> _stepsToTickFractions(int steps) {
  if (steps == 0) return const [];
  return List.generate(steps + 2, (i) => i / (steps + 1));
}

/// 将点值转换为归一化分数。对应 Kotlin `pointsToFractions`。
List<double> _pointsToFractions(List<double> points, double min, double max) {
  return points
      .map((p) => ((p - min) / (max - min)).clamp(0.0, 1.0))
      .toList();
}

/// 计算用于显示的关键点分数。对应 Kotlin `computeKeyPointFractions`。
List<double> _computeKeyPointFractions(
  List<double>? keyPoints,
  List<double> stepFractions,
  double min,
  double max,
  bool showKeyPoints,
) {
  if (keyPoints != null) return _pointsToFractions(keyPoints, min, max);
  if (showKeyPoints) return stepFractions;
  return const [];
}

/// 计算用于磁性吸附与触感反馈的所有关键点分数。
/// 对应 Kotlin `computeAllKeyPointFractions`。
List<double> _computeAllKeyPointFractions(
  List<double>? keyPoints,
  List<double> stepFractions,
  double min,
  double max,
) {
  if (keyPoints != null) return _pointsToFractions(keyPoints, min, max);
  if (stepFractions.isNotEmpty) return stepFractions;
  return const [];
}

/// 根据归一化分数反解为实际值，处理 steps 量化与关键点磁性吸附。
/// 对应 Kotlin `resolveValueFromFraction`。
double _resolveValueFromFraction({
  required double fraction,
  required double min,
  required double max,
  required int steps,
  required List<double> allKeyPointFractions,
  required double magnetThreshold,
}) {
  final f = fraction.clamp(0.0, 1.0);
  final base = min + (max - min) * f;

  if (steps > 0) {
    final stepCount = steps + 1;
    final stepIndex = (f * stepCount).round().clamp(0, stepCount);
    return min + (max - min) * stepIndex / stepCount;
  }

  if (allKeyPointFractions.isNotEmpty) {
    var closest = allKeyPointFractions[0];
    var bestDist = (closest - f).abs();
    for (var i = 1; i < allKeyPointFractions.length; i++) {
      final cand = allKeyPointFractions[i];
      final dist = (cand - f).abs();
      if (dist < bestDist) {
        bestDist = dist;
        closest = cand;
      }
    }
    if (bestDist < magnetThreshold) {
      return min + (max - min) * closest;
    }
  }

  return base;
}
