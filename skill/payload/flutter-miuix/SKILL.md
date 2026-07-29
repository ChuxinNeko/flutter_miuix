---
name: flutter-miuix
description: >-
  在 Flutter 项目中使用 flutter_miuix 组件库（小米 HyperOS / MIUI 风格：超椭圆圆角、
  Folme 弹性动效、液态玻璃模糊、Monet 动态取色，45+ 组件）时使用本 skill。当用户要求
  用 Miuix / HyperOS / MIUI 风格搭建界面，或代码里出现 MiuixScaffold、MiuixButton、
  MiuixTopAppBar、MiuixSwitch、MiuixCard 等 Miuix* 组件、import 'package:flutter_miuix/miuix.dart'
  时，参照本指南获取正确的接线方式、组合范式与避坑要点。
license: Apache-2.0
---

# flutter_miuix 组件库使用指南

flutter_miuix 是从 Kotlin 版 [miuix](https://github.com/compose-miuix-ui/miuix) 1:1 移植的
Flutter 组件库，提供整套小米 HyperOS / MIUI 风格组件：超椭圆圆角、Folme 弹性动效、
液态玻璃模糊、Monet 动态取色。全部尺寸/圆角/内边距均可通过构造参数定制，默认值对齐原版。

- 文档站：https://miuix.nekofun.top/
- 仓库：https://github.com/ChuxinNeko/flutter_miuix
- pub.dev：https://pub.dev/packages/flutter_miuix

> **参数细节查这里**：本文件是快速上手 + 组合范式 + 避坑。每个组件的完整参数表、默认值、
> 颜色配置在 `references/` 下按分类分文件（中英双语），需要精确签名时按“组件目录索引”
> 跳转到对应文件阅读，不要凭记忆猜参数名。

## 何时用本 skill

- 用户要用 Miuix / HyperOS / MIUI 风格搭 Flutter 界面
- 代码里出现 `Miuix*` 组件或 `import 'package:flutter_miuix/miuix.dart';`
- 需要 flutter_miuix 某个组件的正确参数、颜色角色、组合方式

## 安装与导入

`pubspec.yaml`：

```yaml
dependencies:
  flutter_miuix: ^1.0.0
```

**唯一入口**（一个 import 暴露全部公开 API，不要去 import `src/` 下的实现文件）：

```dart
import 'package:flutter_miuix/miuix.dart';
```

## 主题接线（必做，否则颜色/文字样式取不到）

在应用根部包一层 `MiuixSystemTheme`（自动跟随系统明暗），组件通过 `MiuixTheme.of(context)`
读取颜色与文本样式：

```dart
void main() => runApp(
  MiuixSystemTheme(
    child: Builder(
      builder: (context) {
        final theme = MiuixTheme.of(context);
        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            brightness: theme.brightness,
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.colors.primary,
              brightness: theme.brightness,
            ),
          ),
          home: const HomePage(),
        );
      },
    ),
  ),
);
```

- 自定义配色：`MiuixSystemTheme(light: lightColorScheme().copy(primary: ...), dark: ..., child: ...)`
- Monet 动态取色（跟随壁纸 / 种子色）：用 `MiuixThemeController(colorSchemeMode: MiuixColorSchemeMode.monetSystem, keyColor: ..., child: ...)`，细节见 `references/60_theme.zh.md`
- 读取主题：`final theme = MiuixTheme.of(context);` → `theme.colors.xxx` / `theme.textStyles.xxx` / `theme.brightness`

## 核心心智模型

**1. MiuixScaffold 的 content 是一个「接收 padding 的 builder」，不是 Widget。**
Scaffold 先测量顶栏/底栏/系统安全区，把算出的 `EdgeInsets` 通过回调交给你，由你在内容根部自行套 `Padding`：

```dart
MiuixScaffold(
  topBar: const MiuixSmallTopAppBar(title: '首页'),
  content: (padding) => ListView(  // padding 是参数，必须自己应用
    padding: padding,
    children: [/* ... */],
  ),
)
```

**2. 颜色走语义角色，不写死色值。** `theme.colors` 有 50+ HyperOS 语义角色：
`primary/onPrimary`、`surface/onSurface`、`background/onBackground`、`surfaceContainer`、
`onSurfaceVariantSummary`、`dividerLine`、`error/onError` 等。完整清单见 `references/60_theme.zh.md`。

**3. 文本样式走预设。** `theme.textStyles` 有 14 个预设：`main`(17)、`body1/2`、`title1~4`、
`subtitle`(14 粗)、`footnote1/2`、`button` 等。`MiuixText` 默认用 `main` 并自动取内容色。

**4. MiuixIcon 三选一。** `icon`(Material IconData) / `vector`(内置矢量图标) / `child`(自定义 Widget)
三者恰好传一个（构造断言）。内置图标：`MiuixIcons.basic.search`、`MiuixIcons.extended.byName('home')!`
（`byName` 返回可空，找不到返回 null）。单色图标默认用内容色染色，多色图标传 `tint: kMiuixTintUnspecified` 关闭染色。

**5. 输入类组件需要 Material 祖先。** `MiuixTextField` / `MiuixInputField` 依赖 Flutter 文本编辑基建，
其上必须有 `Material`（`MaterialApp` 已提供；若在纯 Overlay 里用，套一层 `Material(type: MaterialType.transparency)`）。

## 组件目录索引

需要某组件的完整参数表/默认值/颜色配置时，打开对应参考文件（中文 `.zh.md`，英文 `.en.md`）。

| 分类 | 组件 | 参考文件 |
|---|---|---|
| 输入 Inputs | MiuixTextField, MiuixSwitch, MiuixCheckbox, MiuixRadioButton, MiuixSlider, MiuixRangeSlider, MiuixSearchBar, MiuixInputField, MiuixNumberPicker | `references/10_inputs.zh.md` |
| 按钮与展示 Buttons & Display | MiuixButton, MiuixTextButton, MiuixIconButton, MiuixFloatingActionButton, MiuixCard, MiuixSurface, MiuixBadge, MiuixBadgedBox, MiuixHorizontalDivider, MiuixVerticalDivider, MiuixSmallTitle, MiuixBasicComponent, MiuixText, MiuixIcon | `references/20_buttons.zh.md` |
| 导航与脚手架 Navigation & Scaffold | MiuixScaffold, MiuixTopAppBar, MiuixSmallTopAppBar, MiuixNavigationBar, MiuixFloatingNavigationBar, MiuixNavigationRail, MiuixTabRow, MiuixTabRowWithContour, MiuixBreadcrumbBar, MiuixVerticalScrollBar, MiuixHorizontalScrollBar, MiuixExitUntilCollapsedScrollBehavior, MiuixScrollBehaviorListener | `references/30_navigation.zh.md` |
| 浮层与反馈 Overlays & Feedback | MiuixOverlayDialog, MiuixOverlayBottomSheet, MiuixWindowBottomSheet, MiuixOverlayDropdownMenu, MiuixOverlayIconDropdownMenu, 级联菜单, MiuixSnackbar/Host, MiuixTooltip, MiuixProgressIndicator (Circular/Linear), MiuixFloatingToolbar, MiuixPullToRefresh | `references/40_overlays.zh.md` |
| 偏好与选择器 Preferences & Pickers | MiuixArrowPreference, MiuixSwitchPreference, MiuixCheckboxPreference, MiuixRadioButtonPreference, MiuixSliderPreference, MiuixDropdownPreference, MiuixSpinnerPreference, MiuixColorPicker, MiuixColorPalette, MiuixDatePicker | `references/50_preferences.zh.md` |
| 主题与动效 Theme & Motion | MiuixTheme, MiuixSystemTheme, MiuixThemeController, MiuixThemeData, MiuixColors, MiuixTextStyles, MiuixMotion, folmeSpring, Monet 动态取色 | `references/60_theme.zh.md` |
| 基础设施 Foundation | MiuixSquircleBorder, MiuixPressable, MiuixContentColor, MiuixScrollEndHaptic, MiuixVectorIcon, 弹层工具 | `references/70_foundation.zh.md` |
| 模糊 / 液态玻璃 Blur | MiuixTextureBlur, MiuixBackdrop, MiuixLayerBackdrop, MiuixHighlight | `references/80_blur.zh.md` |
| 图标 Icons | MiuixIcon, MiuixIcons (basic / extended), MiuixIconWeight | `references/90_icons.zh.md` |
| 颜色空间（高级） Color Spaces | OkLab / OkLch / OkHsv / Hsv 转换 | `references/100_color_spaces.zh.md` |
| 总览 / 安装 | 安装、主题、快速上手、约定 | `references/00_header.zh.md` |

## 常见组合范式（可直接编译）

### 设置页（偏好项列表）

```dart
MiuixScaffold(
  topBar: const MiuixSmallTopAppBar(title: '设置'),
  content: (padding) => ListView(
    padding: padding,
    children: [
      const MiuixSmallTitle('通用'),
      MiuixSwitchPreference(
        title: '飞行模式',
        value: airplaneMode,
        onChanged: (v) => setState(() => airplaneMode = v),
      ),
      MiuixArrowPreference(
        title: '关于',
        summary: '版本、许可与开源信息',
        onClick: () => Navigator.of(context).push(/* ... */),
      ),
    ],
  ),
)
```

### 可折叠大标题栏（滚动联动）

必须同时接两处：`MiuixTopAppBar.scrollBehavior` 与包裹滚动体的 `MiuixScrollBehaviorListener`，
两者共享同一个 behavior 实例。

```dart
final _behavior = MiuixExitUntilCollapsedScrollBehavior(); // 在 State 里持有

MiuixScaffold(
  topBar: MiuixTopAppBar(
    title: '首页',
    subtitle: '副标题',
    scrollBehavior: _behavior,
    blurred: true, // 可选：顶栏毛玻璃，透过顶栏虚化下方内容
  ),
  content: (padding) => MiuixScrollBehaviorListener(
    behavior: _behavior,
    child: ListView(padding: padding, children: [/* ... */]),
  ),
)
```

### 底部导航

```dart
MiuixScaffold(
  bottomBar: MiuixNavigationBar(
    children: [ // 长度必须 2~5
      MiuixNavigationBarItem(
        selected: index == 0,
        onPressed: () => setState(() => index = 0),
        icon: MiuixIcon(vector: MiuixIcons.extended.byName('home')!),
        label: '首页',
      ),
      MiuixNavigationBarItem(
        selected: index == 1,
        onPressed: () => setState(() => index = 1),
        icon: MiuixIcon(vector: MiuixIcons.extended.byName('settings')!),
        label: '我的',
      ),
    ],
  ),
  content: (padding) => pages[index],
)
```

### 对话框 / 底部弹窗（由 state 里的 bool 驱动）

弹层不是命令式 `showDialog`，而是声明式：把它常驻在树里，用 `show` 布尔 +
`onDismissRequest` 回调驱动开合。

```dart
// build 里，与页面主体并列（或作为 content 的一部分）：
MiuixOverlayDialog(
  show: _showDialog,
  title: '提示',
  summary: '确定继续吗？',
  onDismissRequest: () => setState(() => _showDialog = false),
  content: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      MiuixTextButton('取消', onPressed: () => setState(() => _showDialog = false)),
      const SizedBox(width: 12),
      MiuixButton(
        onPressed: () => setState(() => _showDialog = false),
        child: const MiuixText('确定'),
      ),
    ],
  ),
)

// 底部弹窗同理：
MiuixOverlayBottomSheet(
  show: _showSheet,
  title: '选项',
  onDismissRequest: () => setState(() => _showSheet = false),
  content: const SizedBox(height: 200),
)
```

### 下拉菜单

```dart
MiuixOverlayDropdownMenu(
  title: '排序方式',
  entry: MiuixDropdownEntry(items: [
    MiuixDropdownItem(text: '按名称', selected: sort == 0, onClick: () => setState(() => sort = 0)),
    MiuixDropdownItem(text: '按日期', selected: sort == 1, onClick: () => setState(() => sort = 1)),
  ]),
)
```

## 避坑清单

- **按钮在有界宽松约束下不会自动撑满**：`MiuixButton` / `MiuixIconButton` / `MiuixFloatingActionButton`
  贴内容尺寸（对齐 Compose `defaultMinSize` 语义）。在 `Column` / `ListView` 里想要整行宽的按钮，
  自己套 `SizedBox(width: double.infinity, child: MiuixButton(...))`。
- **`MiuixIcons.extended.byName(...)` 返回可空**：找不到返回 `null`，示例里用 `!` 断言前请确认名字存在
  （名字是 lowerCamelCase，如 `addCircle`；运行时可用 `MiuixIcons.extended.names` 列出全部）。
  `MiuixIcons.basic.*` 是直接 getter，不可空（`search`/`check`/`close`/`arrowRight`/`arrowUpDown` 等）。
- **MiuixIcon 三个来源互斥**：`icon`/`vector`/`child` 恰好传一个，多传或不传都会触发断言。
- **可折叠顶栏要接两处**：只给 `MiuixTopAppBar.scrollBehavior` 而不包 `MiuixScrollBehaviorListener`
  （或反之），滚动不会联动折叠。用 `MiuixSmallTopAppBar` 则是静态小标题，不折叠。
- **弹层用 `show` 布尔驱动**，不要找 `showMiuixDialog()` 之类的命令式 API——把组件放进树里，
  切 `show` 并在 `onDismissRequest` 里回置为 false。
- **NavigationBar 子项数量**：`MiuixNavigationBar` / `MiuixFloatingNavigationBar` 断言 children 长度 2~5。
- **content 的 padding 必须自己应用**：`MiuixScaffold.content: (padding) => ...` 里若忘了把 `padding`
  用到内容根部，内容会被顶栏/底栏遮挡。
- **纯色值前先找语义角色**：需要某个颜色时先在 `theme.colors` 找对应角色（见 `references/60_theme.zh.md`），
  写死 `Color(0x...)` 会在明暗切换时失真。

## references 导航

- 先读本文件确定用哪个组件、怎么组合。
- 要精确参数/默认值/颜色配置字段时，按上面「组件目录索引」打开 `references/NN_分类.zh.md`（或 `.en.md`）。
- `references/00_header.zh.md` 是总览（安装、主题、约定），`60_theme` 是配色与动效全表，`90_icons` 是图标系统与可用图标名。

