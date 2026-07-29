## Preferences & Pickers

### MiuixArrowPreference

A preference row with a trailing 10×16 right arrow icon (auto-flipped in RTL), reusing the base row's click/press semantics.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `title` | `String` | required | Row title |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | Title color; falls back to `MiuixBasicComponentDefaults.titleColor` |
| `summary` | `String?` | `null` | Row summary |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | Summary color; falls back to `MiuixBasicComponentDefaults.summaryColor` |
| `startAction` | `Widget?` | `null` | Leading content |
| `endActions` | `List<Widget>?` | `null` | Extra content before the arrow |
| `bottomAction` | `Widget?` | `null` | Bottom content below the main row |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | Inner padding |
| `onClick` | `VoidCallback?` | `null` | Tap callback; not clickable when null |
| `holdDownState` | `bool` | `false` | Whether forced into pressed state |
| `enabled` | `bool` | `true` | Whether enabled |

**Example:**
```dart
MiuixArrowPreference(
  title: 'About',
  summary: 'Version, license and open source info',
  onClick: () {},
)
```

### MiuixArrowPreferenceEndActionColors

Color configuration for the ArrowPreference trailing arrow. Switches between enabled and disabled colors based on `enabled`.

| Field | Type | Description |
|---|---|---|
| `color` | `Color` | Enabled color |
| `disabledColor` | `Color` | Disabled color |

| Method | Signature | Description |
|---|---|---|
| `resolve` | `Color resolve(bool enabled)` | Returns `color` when `enabled` is true, otherwise `disabledColor` |

### MiuixArrowPreferenceDefaults

Default values for ArrowPreference. Private constructor; provides only static methods.

| Method | Signature | Description |
|---|---|---|
| `endActionColors` | `MiuixArrowPreferenceEndActionColors endActionColors(BuildContext context)` | Default colors for the trailing arrow: `color` is theme `onSurfaceVariantActions`, `disabledColor` is `disabledOnSecondaryVariant` |

### MiuixSwitchPreference

A preference row with a trailing `MiuixSwitch`; tapping the whole row toggles `value` and fires `onChanged`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `bool` | required | Current switch state |
| `onChanged` | `ValueChanged<bool>` | required | State change callback |
| `title` | `String` | required | Row title |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | Title color; falls back to default |
| `summary` | `String?` | `null` | Row summary |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | Summary color; falls back to default |
| `startAction` | `Widget?` | `null` | Leading content |
| `endActions` | `List<Widget>?` | `null` | Extra content before the switch |
| `bottomAction` | `Widget?` | `null` | Bottom content |
| `switchColors` | `MiuixSwitchColors?` | `null` | Switch colors; falls back to `MiuixSwitchDefaults.switchColors` |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | Inner padding |
| `holdDownState` | `bool` | `false` | Whether forced into pressed state |
| `enabled` | `bool` | `true` | Whether enabled |

**Example:**
```dart
MiuixSwitchPreference(
  title: 'Airplane mode',
  value: enabled,
  onChanged: (v) => setState(() => enabled = v),
)
```

### MiuixCheckboxLocation

Enum of checkbox positions in `MiuixCheckboxPreference`. `start`/`end` are mirrored automatically under RTL.

| Value | Description |
|---|---|
| `start` | Leading side (before title) |
| `end` | Trailing side (after endActions) |

### MiuixCheckboxPreference

A preference row with a checkbox whose position is set by `checkboxLocation`; tapping the whole row toggles `value` and fires `onChanged`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `title` | `String` | required | Row title |
| `value` | `bool` | required | Current checkbox state |
| `onChanged` | `ValueChanged<bool>?` | required | State change callback; non-interactive when null |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | Title color; falls back to default |
| `summary` | `String?` | `null` | Row summary |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | Summary color; falls back to default |
| `checkboxColors` | `MiuixCheckboxColors?` | `null` | Checkbox colors; falls back to `MiuixCheckboxDefaults.checkboxColors` |
| `startAction` | `Widget?` | `null` | Leading extra content (after checkbox, 5dp gap) |
| `endActions` | `List<Widget>?` | `null` | Trailing extra content (before checkbox, 8dp gap) |
| `checkboxLocation` | `MiuixCheckboxLocation` | `MiuixCheckboxLocation.start` | Checkbox position |
| `bottomAction` | `Widget?` | `null` | Bottom content |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | Inner padding |
| `holdDownState` | `bool` | `false` | Whether forced into pressed state |
| `enabled` | `bool` | `true` | Whether enabled |

