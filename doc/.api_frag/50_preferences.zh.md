## 设置项与选择器 Preferences & Pickers

### MiuixArrowPreference

带右箭头的偏好设置行，末尾追加 10×16 右箭头图标（RTL 下自动翻转），复用基础行的点击/按压语义。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `title` | `String` | 必填 | 行标题 |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | 标题颜色，null 取 `MiuixBasicComponentDefaults.titleColor` |
| `summary` | `String?` | `null` | 行摘要 |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | 摘要颜色，null 取 `MiuixBasicComponentDefaults.summaryColor` |
| `startAction` | `Widget?` | `null` | 起始侧内容 |
| `endActions` | `List<Widget>?` | `null` | 末尾箭头之前的额外内容 |
| `bottomAction` | `Widget?` | `null` | 底部内容，位于主行下方 |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | 内边距 |
| `onClick` | `VoidCallback?` | `null` | 点击回调，null 时不可点击 |
| `holdDownState` | `bool` | `false` | 是否处于按压态 |
| `enabled` | `bool` | `true` | 是否启用 |

**示例：**
```dart
MiuixArrowPreference(
  title: '关于',
  summary: '版本、许可与开源信息',
  onClick: () {},
)
```

### MiuixArrowPreferenceEndActionColors

ArrowPreference 末尾箭头的颜色配置。根据 `enabled` 在启用色与禁用色之间切换。

| 字段 | 类型 | 说明 |
|---|---|---|
| `color` | `Color` | 启用态颜色 |
| `disabledColor` | `Color` | 禁用态颜色 |

| 方法 | 签名 | 说明 |
|---|---|---|
| `resolve` | `Color resolve(bool enabled)` | `enabled` 为 true 返回 `color`，否则返回 `disabledColor` |

### MiuixArrowPreferenceDefaults

ArrowPreference 的默认值集合。私有构造，仅提供静态方法。

| 方法 | 签名 | 说明 |
|---|---|---|
| `endActionColors` | `MiuixArrowPreferenceEndActionColors endActionColors(BuildContext context)` | 末尾箭头的默认颜色：`color` 取主题 `onSurfaceVariantActions`，`disabledColor` 取 `disabledOnSecondaryVariant` |

### MiuixSwitchPreference

带开关的偏好设置行，行末追加 `MiuixSwitch`；点击整行会切换 `value` 并触发 `onChanged`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `value` | `bool` | 必填 | 当前开关状态 |
| `onChanged` | `ValueChanged<bool>` | 必填 | 状态变更回调 |
| `title` | `String` | 必填 | 行标题 |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | 标题颜色，null 取默认 |
| `summary` | `String?` | `null` | 行摘要 |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | 摘要颜色，null 取默认 |
| `startAction` | `Widget?` | `null` | 起始侧内容 |
| `endActions` | `List<Widget>?` | `null` | 开关之前的额外内容 |
| `bottomAction` | `Widget?` | `null` | 底部内容 |
| `switchColors` | `MiuixSwitchColors?` | `null` | 开关颜色，null 取 `MiuixSwitchDefaults.switchColors` |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | 内边距 |
| `holdDownState` | `bool` | `false` | 是否处于按压态 |
| `enabled` | `bool` | `true` | 是否启用 |

**示例：**
```dart
MiuixSwitchPreference(
  title: '飞行模式',
  value: enabled,
  onChanged: (v) => setState(() => enabled = v),
)
```

### MiuixCheckboxLocation

`MiuixCheckboxPreference` 中复选框的位置枚举。RTL 下 `start`/`end` 会自动镜像。

| 值 | 说明 |
|---|---|
| `start` | 起始侧（标题之前） |
| `end` | 末尾侧（endActions 之后） |

### MiuixCheckboxPreference

