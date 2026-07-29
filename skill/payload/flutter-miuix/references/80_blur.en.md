## Liquid Glass & Blur

This chapter covers flutter_miuix's liquid-glass effects: backdrop capture ([MiuixBackdrop] / [MiuixLayerBackdrop] / [MiuixLayerBackdropCapture]), texture blur ([MiuixTextureBlur]), bloom highlight border ([MiuixHighlight] / [BloomStroke] / [LightSource]), and blur defaults ([MiuixBlurDefaults] / [BlurColors] / [BlurBlendMode]).

[MiuixTextureBlur]'s Gaussian blur is delegated to Skia/Impeller's `ui.ImageFilter.blur` (internally separable two-pass + progressive downsampling, grain-free), with sigma taken from the original `BLUR_RADIUS_TO_SIGMA=0.45`; color controls (brightness/contrast/saturation) use an equivalent `ColorFilter.matrix`. [MiuixHighlight]'s bloom border is still based on the precompiled shader `shaders/miuix_bloom_stroke.frag`.

> The top bar has a simpler frosted-glass path: `MiuixTopAppBar(blurred: true)` uses `BackdropFilter` to blur the content behind it, with no backdrop capture needed (see the "Navigation & Scaffold" chapter).

### Backdrop capture

#### MiuixBackdrop

Abstract base class for backdrop content providers, extends `ChangeNotifier`. Blur components (e.g., [MiuixTextureBlur]) use it to access "the content behind themselves" to blur.

| Field / Method | Type | Description |
|---|---|---|
| `isCoordinatesDependent` | `bool` | Whether layout coordinates are needed (true for layer backdrop) |
| `snapshot` | `ui.Image?` | Current backdrop snapshot available for sampling; null when not captured |
| `globalOffset` | `Offset?` | Top-left of the snapshot in the global (window) coordinate system |
| `pixelRatio` | `double` | Device pixel ratio of the snapshot |

#### MiuixLayerBackdrop

A [MiuixBackdrop] backed by a captured layer snapshot.

| Field / Method | Type | Description |
|---|---|---|
| `MiuixLayerBackdrop()` | constructor | Creates directly; must be disposed |
| `isCoordinatesDependent` | `bool` | Always `true` |
| `updateSnapshot(image, globalOffset, pixelRatio)` | `void` | Called by [MiuixLayerBackdropCapture] after each frame's capture; the old snapshot is disposed after replacement |

#### MiuixLayerBackdropCapture

A `SingleChildRenderObjectWidget` that captures a subtree's render output to [backdrop] for blur components to sample.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `backdrop` | `MiuixLayerBackdrop` | required | Backdrop that receives the snapshot |
| `child` | `Widget` | required | Container that should appear as the blur background |

**Implementation notes**:
- This node is a repaint boundary (`isRepaintBoundary = true`); Flutter allocates an `OffsetLayer` for it.
- After each frame's `paint`, an `addPostFrameCallback` asynchronously calls `OffsetLayer.toImageSync` to capture, avoiding reentrant layer issues from re-recording the subtree.
- After capture, the global offset is computed via `localToGlobal(Offset.zero)` and passed to `backdrop.updateSnapshot` along with `pixelRatio`.

**Example:**
```dart
final backdrop = MiuixLayerBackdrop();

Widget tree = Column(
  children: [
    MiuixLayerBackdropCapture(
      backdrop: backdrop,
      child: const MyBackground(), // container that should appear as the blur background
    ),
    MiuixTextureBlur(
      backdrop: backdrop,
      blurRadius: 24,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Liquid glass'),
      ),
    ),
  ],
);
// ... dispose backdrop when done
```

### Texture blur

#### MiuixTextureBlur

Performs a Gaussian blur on the background provided by [backdrop] and overlays the child. The blur is done with `ui.ImageFilter.blur` (separable two-pass + progressive downsampling, grain-free); color controls use `ColorFilter.matrix`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `backdrop` | `MiuixBackdrop` | required | Backdrop provider |
| `shape` | `ShapeBorder?` | `null` | Clip shape (null = rectangle) |
| `blurRadius` | `double` | `MiuixBlurDefaults.blurRadius` (20.0) | Blur radius (dp), auto-clamped to `[0, maxBlurRadius]`; sigma = blurRadius × 0.45 |
| `colors` | `BlurColors` | `BlurColors()` | Post-blur color adjustment |
| `enabled` | `bool` | `true` | When false, only the child is drawn |
| `child` | `Widget?` | `null` | Child overlaid on the blur layer |

