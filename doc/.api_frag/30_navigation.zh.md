## 导航与脚手架 Navigation & Scaffold

### MiuixScaffold

Miuix 风格脚手架，编排顶栏、底栏、悬浮按钮、悬浮工具栏、Snackbar 与弹窗层；`content` 会收到脚手架计算出的内边距，由内容自行应用。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| topBar | Widget? | null | 屏幕顶部的应用栏，通常是 MiuixTopAppBar |
| bottomBar | Widget? | null | 屏幕底部的栏，通常是 MiuixNavigationBar |
| floatingActionButton | Widget? | null | 悬浮操作按钮 |
| floatingActionButtonPosition | MiuixFabPosition | MiuixFabPosition.end | 悬浮操作按钮的位置 |
| floatingToolbar | Widget? | null | 悬浮工具栏 |
| floatingToolbarPosition | MiuixToolbarPosition | MiuixToolbarPosition.bottomCenter | 悬浮工具栏的位置 |
| snackbarHost | Widget? | null | 承载 Snackbar 的组件，通常是 MiuixSnackbarHost |
| popupHost | Widget? | null | 承载弹窗与对话框的组件，为 null 时默认使用 MiuixPopupHost |
| containerColor | Color? | null | 脚手架背景色，默认 MiuixTheme.colors.surface；传入透明色可无背景 |
| contentWindowInsets | EdgeInsets? | null | 传给 content 的窗口内边距；为 null 时取 MediaQuery.paddingOf(context) |
| content | MiuixScaffoldContentBuilder | 必填 | 屏幕主体内容；lambda 接收应应用到内容根部的内边距 |

**示例：**
```dart
MiuixScaffold(
  topBar: MiuixSmallTopAppBar(title: 'Home'),
  bottomBar: MiuixNavigationBar(children: [/* ... */]),
  content: (padding) => Padding(padding: padding, child: bodyList),
)
```

### MiuixScaffoldContentBuilder

`MiuixScaffold.content` 槽的类型别名。脚手架先测量顶/底栏与系统内边距，再把应应用到内容根部的 `EdgeInsets` 通过此回调传给内容；内容应自行用 `Padding` 包裹根部。

**签名：**

```dart
typedef MiuixScaffoldContentBuilder = Widget Function(EdgeInsets contentPadding);
```

| 参数 | 类型 | 说明 |
|---|---|---|
| `contentPadding` | `EdgeInsets` | 由脚手架计算出的内边距，应应用到内容根部 |

### MiuixFabPosition

悬浮操作按钮（FAB）在 MiuixScaffold 中的位置。

| 值 | 说明 |
|---|---|
| start | 底部起始侧，位于底栏（若存在）上方 |
| center | 底部居中，位于底栏（若存在）上方 |
| end | 底部结束侧，位于底栏（若存在）上方 |
| endOverlay | 底部结束侧，覆盖在底栏（若存在）之上 |

### MiuixToolbarPosition

悬浮工具栏在 MiuixScaffold 中的位置。枚举顺序与整型值一一对应（TopStart=0 … BottomCenter=7）。

| 值 | 说明 |
|---|---|
| topStart | 顶部起始 |
| centerStart | 中部起始 |
| bottomStart | 底部起始 |
| topEnd | 顶部结束 |
| centerEnd | 中部结束 |
| bottomEnd | 底部结束 |
| topCenter | 顶部居中 |
| bottomCenter | 底部居中 |

### MiuixTopAppBar