Enum `MiuixCheckboxLocation`: `start` (leading, before title), `end` (trailing, after endActions).

**Example:**
```dart
MiuixCheckboxPreference(
  title: 'Accept terms',
  value: agreed,
  onChanged: (v) => setState(() => agreed = v),
)
```

### MiuixRadioButtonLocation

Enum of radio button positions in `MiuixRadioButtonPreference`. `start`/`end` are mirrored automatically under RTL.

| Value | Description |
|---|---|
| `start` | Leading side (before title) |
| `end` | Trailing side (after endActions) |

### MiuixRadioButtonPreference

A preference row with a radio button whose position is set by `radioButtonLocation`; when selected the title/summary color switches to `primary`, and tapping the row fires `onClick` with haptic feedback.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `title` | `String` | required | Row title |
| `selected` | `bool` | required | Whether in selected state |
| `onClick` | `VoidCallback?` | `null` | Tap callback; not clickable when null |
| `summary` | `String?` | `null` | Row summary |
| `colors` | `MiuixRadioButtonPreferenceColors?` | `null` | Title/summary colors; falls back to `MiuixRadioButtonPreferenceDefaults.radioButtonPreferenceColors` |
| `radioButtonColors` | `MiuixRadioButtonColors?` | `null` | Radio button colors; falls back to `MiuixRadioButtonDefaults.radioButtonColors` |
| `startAction` | `Widget?` | `null` | Leading extra content (after radio button, 5dp gap) |
| `endActions` | `List<Widget>?` | `null` | Trailing extra content (before radio button, 8dp gap) |
| `radioButtonLocation` | `MiuixRadioButtonLocation` | `MiuixRadioButtonLocation.start` | Radio button position |
| `bottomAction` | `Widget?` | `null` | Bottom content |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | Inner padding |
| `holdDownState` | `bool` | `false` | Whether forced into pressed state |
| `enabled` | `bool` | `true` | Whether enabled |

Enum `MiuixRadioButtonLocation`: `start` (leading, before title), `end` (trailing, after endActions).

**Example:**
```dart
MiuixRadioButtonPreference(
  title: 'Option A',
  selected: index == 0,
  onClick: () => setState(() => index = 0),
)
```

### MiuixRadioButtonPreferenceColors

Color configuration for RadioButtonPreference title and summary. Switches between base and selected colors based on `selected`.

| Field | Type | Description |
|---|---|---|
| `titleColor` | `MiuixBasicComponentColors` | Unselected title color |
| `selectedTitleColor` | `MiuixBasicComponentColors` | Selected title color |
| `summaryColor` | `MiuixBasicComponentColors` | Unselected summary color |
| `selectedSummaryColor` | `MiuixBasicComponentColors` | Selected summary color |

| Method | Signature | Description |
|---|---|---|
| `resolveTitleColor` | `MiuixBasicComponentColors resolveTitleColor(bool selected)` | Returns `selectedTitleColor` when `selected` is true, otherwise `titleColor` |
| `resolveSummaryColor` | `MiuixBasicComponentColors resolveSummaryColor(bool selected)` | Returns `selectedSummaryColor` when `selected` is true, otherwise `summaryColor` |

### MiuixRadioButtonPreferenceDefaults

Default values for RadioButtonPreference. Private constructor; provides only static methods.

| Method | Signature | Description |
|---|---|---|
| `radioButtonPreferenceColors` | `MiuixRadioButtonPreferenceColors radioButtonPreferenceColors(BuildContext context)` | Default title/summary colors: unselected title is `onBackground`, unselected summary is `onSurfaceVariantSummary`, selected uses `primary`; disabled color is uniformly `disabledOnSecondaryVariant` |

### MiuixSliderPreference

