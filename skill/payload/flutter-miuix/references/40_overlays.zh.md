## 浮层与反馈 Overlays & Feedback

### MiuixDismissScope

向对话框内容提供关闭请求的 InheritedWidget。包装在 `MiuixOverlayDialog` 内容外侧；子树可通过 `MiuixDismissScope.maybeOf(context)` 取得当前对话框的关闭回调，未处于对话框时返回 `null`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `onDismissRequest` | `VoidCallback` | 必填 | 关闭请求回调 |
| `child` | `Widget` | 必填 | 子树 |

**静态方法：**
- `MiuixDismissScope.maybeOf(BuildContext context) → VoidCallback?`：获取最近祖先 `MiuixDismissScope` 的关闭回调。

### MiuixOverlayDialog

Scaffold 内的 Miuix 对话框，复刻大小屏布局、遮罩、点击外部关闭及进入/退出过渡。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `show` | `bool` | 必填 | 是否显示对话框 |
| `title` | `String?` | `null` | 标题文本 |
| `titleColor` | `Color?` | `null` | 标题颜色，默认取主题 `onBackground` |
| `summary` | `String?` | `null` | 标题下方的摘要文本 |
| `summaryColor` | `Color?` | `null` | 摘要颜色，默认取主题 `onSurfaceSecondary` |
| `backgroundColor` | `Color?` | `null` | 背景色，默认取主题 `background` |
| `enableWindowDim` | `bool` | `true` | 是否启用遮罩变暗 |
| `onDismissRequest` | `VoidCallback?` | `null` | 请求关闭回调（点击外部/遮罩） |
| `onDismissFinished` | `VoidCallback?` | `null` | 退出动画结束回调 |
| `outsideMargin` | `Size` | `Size(12, 12)` | 外边距 |
| `insideMargin` | `Size` | `Size(24, 24)` | 内边距 |
| `defaultWindowInsetsPadding` | `bool` | `true` | 是否套用系统安全区内边距 |
| `renderInRootScaffold` | `bool` | `true` | 是否渲染到根 Scaffold 弹层 |
| `maxWidth` | `double` | `420` | 面板最大宽度 |
| `largeScreen` | `bool?` | `null` | 是否按大屏居中，`null` 时自动判断 |
| `cornerRadius` | `double?` | `null` | 圆角半径，`null` 时用默认 `32` |
| `content` | `Widget` | 必填 | 对话框内容 |

**示例：**
```dart
MiuixOverlayDialog(
  show: show,
  title: '提示',
  summary: '确认要继续吗？',
  onDismissRequest: () => setState(() => show = false),
  content: const SizedBox(),
)
```

### MiuixDialogDefaults

Miuix 对话框的默认值（私有构造，仅 `static` 字段与方法）。

| 常量 | 值 | 说明 |
|---|---|---|
| `maxWidth` | `420` | 面板最大宽度 |
| `cornerRadius` | `32` | 大屏模式下的圆角半径 |
| `outsideMargin` | `Size(12, 12)` | 外边距 |
| `insideMargin` | `Size(24, 24)` | 内边距 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `titleColor(context)` | `Color` | 标题颜色，取主题 `onBackground` |
| `summaryColor(context)` | `Color` | 摘要颜色，取主题 `onSurfaceSecondary` |
| `backgroundColor(context)` | `Color` | 背景色，取主题 `background` |

### MiuixOverlayBottomSheet

Scaffold 内的底部抽屉，含拖动手柄、弹簧平移和纵向拖动关闭；`MiuixWindowBottomSheet` 为窗口级同款（渲染到 root Overlay，无 `renderInRootScaffold` 参数）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `show` | `bool` | 必填 | 是否显示抽屉 |
| `title` | `String?` | `null` | 标题文本 |
| `startAction` | `Widget?` | `null` | 标题行起始侧动作 |
| `endAction` | `Widget?` | `null` | 标题行末尾侧动作 |
| `backgroundColor` | `Color?` | `null` | 背景色，默认取主题 `background` |
| `enableWindowDim` | `bool` | `true` | 是否启用遮罩变暗 |
| `cornerRadius` | `double` | `28` | 顶部圆角半径 |
| `sheetMaxWidth` | `double` | `640` | 抽屉最大宽度 |
| `onDismissRequest` | `VoidCallback?` | `null` | 请求关闭回调 |
| `onDismissFinished` | `VoidCallback?` | `null` | 退出动画结束回调 |
| `outsideMargin` | `Size` | `Size.zero` | 外边距 |
| `insideMargin` | `Size` | `Size(24, 0)` | 内边距 |
| `defaultWindowInsetsPadding` | `bool` | `true` | 是否套用系统安全区内边距 |
| `dragHandleColor` | `Color?` | `null` | 拖动手柄颜色 |
| `allowDismiss` | `bool` | `true` | 是否允许拖动/点击关闭 |
| `enableNestedScroll` | `bool` | `true` | 是否启用嵌套滚动 |
| `renderInRootScaffold` | `bool` | `true` | 是否渲染到根 Scaffold 弹层 |
| `content` | `Widget` | 必填 | 抽屉内容 |

**示例：**
```dart
MiuixOverlayBottomSheet(
  show: show,
  title: '选项',
  onDismissRequest: () => setState(() => show = false),
  content: const SizedBox(height: 200),
)
```

### MiuixBottomSheetDefaults

Miuix 底部抽屉的默认值（私有构造，仅 `static` 字段与方法）。

| 常量 | 值 | 说明 |
|---|---|---|
| `cornerRadius` | `28` | 顶部圆角半径 |
| `maxWidth` | `640` | 抽屉最大宽度 |
| `outsideMargin` | `Size.zero` | 外边距 |
| `insideMargin` | `Size(24, 0)` | 内边距 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `backgroundColor(context)` | `Color` | 背景色，取主题 `background` |
| `dragHandleColor(context)` | `Color` | 拖动手柄颜色，取主题 `onSurfaceVariantSummary` 的 20% 透明度 |

### MiuixWindowBottomSheet

窗口级底部抽屉。Flutter 中无独立 OS 窗口层；本组件以 root Overlay 注册（`renderInRootScaffold` 强制 `true`）。与 `MiuixOverlayBottomSheet` 的差异：无 `renderInRootScaffold` 参数（强制 `true`），其余参数一致。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `show` | `bool` | 必填 | 是否显示抽屉 |
| `title` | `String?` | `null` | 标题文本 |
| `startAction` | `Widget?` | `null` | 标题行起始侧动作 |
| `endAction` | `Widget?` | `null` | 标题行末尾侧动作 |
| `backgroundColor` | `Color?` | `null` | 背景色，默认取主题 `background` |
| `enableWindowDim` | `bool` | `true` | 是否启用遮罩变暗 |
| `cornerRadius` | `double` | `28` | 顶部圆角半径 |
| `sheetMaxWidth` | `double` | `640` | 抽屉最大宽度 |
| `onDismissRequest` | `VoidCallback?` | `null` | 请求关闭回调 |
| `onDismissFinished` | `VoidCallback?` | `null` | 退出动画结束回调 |
| `outsideMargin` | `Size` | `Size.zero` | 外边距 |
| `insideMargin` | `Size` | `Size(24, 0)` | 内边距 |
| `defaultWindowInsetsPadding` | `bool` | `true` | 是否套用系统安全区内边距 |
| `dragHandleColor` | `Color?` | `null` | 拖动手柄颜色 |
| `allowDismiss` | `bool` | `true` | 是否允许拖动/点击关闭 |
| `enableNestedScroll` | `bool` | `true` | 是否启用嵌套滚动 |
| `content` | `Widget` | 必填 | 抽屉内容 |

**示例：**
```dart
MiuixWindowBottomSheet(
  show: show,
  title: '选项',
  onDismissRequest: () => setState(() => show = false),
  content: const SizedBox(height: 200),
)
```

