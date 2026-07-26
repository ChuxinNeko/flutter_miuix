# Changelog

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
