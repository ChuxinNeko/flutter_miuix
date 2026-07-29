# Changelog

## 未发布

### 变更

- **TopAppBar 标题折叠过渡对齐 Compose 原版（双层淡出/弹入，替代字号连续插值）**：此前的折叠动画是自创的关键帧插值（`TextStyle.lerp` 把字号从 32 连续缩到 20、位置从左侧滑向居中），与原版 `TopAppBarLayout` 的视觉不一致。现改为严格复刻原版算法：大标题固定 32sp，住在折叠带下方的独立裁剪层里随折叠偏移上移并在带下缘被裁掉，从第一个折叠像素开始淡出（`alpha = 1 - collapsedFraction * 3`，原版公式），折叠 1/3 处完全消失；小标题（及小副标题）在 1/3 阈值处翻转，以弹簧曲线淡入 + 上浮 20px 出现（show 300ms / hide 150ms，对应原版 folme 弹簧规格），首次构建按当前状态直接定位不重播淡入。
- **重新引入松手吸附（不复现早期解耦回归）**：对应原版 `settleAppBar` 的 snap 段——松手停在折叠过渡区中段时吸附到全展开/全折叠的近端（fraction 0.5 分界）。与 1.0.2–1.0.8 旧实现的关键区别：吸附动画的对象是**列表滚动位置**而非 `heightOffset`，折叠量始终是位置的纯函数，不会重新引入"吸附后 offset 与 pixels 解耦、中部微下滑弹回大标题"的历史回归（1.0.9 因此删掉的 snap 得以安全回归）。可用 `snapOnRelease: false` 关闭。新增回归测试 `test/top_app_bar_release_snap_test.dart`。
- **边界场景加固**：短页面（可滚行程不足以靠滚动位置驻留折叠态）走专用路径，回弹期冻结、松手按 0.5 阈值吸附，消除"回弹 + 闪烁"；底部越界回弹期间冻结标题，避免松手后标题被拉回展开；`heightOffsetLimit` 忽略父级重建造成的瞬时零值（SmallTopAppBar 钉住改用新增的 `TopAppBarState.pin()`）；`contentOffset` 仅记账不通知，`heightOffset` 在布局阶段变更时延迟到帧末通知，其余阶段立即通知。
- **可选增强 `lockSmallTitleUntilTop`（默认关闭，不改变原版语义）**：开启后标题折叠即锁定小标题，惯性滚动碰巧到顶不解锁，只有新手势才重新展开，避免阅读中标题意外来回切换。

## 1.0.9

### 修复

- **大标题折叠后稍微下滑立即弹回大标题（1.0.8 门控仍未根治）**：`ExitUntilCollapsedScrollBehavior` 此前把 `heightOffset` 当成独立累加量（逐 delta 门控增减），并在松手时用弹簧 `snap` 吸到端点。`snap` 会把 `heightOffset` 拉到完全折叠/展开，而真实滚动位置 `pixels` 仍停在顶部过渡区中段——两者就此**解耦**：折叠到居中小标题后轻微下滑，门控发现 `pixels` 尚在过渡区，按增量把标题又展开，视觉上"稍微一动就弹回大标题"。现改为**按位置直接映射**：`heightOffset = -(pixels - minScrollExtent)`，再由 setter 钳到 `[heightOffsetLimit, 0]`。折叠量恒为滚动位置的纯函数，只有内容滚回顶部对应位置才逐像素恢复，中途上/下滑绝不跳变（对齐 iOS/标准大标题语义）。随之移除累加门控、松手 `snap`（弹簧动画）、`AnimationController`/`TickerProvider` 依赖，`MiuixScrollBehaviorListener` 降为无状态组件。回归测试同步更新 `test/top_app_bar_scroll_gate_test.dart`。

## 1.0.8

### 修复

