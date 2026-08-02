// Miuix Flutter 移植版 - OverlayBottomSheet / WindowBottomSheet
// 源自 compose-miuix-ui/miuix 的 overlay/WindowBottomSheet.kt 与
// layout/BottomSheetContentLayout.kt。
// 使用 Miuix popup host / root Overlay、弹簧平移和纵向拖动复刻底部抽屉。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import '../foundation/miuix_popup_utils.dart';
import '../theme/miuix_text_styles.dart';
import '../theme/miuix_theme.dart';
import 'miuix_overlay_dialog.dart' show MiuixDismissScope;

/// Miuix BottomSheet 默认值。对应 Kotlin `BottomSheetDefaults`。
class MiuixBottomSheetDefaults {
  MiuixBottomSheetDefaults._();

  static const double cornerRadius = 28;
  static const double maxWidth = 640;
  static const Size outsideMargin = Size.zero;
  static const Size insideMargin = Size(24, 0);

  static Color backgroundColor(BuildContext context) =>
      MiuixTheme.of(context).colors.background;
  static Color dragHandleColor(BuildContext context) => MiuixTheme.of(
    context,
  ).colors.onSurfaceVariantSummary.withValues(alpha: 0.2);
}

/// Scaffold 内底部抽屉。对应 Kotlin `OverlayBottomSheet`。
class MiuixOverlayBottomSheet extends StatelessWidget {
  const MiuixOverlayBottomSheet({
    super.key,
    required this.show,
    this.title,
    this.startAction,
    this.endAction,
    this.backgroundColor,
    this.enableWindowDim = true,
    this.cornerRadius = MiuixBottomSheetDefaults.cornerRadius,
    this.sheetMaxWidth = MiuixBottomSheetDefaults.maxWidth,
    this.onDismissRequest,
    this.onDismissFinished,
    this.outsideMargin = MiuixBottomSheetDefaults.outsideMargin,
    this.insideMargin = MiuixBottomSheetDefaults.insideMargin,
    this.defaultWindowInsetsPadding = true,
    this.dragHandleColor,
    this.allowDismiss = true,
    this.enableNestedScroll = true,
    this.renderInRootScaffold = true,
    required this.content,
  });

  final bool show;
  final String? title;
  final Widget? startAction;
  final Widget? endAction;
  final Color? backgroundColor;
  final bool enableWindowDim;
  final double cornerRadius;
  final double sheetMaxWidth;
  final VoidCallback? onDismissRequest;
  final VoidCallback? onDismissFinished;
  final Size outsideMargin;
  final Size insideMargin;
  final bool defaultWindowInsetsPadding;
  final Color? dragHandleColor;
  final bool allowDismiss;
  final bool enableNestedScroll;
  final bool renderInRootScaffold;
  final Widget content;

  @override
  Widget build(BuildContext context) => _MiuixBottomSheetLayout(
    show: show,
    title: title,
    startAction: startAction,
    endAction: endAction,
    backgroundColor: backgroundColor,
    enableWindowDim: enableWindowDim,
    cornerRadius: cornerRadius,
    sheetMaxWidth: sheetMaxWidth,
    onDismissRequest: onDismissRequest,
    onDismissFinished: onDismissFinished,
    outsideMargin: outsideMargin,
    insideMargin: insideMargin,
    defaultWindowInsetsPadding: defaultWindowInsetsPadding,
    dragHandleColor: dragHandleColor,
    allowDismiss: allowDismiss,
    enableNestedScroll: enableNestedScroll,
    renderInRootScaffold: renderInRootScaffold,
    windowLevel: false,
    content: content,
  );
}

/// 窗口级底部抽屉。对应 Kotlin `WindowBottomSheet`。
class MiuixWindowBottomSheet extends StatelessWidget {
  const MiuixWindowBottomSheet({
    super.key,
    required this.show,
    this.title,
    this.startAction,
    this.endAction,
    this.backgroundColor,
    this.enableWindowDim = true,
    this.cornerRadius = MiuixBottomSheetDefaults.cornerRadius,
    this.sheetMaxWidth = MiuixBottomSheetDefaults.maxWidth,
    this.onDismissRequest,
    this.onDismissFinished,
    this.outsideMargin = MiuixBottomSheetDefaults.outsideMargin,
    this.insideMargin = MiuixBottomSheetDefaults.insideMargin,
    this.defaultWindowInsetsPadding = true,
    this.dragHandleColor,
    this.allowDismiss = true,
    this.enableNestedScroll = true,
    required this.content,
  });

