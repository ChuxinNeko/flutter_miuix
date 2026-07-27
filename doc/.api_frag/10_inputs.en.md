## Inputs

### MiuixTextField

A Miuix-style text field with a floating label, an animated squircle border on focus, and leading/trailing icons.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `controller` | `TextEditingController?` | `null` | Text editing controller; created internally if omitted |
| `focusNode` | `FocusNode?` | `null` | Focus node; created internally if omitted |
| `onChanged` | `ValueChanged<String>?` | `null` | Called when the text changes |
| `label` | `String` | `''` | Label text (floating label) |
| `useLabelAsPlaceholder` | `bool` | `false` | Treat the label as a placeholder (hidden once text is entered instead of floating) |
| `enabled` | `bool` | `true` | Whether the field is enabled |
| `readOnly` | `bool` | `false` | Whether the field is read-only |
| `textStyle` | `TextStyle?` | `null` | Text style; defaults to the theme's `main` style |
| `leadingIcon` | `Widget?` | `null` | Leading icon |
| `trailingIcon` | `Widget?` | `null` | Trailing icon |
| `singleLine` | `bool` | `false` | Force a single line |
| `maxLines` | `int?` | `null` | Maximum number of lines |
| `minLines` | `int?` | `null` | Minimum number of lines |
| `colors` | `MiuixTextFieldColors?` | `null` | Color configuration; defaults to the theme |
| `cornerRadius` | `double` | `16` | Corner radius |
| `insideMargin` | `EdgeInsets` | `EdgeInsets.all(16)` | Inner padding (per side) |
| `keyboardType` | `TextInputType?` | `null` | Keyboard type |
| `textInputAction` | `TextInputAction?` | `null` | Keyboard action button type |
| `textCapitalization` | `TextCapitalization` | `TextCapitalization.none` | Text capitalization policy |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Called when the keyboard action is triggered |
| `obscureText` | `bool` | `false` | Obscure the input (password) |
| `cursorColor` | `Color?` | `null` | Cursor color; defaults to the focused border color |

**Example:**
```dart
MiuixTextField(
  label: 'Username',
  onChanged: (v) {},
)
```

### MiuixTextFieldColors

Color configuration for the text field. All fields are required.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `backgroundColor` | `Color` | required | Background color; resolves to theme `secondaryContainer` in `textFieldColors` |
| `labelColor` | `Color` | required | Label color; resolves to theme `onSecondaryContainer` in `textFieldColors` |
| `borderColor` | `Color` | required | Focused border color; resolves to theme `primary` in `textFieldColors` |

### MiuixTextFieldDefaults

Default values for the text field. Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| `cornerRadius` | `16` | Default corner radius |
| `insideMargin` | `EdgeInsets.all(16)` | Default inner padding (horizontal/vertical) |
| `borderWidth` | `2` | Focused border width |
| `labelFontSizeFloating` | `10` | Label font size when floating |
| `labelFontSizeNormal` | `17` | Label font size when normal |

| Static Method | Returns | Description |
|---|---|---|
| `textFieldColors(BuildContext context)` | `MiuixTextFieldColors` | Builds default color configuration from the current theme |

### MiuixSwitch

A Miuix-style switch with a 49x28 capsule track and a circular thumb, toggled by tap or horizontal drag.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `bool` | required | Whether the switch is on |
| `onChanged` | `ValueChanged<bool>?` | required | Toggle callback; interaction is disabled when `null` |
| `enabled` | `bool` | `true` | Whether the switch is enabled |
| `colors` | `MiuixSwitchColors?` | `null` | Color configuration; defaults to the theme |

**Example:**
```dart
MiuixSwitch(
  value: isOn,
  onChanged: (v) => setState(() => isOn = v),
)
```

### MiuixSwitchColors

