# flutter_miuix

**English | [简体中文](README_ZH-CN.md)**

[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.12.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A53.12.2-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue)](https://www.apache.org/licenses/LICENSE-2.0)
[![Docs](https://img.shields.io/badge/Docs-miuix.nekofun.top-3482FF)](https://miuix.nekofun.top/)

`flutter_miuix` is a HyperOS-style component library for Flutter, ported from [miuix](https://github.com/compose-miuix-ui/miuix).

📖 **[文档链接 / Documentation](https://miuix.nekofun.top/)**

## AI Coding Skill

Writing Flutter UI with `flutter_miuix` via an AI coding assistant (Claude Code, or any tool supporting [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills))? Install the companion skill so your AI gets correct component usage, theming wiring, composition patterns, and gotchas out of the box - with bilingual API reference for all 45+ components.

```bash
npx flutter-miuix-skill
```

Run it in your Flutter project root - it installs the guide into `.claude/skills/flutter-miuix/`. Restart your AI tool and it's picked up automatically.

```bash
npx flutter-miuix-skill --path <dir>   # target project dir (default: cwd)
npx flutter-miuix-skill --force        # overwrite an existing install
```

> See the [`skill/`](skill/) directory for details.

## Features

- **Complete component coverage**: 45+ components with 100% parity to the original, including Button / TextField / Switch / Slider / NavigationBar / NavigationRail / Scaffold / TopAppBar / TabRow / BreadcrumbBar / BottomSheet / Dialog / Snackbar / Tooltip / Dropdown / ListPopup / CascadingMenu / ColorPicker / PullToRefresh, and more
- **Squircle corners**: `MiuixSquircleBorder` recreates the iconic "square-yet-round" corners of iOS/HyperOS
- **Folme spring motion**: `MiuixSpringEngine` + `folmeSpring(damping, response)` reproduces the physics-based transitions of the original
- **Liquid Glass**: `MiuixTextureBlur` (Gaussian blur via `ImageFilter.blur`) + `MiuixHighlight` (shader-based bloom stroke) for frosted-glass surfaces and lit edges; plus a one-line frosted top bar via `MiuixTopAppBar(blurred: true)`
- **Monet dynamic colors**: Built on `material_color_utilities` + `dynamic_color`, generates a full miuix palette (27 roles) from wallpaper or seed color
- **OkLab / OkLCH / OkHSV color spaces**: A complete port of the original's perceptually-uniform color math, powering multi-space color picking
- **Vector icon system**: `MiuixVectorIcon` + `MiuixBasicIcons` / `MiuixExtendedIcons` support path parsing, tinting, and lookup by name
- **Unified overlay infrastructure**: `MiuixPopupHost` + `MiuixPopupRegistry` manage registration, layering, and transitions for Dialog / BottomSheet / ListPopup / Dropdown

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_miuix: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

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
    // MiuixSystemTheme follows the system brightness and applies Miuix colors
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
              MiuixSnackbarHost.of(context)?.showSnackbar('Clicked!');
            },
          ),
        ),
      ),
    );
  }
}
```

> See the [`example/`](example/) directory for a complete showcase with 14 category pages: Buttons, Inputs, Menus, Display, List Items, Pickers, Feedback, Overlays, Navigation, Side Rail, Utility, Theming, Blur, and Foundation.

## Component Categories

| Category | Key components |
|---|---|
| **Buttons** | `MiuixButton` · `MiuixTextButton` · `MiuixIconButton` · `MiuixFloatingActionButton` |
| **Inputs** | `MiuixTextField` · `MiuixSwitch` · `MiuixCheckbox` · `MiuixRadioButton` · `MiuixSlider` · `MiuixVerticalSlider` · `MiuixRangeSlider` · `MiuixSearchBar` · `MiuixNumberPicker` |
| **Menus** | `MiuixOverlayDropdownMenu` · `MiuixOverlayIconDropdownMenu` · `MiuixOverlayIconCascadingDropdownMenu` · `MiuixOverlaySpinnerPreference` |
| **Display** | `MiuixText` · `MiuixCard` · `MiuixBadge` · `MiuixBadgedBox` · `MiuixHorizontalDivider` · `MiuixVerticalDivider` · `MiuixSmallTitle` · `MiuixBasicComponent` |
| **Preferences** | `MiuixArrowPreference` · `MiuixSwitchPreference` · `MiuixCheckboxPreference` · `MiuixRadioButtonPreference` · `MiuixSliderPreference` · `MiuixRangeSliderPreference` · `MiuixOverlayDropdownPreference` · `MiuixOverlaySpinnerPreference` |
| **Pickers** | `MiuixColorPicker` · `MiuixHsvColorPicker` · `MiuixOkHsvColorPicker` · `MiuixOkLabColorPicker` · `MiuixOkLchColorPicker` · `MiuixColorPalette` |
| **Feedback** | `MiuixSnackbar` · `MiuixSnackbarHost` · `MiuixTooltip` · `MiuixRichTooltip` · `MiuixOverlayDialog` · `MiuixLinearProgressIndicator` · `MiuixCircularProgressIndicator` · `MiuixInfiniteProgressIndicator` |
| **Overlays** | `MiuixOverlayBottomSheet` · `MiuixWindowBottomSheet` · `MiuixFloatingToolbar` · `MiuixListPopupColumn` · `MiuixOverlayListPopup` |
| **Navigation** | `MiuixScaffold` · `MiuixTopAppBar` · `MiuixSmallTopAppBar` · `MiuixNavigationBar` · `MiuixFloatingNavigationBar` · `MiuixNavigationRail` · `MiuixTabRow` · `MiuixTabRowWithContour` · `MiuixBreadcrumbBar` |
| **Utility** | `MiuixSearchBar` · `MiuixVerticalScrollBar` · `MiuixHorizontalScrollBar` · `MiuixPullToRefresh` · `MiuixSurface` |
| **Theming** | `MiuixTheme` · `MiuixSystemTheme` · `MiuixThemeController` · `MiuixColors` · `MiuixTextStyles` · `MiuixMotion` |
| **Blur** | `MiuixTextureBlur` · `MiuixHighlight` · `MiuixLayerBackdrop` · `MiuixLayerBackdropCapture` |
| **Foundation** | `MiuixSquircleBorder` · `MiuixPressable` · `MiuixScrollEndHaptic` · `MiuixContentColor` · `MiuixSpringEngine` · `MiuixPopupHost` |

## Documentation

📖 **Read the docs online: [miuix.nekofun.top](https://miuix.nekofun.top/)**

Detailed API documentation also lives in-repo at [`doc/.api_frag/`](doc/.api_frag/) and is organized by category in both Chinese and English:

| File | Content |
|---|---|
| `00_header` | Installation & theme setup guide |
| `10_inputs` | Input components (TextField / Switch / Checkbox / RadioButton / Slider / SearchBar / NumberPicker) |
| `20_buttons` | Button components (Button / TextButton / IconButton / FloatingActionButton / BasicComponent / Card) |
| `30_navigation` | Navigation & scaffold (Scaffold / TopAppBar / NavigationBar / NavigationRail / TabRow / BreadcrumbBar / ScrollBar) |
| `40_overlays` | Overlays & feedback (Dialog / BottomSheet / Dropdown / ListPopup / Tooltip / Snackbar / FloatingToolbar / ProgressIndicator / PullToRefresh) |
| `50_preferences` | Preferences (Arrow / Switch / Checkbox / RadioButton / Slider / Dropdown / Spinner / ColorPicker / ColorPalette) |
| `60_theme` | Theme & colors (MiuixTheme / MiuixColors / MiuixTextStyles / MiuixMotion / dynamic colors) |
| `70_foundation` | Foundation (Pressable / ContentColor / ScrollEndHaptic / Squircle / Popup registration & transitions / spring utils / vector icons) |
| `80_blur` | Blur & liquid glass (TextureBlur / Highlight / Backdrop) |
| `90_icons` | Icon system (MiuixIcon / MiuixBasicIcons / MiuixExtendedIcons) |
| `100_color_spaces` | Color space transforms (HSV / OkLab / OkLCH / OkHSV / Color extensions) |

## Platform Support

| Platform | Status | Notes |
|---|---|---|
| Android | ✅ Fully supported | Includes wallpaper dynamic colors (`dynamic_color`) |
| iOS | ✅ Fully supported | Dynamic colors fall back to seed color |
| macOS | ✅ Fully supported | Same as iOS |
| Windows | ✅ Fully supported | Dynamic colors fall back to seed color |
| Linux | ✅ Fully supported | Same as Windows |
| Web | ✅ Fully supported | Dynamic colors fall back |

## Dependencies

- [`material_color_utilities`](https://pub.dev/packages/material_color_utilities) — HCT color science + Material dynamic color schemes
- [`dynamic_color`](https://pub.dev/packages/dynamic_color) — Android system wallpaper color extraction

## Acknowledgements

- [compose-miuix-ui/miuix](https://github.com/compose-miuix-ui/miuix) — The original miuix project (Compose Multiplatform implementation); all design, motion, and interaction logic derives from it
- [materialkolor](https://github.com/jordond/materialkolor) — Kotlin Material dynamic color library; `miuixColorsFromSeed` in this package is equivalent to its core flow

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
