## 按钮与显示 Buttons & Display

### MiuixButton

Miuix 风格的按钮，默认次级配色，可点击并带按压遮罩。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| onPressed | VoidCallback? | 必填 | 点击回调，为 null 时视为禁用 |
| child | Widget | 必填 | 按钮内容 |
| enabled | bool | true | 是否启用 |
| cornerRadius | double | 16 | squircle 圆角半径 |
| minWidth | double | 58 | 最小宽度 |
| minHeight | double | 40 | 最小高度 |
| colors | MiuixButtonColors? | null（默认 `MiuixButtonDefaults.buttonColors`，次级色） | 颜色配置 |
| insideMargin | EdgeInsetsGeometry | `EdgeInsets.symmetric(horizontal: 16, vertical: 13)` | 内边距 |

**示例：**
```dart
MiuixButton(
  onPressed: () {},
  child: const MiuixText('确定'),
)
```

### MiuixTextButton

文本按钮，内部构建一个 `MiuixButton` 并居中放置文字。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| text | String | 必填（位置参数） | 按钮文字 |
| onPressed | VoidCallback? | 必填 | 点击回调，为 null 时视为禁用 |
| enabled | bool | true | 是否启用 |
| cornerRadius | double | 16 | squircle 圆角半径 |
| minWidth | double | 58 | 最小宽度 |
| minHeight | double | 40 | 最小高度 |
| colors | MiuixButtonColors? | null（默认次级色） | 颜色配置 |
| insideMargin | EdgeInsetsGeometry | `EdgeInsets.symmetric(horizontal: 16, vertical: 13)` | 内边距 |
| textStyle | TextStyle? | null（默认 `textStyles.button`） | 文字样式 |

**示例：**
```dart
MiuixTextButton('取消', onPressed: () {})
```

### MiuixButtonColors

按钮颜色配置，四个字段均为必填。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| color | Color | 必填 | 容器背景色 |
| disabledColor | Color | 必填 | 禁用时容器背景色 |
| contentColor | Color | 必填 | 内容色 |
| disabledContentColor | Color | 必填 | 禁用时内容色 |

**示例：**
```dart
const MiuixButtonColors(
  color: Colors.blue,
  disabledColor: Colors.blueGrey,
  contentColor: Colors.white,
  disabledContentColor: Colors.white70,
)
```

### MiuixButtonDefaults

私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| minWidth | `58` | 最小宽度 |
| minHeight | `40` | 最小高度 |
| cornerRadius | `16` | squircle 圆角半径 |
| insideMargin | `EdgeInsets.symmetric(horizontal: 16, vertical: 13)` | 内边距 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| buttonColors(BuildContext) | `MiuixButtonColors` | 默认次级按钮颜色 |
| buttonColorsPrimary(BuildContext) | `MiuixButtonColors` | 主色按钮颜色 |

### MiuixIconButton

Miuix 风格的图标按钮，默认圆形（直径 40），背景透明。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| onPressed | VoidCallback? | 必填 | 点击回调，为 null 时视为禁用 |
| child | Widget | 必填 | 图标内容 |
| enabled | bool | true | 是否启用 |
| backgroundColor | Color? | null | 背景色，null 表示透明 |
| cornerRadius | double | 40 | 圆角半径（默认圆形） |
| minHeight | double | 40 | 最小高度 |
| minWidth | double | 40 | 最小宽度 |
| holdDownState | bool | false | 强制按住视觉态（如下拉菜单展开期间） |

**示例：**
```dart
MiuixIconButton(
  onPressed: () {},
  child: MiuixIcon(vector: MiuixIcons.extended.byName('settings')!),
)
```

### MiuixIconButtonDefaults

私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| minWidth | `40` | 最小宽度 |
| minHeight | `40` | 最小高度 |
| cornerRadius | `40` | 圆角半径（圆形，直径 40） |

### MiuixFloatingActionButton

Miuix 风格的浮动操作按钮，圆形背景加阴影，内容色默认继承 `onSurface`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| onPressed | VoidCallback? | 必填 | 点击回调，为 null 时视为禁用 |
| child | Widget | 必填 | 子节点 |
| enabled | bool | true | 是否启用 |
| shape | ShapeBorder | `StadiumBorder()` | 形状 |
| containerColor | Color? | null（默认 `colors.primary`） | 容器背景色 |
| shadowElevation | double | 4 | 阴影高度（逻辑像素） |
| minWidth | double | 60 | 最小宽度 |
| minHeight | double | 60 | 最小高度 |

**示例：**
```dart
MiuixFloatingActionButton(
  onPressed: () {},
  child: MiuixIcon(vector: MiuixIcons.extended.byName('add')!),
)
```

### MiuixFloatingActionButtonDefaults