**Notes**:
- The backdrop snapshot is sampled with an extra ~3σ margin (with `TileMode.clamp`) so blur edges have real neighbors and don't darken; drawing is clipped to the widget's own bounds (`clipRect`), so it never overflows (even without a shape).
- Blur appears on the first frame once the snapshot is ready (no async shader load).

### Bloom highlight border

A rounded-rectangle SDF + 3D hemispherical rim normal + directional light, drawing an illuminated glass edge; composited with `BlendMode.plus`.

#### LightPosition

3D position of a light source (normalized UV).

| Field | Type | Description |
|---|---|---|
| `x` / `y` | `double` | UV position in `[0,1]`; `(0.5, 0.7)` is the reference origin (no contribution there) |
| `z` | `double` | Signed depth; negative places the light behind the surface |

The shader normalizes `(x-0.5, y-0.7, z)` into a direction.

#### LightSource

A directional light.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `position` | `LightPosition` | required | Light position |
| `color` | `Color` | `Color(0xFFFFFFFF)` | Light color |
| `intensity` | `double` | `1.0` | Intensity |

#### BloomStroke

Shading model for the edge bloom stroke.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `color` | `Color` | `Color(0x0DFFFFFF)` (White @ 0.05) | Tile stroke color (alpha scales stroke contribution) |
| `blendMode` | `BlendMode` | `BlendMode.plus` | Composite mode |
| `innerBlurRadius` | `double` | `2.8` | Inner glow depth (dp) |
| `primaryLight` | `LightSource` | see below | Primary light |
| `secondaryLight` | `LightSource` | see below | Secondary light |
| `dualPeak` | `bool` | `false` | Whether each light produces two opposing peaks (Apple-style sweep) |

Default primary light: `LightPosition(0.5, 0.5, -0.5)`, intensity `0.4`; secondary light: `LightPosition(0.5, 0.8, -0.5)`, intensity `0.25`.

**6 GlassStroke presets**:

| Static constant | innerBlurRadius | Primary intensity | Secondary intensity |
|---|---|---|---|
| `glassStrokeBigLight` | 3.5 | 0.3 | 0.2 |
| `glassStrokeMiddleLight` | 2.8 | 0.4 | 0.25 |
| `glassStrokeSmallLight` | 2.6 | 0.6 | 0.35 |
| `glassStrokeBigDark` | 1.7 | 0.4 | 0.25 |
| `glassStrokeMiddleDark` | 2.0 | 0.5 | 0.25 |
| `glassStrokeSmallDark` | 2.3 | 0.6 | 0.25 |

#### Highlight

Highlight configuration.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `width` | `double` | `0.8` | Stroke band width (dp) |
| `alpha` | `double` | `1.0` | Overall opacity |
| `style` | `BloomStroke` | `BloomStroke.glassStrokeMiddleLight` | Shading model |

**6 static presets**: `Highlight.glassStrokeBigLight` / `glassStrokeMiddleLight` / `glassStrokeSmallLight` / `glassStrokeBigDark` / `glassStrokeMiddleDark` / `glassStrokeSmallDark`, each wrapping the corresponding `BloomStroke` preset.

`Highlight.defaultHighlight = Highlight.glassStrokeMiddleLight` (default for standard light cards).

#### MiuixHighlight

A `StatefulWidget` that draws a bloom highlight border on top of its child.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `highlight` | `Highlight` | `Highlight.defaultHighlight` | Highlight configuration |
| `shape` | `ShapeBorder?` | `null` | Rounded shape (reads four corner radii; null = capsule/full round) |
| `child` | `Widget?` | `null` | Child; null fills the parent |

**Implementation notes**:
- The shader program is loaded asynchronously as a singleton (`packages/flutter_miuix/shaders/miuix_bloom_stroke.frag`); until ready, only the child is drawn.
- Drawing is skipped when `width <= 0` or `alpha <= 0`.
- Four corner pixel radii are resolved via `RoundedRectangleBorder`; otherwise half the shorter side is used as a full round.
- The current implementation is the single-peak variant (default `dualPeak=false`, covering all built-in presets).

### Blur defaults & color configuration

#### MiuixBlurDefaults

