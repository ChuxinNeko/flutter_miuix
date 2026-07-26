// Miuix Flutter 移植版 - ScrollBar
// 源自 compose-miuix-ui/miuix 的 ScrollBar.kt。
// 用 ScrollController 适配器、CustomPainter 和拖拽手势复刻浮动滚动条。
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/miuix_theme.dart';

/// 对应 Kotlin `ScrollBarAdapter`，统一适配 Flutter 的 [ScrollController]。
class MiuixScrollBarAdapter {
  const MiuixScrollBarAdapter(this.controller);

  final ScrollController controller;

  ScrollPosition? get _position =>
      controller.hasClients ? controller.position : null;
  double get scrollOffset => _position?.pixels ?? 0;
  double get viewportSize => _position?.viewportDimension ?? 0;
  double get contentSize => (_position?.maxScrollExtent ?? 0) + viewportSize;
  double get maxScrollOffset => math.max(0, contentSize - viewportSize);

  /// 立即滚动到指定内容偏移，并夹在有效范围内。
  void scrollTo(double offset) {
    final position = _position;
    if (position == null) return;
    position.jumpTo(offset.clamp(0.0, position.maxScrollExtent));
  }
}

/// 对应 Kotlin `ScrollBarColors`；null 表示 `Color.Unspecified`。
@immutable
class MiuixScrollBarColors {
  const MiuixScrollBarColors({this.thumbColor, this.trackColor});

  final Color? thumbColor;
  final Color? trackColor;
}

/// 对应 Kotlin `ScrollBarDefaults` 的默认值。
class MiuixScrollBarDefaults {
  MiuixScrollBarDefaults._();

  static const double thumbWidth = 3.64;
  static const double endPadding = 3.46;
  static const double thumbMinLength = 36;
  static const int fadeDelayMillis = 1000;
  static const int fadeDurationMillis = 500;
  static const double touchTargetWidth = 48;
  static const double dragThumbWidth = 6;
  static const double thumbAlpha = 0.1;
  static const double dragThumbAlpha = 0.3;
  static const int dragAnimationDurationMillis = 150;

  static const MiuixScrollBarColors colors = MiuixScrollBarColors();

  static MiuixScrollBarColors defaultColors(BuildContext context) => colors;
}

/// 对应 Kotlin `VerticalScrollBar` 的竖向滚动条。
class MiuixVerticalScrollBar extends StatelessWidget {
  const MiuixVerticalScrollBar({
    super.key,
    required this.adapter,
    this.reverseLayout = false,
    this.trackPadding = EdgeInsets.zero,
    this.colors = MiuixScrollBarDefaults.colors,
    this.thumbWidth = MiuixScrollBarDefaults.thumbWidth,
    this.cornerRadius,
    this.thumbMinLength = MiuixScrollBarDefaults.thumbMinLength,
    this.endPadding = MiuixScrollBarDefaults.endPadding,
  });

  final MiuixScrollBarAdapter adapter;
  final bool reverseLayout;
  final EdgeInsets trackPadding;
  final MiuixScrollBarColors colors;
  final double thumbWidth;
  final double? cornerRadius;
  final double thumbMinLength;
  final double endPadding;

  @override
  Widget build(BuildContext context) => _MiuixScrollBar(
    adapter: adapter,
    vertical: true,
    reverseLayout: reverseLayout,
    trackPadding: trackPadding,
    colors: colors,
    thumbWidth: thumbWidth,
    cornerRadius: cornerRadius,
    thumbMinLength: thumbMinLength,
    endPadding: endPadding,
  );
}

/// 对应 Kotlin `HorizontalScrollBar` 的横向滚动条。
class MiuixHorizontalScrollBar extends StatelessWidget {
  const MiuixHorizontalScrollBar({
    super.key,
    required this.adapter,
    this.reverseLayout = false,
    this.trackPadding = EdgeInsets.zero,
    this.colors = MiuixScrollBarDefaults.colors,
    this.thumbWidth = MiuixScrollBarDefaults.thumbWidth,
    this.cornerRadius,
    this.thumbMinLength = MiuixScrollBarDefaults.thumbMinLength,
    this.endPadding = MiuixScrollBarDefaults.endPadding,
  });

