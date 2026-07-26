import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// 实用类组件演示：搜索栏 / 滚动条 / 下拉刷新 / 表面容器。
///
/// - [MiuixSearchBar] + [MiuixInputField]：可展开的搜索栏，展开后显示建议内容。
/// - [MiuixVerticalScrollBar]：叠加在滚动视图上的 Miuix 风格竖向滚动条。
/// - [MiuixHorizontalScrollBar]：横向滚动条。
/// - [MiuixPullToRefresh]：阻尼下拉刷新，状态由调用方提升管理。
/// - [MiuixSurface]：带 squircle 圆角/描边/阴影的基础表面容器。
class UtilityShowcase extends StatefulWidget {
  const UtilityShowcase({super.key});

  @override
  State<UtilityShowcase> createState() => _UtilityShowcaseState();
}

class _UtilityShowcaseState extends State<UtilityShowcase> {
  // 搜索栏状态。
  String _query = '';
  bool _searchExpanded = false;

  // 竖向滚动条状态。
  final _scrollController = ScrollController();
  late final MiuixScrollBarAdapter _scrollAdapter =
      MiuixScrollBarAdapter(_scrollController);

  // 横向滚动条状态。
  final _hScrollController = ScrollController();
  late final MiuixScrollBarAdapter _hScrollAdapter =
      MiuixScrollBarAdapter(_hScrollController);

  // 下拉刷新状态。
  bool _isRefreshing = false;
  int _itemCount = 8;

  static const _allSuggestions = [
    '按钮 Button',
    '开关 Switch',
    '滑块 Slider',
    '卡片 Card',
    '对话框 Dialog',
    '搜索栏 SearchBar',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _hScrollController.dispose();
    super.dispose();
  }

  List<String> get _matches => _query.isEmpty
      ? _allSuggestions
      : _allSuggestions.where((s) => s.contains(_query)).toList();

  void _startRefresh() {
    setState(() => _isRefreshing = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _itemCount += 3;
        _isRefreshing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ts = MiuixTheme.of(context).textStyles;
    final colors = MiuixTheme.of(context).colors;
    return ShowcasePage(
      title: '实用 Utility',
      subtitle: 'SearchBar / ScrollBar / PullToRefresh / Surface',
      sections: [
        ShowcaseSection('MiuixSearchBar', [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: MiuixSearchBar(
              expanded: _searchExpanded,
              onExpandedChange: (v) => setState(() => _searchExpanded = v),
              inputField: MiuixInputField(
                query: _query,
                onQueryChange: (v) => setState(() => _query = v),
                onSearch: (_) {},
                expanded: _searchExpanded,
                onExpandedChange: (v) => setState(() => _searchExpanded = v),
                label: '搜索组件',
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final s in _matches)
                    MiuixBasicComponent(
                      title: s,
                      startAction: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: MiuixIcon(
                          vector: MiuixIcons.extended.byName('search')!,
                          size: 20,
                        ),
                      ),
                      onClick: () => setState(() {
                        _query = s;
                        _searchExpanded = false;
                      }),
                    ),
                  if (_matches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: MiuixText('无匹配结果', style: ts.body2),
                    ),
                ],
              ),
            ),
          ),
        ]),
        ShowcaseSection('MiuixVerticalScrollBar', [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 200,
              child: MiuixCard(
                insideMargin: EdgeInsets.zero,
                child: Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: 30,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: MiuixText(
                          '列表项 ${i + 1}',
                          style: ts.body1,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      child:
                          MiuixVerticalScrollBar(adapter: _scrollAdapter),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
        ShowcaseSection('MiuixHorizontalScrollBar', [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 140,
              child: MiuixCard(
                insideMargin: EdgeInsets.zero,
                child: Stack(
                  children: [
                    ListView.builder(
                      controller: _hScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      itemCount: 20,
                      itemBuilder: (context, i) {
                        final blockColors = [
                          colors.primary,
                          colors.secondary,
                          colors.tertiaryContainer,
                          colors.errorContainer,
                          colors.primaryContainer,
                          colors.secondaryContainer,
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            width: 96,
                            decoration: BoxDecoration(
                              color: blockColors[i % blockColors.length],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: MiuixText(
                              '${i + 1}',
                              style: ts.title3,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: MiuixHorizontalScrollBar(
                          adapter: _hScrollAdapter),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
        ShowcaseSection('MiuixPullToRefresh', [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: MiuixText(
              '在下方区域内下拉即可刷新（追加 3 项新内容）。',
              style: ts.body2,
              color: colors.onSurfaceVariantSummary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 260,
              child: MiuixCard(
                insideMargin: EdgeInsets.zero,
                child: ClipRect(
                  child: MiuixPullToRefresh(
                    isRefreshing: _isRefreshing,
                    onRefresh: _startRefresh,
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _itemCount,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: MiuixText('内容项 ${i + 1}', style: ts.body1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
        ShowcaseSection('MiuixSurface', [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MiuixSurface(
                  color: colors.surfaceContainer,
                  cornerRadius: 16,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MiuixText('基础表面', style: ts.title4),
                        const SizedBox(height: 4),
                        MiuixText(
                          'surfaceContainer 背景 + squircle 圆角 16',
                          style: ts.body2,
                          color: colors.onSurfaceVariantSummary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                MiuixSurface(
                  color: colors.surface,
                  cornerRadius: 16,
                  shadowElevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MiuixText('带阴影', style: ts.title4),
                        const SizedBox(height: 4),
                        MiuixText(
                          'shadowElevation: 6，浮起感更强',
                          style: ts.body2,
                          color: colors.onSurfaceVariantSummary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                MiuixSurface(
                  color: colors.surface,
                  cornerRadius: 16,
                  border: Border.all(color: colors.dividerLine),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MiuixText('带描边', style: ts.title4),
                        const SizedBox(height: 4),
                        MiuixText(
                          'border: dividerLine，边界清晰',
                          style: ts.body2,
                          color: colors.onSurfaceVariantSummary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                MiuixSurface(
                  color: colors.primaryContainer,
                  cornerRadius: 16,
                  shadowElevation: 4,
                  border: Border.all(color: colors.primary),
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MiuixText('组合：可点击 + 阴影 + 描边',
                            style: ts.title4),
                        const SizedBox(height: 4),
                        MiuixText(
                          'onPressed 启用按压反馈，点击试试',
                          style: ts.body2,
                          color: colors.onSurfaceVariantSummary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }
}