大标题可折叠的 TopAppBar。必须配合 MiuixScrollBehavior 使用才能实现折叠/展开；不传 scrollBehavior 时表现为静态展开状态。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| title | String | 必填 | 标题文本 |
| color | Color? | null | 背景色，默认 MiuixTheme.colors.surface |
| titleColor | Color? | null | 折叠后小标题颜色 |
| largeTitle | String? | null | 大标题，默认与 title 相同 |
| largeTitleColor | Color? | null | 大标题颜色 |
| subtitle | String | '' | 副标题（展开时显示在大标题下方，折叠时显示在小标题下方） |
| subtitleColor | Color? | null | 副标题颜色 |
| navigationIcon | Widget? | null | 导航图标（leading） |
| actions | List\<Widget\>? | null | 操作图标（trailing） |
| scrollBehavior | MiuixScrollBehavior? | null | 控制折叠/展开的滚动行为 |
| defaultWindowInsetsPadding | bool | true | 是否应用默认窗口内边距 |
| titlePadding | double | MiuixTopAppBarDefaults.titlePadding (26) | 标题水平内边距 |
| navigationIconPadding | double | MiuixTopAppBarDefaults.navigationIconPadding (16) | 导航图标起始内边距 |
| actionIconPadding | double | MiuixTopAppBarDefaults.actionIconPadding (16) | 操作图标末端内边距 |
| bottomContent | Widget? | null | 标题区域下方的附加内容 |
| blurred | bool | false | 是否启用毛玻璃背景（增强，非原版行为）。true 时背景变为对**身后已绘制内容**的实时高斯模糊 + 半透明色调，实现"内容透过顶栏虚化"。用 `BackdropFilter` 实现，需顶栏画在可滚动内容之上（MiuixScaffold 的 topBar 即是） |
| blurRadius | double | 24 | 毛玻璃模糊半径（dp），仅 blurred=true 时生效；sigma = blurRadius × 0.45 |
| blurTintAlpha | double | 0.55 | 毛玻璃上叠加的背景色调不透明度 [0,1]，仅 blurred=true 时生效。太高盖住模糊、太低对比不足 |

**示例：**
```dart
final behavior = miuixScrollBehavior();
MiuixTopAppBar(
  title: 'Title',
  subtitle: 'Subtitle',
  scrollBehavior: behavior,
  navigationIcon: MiuixIcon(vector: MiuixIcons.basic.back),
);

// 毛玻璃顶栏（内容透过顶栏虚化）
MiuixScaffold(
  topBar: const MiuixTopAppBar(title: 'Home', blurred: true),
  content: (padding) => ListView(padding: padding, children: [/* ... */]),
);
```

### MiuixSmallTopAppBar

小标题静态 TopAppBar。不参与折叠/展开，固定显示居中标题；如传入 scrollBehavior，会把 state 的 heightOffsetLimit 锁为 0（pinned 效果）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| title | String | 必填 | 标题文本 |
| color | Color? | null | 背景色，默认 MiuixTheme.colors.surface |
| titleColor | Color? | null | 标题颜色 |
| subtitle | String | '' | 副标题（居中显示在标题下方） |
| subtitleColor | Color? | null | 副标题颜色 |
| navigationIcon | Widget? | null | 导航图标（leading） |
| actions | List\<Widget\>? | null | 操作图标（trailing） |
| scrollBehavior | MiuixScrollBehavior? | null | 传入时把共享 behavior 锁为 pinned |
| defaultWindowInsetsPadding | bool | true | 是否应用默认窗口内边距 |
| titlePadding | double | MiuixTopAppBarDefaults.titlePadding (26) | 标题水平内边距 |
| navigationIconPadding | double | MiuixTopAppBarDefaults.navigationIconPadding (16) | 导航图标起始内边距 |
| actionIconPadding | double | MiuixTopAppBarDefaults.actionIconPadding (16) | 操作图标末端内边距 |
| bottomContent | Widget? | null | 标题区域下方的附加内容 |

**示例：**
```dart
MiuixSmallTopAppBar(title: 'Settings', subtitle: 'v1.0')
```

### MiuixTopAppBarState

TopAppBar 的状态（继承 ChangeNotifier）。持有折叠偏移量、内容滚动偏移量等，通常由 MiuixScrollBehavior 持有并更新，由 MiuixTopAppBar 读取。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| initialHeightOffsetLimit | double | double.negativeInfinity | 折叠高度上限（负数，表示允许的最大折叠像素数） |
| initialHeightOffset | double | 0 | 初始折叠偏移量 |
| initialContentOffset | double | 0 | 初始内容滚动偏移量 |

主要属性：`heightOffsetLimit`、`heightOffset`（夹在上限与 0 之间）、`contentOffset`、`collapsedFraction`（0 展开、1 折叠）、`overlappedFraction`。

### MiuixScrollBehavior

滚动行为抽象。暴露 `state`（MiuixTopAppBarState）与 `isPinned`（是否固定，不随滚动收起）。

