## 基础设施 Foundation

本章涵盖 flutter_miuix 的底层基础设施：弹窗注册与过渡（[MiuixPopupController] / [MiuixPopupHost] / [MiuixPopupScope] / [MiuixDialogLayout] / [MiuixPopupLayout]）、Squircle 超椭圆圆角（[MiuixSquircleBorder] / `addSquircleRect`）、按压反馈（[MiuixPressable]）、内容色传递（[MiuixContentColor]）、弹簧与阻尼工具（[MiuixSpringEngine] / `obtainDampingDistance` 等）、运行时着色器封装（[MiuixRuntimeShader]）、滚动到边界触觉反馈（[MiuixScrollEndHaptic]）、矢量图标（[MiuixVectorIcon] / `miuixParsePath`）。

### 弹窗注册与过渡

#### MiuixPopupTransitionBuilder

弹窗内容过渡的构建器类型别名。`MiuixPopupTransition.builder` 即此类型；接收 `0..1` 的进度（0 表示完全隐藏，1 表示完全显示）、子节点，返回过渡后的 Widget。

**签名：**

```dart
typedef MiuixPopupTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);
```

| 参数 | 类型 | 说明 |
|---|---|---|
| `context` | `BuildContext` | 构建上下文 |
| `animation` | `Animation<double>` | 过渡进度，始终夹到 `0..1`；0=完全隐藏，1=完全显示 |
| `child` | `Widget` | 待过渡的子节点 |

#### MiuixPopupController

控制一个对话框或普通弹窗的显示状态。继承 `ChangeNotifier` 并实现 `ValueListenable<bool>`。

| 字段 / 方法 | 类型 | 说明 |
|---|---|---|
| `MiuixPopupController({visible = false})` | 构造 | 初始可见性，默认 false |
| `visible` | `bool` | 当前是否可见；setter 变化时通知监听者 |
| `value` | `bool` | `ValueListenable` 当前值，等同 `visible` |
| `visibleListenable` | `ValueListenable<bool>` | 返回 `this`，便于传给动画监听 |
| `show()` | `void` | 等同 `visible = true` |
| `dismiss()` | `void` | 等同 `visible = false` |
| `toggle()` | `void` | 等同 `visible = !visible` |

控制器可在布局组件重建时保持不变，也可直接监听 `visibleListenable`。

#### MiuixPopupTransition

描述一次进入或退出过渡。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `builder` | `MiuixPopupTransitionBuilder` | 必填 | 接收 `0..1` 进度、子节点，返回过渡 Widget |
| `duration` | `Duration` | 必填 | 非 spring 模式下的动画时长 |
| `curve` | `Curve` | `Curves.linear` | 非 spring 模式下的曲线 |
| `spring` | `SpringDescription?` | `null` | spring 模式；非空时优先用 spring 模拟 |
| `visibilityThreshold` | `double` | `0.0001` | spring 模拟的容差 |

`builder` 接收的进度始终被夹到 `0..1`；0 表示完全隐藏，1 表示完全显示。

**工厂 [MiuixPopupTransition.fade]**：只改变透明度的过渡。
```dart
MiuixPopupTransition.fade(
  duration: const Duration(milliseconds: 200),
  curve: Curves.easeOut,
)
```

#### MiuixPopupDefaults

默认过渡的定义（`MiuixPopupDefaults._()` 私有构造，全部为 `static final` 字段）。

| 字段 | 时长 / 曲线 | 用途 |
|---|---|---|
| `dialogDimEnter` | 300ms / decelerate | 对话框遮罩进入 |
| `dialogDimExit` | 250ms / decelerate | 对话框遮罩退出 |
| `popupDimEnter` | 300ms / sinOut | 普通弹窗遮罩进入 |
| `popupDimExit` | 150ms / sinOut | 普通弹窗遮罩退出 |
| `popupEnter` | 200ms / linear | 普通弹窗内容进入（淡入） |
| `popupExit` | 150ms / linear | 普通弹窗内容退出（淡出） |
| `largeDialogEnter` | 300ms / spring(stiffness=438.6, ratio=0.9) | 大屏对话框进入：淡入 + 0.8→1 缩放 |
| `largeDialogExit` | 200ms / decelerate | 大屏对话框退出：淡出 + 缩放至 0.8 |
| `smallDialogEnter` | 300ms / spring(stiffness=450, ratio=0.88) | 小屏对话框进入：从下方滑入 |
| `smallDialogExit` | 200ms / decelerate | 小屏对话框退出：向下方滑出 |

