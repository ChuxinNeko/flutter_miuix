## 输入 Inputs

### MiuixTextField

Miuix 风格的文本输入框，支持浮动标签、聚焦时的 squircle 边框动画、前后置图标。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `controller` | `TextEditingController?` | `null` | 文本编辑控制器，未提供时内部自建 |
| `focusNode` | `FocusNode?` | `null` | 焦点节点，未提供时内部自建 |
| `onChanged` | `ValueChanged<String>?` | `null` | 文本变化回调 |
| `label` | `String` | `''` | 标签文字（浮动标签） |
| `useLabelAsPlaceholder` | `bool` | `false` | 是否把标签当作占位符（有输入后隐藏而非浮动） |
| `enabled` | `bool` | `true` | 是否启用 |
| `readOnly` | `bool` | `false` | 是否只读 |
| `textStyle` | `TextStyle?` | `null` | 文本样式，默认取主题 `main` |
| `leadingIcon` | `Widget?` | `null` | 前置图标 |
| `trailingIcon` | `Widget?` | `null` | 后置图标 |
| `singleLine` | `bool` | `false` | 是否强制单行 |
| `maxLines` | `int?` | `null` | 最大行数 |
| `minLines` | `int?` | `null` | 最小行数 |
| `colors` | `MiuixTextFieldColors?` | `null` | 颜色配置，默认取主题 |
| `cornerRadius` | `double` | `16` | 圆角半径 |
| `insideMargin` | `EdgeInsets` | `EdgeInsets.all(16)` | 内边距（每侧） |
| `keyboardType` | `TextInputType?` | `null` | 键盘类型 |
| `textInputAction` | `TextInputAction?` | `null` | 键盘 action 按钮类型 |
| `textCapitalization` | `TextCapitalization` | `TextCapitalization.none` | 输入大小写策略 |
| `onSubmitted` | `ValueChanged<String>?` | `null` | 键盘 action 触发时回调 |
| `obscureText` | `bool` | `false` | 是否隐藏输入（密码） |
| `cursorColor` | `Color?` | `null` | 光标颜色，默认取聚焦边框色 |

**示例：**
```dart
MiuixTextField(
  label: '用户名',
  onChanged: (v) {},
)
```

### MiuixTextFieldColors

TextField 颜色配置。所有字段为必填。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `backgroundColor` | `Color` | 必填 | 背景色；`textFieldColors` 中取主题 `secondaryContainer` |
| `labelColor` | `Color` | 必填 | 标签色；`textFieldColors` 中取主题 `onSecondaryContainer` |
| `borderColor` | `Color` | 必填 | 聚焦边框色；`textFieldColors` 中取主题 `primary` |

### MiuixTextFieldDefaults

TextField 默认值集合。私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| `cornerRadius` | `16` | 默认圆角 |
| `insideMargin` | `EdgeInsets.all(16)` | 默认内边距（水平/垂直） |
| `borderWidth` | `2` | 聚焦时边框宽度 |
| `labelFontSizeFloating` | `10` | 标签浮动时字号 |
| `labelFontSizeNormal` | `17` | 标签正常时字号 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `textFieldColors(BuildContext context)` | `MiuixTextFieldColors` | 基于当前主题构造默认颜色配置 |

### MiuixSwitch

Miuix 风格的开关，49x28 胶囊轨道加圆形 thumb，支持点击与水平拖拽切换。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `value` | `bool` | 必填 | 当前是否打开 |
| `onChanged` | `ValueChanged<bool>?` | 必填 | 切换回调，为 `null` 时禁用交互 |
| `enabled` | `bool` | `true` | 是否启用 |
| `colors` | `MiuixSwitchColors?` | `null` | 颜色配置，默认取主题 |

**示例：**
```dart
MiuixSwitch(
  value: isOn,
  onChanged: (v) => setState(() => isOn = v),
)
```

### MiuixSwitchColors