### MiuixExitUntilCollapsedScrollBehavior

"折叠到顶部为止"的滚动行为。上滑时优先折叠 TopAppBar，完全折叠后才让下方内容滚动；下滑时优先展开。实现 MiuixScrollBehavior，`isPinned` 恒为 false。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| state | MiuixTopAppBarState? | 缺省新建 MiuixTopAppBarState() | 关联状态 |
| canScroll | bool Function()? | null | 是否处理滚动事件 |

### MiuixScrollBehaviorListener

把滚动事件桥接到 MiuixExitUntilCollapsedScrollBehavior 的监听器；包裹任意可滚动组件，自动处理折叠/展开以及手势结束后的吸附动画。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| behavior | MiuixExitUntilCollapsedScrollBehavior | 必填 | 滚动行为 |
| child | Widget | 必填 | 被包裹的可滚动子组件 |

**示例：**
```dart
final behavior = miuixScrollBehavior();
MiuixScrollBehaviorListener(
  behavior: behavior,
  child: ListView(children: [/* ... */]),
);
```

### miuixScrollBehavior

创建一个默认的 MiuixExitUntilCollapsedScrollBehavior 的顶层函数。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| state | MiuixTopAppBarState? | null | 关联状态 |
| canScroll | bool Function()? | null | 是否处理滚动事件 |

返回：`MiuixExitUntilCollapsedScrollBehavior`

### MiuixTopAppBarDefaults

TopAppBar 默认值（私有构造，仅静态常量）。

| 常量 | 值 | 说明 |
|---|---|---|
| titlePadding | 26 | 标题水平内边距 |
| navigationIconPadding | 16 | 导航图标起始内边距 |
| actionIconPadding | 16 | 操作图标末端内边距 |
| collapsedHeight | 52 | 折叠状态下 TopAppBar 的高度 |
| smallTopAppBarCenterHeight | 50 | SmallTopAppBar 的垂直中心高度 |
| largeTitleBottomPadding | 4 | 无副标题时大标题的底部内边距 |
| subtitleBottomPadding | 8 | 副标题的底部内边距 |
| titleWidthFraction | 0.9 | 居中标题与导航/操作之间的横向余量比例 |

### MiuixNavigationBar

普通底部导航栏。children 通常由 2 到 5 个 MiuixNavigationBarItem 组成（断言长度 2..5），每项会被 Expanded 等分。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| children | List\<Widget\> | 必填 | 导航项列表（长度须 2..5） |
| color | Color? | null | 背景色，缺省用 colors.background |
| colors | MiuixNavigationBarColors? | null | 颜色配置，缺省取主题默认 |
| showDivider | bool | true | 是否显示顶部分隔线 |
| defaultWindowInsetsPadding | bool | true | 是否补充底部系统区留白 |
| mode | MiuixNavigationBarDisplayMode | MiuixNavigationBarDisplayMode.iconAndText | 导航项显示模式 |

**示例：**
```dart
MiuixNavigationBar(
  children: [
    MiuixNavigationBarItem(selected: index == 0, onPressed: () {}, icon: icon0, label: '首页'),
    MiuixNavigationBarItem(selected: index == 1, onPressed: () {}, icon: icon1, label: '我的'),
  ],
)
```

### MiuixNavigationBarItem

普通导航项。icon 与 labelWidget 是槽位；未提供 labelWidget 时用 label 构造文本。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| selected | bool | 必填 | 是否选中 |
| onPressed | VoidCallback? | 必填 | 点击回调；为 null 时禁用 |
| icon | Widget | 必填 | 图标槽 |
| label | String | 必填 | 可访问性标签及默认可见文本 |
| labelWidget | Widget? | null | 自定义标签组件 |
| enabled | bool | true | 是否启用 |
| badge | Widget? | null | 徽标槽，锚定在图标顶部末端 |

### MiuixFloatingNavigationBar