### MiuixDropdownItem

下拉/微调器/下拉菜单中的一项。`children` 非空时此项成为子菜单触发器（级联菜单）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `text` | `String` | 必填 | 项显示文本 |
| `enabled` | `bool` | `true` | 是否可点击 |
| `selected` | `bool` | `false` | 是否选中态 |
| `onClick` | `VoidCallback?` | `null` | 点击回调（有子菜单时被级联层消费而忽略） |
| `icon` | `Widget?` | `null` | 前置图标 |
| `summary` | `String?` | `null` | 标题下方的摘要 |
| `children` | `List<MiuixDropdownItem>?` | `null` | 可选子菜单项 |

命名构造 `MiuixDropdownItem.spinner({icon, title, summary})` 兼容旧 `SpinnerEntry`。

### MiuixDropdownEntry

一组下拉项（一个视觉分组）。`enabled` 为 false 时该组所有项被禁用。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `items` | `List<MiuixDropdownItem>` | 必填 | 本组内展示的项 |
| `enabled` | `bool` | `true` | 本组是否启用 |

### MiuixDropdownColors

下拉选项行使用的颜色（旧别名 `SpinnerColors`）。7 个字段均为必填。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `contentColor` | `Color` | 必填 | 未选中项的文本颜色 |
| `summaryColor` | `Color` | 必填 | 未选中项的摘要文本颜色 |
| `containerColor` | `Color` | 必填 | 未选中项的背景颜色 |
| `selectedContentColor` | `Color` | 必填 | 选中项的文本颜色 |
| `selectedSummaryColor` | `Color` | 必填 | 选中项的摘要文本颜色 |
| `selectedContainerColor` | `Color` | 必填 | 选中项的背景颜色 |
| `selectedIndicatorColor` | `Color` | 必填 | 选中指示图标（勾号）的颜色 |

### MiuixDropdownDefaults

下拉行的默认尺寸、间距与颜色（私有构造，仅 `static` 字段与方法）。

| 常量 | 值 | 说明 |
|---|---|---|
| `minHeight` | `56` | 对话框模式下的最小行高 |
| `minWidth` | `200` | 对话框模式下的最小行宽 |
| `checkIconSize` | `20` | 选中项尾部勾号尺寸 |
| `arrowSize` | `Size(10, 16)` | `MiuixDropdownArrowEndAction` 中上下箭头尺寸 |
| `chevronSize` | `Size(10, 16)` | 拥有子菜单的行的尾部箭头尺寸 |
| `iconMinSize` | `26` | 前置图标单元格的最小尺寸 |
| `maxItemTextWidth` | `216` | 弹窗模式下内部图标/文本行的最大宽度 |
| `insideHorizontalPadding` | `20` | 弹窗模式下每行的水平内边距 |
| `dialogHorizontalPadding` | `28` | 对话框模式下每行的水平内边距 |
| `firstLastVerticalPadding` | `20` | 弹窗模式下首/末行的上/下内边距 |
| `middleVerticalPadding` | `12` | 弹窗模式下中间行、对话框模式下所有行的上/下内边距 |
| `iconEndPadding` | `12` | 前置图标与标题文本之间的间距 |
| `checkIconStartPadding` | `12` | 标题/摘要块与尾部勾号之间的间距 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `dropdownColors(context, {...})` | `MiuixDropdownColors` | 弹窗模式默认颜色（content 取 `onSurfaceContainer`，selected 取 `primary`） |
| `dialogDropdownColors(context, {...})` | `MiuixDropdownColors` | 对话框模式默认颜色（selected 取 `onTertiaryContainer` / `tertiaryContainer`） |

### MiuixDropdownArrowEndAction

尾部的上下箭头动作图标。以 `MiuixDropdownDefaults.arrowSize`（10×16）绘制，垂直居中，颜色由 `actionColor` 决定。通常放在触发行的尾部，指示可展开下拉。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `actionColor` | `Color` | 必填 | 箭头的填充颜色 |

**示例：**
```dart
MiuixBasicComponent(
  title: '排序',
  endActions: [
    MiuixDropdownArrowEndAction(actionColor: theme.colors.onSurfaceVariantActions),
  ],
  onClick: () {},
)
```

### MiuixDropdownImpl

下拉选项行的渲染实现。本组件仅负责单行的呈现与点击；弹层、触发器与级联子菜单在独立文件中。常用于 `MiuixListPopupColumn` 内构造自定义下拉内容。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `item` | `MiuixDropdownItem` | 必填 | 当前选项的数据 |
| `optionSize` | `int` | 必填 | 选项总数 |
| `isSelected` | `bool` | 必填 | 是否选中 |
| `index` | `int` | 必填 | 当前项下标 |
| `onSelectedIndexChange` | `ValueChanged<int>` | 必填 | 选中时以 `index` 回调 |
| `dropdownColors` | `MiuixDropdownColors?` | `null`（默认 `dropdownColors`） | 行配色 |
| `enabled` | `bool?` | `null`（默认取 `item.enabled`） | 是否可点击；禁用行忽略点击并使用禁用文本色 |
| `dialogMode` | `bool` | `false` | 是否对话框模式 |
| `hasSubmenu` | `bool` | `false` | 是否作为子菜单触发器；true 时尾部显示箭头而非选中勾号，无障碍角色变为按钮 |
| `isFirst` | `bool?` | `null`（默认 `index == 0`） | 是否为整个弹层的首行（弹窗模式下首行有更大上内边距） |
| `isLast` | `bool?` | `null`（默认 `index == optionSize - 1`） | 是否为整个弹层的末行 |

命名构造 `MiuixDropdownImpl.text({required String text, ...})`：文本便捷构造，内部以 `text` 与 `enabled` 构造一个 `MiuixDropdownItem`。

**示例：**
```dart
MiuixListPopupColumn(children: [
  MiuixDropdownImpl.text(
    text: '复制',
    isSelected: false,
    index: 0,
    optionSize: 2,
    onSelectedIndexChange: (i) {},
  ),
  MiuixDropdownImpl.text(
    text: '粘贴',
    isSelected: false,
    index: 1,
    optionSize: 2,
    onSelectedIndexChange: (i) {},
  ),
])
```

### MiuixOverlayDropdownMenu

以 BasicComponent 为触发器的 Scaffold 内下拉菜单（单分组）。默认构造收单个 `entry`；命名构造 `.entries` 收 `entries` 列表（多分组）。`MiuixWindowDropdownMenu` 为窗口级同款（无 `renderInRootScaffold`）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry` | 必填 | 单个下拉分组（默认构造） |
| `entries` | `List<MiuixDropdownEntry>` | 必填 | 多个下拉分组（`.entries` 构造） |
| `title` | `String` | 必填 | 触发行标题 |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | 标题颜色 |
| `summary` | `String?` | `null` | 触发行摘要 |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | 摘要颜色 |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | 弹层配色，默认取 `MiuixDropdownDefaults.dropdownColors` |
| `startAction` | `Widget?` | `null` | 触发行起始侧动作 |
| `bottomAction` | `Widget?` | `null` | 触发行底部动作 |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | 触发行内边距 |
| `maxHeight` | `double?` | `null` | 弹层最大高度 |
| `enabled` | `bool` | `true` | 是否启用 |
| `renderInRootScaffold` | `bool` | `true` | 是否渲染到根 Scaffold 弹层 |
| `collapseOnSelection` | `bool?` | `true`（`.entries` 时 `null`） | 选中后是否收起（`null` 时按分组数推断） |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | 展开/收起回调 |

**示例：**
```dart
MiuixOverlayDropdownMenu(
  title: '排序方式',
  entry: MiuixDropdownEntry(items: [
    MiuixDropdownItem(text: '按名称', selected: true, onClick: () {}),
    MiuixDropdownItem(text: '按时间', onClick: () {}),
  ]),
)
```

### MiuixWindowDropdownMenu

窗口级下拉菜单（单分组）。命名构造 `.entries` 收多分组。Flutter 中无独立 OS 窗口层；本组件以 root Overlay 注册（`renderInRootScaffold` 强制 `true`）。与 `MiuixOverlayDropdownMenu` 的差异：无 `renderInRootScaffold` 参数（强制 `true`），其余参数一致。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry` | 必填 | 单个下拉分组（默认构造） |
| `entries` | `List<MiuixDropdownEntry>` | 必填 | 多个下拉分组（`.entries` 构造） |
| `title` | `String` | 必填 | 触发行标题 |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | 标题颜色 |
| `summary` | `String?` | `null` | 触发行摘要 |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | 摘要颜色 |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | 弹层配色，默认取 `MiuixDropdownDefaults.dropdownColors` |
| `startAction` | `Widget?` | `null` | 触发行起始侧动作 |
| `bottomAction` | `Widget?` | `null` | 触发行底部动作 |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | 触发行内边距 |
| `maxHeight` | `double?` | `null` | 弹层最大高度 |
| `enabled` | `bool` | `true` | 是否启用 |
| `collapseOnSelection` | `bool?` | `true`（`.entries` 时 `null`） | 选中后是否收起（`null` 时按分组数推断） |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | 展开/收起回调 |

