import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// 导航类组件演示：TabRow / TabRowWithContour / NavigationBar /
/// FloatingNavigationBar / NavigationRail / BreadcrumbBar。
class NavigationShowcase extends StatefulWidget {
  const NavigationShowcase({super.key});

  @override
  State<NavigationShowcase> createState() => _NavigationShowcaseState();
}

class _NavigationShowcaseState extends State<NavigationShowcase> {
  int _tabRowIndex = 0;
  int _contourIndex = 0;
  int _navIndex = 0;
  int _floatingIndex = 0;
  int _railIndex = 0;
  late final MiuixNavigationRailState _railState;

  // 图标名称使用 MiuixIcons.extended 内置图标。
  static const _floatingDestinations = [
    (icon: 'home', label: '首页'),
    (icon: 'search', label: '发现'),
    (icon: 'messages', label: '通知'),
    (icon: 'contacts', label: '我的'),
  ];

  static const _railDestinations = [
    (icon: 'home', label: '首页'),
    (icon: 'search', label: '发现'),
    (icon: 'messages', label: '通知'),
    (icon: 'contacts', label: '我的'),
  ];

  @override
  void initState() {
    super.initState();
    _railState = MiuixNavigationRailState();
  }

  @override
  void dispose() {
    _railState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ts = MiuixTheme.of(context).textStyles;
    final colors = MiuixTheme.of(context).colors;
    const tabs1 = ['推荐', '关注', '热门', '附近'];
    const tabs2 = ['首页', '分类', '我的'];
    return ShowcasePage(
      title: '导航 Navigation',
      subtitle:
          'TabRow / NavigationBar / NavigationRail / FloatingNavigationBar / BreadcrumbBar',
      sections: [
        ShowcaseSection('MiuixTabRow', [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: MiuixTabRow(
              tabs: tabs1,
              selectedTabIndex: _tabRowIndex,
              onTabSelected: (i) => setState(() => _tabRowIndex = i),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: MiuixText(
              '当前选中：${tabs1[_tabRowIndex]}',
              style: ts.body2,
              color: colors.onSurfaceVariantSummary,
            ),
          ),
        ]),
        ShowcaseSection('MiuixTabRowWithContour', [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: MiuixTabRowWithContour(
              tabs: tabs2,
              selectedTabIndex: _contourIndex,
              onTabSelected: (i) => setState(() => _contourIndex = i),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: MiuixText(
              '当前选中：${tabs2[_contourIndex]}',
              style: ts.body2,
              color: colors.onSurfaceVariantSummary,
            ),
          ),
        ]),
        ShowcaseSection('MiuixBreadcrumbBar', [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: MiuixBreadcrumbBar(
              items: const [
                MiuixBreadcrumbItem(path: 'home', text: '首页'),
                MiuixBreadcrumbItem(path: 'list', text: '列表'),
                MiuixBreadcrumbItem(path: 'detail', text: '详情'),
              ],
              onItemClick: (i) {},
            ),
          ),
        ]),
        ShowcaseSection('MiuixNavigationBar（底部）', [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 80,
              child: MiuixNavigationBar(
                children: [
                  MiuixNavigationBarItem(
                    selected: _navIndex == 0,
                    onPressed: () => setState(() => _navIndex = 0),
                    icon: MiuixIcon(
                      vector: MiuixIcons.extended.byName('home')!,
                      size: 24,
                    ),
                    label: '首页',
                  ),
                  MiuixNavigationBarItem(
                    selected: _navIndex == 1,
                    onPressed: () => setState(() => _navIndex = 1),
                    icon: MiuixIcon(
                      vector: MiuixIcons.extended.byName('search')!,
                      size: 24,
                    ),
                    label: '发现',
                  ),
                  MiuixNavigationBarItem(
                    selected: _navIndex == 2,
                    onPressed: () => setState(() => _navIndex = 2),
                    icon: MiuixIcon(
                      vector: MiuixIcons.extended.byName('contacts')!,
                      size: 24,
                    ),
                    label: '我的',
                  ),
                ],
              ),
            ),
          ),
        ]),
        ShowcaseSection('MiuixFloatingNavigationBar（悬浮）', [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 200,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MiuixIcon(
                            vector: MiuixIcons.extended.byName(
                              _floatingDestinations[_floatingIndex].icon,
                            )!,
                            size: 48,
                            tint: colors.onBackground,
                          ),
                          const SizedBox(height: 8),
                          MiuixText(
                            _floatingDestinations[_floatingIndex].label,
                            style: ts.title4,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: MiuixFloatingNavigationBar(
                        children: [
                          for (final (i, dest)
                              in _floatingDestinations.indexed)
                            MiuixFloatingNavigationBarItem(
                              selected: _floatingIndex == i,
                              onPressed: () =>
                                  setState(() => _floatingIndex = i),
                              icon: MiuixIcon(
                                vector:
                                    MiuixIcons.extended.byName(dest.icon)!,
                                size: 24,
                              ),
                              label: dest.label,
                              badge: i == 2
                                  ? const MiuixBadge(child: MiuixText('3'))
                                  : null,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
        ShowcaseSection('MiuixNavigationRail（侧边导航栏）', [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            // 用 AnimatedBuilder 监听 _railState，展开/收起时按钮文字同步更新。
            child: AnimatedBuilder(
              animation: _railState,
              builder: (context, _) {
                return SizedBox(
                  height: 320,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        MiuixNavigationRail(
                          state: _railState,
                          children: [
                            for (final (i, dest)
                                in _railDestinations.indexed)
                              MiuixNavigationRailItem(
                                selected: _railIndex == i,
                                onPressed: () =>
                                    setState(() => _railIndex = i),
                                icon: MiuixIcon(
                                  vector:
                                      MiuixIcons.extended.byName(dest.icon)!,
                                  size: 24,
                                ),
                                label: dest.label,
                                badge: i == 2
                                    ? const MiuixBadge(
                                        child: MiuixText('5'),
                                      )
                                    : null,
                              ),
                          ],
                        ),
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MiuixIcon(
                                  vector: MiuixIcons.extended.byName(
                                    _railDestinations[_railIndex].icon,
                                  )!,
                                  size: 48,
                                  tint: colors.onBackground,
                                ),
                                const SizedBox(height: 8),
                                MiuixText(
                                  _railDestinations[_railIndex].label,
                                  style: ts.title4,
                                ),
                                const SizedBox(height: 20),
                                MiuixButton(
                                  onPressed: () => _railState.toggle(),
                                  child: MiuixText(
                                    _railState.isExpanded ? '收起侧栏' : '展开侧栏',
                                    style: ts.button,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: MiuixText(
              '桌面/平板适配的侧边导航栏，可折叠/展开，点击右侧按钮切换。',
              style: ts.body2,
              color: colors.onSurfaceVariantSummary,
            ),
          ),
        ]),
      ],
    );
  }
}