A preference row with a `MiuixSlider` in the bottom area; the trailing area can show `valueText`, and a right arrow is appended when `onClick` is non-null. Asserts `steps >= 0` and `min < max`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `double` | required | Current slider value; clamped to `min..max` |
| `onValueChange` | `ValueChanged<double>` | required | Value change callback |
| `title` | `String?` | `null` | Row title |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | Title color; falls back to default |
| `summary` | `String?` | `null` | Row summary |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | Summary color; falls back to default |
| `startAction` | `Widget?` | `null` | Leading content |
| `valueText` | `String?` | `null` | Current value text in the trailing area |
| `endActions` | `List<Widget>?` | `null` | Extra content after `valueText` |
| `bottomAction` | `Widget?` | `null` | Extra content above the slider |
| `onClick` | `VoidCallback?` | `null` | Tap callback; appends a right arrow when non-null |
| `holdDownState` | `bool` | `false` | Whether forced into pressed state |
| `enabled` | `bool` | `true` | Whether enabled |
| `min` | `double` | `0.0` | Slider minimum |
| `max` | `double` | `1.0` | Slider maximum |
| `steps` | `int` | `0` | Discrete steps; 0 means continuous |
| `onValueChangeFinished` | `VoidCallback?` | `null` | Callback when value change finishes |
| `reverseDirection` | `bool` | `false` | Whether reversed (increases right-to-left) |
| `sliderHeight` | `double` | `MiuixSliderDefaults.minHeight` (28) | Slider height |
| `sliderColors` | `MiuixSliderColors?` | `null` | Slider colors; falls back to `MiuixSliderDefaults.sliderColors` |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect` (`edge`) | Haptic feedback type |
| `showKeyPoints` | `bool` | `false` | Whether to show key points |
| `keyPoints` | `List<double>?` | `null` | Custom key points; derived from `steps` when null |
| `magnetThreshold` | `double` | `0.02` | Magnet threshold (0..1) |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | Inner padding |

**Example:**
```dart
MiuixSliderPreference(
  title: 'Brightness',
  value: brightness,
  valueText: '${(brightness * 100).round()}%',
  onValueChange: (v) => setState(() => brightness = v),
)
```

### MiuixRangeSliderPreference

A preference row with a `MiuixRangeSlider` in the bottom area; the trailing area can show `valueText`, and a right arrow is appended when `onClick` is non-null. Asserts `steps >= 0` and `min < max`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `startValue` | `double` | required | Start value; clamped to `min..max` |
| `endValue` | `double` | required | End value; clamped to `min..max` |
| `onValueChange` | `ValueChanged<(double, double)>` | required | Value change callback with `(newStart, newEnd)` |
| `title` | `String?` | `null` | Row title |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | Title color |
| `summary` | `String?` | `null` | Row summary |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | Summary color |
| `startAction` | `Widget?` | `null` | Leading content |
| `valueText` | `String?` | `null` | Current value text in the trailing area |
| `endActions` | `List<Widget>?` | `null` | Extra content in the trailing area |
| `bottomAction` | `Widget?` | `null` | Extra content above the slider |
| `onClick` | `VoidCallback?` | `null` | Tap callback; appends a right arrow when non-null |
| `holdDownState` | `bool` | `false` | Whether forced into pressed state |
| `enabled` | `bool` | `true` | Whether enabled |
| `min` | `double` | `0.0` | Slider minimum |
| `max` | `double` | `1.0` | Slider maximum |
| `steps` | `int` | `0` | Discrete steps |
| `onValueChangeFinished` | `VoidCallback?` | `null` | Callback when value change finishes |
| `sliderHeight` | `double` | `MiuixSliderDefaults.minHeight` (28) | Slider height |
| `sliderColors` | `MiuixSliderColors?` | `null` | Slider colors |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect` (`edge`) | Haptic feedback type |
| `showKeyPoints` | `bool` | `false` | Whether to show key points |
| `keyPoints` | `List<double>?` | `null` | Custom key points |
| `magnetThreshold` | `double` | `0.02` | Magnet threshold |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | Inner padding |

**Example:**
```dart
MiuixRangeSliderPreference(
  title: 'Price range',
  startValue: lo,
  endValue: hi,
  onValueChange: (r) => setState(() { lo = r.$1; hi = r.$2; }),
)
```

### MiuixOverlayDropdownPreference