  final MiuixScrollBarAdapter adapter;
  final bool reverseLayout;
  final EdgeInsets trackPadding;
  final MiuixScrollBarColors colors;
  final double thumbWidth;
  final double? cornerRadius;
  final double thumbMinLength;
  final double endPadding;

  @override
  Widget build(BuildContext context) => _MiuixScrollBar(
    adapter: adapter,
    vertical: false,
    reverseLayout: reverseLayout,
    trackPadding: trackPadding,
    colors: colors,
    thumbWidth: thumbWidth,
    cornerRadius: cornerRadius,
    thumbMinLength: thumbMinLength,
    endPadding: endPadding,
  );
}

class _MiuixScrollBar extends StatefulWidget {
  const _MiuixScrollBar({
    required this.adapter,
    required this.vertical,
    required this.reverseLayout,
    required this.trackPadding,
    required this.colors,
    required this.thumbWidth,
    required this.cornerRadius,
    required this.thumbMinLength,
    required this.endPadding,
  });

  final MiuixScrollBarAdapter adapter;
  final bool vertical;
  final bool reverseLayout;
  final EdgeInsets trackPadding;
  final MiuixScrollBarColors colors;
  final double thumbWidth;
  final double? cornerRadius;
  final double thumbMinLength;
  final double endPadding;

  @override
  State<_MiuixScrollBar> createState() => _MiuixScrollBarState();
}

