// Miuix Flutter 移植版 - Tooltip
// 源自 compose-miuix-ui/miuix 的 Tooltip.kt。
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:flutter/material.dart';

import '../foundation/miuix_content_color.dart';
import '../foundation/miuix_squircle.dart';
import '../theme/miuix_text_styles.dart';
import '../theme/miuix_theme.dart';

/// Tooltip 相对锚点的首选方位；空间不足时会翻转到相反一侧。
enum MiuixTooltipAnchorPosition { above, below, left, right, start, end }

/// Tooltip 内容构建时可用的锚点信息。
@immutable
class MiuixTooltipScope {
  const MiuixTooltipScope({
    required this.positioning,
    required this.anchorBounds,
  });

  /// 当前实际采用的方位（已经过 RTL 解析及空间不足翻转）。
  final MiuixTooltipAnchorPosition positioning;

  /// 锚点在 Overlay 坐标系中的边界。
  final Rect anchorBounds;
}

/// Rich Tooltip 的颜色配置。
@immutable
class MiuixRichTooltipColors {
  const MiuixRichTooltipColors({
    required this.containerColor,
    required this.contentColor,
    required this.titleContentColor,
    required this.actionContentColor,
  });

  final Color containerColor;
  final Color contentColor;
  final Color titleContentColor;
  final Color actionContentColor;
}

/// Tooltip 的尺寸、颜色和动画默认值。
class MiuixTooltipDefaults {
  MiuixTooltipDefaults._();

  static const double spacingBetweenTooltipAndAnchor = 8;
  static const Size caretSize = Size(16, 8);
  static const double plainTooltipMaxWidth = 200;
  static const double plainTooltipCornerRadius = 12;
  static const EdgeInsets plainTooltipInsideMargin =
      EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const double richTooltipMaxWidth = 320;
  static const double richTooltipCornerRadius = 16;
  static const EdgeInsets richTooltipInsideMargin = EdgeInsets.all(16);
  static const double richTooltipActionCornerRadius = 8;
  static const EdgeInsets richTooltipActionInsideMargin =
      EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  static const Duration tooltipDuration = Duration(milliseconds: 1500);
  static const Duration animationDuration = Duration(milliseconds: 180);

  /// Plain Tooltip 使用反色表面。
  static Color plainTooltipContainerColor(BuildContext context) =>
      MiuixTheme.of(context).colors.onSecondaryVariant;

  static Color plainTooltipContentColor(BuildContext context) =>
      MiuixTheme.of(context).colors.secondaryVariant;

  static MiuixRichTooltipColors richTooltipColors(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return MiuixRichTooltipColors(
      containerColor: colors.surfaceContainer,
      contentColor: colors.onSurfaceContainerVariant,
      titleContentColor: colors.onSurfaceContainer,
      actionContentColor: colors.primary,
    );
  }
}

/// 控制 Tooltip 显隐的状态。
///
/// 所有实例共享一个活动槽，因此同一时刻至多显示一个 Tooltip。非持久状态在
/// [MiuixTooltipDefaults.tooltipDuration] 后自动关闭。
class MiuixTooltipState extends ChangeNotifier {
  MiuixTooltipState({
    this.initialIsVisible = false,
    this.isPersistent = false,
  }) : _isVisible = initialIsVisible;

  static MiuixTooltipState? _active;

  final bool initialIsVisible;
  final bool isPersistent;
  bool _isVisible;
  bool _disposed = false;
  Timer? _timer;
  Completer<void>? _showCompleter;

  bool get isVisible => _isVisible;

  /// 显示 Tooltip，并在它关闭时完成返回的 Future。
  Future<void> show() {
    if (_disposed) return Future<void>.value();
    if (_active != null && !identical(_active, this)) _active!.dismiss();
    _active = this;
    _timer?.cancel();
    _showCompleter ??= Completer<void>();
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
    if (!isPersistent) {
      _timer = Timer(MiuixTooltipDefaults.tooltipDuration, dismiss);
    }
    return _showCompleter!.future;
  }

  /// 关闭 Tooltip。
  void dismiss() {
    _timer?.cancel();
    _timer = null;
    if (identical(_active, this)) _active = null;
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
    final completer = _showCompleter;
    _showCompleter = null;
    if (completer != null && !completer.isCompleted) completer.complete();
  }

  @override
  void dispose() {
    dismiss();
    _disposed = true;
    super.dispose();
  }
}