Switch 颜色配置。所有字段为必填。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `checkedThumbColor` | `Color` | 必填 | 选中时 thumb 颜色；`switchColors` 中取主题 `onPrimary` |
| `uncheckedThumbColor` | `Color` | 必填 | 未选时 thumb 颜色；`switchColors` 中取主题 `onSecondary` |
| `disabledCheckedThumbColor` | `Color` | 必填 | 禁用且选中时 thumb 颜色；取 `disabledOnPrimary` |
| `disabledUncheckedThumbColor` | `Color` | 必填 | 禁用且未选时 thumb 颜色；取 `disabledOnSecondary` |
| `checkedTrackColor` | `Color` | 必填 | 选中时轨道颜色；`switchColors` 中取主题 `primary` |
| `uncheckedTrackColor` | `Color` | 必填 | 未选时轨道颜色；`switchColors` 中取主题 `secondary` |
| `disabledCheckedTrackColor` | `Color` | 必填 | 禁用且选中时轨道颜色；取 `disabledPrimary` |
| `disabledUncheckedTrackColor` | `Color` | 必填 | 禁用且未选时轨道颜色；取 `disabledSecondary` |

### MiuixSwitchDefaults

Switch 默认值集合。私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| `trackWidth` | `49` | 轨道宽度 |
| `trackHeight` | `28` | 轨道高度 |
| `thumbSize` | `20` | thumb 直径 |
| `thumbOffsetOff` | `4` | thumb 关闭时偏移 |
| `thumbOffsetOn` | `25` | thumb 开启时偏移 |
| `thumbScaleActive` | `1.127` | thumb 按下/悬停/拖拽时放大系数 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `switchColors(BuildContext context)` | `MiuixSwitchColors` | 基于当前主题构造默认颜色配置 |

### MiuixCheckbox

Miuix 风格的复选框，26dp 圆形背景加带 trim 动画的勾号，支持选中/未选/半选三态。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `value` | `bool?` | 必填 | `true`=选中，`false`=未选，`null`=半选 |
| `onChanged` | `ValueChanged<bool?>?` | `null` | 状态变化回调，为 `null` 时禁用交互 |
| `enabled` | `bool` | `true` | 是否启用 |
| `colors` | `MiuixCheckboxColors?` | `null` | 颜色配置，默认取主题 |

**示例：**
```dart
MiuixCheckbox(
  value: checked,
  onChanged: (v) => setState(() => checked = v ?? false),
)
```

### MiuixCheckboxColors

Checkbox 颜色配置。所有字段为必填。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `checkedForegroundColor` | `Color` | 必填 | 选中时前景色（勾号）；`checkboxColors` 中取 `onPrimary` |
| `uncheckedForegroundColor` | `Color` | 必填 | 未选时前景色；`checkboxColors` 中取 `secondary` |
| `disabledCheckedForegroundColor` | `Color` | 必填 | 禁用且选中时前景色；取 `disabledOnPrimary` |
| `disabledUncheckedForegroundColor` | `Color` | 必填 | 禁用且未选时前景色；取 `disabledOnPrimary` |
| `checkedBackgroundColor` | `Color` | 必填 | 选中时背景色；`checkboxColors` 中取 `primary` |
| `uncheckedBackgroundColor` | `Color` | 必填 | 未选时背景色；`checkboxColors` 中取 `secondary` |
| `disabledCheckedBackgroundColor` | `Color` | 必填 | 禁用且选中时背景色；取 `disabledPrimary` |
| `disabledUncheckedBackgroundColor` | `Color` | 必填 | 禁用且未选时背景色；取 `disabledSecondary` |

### MiuixCheckboxDefaults

Checkbox 默认值集合。私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| `size` | `26` | 复选框尺寸（宽=高） |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `checkboxColors(BuildContext context)` | `MiuixCheckboxColors` | 基于当前主题构造默认颜色配置 |

### MiuixRadioButton

Miuix 风格的单选按钮，26dp，选中时显示带 trim 动画的勾号（无背景圆）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `selected` | `bool` | 必填 | 是否选中 |
| `onChanged` | `ValueChanged<bool>?` | `null` | 选中回调（仅从未选到选中触发），为 `null` 时禁用交互 |
| `enabled` | `bool` | `true` | 是否启用 |
| `colors` | `MiuixRadioButtonColors?` | `null` | 颜色配置，默认取主题 |

**示例：**
```dart
MiuixRadioButton(
  selected: value == 0,
  onChanged: (_) => setState(() => value = 0),
)
```

### MiuixRadioButtonColors