  final bool show;
  final String? title;
  final Widget? startAction;
  final Widget? endAction;
  final Color? backgroundColor;
  final bool enableWindowDim;
  final double cornerRadius;
  final double sheetMaxWidth;
  final VoidCallback? onDismissRequest;
  final VoidCallback? onDismissFinished;
  final Size outsideMargin;
  final Size insideMargin;
  final bool defaultWindowInsetsPadding;
  final Color? dragHandleColor;
  final bool allowDismiss;
  final bool enableNestedScroll;
  final Widget content;

  @override
  Widget build(BuildContext context) => _MiuixBottomSheetLayout(
    show: show,
    title: title,
    startAction: startAction,
    endAction: endAction,
    backgroundColor: backgroundColor,
    enableWindowDim: enableWindowDim,
    cornerRadius: cornerRadius,
    sheetMaxWidth: sheetMaxWidth,
    onDismissRequest: onDismissRequest,
    onDismissFinished: onDismissFinished,
    outsideMargin: outsideMargin,
    insideMargin: insideMargin,
    defaultWindowInsetsPadding: defaultWindowInsetsPadding,
    dragHandleColor: dragHandleColor,
    allowDismiss: allowDismiss,
    enableNestedScroll: enableNestedScroll,
    renderInRootScaffold: true,
    windowLevel: true,
    content: content,
  );
}

class _MiuixBottomSheetLayout extends StatefulWidget {
  const _MiuixBottomSheetLayout({
    required this.show,
    required this.title,
    required this.startAction,
    required this.endAction,
    required this.backgroundColor,
    required this.enableWindowDim,
    required this.cornerRadius,
    required this.sheetMaxWidth,
    required this.onDismissRequest,
    required this.onDismissFinished,
    required this.outsideMargin,
    required this.insideMargin,
    required this.defaultWindowInsetsPadding,
    required this.dragHandleColor,
    required this.allowDismiss,
    required this.enableNestedScroll,
    required this.renderInRootScaffold,
    required this.windowLevel,
    required this.content,
  });

  final bool show;
  final String? title;
  final Widget? startAction;
  final Widget? endAction;
  final Color? backgroundColor;
  final bool enableWindowDim;
  final double cornerRadius;
  final double sheetMaxWidth;
  final VoidCallback? onDismissRequest;
  final VoidCallback? onDismissFinished;
  final Size outsideMargin;
  final Size insideMargin;
  final bool defaultWindowInsetsPadding;
  final Color? dragHandleColor;
  final bool allowDismiss;
  final bool enableNestedScroll;
  final bool renderInRootScaffold;
  final bool windowLevel;
  final Widget content;

  @override
  State<_MiuixBottomSheetLayout> createState() =>
      _MiuixBottomSheetLayoutState();
}