**示例：**
```dart
MiuixWindowDropdownMenu(
  title: '排序方式',
  entry: MiuixDropdownEntry(items: [
    MiuixDropdownItem(text: '按名称', selected: true, onClick: () {}),
    MiuixDropdownItem(text: '按时间', onClick: () {}),
  ]),
)
```

### MiuixOverlayIconDropdownMenu

以 IconButton 为触发器的 Scaffold 内图标下拉菜单（单分组）。命名构造 `.entries` 收多分组；`MiuixWindowIconDropdownMenu` 为窗口级同款。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry` | 必填 | 单个下拉分组（默认构造） |
| `entries` | `List<MiuixDropdownEntry>` | 必填 | 多个下拉分组（`.entries` 构造） |
| `enabled` | `bool` | `true` | 是否启用 |
| `maxHeight` | `double?` | `null` | 弹层最大高度 |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | 弹层配色 |
| `renderInRootScaffold` | `bool` | `true` | 是否渲染到根 Scaffold 弹层 |
| `collapseOnSelection` | `bool?` | `true`（`.entries` 时 `null`） | 选中后是否收起 |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | 展开/收起回调 |
| `backgroundColor` | `Color?` | `null` | 图标按钮背景色 |
| `cornerRadius` | `double` | `MiuixIconButtonDefaults.cornerRadius` | 图标按钮圆角 |
| `minHeight` | `double` | `MiuixIconButtonDefaults.minHeight` | 图标按钮最小高度 |
| `minWidth` | `double` | `MiuixIconButtonDefaults.minWidth` | 图标按钮最小宽度 |
| `child` | `Widget` | 必填 | 图标按钮内容 |

### MiuixWindowIconDropdownMenu

窗口级图标下拉菜单（单分组）。命名构造 `.entries` 收多分组。Flutter 中无独立 OS 窗口层；本组件以 root Overlay 注册（`renderInRootScaffold` 强制 `true`）。与 `MiuixOverlayIconDropdownMenu` 的差异：无 `renderInRootScaffold` 参数（强制 `true`），其余参数一致。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry` | 必填 | 单个下拉分组（默认构造） |
| `entries` | `List<MiuixDropdownEntry>` | 必填 | 多个下拉分组（`.entries` 构造） |
| `enabled` | `bool` | `true` | 是否启用 |
| `maxHeight` | `double?` | `null` | 弹层最大高度 |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | 弹层配色 |
| `collapseOnSelection` | `bool?` | `true`（`.entries` 时 `null`） | 选中后是否收起 |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | 展开/收起回调 |
| `backgroundColor` | `Color?` | `null` | 图标按钮背景色 |
| `cornerRadius` | `double` | `MiuixIconButtonDefaults.cornerRadius` | 图标按钮圆角 |
| `minHeight` | `double` | `MiuixIconButtonDefaults.minHeight` | 图标按钮最小高度 |
| `minWidth` | `double` | `MiuixIconButtonDefaults.minWidth` | 图标按钮最小宽度 |
| `child` | `Widget` | 必填 | 图标按钮内容 |

### MiuixOverlayIconCascadingDropdownMenu

以 IconButton 为触发器的 Scaffold 内图标级联下拉菜单；子项 `MiuixDropdownItem.children` 非空时成为子菜单触发器，级联深度限制为 2。命名构造 `.entries` 收多分组；`MiuixWindowIconCascadingDropdownMenu` 为窗口级同款。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `entry` / `entries` | `MiuixDropdownEntry` / `List<MiuixDropdownEntry>` | 必填 | 下拉分组（默认构造/`.entries` 构造） |
| `enabled` | `bool` | `true` | 是否启用 |
| `maxHeight` | `double?` | `null` | 弹层最大高度 |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | 弹层配色 |
| `renderInRootScaffold` | `bool` | `true` | 是否渲染到根 Scaffold 弹层 |
| `collapseOnSelection` | `bool` | `true` | 选中后是否收起 |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | 展开/收起回调 |
| `backgroundColor` | `Color?` | `null` | 图标按钮背景色 |
| `cornerRadius` | `double` | `MiuixIconButtonDefaults.cornerRadius` | 图标按钮圆角 |
| `minHeight` | `double` | `MiuixIconButtonDefaults.minHeight` | 图标按钮最小高度 |
| `minWidth` | `double` | `MiuixIconButtonDefaults.minWidth` | 图标按钮最小宽度 |
| `child` | `Widget` | 必填 | 图标按钮内容 |

### MiuixWindowIconCascadingDropdownMenu

窗口级图标级联下拉菜单（单分组）。命名构造 `.entries` 收多分组。Flutter 中无独立 OS 窗口层；本组件以窗口级 Overlay 注册。与 `MiuixOverlayIconCascadingDropdownMenu` 的差异：无 `renderInRootScaffold` 参数（强制 `true`），其余参数一致。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `entry` / `entries` | `MiuixDropdownEntry` / `List<MiuixDropdownEntry>` | 必填 | 下拉分组（默认构造/`.entries` 构造） |
| `enabled` | `bool` | `true` | 是否启用 |
| `maxHeight` | `double?` | `null` | 弹层最大高度 |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | 弹层配色 |
| `collapseOnSelection` | `bool` | `true` | 选中后是否收起 |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | 展开/收起回调 |
| `backgroundColor` | `Color?` | `null` | 图标按钮背景色 |
| `cornerRadius` | `double` | `MiuixIconButtonDefaults.cornerRadius` | 图标按钮圆角 |
| `minHeight` | `double` | `MiuixIconButtonDefaults.minHeight` | 图标按钮最小高度 |
| `minWidth` | `double` | `MiuixIconButtonDefaults.minWidth` | 图标按钮最小宽度 |
| `child` | `Widget` | 必填 | 图标按钮内容 |

### MiuixDropdownEntriesPopupContent

在弹窗容器内渲染 `MiuixDropdownEntry` 分组列表。内部计算弹窗全局的 first/last：仅整个弹窗的第一行与最后一行获得更大的首/末内边距；分组边界回退到中间行内边距。分组之间插入 1.5dp 分隔线。调用方需将其放入 `MiuixListPopupColumn` 之类的滚动容器；本组件本身不滚动。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `entries` | `List<MiuixDropdownEntry>` | 必填 | 一组或多组下拉项 |
| `dropdownColors` | `MiuixDropdownColors` | 必填 | 下拉行配色 |
| `onItemClick` | `void Function(int entryIdx, int itemIdx)` | 必填 | 项点击回调，参数为 `(分组下标, 项下标)` |

