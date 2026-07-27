## Buttons & Display

### MiuixButton

A Miuix-style button with secondary colors by default; tappable with a press overlay.

| Parameter | Type | Default | Description |
|---|---|---|---|
| onPressed | VoidCallback? | required | Tap callback; null disables the button |
| child | Widget | required | Button content |
| enabled | bool | true | Whether the button is enabled |
| cornerRadius | double | 16 | Squircle corner radius |
| minWidth | double | 58 | Minimum width |
| minHeight | double | 40 | Minimum height |
| colors | MiuixButtonColors? | null (defaults to `MiuixButtonDefaults.buttonColors`, secondary) | Color configuration |
| insideMargin | EdgeInsetsGeometry | `EdgeInsets.symmetric(horizontal: 16, vertical: 13)` | Inner padding |

**Example:**
```dart
MiuixButton(
  onPressed: () {},
  child: const MiuixText('OK'),
)
```

### MiuixTextButton

A text button that builds a `MiuixButton` internally with centered text.

| Parameter | Type | Default | Description |
|---|---|---|---|
| text | String | required (positional) | Button text |
| onPressed | VoidCallback? | required | Tap callback; null disables the button |
| enabled | bool | true | Whether the button is enabled |
| cornerRadius | double | 16 | Squircle corner radius |
| minWidth | double | 58 | Minimum width |
| minHeight | double | 40 | Minimum height |
| colors | MiuixButtonColors? | null (defaults to secondary colors) | Color configuration |
| insideMargin | EdgeInsetsGeometry | `EdgeInsets.symmetric(horizontal: 16, vertical: 13)` | Inner padding |
| textStyle | TextStyle? | null (defaults to `textStyles.button`) | Text style |

**Example:**
```dart
MiuixTextButton('Cancel', onPressed: () {})
```

### MiuixButtonColors

Button color configuration; all four fields are required.

| Parameter | Type | Default | Description |
|---|---|---|---|
| color | Color | required | Container background color |
| disabledColor | Color | required | Container background color when disabled |
| contentColor | Color | required | Content color |
| disabledContentColor | Color | required | Content color when disabled |

**Example:**
```dart
const MiuixButtonColors(
  color: Colors.blue,
  disabledColor: Colors.blueGrey,
  contentColor: Colors.white,
  disabledContentColor: Colors.white70,
)
```

### MiuixButtonDefaults

Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| minWidth | `58` | Minimum width |
| minHeight | `40` | Minimum height |
| cornerRadius | `16` | Squircle corner radius |
| insideMargin | `EdgeInsets.symmetric(horizontal: 16, vertical: 13)` | Inner padding |

| Static Method | Returns | Description |
|---|---|---|
| buttonColors(BuildContext) | `MiuixButtonColors` | Default secondary button colors |
| buttonColorsPrimary(BuildContext) | `MiuixButtonColors` | Primary button colors |

### MiuixIconButton

A Miuix-style icon button; circular by default (diameter 40) with a transparent background.

| Parameter | Type | Default | Description |
|---|---|---|---|
| onPressed | VoidCallback? | required | Tap callback; null disables the button |
| child | Widget | required | Icon content |
| enabled | bool | true | Whether the button is enabled |
| backgroundColor | Color? | null | Background color; null means transparent |
| cornerRadius | double | 40 | Corner radius (circular by default) |
| minHeight | double | 40 | Minimum height |
| minWidth | double | 40 | Minimum width |
| holdDownState | bool | false | Force the held-down visual state (e.g. while a dropdown is open) |

**Example:**
```dart
MiuixIconButton(
  onPressed: () {},
  child: MiuixIcon(vector: MiuixIcons.extended.byName('settings')!),
)
```

### MiuixIconButtonDefaults

Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| minWidth | `40` | Minimum width |
| minHeight | `40` | Minimum height |
| cornerRadius | `40` | Corner radius (circular, diameter 40) |

### MiuixFloatingActionButton

A Miuix-style floating action button with a circular background and shadow; content color inherits `onSurface` by default.

| Parameter | Type | Default | Description |
|---|---|---|---|
| onPressed | VoidCallback? | required | Tap callback; null disables the button |
| child | Widget | required | Child widget |
| enabled | bool | true | Whether the button is enabled |
| shape | ShapeBorder | `StadiumBorder()` | Shape |
| containerColor | Color? | null (defaults to `colors.primary`) | Container background color |
| shadowElevation | double | 4 | Shadow elevation (logical pixels) |
| minWidth | double | 60 | Minimum width |
| minHeight | double | 60 | Minimum height |

**Example:**
```dart
MiuixFloatingActionButton(
  onPressed: () {},
  child: MiuixIcon(vector: MiuixIcons.extended.byName('add')!),
)
```

