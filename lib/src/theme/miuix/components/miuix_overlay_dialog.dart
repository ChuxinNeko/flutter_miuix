// Miuix Flutter 移植版 - OverlayDialog
// 源自 compose-miuix-ui/miuix 的 overlay/OverlayDialog.kt 与 layout/DialogContentLayout.kt。
// 通过已移植的 MiuixDialogLayout 注册至 Scaffold 弹层，并在内容层复刻大小屏布局、
// 遮罩、点击外部关闭及 Miuix 进入/退出过渡。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/miuix_popup_utils.dart';
import '../foundation/miuix_squircle.dart';
import '../theme/miuix_text_styles.dart';
import '../theme/miuix_theme.dart';

/// 对应 Kotlin `LocalDismissState`：向对话框内容提供关闭请求。
class MiuixDismissScope extends InheritedWidget {
  const MiuixDismissScope({
    super.key,
    required this.onDismissRequest,
    required super.child,
  });

  final VoidCallback onDismissRequest;

  /// 获取当前对话框的关闭回调；未处于对话框时返回 null。
  static VoidCallback? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<MiuixDismissScope>()
      ?.onDismissRequest;

  @override
  bool updateShouldNotify(MiuixDismissScope oldWidget) =>
      onDismissRequest != oldWidget.onDismissRequest;
}

/// Miuix 对话框默认值。对应 Kotlin `DialogDefaults`。
class MiuixDialogDefaults {
  MiuixDialogDefaults._();

  static const double maxWidth = 420;
  static const double cornerRadius = 32;
  static const Size outsideMargin = Size(12, 12);
  static const Size insideMargin = Size(24, 24);

  static Color titleColor(BuildContext context) =>
      MiuixTheme.of(context).colors.onBackground;
  static Color summaryColor(BuildContext context) =>
      MiuixTheme.of(context).colors.onSurfaceSecondary;
  static Color backgroundColor(BuildContext context) =>
      MiuixTheme.of(context).colors.background;
}

/// Scaffold 内 Miuix 对话框。对应 Kotlin `OverlayDialog`。
class MiuixOverlayDialog extends StatefulWidget {
  const MiuixOverlayDialog({
    super.key,
    required this.show,
    this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.backgroundColor,
    this.enableWindowDim = true,
    this.onDismissRequest,
    this.onDismissFinished,
    this.outsideMargin = MiuixDialogDefaults.outsideMargin,
    this.insideMargin = MiuixDialogDefaults.insideMargin,
    this.defaultWindowInsetsPadding = true,
    this.renderInRootScaffold = true,
    this.maxWidth = MiuixDialogDefaults.maxWidth,
    this.largeScreen,
    this.cornerRadius,
    required this.content,
  });

  final bool show;
  final String? title;
  final Color? titleColor;
  final String? summary;
  final Color? summaryColor;
  final Color? backgroundColor;
  final bool enableWindowDim;
  final VoidCallback? onDismissRequest;
  final VoidCallback? onDismissFinished;
  final Size outsideMargin;
  final Size insideMargin;
  final bool defaultWindowInsetsPadding;
  final bool renderInRootScaffold;
  final double maxWidth;
  final bool? largeScreen;
  final double? cornerRadius;
  final Widget content;

  @override
  State<MiuixOverlayDialog> createState() => _MiuixOverlayDialogState();
}

class _MiuixOverlayDialogState extends State<MiuixOverlayDialog> {
  late final MiuixPopupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MiuixPopupController(visible: widget.show);
  }

  @override
  void didUpdateWidget(MiuixOverlayDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.visible = widget.show;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MiuixDialogLayout(
      controller: _controller,
      enableWindowDim: widget.enableWindowDim,
      enableAutoLargeScreen: widget.largeScreen ?? true,
      onDismissFinished: widget.onDismissFinished,
      renderInRoot: widget.renderInRootScaffold,
      content: (_) => _MiuixDialogContent(
        title: widget.title,
        titleColor: widget.titleColor,
        summary: widget.summary,
        summaryColor: widget.summaryColor,
        backgroundColor: widget.backgroundColor,
        onDismissRequest: widget.onDismissRequest,
        outsideMargin: widget.outsideMargin,
        insideMargin: widget.insideMargin,
        defaultWindowInsetsPadding: widget.defaultWindowInsetsPadding,
        maxWidth: widget.maxWidth,
        largeScreen: widget.largeScreen,
        cornerRadius: widget.cornerRadius,
        child: widget.content,
      ),
    );
  }
}

