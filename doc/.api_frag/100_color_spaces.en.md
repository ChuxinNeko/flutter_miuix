## Color Spaces

This chapter covers flutter_miuix's color space abstractions: [Hsv] (traditional HSV), [OkLab] (perceptually uniform Lab), [OkLch] (perceptually uniform LCH), [OkHsv] (OkLab-based HSV), and the [Color] conversion extension [MiuixColorSpaceExtensions].

All color space classes are `@immutable` and implement `==` / `hashCode`, so they can be used directly in scenarios requiring value equality such as `ValueListenable` and `AnimatedBuilder`.

### Design Overview

| Class | Dimensions | Value Ranges | Use Case |
|---|---|---|---|
| [Hsv] | h/s/v | h: `[0, 360]` deg; s/v: `[0, 100]` percent | Traditional HSV, hue-ring uniform (intuitive for programmers) |
| [OkLab] | l/a/b | l: `[0, 100]`; a/b: `[-100, 100]` | Perceptually uniform lightness & color axes, color-diff calculations |
| [OkLch] | l/c/h | l/c: `[0, 100]`; h: `[0, 360]` deg | Perceptually uniform chroma & hue, palette generation |
| [OkHsv] | h/s/v | h: `[0, 360]` deg; s/v: `[0, 100]` percent | Perceptually uniform HSV, preferred for color pickers |

> **Normalized Intervals**: All classes expose "user-friendly normalized intervals" (lightness/saturation/chroma in 0..100, hue in 0..360 degrees); internally they are scaled to each space's algorithmic interval (e.g. OkLab's a/b internally `[-0.4, 0.4]`, OkLch's c internally `[0, 0.4]`).

> **Gamut Clipping**: All `toColor` methods clip to the sRGB gamut when mapping back, ensuring output channels stay within `[0, 1]`. OkLab/OkLch's a/b/c are also pre-clipped to safe ranges to avoid unpredictable out-of-gamut colors.

### Hsv

Traditional HSV color space. **Preserves full floating-point precision** instead of 8-bit truncation.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `h` | `double` | required (positional) | Hue in degrees, `[0, 360]` |
| `s` | `double` | required (positional) | Saturation in percent, `[0, 100]` |
| `v` | `double` | required (positional) | Value/brightness in percent, `[0, 100]` |

| Method / Field | Returns | Description |
|---|---|---|
| `toColor([alpha = 1.0])` | `Color` | Converts to sRGB; hue normalized to `[0, 360)`, s/v clamped to `[0, 1]`, computed component by component |
| `copyWith({h, s, v})` | `Hsv` | Copy with selected fields replaced |
| `h` / `s` / `v` | `double` | Components |

**Example:**
```dart
const Hsv(120, 80, 90).toColor();           // green-ish
Hsv(0, 100, 100).copyWith(h: 240).toColor(); // red -> blue
```

### OkLab

Perceptually uniform Lab color space. Lightness l is decoupled from a (green-red axis) and b (blue-yellow axis), so adjacent numeric differences correspond to approximately equal perceived color differences.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `l` | `double` | required (positional) | Lightness percent, `0..100` |
| `a` | `double` | required (positional) | Green-red axis, `-100..100` (negative=green, positive=red) |
| `b` | `double` | required (positional) | Blue-yellow axis, `-100..100` (negative=blue, positive=yellow) |

| Method / Field | Returns | Description |
|---|---|---|
| `toColor([alpha = 1.0])` | `Color` | Converts to sRGB; l clamped to `[0, 1]` via `l/100`; a, b scaled by `x/100*0.4` then clamped to `[-0.4, 0.4]` |
| `copyWith({l, a, b})` | `OkLab` | Copy with selected fields replaced |
| `l` / `a` / `b` | `double` | Components |

**Example:**
```dart
// Mid-gray (l=50, no color axes)
const OkLab(50, 0, 0).toColor();

// Reddish
const OkLab(60, 30, 10).toColor();
```

### OkLch

Perceptually uniform LCH color space (polar form of OkLab). Chroma c is decoupled from hue h, so scanning h with fixed l and c yields a perceptually uniform hue ring — ideal for palette generation.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `l` | `double` | required (positional) | Lightness percent, `0..100` |
| `c` | `double` | required (positional) | Chroma percent, `0..100` (0=gray, larger=more saturated) |
| `h` | `double` | required (positional) | Hue in degrees, `[0, 360]` |

| Method / Field | Returns | Description |
|---|---|---|
| `toColor([alpha = 1.0])` | `Color` | Converts to sRGB; l clamped to `[0, 1]` via `l/100`; c scaled by `c/100*0.4` then clamped to `[0, 0.4]`; h normalized to `[0, 360)` |
| `copyWith({l, c, h})` | `OkLch` | Copy with selected fields replaced |
| `l` / `c` / `h` | `double` | Components |