#### MiuixPopupEntry

注册表中的统一弹窗条目，继承 `ChangeNotifier`。通常无需手工创建；使用 [MiuixDialogLayout] 或 [MiuixPopupLayout] 注册。

| 字段 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `controller` | `MiuixPopupController` | 必填 | 控制器 |
| `content` | `WidgetBuilder` | 必填 | 内容构建器 |
| `enterTransition` / `exitTransition` | `MiuixPopupTransition?` | `null` | 自定义进/退场过渡；null 走默认 |
| `enableWindowDim` | `bool` | `true` | 是否启用窗口遮罩 |
| `dimEnterTransition` / `dimExitTransition` | `MiuixPopupTransition?` | `null` | 自定义遮罩过渡；null 走默认 |
| `zIndex` | `double` | 由 registry 分配 | 层级 |
| `orphaned` | `bool` | `false` | 是否已被宿主放弃所有权（见下） |
| `isDialog` | `bool` | （子类覆盖） | 是否对话框条目 |

**`orphaned` 机制**：为 `true` 时，`_MiuixHostedEntry` 在退出动画结束、entry 从 registry 移除后负责 dispose 本 entry；为 `false` 时 entry 仍由宿主持有，HostedEntry 不得 dispose，否则宿主再次 show 对话框时会向已 dispose 的 `ChangeNotifier` `addListener`，抛 use-after-dispose。

#### MiuixDialogEntry

对话框条目，继承 [MiuixPopupEntry]。

| 额外参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `enableAutoLargeScreen` | `bool` | `true` | 是否自动按大/小屏切换进退场过渡 |
| `dimAlpha` | `ValueListenable<double>?` | `null` | 遮罩 alpha 联动（如随滚动透明度变化） |
| `onDismissFinished` | `VoidCallback?` | `null` | 退出动画结束回调 |

`isDialog` 恒为 `true`。

#### MiuixPlainPopupEntry

普通弹窗条目，继承 [MiuixPopupEntry]。

| 额外参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `enableBackHandler` | `bool` | `true` | 是否拦截返回键（仅最上层生效） |

`isDialog` 恒为 `false`。

#### MiuixPopupRegistry

保存某一挂载层中的对话框与普通弹窗，并按注册顺序分配 z-order。继承 `ChangeNotifier`。

| 字段 / 方法 | 类型 | 说明 |
|---|---|---|
| `MiuixPopupRegistry.fallback` | `static` | 未安装 [MiuixPopupScope] 时使用的进程级后备注册表 |
| `dialogs` | `List<MiuixDialogEntry>` | 对话框条目（不可修改视图） |
| `popups` | `List<MiuixPlainPopupEntry>` | 普通弹窗条目（不可修改视图） |
| `isEmpty` | `bool` | 是否为空 |
| `entries` | `Iterable<MiuixPopupEntry>` | 全部条目（dialogs 在前，popups 在后） |
| `contains(entry)` | `bool` | 是否包含某条目 |
| `add(entry)` | `void` | 添加并分配 zIndex；自动监听 controller/entry 变化 |
| `remove(entry)` | `void` | 移除并解除监听；空时重置 zIndex |

#### MiuixPopupScope

为子树提供 local/root 两级弹窗注册表的 [InheritedWidget]。每个 Scope 都有自己的 local 注册表；嵌套 Scope 默认继承最外层 root，`establishRoot` 可显式建立新的 root 边界。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `child` | `Widget` | 必填 | 子树 |
| `registry` | `MiuixPopupRegistry?` | `null` | 自定义 local 注册表；null 时使用内部新建的 |
| `establishRoot` | `bool` | `false` | 是否建立新的 root 边界 |

| 静态方法 | 返回 | 说明 |
|---|---|---|
| `of(context, {root = false})` | `MiuixPopupRegistry` | 取当前 Scope 的 local 或 root；未包裹返回 `fallback` |
| `maybeOf(context, {root = false})` | `MiuixPopupRegistry?` | 同上，但未包裹返回 null |

#### MiuixDialogLayout