class _MiuixBottomSheetLayoutState extends State<_MiuixBottomSheetLayout>
    with TickerProviderStateMixin {
  late final MiuixPopupController _popupController;
  late final AnimationController _progress;
  late final AnimationController _handlePress;
  OverlayEntry? _windowEntry;
  double _dragOffset = 0;
  double _sheetHeight = 500;
  VelocityTracker? _velocityTracker;

  @override
  void initState() {
    super.initState();
    _popupController = MiuixPopupController(visible: widget.show);
    _progress = AnimationController.unbounded(vsync: this, value: 0);
    _handlePress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _syncVisibility(initial: true);
  }

  @override
  void didUpdateWidget(_MiuixBottomSheetLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) _syncVisibility();
    _windowEntry?.markNeedsBuild();
  }

  SpringDescription get _enterSpring =>
      SpringDescription.withDampingRatio(mass: 1, stiffness: 273.4, ratio: 0.9);

  TickerFuture _springTo(double target, {double velocity = 0}) {
    return _progress.animateWith(
      SpringSimulation(
        _enterSpring,
        _progress.value,
        target,
        velocity,
        tolerance: const Tolerance(distance: 0.0001, velocity: 0.0001),
      ),
    );
  }

  void _syncVisibility({bool initial = false}) {
    if (widget.show) {
      _dragOffset = 0;
      if (widget.windowLevel) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _ensureWindowEntry(),
        );
      } else {
        _popupController.show();
      }
      _springTo(1);
    } else if (!initial) {
      // 退出动画用弹簧模拟；AnimationController.animateWith 始终以 forward 方向
      // 运行，弹簧收敛到 0 时状态是 completed 而非 dismissed。因此不能靠
      // AnimationStatus.dismissed 判定退出完成（那样永远等不到，遮罩层会残留
      // 并吞掉所有点击）。改为在 TickerFuture 完成时收尾；若期间被重新打开，
      // animateWith 会取消上一条 ticker，orCancel 抛错，onError 里忽略即可。
      _springTo(0).orCancel.then(
        (_) => _finishDismiss(),
        onError: (_) {},
      );
    }
  }

  /// 退出动画结束后的收尾：关闭弹窗（移除遮罩）、清理窗口层、回调。
  void _finishDismiss() {
    if (!mounted || widget.show) return;
    _popupController.dismiss();
    _removeWindowEntry();
    widget.onDismissFinished?.call();
  }

  void _ensureWindowEntry() {
    if (!mounted || !widget.show || _windowEntry != null) return;
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _windowEntry = OverlayEntry(builder: (_) => _hosted(context));
    overlay.insert(_windowEntry!);
  }

  void _removeWindowEntry() {
    _windowEntry?.remove();
    _windowEntry?.dispose();
    _windowEntry = null;
  }

  void _requestDismiss() {
    if (widget.allowDismiss) widget.onDismissRequest?.call();
  }

  @override
  void dispose() {
    _removeWindowEntry();
    _popupController.dispose();
    _progress.dispose();
    _handlePress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.windowLevel) return const SizedBox.shrink();
    return MiuixDialogLayout(
      controller: _popupController,
      enableWindowDim: false,
      enableAutoLargeScreen: false,
      enterTransition: _identityTransition,
      exitTransition: _identityTransition,
      renderInRoot: widget.renderInRootScaffold,
      content: (_) => _hosted(context),
    );
  }

  static const MiuixPopupTransition _identityTransition = MiuixPopupTransition(
    duration: Duration.zero,
    builder: _identityBuilder,
  );

  static Widget _identityBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) => child;

  Widget _hosted(BuildContext sourceContext) {
    final MiuixThemeData theme = MiuixTheme.of(sourceContext);
    final Color dim = theme.colors.windowDimming;
    return PopScope<Object?>(
      canPop: !widget.allowDismiss,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestDismiss();
      },
      child: AnimatedBuilder(
        animation: _progress,
        builder: (_, _) {
          final double progress = _progress.value.clamp(0.0, 1.0);
          final double dragAlpha =
              1 - (_dragOffset / _sheetHeight).clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _requestDismiss,
                child: ColoredBox(
                  color: widget.enableWindowDim
                      ? dim.withValues(alpha: dim.a * progress * dragAlpha)
                      : const Color(0x00000000),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    _sheetHeight * (1 - progress) + _dragOffset,
                  ),
                  child: _sheet(sourceContext),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sheet(BuildContext context) {
    final EdgeInsets media = widget.defaultWindowInsetsPadding
        ? MediaQuery.viewInsetsOf(context)
        : EdgeInsets.zero;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: widget.sheetMaxWidth,
        maxHeight:
            MediaQuery.sizeOf(context).height -
            MediaQuery.paddingOf(context).top,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.outsideMargin.width),
        child: _SheetSizeReporter(
          onSize: (size) => _sheetHeight = size.height,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color:
                  widget.backgroundColor ??
                  MiuixBottomSheetDefaults.backgroundColor(context),
              shape: _TopSquircleBorder(cornerRadius: widget.cornerRadius),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: media.bottom + widget.insideMargin.height,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _dragHandle(context),
                  _titleRow(context),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.insideMargin.width,
                      ),
                      child: MiuixDismissScope(
                        onDismissRequest: widget.onDismissRequest ?? () {},
                        child: widget.content,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dragHandle(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _handlePress.forward(),
      onTapUp: (_) => _handlePress.reverse(),
      onTapCancel: _handlePress.reverse,
      onVerticalDragStart: (details) {
        _handlePress.forward();
        _velocityTracker = VelocityTracker.withKind(
          details.kind ?? PointerDeviceKind.touch,
        );
        _velocityTracker!.addPosition(
          details.sourceTimeStamp ?? Duration.zero,
          details.globalPosition,
        );
      },
      onVerticalDragUpdate: (details) {
        _velocityTracker?.addPosition(
          details.sourceTimeStamp ?? Duration.zero,
          details.globalPosition,
        );
        double next = _dragOffset + details.delta.dy;
        if (next < 0 || (!widget.allowDismiss && next > 0)) {
          next = _dragOffset + details.delta.dy * 0.1;
        }
        setState(() => _dragOffset = next);
        _windowEntry?.markNeedsBuild();
      },
      onVerticalDragEnd: (details) {
        _handlePress.reverse();
        final double velocity =
            _velocityTracker?.getVelocity().pixelsPerSecond.dy ??
            details.velocity.pixelsPerSecond.dy;
        if (widget.allowDismiss &&
            (velocity > 800 || (_dragOffset > 150 && velocity > -800))) {
          widget.onDismissRequest?.call();
        } else {
          setState(() => _dragOffset = 0);
          _windowEntry?.markNeedsBuild();
        }
      },
      child: SizedBox(
        height: 24,
        width: double.infinity,
        child: Center(
          child: AnimatedBuilder(
            animation: _handlePress,
            builder: (_, _) => Container(
              width: 45 + 10 * _handlePress.value,
              height: 4 * (1 + 0.15 * _handlePress.value),
              decoration: BoxDecoration(
                color:
                    (widget.dragHandleColor ??
                            MiuixBottomSheetDefaults.dragHandleColor(context))
                        .withValues(alpha: 0.2 + 0.15 * _handlePress.value),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleRow(BuildContext context) {
    if (widget.title == null &&
        widget.startAction == null &&
        widget.endAction == null) {
      return const SizedBox(height: 18);
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.insideMargin.width,
        6,
        widget.insideMargin.width,
        12,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (widget.title != null)
            Text(
              widget.title!,
              textAlign: TextAlign.center,
              style: MiuixTheme.of(context).textStyles.title4.copyWith(
                fontWeight: FontWeight.w500,
                color: MiuixTheme.of(context).colors.onSurface,
              ).withMiuixWeight(MiuixTheme.of(context).fontWeightAdjustment),
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: widget.startAction,
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: widget.endAction,
          ),
        ],
      ),
    );
  }
}

class _TopSquircleBorder extends ShapeBorder {
  const _TopSquircleBorder({required this.cornerRadius});

  final double cornerRadius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();
    final double r = cornerRadius.clamp(0.0, rect.width / 2);
    const double control = 0.643;
    final double handle = r * (1 - control);
    path
      ..moveTo(rect.left + r, rect.top)
      ..lineTo(rect.right - r, rect.top)
      ..cubicTo(
        rect.right - handle,
        rect.top,
        rect.right,
        rect.top + handle,
        rect.right,
        rect.top + r,
      )
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top + r)
      ..cubicTo(
        rect.left,
        rect.top + handle,
        rect.left + handle,
        rect.top,
        rect.left + r,
        rect.top,
      )
      ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) =>
      _TopSquircleBorder(cornerRadius: cornerRadius * t);
}

class _SheetSizeReporter extends SingleChildRenderObjectWidget {
  const _SheetSizeReporter({required this.onSize, required super.child});
  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _SheetSizeRenderObject(onSize);

  @override
  void updateRenderObject(
    BuildContext context,
    _SheetSizeRenderObject renderObject,
  ) {
    renderObject.onSize = onSize;
  }
}

class _SheetSizeRenderObject extends RenderProxyBox {
  _SheetSizeRenderObject(this.onSize);
  ValueChanged<Size> onSize;
  Size? _reported;

  @override
  void performLayout() {
    super.performLayout();
    if (size == _reported) return;
    _reported = size;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached) onSize(size);
    });
  }
}