A dropdown preference row rendered within the Scaffold; shows the selected value text and a dropdown arrow, tapping expands a dropdown popup (rendered in the root Scaffold). The default constructor takes `items` + `selectedIndex`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `items` | `List<String>` | required | Dropdown item texts |
| `selectedIndex` | `int` | required | Current selected index |
| `title` | `String` | required | Row title |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | Title color |
| `summary` | `String?` | `null` | Row summary |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | Summary color |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | Dropdown colors; falls back to `MiuixDropdownDefaults.dropdownColors` |
| `startAction` | `Widget?` | `null` | Leading content |
| `bottomAction` | `Widget?` | `null` | Bottom content |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | Inner padding |
| `maxHeight` | `double?` | `null` | Max popup height |
| `enabled` | `bool` | `true` | Whether enabled |
| `showValue` | `bool` | `true` | Whether to show the selected value text |
| `renderInRootScaffold` | `bool` | `true` | Whether to render the popup in the root Scaffold |
| `collapseOnSelection` | `bool?` | `true` | Whether to collapse after selection (default ctor is `true`) |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | Expanded state change callback |
| `onSelectedIndexChange` | `ValueChanged<int>?` | `null` | Selected index change callback |

Named constructors: `.entry({required MiuixDropdownEntry entry, ...})` (single group) and `.entries({required List<MiuixDropdownEntry> entries, ...})` (multi group); `.entries` defaults `collapseOnSelection` to `null` (auto by group count) and does not take `onSelectedIndexChange`.

**Example:**
```dart
MiuixOverlayDropdownPreference(
  title: 'Language',
  items: const ['简体中文', 'English'],
  selectedIndex: langIndex,
  onSelectedIndexChange: (i) => setState(() => langIndex = i),
)
```

### MiuixWindowDropdownPreference

A window-level dropdown preference row; behaves like `MiuixOverlayDropdownPreference` but the popup renders in the root Overlay, so there is no `renderInRootScaffold` parameter.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `items` | `List<String>` | required | Dropdown item texts |
| `selectedIndex` | `int` | required | Current selected index |
| `title` | `String` | required | Row title |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | Title color |
| `summary` | `String?` | `null` | Row summary |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | Summary color |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | Dropdown colors; falls back to default |
| `startAction` | `Widget?` | `null` | Leading content |
| `bottomAction` | `Widget?` | `null` | Bottom content |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | Inner padding |
| `maxHeight` | `double?` | `null` | Max popup height |
| `enabled` | `bool` | `true` | Whether enabled |
| `showValue` | `bool` | `true` | Whether to show the selected value text |
| `collapseOnSelection` | `bool?` | `true` | Whether to collapse after selection |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | Expanded state change callback |
| `onSelectedIndexChange` | `ValueChanged<int>?` | `null` | Selected index change callback |

Named constructors: `.entry` (single group) and `.entries` (multi group, `collapseOnSelection` defaults to `null`).

**Example:**
```dart
MiuixWindowDropdownPreference(
  title: 'Theme',
  items: const ['Light', 'Dark', 'System'],
  selectedIndex: themeIndex,
  onSelectedIndexChange: (i) => setState(() => themeIndex = i),
)
```

### MiuixOverlaySpinnerPreference

A spinner (dropdown selection) preference row rendered within the Scaffold. Unlike Dropdown, `items` is a `List<MiuixDropdownItem>` (keeping icon/summary, etc.), and when `dialogButtonString` is non-null it uses dialog mode (otherwise popup mode). The default constructor takes `items` + `selectedIndex`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `items` | `List<MiuixDropdownItem>` | required | Dropdown items |
| `selectedIndex` | `int` | required | Current selected index |
| `title` | `String` | required | Row title |
| `dialogButtonString` | `String?` | `null` | Uses dialog mode when non-null; also the button text |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | Title color |
| `summary` | `String?` | `null` | Row summary |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | Summary color |
| `spinnerColors` | `MiuixDropdownColors?` | `null` | Colors; when null, dialog uses `dialogDropdownColors`, popup uses `dropdownColors` |
| `startAction` | `Widget?` | `null` | Leading content |
| `bottomAction` | `Widget?` | `null` | Bottom content |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | Inner padding |
| `maxHeight` | `double?` | `null` | Max popup height |
| `enabled` | `bool` | `true` | Whether enabled |
| `showValue` | `bool` | `true` | Whether to show the selected value text |
| `renderInRootScaffold` | `bool` | `true` | Whether to render in the root Scaffold |
| `collapseOnSelection` | `bool?` | `null` | Whether to collapse after selection |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | Expanded state change callback |
| `onSelectedIndexChange` | `ValueChanged<int>?` | `null` | Selected index change callback |

