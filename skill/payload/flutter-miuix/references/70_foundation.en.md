## Foundation

This chapter covers flutter_miuix's low-level infrastructure: popup registration and transitions ([MiuixPopupController] / [MiuixPopupHost] / [MiuixPopupScope] / [MiuixDialogLayout] / [MiuixPopupLayout]), squircle rounded corners ([MiuixSquircleBorder] / `addSquircleRect`), press feedback ([MiuixPressable]), content color propagation ([MiuixContentColor]), spring & damping utilities ([MiuixSpringEngine] / `obtainDampingDistance` etc.), runtime shader wrapper ([MiuixRuntimeShader]), scroll-end haptic feedback ([MiuixScrollEndHaptic]), and vector icons ([MiuixVectorIcon] / `miuixParsePath`).

### Popup registration & transitions

#### MiuixPopupTransitionBuilder

Type alias for the popup content transition builder. `MiuixPopupTransition.builder` is of this type; it receives `0..1` progress (0 = fully hidden, 1 = fully shown), the child, and returns the transitioned widget.

**Signature:**

```dart
typedef MiuixPopupTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);
```

| Parameter | Type | Description |
|---|---|---|
| `context` | `BuildContext` | Build context |
| `animation` | `Animation<double>` | Transition progress, always clamped to `0..1`; 0=fully hidden, 1=fully shown |
| `child` | `Widget` | The child to be transitioned |

#### MiuixPopupController

Controls the visibility of a dialog or plain popup. Extends `ChangeNotifier` and implements `ValueListenable<bool>`.

| Field / Method | Type | Description |
|---|---|---|
| `MiuixPopupController({visible = false})` | constructor | Initial visibility, default false |
| `visible` | `bool` | Current visibility; setter notifies listeners on change |
| `value` | `bool` | Current `ValueListenable` value, equivalent to `visible` |
| `visibleListenable` | `ValueListenable<bool>` | Returns `this`, convenient for animation listening |
| `show()` | `void` | Equivalent to `visible = true` |
| `dismiss()` | `void` | Equivalent to `visible = false` |
| `toggle()` | `void` | Equivalent to `visible = !visible` |

The controller can be retained across layout rebuilds or directly listened to via `visibleListenable`.

#### MiuixPopupTransition

Describes an enter or exit transition.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `builder` | `MiuixPopupTransitionBuilder` | required | Receives `0..1` progress, child; returns the transition widget |
| `duration` | `Duration` | required | Animation duration in non-spring mode |
| `curve` | `Curve` | `Curves.linear` | Curve in non-spring mode |
| `spring` | `SpringDescription?` | `null` | Spring mode; when non-null, spring simulation takes precedence |
| `visibilityThreshold` | `double` | `0.0001` | Tolerance for spring simulation |

The progress received by `builder` is always clamped to `0..1`; 0 = fully hidden, 1 = fully shown.

**Factory [MiuixPopupTransition.fade]**: fade-only transition.
```dart
MiuixPopupTransition.fade(
  duration: const Duration(milliseconds: 200),
  curve: Curves.easeOut,
)
```

#### MiuixPopupDefaults

Default popup transition definitions (`MiuixPopupDefaults._()` private constructor; all fields are `static final`).

| Field | Duration / Curve | Usage |
|---|---|---|
| `dialogDimEnter` | 300ms / decelerate | Dialog dim enter |
| `dialogDimExit` | 250ms / decelerate | Dialog dim exit |
| `popupDimEnter` | 300ms / sinOut | Plain popup dim enter |
| `popupDimExit` | 150ms / sinOut | Plain popup dim exit |
| `popupEnter` | 200ms / linear | Plain popup content enter (fade) |
| `popupExit` | 150ms / linear | Plain popup content exit (fade) |
| `largeDialogEnter` | 300ms / spring(stiffness=438.6, ratio=0.9) | Large-screen dialog enter: fade + 0.8→1 scale |
| `largeDialogExit` | 200ms / decelerate | Large-screen dialog exit: fade + scale to 0.8 |
| `smallDialogEnter` | 300ms / spring(stiffness=450, ratio=0.88) | Small-screen dialog enter: slide up from bottom |
| `smallDialogExit` | 200ms / decelerate | Small-screen dialog exit: slide down |