私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| minWidth | `60` | 默认最小宽度 |
| minHeight | `60` | 默认最小高度 |
| shadowElevation | `4` | 默认阴影高度 |
| shape | `StadiumBorder()` | 默认形状；正方形 bounds 下为正圆，矩形下为胶囊 |

### MiuixCard

Miuix 风格的卡片，squircle 圆角，向下传递内容色，可选点击与按压反馈。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| cornerRadius | double | 16 | 圆角半径 |
| insideMargin | EdgeInsetsGeometry | `EdgeInsets.zero` | 内边距 |
| colors | MiuixCardColors? | null（默认 surfaceContainer / onSurfaceContainer） | 颜色配置 |
| onPressed | VoidCallback? | null | 点击回调 |
| onLongPress | VoidCallback? | null | 长按回调 |
| feedbackType | MiuixPressFeedbackType | `MiuixPressFeedbackType.none` | 按压反馈类型（none / sink / tilt） |
| child | Widget? | null | 子节点 |

**示例：**
```dart
const MiuixCard(
  insideMargin: EdgeInsets.all(16),
  child: MiuixText('卡片内容'),
)
```

### MiuixCardColors

卡片颜色配置，两个字段均为必填。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| color | Color | 必填 | 容器背景色 |
| contentColor | Color | 必填 | 内容色 |

**示例：**
```dart
const MiuixCardColors(
  color: Colors.white,
  contentColor: Colors.black,
)
```

### MiuixCardDefaults

私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| cornerRadius | `16` | 默认圆角半径 |
| insideMargin | `EdgeInsets.zero` | 默认内边距 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| defaultColors(BuildContext) | `MiuixCardColors` | 默认颜色：surfaceContainer / onSurfaceContainer |

### MiuixSurface

Miuix 风格的 Surface，提供背景色、内容色、边框、阴影，并向下传递内容色。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| color | Color? | null（默认 `colors.surface`） | 背景色 |
| contentColor | Color? | null（默认 `colors.onSurface`） | 内容色 |
| cornerRadius | double | 0 | 圆角半径，0 表示直角 |
| squircleEnabled | bool | true | 是否启用 squircle 圆角 |
| border | Border? | null | 边框 |
| shadowElevation | double | 0 | 阴影高度（逻辑像素） |
| onPressed | VoidCallback? | null | 点击回调，非 null 时可点击 |
| enabled | bool | true | 是否启用点击 |
| child | Widget | 必填 | 子节点 |

**示例：**
```dart
const MiuixSurface(
  cornerRadius: 12,
  child: MiuixText('表面内容'),
)
```

### MiuixBadge

Miuix 风格的徽标。`child` 为 null 时绘制 6×6 圆点，否则为至少 16×16 的胶囊。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| containerColor | Color? | null（默认 `colors.error`） | 容器背景色 |
| contentColor | Color? | null（默认 `colors.onError`） | 内容色 |
| child | Widget? | null | 内容，为 null 时显示圆点 |

**示例：**
```dart
const MiuixBadge(child: MiuixText('9'))
```

### MiuixBadgeDefaults

私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| size | `6` | 无内容圆点徽标的默认尺寸 |
| largeSize | `16` | 含内容徽标的默认最小尺寸 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| containerColor(BuildContext) | `Color` | 默认容器色，对应主题的 `error` |
| contentColor(BuildContext) | `Color` | 默认内容色，对应主题的 `onError` |

### MiuixBadgedBox

将徽标放置在锚点右上角的容器，组件尺寸由 `child` 决定，放置随 RTL 镜像。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| badge | Widget | 必填 | 徽标（通常为 `MiuixBadge`） |
| child | Widget | 必填 | 锚点子节点 |
| topBound | double? | null | 顶部夹取边界，默认不夹取 |
| endBound | double? | null | 结束方向夹取边界，默认不夹取 |

**示例：**
```dart
MiuixBadgedBox(
  badge: const MiuixBadge(),
  child: MiuixIcon(vector: MiuixIcons.extended.byName('messages')!),
)
```

### MiuixHorizontalDivider

水平分隔线，宽度撑满，默认厚度 0.75。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| thickness | double | 0.75 | 线条厚度 |
| color | Color? | null（默认 `colors.dividerLine`） | 线条颜色 |

**示例：**
```dart
const MiuixHorizontalDivider()
```

### MiuixVerticalDivider

垂直分隔线，高度撑满，默认厚度 0.75。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| thickness | double | 0.75 | 线条厚度 |
| color | Color? | null（默认 `colors.dividerLine`） | 线条颜色 |

**示例：**
```dart
const SizedBox(height: 24, child: MiuixVerticalDivider())
```

### MiuixDividerDefaults

私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| thickness | `0.75` | 默认厚度 0.75dp |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| dividerColor(BuildContext) | `Color` | 默认颜色，取自 `MiuixTheme.colors.dividerLine` |

### MiuixSmallTitle