### MiuixDropdownEntriesDialogItems

在对话框容器内渲染 `MiuixDropdownEntry` 分组列表（作为 `ListView`/`Column` 的 children）。对话框模式使用统一的垂直内边距，不传播弹窗全局 first/last；分组之间同样插入 1.5dp 分隔线。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `entries` | `List<MiuixDropdownEntry>` | 必填 | 一组或多组下拉项 |
| `dropdownColors` | `MiuixDropdownColors` | 必填 | 下拉行配色 |
| `onItemClick` | `void Function(int entryIdx, int itemIdx)` | 必填 | 项点击回调 |

### MiuixOverlayDropdownPopup

Scaffold 内下拉弹窗。默认构造收单个 `entry`（单分组）；命名构造 `.entries` 收 `entries` 列表（多分组）。内部使用 `MiuixOverlayListPopup` 与 `MiuixDropdownEntriesPopupContent` 渲染，对齐方式为 `MiuixPopupAlign.end`。点击项时触发 `HapticFeedback.selectionClick()` 并按 `collapseOnSelection` 决定是否关闭。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry?` | 必填（默认构造） | 单个下拉分组 |
| `entries` | `List<MiuixDropdownEntry>` | 必填（`.entries` 构造） | 多个下拉分组 |
| `show` | `bool` | 必填 | 是否显示 |
| `anchorBounds` | `Rect` | 必填 | 锚点在窗口坐标系中的 Rect |
| `onDismiss` | `VoidCallback` | 必填 | 请求关闭回调 |
| `onDismissFinished` | `VoidCallback` | 必填 | 退出动画结束回调 |
| `maxHeight` | `double?` | `null` | 弹层最大高度 |
| `dropdownColors` | `MiuixDropdownColors` | 必填 | 弹层配色 |
| `renderInRootScaffold` | `bool` | `true` | 是否注册到 root 注册表 |
| `collapseOnSelection` | `bool?` | `true`（默认构造）/ `entries.length <= 1`（`.entries` 构造） | 选中后是否收起 |

### MiuixWindowDropdownPopup

窗口级下拉弹窗。Flutter 的 Navigator Overlay 已是窗口级宿主，故不依赖 `MiuixScaffold`，无 `renderInRootScaffold` 参数。其余行为与 `MiuixOverlayDropdownPopup` 一致。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry?` | 必填（默认构造） | 单个下拉分组 |
| `entries` | `List<MiuixDropdownEntry>` | 必填（`.entries` 构造） | 多个下拉分组 |
| `show` | `bool` | 必填 | 是否显示 |
| `anchorBounds` | `Rect` | 必填 | 锚点 Rect |
| `onDismiss` | `VoidCallback` | 必填 | 请求关闭回调 |
| `onDismissFinished` | `VoidCallback` | 必填 | 退出动画结束回调 |
| `maxHeight` | `double?` | `null` | 弹层最大高度 |
| `dropdownColors` | `MiuixDropdownColors` | 必填 | 弹层配色 |
| `collapseOnSelection` | `bool?` | `true`（默认构造）/ `entries.length <= 1`（`.entries` 构造） | 选中后是否收起 |

### MiuixOverlayDropdownDialog

Scaffold 内下拉对话框（单分组）。命名构造 `.entries` 收多分组；以 `MiuixOverlayDialog` 为容器渲染 `MiuixDropdownEntriesDialogItems`，附带标题、底部确认按钮。点击项触发 `HapticFeedback.selectionClick()`，并根据 `collapseOnSelection` 决定是否关闭。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry?` | 必填（默认构造） | 单个下拉分组 |
| `entries` | `List<MiuixDropdownEntry>` | 必填（`.entries` 构造） | 多个下拉分组 |
| `title` | `String` | 必填 | 对话框标题 |
| `dialogButtonString` | `String` | 必填 | 底部按钮文字 |
| `show` | `bool` | 必填 | 是否显示 |
| `onDismiss` | `VoidCallback` | 必填 | 请求关闭回调 |
| `onDismissFinished` | `VoidCallback` | 必填 | 退出动画结束回调 |
| `dropdownColors` | `MiuixDropdownColors` | 必填 | 下拉行配色 |
| `renderInRootScaffold` | `bool` | `true` | 是否渲染到根 Scaffold 弹层 |
| `collapseOnSelection` | `bool?` | `true`（默认构造）/ `entries.length <= 1`（`.entries` 构造） | 选中后是否收起 |

### MiuixWindowDropdownDialog

窗口级下拉对话框（单分组）。命名构造 `.entries` 收多分组。Flutter 中无独立 OS 窗口层；本组件以 `MiuixOverlayDialog` 的 `renderInRootScaffold: true` 注册至根 Overlay。与 `MiuixOverlayDropdownDialog` 的差异：无 `renderInRootScaffold` 参数（强制 `true`），其余参数一致。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry?` | 必填（默认构造） | 单个下拉分组 |
| `entries` | `List<MiuixDropdownEntry>` | 必填（`.entries` 构造） | 多个下拉分组 |
| `title` | `String` | 必填 | 对话框标题 |
| `dialogButtonString` | `String` | 必填 | 底部按钮文字 |
| `show` | `bool` | 必填 | 是否显示 |
| `onDismiss` | `VoidCallback` | 必填 | 请求关闭回调 |
| `onDismissFinished` | `VoidCallback` | 必填 | 退出动画结束回调 |
| `dropdownColors` | `MiuixDropdownColors` | 必填 | 下拉行配色 |
| `collapseOnSelection` | `bool?` | `true`（默认构造）/ `entries.length <= 1`（`.entries` 构造） | 选中后是否收起 |

### MiuixListPopupColumn

自动将所有列表项统一为前八项中最宽项宽度的可滚动列（宽度限制 200–288 逻辑像素）；ListPopup 的基础构件之一，通常由 popup host 在外层提供最大高度约束。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `children` | `List<Widget>` | 必填 | 列表项 |
| `scrollController` | `ScrollController?` | `null` | 滚动控制器 |
| `physics` | `ScrollPhysics?` | `null` | 滚动物理，默认 `ClampingScrollPhysics` |

### ListPopup 系列

ListPopup 是基于锚点 Rect 定位的轻量弹层，复刻 0.15→1 揭示、淡入淡出、遮罩、外部点击与返回键关闭。适合做右键菜单、上下文菜单、自定义下拉等。

#### MiuixPopupAlign

弹窗相对锚点的逻辑对齐方式。对应 Kotlin `PopupPositionProvider` 的对齐枚举。RTL 下 `start`/`end` 会自动镜像。

| 值 | 说明 |
|---|---|
| `start` | 起始侧（LTR 下左对齐），垂直位置自动选择锚点上方或下方 |
| `end` | 结束侧（LTR 下右对齐），垂直位置自动选择 |
| `topStart` | 锚点下方、起始侧对齐 |
| `topEnd` | 锚点下方、结束侧对齐 |
| `bottomStart` | 锚点上方、起始侧对齐 |
| `bottomEnd` | 锚点上方、结束侧对齐 |

#### MiuixPopupPositionProvider

供统一 popup host 使用的位置计算接口。对应 Kotlin `PopupPositionProvider`。所有坐标均为相对于窗口左上角的逻辑像素；实现**不得**自行读取 [MediaQuery]，因此同一算法可同时用于 Overlay 与窗口级 host。

| 方法 / 字段 | 类型 | 说明 |
|---|---|---|
| `calculatePosition({anchorBounds, windowBounds, textDirection, popupContentSize, popupMargin, alignment})` | `Offset` | 计算弹窗左上角在窗口中的位置 |
| `margins` | `EdgeInsetsGeometry` | 弹窗的额外外边距；方向性边距由调用方按当前文字方向解析 |

#### MiuixPopupSpringSpec

Compose spring 的 Flutter 等价描述。对应 Kotlin `PopupSpringSpec`。