#### MiuixPopupEntry

Unified popup entry in the registry, extends `ChangeNotifier`. Usually not created manually; register via [MiuixDialogLayout] or [MiuixPopupLayout].

| Field | Type | Default | Description |
|---|---|---|---|
| `controller` | `MiuixPopupController` | required | Controller |
| `content` | `WidgetBuilder` | required | Content builder |
| `enterTransition` / `exitTransition` | `MiuixPopupTransition?` | `null` | Custom enter/exit transitions; null uses defaults |
| `enableWindowDim` | `bool` | `true` | Whether window dim is enabled |
| `dimEnterTransition` / `dimExitTransition` | `MiuixPopupTransition?` | `null` | Custom dim transitions; null uses defaults |
| `zIndex` | `double` | assigned by registry | Stack order |
| `orphaned` | `bool` | `false` | Whether the host has relinquished ownership (see below) |
| `isDialog` | `bool` | (overridden by subclass) | Whether this is a dialog entry |

**`orphaned` mechanism**: when `true`, the `_MiuixHostedEntry` is responsible for disposing of this entry after the exit animation finishes and the entry is removed from the registry; when `false`, the entry is still owned by the host, and the HostedEntry must not dispose of it — otherwise, when the host shows the dialog again, `addListener` would be called on an already-disposed `ChangeNotifier`, throwing use-after-dispose.

#### MiuixDialogEntry

Dialog entry, extends [MiuixPopupEntry].

| Extra parameter | Type | Default | Description |
|---|---|---|---|
| `enableAutoLargeScreen` | `bool` | `true` | Auto-switch enter/exit transitions by large/small screen |
| `dimAlpha` | `ValueListenable<double>?` | `null` | Dim alpha linkage (e.g., following scroll opacity) |
| `onDismissFinished` | `VoidCallback?` | `null` | Callback when exit animation finishes |

`isDialog` is always `true`.

#### MiuixPlainPopupEntry

Plain popup entry, extends [MiuixPopupEntry].

| Extra parameter | Type | Default | Description |
|---|---|---|---|
| `enableBackHandler` | `bool` | `true` | Whether to intercept the back button (only the topmost takes effect) |

`isDialog` is always `false`.

#### MiuixPopupRegistry

Holds the dialogs and plain popups in a mount layer and assigns z-order by registration order. Extends `ChangeNotifier`.

| Field / Method | Type | Description |
|---|---|---|
| `MiuixPopupRegistry.fallback` | `static` | Process-level fallback registry used when no [MiuixPopupScope] is installed |
| `dialogs` | `List<MiuixDialogEntry>` | Dialog entries (unmodifiable view) |
| `popups` | `List<MiuixPlainPopupEntry>` | Plain popup entries (unmodifiable view) |
| `isEmpty` | `bool` | Whether empty |
| `entries` | `Iterable<MiuixPopupEntry>` | All entries (dialogs first, then popups) |
| `contains(entry)` | `bool` | Whether the entry is present |
| `add(entry)` | `void` | Adds and assigns zIndex; auto-listens to controller/entry changes |
| `remove(entry)` | `void` | Removes and unlistens; resets zIndex when empty |

#### MiuixPopupScope

An [InheritedWidget] that provides local/root popup registries to a subtree. Each Scope has its own local registry; nested Scopes inherit the outermost root by default, and `establishRoot` establishes a new root boundary.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | required | Subtree |
| `registry` | `MiuixPopupRegistry?` | `null` | Custom local registry; null uses an internally created one |
| `establishRoot` | `bool` | `false` | Whether to establish a new root boundary |

