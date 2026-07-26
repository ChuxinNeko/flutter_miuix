// Miuix Flutter 移植版 - OverlayListPopup / WindowListPopup
// 源自 compose-miuix-ui/miuix 的 overlay/OverlayListPopup.kt、window/WindowListPopup.kt
// 与 layout/ListPopupLayout.kt。
// 统一布局内核通过锚点 Rect + MiuixPopupPositionProvider 定位，使用基础 ListPopupContent
// 复刻 0.15→1 揭示、淡入淡出、遮罩、外部点击与返回键关闭。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../foundation/miuix_popup_utils.dart';
import '../theme/miuix_theme.dart';
import 'miuix_list_popup.dart';
import 'miuix_overlay_dialog.dart' show MiuixDismissScope;

/// Scaffold 内列表弹窗。对应 Kotlin `OverlayListPopup`。
class MiuixOverlayListPopup extends StatelessWidget {
  const MiuixOverlayListPopup({
    super.key,
    required this.show,
    required this.anchorBounds,
    this.popupPositionProvider,
    this.alignment = MiuixPopupAlign.start,
    this.enableWindowDim = true,
    this.onDismissRequest,
    this.onDismissFinished,
    this.maxHeight,
    this.minWidth = MiuixListPopupDefaults.minWidth,
    this.renderInRootScaffold = true,
    required this.content,
  });

  final bool show;
  final Rect anchorBounds;
  final MiuixPopupPositionProvider? popupPositionProvider;
  final MiuixPopupAlign alignment;
  final bool enableWindowDim;
  final VoidCallback? onDismissRequest;
  final VoidCallback? onDismissFinished;
  final double? maxHeight;
  final double minWidth;
  final bool renderInRootScaffold;
  final Widget content;

  @override
  Widget build(BuildContext context) => _MiuixListPopupLayout(
    show: show,
    anchorBounds: anchorBounds,
    popupPositionProvider: popupPositionProvider,
    alignment: alignment,
    enableWindowDim: enableWindowDim,
    onDismissRequest: onDismissRequest,
    onDismissFinished: onDismissFinished,
    maxHeight: maxHeight,
    minWidth: minWidth,
    renderInRootScaffold: renderInRootScaffold,
    windowLevel: false,
    content: content,
  );
}

/// 窗口级列表弹窗。对应 Kotlin `WindowListPopup`。
///
/// Flutter 的 Navigator Overlay 已是窗口级宿主，因此本组件不依赖 [MiuixScaffold]。
class MiuixWindowListPopup extends StatelessWidget {
  const MiuixWindowListPopup({
    super.key,
    required this.show,
    required this.anchorBounds,
    this.popupPositionProvider,
    this.alignment = MiuixPopupAlign.start,
    this.enableWindowDim = true,
    this.onDismissRequest,
    this.onDismissFinished,
    this.maxHeight,
    this.minWidth = MiuixListPopupDefaults.minWidth,
    required this.content,
  });

  final bool show;
  final Rect anchorBounds;
  final MiuixPopupPositionProvider? popupPositionProvider;
  final MiuixPopupAlign alignment;
  final bool enableWindowDim;
  final VoidCallback? onDismissRequest;
  final VoidCallback? onDismissFinished;
  final double? maxHeight;
  final double minWidth;
  final Widget content;

  @override
  Widget build(BuildContext context) => _MiuixListPopupLayout(
    show: show,
    anchorBounds: anchorBounds,
    popupPositionProvider: popupPositionProvider,
    alignment: alignment,
    enableWindowDim: enableWindowDim,
    onDismissRequest: onDismissRequest,
    onDismissFinished: onDismissFinished,
    maxHeight: maxHeight,
    minWidth: minWidth,
    renderInRootScaffold: true,
    windowLevel: true,
    content: content,
  );
}