悬浮式底部导航栏。内容按自身宽度排列，不参与等分，项目之间固定间隔 12（断言 children 长度 2..5）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| children | List\<Widget\> | 必填 | 导航项列表（长度须 2..5） |
| color | Color? | null | 背景色，缺省用 colors.floatingBackground |
| colors | MiuixNavigationBarColors? | null | 颜色配置，缺省取主题默认 |
| cornerRadius | double | MiuixFloatingNavigationBarDefaults.cornerRadius (50) | 圆角半径 |
| horizontalAlignment | AlignmentGeometry | AlignmentDirectional.center | 水平对齐 |
| horizontalOutSidePadding | double | MiuixFloatingNavigationBarDefaults.horizontalOutSidePadding (36) | 外侧水平内边距 |
| shadowElevation | double | MiuixFloatingNavigationBarDefaults.shadowElevation (1) | 是否显示阴影（>0 显示；阴影几何固定黑色 20%、blurRadius=10） |
| showDivider | bool | false | 是否显示描边 |
| defaultWindowInsetsPadding | bool | true | 是否应用默认 caption-bar inset（移动端为 0） |

**示例：**
```dart
MiuixFloatingNavigationBar(
  children: [
    MiuixFloatingNavigationBarItem(selected: true, onPressed: () {}, icon: icon0, label: '首页'),
    MiuixFloatingNavigationBarItem(selected: false, onPressed: () {}, icon: icon1, label: '我的'),
  ],
)
```

### MiuixFloatingNavigationBarItem

悬浮导航项。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| selected | bool | 必填 | 是否选中 |
| onPressed | VoidCallback? | 必填 | 点击回调；为 null 时禁用 |
| icon | Widget | 必填 | 图标槽 |
| label | String | 必填 | 可访问性标签 |
| enabled | bool | true | 是否启用 |
| badge | Widget? | null | 徽标槽 |

### MiuixNavigationItem

导航项数据（@immutable）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| label | String | 必填 | 可访问性标签及默认可见标签文本 |
| icon | Widget | 必填 | 图标槽；组件会通过 IconTheme 提供尺寸和状态色 |
| badge | Widget? | null | 可选 badge 槽，锚定在图标的顶部末端 |

### MiuixNavigationBarDisplayMode

导航项显示模式。

| 值 | 说明 |
|---|---|
| iconAndText | 始终显示图标和文本 |
| iconOnly | 仅显示图标 |
| iconWithSelectedLabel | 始终显示图标，仅为选中项显示文本 |

### MiuixNavigationBarColors

导航栏颜色，集中保存普通与悬浮导航栏使用的主题色（@immutable）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| background | Color | 必填 | 普通导航栏背景色 |
| floatingBackground | Color | 必填 | 悬浮导航栏背景色 |
| content | Color | 必填 | 图标和标签的基础颜色；状态透明度在此之上计算 |
| divider | Color | 必填 | 分隔线和悬浮描边颜色 |

### MiuixNavigationBarDefaults

普通导航栏默认值（私有构造）。

| 常量 | 值 | 说明 |
|---|---|---|
| itemHeight | 64 | 项目高度 |
| iconSize | 26 | 图标尺寸 |
| labelFontSize | 12 | 标签字号 |
| iconTopPadding | 8 | 图标顶部内边距 |
| bottomPadding | 8 | 底部内边距 |
| selectedPressedAlpha | 0.5 | 选中且按下透明度 |
| unselectedPressedAlpha | 0.6 | 未选中且按下透明度 |
| unselectedAlpha | 0.4 | 未选中透明度 |
| selectionAnimationDuration | 300ms | 选择动画时长 |

静态方法 `defaultColors(BuildContext) → MiuixNavigationBarColors`：从当前主题创建默认颜色。

### MiuixFloatingNavigationBarDefaults

悬浮导航栏默认值（私有构造）。

| 常量 | 值 | 说明 |
|---|---|---|
| horizontalOutSidePadding | 36 | 外侧水平内边距 |
| shadowElevation | 1 | 阴影开关 |
| horizontalPadding | 12 | 内部水平内边距 |
| itemSpacing | 12 | 项目间距 |
| iconSize | 28 | 图标尺寸 |
| iconPadding | 10 | 图标内边距 |
| selectedPressedAlpha | 0.5 | 选中且按下透明度 |
| unselectedPressedAlpha | 0.6 | 未选中且按下透明度 |
| unselectedAlpha | 0.4 | 未选中透明度 |
| cornerRadius | 50 | 圆角，与 FloatingToolbarDefaults.CornerRadius 一致 |