| Static method | Returns | Description |
|---|---|---|
| `of(context, {root = false})` | `MiuixPopupRegistry` | Returns local or root of the current Scope; returns `fallback` if not wrapped |
| `maybeOf(context, {root = false})` | `MiuixPopupRegistry?` | Same as above, but returns null if not wrapped |

#### MiuixDialogLayout

Registers a dialog in the current Scope; does not paint anything itself (`build` returns `SizedBox.shrink()`).

| Parameter | Type | Default | Description |
|---|---|---|---|
| `controller` | `MiuixPopupController` | required | Controller |
| `content` | `WidgetBuilder?` | required | Content builder; null hides the dialog and auto-dismisses if visible |
| `enterTransition` / `exitTransition` | `MiuixPopupTransition?` | `null` | Custom enter/exit transitions |
| `enableWindowDim` | `bool` | `true` | Whether dim is enabled |
| `enableAutoLargeScreen` | `bool` | `true` | Switch transitions by large/small screen |
| `dimEnterTransition` / `dimExitTransition` | `MiuixPopupTransition?` | `null` | Custom dim transitions |
| `dimAlpha` | `ValueListenable<double>?` | `null` | Dim alpha linkage |
| `onDismissFinished` | `VoidCallback?` | `null` | Exit animation finished callback |
| `renderInRoot` | `bool` | `true` | Whether to register in the root registry (true) or local (false) |

#### MiuixPopupLayout

Registers a plain popup in the current Scope; does not paint anything itself.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `controller` | `MiuixPopupController` | required | Controller |
| `content` | `WidgetBuilder?` | required | Content builder; null hides the popup |
| `enterTransition` / `exitTransition` | `MiuixPopupTransition?` | `null` | Custom enter/exit transitions |
| `enableWindowDim` | `bool` | `true` | Whether dim is enabled |
| `enableBackHandler` | `bool` | `true` | Whether to intercept the back button |
| `dimEnterTransition` / `dimExitTransition` | `MiuixPopupTransition?` | `null` | Custom dim transitions |
| `renderInRoot` | `bool` | `true` | Whether to register in the root registry |

#### MiuixPopupHost

