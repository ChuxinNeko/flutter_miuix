// Miuix Flutter 移植版 - Scaffold
// 源自 compose-miuix-ui/miuix 的 Scaffold.kt。
// 用 CustomMultiChildLayout + MultiChildLayoutDelegate 复刻 SubcomposeLayout 的“先测量栏、
// 再把内边距喂给内容”流程；内边距通过 ValueNotifier 回传给 body（ValueListenableBuilder），
// 存在一帧沉降，等价于 Compose 的同帧 subcompose。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';

import '../foundation/miuix_popup_utils.dart';
import 'miuix_surface.dart';

/// 悬浮操作按钮（FAB）在 [MiuixScaffold] 中的位置。对应 Kotlin `FabPosition`。
enum MiuixFabPosition {
  /// 底部起始侧，位于底栏（若存在）上方。
  start,

  /// 底部居中，位于底栏（若存在）上方。
  center,

  /// 底部结束侧，位于底栏（若存在）上方。
  end,

  /// 底部结束侧，覆盖在底栏（若存在）之上。
  endOverlay,
}

/// 悬浮工具栏在 [MiuixScaffold] 中的位置。对应 Kotlin `ToolbarPosition`。
///
/// 枚举顺序与 Kotlin 的整型值一一对应（TopStart=0 … BottomCenter=7）。
enum MiuixToolbarPosition {
  topStart,
  centerStart,
  bottomStart,
  topEnd,
  centerEnd,
  bottomEnd,
  topCenter,
  bottomCenter,
}

/// [MiuixScaffold] 的内容构建器；接收由脚手架计算出的内边距 [contentPadding]，
/// 内容应自行将其应用到根部（对应 Kotlin `content: (PaddingValues) -> Unit`）。
typedef MiuixScaffoldContentBuilder =
    Widget Function(EdgeInsets contentPadding);

// FAB 距底栏 / 脚手架底部的间距。
const double _fabSpacing = 12;

// 悬浮工具栏距脚手架底部的间距（放置时向上抬升该值）。
const double _floatingToolbarSpacing = 4;

/// Miuix 风格的脚手架。对应 Kotlin `Scaffold`。
///
/// 实现 Miuix 的基础视觉布局结构：顶栏、底栏、悬浮按钮、悬浮工具栏、Snackbar 与弹窗层。
/// 内容槽 [content] 会收到脚手架计算出的内边距（顶/底栏高度或系统栏内边距），
/// 由内容自行应用——与 Compose 版一致：body 铺满整个脚手架，栏绘制在其之上。
class MiuixScaffold extends StatefulWidget {
  const MiuixScaffold({
    super.key,
    this.topBar,
    this.bottomBar,
    this.floatingActionButton,
    this.floatingActionButtonPosition = MiuixFabPosition.end,
    this.floatingToolbar,
    this.floatingToolbarPosition = MiuixToolbarPosition.bottomCenter,
    this.snackbarHost,
    this.popupHost,
    this.containerColor,
    this.contentWindowInsets,
    required this.content,
  });

  /// 屏幕顶部的应用栏，通常是 `MiuixTopAppBar`。
  final Widget? topBar;

  /// 屏幕底部的栏，通常是 `MiuixNavigationBar`。
  final Widget? bottomBar;

  /// 悬浮操作按钮。
  final Widget? floatingActionButton;

  /// 悬浮操作按钮的位置，默认 [MiuixFabPosition.end]。
  final MiuixFabPosition floatingActionButtonPosition;

  /// 悬浮工具栏。
  final Widget? floatingToolbar;

  /// 悬浮工具栏的位置，默认 [MiuixToolbarPosition.bottomCenter]。
  final MiuixToolbarPosition floatingToolbarPosition;

  /// 承载 Snackbar 的组件，通常是 `MiuixSnackbarHost`。
  final Widget? snackbarHost;

  /// 承载弹窗与对话框的组件，默认使用 [MiuixPopupHost]。
  ///
  /// 对应 Kotlin 的 `popupHost = { MiuixPopupHost() }`。
  final Widget? popupHost;

  /// 脚手架背景色，默认 `MiuixTheme.colors.surface`；传入透明色可无背景。
  final Color? containerColor;