Named constructors: `.entry` (single group, `collapseOnSelection` defaults to `true`) and `.entries` (multi group, defaults to `null`); neither takes `onSelectedIndexChange`.

**Example:**
```dart
MiuixOverlaySpinnerPreference(
  title: 'Sort by',
  items: const [MiuixDropdownItem(text: 'Name'), MiuixDropdownItem(text: 'Date')],
  selectedIndex: sortIndex,
  onSelectedIndexChange: (i) => setState(() => sortIndex = i),
)
```

### MiuixWindowSpinnerPreference

A window-level spinner preference row; behaves like `MiuixOverlaySpinnerPreference` but the popup renders in the root Overlay, so there is no `renderInRootScaffold` parameter.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `items` | `List<MiuixDropdownItem>` | required | Dropdown items |
| `selectedIndex` | `int` | required | Current selected index |
| `title` | `String` | required | Row title |
| `dialogButtonString` | `String?` | `null` | Uses dialog mode when non-null; also the button text |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | Title color |
| `summary` | `String?` | `null` | Row summary |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | Summary color |
| `spinnerColors` | `MiuixDropdownColors?` | `null` | Colors; falls back to defaults by mode |
| `startAction` | `Widget?` | `null` | Leading content |
| `bottomAction` | `Widget?` | `null` | Bottom content |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | Inner padding |
| `maxHeight` | `double?` | `null` | Max popup height |
| `enabled` | `bool` | `true` | Whether enabled |
| `showValue` | `bool` | `true` | Whether to show the selected value text |
| `collapseOnSelection` | `bool?` | `null` | Whether to collapse after selection |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | Expanded state change callback |
| `onSelectedIndexChange` | `ValueChanged<int>?` | `null` | Selected index change callback |

Named constructors: `.entry` (single group, `collapseOnSelection` defaults to `true`) and `.entries` (multi group, defaults to `null`).

**Example:**
```dart
MiuixWindowSpinnerPreference(
  title: 'Account',
  items: const [MiuixDropdownItem(text: 'Alice'), MiuixDropdownItem(text: 'Bob')],
  selectedIndex: 0,
  dialogButtonString: 'Cancel',
  onSelectedIndexChange: (i) {},
)
```

### MiuixColorSpace

Enum of color spaces used by `MiuixColorPicker`.

| Value | Description |
|---|---|
| `hsv` | Classic HSV |
| `okhsv` | OkLab-based OkHSV, better perceptual uniformity |
| `oklab` | OkLab (lightness + green-red axis + blue-yellow axis) |
| `oklch` | OkLCH (lightness + chroma + hue) |

### MiuixColorPicker

A Miuix-style multi-color-space slider color picker; dispatches to a sub-picker based on `colorSpace`, with H/S/V (or the corresponding channels) plus an alpha slider.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `color` | `Color` | required | Current color |
| `onColorChanged` | `ValueChanged<Color>` | required | Color change callback |
| `showPreview` | `bool` | `true` | Whether to show the selected color preview bar |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect` (`edge`) | Slider haptic feedback type |
| `colorSpace` | `MiuixColorSpace` | `MiuixColorSpace.hsv` | Color space to use |

Enum `MiuixColorSpace`: `hsv` (classic HSV), `okhsv` (OkLab-based OkHSV, better perceptual uniformity), `oklab` (lightness + green-red axis + blue-yellow axis), `oklch` (lightness + chroma + hue).

Equivalent single-space widgets are also provided (same constructor params, no `colorSpace`): `MiuixHsvColorPicker`, `MiuixOkHsvColorPicker`, `MiuixOkLabColorPicker`, `MiuixOkLchColorPicker`.

**Example:**
```dart
MiuixColorPicker(
  color: current,
  colorSpace: MiuixColorSpace.okhsv,
  onColorChanged: (c) => setState(() => current = c),
)
```

### MiuixHsvColorPicker

Miuix color picker using the HSV color space. Parameters are the same as `MiuixColorPicker`, but without the `colorSpace` field; the HSV color space is fixed.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `color` | `Color` | required | Current color |
| `onColorChanged` | `ValueChanged<Color>` | required | Color change callback |
| `showPreview` | `bool` | `true` | Whether to show the selected color preview bar |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect` (`edge`) | Slider haptic feedback type |