带复选框的偏好设置行，复选框位置由 `checkboxLocation` 决定；点击整行切换 `value` 并触发 `onChanged`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `title` | `String` | 必填 | 行标题 |
| `value` | `bool` | 必填 | 当前复选框状态 |
| `onChanged` | `ValueChanged<bool>?` | 必填 | 状态变更回调，null 时不可交互 |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | 标题颜色，null 取默认 |
| `summary` | `String?` | `null` | 行摘要 |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | 摘要颜色，null 取默认 |
| `checkboxColors` | `MiuixCheckboxColors?` | `null` | 复选框颜色，null 取 `MiuixCheckboxDefaults.checkboxColors` |
| `startAction` | `Widget?` | `null` | 起始侧额外内容（复选框之后，5dp 间距） |
| `endActions` | `List<Widget>?` | `null` | 末尾额外内容（复选框之前，8dp 间距） |
| `checkboxLocation` | `MiuixCheckboxLocation` | `MiuixCheckboxLocation.start` | 复选框位置 |
| `bottomAction` | `Widget?` | `null` | 底部内容 |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | 内边距 |
| `holdDownState` | `bool` | `false` | 是否处于按压态 |
| `enabled` | `bool` | `true` | 是否启用 |

枚举 `MiuixCheckboxLocation`：`start`（起始侧，标题之前）、`end`（末尾侧，endActions 之后）。

**示例：**
```dart
MiuixCheckboxPreference(
  title: '接受条款',
  value: agreed,
  onChanged: (v) => setState(() => agreed = v),
)
```

### MiuixRadioButtonLocation

`MiuixRadioButtonPreference` 中单选按钮的位置枚举。RTL 下 `start`/`end` 会自动镜像。

| 值 | 说明 |
|---|---|
| `start` | 起始侧（标题之前） |
| `end` | 末尾侧（endActions 之后） |

### MiuixRadioButtonPreference

带单选按钮的偏好设置行，单选按钮位置由 `radioButtonLocation` 决定；选中时标题/摘要色切换为 `primary`，点击整行触发 `onClick` 并给出触感反馈。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `title` | `String` | 必填 | 行标题 |
| `selected` | `bool` | 必填 | 是否处于选中态 |
| `onClick` | `VoidCallback?` | `null` | 点击回调，null 时不可点击 |
| `summary` | `String?` | `null` | 行摘要 |
| `colors` | `MiuixRadioButtonPreferenceColors?` | `null` | 标题/摘要颜色，null 取 `MiuixRadioButtonPreferenceDefaults.radioButtonPreferenceColors` |
| `radioButtonColors` | `MiuixRadioButtonColors?` | `null` | 单选按钮颜色，null 取 `MiuixRadioButtonDefaults.radioButtonColors` |
| `startAction` | `Widget?` | `null` | 起始侧额外内容（单选按钮之后，5dp 间距） |
| `endActions` | `List<Widget>?` | `null` | 末尾额外内容（单选按钮之前，8dp 间距） |
| `radioButtonLocation` | `MiuixRadioButtonLocation` | `MiuixRadioButtonLocation.start` | 单选按钮位置 |
| `bottomAction` | `Widget?` | `null` | 底部内容 |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | 内边距 |
| `holdDownState` | `bool` | `false` | 是否处于按压态 |
| `enabled` | `bool` | `true` | 是否启用 |

枚举 `MiuixRadioButtonLocation`：`start`（起始侧，标题之前）、`end`（末尾侧，endActions 之后）。

**示例：**
```dart
MiuixRadioButtonPreference(
  title: '选项 A',
  selected: index == 0,
  onClick: () => setState(() => index = 0),
)
```

### MiuixRadioButtonPreferenceColors

RadioButtonPreference 标题与摘要的颜色配置。根据 `selected` 在基础色与选中色之间切换。

| 字段 | 类型 | 说明 |
|---|---|---|
| `titleColor` | `MiuixBasicComponentColors` | 未选中标题颜色 |
| `selectedTitleColor` | `MiuixBasicComponentColors` | 选中标题颜色 |
| `summaryColor` | `MiuixBasicComponentColors` | 未选中摘要颜色 |
| `selectedSummaryColor` | `MiuixBasicComponentColors` | 选中摘要颜色 |