- **大标题在列表中部下滑时被弹回展开**：`ExitUntilCollapsedScrollBehavior` 此前对上滑/下滑对称累加 `heightOffset`，在列表任意位置轻微下滑都会立即展开顶栏（松手后还被 snap 完整弹回大标题），偏离 Kotlin 原版"下滑仅在内容到顶后才展开"的语义。现改为按内容位置门控：只统计发生在顶部过渡区间 `[minScrollExtent, minScrollExtent + 展开量]` 内的滚动行程——中部下滑门控量恒为 0 保持折叠，滚回顶部区间才逐像素展开（含 iOS 弹性下拉过顶段）；上滑折叠只忽略回弹归位段（min 以下），其余不变。Android `ClampingScrollPhysics` 到顶后 `scrollDelta` 被钳成 0 的场景（当年对称累加的动机），改用顶部 `OverscrollNotification`（overscroll < 0）驱动展开，对应 Kotlin `onPostScroll` 的"剩余下滑量"。回归测试 `test/top_app_bar_scroll_gate_test.dart`。
- **内嵌子列表误驱动顶栏折叠**：`handleScroll` 未过滤通知来源，页面内嵌套的横向/内层滚动视图（如卡片里的横向列表）滚动时也会牵动大标题。现仅响应 `depth == 0` 且竖向轴的通知。

## 1.0.7

### 修复

- **PullToRefresh 下拉中段触发 RenderFlex 溢出断言**：刷新头内容（指示圈 + 文案）在 `SizedBox(height: 动画高度)` 的受限约束内用 `Column` 布局，头部尚未展开到内容自然高度时（进度约 < 0.7）每帧抛出 "overflowed by N pixels on the bottom"（视觉上本就被 `ClipRect` 裁剪，仅调试期噪音）。现在 `ClipRect` 内垫一层顶部锚定、纵向无界的 `OverflowBox`，内容始终按自然高度布局、由裁剪负责渐显，视觉行为不变、断言消除。

## 1.0.6

### 修复

- **TopAppBar 超长标题溢出屏幕**：主/副标题的 `Text` 位于 `Positioned(left, top)` 下，宽度无界，`maxLines: 1 + ellipsis` 永远不触发，长标题直接画出屏幕。现按当前折叠进度计算可用宽度（大端点右留 `titlePadding` 对称边距、小端点避开 actions）并用 `ConstrainedBox` 显式限宽，超长时正确显示省略号；折叠端点的居中定位同步改用钳制后的文字宽度，避免超长标题的目标位置压到导航图标上。

## 1.0.5

### 修复

- **对话框被输入法遮挡**：`MiuixOverlayDialog` 在手机上底部锚定，但底边距只计算了安全区，未计入键盘高度（`viewInsets.bottom`）。现在面板随键盘上移（`AnimatedPadding` 平滑跟随，取键盘高度与底部安全区较大值），对应 Compose 版 `imePadding` 语义。
- **弹层宿主拆卸期断言**：整棵树销毁时 `MiuixDialogLayout.dispose` 的 `dismiss()` 会同步触发宿主可见性回调，在已 deactivate 的 element 上读 `MediaQuery` 抛 "deactivated ancestor" 断言。回调入口现已短路。

## 1.0.4

### 修复

- **TopAppBar 折叠标题飞出屏幕**：`MiuixIconButton` / `MiuixButton` / `MiuixFloatingActionButton` 内部 `Center` 未设 `widthFactor/heightFactor`，在有界宽松约束下被撑满可用空间（Compose `defaultMinSize` 语义应贴内容尺寸）。TopAppBar 测量层因此把导航图标测成整屏宽，折叠标题的避让目标被推到屏幕外——滚动时标题向右飞出。现已改为贴内容尺寸；注意这同时意味着按钮在 Column/ListView 等有界宽松上下文中不再自动撑满宽度（需要全宽时请自行包 `SizedBox(width: double.infinity)`）。
- **折叠标题目标位置防御性钳制**：无论 nav/actions 测量结果如何，折叠目标绝不超出可视范围。
- **吸附动画与手势争抢**：松手后的吸附动画不会被新滚动手势取消，与手势输入争抢 `heightOffset`（症状：折叠到底后被残留动画拉回展开、滚动中标题抖动）。现在新手势开始时停止残留吸附动画。