Color configuration for the switch. All fields are required.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `checkedThumbColor` | `Color` | required | Thumb color when checked; resolves to theme `onPrimary` in `switchColors` |
| `uncheckedThumbColor` | `Color` | required | Thumb color when unchecked; resolves to theme `onSecondary` |
| `disabledCheckedThumbColor` | `Color` | required | Thumb color when disabled and checked; resolves to `disabledOnPrimary` |
| `disabledUncheckedThumbColor` | `Color` | required | Thumb color when disabled and unchecked; resolves to `disabledOnSecondary` |
| `checkedTrackColor` | `Color` | required | Track color when checked; resolves to theme `primary` |
| `uncheckedTrackColor` | `Color` | required | Track color when unchecked; resolves to theme `secondary` |
| `disabledCheckedTrackColor` | `Color` | required | Track color when disabled and checked; resolves to `disabledPrimary` |
| `disabledUncheckedTrackColor` | `Color` | required | Track color when disabled and unchecked; resolves to `disabledSecondary` |

### MiuixSwitchDefaults

Default values for the switch. Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| `trackWidth` | `49` | Track width |
| `trackHeight` | `28` | Track height |
| `thumbSize` | `20` | Thumb diameter |
| `thumbOffsetOff` | `4` | Thumb offset when off |
| `thumbOffsetOn` | `25` | Thumb offset when on |
| `thumbScaleActive` | `1.127` | Thumb scale factor when pressed/hovered/dragged |

| Static Method | Returns | Description |
|---|---|---|
| `switchColors(BuildContext context)` | `MiuixSwitchColors` | Builds default color configuration from the current theme |

### MiuixCheckbox

A Miuix-style checkbox with a 26dp round background and a trim-animated checkmark, supporting on/off/indeterminate states.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `bool?` | required | `true` = on, `false` = off, `null` = indeterminate |
| `onChanged` | `ValueChanged<bool?>?` | `null` | State change callback; interaction is disabled when `null` |
| `enabled` | `bool` | `true` | Whether the checkbox is enabled |
| `colors` | `MiuixCheckboxColors?` | `null` | Color configuration; defaults to the theme |

**Example:**
```dart
MiuixCheckbox(
  value: checked,
  onChanged: (v) => setState(() => checked = v ?? false),
)
```

### MiuixCheckboxColors

Color configuration for the checkbox. All fields are required.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `checkedForegroundColor` | `Color` | required | Foreground (checkmark) color when checked; resolves to `onPrimary` in `checkboxColors` |
| `uncheckedForegroundColor` | `Color` | required | Foreground color when unchecked; resolves to `secondary` |
| `disabledCheckedForegroundColor` | `Color` | required | Foreground color when disabled and checked; resolves to `disabledOnPrimary` |
| `disabledUncheckedForegroundColor` | `Color` | required | Foreground color when disabled and unchecked; resolves to `disabledOnPrimary` |
| `checkedBackgroundColor` | `Color` | required | Background color when checked; resolves to `primary` |
| `uncheckedBackgroundColor` | `Color` | required | Background color when unchecked; resolves to `secondary` |
| `disabledCheckedBackgroundColor` | `Color` | required | Background color when disabled and checked; resolves to `disabledPrimary` |
| `disabledUncheckedBackgroundColor` | `Color` | required | Background color when disabled and unchecked; resolves to `disabledSecondary` |

### MiuixCheckboxDefaults

Default values for the checkbox. Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| `size` | `26` | Checkbox size (width = height) |

| Static Method | Returns | Description |
|---|---|---|
| `checkboxColors(BuildContext context)` | `MiuixCheckboxColors` | Builds default color configuration from the current theme |

### MiuixRadioButton

A Miuix-style radio button, 26dp, showing a trim-animated checkmark when selected (no background circle).

| Parameter | Type | Default | Description |
|---|---|---|---|
| `selected` | `bool` | required | Whether it is selected |
| `onChanged` | `ValueChanged<bool>?` | `null` | Selection callback (fires only on unselected-to-selected); interaction is disabled when `null` |
| `enabled` | `bool` | `true` | Whether the radio button is enabled |
| `colors` | `MiuixRadioButtonColors?` | `null` | Color configuration; defaults to the theme |

**Example:**
```dart
MiuixRadioButton(
  selected: value == 0,
  onChanged: (_) => setState(() => value = 0),
)
```

### MiuixRadioButtonColors