class _MiuixDialogContent extends StatelessWidget {
  const _MiuixDialogContent({
    required this.title,
    required this.titleColor,
    required this.summary,
    required this.summaryColor,
    required this.backgroundColor,
    required this.onDismissRequest,
    required this.outsideMargin,
    required this.insideMargin,
    required this.defaultWindowInsetsPadding,
    required this.maxWidth,
    required this.largeScreen,
    required this.cornerRadius,
    required this.child,
  });

  final String? title;
  final Color? titleColor;
  final String? summary;
  final Color? summaryColor;
  final Color? backgroundColor;
  final VoidCallback? onDismissRequest;
  final Size outsideMargin;
  final Size insideMargin;
  final bool defaultWindowInsetsPadding;
  final double maxWidth;
  final bool? largeScreen;
  final double? cornerRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MiuixThemeData theme = MiuixTheme.of(context);
    final bool isLarge = largeScreen ?? isMiuixLargeScreen(context);
    final EdgeInsets system = defaultWindowInsetsPadding
        ? MediaQuery.paddingOf(context)
        : EdgeInsets.zero;
    // 输入法（键盘）高度：面板需随键盘上移，否则底部锚定的对话框会被键盘
    // 遮挡（对应 Compose 版 imePadding）。键盘弹出时其高度已覆盖底部安全区，
    // 取两者较大值避免重复留白。
    final double imeBottom = MediaQuery.viewInsetsOf(context).bottom;
    final double radius =
        cornerRadius ?? (isLarge ? MiuixDialogDefaults.cornerRadius : 32);

    Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                title!,
                textAlign: TextAlign.center,
                style: theme.textStyles.title4.copyWith(
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? MiuixDialogDefaults.titleColor(context),
                ).withMiuixWeight(theme.fontWeightAdjustment),
              ),
            ),
          ),
        if (summary != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                summary!,
                textAlign: TextAlign.center,
                style: theme.textStyles.body1.copyWith(
                  color:
                      summaryColor ?? MiuixDialogDefaults.summaryColor(context),
                ).withMiuixWeight(theme.fontWeightAdjustment),
              ),
            ),
          ),
        MiuixDismissScope(
          onDismissRequest: onDismissRequest ?? () {},
          child: child,
        ),
      ],
    );

    column = DecoratedBox(
      decoration: ShapeDecoration(
        color: backgroundColor ?? MiuixDialogDefaults.backgroundColor(context),
        shape: MiuixSquircleBorder(cornerRadius: radius, enabled: radius > 0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: insideMargin.width,
          vertical: insideMargin.height,
        ),
        child: column,
      ),
    );

    final Widget panel = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: isLarge
            ? MediaQuery.sizeOf(context).height * (2 / 3)
            : double.infinity,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: column,
      ),
    );

    // 兜底 Material：MiuixPopupHost 路径已在 _MiuixHostedEntry 中包过 Material，
    // 但本组件也可能被其它路径（如自定义 Overlay/Navigator）直接渲染，缺 Material
    // 祖先时 Text 会出现黄色双下划线。这里用 transparency 类型不引入额外背景，
    // 仅保证 DefaultTextStyle / TextTheme 可用。
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismissRequest,
        child: Semantics(
          button: true,
          label: 'Dismiss',
          onTap: onDismissRequest,
          // AnimatedPadding：键盘高度变化逐帧上报时平滑跟随，避免跳变。
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.fromLTRB(
              outsideMargin.width,
              system.top,
              outsideMargin.width,
              math.max(system.bottom, imeBottom) + outsideMargin.height,
            ),
            child: Align(
              alignment: isLarge ? Alignment.center : Alignment.bottomCenter,
              child: panel,
            ),
          ),
        ),
      ),
    );
  }
}