在当前 Scope 中注册一个对话框；自身不绘制任何内容（`build` 返回 `SizedBox.shrink()`）。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `controller` | `MiuixPopupController` | 必填 | 控制器 |
| `content` | `WidgetBuilder?` | 必填 | 内容构建器；为 null 时不显示，且会自动 dismiss 已显示的 |
| `enterTransition` / `exitTransition` | `MiuixPopupTransition?` | `null` | 自定义进/退场过渡 |
| `enableWindowDim` | `bool` | `true` | 是否启用遮罩 |
| `enableAutoLargeScreen` | `bool` | `true` | 是否按大/小屏切换过渡 |
| `dimEnterTransition` / `dimExitTransition` | `MiuixPopupTransition?` | `null` | 自定义遮罩过渡 |
| `dimAlpha` | `ValueListenable<double>?` | `null` | 遮罩 alpha 联动 |
| `onDismissFinished` | `VoidCallback?` | `null` | 退出动画结束回调 |
| `renderInRoot` | `bool` | `true` | 是否注册到 root 注册表（true）或 local（false） |

#### MiuixPopupLayout

在当前 Scope 中注册一个普通弹窗；自身不绘制任何内容。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `controller` | `MiuixPopupController` | 必填 | 控制器 |
| `content` | `WidgetBuilder?` | 必填 | 内容构建器；为 null 时不显示 |
| `enterTransition` / `exitTransition` | `MiuixPopupTransition?` | `null` | 自定义进/退场过渡 |
| `enableWindowDim` | `bool` | `true` | 是否启用遮罩 |
| `enableBackHandler` | `bool` | `true` | 是否拦截返回键 |
| `dimEnterTransition` / `dimExitTransition` | `MiuixPopupTransition?` | `null` | 自定义遮罩过渡 |
| `renderInRoot` | `bool` | `true` | 是否注册到 root 注册表 |

#### MiuixPopupHost

绘制注册表中的所有条目，拦截下层指针，并处理最上层普通弹窗的返回键。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `child` | `Widget?` | `null` | 下层内容；非空时 Host 直接作为 Stack 包装器 |
| `registry` | `MiuixPopupRegistry?` | `null` | 指定注册表；null 时取 `MiuixPopupScope.of(context)` |
| `windowDimmingColor` | `Color` | `Color(0x4D000000)` | 默认遮罩色 |

**返回键处理**：通过 `PopScope` 拦截系统返回。`canPop` 仅当存在可见且 `enableBackHandler=true` 的 popup 时为 `false`；触发返回时调用最上层 popup 的 `controller.dismiss()`。

**典型用法**（应用根部）：
```dart
MiuixPopupHost(
  child: MaterialApp(home: MyApp()),
)
```

#### MiuixPopupUtils

静态工具类式的便捷入口（`MiuixPopupUtils._()` 私有构造，仅暴露 `static` 方法）。

| 方法 | 等价于 |
|---|---|
| `MiuixPopupUtils.dialogLayout({...})` | `MiuixDialogLayout(...)` |
| `MiuixPopupUtils.popupLayout({...})` | `MiuixPopupLayout(...)` |

#### `isMiuixLargeScreen(context)` → `bool`

判断当前逻辑窗口是否满足 Miuix 大屏阈值：**宽 ≥ 840 且 高 ≥ 480**。

### Squircle 超椭圆圆角

HyperOS 标志性的平滑圆角，用三次贝塞尔（控制比例 `0.643`）逼近超椭圆。源自 compose-miuix-ui/miuix-squircle 的 `SquirclePath.kt`。

#### SquircleDefaults

| 常量 | 值 | 说明 |
|---|---|---|
| `extension` | `1.1` | 圆角瓦片尺寸相对 `cornerRadius` 的倍数；1.0=圆弧，1.1=连续圆角 |
| `extensionMin` | `1.0` | `extension` 下限 |
| `extensionMax` | `2.0` | `extension` 上限 |

#### `addSquircleRect(path, width, height, cornerRadius, {extension, enabled})`

向 [path] 追加一个 squircle 圆角矩形。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `path` | `Path` | 必填 | 目标 Path |
| `width` / `height` | `double` | 必填 | 像素尺寸；非正则不追加 |
| `cornerRadius` | `double` | 必填 | 圆角半径；自动夹到短边一半 |
| `extension` | `double` | `SquircleDefaults.extension` | 圆角瓦片倍数；夹到 `[1.0, 2.0]` |
| `enabled` | `bool` | `true` | false 时退化为普通圆角矩形 |