Color configuration for the radio button. All fields are required.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `selectedColor` | `Color` | required | Color when selected (checkmark and stroke); resolves to `primary` in `radioButtonColors` |
| `disabledSelectedColor` | `Color` | required | Color when disabled and selected; resolves to `disabledPrimary` |

### MiuixRadioButtonDefaults

Default values for the radio button. Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| `size` | `26` | Radio button size (width = height) |

| Static Method | Returns | Description |
|---|---|---|
| `radioButtonColors(BuildContext context)` | `MiuixRadioButtonColors` | Builds default color configuration from the current theme |

### MiuixSlider

A Miuix-style horizontal slider supporting steps, key points, magnetic snapping, haptic feedback, reversed direction, and a disabled state.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `double` | required | Current value |
| `onValueChanged` | `ValueChanged<double>?` | required | Value change callback; interaction is disabled when `null` |
| `enabled` | `bool` | `true` | Whether the slider is enabled |
| `min` | `double` | `0.0` | Minimum value |
| `max` | `double` | `1.0` | Maximum value |
| `steps` | `int` | `0` | Number of steps (0 for continuous) |
| `onValueChangeFinished` | `VoidCallback?` | `null` | Called when the drag ends |
| `reverseDirection` | `bool` | `false` | Whether to reverse the direction |
| `height` | `double` | `MiuixSliderDefaults.minHeight` (28) | Track height |
| `colors` | `MiuixSliderColors?` | `null` | Color configuration; defaults to the theme |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderHapticEffect.edge` | Haptic feedback type |
| `showKeyPoints` | `bool` | `false` | Whether to show key points |
| `keyPoints` | `List<double>?` | `null` | Custom list of key point values |
| `magnetThreshold` | `double` | `0.02` | Magnetic snapping threshold |

**Example:**
```dart
MiuixSlider(
  value: progress,
  onValueChanged: (v) => setState(() => progress = v),
)
```

### MiuixSliderColors

Color configuration for the slider. All fields are required. `MiuixVerticalSlider` and `MiuixRangeSlider` reuse this configuration.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `foregroundColor` | `Color` | required | Foreground color (selected segment); resolves to theme `primary` in `sliderColors` |
| `disabledForegroundColor` | `Color` | required | Foreground color when disabled; resolves to `disabledPrimarySlider` |
| `backgroundColor` | `Color` | required | Track background color; resolves to `sliderBackground` |
| `disabledBackgroundColor` | `Color` | required | Track background color when disabled; resolves to `disabledSecondary` |
| `thumbColor` | `Color` | required | Thumb color; resolves to `onPrimary` |
| `disabledThumbColor` | `Color` | required | Thumb color when disabled; resolves to `disabledOnPrimary` |
| `keyPointColor` | `Color` | required | Key point color; resolves to `sliderKeyPoint` |
| `keyPointForegroundColor` | `Color` | required | Selected key point color; resolves to `sliderKeyPointForeground` |

### MiuixSliderDefaults

Default values for the slider. Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| `minHeight` | `28` | Minimum height (horizontal Slider/RangeSlider) or width (vertical) |
| `keyPointRadius` | `3.855` | Key point radius |
| `defaultHapticEffect` | `MiuixSliderHapticEffect.edge` | Default haptic feedback type |
| `thumbScaleActive` | `1.127` | Thumb scale factor when pressed/dragged/hovered |
| `thumbRadiusRatio` | `0.72` | Ratio of actual thumb radius to track radius |
| `dragOverlayAlpha` | `0.044` | Background dimming alpha while dragging |

| Static Method | Returns | Description |
|---|---|---|
| `sliderColors(BuildContext context)` | `MiuixSliderColors` | Builds default color configuration from the current theme |

### MiuixVerticalSlider

A Miuix-style vertical slider; parameters largely match `MiuixSlider` but oriented vertically.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `double` | required | Current value |
| `onValueChanged` | `ValueChanged<double>?` | required | Value change callback; interaction is disabled when `null` |
| `enabled` | `bool` | `true` | Whether the slider is enabled |
| `min` | `double` | `0.0` | Minimum value |
| `max` | `double` | `1.0` | Maximum value |
| `steps` | `int` | `0` | Number of steps (0 for continuous) |
| `onValueChangeFinished` | `VoidCallback?` | `null` | Called when the drag ends |
| `reverseDirection` | `bool` | `false` | Whether to reverse the direction |
| `width` | `double` | `MiuixSliderDefaults.minHeight` (28) | Track width |
| `colors` | `MiuixSliderColors?` | `null` | Color configuration; defaults to the theme |
| `effect` | `bool` | `false` | Reserved parameter (no visual effect enabled upstream yet), kept for API parity |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderHapticEffect.edge` | Haptic feedback type |
| `showKeyPoints` | `bool` | `false` | Whether to show key points |
| `keyPoints` | `List<double>?` | `null` | Custom list of key point values |
| `magnetThreshold` | `double` | `0.02` | Magnetic snapping threshold |