## 1.0.3

### 修复

- **MiuixTextField 点击无法聚焦**：占位/浮动标签的 `Text` 叠在内部 `TextField` 之上且参与命中测试（`RenderParagraph` 命中即止），点在占位文字上事件被吞掉，无法唤起键盘。标签现包裹 `IgnorePointer`。
- **MiuixTextField 整块可点击**：背景、内边距与非交互图标区域此前不可点击（有效点击区仅剩文本行本身）。现在整个输入框区域点击均聚焦唤起键盘（与 Compose 原版一致）；内部 trailing 按钮等更深层手势优先级不受影响。

### 新增

- **MiuixTextField.autofocus**：挂载后自动聚焦并唤起键盘（常用于对话框内输入框），默认 `false`。

## 1.0.2

### 修复

- **MiuixTextField**：`textInputAction` / `textCapitalization` / `onSubmitted` 此前未转发给内部 `TextField`，导致键盘 action 键（搜索/完成）与提交回调不生效。现已正确转发。
- **弹层 entry 双重 dispose**：承载弹层的路由整体 pop 时，`MiuixDialogLayout`/`MiuixPopupLayout` 的 State 与 popup host 的 HostedEntry 会在同一帧卸载，双方的 orphaned 判断同时成立并各自调用 `entry.dispose()`，抛 use-after-dispose 断言。`MiuixPopupEntry.dispose` 现已幂等（新增 `isDisposed`），二次调用为无害 no-op。

### 变更

- **包结构调整**：实现文件移入 `lib/src/`，仅保留 `lib/miuix.dart` 作为唯一公开入口。pub.dev 安装页现在只显示一行 `import 'package:flutter_miuix/miuix.dart';`，不再逐个列出内部文件。公开 API 与导入方式不变。

## 1.0.0

首个发布版本。miuix（Kotlin Multiplatform）组件库到 Flutter 的 1:1 移植。

### 新增

- **完整组件覆盖**：45+ 个组件，覆盖 Button / TextField / Switch / Slider / Checkbox / RadioButton / NavigationBar / FloatingNavigationBar / NavigationRail / Scaffold / TopAppBar / SmallTopAppBar / TabRow / BreadcrumbBar / Card / Badge / Divider / SmallTitle / BasicComponent / 各类 Preference / Dropdown / Spinner / CascadingMenu / NumberPicker / ColorPicker / ColorPalette / DatePicker / BottomSheet / FloatingToolbar / Dialog / Snackbar / Tooltip / ProgressIndicator / SearchBar / ScrollBar / PullToRefresh / Surface 等。
- **Squircle 超椭圆圆角**：`MiuixSquircleBorder` 复刻 iOS/HyperOS 圆角。
- **Folme 弹簧动效**：`MiuixSpringEngine` + `folmeSpring(damping, response)`。
- **液态玻璃**：`MiuixTextureBlur`（`ImageFilter.blur` 高斯模糊 + 颜色控制）、`MiuixHighlight`（着色器 bloom 高光描边）、`MiuixLayerBackdrop` / `MiuixLayerBackdropCapture` 背景捕获；另有一行开启的毛玻璃顶栏 `MiuixTopAppBar(blurred: true)`。
- **Monet 动态取色**：基于 `material_color_utilities` + `dynamic_color`，从壁纸或种子色生成整套 miuix 配色（27 个语义角色）。
- **OkLab / OkLCH / OkHSV 色彩空间**：完整移植原版感知均匀色彩数学。
- **矢量图标系统**：`MiuixVectorIcon` + `MiuixBasicIcons`（7 个基础图标）/ `MiuixExtendedIcons`（156 个扩展图标 × 5 字重）。
- **主题体系**：`MiuixTheme` / `MiuixThemeData` / `MiuixThemeController`，支持明暗模式与动态取色。