| 方法 | 签名 | 说明 |
|---|---|---|
| `resolveTitleColor` | `MiuixBasicComponentColors resolveTitleColor(bool selected)` | `selected` 为 true 返回 `selectedTitleColor`，否则返回 `titleColor` |
| `resolveSummaryColor` | `MiuixBasicComponentColors resolveSummaryColor(bool selected)` | `selected` 为 true 返回 `selectedSummaryColor`，否则返回 `summaryColor` |

### MiuixRadioButtonPreferenceDefaults

RadioButtonPreference 的默认值集合。私有构造，仅提供静态方法。

| 方法 | 签名 | 说明 |
|---|---|---|
| `radioButtonPreferenceColors` | `MiuixRadioButtonPreferenceColors radioButtonPreferenceColors(BuildContext context)` | 标题与摘要的默认颜色：未选中标题取 `onBackground`、未选中摘要取 `onSurfaceVariantSummary`，选中态均取 `primary`；禁用色统一为 `disabledOnSecondaryVariant` |

### MiuixSliderPreference

带滑块的偏好设置行，`MiuixSlider` 放在底部区域；末尾可显示 `valueText`，`onClick` 非空时追加右箭头图标。断言 `steps >= 0` 且 `min < max`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `value` | `double` | 必填 | 当前滑块值，会被夹到 `min..max` |
| `onValueChange` | `ValueChanged<double>` | 必填 | 值变更回调 |
| `title` | `String?` | `null` | 行标题 |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | 标题颜色，null 取默认 |
| `summary` | `String?` | `null` | 行摘要 |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | 摘要颜色，null 取默认 |
| `startAction` | `Widget?` | `null` | 起始侧内容 |
| `valueText` | `String?` | `null` | 末尾区域当前值文本 |
| `endActions` | `List<Widget>?` | `null` | `valueText` 之后的额外内容 |
| `bottomAction` | `Widget?` | `null` | 滑块上方的额外内容 |
| `onClick` | `VoidCallback?` | `null` | 点击回调，非空时末尾追加右箭头 |
| `holdDownState` | `bool` | `false` | 是否处于按压态 |
| `enabled` | `bool` | `true` | 是否启用 |
| `min` | `double` | `0.0` | 滑块最小值 |
| `max` | `double` | `1.0` | 滑块最大值 |
| `steps` | `int` | `0` | 离散步进数，0 表示连续 |
| `onValueChangeFinished` | `VoidCallback?` | `null` | 值变更结束回调 |
| `reverseDirection` | `bool` | `false` | 是否反向（从右向左递增） |
| `sliderHeight` | `double` | `MiuixSliderDefaults.minHeight`（28） | 滑块高度 |
| `sliderColors` | `MiuixSliderColors?` | `null` | 滑块颜色，null 取 `MiuixSliderDefaults.sliderColors` |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect`（`edge`） | 触感反馈类型 |
| `showKeyPoints` | `bool` | `false` | 是否显示关键点 |
| `keyPoints` | `List<double>?` | `null` | 自定义关键点，null 时由 `steps` 推导 |
| `magnetThreshold` | `double` | `0.02` | 磁吸阈值（0..1） |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | 内边距 |

**示例：**
```dart
MiuixSliderPreference(
  title: '亮度',
  value: brightness,
  valueText: '${(brightness * 100).round()}%',
  onValueChange: (v) => setState(() => brightness = v),
)
```

### MiuixRangeSliderPreference

带范围滑块的偏好设置行，`MiuixRangeSlider` 放在底部区域；末尾可显示 `valueText`，`onClick` 非空时追加右箭头图标。断言 `steps >= 0` 且 `min < max`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `startValue` | `double` | 必填 | 起始值，会被夹到 `min..max` |
| `endValue` | `double` | 必填 | 结束值，会被夹到 `min..max` |
| `onValueChange` | `ValueChanged<(double, double)>` | 必填 | 值变更回调，参数为 `(newStart, newEnd)` |
| `title` | `String?` | `null` | 行标题 |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | 标题颜色 |
| `summary` | `String?` | `null` | 行摘要 |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | 摘要颜色 |
| `startAction` | `Widget?` | `null` | 起始侧内容 |
| `valueText` | `String?` | `null` | 末尾区域当前值文本 |
| `endActions` | `List<Widget>?` | `null` | 末尾区域额外内容 |
| `bottomAction` | `Widget?` | `null` | 滑块上方的额外内容 |
| `onClick` | `VoidCallback?` | `null` | 点击回调，非空时末尾追加右箭头 |
| `holdDownState` | `bool` | `false` | 是否处于按压态 |
| `enabled` | `bool` | `true` | 是否启用 |
| `min` | `double` | `0.0` | 滑块最小值 |
| `max` | `double` | `1.0` | 滑块最大值 |
| `steps` | `int` | `0` | 离散步进数 |
| `onValueChangeFinished` | `VoidCallback?` | `null` | 值变更结束回调 |
| `sliderHeight` | `double` | `MiuixSliderDefaults.minHeight`（28） | 滑块高度 |
| `sliderColors` | `MiuixSliderColors?` | `null` | 滑块颜色 |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect`（`edge`） | 触感反馈类型 |
| `showKeyPoints` | `bool` | `false` | 是否显示关键点 |
| `keyPoints` | `List<double>?` | `null` | 自定义关键点 |
| `magnetThreshold` | `double` | `0.02` | 磁吸阈值 |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | 内边距 |