| 参数 | 类型 | 说明 |
|---|---|---|
| `dampingRatio` | `double` | 阻尼比 |
| `stiffness` | `double` | 刚度 |
| `visibilityThreshold` | `double` | spring 模拟容差 |

`description` getter 返回 Flutter `SpringDescription`；`simulation(from, to, {velocity})` 创建 `SpringSimulation` 供 `AnimationController.unbounded().animateWith(...)` 使用。

#### MiuixPopupTweenSpec

Popup 补间动画的时长与曲线。对应 Kotlin `PopupTweenSpec`。

| 参数 | 类型 | 说明 |
|---|---|---|
| `duration` | `Duration` | 时长 |
| `curve` | `Curve` | 曲线 |

#### MiuixListPopupDefaults

ListPopup 的尺寸、动效与默认位置策略。对应 Kotlin `ListPopupDefaults`（私有构造，仅 `static` 字段）。

| 常量 / 方法 | 值 / 返回 | 说明 |
|---|---|---|
| `minWidth` | `200` | 弹窗最小宽度 |
| `minPopupHeight` | `50` | 弹窗最小高度 |
| `cornerRadius` | `16` | 圆角半径 |
| `fractionAnimationSpec` | spring(0.82, 362.5) | 揭示动画 spring |
| `resetAnimationSpec` | 同上 | 重置动画 spring |
| `alphaEnterAnimationSpec` | 200ms / fastOutSlowIn | 进入淡入 |
| `alphaExitAnimationSpec` | 150ms / fastOutSlowIn | 退出淡出 |
| `dimEnterAnimationSpec` | 300ms / sinOut | 遮罩进入 |
| `dimExitAnimationSpec` | 150ms / sinOut | 遮罩退出 |
| `dropdownPosition` | `MiuixPopupPositionProvider` | 下拉菜单默认位置策略（verticalMargin=8） |
| `contextMenuPosition` | `MiuixPopupPositionProvider` | 上下文菜单默认位置策略（无 margin） |
| `dropdownPositionProvider({verticalMargin, horizontalMargin})` | `MiuixPopupPositionProvider` | 创建自定义下拉位置策略 |

#### MiuixListPopupColumn

自动将所有列表项统一为前八项中最宽项宽度的可滚动列（宽度限制 200–288 逻辑像素）；ListPopup 的基础构件之一，通常由 popup host 在外层提供最大高度约束。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `children` | `List<Widget>` | 必填 | 列表项 |
| `scrollController` | `ScrollController?` | `null` | 滚动控制器 |
| `physics` | `ScrollPhysics?` | `null` | 滚动物理，默认 `ClampingScrollPhysics` |

#### MiuixListPopupContent

承载列表内容的缩放、淡入淡出与定向 squircle 揭示容器。对应 Kotlin `ListPopupContent`。通常由 popup host 内部使用，调用方一般不直接构建。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `popupContentSize` | `Size` | 必填 | 当前内容尺寸（首次为 `Size.zero`） |
| `onPopupContentSizeChange` | `ValueChanged<Size>` | 必填 | 内容尺寸变化回调 |
| `fractionProgress` | `double Function()` | 必填 | 揭示进度（0..1）的实时读取函数 |
| `alphaProgress` | `double Function()` | 必填 | 透明度进度（0..1）的实时读取函数 |
| `popupLayoutPosition` | `MiuixPopupLayoutPosition` | 必填 | 布局方位信息 |
| `localTransformOrigin` | `Offset` | 必填 | 局部变换原点（归一化） |
| `child` | `Widget` | 必填 | 列表内容（通常为 `MiuixListPopupColumn`） |
| `animation` | `Listenable?` | `null` | 合并后的动画监听，避免 widget 重建 |
| `backgroundColor` | `Color?` | `null` | 背景色，默认取 `colors.surfaceContainer` |
| `cornerRadius` | `double` | `MiuixListPopupDefaults.cornerRadius`（16） | 圆角半径 |

#### MiuixOverlayListPopup

Scaffold 内列表弹窗。对应 Kotlin `OverlayListPopup`。通过 [MiuixPopupLayout] 注册到 root 或 local 注册表，由统一 popup host 绘制。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `show` | `bool` | 必填 | 是否显示 |
| `anchorBounds` | `Rect` | 必填 | 锚点在窗口坐标系中的 Rect |
| `popupPositionProvider` | `MiuixPopupPositionProvider?` | `null`（默认 `dropdownPosition`） | 位置策略 |
| `alignment` | `MiuixPopupAlign` | `start` | 对齐方式 |
| `enableWindowDim` | `bool` | `true` | 是否启用遮罩 |
| `onDismissRequest` | `VoidCallback?` | `null` | 请求关闭回调 |
| `onDismissFinished` | `VoidCallback?` | `null` | 退出动画结束回调 |
| `maxHeight` | `double?` | `null` | 最大高度 |
| `minWidth` | `double` | `MiuixListPopupDefaults.minWidth`（200） | 最小宽度 |
| `renderInRootScaffold` | `bool` | `true` | 是否注册到 root 注册表 |
| `content` | `Widget` | 必填 | 弹窗内容 |

**示例：**
```dart
MiuixOverlayListPopup(
  show: show,
  anchorBounds: anchorRect,
  onDismissRequest: () => setState(() => show = false),
  content: MiuixListPopupColumn(children: [
    MiuixDropdownImpl.text(text: '复制', isSelected: false, index: 0,
      optionSize: 2, onSelectedIndexChange: (i) {}),
  ]),
)
```

#### MiuixWindowListPopup

窗口级列表弹窗。对应 Kotlin `WindowListPopup`。Flutter 的 Navigator Overlay 已是窗口级宿主，故不依赖 [MiuixScaffold]。参数与 `MiuixOverlayListPopup` 相同，但无 `renderInRootScaffold`。

#### MiuixOverlayCascadingListPopup

Scaffold 内二级级联列表弹窗。对应 Kotlin `OverlayCascadingListPopup`。子项 `MiuixDropdownItem.children` 非空时成为子菜单触发器，级联深度限制为 2。主菜单复用 ListPopup 动效；子菜单以 0.95 主层缩放、半强度遮罩与弹簧展开复刻级联态。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `show` | `bool` | 必填 | 是否显示 |
| `anchorBounds` | `Rect` | 必填 | 锚点 Rect |
| `entries` | `List<MiuixDropdownEntry>` | 必填 | 多分组数据（含子菜单项） |
| `onDismissRequest` | `VoidCallback` | 必填 | 请求关闭回调 |
| `onDismissFinished` | `VoidCallback?` | `null` | 退出动画结束回调 |
| `popupPositionProvider` | `MiuixPopupPositionProvider?` | `null`（默认 `dropdownPosition`） | 位置策略 |
| `alignment` | `MiuixPopupAlign` | `end` | 对齐方式 |
| `enableWindowDim` | `bool` | `true` | 是否启用遮罩 |
| `maxHeight` | `double?` | `null` | 最大高度 |
| `minWidth` | `double` | `200` | 最小宽度 |
| `renderInRootScaffold` | `bool` | `true` | 是否注册到 root |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | 配色，默认取 `dropdownColors` |
| `collapseOnSelection` | `bool` | `true` | 选中后是否收起 |

#### MiuixWindowCascadingListPopup

窗口级二级级联列表弹窗。对应 Kotlin `WindowCascadingListPopup`。参数同上，无 `renderInRootScaffold`。

#### MiuixPopupLayoutPosition

弹窗位于锚点的哪一侧，以及贴近锚点的哪条横向边。对应 Kotlin `PopupLayoutPosition`。

| 字段 | 类型 | 说明 |
|---|---|---|
| `showBelow` | `bool` | 是否显示在锚点下方 |
| `showAbove` | `bool` | 是否显示在锚点上方 |
| `isRightAligned` | `bool` | 是否右对齐 |
| `showMiddle` | `bool`（getter） | 既不在上方也不在下方（与锚点垂直重叠） |