小标题，使用 `subtitle` 样式（14sp 加粗），默认色 `onBackgroundVariant`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| text | String | 必填（位置参数） | 标题文字 |
| textColor | Color? | null（默认 `colors.onBackgroundVariant`） | 文字颜色 |
| insideMargin | EdgeInsetsGeometry | `EdgeInsets.symmetric(horizontal: 28, vertical: 8)` | 内边距 |

**示例：**
```dart
const MiuixSmallTitle('分组标题')
```

### MiuixBasicComponent

Miuix 基础行组件，广泛用于扩展组件；内部用自定义 RenderBox 复刻 start/center/end 的 2:5:3 测量约束。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| title | String? | null | 标题文字 |
| titleColor | MiuixBasicComponentColors? | null（默认 `titleColor`） | 标题颜色配置 |
| summary | String? | null | 摘要文字 |
| summaryColor | MiuixBasicComponentColors? | null（默认 `summaryColor`） | 摘要颜色配置 |
| startAction | Widget? | null | 起始操作项 |
| endActions | List\<Widget\>? | null | 结束操作项列表 |
| bottomAction | Widget? | null | 底部操作项 |
| insideMargin | EdgeInsetsGeometry | `EdgeInsets.all(16)` | 内边距 |
| onClick | VoidCallback? | null | 点击回调 |
| onClickLabel | String? | null | 无障碍点击标签 |
| role | MiuixBasicComponentRole? | null | 无障碍角色（button / checkbox / radioButton / switchControl / tab / dropdownList） |
| holdDownState | bool | false | 强制按住视觉态 |
| enabled | bool | true | 是否启用 |
| content | List\<Widget\>? | null | 自定义中心内容，为 null 时由 title/summary 构建 |

**示例：**
```dart
MiuixBasicComponent(
  title: '标题',
  summary: '摘要',
  onClick: () {},
)
```

### MiuixBasicComponentRole

BasicComponent 的无障碍角色枚举。

| 值 | 说明 |
|---|---|
| button | 按钮 |
| checkbox | 复选框 |
| radioButton | 单选按钮 |
| switchControl | 开关 |
| tab | 选项卡 |
| dropdownList | 下拉列表 |

### MiuixBasicComponentColors

BasicComponent 颜色配置，两个字段均为必填。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| color | Color | 必填 | 启用时颜色 |
| disabledColor | Color | 必填 | 禁用时颜色 |

**示例：**
```dart
const MiuixBasicComponentColors(
  color: Colors.black,
  disabledColor: Colors.grey,
)
```

### MiuixBasicComponentDefaults

私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| insideMargin | `EdgeInsets.all(16)` | 组件四周默认内边距，均为 16 逻辑像素 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| titleColor(BuildContext) | `MiuixBasicComponentColors` | 标题默认颜色 |
| summaryColor(BuildContext) | `MiuixBasicComponentColors` | 摘要默认颜色 |

### MiuixText

Miuix 风格的文本，默认样式 `textStyles.main`，颜色取自 `MiuixContentColor`。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| text | String | 必填（位置参数） | 文本内容 |
| color | Color? | null（默认取内容色，显式 color 优先级最高） | 文字颜色 |
| fontSize | double? | null | 字号 |
| fontWeight | FontWeight? | null | 字重 |
| fontFamily | String? | null | 字体 |
| letterSpacing | double? | null | 字间距 |
| fontStyle | FontStyle? | null | 字体样式 |
| decoration | TextDecoration? | null | 文本装饰 |
| textAlign | TextAlign? | null | 对齐方式 |
| height | double? | null | 行高 |
| maxLines | int? | null | 最大行数 |
| overflow | TextOverflow? | null | 溢出处理 |
| softWrap | bool | true | 是否自动换行 |
| style | TextStyle? | null（默认 `textStyles.main`） | 基础样式 |

**示例：**
```dart
const MiuixText('你好，Miuix')
```

### MiuixIcon

Miuix 风格的图标。`icon` / `vector` / `child` 三选一；单色图标通过 `tint` 上色。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| icon | IconData? | null | Material 图标数据 |
| vector | MiuixVectorIcon? | null | Miuix 内置矢量图标 |
| child | Widget? | null | 自定义图标 Widget（多色图标等） |
| tint | Color? | null（默认取内容色；传 `kMiuixTintUnspecified` 时不上色） | 上色颜色 |
| contentDescription | String? | null | 无障碍描述，为 null 时不包裹 Semantics |
| size | double? | null（`icon` 路径回退到 24） | 图标尺寸 |

**示例：**
```dart
MiuixIcon(vector: MiuixIcons.extended.byName('favoritesFill')!, size: 24)
```

### MiuixIconDefaults

私有构造，仅 `static` 字段/方法。

| 常量 | 值 | 说明 |
|---|---|---|
| defaultSize | `24` | 默认图标尺寸（逻辑像素） |

