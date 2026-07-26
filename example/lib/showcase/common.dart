import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

/// 内容区最大宽度：宽屏（横屏/桌面）下把演示内容限宽居中，避免组件被拉得过长。
/// 窄屏（手机）实际宽度小于此值，不受影响。
const double _kMaxContentWidth = 720;

/// 标记内容页处于"嵌入模式"（横屏 WinUI 布局的右侧内容区）。
///
/// 嵌入时 [ShowcasePage] 不再绘制自己的顶栏（顶部由外层全宽标题栏统一承担），
/// 且窗口内边距归零（外层 scaffold 已处理）。竖屏 push 进来的页面无此祖先 → 照常显示顶栏。
class ShowcaseEmbedded extends InheritedWidget {
  const ShowcaseEmbedded({
    super.key,
    this.embedded = true,
    required super.child,
  });

  final bool embedded;

  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ShowcaseEmbedded>()
          ?.embedded ??
      false;

  @override
  bool updateShouldNotify(ShowcaseEmbedded oldWidget) =>
      embedded != oldWidget.embedded;
}

/// Demo 页面通用骨架：[MiuixScaffold] + [MiuixTopAppBar]（含返回按钮）+ 滚动列表。
class ShowcasePage extends StatelessWidget {
  const ShowcasePage({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.sections,
    this.overlay,
    this.snackbarHost,
  });

  final String title;
  final String subtitle;
  final List<ShowcaseSection> sections;
  final Widget? overlay;
  final Widget? snackbarHost;

  @override
  Widget build(BuildContext context) {
    // 嵌入横屏内容区时：不画顶栏（外层全宽标题栏统一承担），内边距归零。
    final embedded = ShowcaseEmbedded.of(context);
    // 仅当能返回时才显示返回按钮：竖屏 push 进来的页面照常显示；嵌入模式无顶栏。
    final canPop = Navigator.of(context).canPop();
    return MiuixScaffold(
      // 嵌入模式内边距归零：顶部空间已由外层标题栏占据，避免重复留白。
      contentWindowInsets: embedded ? EdgeInsets.zero : null,
      topBar: embedded
          ? null
          : MiuixTopAppBar(
              title: title,
              subtitle: subtitle,
              navigationIcon: canPop
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: MiuixIconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                    )
                  : null,
            ),
      snackbarHost: snackbarHost,
      content: (padding) => Material(
        // MiuixTextField 内部使用 Flutter TextField，需要 Material 祖先。
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // 宽屏下把内容限宽并居中，避免组件被拉得过长（窄屏无影响）。
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
                child: ListView.builder(
                  padding: padding.copyWith(bottom: 32),
                  itemCount: sections.length,
                  itemBuilder: (context, index) {
                    final s = sections[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MiuixSmallTitle(s.title),
                        ...s.items,
                      ],
                    );
                  },
                ),
              ),
            ),
            ?overlay,
          ],
        ),
      ),
    );
  }
}

/// 一个分组：标题 + 多个 demo 项。
class ShowcaseSection {
  const ShowcaseSection(this.title, this.items);
  final String title;
  final List<Widget> items;
}

/// 一行 demo 项：左侧标签 + 右侧组件演示。
///
/// 标签统一使用 miuix `body2` 样式（14sp）。
class ShowcaseItem extends StatelessWidget {
  const ShowcaseItem({
    super.key,
    required this.label,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
  });

  final String label;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final ts = MiuixTheme.of(context).textStyles;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 88,
            child: MiuixText(
              label,
              style: ts.body2,
              color: MiuixTheme.of(context).colors.onSurfaceVariantSummary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// 垂直排列多个组件的容器（用于一组同类型 demo）。
class ShowcaseBlock extends StatelessWidget {
  const ShowcaseBlock({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    this.alignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final EdgeInsets padding;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// 分组卡片：用 [MiuixCard] 包裹 [Column]，把多个列表项装进一个圆角卡片。
/// 项之间由调用方插入 [IndentDivider] 分隔。这是 miuix 设置页的标准布局。
class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: MiuixCard(
        // MiuixCard 默认 insideMargin=EdgeInsets.zero，让内部项自己控制内边距。
        child: Column(
          // 必须 min：否则在有界高度容器（如底部弹窗的 Flexible）里，
          // Column 会默认 max 撑满可用高度，导致弹窗几乎占满全屏。
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// 带左侧缩进的水平分隔线（对齐列表项标题，避开起始图标槽位）。
class IndentDivider extends StatelessWidget {
  const IndentDivider({super.key, this.indent = 56});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: const MiuixHorizontalDivider(),
    );
  }
}