### MiuixFloatingActionButtonDefaults

Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| minWidth | `60` | Default minimum width |
| minHeight | `60` | Default minimum height |
| shadowElevation | `4` | Default shadow elevation |
| shape | `StadiumBorder()` | Default shape; a circle under square bounds, a capsule under rectangular bounds |

### MiuixCard

A Miuix-style card with squircle corners; propagates content color downward, with optional tap and press feedback.

| Parameter | Type | Default | Description |
|---|---|---|---|
| cornerRadius | double | 16 | Corner radius |
| insideMargin | EdgeInsetsGeometry | `EdgeInsets.zero` | Inner padding |
| colors | MiuixCardColors? | null (defaults to surfaceContainer / onSurfaceContainer) | Color configuration |
| onPressed | VoidCallback? | null | Tap callback |
| onLongPress | VoidCallback? | null | Long-press callback |
| feedbackType | MiuixPressFeedbackType | `MiuixPressFeedbackType.none` | Press feedback type (none / sink / tilt) |
| child | Widget? | null | Child widget |

**Example:**
```dart
const MiuixCard(
  insideMargin: EdgeInsets.all(16),
  child: MiuixText('Card content'),
)
```

### MiuixCardColors

Card color configuration; both fields are required.

| Parameter | Type | Default | Description |
|---|---|---|---|
| color | Color | required | Container background color |
| contentColor | Color | required | Content color |

**Example:**
```dart
const MiuixCardColors(
  color: Colors.white,
  contentColor: Colors.black,
)
```

### MiuixCardDefaults

Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| cornerRadius | `16` | Default corner radius |
| insideMargin | `EdgeInsets.zero` | Default inner padding |

| Static Method | Returns | Description |
|---|---|---|
| defaultColors(BuildContext) | `MiuixCardColors` | Default colors: surfaceContainer / onSurfaceContainer |

### MiuixSurface

A Miuix-style surface providing background color, content color, border, and shadow; propagates content color downward.

| Parameter | Type | Default | Description |
|---|---|---|---|
| color | Color? | null (defaults to `colors.surface`) | Background color |
| contentColor | Color? | null (defaults to `colors.onSurface`) | Content color |
| cornerRadius | double | 0 | Corner radius; 0 means square corners |
| squircleEnabled | bool | true | Whether squircle corners are enabled |
| border | Border? | null | Border |
| shadowElevation | double | 0 | Shadow elevation (logical pixels) |
| onPressed | VoidCallback? | null | Tap callback; when non-null the surface is tappable |
| enabled | bool | true | Whether tapping is enabled |
| child | Widget | required | Child widget |

**Example:**
```dart
const MiuixSurface(
  cornerRadius: 12,
  child: MiuixText('Surface content'),
)
```

### MiuixBadge

A Miuix-style badge. When `child` is null it draws a 6x6 dot; otherwise a capsule of at least 16x16.

| Parameter | Type | Default | Description |
|---|---|---|---|
| containerColor | Color? | null (defaults to `colors.error`) | Container background color |
| contentColor | Color? | null (defaults to `colors.onError`) | Content color |
| child | Widget? | null | Content; a dot is shown when null |

**Example:**
```dart
const MiuixBadge(child: MiuixText('9'))
```

### MiuixBadgeDefaults

Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| size | `6` | Default size of the dot badge without content |
| largeSize | `16` | Default minimum size of the badge with content |

| Static Method | Returns | Description |
|---|---|---|
| containerColor(BuildContext) | `Color` | Default container color; maps to theme `error` |
| contentColor(BuildContext) | `Color` | Default content color; maps to theme `onError` |

### MiuixBadgedBox

A container that places a badge at the anchor's top-right corner; the box size is determined by `child`, and placement mirrors under RTL.

| Parameter | Type | Default | Description |
|---|---|---|---|
| badge | Widget | required | The badge (usually a `MiuixBadge`) |
| child | Widget | required | Anchor child |
| topBound | double? | null | Top clamp bound; no clamping by default |
| endBound | double? | null | End-direction clamp bound; no clamping by default |

**Example:**
```dart
MiuixBadgedBox(
  badge: const MiuixBadge(),
  child: MiuixIcon(vector: MiuixIcons.extended.byName('messages')!),
)
```

### MiuixHorizontalDivider

A horizontal divider that fills the available width; default thickness 0.75.

| Parameter | Type | Default | Description |
|---|---|---|---|
| thickness | double | 0.75 | Line thickness |
| color | Color? | null (defaults to `colors.dividerLine`) | Line color |

**Example:**
```dart
const MiuixHorizontalDivider()
```

### MiuixVerticalDivider

A vertical divider that fills the available height; default thickness 0.75.

| Parameter | Type | Default | Description |
|---|---|---|---|
| thickness | double | 0.75 | Line thickness |
| color | Color? | null (defaults to `colors.dividerLine`) | Line color |

**Example:**
```dart
const SizedBox(height: 24, child: MiuixVerticalDivider())
```

