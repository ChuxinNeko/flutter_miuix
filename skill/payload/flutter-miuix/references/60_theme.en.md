## Theme, Colors & Motion

This chapter covers flutter_miuix's theming infrastructure: [MiuixTheme]/[MiuixSystemTheme] provide static theming, while [MiuixThemeController] offers full Monet dynamic color. [MiuixColors] defines 50+ HyperOS semantic roles, [MiuixTextStyles] defines 14 preset type styles, and [MiuixMotion] plus `folmeSpring` deliver the original library's springs and easing curves.

### MiuixThemeData

Immutable Miuix theme data aggregating [MiuixColors], [MiuixTextStyles] and [Brightness].

| Field / Method | Type | Description |
|---|---|---|
| `colors` | `MiuixColors` | Color scheme |
| `textStyles` | `MiuixTextStyles` | Text style set |
| `brightness` | `Brightness` | Current brightness mode |
| `MiuixThemeData.light({colors, textStyles})` | factory | Light theme; defaults to [lightColorScheme] + [defaultTextStyles] |
| `MiuixThemeData.dark({colors, textStyles})` | factory | Dark theme; defaults to [darkColorScheme] + [defaultTextStyles] |
| `MiuixThemeData.of(brightness, {lightColors, darkColors, textStyles})` | factory | Auto-selects light/dark by system brightness |
| `copyWith({colors, textStyles, brightness})` | `MiuixThemeData` | Copies and overrides selected fields |

**Example:**
```dart
final data = MiuixThemeData.light(
  colors: lightColorScheme().copy(primary: Color(0xFFFF6B35)),
);
```

### MiuixTheme

An [InheritedWidget] that provides [MiuixThemeData] to a subtree.

| Parameter / Method | Type | Default | Description |
|---|---|---|---|
| `data` | `MiuixThemeData` | required | Theme data |
| `child` | `Widget` | required | Subtree |
| `MiuixTheme.of(context)` | `MiuixThemeData` | — | Returns current theme; falls back to `MiuixThemeData.light()` if not wrapped |
| `MiuixTheme.maybeOf(context)` | `MiuixThemeData?` | — | Reads without establishing a dependency; returns null if not wrapped |

**Example:**
```dart
MiuixTheme(
  data: MiuixThemeData.light(),
  child: MyApp(),
)
```

### MiuixSystemTheme

A convenience widget that applies light/dark theme automatically based on `MediaQuery.platformBrightnessOf`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `light` | `MiuixColors?` | `null` (= [lightColorScheme]) | Custom light colors |
| `dark` | `MiuixColors?` | `null` (= [darkColorScheme]) | Custom dark colors |
| `textStyles` | `MiuixTextStyles?` | `null` (= [defaultTextStyles]) | Custom text styles |
| `child` | `Widget` | required | Subtree |

**Example:**
```dart
MiuixSystemTheme(
  child: Builder(builder: (context) {
    final theme = MiuixTheme.of(context);
    return MaterialApp(
      theme: ThemeData(brightness: theme.brightness),
      home: const HomePage(),
    );
  }),
)
```

### MiuixColorSchemeMode

Color scheme mode enum.

| Value | Description |
|---|---|
| `system` | Follows system brightness, uses static light/dark colors |
| `light` | Forces light |
| `dark` | Forces dark |
| `monetSystem` | Follows system brightness + Monet dynamic color |
| `monetLight` | Light + Monet dynamic color |
| `monetDark` | Dark + Monet dynamic color |

> `monet*` modes: when `keyColor` is non-null, colors are generated synchronously from the seed (pure HCT computation); when `keyColor` is null, the platform wallpaper is read (Android), and a fixed seed `0xFF6750A4` is used on other platforms.

### MiuixThemeController

Full theme controller that resolves colors by [MiuixColorSchemeMode] and provides [MiuixTheme] to the subtree.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `colorSchemeMode` | `MiuixColorSchemeMode` | `system` | Color scheme mode |
| `lightColors` | `MiuixColors?` | `null` (= [lightColorScheme]) | Static light colors |
| `darkColors` | `MiuixColors?` | `null` (= [darkColorScheme]) | Static dark colors |
| `textStyles` | `MiuixTextStyles?` | `null` (= [defaultTextStyles]) | Text styles |
| `keyColor` | `Color?` | `null` | Monet seed color; null reads platform wallpaper |
| `colorSpec` | `MiuixThemeColorSpec` | `spec2021` | Color spec version |
| `paletteStyle` | `MiuixThemePaletteStyle` | `tonalSpot` | Monet palette style |
| `isDark` | `bool?` | `null` | Force dark; null follows the system |
| `child` | `Widget` | required | Subtree |

**Monet resolution flow:**
1. `keyColor` non-null → synchronously calls [miuixColorsFromSeed] (pure HCT, no platform channel).
2. `keyColor` null → asynchronously calls [miuixPlatformDynamicColors] (Android wallpaper; other platforms fall back to the fixed seed). Until the result is ready, [miuixMonetSystemColors] is used as a placeholder to avoid flicker.