静态方法 `defaultColors(BuildContext) → MiuixNavigationBarColors`：委托 MiuixNavigationBarDefaults.defaultColors。

### MiuixNavigationRail

适合宽屏使用、可选展开控制器的 Miuix 导航栏。state 为空时使用经典折叠布局且不显示切换按钮；非空时栏宽、项目布局、选中背景和字号共享同一条弹簧动画。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| children | List\<Widget\> | 必填 | 导航项列表，通常为 MiuixNavigationRailItem |
| state | MiuixNavigationRailState? | null | 展开/折叠状态；为 null 时无切换按钮 |
| header | Widget? | null | 顶部头部内容 |
| colors | MiuixNavigationRailColors? | null | 颜色配置，缺省取主题默认 |
| showDivider | bool | true | 是否显示右侧分隔线 |
| defaultWindowInsetsPadding | bool | true | 是否应用默认窗口内边距 |
| minWidth | double | MiuixNavigationRailDefaults.minWidth (80) | 折叠宽度 |
| expandedWidth | double | MiuixNavigationRailDefaults.expandedWidth (240) | 展开宽度 |
| expandContentDescription | String | MiuixNavigationRailDefaults.expandContentDescription ('Expand navigation rail') | 展开按钮无障碍描述 |
| collapseContentDescription | String | MiuixNavigationRailDefaults.collapseContentDescription ('Collapse navigation rail') | 折叠按钮无障碍描述 |
| scrollController | ScrollController? | null | 内部滚动控制器 |
| iconSize | double | MiuixNavigationRailDefaults.iconSize (28) | 项目图标尺寸；减小会同时降低项目高度（折叠/展开态都变矮） |
| itemVerticalPadding | double | MiuixNavigationRailDefaults.itemVerticalPadding (12) | 折叠态项目上下内边距 |
| expandedItemVerticalPadding | double | MiuixNavigationRailDefaults.expandedItemContentVerticalPadding (14) | 展开态项目上下内边距；减小可直接降低展开态每项高度 |
| labelFontSize | double | MiuixNavigationRailDefaults.labelFontSize (12) | 折叠态标签字号 |
| expandedLabelFontSize | double | MiuixNavigationRailDefaults.expandedLabelFontSize (16) | 展开态标签字号 |

> 后 5 个尺寸参数为增强项，默认值保持原值（非破坏），用于按需压缩侧栏项。

**示例：**
```dart
final railState = MiuixNavigationRailState();
MiuixNavigationRail(
  state: railState,
  children: [
    MiuixNavigationRailItem(selected: true, onPressed: () {}, icon: icon0, label: '首页'),
    MiuixNavigationRailItem(selected: false, onPressed: () {}, icon: icon1, label: '设置'),
  ],
)
```

### MiuixNavigationRailItem

导航栏项目，支持图标、标签以及可选徽标槽位。图标为装饰内容，项目语义仅朗读 label。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| selected | bool | 必填 | 是否选中 |
| onPressed | VoidCallback? | 必填 | 点击回调；为 null 时禁用 |
| icon | Widget | 必填 | 图标槽 |
| label | String | 必填 | 标签文本（无障碍朗读） |
| enabled | bool | true | 是否启用 |
| badge | Widget? | null | 徽标槽，锚定到图标右上角 |

### MiuixNavigationRailState

控制 MiuixNavigationRail 展开与折叠的状态对象（继承 ChangeNotifier）。别名 MiuixNavigationRailController。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| initialValue | MiuixNavigationRailValue | MiuixNavigationRailValue.collapsed | 初始展开状态 |

主要成员：`currentValue`、`isExpanded`、`expand()`、`collapse()`、`toggle()`。

### MiuixNavigationRailController

MiuixNavigationRailState 的类型别名（`typedef MiuixNavigationRailController = MiuixNavigationRailState`）。

### MiuixNavigationRailValue

导航栏的展开状态枚举。

| 值 | 说明 |
|---|---|
| collapsed | 折叠 |
| expanded | 展开 |

### MiuixNavigationRailColors

导航栏颜色配置（@immutable）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| background | Color | 必填 | 背景色 |
| content | Color | 必填 | 内容（图标/标签）色 |
| indicator | Color | 必填 | 选中指示器色 |
| divider | Color | 必填 | 分隔线色 |