#### MiuixListPopupLayoutInfo

popup host 定位、缩放与揭示动画所需的完整布局信息。对应 Kotlin `ListPopupLayoutInfo`。通常由 [computeListPopupLayoutInfo] 计算后传入 host。

| 字段 | 类型 | 说明 |
|---|---|---|
| `windowBounds` | `Rect` | 窗口安全区边界 |
| `popupMargin` | `EdgeInsets` | 解析后的弹窗外边距 |
| `calculatedOffset` | `Offset` | 弹窗左上角窗口坐标；内容未测量时为 `Offset.zero` |
| `effectiveTransformOrigin` | `Offset` | 归一化的窗口坐标原点，供统一 popup host 的全局动效使用 |
| `localTransformOrigin` | `Offset` | 归一化的弹窗局部原点，供 [MiuixListPopupContent] 使用 |
| `popupLayoutPosition` | `MiuixPopupLayoutPosition` | 布局方位信息 |

#### `computeListPopupLayoutInfo(context, {alignment, popupPositionProvider, parentBounds, popupContentSize})` → `MiuixListPopupLayoutInfo`

从窗口安全区、锚点与已测量内容计算 popup host 所需布局信息。对应 Kotlin `computeListPopupLayoutInfo`。`parentBounds` 必须是窗口坐标；首次构建可传 `Size.zero`，此时返回预测原点，待 `MiuixListPopupContent.onPopupContentSizeChange` 回报后重新计算。

#### `safeTransformOrigin(x, y)` → `Offset`

将变换原点中的 NaN 和负数归零；正值（包括大于 1）保持原样。对应 Kotlin `safeTransformOrigin`。

### MiuixTooltipAnchorPosition

Tooltip 相对锚点的首选方位枚举。对应 Kotlin `TooltipAnchorPosition`。空间不足时会自动翻转到相反一侧；`start`/`end` 在 RTL 下会先解析为 `left`/`right`。

| 值 | 说明 |
|---|---|
| `above` | 锚点上方 |
| `below` | 锚点下方 |
| `left` | 锚点左侧 |
| `right` | 锚点右侧 |
| `start` | 起始侧（LTR 下解析为 `left`，RTL 下为 `right`） |
| `end` | 结束侧（LTR 下解析为 `right`，RTL 下为 `left`） |

### MiuixTooltipState

控制 Tooltip 显隐的状态控制器，继承 `ChangeNotifier`。对应 Kotlin `TooltipState`。所有实例共享一个活动槽，因此同一时刻至多显示一个 Tooltip；非持久状态在 `MiuixTooltipDefaults.tooltipDuration`（1500ms）后自动关闭。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `initialIsVisible` | `bool` | `false` | 初始是否可见 |
| `isPersistent` | `bool` | `false` | 是否为持久 Tooltip（不自动关闭） |

| 方法 / 字段 | 返回 | 说明 |
|---|---|---|
| `isVisible` | `bool` (getter) | 当前是否可见 |
| `show()` | `Future<void>` | 显示 Tooltip；关闭时完成返回的 Future |
| `dismiss()` | `void` | 关闭 Tooltip |

### MiuixTooltipScope

Tooltip 内容构建时可用的锚点信息。对应 Kotlin `TooltipScope`。

| 字段 | 类型 | 说明 |
|---|---|---|
| `positioning` | `MiuixTooltipAnchorPosition` | 当前实际采用的方位（已经过 RTL 解析及空间不足翻转） |
| `anchorBounds` | `Rect` | 锚点在 Overlay 坐标系中的边界 |

### MiuixRichTooltipColors

Rich Tooltip 的颜色配置。对应 Kotlin `RichTooltipColors`。4 个字段均为必填。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `containerColor` | `Color` | 必填 | 容器背景色 |
| `contentColor` | `Color` | 必填 | 正文内容色 |
| `titleContentColor` | `Color` | 必填 | 标题内容色 |
| `actionContentColor` | `Color` | 必填 | 操作按钮内容色 |

### MiuixTooltipDefaults

Tooltip 的尺寸、颜色和动画默认值。对应 Kotlin `TooltipDefaults`（私有构造，仅 `static` 字段与方法）。

| 常量 | 值 | 说明 |
|---|---|---|
| `spacingBetweenTooltipAndAnchor` | `8` | Tooltip 与锚点的间距 |
| `caretSize` | `Size(16, 8)` | 箭头尺寸 |
| `plainTooltipMaxWidth` | `200` | Plain Tooltip 最大宽度 |
| `plainTooltipCornerRadius` | `12` | Plain Tooltip 圆角半径 |
| `plainTooltipInsideMargin` | `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` | Plain Tooltip 内边距 |
| `richTooltipMaxWidth` | `320` | Rich Tooltip 最大宽度 |
| `richTooltipCornerRadius` | `16` | Rich Tooltip 圆角半径 |
| `richTooltipInsideMargin` | `EdgeInsets.all(16)` | Rich Tooltip 内边距 |
| `richTooltipActionCornerRadius` | `8` | Rich Tooltip 操作按钮圆角半径 |
| `richTooltipActionInsideMargin` | `EdgeInsets.symmetric(horizontal: 12, vertical: 6)` | Rich Tooltip 操作按钮内边距 |
| `tooltipDuration` | `Duration(milliseconds: 1500)` | 非持久 Tooltip 自动关闭时长 |
| `animationDuration` | `Duration(milliseconds: 180)` | 进/退场动画时长 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `plainTooltipContainerColor(context)` | `Color` | Plain Tooltip 容器色，取 `onSecondaryVariant` |
| `plainTooltipContentColor(context)` | `Color` | Plain Tooltip 内容色，取 `secondaryVariant` |
| `richTooltipColors(context)` | `MiuixRichTooltipColors` | Rich Tooltip 默认配色 |

### MiuixTooltipBox

将 `tooltip` 锚定到 `child`，支持鼠标悬停、触摸长按及状态控制。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `tooltip` | `Widget Function(BuildContext, MiuixTooltipScope)` | 必填 | Tooltip 内容槽，scope 提供实际方位与锚点边界 |
| `child` | `Widget` | 必填 | 锚点子组件 |
| `state` | `MiuixTooltipState?` | `null` | 显隐状态，未提供时内部自建 |
| `positioning` | `MiuixTooltipAnchorPosition` | `below` | 首选方位，空间不足时翻转 |
| `spacing` | `double` | `8` | Tooltip 与锚点间距 |
| `focusable` | `bool` | `false` | 是否可点外/返回键关闭 |
| `enableUserInput` | `bool` | `true` | 是否响应悬停/长按 |
| `semanticLabel` | `String` | `'显示提示'` | 无障碍标签 |

**示例：**
```dart
MiuixTooltipBox(
  tooltip: (context, scope) =>
      MiuixPlainTooltip(scope: scope, child: const Text('提示文本')),
  child: MiuixIcon(vector: MiuixIcons.extended.byName('info')!),
)
```

### MiuixPlainTooltip

反色表面的短标签 Tooltip，配合 `MiuixTooltipBox` 使用。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `scope` | `MiuixTooltipScope` | 必填 | 来自 `MiuixTooltipBox` 的锚点信息 |
| `child` | `Widget` | 必填 | Tooltip 内容 |
| `showCaret` | `bool` | `false` | 是否显示指向锚点的箭头 |
| `maxWidth` | `double` | `200` | 最大宽度 |
| `cornerRadius` | `double` | `12` | 圆角半径 |
| `containerColor` | `Color?` | `null` | 背景色，默认取反色表面 |
| `contentColor` | `Color?` | `null` | 内容色 |
| `insideMargin` | `EdgeInsetsGeometry` | `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` | 内边距 |