**Example:**
```dart
MiuixThemeController(
  colorSchemeMode: MiuixColorSchemeMode.monetSystem,
  keyColor: const Color(0xFF6750A4),
  child: MyApp(),
)
```

### MiuixColors

Miuix color scheme. All fields are non-nullable and can be partially overridden via [copy]; light/dark defaults are provided by [lightColorScheme] / [darkColorScheme], matching the HyperOS specification.

#### Primary semantic roles

| Field | Description |
|---|---|
| `primary` / `onPrimary` | Primary color / text-on-primary (Switch, Button, Slider) |
| `primaryVariant` / `onPrimaryVariant` | Primary variant (Card) |
| `primaryContainer` / `onPrimaryContainer` | Primary container |
| `secondary` / `onSecondary` | Secondary color / text-on-secondary |
| `secondaryVariant` / `onSecondaryVariant` | Secondary variant |
| `secondaryContainer` / `onSecondaryContainer` | Secondary container |
| `secondaryContainerVariant` / `onSecondaryContainerVariant` | Secondary container variant |
| `tertiaryContainer` / `onTertiaryContainer` / `tertiaryContainerVariant` | Tertiary container |
| `error` / `onError` | Error color / text-on-error |
| `errorContainer` / `onErrorContainer` | Error container |
| `background` / `onBackground` / `onBackgroundVariant` | App background / text / variant text |
| `surface` / `onSurface` / `surfaceVariant` | Surface / text-on-surface / variant |
| `onSurfaceSecondary` | Secondary text on surface (80% alpha) |
| `onSurfaceVariantSummary` / `onSurfaceVariantActions` | Summary / action text on surface variant |
| `surfaceContainer` / `onSurfaceContainer` / `onSurfaceContainerVariant` | Surface container / text / variant text |
| `surfaceContainerHigh` / `onSurfaceContainerHigh` | High surface container |
| `surfaceContainerHighest` / `onSurfaceContainerHighest` | Highest surface container |
| `outline` | Outline / border |
| `dividerLine` | Divider line |
| `windowDimming` | Window dim color (Dialog / Dropdown / Spinner / BottomSheet) |
| `sliderKeyPoint` / `sliderKeyPointForeground` / `sliderBackground` | Slider key point / foreground / background |

#### Disabled-state colors

| Field | Description |
|---|---|
| `disabledPrimary` / `disabledOnPrimary` | Switch disabled primary / text |
| `disabledPrimaryButton` / `disabledOnPrimaryButton` | Button disabled primary / text |
| `disabledPrimarySlider` | Slider disabled primary |
| `disabledSecondary` / `disabledOnSecondary` | Disabled secondary / text |
| `disabledSecondaryVariant` / `disabledOnSecondaryVariant` | Disabled secondary variant / text |
| `disabledOnSurface` | Disabled text on surface |

#### Default color factories

| Function | Returns | Description |
|---|---|---|
| `lightColorScheme()` | `MiuixColors` | Default light (primary=`0xFF3482FF`, background=white) |
| `darkColorScheme()` | `MiuixColors` | Default dark (primary=`0xFF277AF7`, background=`0xFF242424`) |

#### `MiuixColors.copy(...)`

Copies and overrides selected colors; every parameter is nullable and falls back to the original value. Returns a new [MiuixColors] instance.

**Example:**
```dart
final colors = lightColorScheme().copy(
  primary: const Color(0xFFFF6B35),
  background: const Color(0xFFFFFBF8),
);
```

### MiuixTextStyles

Miuix text style set. Only font size / weight / line height are stored; the runtime color comes from [MiuixTheme]'s `onBackground`.

| Field | Size | Height/Weight | Usage |
|---|---|---|---|
| `main` | 17 | — | Main text |
| `paragraph` | 17 | 1.2em | Paragraph |
| `body1` | 16 | — | Body 1 |
| `body2` | 14 | — | Body 2 |
| `button` | 17 | — | Button |
| `footnote1` | 13 | — | Footnote 1 |
| `footnote2` | 11 | — | Footnote 2 |
| `headline1` | 17 | — | Headline 1 |
| `headline2` | 16 | — | Headline 2 |
| `subtitle` | 14 | bold | Subtitle |
| `title1` | 32 | — | Title 1 |
| `title2` | 24 | — | Title 2 |
| `title3` | 20 | — | Title 3 |
| `title4` | 18 | — | Title 4 |

#### `MiuixTextStyles.copy({...})`

Copies and overrides selected fields, returning a new instance.

#### `defaultTextStyles()`

Returns the default style set matching the Miuix specification (all values in the table above). Can be replaced by passing it to the `textStyles` parameter of [MiuixThemeData] / [MiuixSystemTheme] / [MiuixThemeController].

### Monet dynamic color

#### MiuixThemeColorSpec