### MiuixNavigationRailDefaults

NavigationRail 默认值（私有构造）。

| 常量 | 值 | 说明 |
|---|---|---|
| minWidth | 80 | 折叠宽度 |
| expandedWidth | 240 | 展开宽度 |
| verticalPadding | 24 | 垂直内边距 |
| headerSpacing | 24 | 头部间距 |
| iconSize | 28 | 图标尺寸 |
| iconTextSpacing | 4 | 图标与文字间距 |
| itemVerticalPadding | 12 | 项目垂直内边距 |
| labelFontSize | 12 | 折叠标签字号 |
| expandedLabelFontSize | 16 | 展开标签字号 |
| expandedItemHorizontalMargin | 12 | 展开项水平外边距 |
| expandedItemCornerRadius | 16 | 展开项圆角 |
| collapsedIndicatorVerticalPadding | 4 | 折叠指示器垂直内边距 |
| expandedItemContentHorizontalPadding | 14 | 展开项内容水平内边距 |
| expandedItemContentVerticalPadding | 14 | 展开项内容垂直内边距 |
| expandedItemIconTextSpacing | 16 | 展开项图标与文字间距 |
| expandContentDescription | 'Expand navigation rail' | 展开描述 |
| collapseContentDescription | 'Collapse navigation rail' | 折叠描述 |

静态方法 `colors(BuildContext) → MiuixNavigationRailColors`：从当前主题创建默认颜色。

### MiuixTabRow

Miuix 标签栏。横向可滚动，选中项以 squircle 背景指示。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| tabs | List\<String\> | 必填 | 标签文本列表 |
| selectedTabIndex | int | 必填 | 选中项索引 |
| onTabSelected | ValueChanged\<int\> | 必填 | 选中回调 |
| colors | MiuixTabRowColors? | null | 颜色配置，缺省取主题默认 |
| minWidth | double | MiuixTabRowDefaults.tabRowMinWidth (76) | 单个标签最小宽度 |
| maxWidth | double | MiuixTabRowDefaults.tabRowMaxWidth (98) | 单个标签最大宽度 |
| height | double | MiuixTabRowDefaults.tabRowHeight (42) | 标签栏高度 |
| cornerRadius | double | MiuixTabRowDefaults.tabRowCornerRadius (12) | 指示器圆角 |
| itemSpacing | double | MiuixTabRowDefaults.tabRowItemSpacing (9) | 项目间距 |
| contentAlignment | AlignmentGeometry | Alignment.center | 标签内容对齐 |
| scrollController | ScrollController? | null | 横向滚动控制器 |

**示例：**
```dart
MiuixTabRow(
  tabs: ['全部', '未读', '已归档'],
  selectedTabIndex: index,
  onTabSelected: (i) => setState(() => index = i),
)
```

### MiuixTabRowWithContour

带外轮廓标签栏。整体套一层 squircle 外框，指示器带 200ms 位移动画。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| tabs | List\<String\> | 必填 | 标签文本列表 |
| selectedTabIndex | int | 必填 | 选中项索引 |
| onTabSelected | ValueChanged\<int\> | 必填 | 选中回调 |
| colors | MiuixTabRowColors? | null | 颜色配置，缺省取主题默认 |
| minWidth | double | MiuixTabRowDefaults.tabRowWithContourMinWidth (62) | 单个标签最小宽度 |
| maxWidth | double | MiuixTabRowDefaults.tabRowWithContourMaxWidth (84) | 单个标签最大宽度 |
| height | double | MiuixTabRowDefaults.tabRowWithContourHeight (45) | 标签栏高度 |
| cornerRadius | double | MiuixTabRowDefaults.tabRowWithContourCornerRadius (8) | 指示器圆角 |
| itemSpacing | double | MiuixTabRowDefaults.contourItemSpacing (5) | 项目间距 |
| contentAlignment | AlignmentGeometry | Alignment.center | 标签内容对齐 |
| scrollController | ScrollController? | null | 横向滚动控制器 |

**示例：**
```dart
MiuixTabRowWithContour(
  tabs: ['日', '周', '月'],
  selectedTabIndex: index,
  onTabSelected: (i) => setState(() => index = i),
)
```