**示例：**
```dart
MiuixRangeSliderPreference(
  title: '价格区间',
  startValue: lo,
  endValue: hi,
  onValueChange: (r) => setState(() { lo = r.$1; hi = r.$2; }),
)
```

### MiuixOverlayDropdownPreference

Scaffold 内下拉偏好行，行末显示选中值文本与下拉箭头，点击展开下拉弹窗（在根 Scaffold 内渲染）。默认构造函数接收 `items` + `selectedIndex`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `items` | `List<String>` | 必填 | 下拉项文本列表 |
| `selectedIndex` | `int` | 必填 | 当前选中索引 |
| `title` | `String` | 必填 | 行标题 |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | 标题颜色 |
| `summary` | `String?` | `null` | 行摘要 |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | 摘要颜色 |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | 下拉颜色，null 取 `MiuixDropdownDefaults.dropdownColors` |
| `startAction` | `Widget?` | `null` | 起始侧内容 |
| `bottomAction` | `Widget?` | `null` | 底部内容 |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | 内边距 |
| `maxHeight` | `double?` | `null` | 弹窗最大高度 |
| `enabled` | `bool` | `true` | 是否启用 |
| `showValue` | `bool` | `true` | 是否显示选中值文本 |
| `renderInRootScaffold` | `bool` | `true` | 是否在根 Scaffold 内渲染弹窗 |
| `collapseOnSelection` | `bool?` | `true` | 选中后是否收起（默认构造函数为 `true`） |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | 展开状态变更回调 |
| `onSelectedIndexChange` | `ValueChanged<int>?` | `null` | 选中索引变更回调 |

命名构造函数：`.entry({required MiuixDropdownEntry entry, ...})` 单分组、`.entries({required List<MiuixDropdownEntry> entries, ...})` 多分组；`.entries` 的 `collapseOnSelection` 默认 `null`（据分组数自动决定），且不接收 `onSelectedIndexChange`。

**示例：**
```dart
MiuixOverlayDropdownPreference(
  title: '语言',
  items: const ['简体中文', 'English'],
  selectedIndex: langIndex,
  onSelectedIndexChange: (i) => setState(() => langIndex = i),
)
```

### MiuixWindowDropdownPreference