/// 将 [tooltip] 锚定到 [child]，支持鼠标悬停、触摸长按及状态控制。
class MiuixTooltipBox extends StatefulWidget {
  const MiuixTooltipBox({
    super.key,
    required this.tooltip,
    required this.child,
    this.state,
    this.positioning = MiuixTooltipAnchorPosition.below,
    this.spacing = MiuixTooltipDefaults.spacingBetweenTooltipAndAnchor,
    this.focusable = false,
    this.enableUserInput = true,
    this.semanticLabel = '显示提示',
  });

  /// Tooltip 槽。通过 scope 可获得实际方位和锚点边界。
  final Widget Function(BuildContext context, MiuixTooltipScope scope) tooltip;
  final Widget child;
  final MiuixTooltipState? state;
  final MiuixTooltipAnchorPosition positioning;
  final double spacing;
  final bool focusable;
  final bool enableUserInput;
  final String semanticLabel;

  @override
  State<MiuixTooltipBox> createState() => _MiuixTooltipBoxState();
}

class _MiuixTooltipBoxState extends State<MiuixTooltipBox>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  late MiuixTooltipState _state;
  late bool _ownsState;
  late AnimationController _controller;
  OverlayEntry? _entry;
  LocalHistoryEntry? _historyEntry;
  bool _hoveringAnchor = false;
  bool _hoveringTooltip = false;

  @override
  void initState() {
    super.initState();
    _setState(widget.state);
    _controller = AnimationController(
      vsync: this,
      duration: MiuixTooltipDefaults.animationDuration,
      reverseDuration: MiuixTooltipDefaults.animationDuration,
    )..addStatusListener(_onAnimationStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _state.isVisible) _syncVisibility();
    });
  }

  void _setState(MiuixTooltipState? value) {
    _ownsState = value == null;
    _state = value ?? MiuixTooltipState();
    _state.addListener(_syncVisibility);
  }

  @override
  void didUpdateWidget(MiuixTooltipBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.state, widget.state)) {
      _state.removeListener(_syncVisibility);
      if (_ownsState) _state.dispose();
      _setState(widget.state);
      _syncVisibility();
    } else if (_entry != null) {
      _entry!.markNeedsBuild();
    }
  }

  void _syncVisibility() {
    if (!mounted) return;
    if (_state.isVisible) {
      _showOverlay();
      _controller.forward();
    } else {
      _controller.reverse();
      _removeHistoryEntry();
    }
  }

  void _showOverlay() {
    if (_entry != null) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final anchorBox = context.findRenderObject() as RenderBox?;
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (anchorBox == null || overlayBox == null || !anchorBox.hasSize) return;
    final topLeft = anchorBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final anchor = topLeft & anchorBox.size;
    final theme = MiuixTheme.of(context);
    final direction = Directionality.of(context);
    final actualPosition = ValueNotifier<MiuixTooltipAnchorPosition>(
      _resolvePosition(widget.positioning, direction),
    );

    _entry = OverlayEntry(
      builder: (overlayContext) => MiuixTheme(
        data: theme,
        child: Directionality(
          textDirection: direction,
          child: Stack(
            children: [
              if (widget.focusable)
                Positioned.fill(
                  child: Semantics(
                    button: true,
                    label: '关闭提示',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _state.dismiss,
                    ),
                  ),
                ),
              CustomSingleChildLayout(
                delegate: _MiuixTooltipPositionDelegate(
                  anchor: anchor,
                  preferred: widget.positioning,
                  spacing: widget.spacing,
                  textDirection: direction,
                  actualPosition: actualPosition,
                ),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOut,
                    reverseCurve: Curves.easeIn,
                  ),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeOutBack,
                        reverseCurve: Curves.easeIn,
                      ),
                    ),
                    child: MouseRegion(
                      onEnter: (_) => _hoveringTooltip = true,
                      onExit: (_) {
                        _hoveringTooltip = false;
                        if (!_hoveringAnchor && !_state.isPersistent) {
                          _state.dismiss();
                        }
                      },
                      child: Semantics(
                        liveRegion: true,
                        container: true,
                        label: '提示',
                        child: ValueListenableBuilder<MiuixTooltipAnchorPosition>(
                          valueListenable: actualPosition,
                          builder: (context, position, _) => widget.tooltip(
                            context,
                            MiuixTooltipScope(
                              positioning: position,
                              anchorBounds: anchor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    overlay.insert(_entry!);
    if (widget.focusable) {
      _historyEntry = LocalHistoryEntry(onRemove: _state.dismiss);
      ModalRoute.of(context)?.addLocalHistoryEntry(_historyEntry!);
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !_state.isVisible) {
      final entry = _entry;
      _entry = null;
      entry?.remove();
    }
  }

  void _removeHistoryEntry() {
    final entry = _historyEntry;
    _historyEntry = null;
    entry?.remove();
  }

  @override
  void dispose() {
    _state.removeListener(_syncVisibility);
    if (_ownsState) _state.dispose();
    _removeHistoryEntry();
    _entry?.remove();
    _entry = null;
    _controller
      ..removeStatusListener(_onAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = CompositedTransformTarget(link: _link, child: widget.child);
    if (widget.enableUserInput) {
      result = MouseRegion(
        onEnter: (_) {
          _hoveringAnchor = true;
          _state.show();
        },
        onExit: (_) {
          _hoveringAnchor = false;
          scheduleMicrotask(() {
            if (!_hoveringTooltip && !_state.isPersistent) _state.dismiss();
          });
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
          onLongPress: _state.show,
          child: result,
        ),
      );
    }
    return Semantics(
      container: true,
      onLongPress: widget.enableUserInput ? _state.show : null,
      onLongPressHint: widget.enableUserInput ? widget.semanticLabel : null,
      child: result,
    );
  }
}

/// 反色表面的短标签 Tooltip。
class MiuixPlainTooltip extends StatelessWidget {
  const MiuixPlainTooltip({
    super.key,
    required this.scope,
    required this.child,
    this.showCaret = false,
    this.maxWidth = MiuixTooltipDefaults.plainTooltipMaxWidth,
    this.cornerRadius = MiuixTooltipDefaults.plainTooltipCornerRadius,
    this.containerColor,
    this.contentColor,
    this.insideMargin = MiuixTooltipDefaults.plainTooltipInsideMargin,
  });

  final MiuixTooltipScope scope;
  final Widget child;
  final bool showCaret;
  final double maxWidth;
  final double cornerRadius;
  final Color? containerColor;
  final Color? contentColor;
  final EdgeInsetsGeometry insideMargin;

  @override
  Widget build(BuildContext context) {
    final container = containerColor ??
        MiuixTooltipDefaults.plainTooltipContainerColor(context);
    final content =
        contentColor ?? MiuixTooltipDefaults.plainTooltipContentColor(context);
    return Semantics(
      liveRegion: true,
      container: true,
      child: _MiuixTooltipSurface(
        scope: scope,
        showCaret: showCaret,
        maxWidth: maxWidth,
        cornerRadius: cornerRadius,
        containerColor: container,
        insideMargin: insideMargin,
        child: MiuixContentColor(
          color: content,
          child: DefaultTextStyle.merge(
            style: MiuixTheme.of(context).textStyles.body2.copyWith(color: content)
                .withMiuixWeight(MiuixTheme.of(context).fontWeightAdjustment),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 带可选标题和操作的持久 Rich Tooltip。
class MiuixRichTooltip extends StatelessWidget {
  const MiuixRichTooltip({
    super.key,
    required this.scope,
    required this.text,
    this.title,
    this.action,
    this.showCaret = false,
    this.maxWidth = MiuixTooltipDefaults.richTooltipMaxWidth,
    this.cornerRadius = MiuixTooltipDefaults.richTooltipCornerRadius,
    this.colors,
    this.insideMargin = MiuixTooltipDefaults.richTooltipInsideMargin,
  });

  final MiuixTooltipScope scope;
  final Widget text;
  final Widget? title;
  final Widget? action;
  final bool showCaret;
  final double maxWidth;
  final double cornerRadius;
  final MiuixRichTooltipColors? colors;
  final EdgeInsetsGeometry insideMargin;

  @override
  Widget build(BuildContext context) {
    final palette = colors ?? MiuixTooltipDefaults.richTooltipColors(context);
    return Semantics(
      container: true,
      child: _MiuixTooltipSurface(
        scope: scope,
        showCaret: showCaret,
        maxWidth: maxWidth,
        cornerRadius: cornerRadius,
        containerColor: palette.containerColor,
        insideMargin: insideMargin,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              MiuixContentColor(
                color: palette.titleContentColor,
                child: DefaultTextStyle.merge(
                  style: MiuixTheme.of(context)
                      .textStyles
                      .subtitle
                      .copyWith(color: palette.titleContentColor)
                      .withMiuixWeight(MiuixTheme.of(context).fontWeightAdjustment),
                  child: title!,
                ),
              ),
              const SizedBox(height: 8),
            ],
            MiuixContentColor(
              color: palette.contentColor,
              child: DefaultTextStyle.merge(
                style: MiuixTheme.of(context)
                    .textStyles
                    .body2
                    .copyWith(color: palette.contentColor)
                    .withMiuixWeight(MiuixTheme.of(context).fontWeightAdjustment),
                child: text,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: MiuixContentColor(
                  color: palette.actionContentColor,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: palette.actionContentColor),
                    child: action!,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 常用 Rich Tooltip 便捷封装；默认创建持久状态并支持点外及返回键关闭。
class MiuixRichTooltipBox extends StatefulWidget {
  const MiuixRichTooltipBox({
    super.key,
    required this.text,
    required this.child,
    this.state,
    this.title,
    this.actionText,
    this.onActionPressed,
    this.enabled = true,
    this.positioning = MiuixTooltipAnchorPosition.below,
    this.colors,
    this.showCaret = false,
  });

  final String text;
  final Widget child;
  final MiuixTooltipState? state;
  final String? title;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final bool enabled;
  final MiuixTooltipAnchorPosition positioning;
  final MiuixRichTooltipColors? colors;
  final bool showCaret;

  @override
  State<MiuixRichTooltipBox> createState() => _MiuixRichTooltipBoxState();
}

class _MiuixRichTooltipBoxState extends State<MiuixRichTooltipBox> {
  late MiuixTooltipState _state;
  late bool _ownsState;

  @override
  void initState() {
    super.initState();
    _adoptState();
  }

  void _adoptState() {
    _ownsState = widget.state == null;
    _state = widget.state ?? MiuixTooltipState(isPersistent: true);
  }

  @override
  void didUpdateWidget(MiuixRichTooltipBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.state, widget.state)) {
      if (_ownsState) _state.dispose();
      _adoptState();
    }
  }

  @override
  void dispose() {
    if (_ownsState) _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.colors ?? MiuixTooltipDefaults.richTooltipColors(context);
    return MiuixTooltipBox(
      state: _state,
      positioning: widget.positioning,
      focusable: true,
      enableUserInput: widget.enabled,
      tooltip: (context, scope) => MiuixRichTooltip(
        scope: scope,
        colors: palette,
        showCaret: widget.showCaret,
        title: widget.title == null ? null : Text(widget.title!),
        action: widget.actionText == null
            ? null
            : TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: palette.actionContentColor,
                  padding: MiuixTooltipDefaults.richTooltipActionInsideMargin,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      MiuixTooltipDefaults.richTooltipActionCornerRadius,
                    ),
                  ),
                ),
                onPressed: () {
                  widget.onActionPressed?.call();
                  _state.dismiss();
                },
                child: Text(widget.actionText!),
              ),
        text: Text(widget.text),
      ),
      child: widget.child,
    );
  }
}

class _MiuixTooltipSurface extends StatelessWidget {
  const _MiuixTooltipSurface({
    required this.scope,
    required this.showCaret,
    required this.maxWidth,
    required this.cornerRadius,
    required this.containerColor,
    required this.insideMargin,
    required this.child,
  });

  final MiuixTooltipScope scope;
  final bool showCaret;
  final double maxWidth;
  final double cornerRadius;
  final Color containerColor;
  final EdgeInsetsGeometry insideMargin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final vertical = scope.positioning == MiuixTooltipAnchorPosition.above ||
        scope.positioning == MiuixTooltipAnchorPosition.below;
    final caret = showCaret && vertical;
    final caretOnTop = scope.positioning == MiuixTooltipAnchorPosition.below;
    final caretHeight = caret ? MiuixTooltipDefaults.caretSize.height : 0.0;
    final shape = MiuixSquircleBorder(cornerRadius: cornerRadius);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(
        padding: EdgeInsets.only(
          top: caretOnTop ? caretHeight : 0,
          bottom: !caretOnTop ? caretHeight : 0,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: ShapeDecoration(
                color: containerColor,
                shape: shape,
                shadows: const [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 10),
                ],
              ),
              child: Padding(padding: insideMargin, child: child),
            ),
            if (caret)
              Positioned(
                top: caretOnTop ? -caretHeight : null,
                bottom: caretOnTop ? null : -caretHeight,
                child: CustomPaint(
                  size: MiuixTooltipDefaults.caretSize,
                  painter: _MiuixTooltipCaretPainter(
                    color: containerColor,
                    pointsDown: !caretOnTop,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiuixTooltipCaretPainter extends CustomPainter {
  const _MiuixTooltipCaretPainter({
    required this.color,
    required this.pointsDown,
  });

  final Color color;
  final bool pointsDown;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointsDown) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height);
    } else {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MiuixTooltipCaretPainter oldDelegate) =>
      color != oldDelegate.color || pointsDown != oldDelegate.pointsDown;
}

class _MiuixTooltipPositionDelegate extends SingleChildLayoutDelegate {
  _MiuixTooltipPositionDelegate({
    required this.anchor,
    required this.preferred,
    required this.spacing,
    required this.textDirection,
    required this.actualPosition,
  });

  final Rect anchor;
  final MiuixTooltipAnchorPosition preferred;
  final double spacing;
  final TextDirection textDirection;
  final ValueNotifier<MiuixTooltipAnchorPosition> actualPosition;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(constraints.biggest);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final resolved = _resolvePosition(preferred, textDirection);
    final opposite = _opposite(resolved);
    final selected = _fits(resolved, size, childSize) ||
            !_fits(opposite, size, childSize)
        ? resolved
        : opposite;
    if (actualPosition.value != selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (actualPosition.value != selected) actualPosition.value = selected;
      });
    }

    double x = anchor.center.dx - childSize.width / 2;
    double y = anchor.center.dy - childSize.height / 2;
    switch (selected) {
      case MiuixTooltipAnchorPosition.above:
        y = anchor.top - childSize.height - spacing;
      case MiuixTooltipAnchorPosition.below:
        y = anchor.bottom + spacing;
      case MiuixTooltipAnchorPosition.left:
        x = anchor.left - childSize.width - spacing;
      case MiuixTooltipAnchorPosition.right:
        x = anchor.right + spacing;
      case MiuixTooltipAnchorPosition.start:
      case MiuixTooltipAnchorPosition.end:
        break;
    }
    return Offset(
      x.clamp(0.0, (size.width - childSize.width).clamp(0.0, size.width)),
      y.clamp(0.0, (size.height - childSize.height).clamp(0.0, size.height)),
    );
  }

  bool _fits(MiuixTooltipAnchorPosition side, Size area, Size child) {
    return switch (side) {
      MiuixTooltipAnchorPosition.above =>
        anchor.top - spacing >= child.height,
      MiuixTooltipAnchorPosition.below =>
        area.height - anchor.bottom - spacing >= child.height,
      MiuixTooltipAnchorPosition.left =>
        anchor.left - spacing >= child.width,
      MiuixTooltipAnchorPosition.right =>
        area.width - anchor.right - spacing >= child.width,
      MiuixTooltipAnchorPosition.start || MiuixTooltipAnchorPosition.end => false,
    };
  }

  @override
  bool shouldRelayout(_MiuixTooltipPositionDelegate oldDelegate) =>
      anchor != oldDelegate.anchor ||
      preferred != oldDelegate.preferred ||
      spacing != oldDelegate.spacing ||
      textDirection != oldDelegate.textDirection;
}

MiuixTooltipAnchorPosition _resolvePosition(
  MiuixTooltipAnchorPosition position,
  TextDirection direction,
) {
  if (position == MiuixTooltipAnchorPosition.start) {
    return direction == TextDirection.ltr
        ? MiuixTooltipAnchorPosition.left
        : MiuixTooltipAnchorPosition.right;
  }
  if (position == MiuixTooltipAnchorPosition.end) {
    return direction == TextDirection.ltr
        ? MiuixTooltipAnchorPosition.right
        : MiuixTooltipAnchorPosition.left;
  }
  return position;
}

MiuixTooltipAnchorPosition _opposite(MiuixTooltipAnchorPosition position) {
  return switch (position) {
    MiuixTooltipAnchorPosition.above => MiuixTooltipAnchorPosition.below,
    MiuixTooltipAnchorPosition.below => MiuixTooltipAnchorPosition.above,
    MiuixTooltipAnchorPosition.left => MiuixTooltipAnchorPosition.right,
    MiuixTooltipAnchorPosition.right => MiuixTooltipAnchorPosition.left,
    MiuixTooltipAnchorPosition.start => MiuixTooltipAnchorPosition.end,
    MiuixTooltipAnchorPosition.end => MiuixTooltipAnchorPosition.start,
  };
}
