# flutter_miuix API Reference

> This is the complete API reference for the **flutter_miuix** component library (English). For the Chinese version, see [`API.zh.md`](API.zh.md).

flutter_miuix is a Flutter component library ported from [miuix](https://github.com/compose-miuix-ui/miuix). It delivers the full Xiaomi HyperOS / MIUI-style component set: squircle corners, dynamic color (Monet), liquid-glass blur, and more.

- Every component's **size, corner radius, padding, and other dimensions are customizable via constructor parameters**, each with a default value matching the original library.
- Colors resolve through `MiuixColors` semantic roles and text through `MiuixTextStyles` presets, switching light/dark automatically with the theme.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_miuix: ^1.0.0
```

Then:

```dart
import 'package:flutter_miuix/miuix.dart';
```

> A single import exposes the entire public API.

## Theming setup

Wrap your app root in `MiuixSystemTheme` (which follows the system light/dark mode automatically). Components then read colors and text styles via `MiuixTheme.of(context)`:

```dart
void main() => runApp(
  MiuixSystemTheme(
    child: Builder(
      builder: (context) {
        final theme = MiuixTheme.of(context);
        return MaterialApp(
          theme: ThemeData(brightness: theme.brightness),
          home: const HomePage(),
        );
      },
    ),
  ),
);
```

For custom color schemes or dynamic color (Monet), see `MiuixSystemTheme` / `MiuixThemeController` / `miuixColorsFromSeed` in the "Theme, Foundation & Icons" section at the end.

## Quick start

```dart
MiuixScaffold(
  topBar: const MiuixTopAppBar(title: 'flutter_miuix'),
  content: (padding) => ListView(
    padding: padding,
    children: [
      MiuixButton(
        onPressed: () {},
        child: const MiuixText('Primary Button'),
      ),
    ],
  ),
)
```

## Conventions

- In the tables, a default value of "required" means the parameter is `required` (no default; must be provided).
- A default shown as `MiuixXxxDefaults.yyy` is sourced from that component's `Defaults` constants; check the source for the concrete value.
- All examples compile and run as-is and show only the most common parameters; see each component's table for the full set.

---