窗口级下拉偏好行，行为同 `MiuixOverlayDropdownPreference`，但弹窗以根 Overlay 渲染，故无 `renderInRootScaffold` 参数。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `items` | `List<String>` | 必填 | 下拉项文本列表 |
| `selectedIndex` | `int` | 必填 | 当前选中索引 |
| `title` | `String` | 必填 | 行标题 |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | 标题颜色 |
| `summary` | `String?` | `null` | 行摘要 |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | 摘要颜色 |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | 下拉颜色，null 取默认 |
| `startAction` | `Widget?` | `null` | 起始侧内容 |
| `bottomAction` | `Widget?` | `null` | 底部内容 |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | 内边距 |
| `maxHeight` | `double?` | `null` | 弹窗最大高度 |
| `enabled` | `bool` | `true` | 是否启用 |
| `showValue` | `bool` | `true` | 是否显示选中值文本 |
| `collapseOnSelection` | `bool?` | `true` | 选中后是否收起 |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | 展开状态变更回调 |
| `onSelectedIndexChange` | `ValueChanged<int>?` | `null` | 选中索引变更回调 |

命名构造函数：`.entry`（单分组）、`.entries`（多分组，`collapseOnSelection` 默认 `null`）。

**示例：**
```dart
MiuixWindowDropdownPreference(
  title: '主题',
  items: const ['浅色', '深色', '跟随系统'],
  selectedIndex: themeIndex,
  onSelectedIndexChange: (i) => setState(() => themeIndex = i),
)
```

### MiuixOverlaySpinnerPreference

Scaffold 内下拉选择偏好行。与 Dropdown 的区别：`items` 为 `List<MiuixDropdownItem>`（保留 icon/summary 等），且 `dialogButtonString` 非空时改用对话框模式（否则弹窗模式）。默认构造函数接收 `items` + `selectedIndex`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `items` | `List<MiuixDropdownItem>` | 必填 | 下拉项列表 |
| `selectedIndex` | `int` | 必填 | 当前选中索引 |
| `title` | `String` | 必填 | 行标题 |
| `dialogButtonString` | `String?` | `null` | 非空时使用对话框模式并作为按钮文本 |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | 标题颜色 |
| `summary` | `String?` | `null` | 行摘要 |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | 摘要颜色 |
| `spinnerColors` | `MiuixDropdownColors?` | `null` | 颜色，null 时对话框取 `dialogDropdownColors`、弹窗取 `dropdownColors` |
| `startAction` | `Widget?` | `null` | 起始侧内容 |
| `bottomAction` | `Widget?` | `null` | 底部内容 |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | 内边距 |
| `maxHeight` | `double?` | `null` | 弹窗最大高度 |
| `enabled` | `bool` | `true` | 是否启用 |
| `showValue` | `bool` | `true` | 是否显示选中值文本 |
| `renderInRootScaffold` | `bool` | `true` | 是否在根 Scaffold 内渲染 |
| `collapseOnSelection` | `bool?` | `null` | 选中后是否收起 |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | 展开状态变更回调 |
| `onSelectedIndexChange` | `ValueChanged<int>?` | `null` | 选中索引变更回调 |

命名构造函数：`.entry`（单分组，`collapseOnSelection` 默认 `true`）、`.entries`（多分组，`collapseOnSelection` 默认 `null`）；二者均不接收 `onSelectedIndexChange`。

**示例：**
```dart
MiuixOverlaySpinnerPreference(
  title: '排序方式',
  items: const [MiuixDropdownItem(text: '按名称'), MiuixDropdownItem(text: '按日期')],
  selectedIndex: sortIndex,
  onSelectedIndexChange: (i) => setState(() => sortIndex = i),
)
```

### MiuixWindowSpinnerPreference