#### MiuixSquircleBorder

一个 [ShapeBorder]，轮廓为 squircle。可直接用于 `ShapeDecoration`、`PhysicalShape`、`Material` 等。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `cornerRadius` | `double` | `0.0` | 圆角半径（逻辑像素） |
| `extension` | `double` | `SquircleDefaults.extension`（1.1） | 圆角瓦片倍数 |
| `enabled` | `bool` | `true` | 是否启用 squircle；false 退化为普通圆角 |
| `side` | `BorderSide` | `BorderSide.none` | 边框 |

实现了 `dimensions`、`getInnerPath`、`getOuterPath`、`paint`、`scale`、`==`、`hashCode`，可作为 `ShapeDecoration.shape` 直接使用。

**示例：**
```dart
Container(
  width: 80, height: 80,
  decoration: ShapeDecoration(
    color: Colors.blue,
    shape: MiuixSquircleBorder(cornerRadius: 24),
  ),
)
```

### MiuixPressable

Miuix 风格的可按压容器。在子节点之上叠加一层半透明遮罩，按下/悬停/聚焦时通过 spring 驱动 alpha 变化，可选叠加 sink（下沉缩放）或 tilt（3D 倾斜）反馈。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `onPressed` | `VoidCallback?` | 必填 | 点击回调；为 null 时 `enabled` 视为 false |
| `child` | `Widget` | 必填 | 子节点 |
| `enabled` | `bool` | `true` | 是否启用 |
| `feedbackType` | `MiuixPressFeedbackType` | `none` | 额外反馈类型 |
| `sinkAmount` | `double` | `0.94` | sink 反馈的缩放目标 |
| `tiltAmount` | `double` | `8.0` | tilt 反馈的最大倾角（度） |
| `overlayColor` | `Color?` | `null` | 遮罩颜色；null 取 `MiuixTheme.colors.onBackground` |
| `borderRadius` | `BorderRadius?` | `null` | 遮罩圆角；与 `shape` 二选一 |
| `shape` | `ShapeBorder?` | `null` | 遮罩形状（如 squircle/stadium）；优先于 `borderRadius` |
| `heldDown` | `bool` | `false` | 外部强制"按下保持"状态（Preference、菜单项用） |
| `autofocus` | `bool` | `false` | 是否自动获取焦点 |
| `focusNode` | `FocusNode?` | `null` | 外部焦点节点 |
| `semanticLabel` | `String?` | `null` | 无障碍标签 |
| `button` | `bool` | `true` | 是否标记为按钮语义（Checkbox/Switch 等可置 false） |
| `behavior` | `HitTestBehavior` | `opaque` | 点击测试行为 |
| `onLongPress` | `VoidCallback?` | `null` | 长按回调 |

#### MiuixPressFeedbackType

按压视觉反馈类型。

| 值 | 说明 |
|---|---|
| `none` | 无反馈（仅按压遮罩） |
| `sink` | 按下时轻微下沉缩放 |
| `tilt` | 按下时根据触点位置倾斜（3D） |

**遮罩 alpha 增量**：hover `+0.06`，focus `+0.08`，press `+0.10`，可叠加。

**示例：**
```dart
MiuixPressable(
  onPressed: () {},
  feedbackType: MiuixPressFeedbackType.sink,
  shape: MiuixSquircleBorder(cornerRadius: 16),
  child: const Padding(
    padding: EdgeInsets.all(16),
    child: Text('Press me'),
  ),
)
```

### MiuixContentColor

向子树传递一个默认的"内容色"（文字/图标色）。由 `MiuixSurface` / `MiuixCard` / `MiuixButton` 等容器向下传递，供 `MiuixText` / `MiuixIcon` 等子组件默认取色。

| 参数 / 方法 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `color` | `Color` | 必填 | 内容色 |
| `child` | `Widget` | 必填 | 子树 |
| `MiuixContentColor.of(context)` | `Color` | — | 取最近祖先的内容色；未包裹返回黑色 |

### 弹簧与阻尼工具

Folme 弹簧动效的底层数学与逐帧引擎。

#### MiuixSpringDefaults

