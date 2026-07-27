# flutter_miuix

**[English](README.md) | 简体中文**

[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.12.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A53.12.2-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue)](https://www.apache.org/licenses/LICENSE-2.0)
[![Docs](https://img.shields.io/badge/文档-miuix.nekofun.top-3482FF)](https://miuix.nekofun.top/)

`flutter_miuix` 是一个适用于 Flutter 的 HyperOS 风格组件库，移植自 [miuix](https://github.com/compose-miuix-ui/miuix)。

📖 **[文档链接](https://miuix.nekofun.top/)**

## 特性

- **完整组件覆盖**：45+ 个组件，对应原版 100% 覆盖率，含 Button / TextField / Switch / Slider / NavigationBar / NavigationRail / Scaffold / TopAppBar / TabRow / BreadcrumbBar / BottomSheet / Dialog / Snackbar / Tooltip / Dropdown / ListPopup / CascadingMenu / ColorPicker / PullToRefresh 等
- **Squircle 超椭圆圆角**：通过 `MiuixSquircleBorder` 复刻 iOS/HyperOS 标志性的"方中带圆"圆角
- **Folme 弹簧动效**：`MiuixSpringEngine` + `folmeSpring(damping, response)`，复刻原版的物理感过渡
- **液态玻璃 Liquid Glass**：`MiuixTextureBlur`（`ImageFilter.blur` 高斯模糊）+ `MiuixHighlight`（着色器 bloom 高光描边），实现毛玻璃表面与发光边缘；另有一行开启的毛玻璃顶栏 `MiuixTopAppBar(blurred: true)`
- **Monet 动态取色**：基于 `material_color_utilities` + `dynamic_color`，支持从壁纸或种子色生成整套 miuix 配色（27 个角色）
- **OkLab / OkLCH / OkHSV 色彩空间**：完整移植原版的感知均匀色彩数学，支撑 ColorPicker 的多色彩空间取色
- **Vector Icon 系统**：`MiuixVectorIcon` + `MiuixBasicIcons` / `MiuixExtendedIcons`，支持路径解析、tint 着色与按名称检索
- **统一弹层基础设施**：`MiuixPopupHost` + `MiuixPopupRegistry` 统一管理 Dialog / BottomSheet / ListPopup / Dropdown 的注册、分层与过渡

## 安装

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  flutter_miuix: ^1.0.0
```

然后执行：

```bash
flutter pub get
```

## 快速开始

```dart
import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MiuixSystemTheme 自动跟随系统明暗模式，并应用 Miuix 配色
    return MiuixSystemTheme(
      child: Builder(
        builder: (context) {
          final theme = MiuixTheme.of(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: theme.colors.primary,
                brightness: theme.brightness,
              ),
              brightness: theme.brightness,
            ),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MiuixScaffold(
      topBar: MiuixTopAppBar(title: 'flutter_miuix'),
      content: (padding) => Padding(
        padding: padding,
        child: Center(
          child: MiuixButton(
            title: 'Hello Miuix',
            onClick: () {
              MiuixSnackbarHost.of(context)?.showSnackbar('已点击！');
            },
          ),
        ),
      ),
    );
  }
}
```

> 完整示例请参考 [`example/`](example/) 目录，包含 14 个分类的演示页面：按钮、输入、菜单、显示、列表项、选择器、反馈、浮层、导航、侧边导航、实用工具、主题、模糊、基础。

## 组件分类

| 分类 | 主要组件 |
|---|---|
| **按钮 Buttons** | `MiuixButton` · `MiuixTextButton` · `MiuixIconButton` · `MiuixFloatingActionButton` |
| **输入 Inputs** | `MiuixTextField` · `MiuixSwitch` · `MiuixCheckbox` · `MiuixRadioButton` · `MiuixSlider` · `MiuixVerticalSlider` · `MiuixRangeSlider` · `MiuixSearchBar` · `MiuixNumberPicker` |
| **菜单 Menus** | `MiuixOverlayDropdownMenu` · `MiuixOverlayIconDropdownMenu` · `MiuixOverlayIconCascadingDropdownMenu` · `MiuixOverlaySpinnerPreference` |
| **显示 Display** | `MiuixText` · `MiuixCard` · `MiuixBadge` · `MiuixBadgedBox` · `MiuixHorizontalDivider` · `MiuixVerticalDivider` · `MiuixSmallTitle` · `MiuixBasicComponent` |
| **偏好 Preferences** | `MiuixArrowPreference` · `MiuixSwitchPreference` · `MiuixCheckboxPreference` · `MiuixRadioButtonPreference` · `MiuixSliderPreference` · `MiuixRangeSliderPreference` · `MiuixOverlayDropdownPreference` · `MiuixOverlaySpinnerPreference` |
| **选择器 Pickers** | `MiuixColorPicker` · `MiuixHsvColorPicker` · `MiuixOkHsvColorPicker` · `MiuixOkLabColorPicker` · `MiuixOkLchColorPicker` · `MiuixColorPalette` |
| **反馈 Feedback** | `MiuixSnackbar` · `MiuixSnackbarHost` · `MiuixTooltip` · `MiuixRichTooltip` · `MiuixOverlayDialog` · `MiuixLinearProgressIndicator` · `MiuixCircularProgressIndicator` · `MiuixInfiniteProgressIndicator` |
| **浮层 Overlays** | `MiuixOverlayBottomSheet` · `MiuixWindowBottomSheet` · `MiuixFloatingToolbar` · `MiuixListPopupColumn` · `MiuixOverlayListPopup` |
| **导航 Navigation** | `MiuixScaffold` · `MiuixTopAppBar` · `MiuixSmallTopAppBar` · `MiuixNavigationBar` · `MiuixFloatingNavigationBar` · `MiuixNavigationRail` · `MiuixTabRow` · `MiuixTabRowWithContour` · `MiuixBreadcrumbBar` |
| **实用 Utility** | `MiuixSearchBar` · `MiuixVerticalScrollBar` · `MiuixHorizontalScrollBar` · `MiuixPullToRefresh` · `MiuixSurface` |
| **主题 Theming** | `MiuixTheme` · `MiuixSystemTheme` · `MiuixThemeController` · `MiuixColors` · `MiuixTextStyles` · `MiuixMotion` |
| **模糊 Blur** | `MiuixTextureBlur` · `MiuixHighlight` · `MiuixLayerBackdrop` · `MiuixLayerBackdropCapture` |
| **基础 Foundation** | `MiuixSquircleBorder` · `MiuixPressable` · `MiuixScrollEndHaptic` · `MiuixContentColor` · `MiuixSpringEngine` · `MiuixPopupHost` |

## 文档

📖 **在线文档：[miuix.nekofun.top](https://miuix.nekofun.top/)**

详细的 API 文档同时位于仓库内 [`doc/.api_frag/`](doc/.api_frag/) 目录，按分类组织为中英双语：

| 文件 | 内容 |
|---|---|
| `00_header` | 安装与主题接入指南 |
| `10_inputs` | 输入组件（TextField / Switch / Checkbox / RadioButton / Slider / SearchBar / NumberPicker） |
| `20_buttons` | 按钮组件（Button / TextButton / IconButton / FloatingActionButton / BasicComponent / Card） |
| `30_navigation` | 导航与脚手架（Scaffold / TopAppBar / NavigationBar / NavigationRail / TabRow / BreadcrumbBar / ScrollBar） |
| `40_overlays` | 浮层与反馈（Dialog / BottomSheet / Dropdown / ListPopup / Tooltip / Snackbar / FloatingToolbar / ProgressIndicator / PullToRefresh） |
| `50_preferences` | 偏好设置（Arrow / Switch / Checkbox / RadioButton / Slider / Dropdown / Spinner / ColorPicker / ColorPalette） |
| `60_theme` | 主题与配色（MiuixTheme / MiuixColors / MiuixTextStyles / MiuixMotion / 动态取色） |
| `70_foundation` | 基础设施（Pressable / ContentColor / ScrollEndHaptic / Squircle / Popup 注册与过渡 / 弹簧工具 / 矢量图标） |
| `80_blur` | 模糊与液态玻璃（TextureBlur / Highlight / Backdrop） |
| `90_icons` | 图标系统（MiuixIcon / MiuixBasicIcons / MiuixExtendedIcons） |
| `100_color_spaces` | 色彩空间变换（HSV / OkLab / OkLCH / OkHSV / Color 扩展） |

## 平台支持

| 平台 | 支持情况 | 备注 |
|---|---|---|
| Android | ✅ 完整支持 | 含壁纸动态取色（`dynamic_color`） |
| iOS | ✅ 完整支持 | 壁纸动态取色回退到种子色 |
| macOS | ✅ 完整支持 | 同 iOS |
| Windows | ✅ 完整支持 | 壁纸动态取色回退到种子色 |
| Linux | ✅ 完整支持 | 同 Windows |
| Web | ✅ 完整支持 | 动态取色回退 |

## 依赖

- [`material_color_utilities`](https://pub.dev/packages/material_color_utilities) — HCT 色彩科学 + Material 动态配色方案
- [`dynamic_color`](https://pub.dev/packages/dynamic_color) — Android 系统壁纸取色

## 致谢

- [compose-miuix-ui/miuix](https://github.com/compose-miuix-ui/miuix) — 原版 miuix 项目（Compose Multiplatform 实现），本库的所有设计、动效与交互逻辑均源自该项目
- [materialkolor](https://github.com/jordond/materialkolor) — Kotlin 端的 Material 动态配色库，本库的 `miuixColorsFromSeed` 等价于其核心流程

## License

```
Copyright 2026 flutter_miuix contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