**Example:**
```dart
SizedBox(
  height: 200,
  child: MiuixVerticalSlider(
    value: volume,
    onValueChanged: (v) => setState(() => volume = v),
  ),
)
```

### MiuixRangeSlider

A Miuix-style range slider with two thumbs controlling the start and end values.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `startValue` | `double` | required | Start value |
| `endValue` | `double` | required | End value |
| `onValueChanged` | `ValueChanged<(double, double)>?` | required | Value change callback (start, end); interaction is disabled when `null` |
| `enabled` | `bool` | `true` | Whether the slider is enabled |
| `min` | `double` | `0.0` | Minimum value |
| `max` | `double` | `1.0` | Maximum value |
| `steps` | `int` | `0` | Number of steps (0 for continuous) |
| `onValueChangeFinished` | `VoidCallback?` | `null` | Called when the drag ends |
| `height` | `double` | `MiuixSliderDefaults.minHeight` (28) | Track height |
| `colors` | `MiuixSliderColors?` | `null` | Color configuration; defaults to the theme |
| `hapticEffect` | `MiuixSliderHapticEffect` | `MiuixSliderHapticEffect.edge` | Haptic feedback type |
| `showKeyPoints` | `bool` | `false` | Whether to show key points |
| `keyPoints` | `List<double>?` | `null` | Custom list of key point values |
| `magnetThreshold` | `double` | `0.02` | Magnetic snapping threshold |

**Example:**
```dart
MiuixRangeSlider(
  startValue: lo,
  endValue: hi,
  onValueChanged: (r) => setState(() { lo = r.$1; hi = r.$2; }),
)
```

### MiuixSliderHapticEffect (enum)

Slider haptic feedback type.

| Value | Description |
|---|---|
| `none` | No haptic feedback |
| `edge` | Triggered at the 0% and 100% endpoints |
| `step` | Triggered at step points |

### MiuixSearchBar

A Miuix-style search bar container. When expanded, it shows the trailing action and result content and intercepts the system back gesture to collapse first.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `inputField` | `Widget` | required | The input field widget (typically `MiuixInputField`) |
| `onExpandedChange` | `ValueChanged<bool>` | required | Called when the expanded state changes |
| `content` | `Widget` | required | Result content shown when expanded |
| `insideMargin` | `EdgeInsets` | `EdgeInsets.symmetric(horizontal: 12)` | Padding around the input field |
| `expanded` | `bool` | `false` | Whether the bar is expanded |
| `outsideEndAction` | `Widget?` | `null` | Action widget shown at the trailing edge when expanded |

**Example:**
```dart
MiuixSearchBar(
  expanded: expanded,
  onExpandedChange: (v) => setState(() => expanded = v),
  inputField: MiuixInputField(
    query: query,
    onQueryChange: (v) => setState(() => query = v),
    onSearch: (v) {},
    expanded: expanded,
    onExpandedChange: (v) => setState(() => expanded = v),
  ),
  content: const SizedBox(),
)
```

### MiuixSearchBarDefaults