| 常量 | 值 | 说明 |
|---|---|---|
| `maxFrameDeltaSeconds` | `0.016` | 单帧最大步长（秒） |
| `minFrameDeltaSeconds` | `0.001` | 单帧最小步长（秒） |
| `highVelocityThreshold` | `5000.0` | 高初速度阈值，超过后使用较慢自然周期 |
| `criticalDampingRatio` | `1.0` | 临界阻尼比 |
| `standardSpringPeriod` | `0.4` | 标准自然周期（秒） |
| `slowerSpringPeriodForHighVelocity` | `0.55` | 高速时使用的自然周期（秒） |

#### `obtainDampingDistance(normalizedInput, range)` → `double`

阻尼公式为 `x - x² + x³/3`；`normalizedInput` 先夹取到 `0..1`，乘 `range` 得阻尼位移。

#### `obtainTouchDistance(currentPixelOffset, range)` → `double`

把阻尼位移还原为触摸位移。还原公式为 `range - range^(2/3) * (range - 3*offset)^(1/3)`。

#### MiuixSpringOperator

以显式欧拉法计算下一帧速度。

| 参数 | 说明 |
|---|---|
| `dampingRatio` | 阻尼比 |
| `naturalPeriod` | 自然周期（秒，>0） |

`updateVelocity({currentVelocity, deltaTime, currentPosition, targetPosition})` 返回新速度。

#### MiuixSpringEngine

临界阻尼逐帧引擎。可手动 `start`/`step`，也可通过 `runSettleAnimation` 用 Flutter `Ticker` 驱动。

| 方法 | 说明 |
|---|---|
| `start({startValue, targetValue, initialVelocity})` | 初始化一次从 `startValue` 到 `targetValue` 的弹簧运动；按初速度大小自动选 `standard`/`slower` 周期 |
| `step(deltaTime)` → `bool` | 推进一帧；返回 true 表示已到达平衡 |
| `runSettleAnimation({vsync, startValue, targetValue = 0, initialVelocity, onFrame, onSettle})` → `Future<void>` | 用 `Ticker` 驱动到平衡，每帧调用 `onFrame(currentPosition)`；正常结束或取消都会调用 `onSettle` |

字段 `velocity` 与 `currentPosition` 暴露当前状态。

### 运行时着色器封装

#### `isRenderEffectSupported()` → `bool`

恒为 `true`。Flutter 的 `ImageFilter` / `BackdropFilter` 在所有目标平台都可用。

#### `isRuntimeShaderSupported()` → `bool`

恒为 `true`。Flutter 的 `FragmentProgram` 在 Impeller/Skia 上均可用。

#### MiuixRuntimeShader

运行时着色器的跨平台封装。

Flutter 的 `FragmentShader` 只能由**预编译的 `.frag` 资源**（经 impellerc）产生，uniform 按**下标**设置（`setFloat(index, value)`）。本封装通过 `uniformLayout`（uniform 名 → 起始 float 下标）把名字翻译成下标，从而支持"按名设 uniform"的调用风格。

| 参数 / 字段 | 类型 | 说明 |
|---|---|---|
| `MiuixRuntimeShader.fromProgram(program, {uniformLayout, samplerLayout})` | 构造 | 用已加载的 `FragmentProgram` 构造 |
| `shader` | `ui.FragmentShader` | 底层着色器，可直接作为 `ui.Shader` 用于 `Paint..shader` |
| `uniformLayout` | `Map<String, int>` | uniform 名 → 起始 float 下标 |
| `samplerLayout` | `Map<String, int>` | sampler 名 → sampler 下标 |

| 方法 | 说明 |
|---|---|
| `setFloatUniform(name, value)` | 设置单个 float uniform |
| `setFloat2Uniform(name, v1, v2)` | 设置 vec2 uniform |
| `setFloat3Uniform(name, v1, v2, v3)` | 设置 vec3 uniform |
| `setFloat4Uniform(name, v1, v2, v3, v4)` | 设置 vec4 uniform |
| `setFloatArrayUniform(name, values)` | 设置 float 数组 uniform |
| `setColorUniform(name, color)` | 设置颜色 uniform（RGBA 0..1） |
| `setInputShader(name, image)` | 设置采样器（传 `ui.Image`） |
| `dispose()` | 释放底层 `FragmentShader` |