class _MiuixScrollBarState extends State<_MiuixScrollBar>
    with TickerProviderStateMixin {
  late final AnimationController _highlight;
  late final AnimationController _opacity;
  late final AnimationController _length;
  Timer? _fadeTimer;
  bool _hovered = false;
  bool _dragging = false;
  double _trackSize = 0;
  double _displayedLength = 0;
  double _unscrolledDragDistance = 0;

  @override
  void initState() {
    super.initState();
    _highlight = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: MiuixScrollBarDefaults.dragAnimationDurationMillis,
      ),
    );
    _opacity = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: MiuixScrollBarDefaults.fadeDurationMillis,
      ),
    );
    _length =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 150),
        )..addListener(() {
          _displayedLength = _length.value;
          if (mounted) setState(() {});
        });
    widget.adapter.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(_MiuixScrollBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adapter.controller != widget.adapter.controller) {
      oldWidget.adapter.controller.removeListener(_onScroll);
      widget.adapter.controller.addListener(_onScroll);
    }
  }

  bool get _highlighted => _hovered || _dragging;

  void _onScroll() {
    _show();
    if (!_highlighted) _scheduleFade();
    if (mounted) setState(() {});
  }

  void _show() {
    _fadeTimer?.cancel();
    _opacity.value = 1;
  }

  void _scheduleFade() {
    _fadeTimer?.cancel();
    if (_opacity.value <= 0) return;
    _fadeTimer = Timer(
      const Duration(milliseconds: MiuixScrollBarDefaults.fadeDelayMillis),
      () => _opacity.animateTo(0, curve: Curves.fastOutSlowIn),
    );
  }

  void _setHovered(bool value) {
    _hovered = value;
    _syncHighlight();
  }

  void _syncHighlight() {
    if (_highlighted) {
      _show();
      _highlight.animateTo(1, curve: Curves.fastOutSlowIn);
    } else {
      _highlight.animateTo(0, curve: Curves.fastOutSlowIn);
      _scheduleFade();
    }
    setState(() {});
  }

  double get _beforePadding =>
      widget.vertical ? widget.trackPadding.top : widget.trackPadding.left;
  double get _afterPadding =>
      widget.vertical ? widget.trackPadding.bottom : widget.trackPadding.right;

  _SliderGeometry get _geometry => _SliderGeometry(
    adapter: widget.adapter,
    trackSize: _trackSize,
    minThumbSize: widget.thumbMinLength,
    reverseLayout: widget.reverseLayout,
  );

  void _startDrag(DragStartDetails details, Size size) {
    final position = details.localPosition;
    final inStrip = widget.vertical
        ? position.dx >= size.width - MiuixScrollBarDefaults.touchTargetWidth
        : position.dy >= size.height - MiuixScrollBarDefaults.touchTargetWidth;
    if (!inStrip) return;
    final axisPosition = widget.vertical ? position.dy : position.dx;
    final adjusted = axisPosition - _beforePadding;
    final geometry = _geometry;
    final start = geometry.position.roundToDouble();
    final end = start + geometry.thumbSize.roundToDouble();
    if (adjusted < start || adjusted > end) return;
    _dragging = true;
    _unscrolledDragDistance = 0;
    _syncHighlight();
  }

  void _drag(DragUpdateDetails details) {
    if (!_dragging) return;
    final delta = widget.vertical ? details.delta.dy : details.delta.dx;
    final geometry = _geometry;
    final maxPosition = widget.adapter.maxScrollOffset * geometry.scrollScale;
    final current = geometry.position;
    final target = (current + delta + _unscrolledDragDistance).clamp(
      0.0,
      math.max(0.0, maxPosition),
    );
    final sliderDelta = target - current;
    final raw = widget.reverseLayout
        ? geometry.trackSize - geometry.thumbSize - (current + sliderDelta)
        : current + sliderDelta;
    if (geometry.scrollScale != 0) {
      widget.adapter.scrollTo(raw / geometry.scrollScale);
    }
    _unscrolledDragDistance += delta - sliderDelta;
  }

  void _endDrag([DragEndDetails? _]) {
    if (!_dragging) return;
    _dragging = false;
    _syncHighlight();
  }

  @override
  void dispose() {
    widget.adapter.controller.removeListener(_onScroll);
    _fadeTimer?.cancel();
    _highlight.dispose();
    _opacity.dispose();
    _length.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossSize = widget.thumbWidth + widget.endPadding * 2;
        final width = widget.vertical
            ? math.min(crossSize, constraints.maxWidth)
            : constraints.maxWidth;
        final height = widget.vertical
            ? constraints.maxHeight
            : math.min(crossSize, constraints.maxHeight);
        _trackSize = math.max(
          0,
          (widget.vertical ? height : width) -
              (_beforePadding + _afterPadding).round(),
        );
        final geometry = _geometry;
        final targetLength = geometry.thumbSize;
        if (_displayedLength == 0) {
          _displayedLength = targetLength;
          _length.value = targetLength;
        } else if ((targetLength - _displayedLength).abs() >= 1 &&
            !_length.isAnimating) {
          _length.animateTo(targetLength, curve: Curves.fastOutSlowIn);
        } else if ((targetLength - _displayedLength).abs() < 1) {
          _displayedLength = targetLength;
        }
        final baseColor =
            widget.colors.thumbColor ?? MiuixTheme.of(context).colors.onSurface;
        final defaultAlpha =
            widget.colors.thumbColor?.a ?? MiuixScrollBarDefaults.thumbAlpha;
        final dragAlpha =
            widget.colors.thumbColor?.a ??
            MiuixScrollBarDefaults.dragThumbAlpha;

        return MouseRegion(
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) => _startDrag(details, Size(width, height)),
            onPanUpdate: _drag,
            onPanEnd: _endDrag,
            onPanCancel: _endDrag,
            child: SizedBox(
              width: width,
              height: height,
              child: AnimatedBuilder(
                animation: Listenable.merge([_highlight, _opacity]),
                builder: (context, _) {
                  final animatedWidth =
                      widget.thumbWidth +
                      (MiuixScrollBarDefaults.dragThumbWidth -
                              widget.thumbWidth) *
                          _highlight.value;
                  final alpha =
                      defaultAlpha +
                      (dragAlpha - defaultAlpha) * _highlight.value;
                  return CustomPaint(
                    painter: _ScrollBarPainter(
                      vertical: widget.vertical,
                      geometry: geometry,
                      beforePadding: _beforePadding,
                      afterPadding: _afterPadding,
                      thumbWidth: animatedWidth,
                      thumbLength: _displayedLength,
                      endPadding: widget.endPadding,
                      cornerRadius: widget.cornerRadius,
                      opacity: _opacity.value,
                      thumbColor: baseColor.withValues(
                        alpha: (alpha * _opacity.value).clamp(0.0, 1.0),
                      ),
                      trackColor: widget.colors.trackColor,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliderGeometry {
  const _SliderGeometry({
    required this.adapter,
    required this.trackSize,
    required this.minThumbSize,
    required this.reverseLayout,
  });

  final MiuixScrollBarAdapter adapter;
  final double trackSize;
  final double minThumbSize;
  final bool reverseLayout;

  double get visiblePart => adapter.contentSize == 0
      ? 1
      : math.min(1, adapter.viewportSize / adapter.contentSize);
  double get thumbSize => math.max(minThumbSize, trackSize * visiblePart);
  double get scrollScale {
    final extraContent = adapter.maxScrollOffset;
    return extraContent == 0 ? 1 : (trackSize - thumbSize) / extraContent;
  }

  double get rawPosition => scrollScale * adapter.scrollOffset;
  double get position =>
      reverseLayout ? trackSize - thumbSize - rawPosition : rawPosition;
}

class _ScrollBarPainter extends CustomPainter {
  const _ScrollBarPainter({
    required this.vertical,
    required this.geometry,
    required this.beforePadding,
    required this.afterPadding,
    required this.thumbWidth,
    required this.thumbLength,
    required this.endPadding,
    required this.cornerRadius,
    required this.opacity,
    required this.thumbColor,
    required this.trackColor,
  });

  final bool vertical;
  final _SliderGeometry geometry;
  final double beforePadding;
  final double afterPadding;
  final double thumbWidth;
  final double thumbLength;
  final double endPadding;
  final double? cornerRadius;
  final double opacity;
  final Color thumbColor;
  final Color? trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (geometry.trackSize == 0 ||
        opacity <= 0 ||
        geometry.thumbSize >= geometry.trackSize) {
      return;
    }
    final radius = Radius.circular(cornerRadius ?? thumbWidth / 2);
    final cross = vertical
        ? size.width - thumbWidth - endPadding
        : size.height - thumbWidth - endPadding;
    if (trackColor != null) {
      final rect = vertical
          ? Rect.fromLTWH(
              cross,
              beforePadding,
              thumbWidth,
              size.height - beforePadding - afterPadding,
            )
          : Rect.fromLTWH(
              beforePadding,
              cross,
              size.width - beforePadding - afterPadding,
              thumbWidth,
            );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius),
        Paint()
          ..color = trackColor!.withValues(
            alpha: (trackColor!.a * opacity).clamp(0.0, 1.0),
          ),
      );
    }
    final offset = beforePadding + geometry.position;
    final thumbRect = vertical
        ? Rect.fromLTWH(cross, offset, thumbWidth, thumbLength)
        : Rect.fromLTWH(offset, cross, thumbLength, thumbWidth);
    canvas.drawRRect(
      RRect.fromRectAndRadius(thumbRect, radius),
      Paint()..color = thumbColor,
    );
  }

  @override
  bool shouldRepaint(_ScrollBarPainter old) =>
      old.geometry.position != geometry.position ||
      old.geometry.thumbSize != geometry.thumbSize ||
      old.thumbWidth != thumbWidth ||
      old.thumbLength != thumbLength ||
      old.opacity != opacity ||
      old.thumbColor != thumbColor ||
      old.trackColor != trackColor;
}