  /// 传给 [content] 的窗口内边距；为 null 时取 `MediaQuery.paddingOf(context)`
  /// （等价于 Kotlin 默认的 `systemBars ∪ displayCutout`，并已被祖先 SafeArea 扣减）。
  final EdgeInsets? contentWindowInsets;

  /// 屏幕主体内容。lambda 接收应应用到内容根部的内边距。
  final MiuixScaffoldContentBuilder content;

  @override
  State<MiuixScaffold> createState() => _MiuixScaffoldState();
}

class _MiuixScaffoldState extends State<MiuixScaffold> {
  // 对应 Kotlin 那个在测量期更新、却不触发整体重组的可变 paddingHolder。
  // 这里用 ValueNotifier 承载，body 通过 ValueListenableBuilder 单独重建。
  final ValueNotifier<EdgeInsets> _contentPadding = ValueNotifier<EdgeInsets>(
    EdgeInsets.zero,
  );

  @override
  void dispose() {
    _contentPadding.dispose();
    super.dispose();
  }

  // 在布局期由 delegate 回调；延到帧后更新以避免布局中触发 setState。
  void _reportPadding(EdgeInsets padding) {
    if (_contentPadding.value == padding) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _contentPadding.value = padding;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 默认窗口内边距 = systemBars ∪ displayCutout，映射为已被祖先 SafeArea/
    // MediaQuery.removePadding 扣减后的 MediaQuery.paddingOf——等价于 Kotlin 的
    // onConsumedWindowInsetsChanged + exclude(consumed)。
    final EdgeInsets insets =
        widget.contentWindowInsets ?? MediaQuery.paddingOf(context);

    final Widget body = ValueListenableBuilder<EdgeInsets>(
      valueListenable: _contentPadding,
      builder: (context, padding, _) => widget.content(padding),
    );

    return MiuixSurface(
      color: widget.containerColor,
      // MiuixPopupScope：顶层脚手架自成 root，嵌套脚手架复用祖先 root
      // （对应 rootPopupStates = LocalRootPopupStates.current ?: popupStates）。
      child: MiuixPopupScope(
        child: _MiuixScaffoldLayout(
          insets: insets,
          fabPosition: widget.floatingActionButtonPosition,
          toolbarPosition: widget.floatingToolbarPosition,
          onPadding: _reportPadding,
          topBar: widget.topBar,
          bottomBar: widget.bottomBar,
          fab: widget.floatingActionButton,
          floatingToolbar: widget.floatingToolbar,
          snackbar: widget.snackbarHost,
          // 默认承载器渲染本层注册表（对应 Kotlin MiuixPopupHost 读 LocalPopupStates）。
          popup: widget.popupHost ?? const MiuixPopupHost(),
          body: body,
        ),
      ),
    );
  }
}

// 脚手架七个布局槽的标识。绘制顺序即此列表在 children 中的先后：
// body → topBar → snackbar → bottomBar → floatingToolbar → fab → popup（最上层）。
enum _ScaffoldSlot {
  body,
  topBar,
  snackbar,
  bottomBar,
  floatingToolbar,
  fab,
  popup,
}

class _MiuixScaffoldLayout extends StatelessWidget {
  const _MiuixScaffoldLayout({
    required this.insets,
    required this.fabPosition,
    required this.toolbarPosition,
    required this.onPadding,
    required this.topBar,
    required this.bottomBar,
    required this.fab,
    required this.floatingToolbar,
    required this.snackbar,
    required this.popup,
    required this.body,
  });

  final EdgeInsets insets;
  final MiuixFabPosition fabPosition;
  final MiuixToolbarPosition toolbarPosition;
  final ValueChanged<EdgeInsets> onPadding;
  final Widget? topBar;
  final Widget? bottomBar;
  final Widget? fab;
  final Widget? floatingToolbar;
  final Widget? snackbar;
  final Widget popup;
  final Widget body;