RadioButton 颜色配置。所有字段为必填。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `selectedColor` | `Color` | 必填 | 选中时颜色（勾号与笔触）；`radioButtonColors` 中取 `primary` |
| `disabledSelectedColor` | `Color` | 必填 | 禁用时选中颜色；取 `disabledPrimary` |

### MiuixRadioButtonDefaults

RadioButton 默认值集合。私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| `size` | `26` | 单选按钮尺寸（宽=高） |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `radioButtonColors(BuildContext context)` | `MiuixRadioButtonColors` | 基于当前主题构造默认颜色配置 |

### MiuixSlider

Miuix 风格的水平滑块，支持步进、关键点显示、磁性吸附、触感反馈、反向方向与禁用态。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `value` | `double` | 必填 | 当前值 |
| `onValueChanged` | `ValueChanged<double>?` | 必填 | 值变化回调，为 `null` 时禁用交互 |
| `enabled` | `bool` | `true` | 是否启用 |
| `min` | `double` | `0.0` | 最小值 |
| `max` | `double` | `1.0` | 最大值 |
| `steps` | `int` | `0` | 步进数（0 为连续） |
| `onValueChangeFinished` | `VoidCallback?` | `null` | 拖拽结束回调 |
| `reverseDirection` | `bool` | `false` | 是否反向 |
| `height` | `double` | `MiuixSliderDefaults.minHeight`（28） | 轨道高度 |
| `colors` | `MiuixSliderColors?` | `null` | 颜色配置，默认取主题 |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderHapticEffect.edge` | 触感反馈类型 |
| `showKeyPoints` | `bool` | `false` | 是否显示关键点 |
| `keyPoints` | `List<double>?` | `null` | 自定义关键点值列表 |
| `magnetThreshold` | `double` | `0.02` | 磁性吸附阈值 |

**示例：**
```dart
MiuixSlider(
  value: progress,
  onValueChanged: (v) => setState(() => progress = v),
)
```

### MiuixSliderColors

Slider 颜色配置。所有字段为必填。`MiuixVerticalSlider` 与 `MiuixRangeSlider` 也复用此配置。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `foregroundColor` | `Color` | 必填 | 前景色（已选中段）；`sliderColors` 中取主题 `primary` |
| `disabledForegroundColor` | `Color` | 必填 | 禁用时前景色；取 `disabledPrimarySlider` |
| `backgroundColor` | `Color` | 必填 | 轨道背景色；`sliderColors` 中取 `sliderBackground` |
| `disabledBackgroundColor` | `Color` | 必填 | 禁用时轨道背景色；取 `disabledSecondary` |
| `thumbColor` | `Color` | 必填 | thumb 颜色；`sliderColors` 中取 `onPrimary` |
| `disabledThumbColor` | `Color` | 必填 | 禁用时 thumb 颜色；取 `disabledOnPrimary` |
| `keyPointColor` | `Color` | 必填 | 关键点颜色；`sliderColors` 中取 `sliderKeyPoint` |
| `keyPointForegroundColor` | `Color` | 必填 | 已选中关键点颜色；取 `sliderKeyPointForeground` |

### MiuixSliderDefaults

Slider 默认值集合。私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| `minHeight` | `28` | Slider / RangeSlider 的最小高度（水平）或宽度（垂直） |
| `keyPointRadius` | `3.855` | 关键点半径 |
| `defaultHapticEffect` | `MiuixSliderHapticEffect.edge` | 默认触感反馈类型 |
| `thumbScaleActive` | `1.127` | thumb 在按下/拖拽/悬停时的放大系数 |
| `thumbRadiusRatio` | `0.72` | thumb 实际半径相对轨道半径的比例 |
| `dragOverlayAlpha` | `0.044` | 拖拽时的背景压暗 alpha |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `sliderColors(BuildContext context)` | `MiuixSliderColors` | 基于当前主题构造默认颜色配置 |

### MiuixVerticalSlider

Miuix 风格的垂直滑块，参数与 `MiuixSlider` 基本一致，方向为纵向。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `value` | `double` | 必填 | 当前值 |
| `onValueChanged` | `ValueChanged<double>?` | 必填 | 值变化回调，为 `null` 时禁用交互 |
| `enabled` | `bool` | `true` | 是否启用 |
| `min` | `double` | `0.0` | 最小值 |
| `max` | `double` | `1.0` | 最大值 |
| `steps` | `int` | `0` | 步进数（0 为连续） |
| `onValueChangeFinished` | `VoidCallback?` | `null` | 拖拽结束回调 |
| `reverseDirection` | `bool` | `false` | 是否反向 |
| `width` | `double` | `MiuixSliderDefaults.minHeight`（28） | 轨道宽度 |
| `colors` | `MiuixSliderColors?` | `null` | 颜色配置，默认取主题 |
| `effect` | `bool` | `false` | 保留参数（上游暂未启用任何视觉效果），维持 API 对齐 |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderHapticEffect.edge` | 触感反馈类型 |
| `showKeyPoints` | `bool` | `false` | 是否显示关键点 |
| `keyPoints` | `List<double>?` | `null` | 自定义关键点值列表 |
| `magnetThreshold` | `double` | `0.02` | 磁性吸附阈值 |