Blur effect defaults. `MiuixBlurDefaults._()` private constructor; all fields are `static`.

| Constant | Value | Description |
|---|---|---|
| `blurRadius` | `20.0` | Default blur radius (dp) |
| `noiseCoefficient` | `0.0045` | Default noise jitter coefficient (anti-banding) |
| `progressiveNoiseCoefficient` | `0.0` | Default noise coefficient for progressive blur (0 = disabled) |
| `maxBlurRadius` | `150.0` | Maximum blur radius (dp) |
| `blurRadiusToSigma` | `0.45` | Conversion coefficient from blur radius to Gaussian sigma |
| `blurKernelReach` | `13` | Blur kernel reach (source pixels) |

#### `MiuixBlurDefaults.blurColors({blendColors, brightness, contrast, saturation})` → `BlurColors`

Convenience factory for [BlurColors].

#### BlurColors

Color configuration applied after blur.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `blendColors` | `List<BlendColorEntry>` | `const []` | Stacked onto the blurred background in order |
| `brightness` | `double` | `0.0` | Brightness adjustment `[-1,1]`; 0 = no change |
| `contrast` | `double` | `1.0` | Contrast multiplier; 1 = no change |
| `saturation` | `double` | `1.0` | Saturation multiplier; 1 = no change |

Implements `==` / `hashCode`.

#### BlendColorEntry

A single color blend stacked on the blurred background.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `color` | `Color` | required | Overlay color |
| `mode` | `BlurBlendMode` | `BlurBlendMode.srcOver` | Blend mode |

Implements `==` / `hashCode`.

#### BlurBlendMode

Blur color blend mode. `value` is the raw mode identifier.

- `0-28`: standard `SkBlendMode` (GPU-processed), one-to-one with Flutter `BlendMode`.
- `>=100`: extended custom modes (Lab / linear light, etc., handled by runtime shader).

**Standard modes** (selected): `clear=0`, `src=1`, `dst=2`, `srcOver=3`, `dstOver=4`, `srcIn=5`, `dstIn=6`, `srcOut=7`, `dstOut=8`, `srcAtop=9`, `dstAtop=10`, `xor=11`, `plus=12`, `modulate=13`, `screen=14`, `overlay=15`, `darken=16`, `lighten=17`, `colorDodge=18`, `colorBurn=19`, `hardLight=20`, `softLight=21`, `difference=22`, `exclusion=23`, `multiply=24`, `hue=25`, `saturationMode=26`, `colorMode=27`, `luminosity=28`.

**Extended modes** (selected): `linearLight=100`, `linearLightWithGreyscale=101`, `miDifference=102`, `labLightenWithGreyscale=103`, `labDarkenWithGreyscale=105`, `lab=106`, `linearLightLab=107`, `miColorDodge=118`, `miColorBurn=119`, `plusDarker=120`, `plusLighter=121`, `alphaBlend=200`, `miSaturation=201`, `miBrightness=202`, `miLuminance=203`.

> Extended modes require runtime shader support. In the current phase, they are skipped in `MiuixTextureBlur`'s `blendColors` (only standard modes 0-28 are implemented directly via Flutter `BlendMode` color blocks).

#### `miuixStandardBlendMode(mode)` → `BlendMode?`

Maps a [BlurBlendMode] to a native Flutter [BlendMode] (standard modes 0-28 only). Extended modes (>=100) return null and require a runtime shader.

### Full example: liquid-glass card

```dart
class _GlassState extends State<MyGlass> {
  final _backdrop = MiuixLayerBackdrop();

  @override
  void dispose() {
    _backdrop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background content (to be blurred)
        Positioned.fill(
          child: MiuixLayerBackdropCapture(
            backdrop: _backdrop,
            child: const MyScrollableContent(),
          ),
        ),
        // Frosted-glass card + bloom highlight border
        Center(
          child: SizedBox(
            width: 220, height: 140,
            child: MiuixHighlight(
              highlight: Highlight.glassStrokeMiddleLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: MiuixTextureBlur(
                backdrop: _backdrop,
                shape: const MiuixSquircleBorder(cornerRadius: 28),
                blurRadius: 24,
                colors: MiuixBlurDefaults.blurColors(saturation: 1.5),
                child: const Center(child: Text('Liquid glass')),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

> For a top-bar frosted glass, prefer `MiuixTopAppBar(blurred: true)` — no backdrop capture needed.