class _MiuixListPopupLayout extends StatefulWidget {
  const _MiuixListPopupLayout({
    required this.show,
    required this.anchorBounds,
    required this.popupPositionProvider,
    required this.alignment,
    required this.enableWindowDim,
    required this.onDismissRequest,
    required this.onDismissFinished,
    required this.maxHeight,
    required this.minWidth,
    required this.renderInRootScaffold,
    required this.windowLevel,
    required this.content,
  });

  final bool show;
  final Rect anchorBounds;
  final MiuixPopupPositionProvider? popupPositionProvider;
  final MiuixPopupAlign alignment;
  final bool enableWindowDim;
  final VoidCallback? onDismissRequest;
  final VoidCallback? onDismissFinished;
  final double? maxHeight;
  final double minWidth;
  final bool renderInRootScaffold;
  final bool windowLevel;
  final Widget content;

  @override
  State<_MiuixListPopupLayout> createState() => _MiuixListPopupLayoutState();
}

class _MiuixListPopupLayoutState extends State<_MiuixListPopupLayout>
    with TickerProviderStateMixin {
  late final MiuixPopupController _popupController;
  late final AnimationController _fraction;
  late final AnimationController _alpha;
  OverlayEntry? _windowEntry;
  Size _contentSize = Size.zero;

  MiuixPopupPositionProvider get _positionProvider =>
      widget.popupPositionProvider ?? MiuixListPopupDefaults.dropdownPosition;

  @override
  void initState() {
    super.initState();
    _popupController = MiuixPopupController(visible: widget.show);
    _fraction = AnimationController.unbounded(vsync: this, value: 0);
    _alpha = AnimationController(vsync: this, value: 0);
    _syncVisibility(initial: true);
  }

  @override
  void didUpdateWidget(_MiuixListPopupLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) _syncVisibility();
    if (widget.windowLevel && _windowEntry != null) {
      // didUpdateWidget 处于 build 阶段，不能直接调用 markNeedsBuild，
      // 否则抛 "setState() or markNeedsBuild() called during build"。
      // 延后到帧末执行。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_windowEntry != null) _windowEntry!.markNeedsBuild();
      });
    }
  }

  void _syncVisibility({bool initial = false}) {
    if (widget.show) {
      if (widget.windowLevel) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _ensureWindowEntry(),
        );
      } else {
        _popupController.show();
      }
      _fraction.animateWith(
        SpringSimulation(
          MiuixListPopupDefaults.fractionAnimationSpec.description,
          _fraction.value,
          1,
          _fraction.velocity,
          tolerance: const Tolerance(distance: 0.0001, velocity: 0.0001),
        ),
      );
      _alpha.animateTo(
        1,
        duration: MiuixListPopupDefaults.alphaEnterAnimationSpec.duration,
        curve: MiuixListPopupDefaults.alphaEnterAnimationSpec.curve,
      );
    } else if (!initial) {
      _fraction.animateWith(
        SpringSimulation(
          MiuixListPopupDefaults.fractionAnimationSpec.description,
          _fraction.value,
          0,
          _fraction.velocity,
          tolerance: const Tolerance(distance: 0.0001, velocity: 0.0001),
        ),
      );
      _alpha
          .animateTo(
            0,
            duration: MiuixListPopupDefaults.alphaExitAnimationSpec.duration,
            curve: MiuixListPopupDefaults.alphaExitAnimationSpec.curve,
          )
          .then((_) {
            if (!mounted || widget.show) return;
            _fraction.value = 0;
            _popupController.dismiss();
            _removeWindowEntry();
            widget.onDismissFinished?.call();
          });
    }
  }

  void _ensureWindowEntry() {
    if (!mounted || !widget.show || _windowEntry != null) return;
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    // 用 OverlayEntry 的 builder context 而非本 State 的 build context：
    // 后者在 _MiuixListPopupLayoutState 被 dispose 后失效，但 OverlayEntry
    // 仍在 Overlay 中（关闭动画进行中），_buildHostedContent 仍会被调用，
    // 访问已 dispose 的 context 会抛 "Null check operator used on null value"。
    _windowEntry = OverlayEntry(
      builder: (entryContext) => _buildHostedContent(entryContext),
    );
    overlay.insert(_windowEntry!);
  }

  void _removeWindowEntry() {
    _windowEntry?.remove();
    _windowEntry?.dispose();
    _windowEntry = null;
  }

  @override
  void dispose() {
    _removeWindowEntry();
    _popupController.dispose();
    _fraction.dispose();
    _alpha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.windowLevel) return const SizedBox.shrink();
    return MiuixPopupLayout(
      controller: _popupController,
      enableWindowDim: false,
      enableBackHandler: false,
      enterTransition: _identityTransition,
      exitTransition: _identityTransition,
      renderInRoot: widget.renderInRootScaffold,
      // 用 _MiuixHostedEntry 内部 Builder 的 context 而非本 State 的 build
      // context：后者在本 State 被 dispose 后失效，但 _MiuixHostedEntry 仍在
      // Overlay 中（关闭动画进行中），entry.content 仍会被调用，访问已 dispose
      // 的 context 会抛 "Null check operator used on null value"。
      content: (builderContext) => _buildHostedContent(builderContext),
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

  Widget _buildHostedContent(BuildContext sourceContext) {
    final MediaQueryData media = MediaQuery.of(sourceContext);
    final TextDirection direction = Directionality.of(sourceContext);
    final Rect windowBounds = Rect.fromLTRB(
      media.viewPadding.left,
      media.padding.top,
      media.size.width - media.viewPadding.right,
      media.size.height - media.padding.bottom,
    );
    final EdgeInsets margin = _positionProvider.margins.resolve(direction);
    final double availableHeight =
        (windowBounds.height - margin.top - margin.bottom).clamp(
          MiuixListPopupDefaults.minPopupHeight,
          double.infinity,
        );
    final double resolvedMaxHeight = widget.maxHeight == null
        ? availableHeight
        : widget.maxHeight!.clamp(
            MiuixListPopupDefaults.minPopupHeight,
            availableHeight,
          );
    final MiuixListPopupLayoutInfo info = computeListPopupLayoutInfo(
      sourceContext,
      alignment: widget.alignment,
      popupPositionProvider: _positionProvider,
      parentBounds: widget.anchorBounds,
      popupContentSize: _contentSize,
    );
    final Offset position = _positionProvider.calculatePosition(
      anchorBounds: widget.anchorBounds,
      windowBounds: windowBounds,
      textDirection: direction,
      popupContentSize: _contentSize,
      popupMargin: margin,
      alignment: widget.alignment,
    );

    return Material(
      type: MaterialType.transparency,
      child: PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) widget.onDismissRequest?.call();
        },
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismissRequest,
            child: AnimatedBuilder(
              animation: _alpha,
              builder: (_, _) => ColoredBox(
                color: widget.enableWindowDim
                    ? MiuixTheme.of(
                        sourceContext,
                      ).colors.windowDimming.withValues(
                        alpha:
                            MiuixTheme.of(
                              sourceContext,
                            ).colors.windowDimming.a *
                            _alpha.value,
                      )
                    : const Color(0x00000000),
              ),
            ),
          ),
          Positioned(
            left: position.dx,
            top: position.dy,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: widget.minWidth,
                minHeight: MiuixListPopupDefaults.minPopupHeight,
                maxHeight: resolvedMaxHeight,
                maxWidth: windowBounds.width,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: MiuixDismissScope(
                  onDismissRequest: widget.onDismissRequest ?? () {},
                  child: MiuixListPopupContent(
                    popupContentSize: _contentSize,
                    onPopupContentSizeChange: (size) {
                      if (!mounted || size == _contentSize) return;
                      setState(() => _contentSize = size);
                      _windowEntry?.markNeedsBuild();
                    },
                    fractionProgress: () => _fraction.value,
                    alphaProgress: () => _alpha.value,
                    popupLayoutPosition: info.popupLayoutPosition,
                    localTransformOrigin: info.localTransformOrigin,
                    animation: Listenable.merge(<Listenable>[
                      _fraction,
                      _alpha,
                    ]),
                    child: widget.content,
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