### MiuixDividerDefaults

Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| thickness | `0.75` | Default thickness 0.75dp |

| Static Method | Returns | Description |
|---|---|---|
| dividerColor(BuildContext) | `Color` | Default color, taken from `MiuixTheme.colors.dividerLine` |

### MiuixSmallTitle

A small title using the `subtitle` style (14sp bold), default color `onBackgroundVariant`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| text | String | required (positional) | Title text |
| textColor | Color? | null (defaults to `colors.onBackgroundVariant`) | Text color |
| insideMargin | EdgeInsetsGeometry | `EdgeInsets.symmetric(horizontal: 28, vertical: 8)` | Inner padding |

**Example:**
```dart
const MiuixSmallTitle('Section title')
```

### MiuixBasicComponent

The Miuix basic row, widely used by extension components; an internal RenderBox reproduces the 2:5:3 start/center/end measurement constraints.

| Parameter | Type | Default | Description |
|---|---|---|---|
| title | String? | null | Title text |
| titleColor | MiuixBasicComponentColors? | null (defaults to `titleColor`) | Title color configuration |
| summary | String? | null | Summary text |
| summaryColor | MiuixBasicComponentColors? | null (defaults to `summaryColor`) | Summary color configuration |
| startAction | Widget? | null | Start action |
| endActions | List\<Widget\>? | null | End action list |
| bottomAction | Widget? | null | Bottom action |
| insideMargin | EdgeInsetsGeometry | `EdgeInsets.all(16)` | Inner padding |
| onClick | VoidCallback? | null | Tap callback |
| onClickLabel | String? | null | Accessibility tap label |
| role | MiuixBasicComponentRole? | null | Accessibility role (button / checkbox / radioButton / switchControl / tab / dropdownList) |
| holdDownState | bool | false | Force the held-down visual state |
| enabled | bool | true | Whether the component is enabled |
| content | List\<Widget\>? | null | Custom center content; built from title/summary when null |

**Example:**
```dart
MiuixBasicComponent(
  title: 'Title',
  summary: 'Summary',
  onClick: () {},
)
```

### MiuixBasicComponentRole

Accessibility role enum for BasicComponent.

| Value | Description |
|---|---|
| button | Button |
| checkbox | Checkbox |
| radioButton | Radio button |
| switchControl | Switch |
| tab | Tab |
| dropdownList | Dropdown list |

### MiuixBasicComponentColors

BasicComponent color configuration; both fields are required.

| Parameter | Type | Default | Description |
|---|---|---|---|
| color | Color | required | Color when enabled |
| disabledColor | Color | required | Color when disabled |

**Example:**
```dart
const MiuixBasicComponentColors(
  color: Colors.black,
  disabledColor: Colors.grey,
)
```

### MiuixBasicComponentDefaults

Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| insideMargin | `EdgeInsets.all(16)` | Default padding around the component, 16 logical pixels on all sides |

| Static Method | Returns | Description |
|---|---|---|
| titleColor(BuildContext) | `MiuixBasicComponentColors` | Default title color |
| summaryColor(BuildContext) | `MiuixBasicComponentColors` | Default summary color |

### MiuixText

Miuix-style text; default style `textStyles.main`, color taken from `MiuixContentColor`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| text | String | required (positional) | Text content |
| color | Color? | null (defaults to content color; explicit color has highest priority) | Text color |
| fontSize | double? | null | Font size |
| fontWeight | FontWeight? | null | Font weight |
| fontFamily | String? | null | Font family |
| letterSpacing | double? | null | Letter spacing |
| fontStyle | FontStyle? | null | Font style |
| decoration | TextDecoration? | null | Text decoration |
| textAlign | TextAlign? | null | Text alignment |
| height | double? | null | Line height |
| maxLines | int? | null | Maximum number of lines |
| overflow | TextOverflow? | null | Overflow handling |
| softWrap | bool | true | Whether to soft-wrap |
| style | TextStyle? | null (defaults to `textStyles.main`) | Base style |

**Example:**
```dart
const MiuixText('Hello, Miuix')
```

### MiuixIcon

Miuix-style icon. Provide exactly one of `icon` / `vector` / `child`; monochrome icons are tinted via `tint`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| icon | IconData? | null | Material icon data |
| vector | MiuixVectorIcon? | null | Built-in Miuix vector icon |
| child | Widget? | null | Custom icon widget (e.g. multicolor icons) |
| tint | Color? | null (defaults to content color; pass `kMiuixTintUnspecified` to disable tinting) | Tint color |
| contentDescription | String? | null | Accessibility label; no Semantics wrapper when null |
| size | double? | null (the `icon` path falls back to 24) | Icon size |

**Example:**
```dart
MiuixIcon(vector: MiuixIcons.extended.byName('favoritesFill')!, size: 24)
```

### MiuixIconDefaults

Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| defaultSize | `24` | Default icon size (logical pixels) |