  Widget _slot(_ScaffoldSlot id, Widget? child) =>
      LayoutId(id: id, child: child ?? const SizedBox.shrink());

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);
    return CustomMultiChildLayout(
      delegate: _MiuixScaffoldDelegate(
        insets: insets,
        fabPosition: fabPosition,
        toolbarPosition: toolbarPosition,
        direction: direction,
        onPadding: onPadding,
      ),
      children: <Widget>[
        // 顺序即绘制层级（后者在上）。
        _slot(_ScaffoldSlot.body, body),
        _slot(_ScaffoldSlot.topBar, topBar),
        _slot(_ScaffoldSlot.snackbar, snackbar),
        _slot(_ScaffoldSlot.bottomBar, bottomBar),
        _slot(_ScaffoldSlot.floatingToolbar, floatingToolbar),
        _slot(_ScaffoldSlot.fab, fab),
        _slot(_ScaffoldSlot.popup, popup),
      ],
    );
  }
}

class _MiuixScaffoldDelegate extends MultiChildLayoutDelegate {
  _MiuixScaffoldDelegate({
    required this.insets,
    required this.fabPosition,
    required this.toolbarPosition,
    required this.direction,
    required this.onPadding,
  });

  final EdgeInsets insets;
  final MiuixFabPosition fabPosition;
  final MiuixToolbarPosition toolbarPosition;
  final TextDirection direction;
  final ValueChanged<EdgeInsets> onPadding;

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  static bool _isEmpty(Size s) => s.width == 0 && s.height == 0;

  @override
  void performLayout(Size size) {
    final double layoutWidth = size.width;
    final double layoutHeight = size.height;
    final double topInset = insets.top;
    final double leftInset = insets.left;
    final double rightInset = insets.right;
    final double bottomInset = insets.bottom;

    final BoxConstraints full = BoxConstraints.loose(size);
    // 对应 looseConstraints.offset(-left-right, -bottom)。
    final BoxConstraints insetLoose = BoxConstraints(
      maxWidth: (layoutWidth - leftInset - rightInset).clamp(
        0.0,
        double.infinity,
      ),
      maxHeight: (layoutHeight - bottomInset).clamp(0.0, double.infinity),
    );
    final bool isLtr = direction == TextDirection.ltr;

    // 弹窗最先测量（最高层）。用紧约束令 MiuixPopupHost 铺满脚手架，
    // 使其内部 Positioned.fill 遮罩层能覆盖全屏（Kotlin 侧弹窗内容以 fillMaxSize 覆盖）。
    layoutChild(_ScaffoldSlot.popup, BoxConstraints.tight(size));
    final Size topBarSize = layoutChild(_ScaffoldSlot.topBar, full);
    final Size snackbarSize = layoutChild(_ScaffoldSlot.snackbar, insetLoose);
    final Size fabSize = layoutChild(_ScaffoldSlot.fab, insetLoose);
    final Size bottomBarSize = layoutChild(_ScaffoldSlot.bottomBar, full);
    final Size toolbarSize = layoutChild(
      _ScaffoldSlot.floatingToolbar,
      insetLoose,
    );

    final bool topBarEmpty = _isEmpty(topBarSize);
    final bool bottomBarEmpty = _isEmpty(bottomBarSize);
    final bool fabEmpty = _isEmpty(fabSize);
    final bool toolbarEmpty = _isEmpty(toolbarSize);

    // FAB 相对左边缘的偏移，兼顾 LTR / RTL。
    double? fabLeft;
    if (!fabEmpty) {
      final double fabWidth = fabSize.width;
      switch (fabPosition) {
        case MiuixFabPosition.start:
          fabLeft = isLtr
              ? _fabSpacing + leftInset
              : layoutWidth - _fabSpacing - fabWidth - rightInset;
        case MiuixFabPosition.end:
        case MiuixFabPosition.endOverlay:
          fabLeft = isLtr
              ? layoutWidth - _fabSpacing - fabWidth - rightInset
              : _fabSpacing + leftInset;
        case MiuixFabPosition.center:
          fabLeft = (layoutWidth - fabWidth + leftInset - rightInset) / 2;
      }
    }

    final double? fabOffsetFromBottom = fabEmpty
        ? null
        : (bottomBarEmpty || fabPosition == MiuixFabPosition.endOverlay
              ? fabSize.height + _fabSpacing + bottomInset
              : bottomBarSize.height + fabSize.height + _fabSpacing);

    final double snackbarHeight = snackbarSize.height;
    final double snackbarOffsetFromBottom = snackbarHeight != 0
        ? snackbarHeight +
              (fabOffsetFromBottom ??
                  (bottomBarEmpty ? bottomInset : bottomBarSize.height))
        : 0;

    // 计算并回传内容内边距（帧后生效，由 body 单独重建）。
    onPadding(
      EdgeInsets.fromLTRB(
        leftInset,
        topBarEmpty ? topInset : topBarSize.height,
        rightInset,
        bottomBarEmpty ? bottomInset : bottomBarSize.height,
      ),
    );

    // body 铺满整个脚手架（loose，实际填满）；内边距由内容自行应用。
    layoutChild(_ScaffoldSlot.body, full);

    // 放置（绘制顺序由 children 顺序决定，这里只定位）。
    positionChild(_ScaffoldSlot.body, Offset.zero);
    positionChild(_ScaffoldSlot.topBar, Offset.zero);
    positionChild(
      _ScaffoldSlot.snackbar,
      Offset(
        (layoutWidth - snackbarSize.width + leftInset - rightInset) / 2,
        layoutHeight - snackbarOffsetFromBottom,
      ),
    );
    positionChild(
      _ScaffoldSlot.bottomBar,
      Offset(0, layoutHeight - bottomBarSize.height),
    );

    if (!toolbarEmpty) {
      final double availableWidth = layoutWidth - leftInset - rightInset;
      final double availableHeight =
          layoutHeight - topBarSize.height - topInset - bottomInset;
      final Offset aligned = _alignToolbar(
        toolbarSize.width,
        toolbarSize.height,
        availableWidth,
        availableHeight,
        isLtr,
      );
      positionChild(
        _ScaffoldSlot.floatingToolbar,
        Offset(
          leftInset + aligned.dx,
          topBarSize.height + topInset + aligned.dy - _floatingToolbarSpacing,
        ),
      );
    } else {
      positionChild(_ScaffoldSlot.floatingToolbar, Offset.zero);
    }

    if (fabLeft != null && fabOffsetFromBottom != null) {
      positionChild(
        _ScaffoldSlot.fab,
        Offset(fabLeft, layoutHeight - fabOffsetFromBottom),
      );
    } else {
      positionChild(_ScaffoldSlot.fab, Offset.zero);
    }

    positionChild(_ScaffoldSlot.popup, Offset.zero);
  }