### MiuixOkHsvColorPicker

Miuix color picker using the OkHSV color space. Parameters are the same as `MiuixColorPicker`, but without the `colorSpace` field; the OkHSV color space is fixed (OkLab-based, better perceptual uniformity).

| Parameter | Type | Default | Description |
|---|---|---|---|
| `color` | `Color` | required | Current color |
| `onColorChanged` | `ValueChanged<Color>` | required | Color change callback |
| `showPreview` | `bool` | `true` | Whether to show the selected color preview bar |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect` (`edge`) | Slider haptic feedback type |

### MiuixOkLabColorPicker

Miuix color picker using the OkLab color space. Parameters are the same as `MiuixColorPicker`, but without the `colorSpace` field; the OkLab color space is fixed (lightness + green-red axis + blue-yellow axis).

| Parameter | Type | Default | Description |
|---|---|---|---|
| `color` | `Color` | required | Current color |
| `onColorChanged` | `ValueChanged<Color>` | required | Color change callback |
| `showPreview` | `bool` | `true` | Whether to show the selected color preview bar |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect` (`edge`) | Slider haptic feedback type |

### MiuixOkLchColorPicker

Miuix color picker using the OkLch color space. Parameters are the same as `MiuixColorPicker`, but without the `colorSpace` field; the OkLch color space is fixed (lightness + chroma + hue).

| Parameter | Type | Default | Description |
|---|---|---|---|
| `color` | `Color` | required | Current color |
| `onColorChanged` | `ValueChanged<Color>` | required | Color change callback |
| `showPreview` | `bool` | `true` | Whether to show the selected color preview bar |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderDefaults.defaultHapticEffect` (`edge`) | Slider haptic feedback type |

### MiuixColorPalette

A Miuix-style HSV grid palette; `color` is externally controlled, and pressing/dragging in the grid or adjusting alpha returns a new color via `onColorChanged`. Defaults to 7 rows, 12 hue columns plus a gray column. Asserts `rows > 0`, `hueColumns > 0`, `cornerRadius >= 0`, `indicatorRadius >= 0`.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `color` | `Color` | required | Current color |
| `onColorChanged` | `ValueChanged<Color>` | required | Called on selection or alpha change |
| `rows` | `int` | `MiuixColorPaletteDefaults.rows` (7) | Number of color grid rows |
| `hueColumns` | `int` | `MiuixColorPaletteDefaults.hueColumns` (12) | Number of hue columns |
| `includeGrayColumn` | `bool` | `MiuixColorPaletteDefaults.includeGrayColumn` (true) | Whether to append a gray column after the hue columns |
| `showPreview` | `bool` | `MiuixColorPaletteDefaults.showPreview` (true) | Whether to show the top color preview |
| `cornerRadius` | `double` | `MiuixColorPaletteDefaults.cornerRadius` (16) | Grid squircle corner radius |
| `indicatorRadius` | `double` | `MiuixColorPaletteDefaults.indicatorRadius` (10) | Selection indicator ring radius |

**Example:**
```dart
MiuixColorPalette(
  color: current,
  onColorChanged: (c) => setState(() => current = c),
)
```

### MiuixColorPaletteDefaults

Default sizes and grid parameters for MiuixColorPalette. Private constructor; contains only static constants.

| Constant | Value | Description |
|---|---|---|
| `rows` | `7` | Default number of color rows |
| `hueColumns` | `12` | Default number of hue columns |
| `includeGrayColumn` | `true` | Whether to show the gray column by default |
| `showPreview` | `true` | Whether to show the color preview by default |
| `cornerRadius` | `16` | Default corner radius of the palette grid |
| `indicatorRadius` | `10` | Default radius of the selection indicator |
| `controlHeight` | `26` | Height of the color preview and alpha slider |
| `paletteHeight` | `180` | Height of the palette grid |
| `spacing` | `12` | Vertical spacing between sub-items |