### MiuixTabRowColors

标签栏颜色配置（@immutable）。提供 `background(bool)` 与 `content(bool)` 便捷方法。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| backgroundColor | Color | 必填 | 未选中背景色 |
| contentColor | Color | 必填 | 未选中内容色 |
| selectedBackgroundColor | Color | 必填 | 选中背景色 |
| selectedContentColor | Color | 必填 | 选中内容色 |

### MiuixTabRowDefaults

标签栏默认值（私有构造）。

| 常量 | 值 | 说明 |
|---|---|---|
| tabRowHeight | 42 | TabRow 高度 |
| tabRowWithContourHeight | 45 | 带轮廓版高度 |
| tabRowCornerRadius | 12 | TabRow 圆角 |
| tabRowWithContourCornerRadius | 8 | 带轮廓版圆角 |
| tabRowMinWidth | 76 | TabRow 最小标签宽 |
| tabRowWithContourMinWidth | 62 | 带轮廓版最小标签宽 |
| tabRowMaxWidth | 98 | TabRow 最大标签宽 |
| tabRowWithContourMaxWidth | 84 | 带轮廓版最大标签宽 |
| tabRowItemSpacing | 9 | TabRow 项目间距 |
| contourItemSpacing | 5 | 带轮廓版项目间距 |
| contourPadding | 5 | 带轮廓版内边距 |
| itemHorizontalPadding | 12 | 标签水平内边距 |
| borderWidth | 1 | 描边宽度 |

静态方法 `defaultColors(BuildContext) → MiuixTabRowColors`：从当前主题创建默认颜色。

### MiuixBreadcrumbBar

横向面包屑导航栏。内容溢出时横向滚动；highlightIndex 为负数时同时关闭高亮和自动居中。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| items | List\<MiuixBreadcrumbItem\> | 必填 | 面包屑段列表 |
| onItemClick | ValueChanged\<int\> | 必填 | 点击某段的回调 |
| highlightIndex | int? | null | 高亮索引；null 表示最后一项，负数表示禁用高亮 |
| enabled | bool | true | 是否启用 |
| colors | MiuixBreadcrumbBarColors? | null | 颜色配置，缺省取主题默认 |
| insideMargin | EdgeInsets | MiuixBreadcrumbBarDefaults.insideMargin (水平12/垂直8) | 内边距 |
| itemMaxWidth | double | MiuixBreadcrumbBarDefaults.itemMaxWidth (160) | 单段最大宽度 |
| scrollController | ScrollController? | null | 横向滚动控制器 |

**示例：**
```dart
MiuixBreadcrumbBar(
  items: [
    MiuixBreadcrumbItem(path: 'root', text: '根目录'),
    MiuixBreadcrumbItem(path: 'docs'),
  ],
  onItemClick: (i) {},
)
```

### MiuixBreadcrumbItem

单个路径段（@immutable）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| path | String | 必填 | 用于重建完整路径的路径段 |
| text | String? | null | 显示文本；为 null 时显示 path |

### MiuixBreadcrumbItemsPath

`List<MiuixBreadcrumbItem>` 的扩展。用分隔符拼接所有路径段的 `path` 字段，便于重建完整路径。

| 方法签名 | 返回 | 说明 |
|---|---|---|
| `joinToPath({String separator = '/'})` | `String` | 用 `separator` 拼接所有 item 的 `path` 字段 |

**示例：**
```dart
final items = [
  MiuixBreadcrumbItem(path: 'home'),
  MiuixBreadcrumbItem(path: 'docs'),
  MiuixBreadcrumbItem(path: 'api'),
];
final full = items.joinToPath(); // 'home/docs/api'
```

### MiuixBreadcrumbBarColors

面包屑颜色配置（@immutable）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| color | Color | 必填 | 普通段前景色 |
| highlightColor | Color | 必填 | 高亮段前景色 |
| disabledColor | Color | 必填 | 禁用前景色 |
| separatorColor | Color | 必填 | 分隔箭头色 |
| backgroundColor | Color | 必填 | 普通段背景色 |
| highlightBackgroundColor | Color | 必填 | 高亮段背景色 |
| disabledBackgroundColor | Color | 必填 | 禁用背景色 |