Default values for the search bar. Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| `insideMargin` | `EdgeInsets.symmetric(horizontal: 12)` | Padding around the input field |
| `inputFieldMinHeight` | `45` | Minimum input field height |
| `inputFieldFontSize` | `17` | Input field font size |
| `leadingIconStartPadding` | `16` | Leading icon start padding |
| `leadingIconEndPadding` | `8` | Leading icon end padding |
| `trailingIconStartPadding` | `8` | Trailing icon start padding |
| `trailingIconEndPadding` | `16` | Trailing icon end padding |
| `visibilityDuration` | `Duration(milliseconds: 275)` | Expand/collapse animation duration |
| `textFadeDuration` | `Duration(milliseconds: 150)` | Text fade in/out duration |

### MiuixInputField

A Miuix search input field, used with `MiuixSearchBar`, providing a search icon, a clear button, and a placeholder label.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `query` | `String` | required | Current query text |
| `onQueryChange` | `ValueChanged<String>` | required | Called when the query text changes |
| `onSearch` | `ValueChanged<String>` | required | Called when the search is submitted |
| `expanded` | `bool` | required | Whether it is expanded (focused) |
| `onExpandedChange` | `ValueChanged<bool>` | required | Called when the expanded state changes |
| `label` | `String` | `''` | Placeholder label text |
| `enabled` | `bool` | `true` | Whether the field is enabled |
| `textStyle` | `TextStyle?` | `null` | Text style |
| `color` | `Color?` | `null` | Background color; defaults to the theme |
| `leadingIcon` | `Widget?` | `null` | Leading icon; defaults to a search icon |
| `trailingIcon` | `Widget?` | `null` | Trailing icon; uses a fading default clear button when `null` |
| `focusNode` | `FocusNode?` | `null` | Focus node; created internally if omitted |

**Example:**
```dart
MiuixInputField(
  query: query,
  onQueryChange: (v) => setState(() => query = v),
  onSearch: (v) {},
  expanded: expanded,
  onExpandedChange: (v) => setState(() => expanded = v),
  label: 'Search',
)
```

### MiuixNumberPicker

A Miuix-style vertical number picker; the center item is selected while items farther from the center fade and shrink, with wrap-around and inertial snapping.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `int` | required | Current value |
| `onValueChanged` | `ValueChanged<int>?` | required | Value change callback; interaction is disabled when `null` |
| `enabled` | `bool` | `true` | Whether the picker is enabled |
| `min` | `int` | `0` | Minimum value |
| `max` | `int` | `10` | Maximum value |
| `label` | `String Function(int)?` | `null` | Maps a value to display text; defaults to `value.toString()` |
| `visibleItemCount` | `int` | `5` | Number of visible items (must be odd and >= 3) |
| `wrapAround` | `bool` | `false` | Whether scrolling wraps around |
| `colors` | `MiuixNumberPickerColors?` | `null` | Color configuration; defaults to the theme |
| `textStyle` | `TextStyle?` | `null` | Text style; defaults to the theme's `title1` style |
| `itemHeight` | `double` | `MiuixNumberPickerDefaults.itemHeight` (45) | Height of each item |

**Example:**
```dart
MiuixNumberPicker(
  value: hour,
  min: 0,
  max: 23,
  onValueChanged: (v) => setState(() => hour = v),
)
```

### MiuixNumberPickerColors

Color configuration for the number picker. All fields are required.

| Parameter | Type | Default | Description |
|---|---|---|---|
| `selectedTextColor` | `Color` | required | Text color of the selected item; resolves to theme `onSurface` in `colors` |
| `unselectedTextColor` | `Color` | required | Text color of unselected items; resolves to `onSurfaceSecondary` |
| `disabledSelectedTextColor` | `Color` | required | Text color of the selected item when disabled; resolves to `disabledOnSecondary` |
| `disabledUnselectedTextColor` | `Color` | required | Text color of unselected items when disabled; resolves to `disabledOnSecondary` |

### MiuixNumberPickerDefaults

Default values for the number picker. Private constructor; only `static` fields/methods.

| Constant | Value | Description |
|---|---|---|
| `itemHeight` | `45` | Height of each item |

| Static Method | Returns | Description |
|---|---|---|
| `colors(BuildContext context)` | `MiuixNumberPickerColors` | Builds default color configuration from the current theme |