**Example:**
```dart
// Perceptually uniform 36-step hue ring (fixed l, c, scan h)
final palette = List.generate(36, (i) => OkLch(70, 50, i / 36 * 360).toColor());

// Coordinate with MiuixColorPicker: convert current color to OkLch, then adjust lightness only
final lab = current.toOkLch();
final dimmer = lab.copyWith(l: (lab.l - 10).clamp(0, 100)).toColor();
```

### OkHsv

OkLab-based HSV color space. Same API shape as [Hsv], but hue, saturation, and value are all defined in a perceptually uniform space, so color differences are more balanced in all directions when tuning colors.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `h` | `double` | required (positional) | Hue in degrees, `[0, 360]` |
| `s` | `double` | required (positional) | Saturation in percent, `[0, 100]` |
| `v` | `double` | required (positional) | Value/brightness in percent, `[0, 100]` |

| Method / Field | Returns | Description |
|---|---|---|
| `toColor([alpha = 1.0])` | `Color` | Converts to sRGB; **does NOT additionally clip h/s/v or alpha** — passes them through to the underlying algorithm |
| `copyWith({h, s, v})` | `OkHsv` | Copy with selected fields replaced |
| `h` / `s` / `v` | `double` | Components |

> Unlike [Hsv]'s `toColor`, [OkHsv]'s `toColor` does NOT clamp s/v to `[0, 1]` proactively — callers must ensure valid inputs.

**Example:**
```dart
const OkHsv(210, 70, 90).toColor();  // perceptually uniform blue
OkHsv(0, 0, 100).copyWith(h: 180).toColor();
```

### MiuixColorSpaceExtensions

Color space conversion extension on `Color`. Converts the current sRGB [Color] to a normalized-interval [OkLab] / [Hsv] / [OkLch].

```dart
extension MiuixColorSpaceExtensions on Color {
  OkLab toOkLab();
  Hsv toHsv();
  OkLch toOkLch();
}
```

| Method | Returns | Interval Mapping |
|---|---|---|
| `toOkLab()` | `OkLab` | Lightness clamped to `[0, 100]` via `l*100`; a, b restored via `x/0.4*100` then clamped to `[-100, 100]` |
| `toHsv()` | `Hsv` | Hue preserved in degrees; s, v clamped to `[0, 100]` via `x*100` |
| `toOkLch()` | `OkLch` | Lightness clamped to `[0, 100]` via `l*100`; chroma restored via `c/0.4*100` then clamped to `[0, 100]`; hue already normalized |

> All conversions **ignore the input color's alpha** — the output color space classes have no alpha field. To preserve alpha, pass it explicitly via `toColor(current.alpha)`.

**Example:**
```dart
final c = const Color(0xFF3482FF);

// Convert to OkLch then adjust lightness only (good for "dim 10%" perceptually uniform ops)
final lch = c.toOkLch();
final dimmer = lch.copyWith(l: (lch.l - 10).clamp(0, 100)).toColor(c.alpha);

// Convert to HSV then replace hue only (keep original saturation/value, "recolor")
final hsv = c.toHsv();
final recolored = hsv.copyWith(h: 0).toColor(c.alpha); // change to red-ish
```

### Full Example: Perceptually Uniform Palette Generation with OkLch

```dart
/// Generates a perceptually uniform 5-color analogous palette around [seed] (for charts / labels).
List<Color> analogousPalette(Color seed, {int count = 5, double span = 60}) {
  final lch = seed.toOkLch();
  return List.generate(count, (i) {
    final t = (i - (count - 1) / 2) / (count - 1) * 2; // -1..1
    final h = (lch.h + t * span / 2) % 360;
    return lch.copyWith(h: h < 0 ? h + 360 : h).toColor();
  });
}

// Usage
final colors = analogousPalette(const Color(0xFF3482FF));
```

### Internal Implementation Notes

- The underlying algorithms for all `toColor` methods are provided by an internal `Transforms` class (RGB ↔ OkLab, OkLCH, HSV, OkHSV, including gamut clipping and caching). This class is **NOT exported** from `package:flutter_miuix/miuix.dart` — it is an internal implementation. Callers should use the 4 color space classes and [MiuixColorSpaceExtensions] in this section.
- The OkLab/OkLCH math comes from Björn Ottosson's original paper; OkHSV's gamut clipping uses Brent Burmeister's cusp algorithm.
- Batch generation functions like `generateOkLchHueColors` are not publicly exported. For hue rings, use `List.generate` + `OkLch.copyWith` as shown in the example above.