窗口级下拉选择偏好行，行为同 `MiuixOverlaySpinnerPreference`，但弹窗以根 Overlay 渲染，故无 `renderInRootScaffold` 参数。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `items` | `List<MiuixDropdownItem>` | 必填 | 下拉项列表 |
| `selectedIndex` | `int` | 必填 | 当前选中索引 |
| `title` | `String` | 必填 | 行标题 |
| `dialogButtonString` | `String?` | `null` | 非空时使用对话框模式并作为按钮文本 |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | 标题颜色 |
| `summary` | `String?` | `null` | 行摘要 |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | 摘要颜色 |
| `spinnerColors` | `MiuixDropdownColors?` | `null` | 颜色，null 时按模式取默认 |
| `startAction` | `Widget?` | `null` | 起始侧内容 |
| `bottomAction` | `Widget?` | `null` | 底部内容 |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | 内边距 |
| `maxHeight` | `double?` | `null` | 弹窗最大高度 |
| `enabled` | `bool` | `true` | 是否启用 |
| `showValue` | `bool` | `true` | 是否显示选中值文本 |
| `collapseOnSelection` | `bool?` | `null` | 选中后是否收起 |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | 展开状态变更回调 |
| `onSelectedIndexChange` | `ValueChanged<int>?` | `null` | 选中索引变更回调 |

命名构造函数：`.entry`（单分组，`collapseOnSelection` 默认 `true`）、`.entries`（多分组，默认 `null`）。

**示例：**
```dart
MiuixWindowSpinnerPreference(
  title: '账户',
  items: const [MiuixDropdownItem(text: '张三'), MiuixDropdownItem(text: '李四')],
  selectedIndex: 0,
  dialogButtonString: '取消',
  onSelectedIndexChange: (i) {},
)
```

### MiuixColorSpace

`MiuixColorPicker` 使用的色彩空间枚举。

| 值 | 说明 |
|---|---|
| `hsv` | 传统 HSV |
| `okhsv` | 基于 OkLab 的 OkHSV，感知均匀性更好 |
| `oklab` | OkLab（明度 + 绿红轴 + 蓝黄轴） |
| `oklch` | OkLCH（明度 + 色度 + 色相） |

### MiuixColorPicker

Miuix 风格、支持多色彩空间的滑块取色器，根据 `colorSpace` 分派到对应子取色器；含 H/S/V（或对应通道）与透明度滑块。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `color` | `Color` | 必填 | 当前颜色 |
| `onColorChanged` | `ValueChanged<Color>` | 必填 | 颜色变化回调 |
| `showPreview` | `bool` | `true` | 是否显示所选颜色预览条 |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect`（`edge`） | 滑块触感反馈类型 |
| `colorSpace` | `MiuixColorSpace` | `MiuixColorSpace.hsv` | 使用的色彩空间 |

枚举 `MiuixColorSpace`：`hsv`（传统 HSV）、`okhsv`（基于 OkLab 的 OkHSV，感知均匀性更好）、`oklab`（明度 + 绿红轴 + 蓝黄轴）、`oklch`（明度 + 色度 + 色相）。

针对单一色彩空间也提供等价的直接组件（构造参数同上，无 `colorSpace`）：`MiuixHsvColorPicker`、`MiuixOkHsvColorPicker`、`MiuixOkLabColorPicker`、`MiuixOkLchColorPicker`。

**示例：**
```dart
MiuixColorPicker(
  color: current,
  colorSpace: MiuixColorSpace.okhsv,
  onColorChanged: (c) => setState(() => current = c),
)
```

### MiuixHsvColorPicker

HSV 色彩空间的 Miuix 取色器。参数与 `MiuixColorPicker` 相同，但无 `colorSpace` 字段，固定使用 HSV 色彩空间。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `color` | `Color` | 必填 | 当前颜色 |
| `onColorChanged` | `ValueChanged<Color>` | 必填 | 颜色变化回调 |
| `showPreview` | `bool` | `true` | 是否显示所选颜色预览条 |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect`（`edge`） | 滑块触感反馈类型 |

### MiuixOkHsvColorPicker