  // 复刻 Compose Alignment.align：在可用区内按对齐方式放置工具栏，RTL 翻转水平方向。
  Offset _alignToolbar(
    double childWidth,
    double childHeight,
    double availableWidth,
    double availableHeight,
    bool isLtr,
  ) {
    final double freeW = availableWidth - childWidth;
    final double freeH = availableHeight - childHeight;
    late double x;
    late double y;
    switch (toolbarPosition) {
      case MiuixToolbarPosition.topStart:
        x = isLtr ? 0 : freeW;
        y = 0;
      case MiuixToolbarPosition.centerStart:
        x = isLtr ? 0 : freeW;
        y = freeH / 2;
      case MiuixToolbarPosition.bottomStart:
        x = isLtr ? 0 : freeW;
        y = freeH;
      case MiuixToolbarPosition.topEnd:
        x = isLtr ? freeW : 0;
        y = 0;
      case MiuixToolbarPosition.centerEnd:
        x = isLtr ? freeW : 0;
        y = freeH / 2;
      case MiuixToolbarPosition.bottomEnd:
        x = isLtr ? freeW : 0;
        y = freeH;
      case MiuixToolbarPosition.topCenter:
        x = freeW / 2;
        y = 0;
      case MiuixToolbarPosition.bottomCenter:
        x = freeW / 2;
        y = freeH;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_MiuixScaffoldDelegate oldDelegate) {
    return insets != oldDelegate.insets ||
        fabPosition != oldDelegate.fabPosition ||
        toolbarPosition != oldDelegate.toolbarPosition ||
        direction != oldDelegate.direction;
  }
}