未在 `uniformLayout` / `samplerLayout` 登记的名字会抛 `ArgumentError`。

### MiuixScrollEndHaptic

当可滚动内容被**惯性甩到**起始/末尾边界时触发一次触觉反馈。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `hapticFeedbackType` | `MiuixHapticFeedbackType` | `textHandleMove` | 触觉类型 |
| `child` | `Widget` | 必填 | 含可滚动子组件的子树 |

#### MiuixHapticFeedbackType

| 值 | 说明 | Flutter 映射 |
|---|---|---|
| `textHandleMove` | 轻微选择反馈（默认，对应 Android `TextHandleMove`） | `HapticFeedback.selectionClick` |
| `lightImpact` | 轻碰 | `HapticFeedback.lightImpact` |
| `mediumImpact` | 中等碰撞 | `HapticFeedback.mediumImpact` |
| `heavyImpact` | 重碰撞 | `HapticFeedback.heavyImpact` |

**状态机**：从边界往内容方向滚动时（`scrollDelta` 超过 `1.0`）复位状态；仅处理惯性甩动越界（`OverscrollNotification` 且 `dragDetails == null`），拖拽越界不触发；每次触边只触发一次，避免连续抖动。

**示例：**
```dart
MiuixScrollEndHaptic(
  child: ListView(children: [...]),
)
```

### 矢量图标

#### MiuixVectorPath

单条矢量路径的绘制描述。

| 参数 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `build` | `Path Function()` | 必填 | 构造路径（视口坐标系）；用回调以避免共享可变 Path |
| `style` | `PaintingStyle` | `fill` | 填充或描边 |
| `color` | `Color` | `Color(0xFF000000)` | 矢量原始颜色（`SolidColor`）；仅未 tint 时使用 |
| `alpha` | `double` | `1.0` | 不透明度（对应 `fillAlpha` / `strokeAlpha`） |
| `strokeWidth` | `double` | `0.0` | 描边宽度（0 表示 1px 发丝线） |
| `strokeCap` | `StrokeCap` | `butt` | 描边线帽 |
| `groupTransform` | `Matrix4?` | `null` | 视口坐标系下的组变换（如纵向翻转） |

#### MiuixVectorIcon

矢量图标。

| 参数 | 类型 | 说明 |
|---|---|---|
| `name` | `String` | 图标名（用于调试与语义回退） |
| `viewport` | `Size` | 路径坐标所在的视口尺寸（`viewportWidth/Height`） |
| `intrinsicSize` | `Size` | 默认渲染尺寸（`defaultWidth/Height`，逻辑像素）；当 [MiuixIcon] 未显式指定 size 时按此渲染 |
| `paths` | `List<MiuixVectorPath>` | 组成该图标的所有路径（按绘制顺序） |

#### MiuixVectorIconPainter

将 [MiuixVectorIcon] 绘制到**视口尺寸**画布上的 `CustomPainter`；外层缩放交给 `FittedBox`。

| 参数 | 类型 | 说明 |
|---|---|---|
| `icon` | `MiuixVectorIcon` | 矢量图标 |
| `tint` | `Color?` | 上色色；非空时以 `ColorFilter.mode(tint, BlendMode.srcIn)` 对整幅矢量上色；为空时按矢量原始颜色绘制（多色/不上色场景） |

#### `miuixEvenOddPath()` → `Path`

构造一个带偶数-奇数填充规则的空 [Path]。便于图标定义处链式 `..moveTo(...)`。

#### `miuixParsePath(data, {fillType})` → `Path`

从 SVG 风格的路径数据字符串解析出 [Path]。用于扩展图标（miuix-icons，156×5 个变体）。

支持的命令（**仅绝对坐标**）：

| 命令 | 含义 | 参数 |
|---|---|---|
| `M x y` | 移动 | 2 |
| `L x y` | 直线 | 2 |
| `Q x1 y1 x y` | 二次贝塞尔 | 4 |
| `C x1 y1 x2 y2 x y` | 三次贝塞尔 | 6 |
| `Z` | 闭合 | 0 |

数字以空白分隔，命令字母单独成 token。`fillType` 默认 `nonZero`。

> `HorizontalTo` / `VerticalTo` 在生成阶段已被展开为完整的 `L x y`，因此无需处理 H/V。