OkHSV 色彩空间的 Miuix 取色器。参数与 `MiuixColorPicker` 相同，但无 `colorSpace` 字段，固定使用 OkHSV 色彩空间（基于 OkLab，感知均匀性更好）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `color` | `Color` | 必填 | 当前颜色 |
| `onColorChanged` | `ValueChanged<Color>` | 必填 | 颜色变化回调 |
| `showPreview` | `bool` | `true` | 是否显示所选颜色预览条 |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect`（`edge`） | 滑块触感反馈类型 |

### MiuixOkLabColorPicker

OkLab 色彩空间的 Miuix 取色器。参数与 `MiuixColorPicker` 相同，但无 `colorSpace` 字段，固定使用 OkLab 色彩空间（明度 + 绿红轴 + 蓝黄轴）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `color` | `Color` | 必填 | 当前颜色 |
| `onColorChanged` | `ValueChanged<Color>` | 必填 | 颜色变化回调 |
| `showPreview` | `bool` | `true` | 是否显示所选颜色预览条 |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect`（`edge`） | 滑块触感反馈类型 |

### MiuixOkLchColorPicker

OkLch 色彩空间的 Miuix 取色器。参数与 `MiuixColorPicker` 相同，但无 `colorSpace` 字段，固定使用 OkLch 色彩空间（明度 + 色度 + 色相）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `color` | `Color` | 必填 | 当前颜色 |
| `onColorChanged` | `ValueChanged<Color>` | 必填 | 颜色变化回调 |
| `showPreview` | `bool` | `true` | 是否显示所选颜色预览条 |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect`（`edge`） | 滑块触感反馈类型 |

### MiuixColorPalette

Miuix 风格的 HSV 网格调色板，`color` 外部受控；在网格中按下/拖动或调节透明度时通过 `onColorChanged` 返回新颜色。默认 7 行、12 个色相列并附加灰阶列。断言 `rows > 0`、`hueColumns > 0`、`cornerRadius >= 0`、`indicatorRadius >= 0`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `color` | `Color` | 必填 | 当前颜色 |
| `onColorChanged` | `ValueChanged<Color>` | 必填 | 选色或调节透明度时调用 |
| `rows` | `int` | `MiuixColorPaletteDefaults.rows`（7） | 色彩网格行数 |
| `hueColumns` | `int` | `MiuixColorPaletteDefaults.hueColumns`（12） | 色相列数 |
| `includeGrayColumn` | `bool` | `MiuixColorPaletteDefaults.includeGrayColumn`（true） | 是否在色相列后显示灰阶列 |
| `showPreview` | `bool` | `MiuixColorPaletteDefaults.showPreview`（true） | 是否显示顶部颜色预览 |
| `cornerRadius` | `double` | `MiuixColorPaletteDefaults.cornerRadius`（16） | 网格 squircle 圆角半径 |
| `indicatorRadius` | `double` | `MiuixColorPaletteDefaults.indicatorRadius`（10） | 选中指示器圆环半径 |

**示例：**
```dart
MiuixColorPalette(
  color: current,
  onColorChanged: (c) => setState(() => current = c),
)
```

### MiuixColorPaletteDefaults

MiuixColorPalette 的默认尺寸与网格参数。私有构造，仅含静态常量。

| 常量 | 值 | 说明 |
|---|---|---|
| `rows` | `7` | 默认色彩行数 |
| `hueColumns` | `12` | 默认色相列数 |
| `includeGrayColumn` | `true` | 默认显示灰阶列 |
| `showPreview` | `true` | 默认显示颜色预览 |
| `cornerRadius` | `16` | 调色板网格默认圆角半径 |
| `indicatorRadius` | `10` | 选中指示器默认半径 |
| `controlHeight` | `26` | 颜色预览和透明度滑块的高度 |
| `paletteHeight` | `180` | 调色板网格高度 |
| `spacing` | `12` | 子项之间的垂直间距 |