### MiuixRichTooltip

带可选标题和操作的持久 Rich Tooltip，配合 `MiuixTooltipBox` 使用。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `scope` | `MiuixTooltipScope` | 必填 | 来自 `MiuixTooltipBox` 的锚点信息 |
| `text` | `Widget` | 必填 | 正文内容 |
| `title` | `Widget?` | `null` | 标题 |
| `action` | `Widget?` | `null` | 操作按钮 |
| `showCaret` | `bool` | `false` | 是否显示箭头 |
| `maxWidth` | `double` | `320` | 最大宽度 |
| `cornerRadius` | `double` | `16` | 圆角半径 |
| `colors` | `MiuixRichTooltipColors?` | `null` | 配色，默认取主题 |
| `insideMargin` | `EdgeInsetsGeometry` | `EdgeInsets.all(16)` | 内边距 |

### MiuixRichTooltipBox

常用 Rich Tooltip 便捷封装；默认创建持久状态并支持点外及返回键关闭。参数以字符串直接传入标题/正文/操作，无需自行构建 tooltip 槽。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `text` | `String` | 必填 | 正文文本 |
| `child` | `Widget` | 必填 | 锚点子组件 |
| `state` | `MiuixTooltipState?` | `null` | 显隐状态，默认内部创建持久状态 |
| `title` | `String?` | `null` | 标题文本 |
| `actionText` | `String?` | `null` | 操作按钮文本 |
| `onActionPressed` | `VoidCallback?` | `null` | 操作按钮回调 |
| `enabled` | `bool` | `true` | 是否响应用户输入 |
| `positioning` | `MiuixTooltipAnchorPosition` | `below` | 首选方位 |
| `colors` | `MiuixRichTooltipColors?` | `null` | 配色 |
| `showCaret` | `bool` | `false` | 是否显示箭头 |

### MiuixSnackbarVisuals

Snackbar 的可视数据。对应 Kotlin `SnackbarVisuals`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `message` | `String` | 必填 | 显示的消息文本 |
| `actionLabel` | `String?` | `null` | 可选操作标签 |
| `withDismissAction` | `bool` | `false` | 是否显示关闭操作 |
| `duration` | `MiuixSnackbarDuration` | `MiuixSnackbarDuration.short` | 显示时长 |

### MiuixSnackbarData

Snackbar 的交互数据接口。对应 Kotlin `SnackbarData`。

| 方法 / 字段 | 类型 | 说明 |
|---|---|---|
| `visuals` | `MiuixSnackbarVisuals` (getter) | Snackbar 的可视数据 |
| `dismiss()` | `Future<void>` | 关闭 Snackbar |
| `performAction()` | `Future<void>` | 执行 Snackbar 操作 |

### MiuixSnackbarResult

Snackbar 完成结果枚举。对应 Kotlin `SnackbarResult`。

| 值 | 说明 |
|---|---|
| `dismissed` | Snackbar 被关闭或超时消失 |
| `actionPerformed` | 用户执行了 Snackbar 操作 |

### MiuixSnackbarColors

Snackbar 卡片颜色配置。对应 Kotlin `SnackbarColors`。5 个字段均为必填。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `containerColor` | `Color` | 必填 | 卡片背景色 |
| `contentColor` | `Color` | 必填 | 消息内容色 |
| `actionContentColor` | `Color` | 必填 | 操作标签内容色 |
| `dismissActionContentColor` | `Color` | 必填 | 关闭操作内容色 |
| `actionContainerColor` | `Color` | 必填 | 操作标签胶囊背景色 |

### MiuixSnackbarDefaults

Snackbar 默认值。对应 Kotlin `SnackbarDefaults`（私有构造，仅 `static` 字段与方法）。

| 常量 | 值 | 说明 |
|---|---|---|
| `cornerRadius` | `16` | 默认圆角半径 |
| `insideMargin` | `EdgeInsets.all(12)` | 默认内部边距 |
| `outerPadding` | `EdgeInsets.only(left: 12, right: 12, top: 8)` | 默认外部边距 |
| `actionCornerRadius` | `50` | 操作标签胶囊默认圆角半径 |
| `actionInsideMargin` | `EdgeInsets.symmetric(horizontal: 12)` | 操作标签胶囊默认内部边距 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `snackbarColors(context)` | `MiuixSnackbarColors` | 从当前主题创建默认 Snackbar 颜色 |

### MiuixSnackbarHostState

Snackbar Host 的状态对象，继承 `ChangeNotifier`。对应 Kotlin `SnackbarHostState`。持有 Snackbar 队列，每次 `showSnackbar` 都在队列底部加入一个独立 Snackbar；多个消息可同时显示。返回的 Future 会在超时、关闭、滑动关闭或操作执行后完成。

| 方法 | 返回 | 说明 |
|---|---|---|
| `showSnackbar(message, {actionLabel, withDismissAction, duration})` | `Future<MiuixSnackbarResult>` | 入队一个 Snackbar 并返回完成结果 |
| `newestSnackbarData()` | `Future<MiuixSnackbarData?>` | 返回当前最新的可见 Snackbar 数据 |
| `oldestSnackbarData()` | `Future<MiuixSnackbarData?>` | 返回当前最旧的可见 Snackbar 数据 |

**示例：**
```dart
final host = MiuixSnackbarHostState();
host.showSnackbar('已保存', actionLabel: '撤销');
MiuixSnackbarHost(state: host);
```

### MiuixSnackbarHost

统一管理 Snackbar 队列、自动关闭、进退场和双向滑动关闭；最新消息位于底部。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `state` | `MiuixSnackbarHostState` | 必填 | Host 状态 |
| `canSwipeToDismiss` | `bool` | `true` | 是否允许水平滑动关闭 |
| `builder` | `Widget Function(BuildContext, MiuixSnackbarData)?` | `null` | 自定义卡片内容，默认构建 `MiuixSnackbar` |
| `blurSigma` | `double` | `0.0` | 默认构建时传给 `MiuixSnackbar` 的模糊强度，> 0 启用毛玻璃背景 |
| `blurBackgroundAlpha` | `double` | `0.55` | 默认构建时传给 `MiuixSnackbar` 的背景不透明度 |

`MiuixSnackbarHostState` 通过 `showSnackbar(message, {actionLabel, withDismissAction, duration})` 入队并返回 `Future<MiuixSnackbarResult>`。

**示例：**
```dart
final host = MiuixSnackbarHostState();
// 显示
host.showSnackbar('已保存', actionLabel: '撤销');
// 挂载（毛玻璃背景）
MiuixSnackbarHost(state: host, blurSigma: 30);
```

### MiuixSnackbar

Snackbar 卡片，由 Host 默认构建；可单独用于自定义 `builder`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `data` | `MiuixSnackbarData` | 必填 | Snackbar 交互数据 |
| `cornerRadius` | `double` | `16` | 卡片圆角半径 |
| `colors` | `MiuixSnackbarColors?` | `null` | 卡片颜色，默认取主题 |
| `insideMargin` | `EdgeInsetsGeometry` | `EdgeInsets.all(12)` | 卡片内部边距 |
| `blurSigma` | `double` | `0.0` | 高斯模糊强度，> 0 启用 HyperOS 风格毛玻璃背景（用 `BackdropFilter` 模糊身后内容，背景色降为半透明） |
| `blurBackgroundAlpha` | `double` | `0.55` | 启用模糊时背景色的不透明度，越小越透 |

### MiuixFloatingToolbar

悬浮工具栏：自包含容器（squircle 背景 + 固定几何阴影 + 可选描边），横/纵布局由调用方在 `child` 内自行决定。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `child` | `Widget` | 必填 | 内容（调用方自行用 Row/Column 排布） |
| `color` | `Color?` | `null` | 背景色，默认取主题 `surfaceContainer` |
| `cornerRadius` | `double` | `50` | 圆角半径 |
| `outSidePadding` | `EdgeInsetsGeometry` | `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` | 外部留白 |
| `shadowElevation` | `double` | `4` | 阴影开关（>0 显示，几何固定不缩放） |
| `showDivider` | `bool` | `false` | 是否显示 0.75dp 描边 |

