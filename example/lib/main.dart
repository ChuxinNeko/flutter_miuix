import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'showcase/buttons.dart';
import 'showcase/common.dart';
import 'showcase/display.dart';
import 'showcase/feedback.dart';
import 'showcase/inputs.dart';
import 'showcase/menus.dart';
import 'showcase/pickers.dart';
import 'showcase/overlays.dart';
import 'showcase/utility.dart';
import 'showcase/theming.dart';
import 'showcase/foundation.dart';
import 'showcase/blur.dart';
import 'showcase/navigation.dart';
import 'showcase/preferences.dart';

void main() {
  runApp(const MiuixShowcaseApp());
}

/// miuix Flutter 组件库 Demo 入口。
///
/// 用 [MiuixSystemTheme] 跟随系统明暗模式；用 [MiuixScaffold] + [MiuixTopAppBar]
/// 搭建主页，列表展示各组件分类，点击进入对应演示页。
class MiuixShowcaseApp extends StatelessWidget {
  const MiuixShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MiuixSystemTheme(
      child: Builder(
        builder: (context) {
          final themeData = MiuixTheme.of(context);
          return MaterialApp(
            title: 'flutter_miuix',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: themeData.colors.primary,
                brightness: themeData.brightness,
              ),
              brightness: themeData.brightness,
              fontFamily: 'MiSans',
            ),
            home: const _HomePage(),
          );
        },
      ),
    );
  }
}