**示例：**
```dart
SizedBox(
  height: 200,
  child: MiuixVerticalSlider(
    value: volume,
    onValueChanged: (v) => setState(() => volume = v),
  ),
)
```

### MiuixRangeSlider

Miuix 风格的范围滑块，两个 thumb 分别控制起止值。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `startValue` | `double` | 必填 | 起始值 |
| `endValue` | `double` | 必填 | 结束值 |
| `onValueChanged` | `ValueChanged<(double, double)>?` | 必填 | 值变化回调（起, 止），为 `null` 时禁用交互 |
| `enabled` | `bool` | `true` | 是否启用 |
| `min` | `double` | `0.0` | 最小值 |
| `max` | `double` | `1.0` | 最大值 |
| `steps` | `int` | `0` | 步进数（0 为连续） |
| `onValueChangeFinished` | `VoidCallback?` | `null` | 拖拽结束回调 |
| `height` | `double` | `MiuixSliderDefaults.minHeight`（28） | 轨道高度 |
| `colors` | `MiuixSliderColors?` | `null` | 颜色配置，默认取主题 |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderHapticEffect.edge` | 触感反馈类型 |
| `showKeyPoints` | `bool` | `false` | 是否显示关键点 |
| `keyPoints` | `List<double>?` | `null` | 自定义关键点值列表 |
| `magnetThreshold` | `double` | `0.02` | 磁性吸附阈值 |

**示例：**
```dart
MiuixRangeSlider(
  startValue: lo,
  endValue: hi,
  onValueChanged: (r) => setState(() { lo = r.$1; hi = r.$2; }),
)
```

### MiuixSliderHapticEffect（枚举）

Slider 触感反馈类型。

| 枚举值 | 说明 |
|---|---|
| `none` | 无触感反馈 |
| `edge` | 在 0% 和 100% 端点触发 |
| `step` | 在步进点触发 |

### MiuixSearchBar

Miuix 风格的搜索栏容器，展开时显示尾部动作与结果内容，并拦截系统返回以先收起搜索栏。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `inputField` | `Widget` | 必填 | 输入框组件（通常为 `MiuixInputField`） |
| `onExpandedChange` | `ValueChanged<bool>` | 必填 | 展开状态变化回调 |
| `content` | `Widget` | 必填 | 展开后显示的结果内容 |
| `insideMargin` | `EdgeInsets` | `EdgeInsets.symmetric(horizontal: 12)` | 输入框内边距 |
| `expanded` | `bool` | `false` | 是否展开 |
| `outsideEndAction` | `Widget?` | `null` | 展开时显示在尾部的动作组件 |

**示例：**
```dart
MiuixSearchBar(
  expanded: expanded,
  onExpandedChange: (v) => setState(() => expanded = v),
  inputField: MiuixInputField(
    query: query,
    onQueryChange: (v) => setState(() => query = v),
    onSearch: (v) {},
    expanded: expanded,
    onExpandedChange: (v) => setState(() => expanded = v),
  ),
  content: const SizedBox(),
)
```

### MiuixSearchBarDefaults

SearchBar 默认值集合。私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| `insideMargin` | `EdgeInsets.symmetric(horizontal: 12)` | 输入框内边距 |
| `inputFieldMinHeight` | `45` | 输入框最小高度 |
| `inputFieldFontSize` | `17` | 输入框字号 |
| `leadingIconStartPadding` | `16` | 前置图标起始 padding |
| `leadingIconEndPadding` | `8` | 前置图标结束 padding |
| `trailingIconStartPadding` | `8` | 后置图标起始 padding |
| `trailingIconEndPadding` | `16` | 后置图标结束 padding |
| `visibilityDuration` | `Duration(milliseconds: 275)` | 展开/收起动画时长 |
| `textFadeDuration` | `Duration(milliseconds: 150)` | 文本淡入淡出时长 |

### MiuixInputField

Miuix 搜索输入框，配合 `MiuixSearchBar` 使用，提供搜索图标、清除按钮与占位标签。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `query` | `String` | 必填 | 当前查询文本 |
| `onQueryChange` | `ValueChanged<String>` | 必填 | 查询文本变化回调 |
| `onSearch` | `ValueChanged<String>` | 必填 | 提交搜索回调 |
| `expanded` | `bool` | 必填 | 是否展开（聚焦） |
| `onExpandedChange` | `ValueChanged<bool>` | 必填 | 展开状态变化回调 |
| `label` | `String` | `''` | 占位标签文字 |
| `enabled` | `bool` | `true` | 是否启用 |
| `textStyle` | `TextStyle?` | `null` | 文本样式 |
| `color` | `Color?` | `null` | 背景色，默认取主题 |
| `leadingIcon` | `Widget?` | `null` | 前置图标，默认为搜索图标 |
| `trailingIcon` | `Widget?` | `null` | 后置图标，`null` 时用带淡入淡出的默认清除按钮 |
| `focusNode` | `FocusNode?` | `null` | 焦点节点，未提供时内部自建 |

**示例：**
```dart
MiuixInputField(
  query: query,
  onQueryChange: (v) => setState(() => query = v),
  onSearch: (v) {},
  expanded: expanded,
  onExpandedChange: (v) => setState(() => expanded = v),
  label: '搜索',
)
```

### MiuixNumberPicker

Miuix 风格的垂直数字选择器，中心选中，远离中心的项渐隐缩小，支持循环与惯性 snap。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `value` | `int` | 必填 | 当前值 |
| `onValueChanged` | `ValueChanged<int>?` | 必填 | 值变化回调，为 `null` 时禁用交互 |
| `enabled` | `bool` | `true` | 是否启用 |
| `min` | `int` | `0` | 最小值 |
| `max` | `int` | `10` | 最大值 |
| `label` | `String Function(int)?` | `null` | 值到显示文本的映射，默认为 `value.toString()` |
| `visibleItemCount` | `int` | `5` | 可见项数（必须为奇数且 >= 3） |
| `wrapAround` | `bool` | `false` | 是否循环滚动 |
| `colors` | `MiuixNumberPickerColors?` | `null` | 颜色配置，默认取主题 |
| `textStyle` | `TextStyle?` | `null` | 文本样式，默认取主题 `title1` |
| `itemHeight` | `double` | `MiuixNumberPickerDefaults.itemHeight`（45） | 每项高度 |

**示例：**
```dart
MiuixNumberPicker(
  value: hour,
  min: 0,
  max: 23,
  onValueChanged: (v) => setState(() => hour = v),
)
```

### MiuixNumberPickerColors

NumberPicker 颜色配置。所有字段为必填。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `selectedTextColor` | `Color` | 必填 | 选中项文本色；`colors` 中取主题 `onSurface` |
| `unselectedTextColor` | `Color` | 必填 | 未选中项文本色；`colors` 中取 `onSurfaceSecondary` |
| `disabledSelectedTextColor` | `Color` | 必填 | 禁用时选中文本色；取 `disabledOnSecondary` |
| `disabledUnselectedTextColor` | `Color` | 必填 | 禁用时未选中文本色；取 `disabledOnSecondary` |

### MiuixNumberPickerDefaults

NumberPicker 默认值集合。私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| `itemHeight` | `45` | 每项高度 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `colors(BuildContext context)` | `MiuixNumberPickerColors` | 基于当前主题构造默认颜色配置 |