### MiuixBreadcrumbBarDefaults

面包屑默认值（私有构造）。

| 常量 | 值 | 说明 |
|---|---|---|
| insideMargin | EdgeInsets(水平12, 垂直8) | 内边距 |
| itemHeight | 32 | 段高度 |
| itemHorizontalPadding | 10 | 段水平内边距 |
| itemMaxWidth | 160 | 段最大宽度 |

静态方法 `defaultColors(BuildContext) → MiuixBreadcrumbBarColors`：从当前主题构造默认颜色。

### MiuixVerticalScrollBar

竖向滚动条。支持悬停/拖拽高亮与自动淡出。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| adapter | MiuixScrollBarAdapter | 必填 | 绑定的滚动适配器 |
| reverseLayout | bool | false | 是否反向布局 |
| trackPadding | EdgeInsets | EdgeInsets.zero | 轨道内边距 |
| colors | MiuixScrollBarColors | MiuixScrollBarDefaults.colors | 颜色配置 |
| thumbWidth | double | MiuixScrollBarDefaults.thumbWidth (3.64) | 滑块宽度 |
| cornerRadius | double? | null | 圆角；为 null 时取 thumbWidth/2 |
| thumbMinLength | double | MiuixScrollBarDefaults.thumbMinLength (36) | 滑块最小长度 |
| endPadding | double | MiuixScrollBarDefaults.endPadding (3.46) | 末端内边距 |

**示例：**
```dart
final controller = ScrollController();
Stack(children: [
  ListView(controller: controller, children: [/* ... */]),
  Positioned(right: 0, top: 0, bottom: 0,
    child: MiuixVerticalScrollBar(adapter: MiuixScrollBarAdapter(controller))),
])
```

### MiuixHorizontalScrollBar

横向滚动条。参数与 MiuixVerticalScrollBar 相同。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| key | Key? | — | Widget key |
| adapter | MiuixScrollBarAdapter | 必填 | 绑定的滚动适配器 |
| reverseLayout | bool | false | 是否反向布局 |
| trackPadding | EdgeInsets | EdgeInsets.zero | 轨道内边距 |
| colors | MiuixScrollBarColors | MiuixScrollBarDefaults.colors | 颜色配置 |
| thumbWidth | double | MiuixScrollBarDefaults.thumbWidth (3.64) | 滑块宽度 |
| cornerRadius | double? | null | 圆角；为 null 时取 thumbWidth/2 |
| thumbMinLength | double | MiuixScrollBarDefaults.thumbMinLength (36) | 滑块最小长度 |
| endPadding | double | MiuixScrollBarDefaults.endPadding (3.46) | 末端内边距 |

### MiuixScrollBarAdapter

统一适配 Flutter ScrollController。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| controller | ScrollController | 必填（位置参数） | 被适配的滚动控制器 |

主要成员：`scrollOffset`、`viewportSize`、`contentSize`、`maxScrollOffset`、`scrollTo(double)`（立即滚动到指定内容偏移，夹在有效范围内）。

### MiuixScrollBarColors

滚动条颜色；null 表示未设置（@immutable）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| thumbColor | Color? | null | 滑块颜色 |
| trackColor | Color? | null | 轨道颜色 |

### MiuixScrollBarDefaults

滚动条默认值（私有构造）。

| 常量 | 值 | 说明 |
|---|---|---|
| thumbWidth | 3.64 | 滑块宽度 |
| endPadding | 3.46 | 末端内边距 |
| thumbMinLength | 36 | 滑块最小长度 |
| fadeDelayMillis | 1000 | 淡出延迟（毫秒） |
| fadeDurationMillis | 500 | 淡出时长（毫秒） |
| touchTargetWidth | 48 | 触摸目标宽度 |
| dragThumbWidth | 6 | 拖拽时滑块宽度 |
| thumbAlpha | 0.1 | 默认滑块透明度 |
| dragThumbAlpha | 0.3 | 拖拽时滑块透明度 |
| dragAnimationDurationMillis | 150 | 拖拽高亮动画时长（毫秒） |
| colors | MiuixScrollBarColors() | 默认颜色（全 null） |

静态方法 `defaultColors(BuildContext) → MiuixScrollBarColors`：返回默认 colors。