Paints all entries in the registry, intercepts lower-layer pointers, and handles the back button for the topmost plain popup.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget?` | `null` | Lower-layer content; when non-null, the Host acts directly as a Stack wrapper |
| `registry` | `MiuixPopupRegistry?` | `null` | Custom registry; null uses `MiuixPopupScope.of(context)` |
| `windowDimmingColor` | `Color` | `Color(0x4D000000)` | Default dim color |

**Back-button handling**: system back is intercepted via `PopScope`. `canPop` is `false` only when there is a visible popup with `enableBackHandler=true`; pressing back calls `controller.dismiss()` on the topmost popup.

**Typical usage** (app root):
```dart
MiuixPopupHost(
  child: MaterialApp(home: MyApp()),
)
```

#### MiuixPopupUtils

Convenience static utility entry point (`MiuixPopupUtils._()` private constructor; only `static` methods are exposed).

| Method | Equivalent to |
|---|---|
| `MiuixPopupUtils.dialogLayout({...})` | `MiuixDialogLayout(...)` |
| `MiuixPopupUtils.popupLayout({...})` | `MiuixPopupLayout(...)` |

#### `isMiuixLargeScreen(context)` → `bool`

Whether the current logical window meets the Miuix large-screen threshold: **width ≥ 840 and height ≥ 480**.

### Squircle rounded corners

The signature HyperOS smooth corner, approximating a superellipse with cubic Béziers (control ratio `0.643`).

#### SquircleDefaults

| Constant | Value | Description |
|---|---|---|
| `extension` | `1.1` | Tile size multiplier relative to `cornerRadius`; 1.0=arc, 1.1=continuous corner |
| `extensionMin` | `1.0` | Lower bound of `extension` |
| `extensionMax` | `2.0` | Upper bound of `extension` |

#### `addSquircleRect(path, width, height, cornerRadius, {extension, enabled})`

Appends a squircle rounded rectangle to [path].

| Parameter | Type | Default | Description |
|---|---|---|---|
| `path` | `Path` | required | Target Path |
| `width` / `height` | `double` | required | Pixel dimensions; non-positive values are skipped |
| `cornerRadius` | `double` | required | Corner radius; clamped to half the shorter side |
| `extension` | `double` | `SquircleDefaults.extension` | Tile multiplier; clamped to `[1.0, 2.0]` |
| `enabled` | `bool` | `true` | When false, falls back to a regular rounded rectangle |

#### MiuixSquircleBorder

A [ShapeBorder] whose outline is a squircle. Can be used directly with `ShapeDecoration`, `PhysicalShape`, `Material`, etc.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `cornerRadius` | `double` | `0.0` | Corner radius (logical pixels) |
| `extension` | `double` | `SquircleDefaults.extension` (1.1) | Tile multiplier |
| `enabled` | `bool` | `true` | Whether squircle is enabled; false falls back to a regular corner |
| `side` | `BorderSide` | `BorderSide.none` | Border |

Implements `dimensions`, `getInnerPath`, `getOuterPath`, `paint`, `scale`, `==`, `hashCode`, so it can be used directly as `ShapeDecoration.shape`.

**Example:**
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

Miuix-style pressable container. Overlays a translucent mask on the child; on press/hover/focus, the alpha is driven by springs, with optional sink (scale-down) or tilt (3D rotation) feedback.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `onPressed` | `VoidCallback?` | required | Click callback; null forces `enabled=false` |
| `child` | `Widget` | required | Child |
| `enabled` | `bool` | `true` | Whether enabled |
| `feedbackType` | `MiuixPressFeedbackType` | `none` | Extra feedback type |
| `sinkAmount` | `double` | `0.94` | Sink feedback scale target |
| `tiltAmount` | `double` | `8.0` | Tilt feedback max angle (degrees) |
| `overlayColor` | `Color?` | `null` | Mask color; null uses `MiuixTheme.colors.onBackground` |
| `borderRadius` | `BorderRadius?` | `null` | Mask corner radius; mutually exclusive with `shape` |
| `shape` | `ShapeBorder?` | `null` | Mask shape (e.g., squircle/stadium); takes precedence over `borderRadius` |
| `heldDown` | `bool` | `false` | Externally forced "held-down" state (used by Preference, menu items) |
| `autofocus` | `bool` | `false` | Whether to autofocus |
| `focusNode` | `FocusNode?` | `null` | External focus node |
| `semanticLabel` | `String?` | `null` | Accessibility label |
| `button` | `bool` | `true` | Whether to mark as button semantics (set false for Checkbox/Switch) |
| `behavior` | `HitTestBehavior` | `opaque` | Hit-test behavior |
| `onLongPress` | `VoidCallback?` | `null` | Long-press callback |

#### MiuixPressFeedbackType

Press visual feedback type.

| Value | Description |
|---|---|
| `none` | No feedback (only the press mask) |
| `sink` | Slight scale-down on press |
| `tilt` | 3D tilt based on touch position on press |

**Mask alpha increments**: hover `+0.06`, focus `+0.08`, press `+0.10`; they stack.

**Example:**
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

Propagates a default "content color" (text/icon color) to the subtree. Pushed by containers like `MiuixSurface` / `MiuixCard` / `MiuixButton` so children like `MiuixText` / `MiuixIcon` can pick it up by default.

| Parameter / Method | Type | Default | Description |
|---|---|---|---|
| `color` | `Color` | required | Content color |
| `child` | `Widget` | required | Subtree |
| `MiuixContentColor.of(context)` | `Color` | — | Returns the nearest ancestor's content color; black if not wrapped |

### Spring & damping utilities

The underlying math and per-frame engine for Folme spring motion.

#### MiuixSpringDefaults

| Constant | Value | Description |
|---|---|---|
| `maxFrameDeltaSeconds` | `0.016` | Max per-frame step (seconds) |
| `minFrameDeltaSeconds` | `0.001` | Min per-frame step (seconds) |
| `highVelocityThreshold` | `5000.0` | High-velocity threshold; above it, a slower natural period is used |
| `criticalDampingRatio` | `1.0` | Critical damping ratio |
| `standardSpringPeriod` | `0.4` | Standard natural period (seconds) |
| `slowerSpringPeriodForHighVelocity` | `0.55` | Natural period used at high velocity (seconds) |

#### `obtainDampingDistance(normalizedInput, range)` → `double`

Damping formula is `x - x² + x³/3`; `normalizedInput` is clamped to `0..1` and multiplied by `range`.

#### `obtainTouchDistance(currentPixelOffset, range)` → `double`

Inverts damped displacement back to touch displacement. Formula: `range - range^(2/3) * (range - 3*offset)^(1/3)`.

#### MiuixSpringOperator

Computes the next-frame velocity via explicit Euler integration.

| Parameter | Description |
|---|---|
| `dampingRatio` | Damping ratio |
| `naturalPeriod` | Natural period (seconds, >0) |

`updateVelocity({currentVelocity, deltaTime, currentPosition, targetPosition})` returns the new velocity.

#### MiuixSpringEngine

Critically damped per-frame engine. You can manually `start`/`step`, or drive it with a Flutter `Ticker` via `runSettleAnimation`.

| Method | Description |
|---|---|
| `start({startValue, targetValue, initialVelocity})` | Initializes a spring motion from `startValue` to `targetValue`; automatically picks `standard`/`slower` period by initial velocity |
| `step(deltaTime)` → `bool` | Advances one frame; returns true when equilibrium is reached |
| `runSettleAnimation({vsync, startValue, targetValue = 0, initialVelocity, onFrame, onSettle})` → `Future<void>` | Drives to equilibrium via `Ticker`, calling `onFrame(currentPosition)` each frame; `onSettle` is called on both normal completion and cancellation |

Fields `velocity` and `currentPosition` expose the current state.

### Runtime shader wrapper

#### `isRenderEffectSupported()` → `bool`

Always `true`. Flutter's `ImageFilter` / `BackdropFilter` is available on all target platforms.

#### `isRuntimeShaderSupported()` → `bool`

Always `true`. Flutter's `FragmentProgram` is available on both Impeller and Skia.

#### MiuixRuntimeShader

Cross-platform wrapper for runtime shaders.

Flutter's `FragmentShader` is produced only from **precompiled `.frag` assets** (via impellerc), with uniforms set by **index** (`setFloat(index, value)`). This wrapper translates names to indices via `uniformLayout` (uniform name → starting float index), enabling a "set uniform by name" call style.

| Parameter / Field | Type | Description |
|---|---|---|
| `MiuixRuntimeShader.fromProgram(program, {uniformLayout, samplerLayout})` | constructor | Constructs from a loaded `FragmentProgram` |
| `shader` | `ui.FragmentShader` | Underlying shader; can be used directly as a `ui.Shader` for `Paint..shader` |
| `uniformLayout` | `Map<String, int>` | uniform name → starting float index |
| `samplerLayout` | `Map<String, int>` | sampler name → sampler index |

| Method | Description |
|---|---|
| `setFloatUniform(name, value)` | Sets a single float uniform |
| `setFloat2Uniform(name, v1, v2)` | Sets a vec2 uniform |
| `setFloat3Uniform(name, v1, v2, v3)` | Sets a vec3 uniform |
| `setFloat4Uniform(name, v1, v2, v3, v4)` | Sets a vec4 uniform |
| `setFloatArrayUniform(name, values)` | Sets a float-array uniform |
| `setColorUniform(name, color)` | Sets a color uniform (RGBA 0..1) |
| `setInputShader(name, image)` | Sets a sampler (takes a `ui.Image`) |
| `dispose()` | Releases the underlying `FragmentShader` |

Names not registered in `uniformLayout` / `samplerLayout` throw `ArgumentError`.

### MiuixScrollEndHaptic

Triggers a haptic feedback when scrollable content is **flung to** the start/end boundary.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `hapticFeedbackType` | `MiuixHapticFeedbackType` | `textHandleMove` | Haptic type |
| `child` | `Widget` | required | Subtree containing scrollable children |

#### MiuixHapticFeedbackType

| Value | Description | Flutter mapping |
|---|---|---|
| `textHandleMove` | Light selection feedback (default; Android `TextHandleMove`) | `HapticFeedback.selectionClick` |
| `lightImpact` | Light impact | `HapticFeedback.lightImpact` |
| `mediumImpact` | Medium impact | `HapticFeedback.mediumImpact` |
| `heavyImpact` | Heavy impact | `HapticFeedback.heavyImpact` |

**State machine**: scrolling from the boundary back into content (when `scrollDelta` exceeds `1.0`) resets the state; only inertial overscroll (`OverscrollNotification` with `dragDetails == null`) is handled — drag overscroll does not trigger; each boundary hit fires only once to avoid jitter.

**Example:**
```dart
MiuixScrollEndHaptic(
  child: ListView(children: [...]),
)
```

### Vector icons

#### MiuixVectorPath

Description of a single vector path.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `build` | `Path Function()` | required | Builds the path (viewport coordinates); a callback avoids sharing mutable Path |
| `style` | `PaintingStyle` | `fill` | Fill or stroke |
| `color` | `Color` | `Color(0xFF000000)` | Original vector color (`SolidColor`); used only when not tinted |
| `alpha` | `double` | `1.0` | Opacity (corresponds to `fillAlpha` / `strokeAlpha`) |
| `strokeWidth` | `double` | `0.0` | Stroke width (0 = 1px hairline) |
| `strokeCap` | `StrokeCap` | `butt` | Stroke cap |
| `groupTransform` | `Matrix4?` | `null` | Group transform in viewport coordinates (e.g., vertical flip) |

#### MiuixVectorIcon

Vector icon.

| Parameter | Type | Description |
|---|---|---|
| `name` | `String` | Icon name (used for debugging and semantic fallback) |
| `viewport` | `Size` | Viewport size for path coordinates (`viewportWidth/Height`) |
| `intrinsicSize` | `Size` | Default render size (`defaultWidth/Height`, logical pixels); used when [MiuixIcon] does not specify a size |
| `paths` | `List<MiuixVectorPath>` | All paths of the icon (in paint order) |

#### MiuixVectorIconPainter

A `CustomPainter` that draws [MiuixVectorIcon] onto a **viewport-sized** canvas; outer scaling is handled by `FittedBox`.

| Parameter | Type | Description |
|---|---|---|
| `icon` | `MiuixVectorIcon` | Vector icon |
| `tint` | `Color?` | Tint color; when non-null, applies `ColorFilter.mode(tint, BlendMode.srcIn)` to the whole vector; null draws with original vector colors (multi-color / untinted scenarios) |

#### `miuixEvenOddPath()` → `Path`

Constructs an empty [Path] with the even-odd fill rule, convenient for chaining `..moveTo(...)` in icon definitions.

#### `miuixParsePath(data, {fillType})` → `Path`

Parses an SVG-style path data string into a [Path]. Used by extended icons (miuix-icons, 156×5 variants).

Supported commands (**absolute coordinates only**):

| Command | Meaning | Args |
|---|---|---|
| `M x y` | Move to | 2 |
| `L x y` | Line to | 2 |
| `Q x1 y1 x y` | Quadratic Bézier | 4 |
| `C x1 y1 x2 y2 x y` | Cubic Bézier | 6 |
| `Z` | Close | 0 |

Numbers are whitespace-separated; command letters are individual tokens. `fillType` defaults to `nonZero`.

> `HorizontalTo` / `VerticalTo` are expanded to full `L x y` at generation time, so H/V do not need to be handled here.