/// 移动端 / 桌面端的分界宽度（逻辑像素）。
const double _kDesktopBreakpoint = 768;

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage>
    with SingleTickerProviderStateMixin {
  final _scrollBehavior = MiuixExitUntilCollapsedScrollBehavior();
  // 横屏（宽屏）WinUI3 布局：左侧可折叠导航栏 + 右侧内容区。
  final _railState =
      MiuixNavigationRailState(initialValue: MiuixNavigationRailValue.expanded);
  int _selectedRailIndex = 0;
  // 桌面端内联搜索框的焦点节点。移动端折叠态的搜索框**不参与焦点**
  // （见 build 里的 IgnorePointer），故此节点仅桌面端使用。
  final _searchFocusNode = FocusNode();
  // 移动端全屏浮层里输入框的独立焦点节点——移动端唯一真正持有焦点的输入框。
  final _overlaySearchFocusNode = FocusNode();
  // 首页搜索栏容器的 key，用于测量其屏幕位置作为浮层展开动画的起点。
  final _searchBarKey = GlobalKey();

  // --- 搜索状态 ---
  String _query = '';
  bool _searchExpanded = false;
  late final AnimationController _searchAnim;

  // 搜索历史（内存态：最近在前、去重、上限 _kMaxHistory 条）。
  // 跨 app 重启的持久化可后续接入 shared_preferences。
  final List<String> _searchHistory = [];
  static const int _kMaxHistory = 10;

  // 移动端全屏搜索浮层
  OverlayEntry? _searchOverlay;

  // 所有组件入口（缓存，不在 build 中重复构建）
  late final List<_DemoEntry> _allEntries = [
    _DemoEntry(
      icon: 'create',
      title: '按钮 Button',
      summary:
          'MiuixButton / MiuixTextButton / MiuixIconButton / MiuixFloatingActionButton',
      page: const ButtonsShowcase(),
      keywords: ['按钮', '文字按钮', '图标按钮', '悬浮按钮', 'FAB', 'button', 'text', 'icon'],
    ),
    _DemoEntry(
      icon: 'edit',
      title: '输入 Input',
      summary:
          'MiuixTextField / MiuixSwitch / MiuixCheckbox / MiuixRadioButton / MiuixSlider',
      page: const InputsShowcase(),
      keywords: [
        '输入', '开关', '复选框', '单选框', '滑块', '文本框', '输入框',
        'switch', 'checkbox', 'radio', 'slider', 'textfield',
      ],
    ),
    _DemoEntry(
      icon: 'listView',
      title: '菜单选择 Menus',
      summary: 'MiuixDropdownPreference / SpinnerPreference / CascadingMenu',
      page: const MenusShowcase(),
      keywords: ['菜单', '下拉', '级联', 'dropdown', 'spinner', 'cascading'],
    ),
    _DemoEntry(
      icon: 'gridView',
      title: '显示 Display',
      summary:
          'MiuixText / MiuixCard / MiuixBadge / MiuixDivider / MiuixSmallTitle / MiuixBasicComponent',
      page: const DisplayShowcase(),
      keywords: ['显示', '卡片', '徽章', '分割线', '标题', 'card', 'badge', 'divider'],
    ),
    _DemoEntry(
      icon: 'listView',
      title: '列表项 Item',
      summary:
          'MiuixBasicComponent / Arrow / Switch / Checkbox / RadioButton / Slider Preference',
      page: const PreferencesShowcase(),
      keywords: ['列表', '列表项', '设置项', '偏好', 'preference', 'item', '箭头'],
    ),
    _DemoEntry(
      icon: 'edit',
      title: '选择器 Pickers',
      summary: 'MiuixNumberPicker / MiuixColorPicker / MiuixColorPalette / MiuixDatePicker',
      page: const PickersShowcase(),
      keywords: ['选择器', '数字选择', '颜色选择', '调色板', '日期选择', '日历', 'number', 'color', 'palette', 'date', 'calendar'],
    ),
    _DemoEntry(
      icon: 'info',
      title: '反馈 Feedback',
      summary:
          'MiuixSnackbar / MiuixTooltip / MiuixOverlayDialog / MiuixProgressIndicator',
      page: const FeedbackShowcase(),
      keywords: ['反馈', '提示', '弹窗', '对话框', '进度', 'snackbar', 'tooltip', 'dialog', 'progress'],
    ),
    _DemoEntry(
      icon: 'info',
      title: '浮层 Overlays',
      summary: 'MiuixOverlayBottomSheet / MiuixFloatingToolbar',
      page: const OverlaysShowcase(),
      keywords: ['浮层', '底部弹窗', '工具栏', 'bottomsheet', 'toolbar'],
    ),
    _DemoEntry(
      icon: 'sidebar',
      title: '导航 Navigation',
      summary:
          'MiuixTabRow / MiuixTabRowWithContour / MiuixNavigationBar / MiuixBreadcrumbBar',
      page: const NavigationShowcase(),
      keywords: ['导航', '标签', '底部导航', '面包屑', 'tab', 'breadcrumb'],
    ),
    _DemoEntry(
      icon: 'search',
      title: '实用 Utility',
      summary: 'MiuixSearchBar / ScrollBar / PullToRefresh / Surface',
      page: const UtilityShowcase(),
      keywords: ['实用', '搜索', '滚动', '下拉刷新', '表面', 'search', 'scroll', 'refresh', 'surface'],
    ),
    _DemoEntry(
      icon: 'create',
      title: '主题 Theming',
      summary: '动态取色 / 文本样式 / 配色角色 / 图标浏览',
      page: const ThemingShowcase(),
      keywords: ['主题', '动态取色', '文本样式', '配色', '图标', 'theme', 'color', 'style'],
    ),
    _DemoEntry(
      icon: 'image',
      title: '模糊 Blur',
      summary: 'MiuixTextureBlur / 液态玻璃（背景捕获 + 高斯模糊 + 颜色控制）',
      page: const BlurShowcase(),
      keywords: ['模糊', '液态玻璃', '高斯模糊', '毛玻璃', 'glass', 'gaussian', 'texture'],
    ),
    _DemoEntry(
      icon: 'gridView',
      title: '基础 Foundation',
      summary: 'MiuixSquircleBorder / MiuixScrollEndHaptic',
      page: const FoundationShowcase(),
      keywords: ['基础', '圆角', '触感', 'squircle', 'haptic', 'border'],
    ),
  ];

  // ---------- 生命周期 ----------

  @override
  void initState() {
    super.initState();
    _searchAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchAnim.addStatusListener(_onSearchAnimStatus);
  }

  @override
  void dispose() {
    // 先直接摘掉浮层（不走 _removeOverlay，避免其 setState / 访问动画），
    // 再销毁动画与焦点节点，规避"动画 dispose 后又被访问"的断言。
    _searchOverlay?.remove();
    _searchOverlay = null;
    _searchAnim
      ..removeStatusListener(_onSearchAnimStatus)
      ..dispose();
    _searchFocusNode.dispose();
    _overlaySearchFocusNode.dispose();
    _railState.dispose();
    super.dispose();
  }

  // ---------- 搜索逻辑 ----------

  List<_DemoEntry> get _filteredEntries {
    if (_query.isEmpty) return _allEntries;
    final q = _query.toLowerCase();
    return _allEntries.where((e) {
      final haystack =
          '${e.title}\n${e.summary}\n${e.keywords.join(' ')}'.toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  /// 是否为桌面端布局（宽屏不需要全屏覆盖效果）。
  bool _isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _kDesktopBreakpoint;

  // ---------- 搜索历史 ----------

  /// 记录一条搜索历史：去重后置顶，超出上限截断。空白串忽略。
  void _commitHistory(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    _searchHistory
      ..removeWhere((e) => e.toLowerCase() == q.toLowerCase())
      ..insert(0, q);
    if (_searchHistory.length > _kMaxHistory) {
      _searchHistory.removeRange(_kMaxHistory, _searchHistory.length);
    }
  }

  void _removeHistory(String query) {
    setState(() => _searchHistory.remove(query));
    _searchOverlay?.markNeedsBuild();
  }

  void _clearHistory() {
    setState(_searchHistory.clear);
    _searchOverlay?.markNeedsBuild();
  }

  /// 点击某条历史：回填查询词并重搜。
  void _applyHistory(String query) {
    setState(() => _query = query);
    _searchOverlay?.markNeedsBuild();
  }

  // ---------- 移动端浮层管理 ----------

  /// 移动端点击折叠态搜索栏时调用：弹出全屏搜索浮层。
  ///
  /// 折叠态搜索框本身不持有焦点（被 [IgnorePointer] 包裹），点击由外层
  /// [GestureDetector] 捕获后直接走这里——不依赖焦点变化，因此不会与
  /// Flutter 焦点系统的异步时序产生竞态（这是"展开关闭后再点无反应"的根因）。
  void _openMobileSearch() {
    if (_searchOverlay != null) return;
    // 用搜索栏容器的 key 测量其屏幕位置作为动画起点。
    final box =
        _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    // 状态栏 / 刘海高度，用于展开后给系统栏预留位置。
    final topInset = MediaQuery.paddingOf(context).top;

    // 起始 y 坐标：搜索栏顶部在屏幕上的全局位置；若无法获取则从 200px 开始。
    final startY = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero).dy
        : 200.0;

    _searchOverlay = OverlayEntry(
      builder: (ctx) => _MobileSearchPage(
        query: _query,
        onQueryChanged: (v) {
          setState(() => _query = v);
          _searchOverlay?.markNeedsBuild();
        },
        onSearch: (v) {
          setState(() => _commitHistory(v));
          _searchOverlay?.markNeedsBuild();
        },
        onDismiss: _dismissSearchOverlay,
        focusNode: _overlaySearchFocusNode,
        startY: startY,
        topInset: topInset,
        animation: _searchAnim,
        entries: _filteredEntries,
        history: _searchHistory,
        onHistoryTap: _applyHistory,
        onHistoryRemove: _removeHistory,
        onHistoryClear: _clearHistory,
        onCommitQuery: _commitHistory,
      ),
    );
    overlay.insert(_searchOverlay!);
    _searchAnim.forward(from: 0);
    // 触发首页重建以隐藏分组卡片。
    setState(() {});
  }

  void _removeOverlay() {
    if (_searchOverlay == null) return;
    _searchOverlay?.remove();
    _searchOverlay = null;
    _query = '';
    // 关键：把动画归零。点击结果跳转走的是"直接移除"路径（非取消按钮的
    // reverse），若不归零，_searchAnim 会卡在 1.0——首页分组卡片的 opacity
    // 绑定了它（1-fade=0 → 全透明空白），且 IgnorePointer(fade>0) 吞掉点击，
    // 于是"返回后卡片空白、搜索框点不开、再点还闪烁"。归零后卡片恢复可见可点。
    // 在 dispose 阶段 _searchAnim 已被 dispose，故加 mounted 守卫。
    if (mounted) {
      _searchAnim.value = 0;
      setState(() {});
    }
  }

  /// 立即移除浮层并收起键盘。
  /// 用于移动端点击遮罩或搜索结果后跳转前的清理。
  void _dismissSearchOverlay() {
    _removeOverlay();
    if (_overlaySearchFocusNode.hasFocus) _overlaySearchFocusNode.unfocus();
  }

  void _onSearchAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _removeOverlay();
      // 动画结束后收起浮层输入框的键盘 / 焦点。
      if (_overlaySearchFocusNode.hasFocus) _overlaySearchFocusNode.unfocus();
    }
  }

  // ---------- UI 构建 ----------

  /// 首页分组卡片：所有组件分类入口。
  Widget _buildEntriesCard() {
    return GroupCard(
      children: [
        for (var i = 0; i < _allEntries.length; i++) ...[
          if (i > 0) const IndentDivider(),
          _EntryTile(entry: _allEntries[i]),
        ],
      ],
    );
  }

  /// 首页搜索栏。桌面端内联展开；移动端折叠态不参与焦点，点击开浮层。
  Widget _buildHomeSearchBar(BuildContext context, bool isDesktop) {
    final searchBar = MiuixSearchBar(
      expanded: isDesktop && _searchExpanded,
      onExpandedChange: (v) => setState(() {
        _searchExpanded = v;
        if (!v) _query = '';
      }),
      outsideEndAction: GestureDetector(
        onTap: () {
          setState(() {
            _searchExpanded = false;
            _query = '';
          });
          _searchFocusNode.unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            '取消',
            style: TextStyle(
              fontSize: 15,
              color: MiuixTheme.of(context).colors.primary,
            ),
          ),
        ),
      ),
      inputField: MiuixInputField(
        query: _query,
        onQueryChange: (v) {
          setState(() => _query = v);
          _searchOverlay?.markNeedsBuild();
        },
        onSearch: (_) {},
        expanded: isDesktop && _searchExpanded,
        onExpandedChange: (v) {
          if (isDesktop) {
            setState(() {
              _searchExpanded = v;
              if (!v) _query = '';
            });
          }
        },
        // 移动端不传焦点节点：折叠态搜索框不应持有焦点。
        focusNode: isDesktop ? _searchFocusNode : null,
        label: '搜索组件…',
      ),
      content: isDesktop
          ? (_query.trim().isEmpty
                ? _SearchHistoryView(
                    history: _searchHistory,
                    onTap: _applyHistory,
                    onRemove: _removeHistory,
                    onClear: _clearHistory,
                  )
                : _DesktopSearchResults(
                    entries: _filteredEntries,
                    onCommitQuery: () => _commitHistory(_query),
                  ))
          : const SizedBox.shrink(),
    );

    if (isDesktop) return searchBar;

    // 移动端：屏蔽搜索框自身的指针（不抢焦点/不弹键盘），
    // 外层用透明 GestureDetector 捕获点击直接开浮层。
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openMobileSearch,
      child: IgnorePointer(child: searchBar),
    );
  }

  /// 宽屏 WinUI3 布局：
  /// - 顶部：全宽标题栏（app 名，跨整个窗口）。
  /// - 其下：左侧可折叠导航栏（☰ 折叠按钮 + Tab，与首页分组卡片同一批分类）
  ///         | 右侧内容区（直接渲染选中分类页面，无自己的标题栏）。
  Widget _buildWideLayout(BuildContext context) {
    final theme = MiuixTheme.of(context);
    return MiuixScaffold(
      // 全宽标题栏：app 名**左对齐**（放 navigationIcon 左侧槽，正好在侧栏 ☰ 折叠按钮上方），
      // 居中的 title 槽留空。
      topBar: MiuixSmallTopAppBar(
        title: '',
        navigationIcon: MiuixText(
          'flutter_miuix',
          style: theme.textStyles.title3,
          color: theme.colors.onSurface,
          fontWeight: FontWeight.w500,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      content: (padding) => Material(
        // 透明 Material：给导航栏内部原生 Text 提供 Material 祖先（否则黄色下划线）。
        // 右侧内容页各自的 MiuixScaffold 正常嵌套其下。
        type: MaterialType.transparency,
        // padding.top = 标题栏高度：把侧栏 + 内容整体下推到标题栏之下。
        child: Padding(
          padding: EdgeInsets.only(top: padding.top),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MiuixNavigationRail(
                state: _railState,
                // 顶部内边距已由标题栏承担，关掉自带窗口内边距避免重复留白。
                defaultWindowInsetsPadding: false,
                // 缩小侧栏项：图标 22、展开态上下内边距 10、展开字号 14（默认 28/14/16）。
                iconSize: 22,
                expandedItemVerticalPadding: 10,
                expandedLabelFontSize: 14,
                children: [
                  for (var i = 0; i < _allEntries.length; i++)
                    MiuixNavigationRailItem(
                      selected: i == _selectedRailIndex,
                      onPressed: () => setState(() => _selectedRailIndex = i),
                      icon: MiuixIcon(
                        vector:
                            MiuixIcons.extended.byName(_allEntries[i].icon)!,
                        size: 22,
                      ),
                      label: _allEntries[i].title,
                    ),
                ],
              ),
              // 右侧内容区：选中分类页面。ShowcaseEmbedded 让其不画自己的顶栏、
              // 内边距归零（顶部由上面全宽标题栏统一承担）。
              // KeyedSubtree(ValueKey) 确保切分类时正确重建。
              Expanded(
                child: ShowcaseEmbedded(
                  child: KeyedSubtree(
                    key: ValueKey<int>(_selectedRailIndex),
                    child: _allEntries[_selectedRailIndex].page,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 宽屏（横屏 / 平板 / 桌面）走 WinUI3 侧栏布局；窄屏保持原有搜索栏 + 卡片列表。
    if (_isDesktop(context)) {
      return _buildWideLayout(context);
    }

    final isDesktop = _isDesktop(context);
    // 搜索激活时（桌面端展开 / 移动端全屏浮层）隐藏首页分组卡片，避免与搜索结果重复展示。
    final searchActive = isDesktop ? _searchExpanded : _searchOverlay != null;
    // 移动端浮层打开时隐藏首页这个折叠态搜索框：屏幕上只保留浮层里的那一个，
    // 避免"两个搜索框"的错位闪烁。用 Opacity（而非移除）保留其布局，
    // 使 startY 测量稳定、动画回落时能无缝对齐。
    final hideHomeSearchBar = !isDesktop && _searchOverlay != null;

    return MiuixScaffold(
      topBar: MiuixTopAppBar(
        title: 'flutter_miuix',
        scrollBehavior: _scrollBehavior,
        // 顶栏毛玻璃：透过顶栏虚化下方滚动内容（BackdropFilter 实时模糊身后 body）。
        blurred: true,
      ),
      content: (padding) => Material(
        type: MaterialType.transparency,
        child: MiuixScrollBehaviorListener(
          behavior: _scrollBehavior,
          child: ListView(
            padding: padding.copyWith(bottom: 32),
            children: [
              // --- 搜索栏 ---
              // 桌面端：内联可展开，输入框直接持有焦点。
              // 移动端：折叠态搜索框用 IgnorePointer 屏蔽，本身不参与焦点；
              //   点击由外层 GestureDetector 捕获，直接开全屏浮层（真焦点只在浮层内）。
              //   这样彻底避开焦点竞态，杜绝"展开关闭后再点无反应"。
              Padding(
                key: _searchBarKey,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Opacity(
                  opacity: hideHomeSearchBar ? 0.0 : 1.0,
                  child: _buildHomeSearchBar(context, isDesktop),
                ),
              ),

              // --- 组件列表 ---
              // 桌面端：搜索激活时直接移除（结果内联展示在搜索栏里）。
              // 移动端：保留在树里，透明度绑定搜索动画随浮层展开同步渐隐、
              //   收起时渐显——避免瞬间移除造成的突兀 / 残留。
              if (isDesktop) ...[
                if (!searchActive) ...[
                  const SizedBox(height: 16),
                  _buildEntriesCard(),
                ],
              ] else
                AnimatedBuilder(
                  animation: _searchAnim,
                  builder: (context, child) {
                    final t = Curves.easeOutCubic.transform(
                      _searchAnim.value.clamp(0.0, 1.0),
                    );
                    // 与浮层背景同一淡入节奏，卡片在浮层盖满前完成渐隐。
                    final fade = (t * 1.35).clamp(0.0, 1.0);
                    return IgnorePointer(
                      ignoring: fade > 0,
                      child: Opacity(opacity: 1 - fade, child: child),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      _buildEntriesCard(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  桌面端：搜索结果内联展开
// ──────────────────────────────────────────────

class _DesktopSearchResults extends StatelessWidget {
  const _DesktopSearchResults({
    required this.entries,
    required this.onCommitQuery,
  });
  final List<_DemoEntry> entries;

  /// 点击结果跳转前记录当前查询词到历史。
  final VoidCallback onCommitQuery;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            '未找到匹配的组件',
            style: TextStyle(
              fontSize: 14,
              color: MiuixTheme.of(context).colors.onSurfaceVariantSummary,
            ),
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const IndentDivider(indent: 16),
          _SearchResultItem(entry: entries[i], onCommitQuery: onCommitQuery),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────
//  移动端：全屏搜索浮层（OverlayEntry）
// ──────────────────────────────────────────────

class _MobileSearchPage extends StatelessWidget {
  const _MobileSearchPage({
    required this.query,
    required this.onQueryChanged,
    required this.onSearch,
    required this.onDismiss,
    required this.focusNode,
    required this.startY,
    required this.topInset,
    required this.animation,
    required this.entries,
    required this.history,
    required this.onHistoryTap,
    required this.onHistoryRemove,
    required this.onHistoryClear,
    required this.onCommitQuery,
  });

  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSearch;
  final VoidCallback onDismiss;
  final FocusNode focusNode;
  final double startY;

  /// 状态栏 / 刘海高度，展开后为系统栏预留的顶部空间。
  final double topInset;
  final AnimationController animation;
  final List<_DemoEntry> entries;

  /// 搜索历史（最近在前）。
  final List<String> history;
  final ValueChanged<String> onHistoryTap;
  final ValueChanged<String> onHistoryRemove;
  final VoidCallback onHistoryClear;

  /// 点击结果跳转前记录当前查询词到历史。
  final ValueChanged<String> onCommitQuery;

  @override
  Widget build(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;

    // 输入框只构建一次的实例引用：AnimatedBuilder 每帧重建外层包裹，
    // 但同一 MiuixInputField 实例被复用，焦点 / 键盘不丢失。
    final inputField = MiuixInputField(
      query: query,
      onQueryChange: onQueryChanged,
      onSearch: onSearch,
      expanded: true,
      onExpandedChange: (_) {},
      focusNode: focusNode,
      label: '搜索组件…',
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(
          animation.value.clamp(0.0, 1.0),
        );
        // 搜索框从首页位置 startY 丝滑上移到状态栏下方（留 8px 呼吸间距）。
        final contentTop = startY + (topInset + 8 - startY) * t;
        // 页面背景与结果随动画淡入，略快于滑动以尽早盖住底层 app 栏。
        final fade = (t * 1.35).clamp(0.0, 1.0);

        return Stack(
          children: [
            // 页面背景：surface 色淡入 + 吸收点击，避免透传到底层首页。
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: ColoredBox(
                  color: colors.surface.withValues(alpha: fade),
                ),
              ),
            ),
            // 搜索框 + 结果，整体从 startY 上移。
            // 包一层透明 Material 满足 TextField 对 Material 祖先的要求；
            // 背景由下方淡入的 ColoredBox 提供，此层不再上色。
            Positioned(
              top: contentTop,
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                children: [
                  // ── 搜索输入框 + 取消（取消按钮随展开宽度渐入） ──
                  // 水平内边距从 24（首页搜索框位置）过渡到 12，配合上移
                  // 让搜索框从原位无缝滑入，杜绝横向跳变。
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 - 12 * t),
                    child: Row(
                      children: [
                        Expanded(child: inputField),
                        ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: t,
                            child: Opacity(
                              opacity: fade,
                              child: GestureDetector(
                                onTap: animation.reverse,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    '取消',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: colors.primary,
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
                  // ── 分隔线 + 内容区（随动画淡入） ──
                  // 空查询 → 搜索历史；有查询 → 匹配结果。
                  Expanded(
                    child: Opacity(
                      opacity: fade,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: MiuixHorizontalDivider(),
                          ),
                          Expanded(
                            child: query.trim().isEmpty
                                ? _SearchHistoryView(
                                    history: history,
                                    onTap: onHistoryTap,
                                    onRemove: onHistoryRemove,
                                    onClear: onHistoryClear,
                                  )
                                : _MobileSearchResults(
                                    entries: entries,
                                    onDismiss: onDismiss,
                                    onCommitQuery: () => onCommitQuery(query),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 移动端搜索浮层的结果列表（分隔线上方由浮层直接构建）。
class _MobileSearchResults extends StatelessWidget {
  const _MobileSearchResults({
    required this.entries,
    required this.onDismiss,
    required this.onCommitQuery,
  });

  final List<_DemoEntry> entries;
  final VoidCallback onDismiss;

  /// 点击结果跳转前记录当前查询词到历史。
  final VoidCallback onCommitQuery;

  @override
  Widget build(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          '未找到匹配的组件',
          style: TextStyle(
            fontSize: 14,
            color: colors.onSurfaceVariantSummary,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      itemBuilder: (ctx, i) => _SearchResultItem(
        entry: entries[i],
        onDismiss: onDismiss,
        onCommitQuery: onCommitQuery,
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  搜索历史视图
// ──────────────────────────────────────────────

/// 空查询时展示的搜索历史。最近在前，可点击重搜、单条删除、一键清空。
class _SearchHistoryView extends StatelessWidget {
  const _SearchHistoryView({
    required this.history,
    required this.onTap,
    required this.onRemove,
    required this.onClear,
  });

  final List<String> history;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    final textStyles = MiuixTheme.of(context).textStyles;

    if (history.isEmpty) {
      // 用 Column(min) + 水平居中，不依赖有界高度——桌面端 content 槽为无界高度，
      // 若用 Center 会试图撑满无限高度而崩溃。
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MiuixIcon(
              vector: MiuixIcons.basic.search,
              size: 40,
              tint: colors.onSurfaceVariantSummary,
            ),
            const SizedBox(height: 12),
            Text(
              '暂无搜索历史',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariantSummary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      // shrinkWrap 让本视图在两种上下文都可用：移动端浮层里被 Expanded 约束
      // （有界，滚动）；桌面端在搜索栏 content 槽里无界（按内容高度收缩）。
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // 标题行 + 清空按钮。
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('搜索历史', style: textStyles.title4),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '清空',
                    style: TextStyle(fontSize: 14, color: colors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final q in history)
          _HistoryItem(query: q, onTap: () => onTap(q), onRemove: () => onRemove(q)),
      ],
    );
  }
}

/// 单条搜索历史。左侧历史图标 + 查询词，右侧删除按钮。
class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return MiuixBasicComponent(
      title: query,
      insideMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      startAction: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: MiuixIcon(
          vector: MiuixIcons.basic.search,
          size: 22,
          tint: colors.onSurfaceVariantSummary,
        ),
      ),
      endActions: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onRemove,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: MiuixIcon(
              vector: MiuixIcons.basic.close,
              size: 18,
              tint: colors.onSurfaceVariantSummary,
            ),
          ),
        ),
      ],
      onClick: onTap,
    );
  }
}

// ──────────────────────────────────────────────
//  通用：搜索结果条目
// ──────────────────────────────────────────────

class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({
    required this.entry,
    this.onDismiss,
    this.onCommitQuery,
  });
  final _DemoEntry entry;
  /// 点击结果项后、跳转前触发的回调。移动端用于关闭搜索浮层。
  final VoidCallback? onDismiss;
  /// 点击结果跳转前记录当前查询词到历史。
  final VoidCallback? onCommitQuery;

  @override
  Widget build(BuildContext context) {
    return MiuixBasicComponent(
      title: entry.title,
      summary: entry.summary,
      insideMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      startAction: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: MiuixIcon(
          vector: MiuixIcons.extended.byName(entry.icon)!,
          size: 24,
        ),
      ),
      onClick: () {
        // 先取出 navigator（context 可能随浮层移除而失效），
        // 记录历史，再关闭浮层，最后跳转。
        final navigator = Navigator.of(context);
        onCommitQuery?.call();
        onDismiss?.call();
        navigator.push(
          MaterialPageRoute(builder: (_) => entry.page),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
//  数据模型 & 列表项
// ──────────────────────────────────────────────

class _DemoEntry {
  const _DemoEntry({
    required this.icon,
    required this.title,
    required this.summary,
    required this.page,
    this.keywords = const [],
  });

  final String icon;
  final String title;
  final String summary;
  final Widget page;
  final List<String> keywords;
}

/// 主页分组卡片内的一个分类入口项。
class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});
  final _DemoEntry entry;

  @override
  Widget build(BuildContext context) {
    return MiuixBasicComponent(
      title: entry.title,
      summary: entry.summary,
      insideMargin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      startAction: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: MiuixIcon(
          vector: MiuixIcons.extended.byName(entry.icon)!,
          size: 24,
        ),
      ),
      onClick: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => entry.page),
      ),
    );
  }
}