**示例：**
```dart
MiuixFloatingToolbar(
  child: Row(mainAxisSize: MainAxisSize.min, children: const [/* 按钮 */]),
)
```

### MiuixFloatingToolbarDefaults

悬浮工具栏默认值。对应 Kotlin `FloatingToolbarDefaults`（私有构造，仅 `static` 字段与方法）。

| 常量 | 值 | 说明 |
|---|---|---|
| `cornerRadius` | `50` | 默认圆角半径（配合较矮工具栏形成胶囊轮廓） |
| `outSidePadding` | `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` | 工具栏外部留白 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `defaultColor(context)` | `Color` | 默认背景色，取主题 `surfaceContainer` |

### MiuixProgressIndicatorColors

进度指示器颜色配置。对应 Kotlin `ProgressIndicatorColors`。3 个字段均为必填。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `foregroundColor` | `Color` | 必填 | 启用时的前景色 |
| `disabledForegroundColor` | `Color` | 必填 | 禁用时的前景色 |
| `backgroundColor` | `Color` | 必填 | 轨道背景色 |

| 方法 | 返回 | 说明 |
|---|---|---|
| `foreground(bool enabled)` | `Color` | 根据 `enabled` 返回前景色 |
| `background()` | `Color` | 返回轨道背景色 |

### MiuixProgressIndicatorDefaults

进度指示器默认值。对应 Kotlin `ProgressIndicatorDefaults`（私有构造，仅 `static` 字段与方法）。

| 常量 | 值 | 说明 |
|---|---|---|
| `defaultLinearHeight` | `6` | 线性指示器默认高度 |
| `defaultCircularStrokeWidth` | `4` | 圆形指示器默认弧线宽度 |
| `defaultCircularSize` | `30` | 圆形指示器默认尺寸 |
| `defaultInfiniteStrokeWidth` | `2` | 无限指示器默认轨道环宽度 |
| `defaultInfiniteOrbitingDotSize` | `2` | 无限指示器默认绕行圆点尺寸 |
| `defaultInfiniteSize` | `20` | 无限指示器默认尺寸 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `defaultColors(context)` | `MiuixProgressIndicatorColors` | 线性与圆形进度指示器的默认颜色 |

### MiuixLinearProgressIndicator

Miuix 风格线性进度指示器。`progress` 为 `null` 时显示 1250ms 线性循环动画。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `progress` | `double?` | `null` | 进度（0–1），`null` 为无限循环 |
| `colors` | `MiuixProgressIndicatorColors?` | `null` | 配色，默认取主题 |
| `height` | `double` | `6` | 轨道高度 |

### MiuixCircularProgressIndicator

Miuix 风格圆形进度指示器。`progress` 为 `null` 时圆弧旋转并在 30°–120° 往返。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `progress` | `double?` | `null` | 进度（0–1），`null` 为无限循环 |
| `colors` | `MiuixProgressIndicatorColors?` | `null` | 配色，默认取主题 |
| `strokeWidth` | `double` | `4` | 弧线宽度 |
| `size` | `double` | `30` | 指示器尺寸 |

### MiuixInfiniteProgressIndicator

带轨道环与绕行圆点的无限进度指示器。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `color` | `Color` | `Color(0xFF888888)` | 颜色（对应 Compose `Color.Gray`） |
| `size` | `double` | `20` | 指示器尺寸 |
| `strokeWidth` | `double` | `2` | 轨道环宽度 |
| `orbitingDotSize` | `double` | `2` | 绕行圆点尺寸 |

**示例：**
```dart
const MiuixCircularProgressIndicator()          // 无限循环
const MiuixLinearProgressIndicator(progress: 0.6)
```

### MiuixRefreshState

下拉刷新指示器的视觉状态枚举。对应 Kotlin `RefreshState`。

| 值 | 说明 |
|---|---|
| `idle` | 空闲 |
| `pulling` | 正在下拉，未达阈值 |
| `thresholdReached` | 已达刷新阈值 |
| `refreshing` | 刷新中 |
| `refreshComplete` | 刷新完成（淡出过渡） |

### MiuixPullToRefreshDefaults

下拉刷新默认值。对应 Kotlin `PullToRefreshDefaults`（私有构造，仅 `static` 字段）。

| 常量 | 值 | 说明 |
|---|---|---|
| `color` | `Color(0xFF888888)` | 指示器颜色（对应 Compose `Color.Gray`） |
| `circleSize` | `20` | 指示器圆圈尺寸 |
| `refreshThreshold` | `0.25` | 触发刷新的进度阈值（0–1） |
| `refreshTexts` | `['Pull down to refresh', 'Release to refresh', 'Refreshing...', 'Refreshed successfully']` | 各状态提示文案 |
| `refreshTextStyle` | `TextStyle(fontSize: 14, fontWeight: bold, color: color)` | 提示文字样式 |

### MiuixPullToRefreshController

下拉刷新控制器，继承 `ChangeNotifier`。保存下拉距离、进度和刷新视觉状态。`refreshThreshold` 表示完整阻尼拖拽范围中触发刷新的比例，取值会限制在 0 到 1；刷新业务状态仍应由 `MiuixPullToRefresh.isRefreshing` 提升管理。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `refreshThreshold` | `double` | `MiuixPullToRefreshDefaults.refreshThreshold`（0.25） | 触发阈值，取值范围 0–1 |

| 方法 / 字段 | 类型 | 说明 |
|---|---|---|
| `refreshState` | `MiuixRefreshState` (getter) | 当前刷新视觉状态 |
| `dragOffset` | `double` (getter) | 当前阻尼后的下拉距离（逻辑像素） |
| `pullProgress` | `double` (getter) | 相对于有效阈值的进度 |
| `fullDragProgress` | `double` (getter) | 相对于完整阻尼拖拽范围的进度 |
| `visualProgress` | `double` (getter) | 指示器从零缩放到完整尺寸的进度 |
| `refreshThreshold` | `double` (getter/setter) | 触发阈值，setter 会重新计算内部参数 |

### MiuixPullToRefresh

Miuix 风格下拉刷新容器。`child` 应包含纵向可滚动组件；刷新业务状态由调用方通过 `isRefreshing` 提升管理。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `isRefreshing` | `bool` | 必填 | 由调用方提升管理的刷新状态 |
| `onRefresh` | `VoidCallback` | 必填 | 越过阈值松手后调用，应尽快把 `isRefreshing` 置 true |
| `child` | `Widget` | 必填 | 内容（含纵向滚动组件） |
| `controller` | `MiuixPullToRefreshController?` | `null` | 下拉状态控制器，未提供时内部自建 |
| `contentPadding` | `EdgeInsetsGeometry` | `EdgeInsets.zero` | 内容内边距 |
| `topAppBarScrollBehavior` | `MiuixScrollBehavior?` | `null` | 与顶栏联动的滚动行为 |
| `color` | `Color` | `Color(0xFF888888)` | 指示器颜色 |
| `circleSize` | `double` | `20` | 指示器圆圈尺寸 |
| `refreshTexts` | `List<String>` | `MiuixPullToRefreshDefaults.refreshTexts` | 各状态提示文案 |
| `refreshTextStyle` | `TextStyle` | `MiuixPullToRefreshDefaults.refreshTextStyle` | 提示文字样式 |
| `onPullProgress` | `ValueChanged<double>?` | `null` | 完整阻尼拖拽范围内的实时进度回调 |

**示例：**
```dart
MiuixPullToRefresh(
  isRefreshing: refreshing,
  onRefresh: () => setState(() => refreshing = true),
  child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: const []),
)
```