Material color spec version. The current `material_color_utilities` 0.13.0 only implements SPEC_2021; `spec2025` is semantically equivalent to requesting 2025 on supported palettes but actually generates via 2021 (matching the original library's "fall back when unsupported" path).

| Value | Description |
|---|---|
| `spec2021` | Material You 2021 color spec |
| `spec2025` | Material You 2025 spec (currently equivalent to spec2021) |

#### MiuixThemePaletteStyle

Monet dynamic color palette style.

| Value | DynamicScheme |
|---|---|
| `tonalSpot` | `SchemeTonalSpot` (default) |
| `neutral` | `SchemeNeutral` |
| `vibrant` | `SchemeVibrant` |
| `expressive` | `SchemeExpressive` |
| `rainbow` | `SchemeRainbow` |
| `fruitSalad` | `SchemeFruitSalad` |
| `monochrome` | `SchemeMonochrome` |
| `fidelity` | `SchemeFidelity` |
| `content` | `SchemeContent` |

#### `miuixColorsFromSeed({seed, colorSpec, paletteStyle, dark})`

Generates a full Miuix color set from a seed color.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `seed` | `Color` | required | Seed color |
| `colorSpec` | `MiuixThemeColorSpec` | `spec2021` | Color spec |
| `paletteStyle` | `MiuixThemePaletteStyle` | `tonalSpot` | Palette style |
| `dark` | `bool` | required | Whether dark |

Returns [MiuixColors]. Flow: select the `DynamicScheme` by `paletteStyle` → extract 27 MD3 roles via `MaterialDynamicColors` → map to Miuix colors via [mapMd3RolesToMiuixColors] (alpha-bearing colors are composited onto their backgrounds to ensure fully opaque results).

#### `miuixMonetSystemColors({dark})`

Default Monet colors: fixed seed `0xFF6750A4` + TonalSpot + Spec2021. Also the `platformDynamicColors` fallback on non-Android platforms.

#### `miuixPlatformDynamicColors({dark})` → `Future<MiuixColors>`

Platform dynamic color.

- Android (and supported platforms): reads the system wallpaper/theme seed via `DynamicColorPlugin.getAccentColor`; if non-null, generates via [miuixColorsFromSeed] (TonalSpot + Spec2021).
- Other platforms or read failures: falls back to [miuixMonetSystemColors] (fixed seed).

> The platform channel is **asynchronous**, so this function returns a `Future`. The UI layer ([MiuixThemeController]) uses [miuixMonetSystemColors] as a placeholder until the result is ready.

#### MiuixMonetRoles

A set of MD3 (Monet) dynamic color roles (27 fields). Filled by [miuixColorsFromSeed] from a `DynamicScheme`, then passed to [mapMd3RolesToMiuixColors] to convert to [MiuixColors].

Main roles: `primary`, `onPrimary`, `primaryFixed`, `onPrimaryFixed`, `error`, `onError`, `errorContainer`, `onErrorContainer`, `primaryContainer`, `onPrimaryContainer`, `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer`, `tertiaryContainer`, `onTertiaryContainer`, `background`, `onBackground`, `surface`, `onSurface`, `surfaceVariant`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest`, `outline`, `outlineVariant`, `onSurfaceVariant`.

#### `mapMd3RolesToMiuixColors(roles, {dark})`

Maps MD3 (Monet) roles to Miuix [MiuixColors]. Replicates the original field-by-field mapping; alpha-bearing disabled/slider/onSurfaceSecondary colors are composited onto their backgrounds via `ensureOpaqueOver` to ensure fully opaque results.

### MiuixMotion

A collection of commonly used Miuix motion curves and springs, grouped by HyperOS interaction conventions.

| Field / Method | Type | Description |
|---|---|---|
| `standardDecelerate` | `Curve` | Standard decelerate, for enter/appear (`DecelerateEasing(1.0)`) |
| `standardAccelerate` | `Curve` | Standard accelerate, for exit/disappear (`AccelerateEasing(1.0)`) |
| `sinOut` | `Curve` | Sine ease-out, for soft translation/scale (`SinOutEasing`) |
| `pressSpring` | `SpringDescription` | General press/state toggle (critically damped, response=0.35s) |
| `bouncySpring` | `SpringDescription` | Bouncy toggle (slightly under-damped 0.85, response=0.45s, natural rebound) |

#### `folmeSpring({damping, response})` → `SpringDescription`

Constructs a [SpringDescription] from damping ratio [damping] and response time [response] (seconds): `stiffness = (2π/response)²`.

| Parameter | Type | Description |
|---|---|---|
| `damping` | `double` | Damping ratio; 1.0=critical, <1 under-damped (rebound), >1 over-damped |
| `response` | `double` | Response time (seconds); smaller is faster |

#### AccelerateEasing

Accelerate curve. With `factor=1`, `y=x²`; larger `factor` exaggerates ease-in.

```dart
const curve = AccelerateEasing(1.0);
```

#### DecelerateEasing

Decelerate curve. With `factor=1`, `1-(1-x)²`; larger `factor` exaggerates ease-out.

#### SinOutEasing

Sine ease-out curve: `sin(t·π/2)`.

**Full motion example:**
```dart
AnimationController(vsync: this)
  ..animateWith(
    SpringSimulation(
      folmeSpring(damping: 0.85, response: 0.45),
      0.0, 1.0, 0.0,
    ),
  );

// Or use presets
AnimationController(vsync: this)
  ..animateTo(1.0, curve: MiuixMotion.standardDecelerate);
```
