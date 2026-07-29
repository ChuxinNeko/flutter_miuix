## Overlays & Feedback

### MiuixDismissScope

An InheritedWidget that exposes a dismiss request to dialog content. Wrapped around `MiuixOverlayDialog` content; descendants can obtain the host dialog's dismiss callback via `MiuixDismissScope.maybeOf(context)`, returning `null` when not inside a dialog.

| Param | Type | Default | Description |
|---|---|---|---|
| `onDismissRequest` | `VoidCallback` | required | Dismiss request callback |
| `child` | `Widget` | required | Subtree |

**Static method:**
- `MiuixDismissScope.maybeOf(BuildContext context) → VoidCallback?`: Returns the dismiss callback of the nearest ancestor `MiuixDismissScope`.

### MiuixOverlayDialog

A Miuix dialog inside a Scaffold, reproducing large/small-screen layout, scrim, tap-outside dismiss and enter/exit transitions.

| Param | Type | Default | Description |
|---|---|---|---|
| `show` | `bool` | required | Whether the dialog is shown |
| `title` | `String?` | `null` | Title text |
| `titleColor` | `Color?` | `null` | Title color, defaults to theme `onBackground` |
| `summary` | `String?` | `null` | Summary text below the title |
| `summaryColor` | `Color?` | `null` | Summary color, defaults to theme `onSurfaceSecondary` |
| `backgroundColor` | `Color?` | `null` | Background color, defaults to theme `background` |
| `enableWindowDim` | `bool` | `true` | Whether to dim the scrim |
| `onDismissRequest` | `VoidCallback?` | `null` | Dismiss request callback (tap outside/scrim) |
| `onDismissFinished` | `VoidCallback?` | `null` | Called when exit animation finishes |
| `outsideMargin` | `Size` | `Size(12, 12)` | Outer margin |
| `insideMargin` | `Size` | `Size(24, 24)` | Inner margin |
| `defaultWindowInsetsPadding` | `bool` | `true` | Apply system safe-area padding |
| `renderInRootScaffold` | `bool` | `true` | Render into root Scaffold overlay |
| `maxWidth` | `double` | `420` | Max panel width |
| `largeScreen` | `bool?` | `null` | Center as large screen; auto-detected when `null` |
| `cornerRadius` | `double?` | `null` | Corner radius; defaults to `32` when `null` |
| `content` | `Widget` | required | Dialog content |

**Example:**
```dart
MiuixOverlayDialog(
  show: show,
  title: 'Notice',
  summary: 'Continue?',
  onDismissRequest: () => setState(() => show = false),
  content: const SizedBox(),
)
```

### MiuixDialogDefaults

Defaults for Miuix dialogs (private constructor, `static` fields only).

| Constant | Value | Description |
|---|---|---|
| `maxWidth` | `420` | Max panel width |
| `cornerRadius` | `32` | Corner radius in large-screen mode |
| `outsideMargin` | `Size(12, 12)` | Outer margin |
| `insideMargin` | `Size(24, 24)` | Inner margin |

| Static method | Returns | Description |
|---|---|---|
| `titleColor(context)` | `Color` | Title color, theme `onBackground` |
| `summaryColor(context)` | `Color` | Summary color, theme `onSurfaceSecondary` |
| `backgroundColor(context)` | `Color` | Background color, theme `background` |

### MiuixOverlayBottomSheet

A bottom sheet inside a Scaffold, with a drag handle, spring translation and vertical swipe-to-dismiss. `MiuixWindowBottomSheet` is the window-level variant (renders into the root Overlay, no `renderInRootScaffold` param).

| Param | Type | Default | Description |
|---|---|---|---|
| `show` | `bool` | required | Whether the sheet is shown |
| `title` | `String?` | `null` | Title text |
| `startAction` | `Widget?` | `null` | Leading action in the title row |
| `endAction` | `Widget?` | `null` | Trailing action in the title row |
| `backgroundColor` | `Color?` | `null` | Background color, defaults to theme `background` |
| `enableWindowDim` | `bool` | `true` | Whether to dim the scrim |
| `cornerRadius` | `double` | `28` | Top corner radius |
| `sheetMaxWidth` | `double` | `640` | Max sheet width |
| `onDismissRequest` | `VoidCallback?` | `null` | Dismiss request callback |
| `onDismissFinished` | `VoidCallback?` | `null` | Called when exit animation finishes |
| `outsideMargin` | `Size` | `Size.zero` | Outer margin |
| `insideMargin` | `Size` | `Size(24, 0)` | Inner margin |
| `defaultWindowInsetsPadding` | `bool` | `true` | Apply system safe-area padding |
| `dragHandleColor` | `Color?` | `null` | Drag handle color |
| `allowDismiss` | `bool` | `true` | Allow drag/tap to dismiss |
| `enableNestedScroll` | `bool` | `true` | Enable nested scroll |
| `renderInRootScaffold` | `bool` | `true` | Render into root Scaffold overlay |
| `content` | `Widget` | required | Sheet content |

**Example:**
```dart
MiuixOverlayBottomSheet(
  show: show,
  title: 'Options',
  onDismissRequest: () => setState(() => show = false),
  content: const SizedBox(height: 200),
)
```

### MiuixBottomSheetDefaults

Defaults for Miuix bottom sheets (private constructor, `static` fields only).

| Constant | Value | Description |
|---|---|---|
| `cornerRadius` | `28` | Top corner radius |
| `maxWidth` | `640` | Max sheet width |
| `outsideMargin` | `Size.zero` | Outer margin |
| `insideMargin` | `Size(24, 0)` | Inner margin |

| Static method | Returns | Description |
|---|---|---|
| `backgroundColor(context)` | `Color` | Background color, theme `background` |
| `dragHandleColor(context)` | `Color` | Drag handle color, theme `onSurfaceVariantSummary` at 20% alpha |

### MiuixWindowBottomSheet

A window-level bottom sheet. Flutter has no standalone OS window layer; this widget registers with the root Overlay (`renderInRootScaffold` forced `true`). Differs from `MiuixOverlayBottomSheet` only in that it has no `renderInRootScaffold` param (forced `true`); other params are identical.

| Param | Type | Default | Description |
|---|---|---|---|
| `show` | `bool` | required | Whether the sheet is shown |
| `title` | `String?` | `null` | Title text |
| `startAction` | `Widget?` | `null` | Leading action in the title row |
| `endAction` | `Widget?` | `null` | Trailing action in the title row |
| `backgroundColor` | `Color?` | `null` | Background color, defaults to theme `background` |
| `enableWindowDim` | `bool` | `true` | Whether to dim the scrim |
| `cornerRadius` | `double` | `28` | Top corner radius |
| `sheetMaxWidth` | `double` | `640` | Max sheet width |
| `onDismissRequest` | `VoidCallback?` | `null` | Dismiss request callback |
| `onDismissFinished` | `VoidCallback?` | `null` | Called when exit animation finishes |
| `outsideMargin` | `Size` | `Size.zero` | Outer margin |
| `insideMargin` | `Size` | `Size(24, 0)` | Inner margin |
| `defaultWindowInsetsPadding` | `bool` | `true` | Apply system safe-area padding |
| `dragHandleColor` | `Color?` | `null` | Drag handle color |
| `allowDismiss` | `bool` | `true` | Allow drag/tap to dismiss |
| `enableNestedScroll` | `bool` | `true` | Enable nested scroll |
| `content` | `Widget` | required | Sheet content |

**Example:**
```dart
MiuixWindowBottomSheet(
  show: show,
  title: 'Options',
  onDismissRequest: () => setState(() => show = false),
  content: const SizedBox(height: 200),
)
```

### MiuixDropdownItem

A single item in a dropdown / spinner / dropdown menu. When `children` is non-empty the item becomes a submenu trigger (cascading menu).

| Param | Type | Default | Description |
|---|---|---|---|
| `text` | `String` | required | Item display text |
| `enabled` | `bool` | `true` | Whether clickable |
| `selected` | `bool` | `false` | Selected state |
| `onClick` | `VoidCallback?` | `null` | Tap callback (consumed/ignored by cascade layer when it has children) |
| `icon` | `Widget?` | `null` | Leading icon |
| `summary` | `String?` | `null` | Summary below the title |
| `children` | `List<MiuixDropdownItem>?` | `null` | Optional submenu items |

Named constructor `MiuixDropdownItem.spinner({icon, title, summary})` is kept for legacy `SpinnerEntry` compatibility.

### MiuixDropdownEntry

A group of dropdown items (one visual group). When `enabled` is false all items in the group are disabled.

| Param | Type | Default | Description |
|---|---|---|---|
| `items` | `List<MiuixDropdownItem>` | required | Items shown in the group |
| `enabled` | `bool` | `true` | Whether the group is enabled |

### MiuixDropdownColors

Colors used by dropdown option rows (legacy alias `SpinnerColors`). All 7 fields are required.

| Param | Type | Default | Description |
|---|---|---|---|
| `contentColor` | `Color` | required | Text color of unselected items |
| `summaryColor` | `Color` | required | Summary text color of unselected items |
| `containerColor` | `Color` | required | Background color of unselected items |
| `selectedContentColor` | `Color` | required | Text color of selected items |
| `selectedSummaryColor` | `Color` | required | Summary text color of selected items |
| `selectedContainerColor` | `Color` | required | Background color of selected items |
| `selectedIndicatorColor` | `Color` | required | Color of the selected indicator (checkmark) |

### MiuixDropdownDefaults

Default sizes, paddings and colors for dropdown rows (private constructor, `static` fields and methods only).

| Constant | Value | Description |
|---|---|---|
| `minHeight` | `56` | Minimum row height in dialog mode |
| `minWidth` | `200` | Minimum row width in dialog mode |
| `checkIconSize` | `20` | Size of the trailing checkmark for selected items |
| `arrowSize` | `Size(10, 16)` | Size of the up/down arrows in `MiuixDropdownArrowEndAction` |
| `chevronSize` | `Size(10, 16)` | Size of the trailing chevron for rows with a submenu |
| `iconMinSize` | `26` | Minimum size of the leading icon cell |
| `maxItemTextWidth` | `216` | Maximum width of the inner icon/text row in popup mode |
| `insideHorizontalPadding` | `20` | Horizontal padding per row in popup mode |
| `dialogHorizontalPadding` | `28` | Horizontal padding per row in dialog mode |
| `firstLastVerticalPadding` | `20` | Top/bottom padding for the first/last row in popup mode |
| `middleVerticalPadding` | `12` | Top/bottom padding for middle rows (popup) and all rows (dialog) |
| `iconEndPadding` | `12` | Spacing between the leading icon and the title text |
| `checkIconStartPadding` | `12` | Spacing between the title/summary block and the trailing checkmark |

| Static method | Returns | Description |
|---|---|---|
| `dropdownColors(context, {...})` | `MiuixDropdownColors` | Default colors for popup mode (`content` uses `onSurfaceContainer`, `selected` uses `primary`) |
| `dialogDropdownColors(context, {...})` | `MiuixDropdownColors` | Default colors for dialog mode (`selected` uses `onTertiaryContainer` / `tertiaryContainer`) |

### MiuixDropdownArrowEndAction

A trailing up/down arrow action icon. Drawn at `MiuixDropdownDefaults.arrowSize` (10×16), vertically centered, color determined by `actionColor`. Typically placed at the end of the trigger row to indicate a dropdown can be expanded.

| Param | Type | Default | Description |
|---|---|---|---|
| `actionColor` | `Color` | required | Fill color of the arrow |

**Example:**
```dart
MiuixBasicComponent(
  title: 'Sort',
  endActions: [
    MiuixDropdownArrowEndAction(actionColor: theme.colors.onSurfaceVariantActions),
  ],
  onClick: () {},
)
```

### MiuixDropdownImpl

The render implementation of a dropdown option row. This widget only handles the presentation and click of a single row; the popup layer, trigger and cascading submenu live in separate files. Commonly used inside a `MiuixListPopupColumn` to build custom dropdown content.

| Param | Type | Default | Description |
|---|---|---|---|
| `item` | `MiuixDropdownItem` | required | Data of the current option |
| `optionSize` | `int` | required | Total number of options |
| `isSelected` | `bool` | required | Whether selected |
| `index` | `int` | required | Index of the current item |
| `onSelectedIndexChange` | `ValueChanged<int>` | required | Callback invoked with `index` when selected |
| `dropdownColors` | `MiuixDropdownColors?` | `null` (default `dropdownColors`) | Row colors |
| `enabled` | `bool?` | `null` (defaults to `item.enabled`) | Whether clickable; disabled rows ignore clicks and use the disabled text color |
| `dialogMode` | `bool` | `false` | Whether in dialog mode |
| `hasSubmenu` | `bool` | `false` | Whether this row triggers a submenu; when true, a chevron is shown instead of the checkmark and the accessibility role becomes a button |
| `isFirst` | `bool?` | `null` (defaults to `index == 0`) | Whether this is the first row of the entire popup (popup mode gives the first row a larger top padding) |
| `isLast` | `bool?` | `null` (defaults to `index == optionSize - 1`) | Whether this is the last row of the entire popup |

Named constructor `MiuixDropdownImpl.text({required String text, ...})`: convenience constructor that builds a `MiuixDropdownItem` from `text` and `enabled` internally.

**Example:**
```dart
MiuixListPopupColumn(children: [
  MiuixDropdownImpl.text(text: 'Copy', isSelected: false, index: 0, optionSize: 2, onSelectedIndexChange: (i) {}),
  MiuixDropdownImpl.text(text: 'Paste', isSelected: false, index: 1, optionSize: 2, onSelectedIndexChange: (i) {}),
])
```

### MiuixOverlayDropdownMenu

A Scaffold dropdown menu triggered by a BasicComponent (single group). Default constructor takes one `entry`; named constructor `.entries` takes an `entries` list (multi-group). `MiuixWindowDropdownMenu` is the window-level variant (no `renderInRootScaffold`).

| Param | Type | Default | Description |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry` | required | Single dropdown group (default constructor) |
| `entries` | `List<MiuixDropdownEntry>` | required | Multiple dropdown groups (`.entries` constructor) |
| `title` | `String` | required | Trigger row title |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | Title color |
| `summary` | `String?` | `null` | Trigger row summary |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | Summary color |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | Popup colors, defaults to `MiuixDropdownDefaults.dropdownColors` |
| `startAction` | `Widget?` | `null` | Leading action in the trigger row |
| `bottomAction` | `Widget?` | `null` | Bottom action in the trigger row |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | Trigger row padding |
| `maxHeight` | `double?` | `null` | Max popup height |
| `enabled` | `bool` | `true` | Whether enabled |
| `renderInRootScaffold` | `bool` | `true` | Render into root Scaffold overlay |
| `collapseOnSelection` | `bool?` | `true` (`null` for `.entries`) | Collapse after selection (inferred from group count when `null`) |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | Expand/collapse callback |

**Example:**
```dart
MiuixOverlayDropdownMenu(
  title: 'Sort by',
  entry: MiuixDropdownEntry(items: [
    MiuixDropdownItem(text: 'Name', selected: true, onClick: () {}),
    MiuixDropdownItem(text: 'Date', onClick: () {}),
  ]),
)
```

### MiuixWindowDropdownMenu

A window-level dropdown menu (single group). Named constructor `.entries` takes multiple groups. Flutter has no standalone OS window layer; this widget registers with the root Overlay (`renderInRootScaffold` forced `true`). Differs from `MiuixOverlayDropdownMenu` only in that it has no `renderInRootScaffold` param (forced `true`); other params are identical.

| Param | Type | Default | Description |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry` | required | Single dropdown group (default constructor) |
| `entries` | `List<MiuixDropdownEntry>` | required | Multiple dropdown groups (`.entries` constructor) |
| `title` | `String` | required | Trigger row title |
| `titleColor` | `MiuixBasicComponentColors?` | `null` | Title color |
| `summary` | `String?` | `null` | Trigger row summary |
| `summaryColor` | `MiuixBasicComponentColors?` | `null` | Summary color |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | Popup colors, defaults to `MiuixDropdownDefaults.dropdownColors` |
| `startAction` | `Widget?` | `null` | Leading action in the trigger row |
| `bottomAction` | `Widget?` | `null` | Bottom action in the trigger row |
| `insideMargin` | `EdgeInsetsGeometry` | `MiuixBasicComponentDefaults.insideMargin` | Trigger row padding |
| `maxHeight` | `double?` | `null` | Max popup height |
| `enabled` | `bool` | `true` | Whether enabled |
| `collapseOnSelection` | `bool?` | `true` (`null` for `.entries`) | Collapse after selection (inferred from group count when `null`) |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | Expand/collapse callback |

**Example:**
```dart
MiuixWindowDropdownMenu(
  title: 'Sort by',
  entry: MiuixDropdownEntry(items: [
    MiuixDropdownItem(text: 'Name', selected: true, onClick: () {}),
    MiuixDropdownItem(text: 'Date', onClick: () {}),
  ]),
)
```

### MiuixOverlayIconDropdownMenu

A Scaffold icon dropdown menu triggered by an IconButton (single group). Named constructor `.entries` takes multiple groups; `MiuixWindowIconDropdownMenu` is the window-level variant.

| Param | Type | Default | Description |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry` | required | Single dropdown group (default constructor) |
| `entries` | `List<MiuixDropdownEntry>` | required | Multiple dropdown groups (`.entries` constructor) |
| `enabled` | `bool` | `true` | Whether enabled |
| `maxHeight` | `double?` | `null` | Max popup height |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | Popup colors |
| `renderInRootScaffold` | `bool` | `true` | Render into root Scaffold overlay |
| `collapseOnSelection` | `bool?` | `true` (`null` for `.entries`) | Collapse after selection |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | Expand/collapse callback |
| `backgroundColor` | `Color?` | `null` | Icon button background color |
| `cornerRadius` | `double` | `MiuixIconButtonDefaults.cornerRadius` | Icon button corner radius |
| `minHeight` | `double` | `MiuixIconButtonDefaults.minHeight` | Icon button min height |
| `minWidth` | `double` | `MiuixIconButtonDefaults.minWidth` | Icon button min width |
| `child` | `Widget` | required | Icon button content |

### MiuixWindowIconDropdownMenu

A window-level icon dropdown menu (single group). Named constructor `.entries` takes multiple groups. Flutter has no standalone OS window layer; this widget registers with the root Overlay (`renderInRootScaffold` forced `true`). Differs from `MiuixOverlayIconDropdownMenu` only in that it has no `renderInRootScaffold` param (forced `true`); other params are identical.

| Param | Type | Default | Description |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry` | required | Single dropdown group (default constructor) |
| `entries` | `List<MiuixDropdownEntry>` | required | Multiple dropdown groups (`.entries` constructor) |
| `enabled` | `bool` | `true` | Whether enabled |
| `maxHeight` | `double?` | `null` | Max popup height |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | Popup colors |
| `collapseOnSelection` | `bool?` | `true` (`null` for `.entries`) | Collapse after selection |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | Expand/collapse callback |
| `backgroundColor` | `Color?` | `null` | Icon button background color |
| `cornerRadius` | `double` | `MiuixIconButtonDefaults.cornerRadius` | Icon button corner radius |
| `minHeight` | `double` | `MiuixIconButtonDefaults.minHeight` | Icon button min height |
| `minWidth` | `double` | `MiuixIconButtonDefaults.minWidth` | Icon button min width |
| `child` | `Widget` | required | Icon button content |

### MiuixOverlayIconCascadingDropdownMenu

A Scaffold icon cascading dropdown menu triggered by an IconButton; a `MiuixDropdownItem.children`-bearing item becomes a submenu trigger, cascade depth limited to 2. Named constructor `.entries` takes multiple groups; `MiuixWindowIconCascadingDropdownMenu` is the window-level variant.

| Param | Type | Default | Description |
|---|---|---|---|
| `entry` / `entries` | `MiuixDropdownEntry` / `List<MiuixDropdownEntry>` | required | Dropdown groups (default / `.entries` constructor) |
| `enabled` | `bool` | `true` | Whether enabled |
| `maxHeight` | `double?` | `null` | Max popup height |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | Popup colors |
| `renderInRootScaffold` | `bool` | `true` | Render into root Scaffold overlay |
| `collapseOnSelection` | `bool` | `true` | Collapse after selection |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | Expand/collapse callback |
| `backgroundColor` | `Color?` | `null` | Icon button background color |
| `cornerRadius` | `double` | `MiuixIconButtonDefaults.cornerRadius` | Icon button corner radius |
| `minHeight` | `double` | `MiuixIconButtonDefaults.minHeight` | Icon button min height |
| `minWidth` | `double` | `MiuixIconButtonDefaults.minWidth` | Icon button min width |
| `child` | `Widget` | required | Icon button content |

### MiuixWindowIconCascadingDropdownMenu

A window-level icon cascading dropdown menu (single group). Named constructor `.entries` takes multiple groups. Flutter has no standalone OS window layer; this widget registers with the window-level Overlay. Differs from `MiuixOverlayIconCascadingDropdownMenu` only in that it has no `renderInRootScaffold` param (forced `true`); other params are identical.

| Param | Type | Default | Description |
|---|---|---|---|
| `entry` / `entries` | `MiuixDropdownEntry` / `List<MiuixDropdownEntry>` | required | Dropdown groups (default / `.entries` constructor) |
| `enabled` | `bool` | `true` | Whether enabled |
| `maxHeight` | `double?` | `null` | Max popup height |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | Popup colors |
| `collapseOnSelection` | `bool` | `true` | Collapse after selection |
| `onExpandedChange` | `ValueChanged<bool>?` | `null` | Expand/collapse callback |
| `backgroundColor` | `Color?` | `null` | Icon button background color |
| `cornerRadius` | `double` | `MiuixIconButtonDefaults.cornerRadius` | Icon button corner radius |
| `minHeight` | `double` | `MiuixIconButtonDefaults.minHeight` | Icon button min height |
| `minWidth` | `double` | `MiuixIconButtonDefaults.minWidth` | Icon button min width |
| `child` | `Widget` | required | Icon button content |

### MiuixDropdownEntriesPopupContent

Renders `MiuixDropdownEntry` group lists inside a popup container. Computes the popup-global first/last internally: only the very first and very last rows of the whole popup get the larger first/last padding; group boundaries fall back to middle-row padding. A 1.5dp divider is inserted between groups. The caller must place it inside a scrollable container such as `MiuixListPopupColumn`; this widget itself does not scroll.

| Param | Type | Default | Description |
|---|---|---|---|
| `entries` | `List<MiuixDropdownEntry>` | required | One or more dropdown groups |
| `dropdownColors` | `MiuixDropdownColors` | required | Dropdown row colors |
| `onItemClick` | `void Function(int entryIdx, int itemIdx)` | required | Item click callback with `(group index, item index)` |

### MiuixDropdownEntriesDialogItems

Renders `MiuixDropdownEntry` group lists inside a dialog container (as children of `ListView`/`Column`). Dialog mode uses a uniform vertical padding and does not propagate popup-global first/last; a 1.5dp divider is also inserted between groups.

| Param | Type | Default | Description |
|---|---|---|---|
| `entries` | `List<MiuixDropdownEntry>` | required | One or more dropdown groups |
| `dropdownColors` | `MiuixDropdownColors` | required | Dropdown row colors |
| `onItemClick` | `void Function(int entryIdx, int itemIdx)` | required | Item click callback |

### MiuixOverlayDropdownPopup

A Scaffold-level dropdown popup. Default constructor takes a single `entry` (single group); named constructor `.entries` takes an `entries` list (multi-group). Internally renders via `MiuixOverlayListPopup` and `MiuixDropdownEntriesPopupContent`, aligned with `MiuixPopupAlign.end`. Tapping an item triggers `HapticFeedback.selectionClick()` and closes based on `collapseOnSelection`.

| Param | Type | Default | Description |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry?` | required (default constructor) | Single dropdown group |
| `entries` | `List<MiuixDropdownEntry>` | required (`.entries` constructor) | Multiple dropdown groups |
| `show` | `bool` | required | Whether to show |
| `anchorBounds` | `Rect` | required | Anchor Rect in window coordinates |
| `onDismiss` | `VoidCallback` | required | Dismiss request callback |
| `onDismissFinished` | `VoidCallback` | required | Exit animation end callback |
| `maxHeight` | `double?` | `null` | Max popup height |
| `dropdownColors` | `MiuixDropdownColors` | required | Popup colors |
| `renderInRootScaffold` | `bool` | `true` | Whether to register with the root registry |
| `collapseOnSelection` | `bool?` | `true` (default) / `entries.length <= 1` (`.entries`) | Collapse after selection |

### MiuixWindowDropdownPopup

A window-level dropdown popup. Flutter's Navigator Overlay is already a window-level host, so this does not depend on `MiuixScaffold` and has no `renderInRootScaffold` param. Otherwise behaves like `MiuixOverlayDropdownPopup`.

| Param | Type | Default | Description |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry?` | required (default constructor) | Single dropdown group |
| `entries` | `List<MiuixDropdownEntry>` | required (`.entries` constructor) | Multiple dropdown groups |
| `show` | `bool` | required | Whether to show |
| `anchorBounds` | `Rect` | required | Anchor Rect |
| `onDismiss` | `VoidCallback` | required | Dismiss request callback |
| `onDismissFinished` | `VoidCallback` | required | Exit animation end callback |
| `maxHeight` | `double?` | `null` | Max popup height |
| `dropdownColors` | `MiuixDropdownColors` | required | Popup colors |
| `collapseOnSelection` | `bool?` | `true` (default) / `entries.length <= 1` (`.entries`) | Collapse after selection |

### MiuixOverlayDropdownDialog

A Scaffold dropdown dialog (single group). Named constructor `.entries` takes multiple groups; uses `MiuixOverlayDialog` as the container to render `MiuixDropdownEntriesDialogItems`, with a title and a bottom confirm button. Tapping an item triggers `HapticFeedback.selectionClick()` and closes the dialog depending on `collapseOnSelection`.

| Param | Type | Default | Description |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry?` | required (default constructor) | Single dropdown group |
| `entries` | `List<MiuixDropdownEntry>` | required (`.entries` constructor) | Multiple dropdown groups |
| `title` | `String` | required | Dialog title |
| `dialogButtonString` | `String` | required | Bottom button text |
| `show` | `bool` | required | Whether to show |
| `onDismiss` | `VoidCallback` | required | Dismiss request callback |
| `onDismissFinished` | `VoidCallback` | required | Exit animation end callback |
| `dropdownColors` | `MiuixDropdownColors` | required | Dropdown row colors |
| `renderInRootScaffold` | `bool` | `true` | Render into root Scaffold overlay |
| `collapseOnSelection` | `bool?` | `true` (default) / `entries.length <= 1` (`.entries`) | Collapse after selection |

### MiuixWindowDropdownDialog

A window-level dropdown dialog (single group). Named constructor `.entries` takes multiple groups. Flutter has no standalone OS window layer; this widget registers with the root Overlay via `MiuixOverlayDialog`'s `renderInRootScaffold: true`. Differs from `MiuixOverlayDropdownDialog` only in that it has no `renderInRootScaffold` param (forced `true`); other params are identical.

| Param | Type | Default | Description |
|---|---|---|---|
| `entry` | `MiuixDropdownEntry?` | required (default constructor) | Single dropdown group |
| `entries` | `List<MiuixDropdownEntry>` | required (`.entries` constructor) | Multiple dropdown groups |
| `title` | `String` | required | Dialog title |
| `dialogButtonString` | `String` | required | Bottom button text |
| `show` | `bool` | required | Whether to show |
| `onDismiss` | `VoidCallback` | required | Dismiss request callback |
| `onDismissFinished` | `VoidCallback` | required | Exit animation end callback |
| `dropdownColors` | `MiuixDropdownColors` | required | Dropdown row colors |
| `collapseOnSelection` | `bool?` | `true` (default) / `entries.length <= 1` (`.entries`) | Collapse after selection |

### MiuixListPopupColumn

A scrollable column that unifies all items to the width of the widest of the first eight items (clamped to 200–288 logical px); one of the ListPopup building blocks, usually given a max-height constraint by the popup host.

| Param | Type | Default | Description |
|---|---|---|---|
| `children` | `List<Widget>` | required | List items |
| `scrollController` | `ScrollController?` | `null` | Scroll controller |
| `physics` | `ScrollPhysics?` | `null` | Scroll physics, defaults to `ClampingScrollPhysics` |

### ListPopup Series

ListPopup is a lightweight popup layer positioned by an anchor Rect, replicating 0.15→1 reveal, fade, dim, tap-outside dismiss and back-key dismiss. Suitable for context menus, right-click menus, custom dropdowns, etc.

#### MiuixPopupAlign

Logical alignment of the popup relative to the anchor. `start`/`end` are mirrored automatically under RTL.

| Value | Description |
|---|---|
| `start` | Start side (left in LTR), vertical position auto-selected above/below the anchor |
| `end` | End side (right in LTR), vertical position auto-selected |
| `topStart` | Below the anchor, start-aligned |
| `topEnd` | Below the anchor, end-aligned |
| `bottomStart` | Above the anchor, start-aligned |
| `bottomEnd` | Above the anchor, end-aligned |

#### MiuixPopupPositionProvider

Position calculation interface for the unified popup host. All coordinates are logical pixels relative to the window's top-left; implementations **must not** read [MediaQuery] themselves, so the same algorithm works for both Overlay and window-level hosts.

| Method / Field | Type | Description |
|---|---|---|
| `calculatePosition({anchorBounds, windowBounds, textDirection, popupContentSize, popupMargin, alignment})` | `Offset` | Computes the popup's top-left position in window coordinates |
| `margins` | `EdgeInsetsGeometry` | Extra popup margin; directional margins are resolved by the caller against the current text direction |

#### MiuixPopupSpringSpec

Spring specification for popup animations.

| Param | Type | Description |
|---|---|---|
| `dampingRatio` | `double` | Damping ratio |
| `stiffness` | `double` | Stiffness |
| `visibilityThreshold` | `double` | Spring simulation tolerance |

The `description` getter returns a Flutter `SpringDescription`; `simulation(from, to, {velocity})` creates a `SpringSimulation` for `AnimationController.unbounded().animateWith(...)`.

#### MiuixPopupTweenSpec

Duration and curve of a popup tween animation.

| Param | Type | Description |
|---|---|---|
| `duration` | `Duration` | Duration |
| `curve` | `Curve` | Curve |

#### MiuixListPopupDefaults

Size, animation and default position strategies for ListPopup (private constructor, `static` fields only).

| Constant / Method | Value / Returns | Description |
|---|---|---|
| `minWidth` | `200` | Minimum popup width |
| `minPopupHeight` | `50` | Minimum popup height |
| `cornerRadius` | `16` | Corner radius |
| `fractionAnimationSpec` | spring(0.82, 362.5) | Reveal animation spring |
| `resetAnimationSpec` | same as above | Reset animation spring |
| `alphaEnterAnimationSpec` | 200ms / fastOutSlowIn | Enter fade |
| `alphaExitAnimationSpec` | 150ms / fastOutSlowIn | Exit fade |
| `dimEnterAnimationSpec` | 300ms / sinOut | Dim enter |
| `dimExitAnimationSpec` | 150ms / sinOut | Dim exit |
| `dropdownPosition` | `MiuixPopupPositionProvider` | Default dropdown position strategy (verticalMargin=8) |
| `contextMenuPosition` | `MiuixPopupPositionProvider` | Default context-menu position strategy (no margin) |
| `dropdownPositionProvider({verticalMargin, horizontalMargin})` | `MiuixPopupPositionProvider` | Creates a custom dropdown position strategy |

#### MiuixListPopupColumn

A scrollable column that unifies all items to the width of the widest of the first eight items (clamped to 200–288 logical px); one of the ListPopup building blocks, usually given a max-height constraint by the popup host.

| Param | Type | Default | Description |
|---|---|---|---|
| `children` | `List<Widget>` | required | List items |
| `scrollController` | `ScrollController?` | `null` | Scroll controller |
| `physics` | `ScrollPhysics?` | `null` | Scroll physics, defaults to `ClampingScrollPhysics` |

#### MiuixListPopupContent

A container that carries the list content with scale, fade and directional squircle reveal. Usually consumed internally by the popup host; callers rarely construct it directly.

| Param | Type | Default | Description |
|---|---|---|---|
| `popupContentSize` | `Size` | required | Current content size (`Size.zero` on first build) |
| `onPopupContentSizeChange` | `ValueChanged<Size>` | required | Content size change callback |
| `fractionProgress` | `double Function()` | required | Live reader for reveal progress (0..1) |
| `alphaProgress` | `double Function()` | required | Live reader for alpha progress (0..1) |
| `popupLayoutPosition` | `MiuixPopupLayoutPosition` | required | Layout position info |
| `localTransformOrigin` | `Offset` | required | Local transform origin (normalized) |
| `child` | `Widget` | required | List content (usually `MiuixListPopupColumn`) |
| `animation` | `Listenable?` | `null` | Merged animation listenable to avoid widget rebuilds |
| `backgroundColor` | `Color?` | `null` | Background color, defaults to `colors.surfaceContainer` |
| `cornerRadius` | `double` | `MiuixListPopupDefaults.cornerRadius` (16) | Corner radius |

#### MiuixOverlayListPopup

A Scaffold-level list popup. Registers with the root or local registry via [MiuixPopupLayout] and is drawn by the unified popup host.

| Param | Type | Default | Description |
|---|---|---|---|
| `show` | `bool` | required | Whether to show |
| `anchorBounds` | `Rect` | required | Anchor Rect in window coordinates |
| `popupPositionProvider` | `MiuixPopupPositionProvider?` | `null` (defaults to `dropdownPosition`) | Position strategy |
| `alignment` | `MiuixPopupAlign` | `start` | Alignment |
| `enableWindowDim` | `bool` | `true` | Whether to enable dim |
| `onDismissRequest` | `VoidCallback?` | `null` | Dismiss request callback |
| `onDismissFinished` | `VoidCallback?` | `null` | Exit animation end callback |
| `maxHeight` | `double?` | `null` | Max height |
| `minWidth` | `double` | `MiuixListPopupDefaults.minWidth` (200) | Min width |
| `renderInRootScaffold` | `bool` | `true` | Whether to register with the root registry |
| `content` | `Widget` | required | Popup content |

**Example:**
```dart
MiuixOverlayListPopup(
  show: show,
  anchorBounds: anchorRect,
  onDismissRequest: () => setState(() => show = false),
  content: MiuixListPopupColumn(children: [
    MiuixDropdownImpl.text(text: 'Copy', isSelected: false, index: 0,
      optionSize: 2, onSelectedIndexChange: (i) {}),
  ]),
)
```

#### MiuixWindowListPopup

A window-level list popup. Flutter's Navigator Overlay is already a window-level host, so this does not depend on [MiuixScaffold]. Same params as `MiuixOverlayListPopup` but without `renderInRootScaffold`.

#### MiuixOverlayCascadingListPopup

A Scaffold-level two-level cascading list popup. When a `MiuixDropdownItem.children` is non-empty it becomes a submenu trigger; cascade depth is limited to 2. The main menu reuses ListPopup animations; the submenu uses 0.95 main-layer scale, half-strength dim and a spring expand to reproduce the cascade state.

| Param | Type | Default | Description |
|---|---|---|---|
| `show` | `bool` | required | Whether to show |
| `anchorBounds` | `Rect` | required | Anchor Rect |
| `entries` | `List<MiuixDropdownEntry>` | required | Multi-group data (including submenu items) |
| `onDismissRequest` | `VoidCallback` | required | Dismiss request callback |
| `onDismissFinished` | `VoidCallback?` | `null` | Exit animation end callback |
| `popupPositionProvider` | `MiuixPopupPositionProvider?` | `null` (defaults to `dropdownPosition`) | Position strategy |
| `alignment` | `MiuixPopupAlign` | `end` | Alignment |
| `enableWindowDim` | `bool` | `true` | Whether to enable dim |
| `maxHeight` | `double?` | `null` | Max height |
| `minWidth` | `double` | `200` | Min width |
| `renderInRootScaffold` | `bool` | `true` | Whether to register with root |
| `dropdownColors` | `MiuixDropdownColors?` | `null` | Colors, defaults to `dropdownColors` |
| `collapseOnSelection` | `bool` | `true` | Whether to collapse after selection |

#### MiuixWindowCascadingListPopup

A window-level two-level cascading list popup. Same params as above, without `renderInRootScaffold`.

#### MiuixPopupLayoutPosition

Which side of the anchor the popup sits on, and which horizontal edge it hugs.

| Field | Type | Description |
|---|---|---|
| `showBelow` | `bool` | Whether shown below the anchor |
| `showAbove` | `bool` | Whether shown above the anchor |
| `isRightAligned` | `bool` | Whether right-aligned |
| `showMiddle` | `bool` (getter) | Neither above nor below (vertically overlaps the anchor) |

#### MiuixListPopupLayoutInfo

Full layout info needed by the popup host for positioning, scaling and reveal animation. Usually computed via [computeListPopupLayoutInfo] and passed into the host.

| Field | Type | Description |
|---|---|---|
| `windowBounds` | `Rect` | Window safe-area bounds |
| `popupMargin` | `EdgeInsets` | Resolved popup margin |
| `calculatedOffset` | `Offset` | Popup top-left in window coordinates; `Offset.zero` until content is measured |
| `effectiveTransformOrigin` | `Offset` | Normalized window-coordinate origin for the unified host's global animations |
| `localTransformOrigin` | `Offset` | Normalized popup-local origin for [MiuixListPopupContent] |
| `popupLayoutPosition` | `MiuixPopupLayoutPosition` | Layout position info |

#### `computeListPopupLayoutInfo(context, {alignment, popupPositionProvider, parentBounds, popupContentSize})` → `MiuixListPopupLayoutInfo`

Computes the layout info needed by the popup host from the window safe area, anchor and measured content. `parentBounds` must be in window coordinates; pass `Size.zero` on first build — a predicted origin is returned, then re-computed once `MiuixListPopupContent.onPopupContentSizeChange` reports back.

#### `safeTransformOrigin(x, y)` → `Offset`

Zeroes out NaN and negative values in a transform origin; positive values (including >1) are preserved.

### MiuixTooltipAnchorPosition

Enum of preferred tooltip positions relative to the anchor. Automatically flips to the opposite side when space is short; `start`/`end` are first resolved to `left`/`right` under RTL.

| Value | Description |
|---|---|
| `above` | Above the anchor |
| `below` | Below the anchor |
| `left` | To the left of the anchor |
| `right` | To the right of the anchor |
| `start` | Start side (`left` in LTR, `right` in RTL) |
| `end` | End side (`right` in LTR, `left` in RTL) |

### MiuixTooltipState

Visibility state controller for tooltips, extending `ChangeNotifier`. All instances share a single active slot, so at most one tooltip is visible at a time; non-persistent states auto-close after `MiuixTooltipDefaults.tooltipDuration` (1500ms).

| Param | Type | Default | Description |
|---|---|---|---|
| `initialIsVisible` | `bool` | `false` | Initial visibility |
| `isPersistent` | `bool` | `false` | Whether the tooltip is persistent (no auto-close) |

| Method / Field | Returns | Description |
|---|---|---|
| `isVisible` | `bool` (getter) | Current visibility |
| `show()` | `Future<void>` | Shows the tooltip; the returned Future completes when closed |
| `dismiss()` | `void` | Dismisses the tooltip |

### MiuixTooltipScope

Anchor info available when building tooltip content.

| Field | Type | Description |
|---|---|---|
| `positioning` | `MiuixTooltipAnchorPosition` | Resolved position (after RTL resolution and short-space flip) |
| `anchorBounds` | `Rect` | Anchor bounds in Overlay coordinates |

### MiuixRichTooltipColors

Color configuration for rich tooltips. All 4 fields are required.

| Param | Type | Default | Description |
|---|---|---|---|
| `containerColor` | `Color` | required | Container background color |
| `contentColor` | `Color` | required | Body content color |
| `titleContentColor` | `Color` | required | Title content color |
| `actionContentColor` | `Color` | required | Action button content color |

### MiuixTooltipDefaults

Default sizes, colors and animation durations for tooltips (private constructor, `static` fields only).

| Constant | Value | Description |
|---|---|---|
| `spacingBetweenTooltipAndAnchor` | `8` | Gap between tooltip and anchor |
| `caretSize` | `Size(16, 8)` | Caret size |
| `plainTooltipMaxWidth` | `200` | Plain tooltip max width |
| `plainTooltipCornerRadius` | `12` | Plain tooltip corner radius |
| `plainTooltipInsideMargin` | `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` | Plain tooltip inner padding |
| `richTooltipMaxWidth` | `320` | Rich tooltip max width |
| `richTooltipCornerRadius` | `16` | Rich tooltip corner radius |
| `richTooltipInsideMargin` | `EdgeInsets.all(16)` | Rich tooltip inner padding |
| `richTooltipActionCornerRadius` | `8` | Rich tooltip action button corner radius |
| `richTooltipActionInsideMargin` | `EdgeInsets.symmetric(horizontal: 12, vertical: 6)` | Rich tooltip action button inner padding |
| `tooltipDuration` | `Duration(milliseconds: 1500)` | Auto-close duration for non-persistent tooltips |
| `animationDuration` | `Duration(milliseconds: 180)` | Enter/exit animation duration |

| Static method | Returns | Description |
|---|---|---|
| `plainTooltipContainerColor(context)` | `Color` | Plain tooltip container color, `onSecondaryVariant` |
| `plainTooltipContentColor(context)` | `Color` | Plain tooltip content color, `secondaryVariant` |
| `richTooltipColors(context)` | `MiuixRichTooltipColors` | Default rich tooltip colors |

### MiuixTooltipBox

Anchors `tooltip` to `child`, supporting mouse hover, touch long-press and state control.

| Param | Type | Default | Description |
|---|---|---|---|
| `tooltip` | `Widget Function(BuildContext, MiuixTooltipScope)` | required | Tooltip content slot; scope provides resolved position and anchor bounds |
| `child` | `Widget` | required | Anchor child |
| `state` | `MiuixTooltipState?` | `null` | Visibility state, created internally when omitted |
| `positioning` | `MiuixTooltipAnchorPosition` | `below` | Preferred position, flips when space is short |
| `spacing` | `double` | `8` | Gap between tooltip and anchor |
| `focusable` | `bool` | `false` | Dismiss on tap-outside/back |
| `enableUserInput` | `bool` | `true` | Respond to hover/long-press |
| `semanticLabel` | `String` | `'显示提示'` | Accessibility label |

**Example:**
```dart
MiuixTooltipBox(
  tooltip: (context, scope) =>
      MiuixPlainTooltip(scope: scope, child: const Text('Tooltip text')),
  child: MiuixIcon(vector: MiuixIcons.extended.byName('info')!),
)
```

### MiuixPlainTooltip

A short-label tooltip on an inverse surface, used with `MiuixTooltipBox`.

| Param | Type | Default | Description |
|---|---|---|---|
| `scope` | `MiuixTooltipScope` | required | Anchor info from `MiuixTooltipBox` |
| `child` | `Widget` | required | Tooltip content |
| `showCaret` | `bool` | `false` | Show caret pointing at the anchor |
| `maxWidth` | `double` | `200` | Max width |
| `cornerRadius` | `double` | `12` | Corner radius |
| `containerColor` | `Color?` | `null` | Background color, defaults to inverse surface |
| `contentColor` | `Color?` | `null` | Content color |
| `insideMargin` | `EdgeInsetsGeometry` | `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` | Inner padding |

### MiuixRichTooltip

A persistent rich tooltip with optional title and action, used with `MiuixTooltipBox`.

| Param | Type | Default | Description |
|---|---|---|---|
| `scope` | `MiuixTooltipScope` | required | Anchor info from `MiuixTooltipBox` |
| `text` | `Widget` | required | Body content |
| `title` | `Widget?` | `null` | Title |
| `action` | `Widget?` | `null` | Action button |
| `showCaret` | `bool` | `false` | Show caret |
| `maxWidth` | `double` | `320` | Max width |
| `cornerRadius` | `double` | `16` | Corner radius |
| `colors` | `MiuixRichTooltipColors?` | `null` | Colors, defaults to theme |
| `insideMargin` | `EdgeInsetsGeometry` | `EdgeInsets.all(16)` | Inner padding |

### MiuixRichTooltipBox

A convenience wrapper for rich tooltips; creates a persistent state by default and supports tap-outside/back dismiss. Takes title/body/action as strings, so no tooltip slot is needed.

| Param | Type | Default | Description |
|---|---|---|---|
| `text` | `String` | required | Body text |
| `child` | `Widget` | required | Anchor child |
| `state` | `MiuixTooltipState?` | `null` | Visibility state, defaults to an internally created persistent state |
| `title` | `String?` | `null` | Title text |
| `actionText` | `String?` | `null` | Action button text |
| `onActionPressed` | `VoidCallback?` | `null` | Action button callback |
| `enabled` | `bool` | `true` | Respond to user input |
| `positioning` | `MiuixTooltipAnchorPosition` | `below` | Preferred position |
| `colors` | `MiuixRichTooltipColors?` | `null` | Colors |
| `showCaret` | `bool` | `false` | Show caret |

### MiuixSnackbarVisuals

Visual data of a snackbar.

| Param | Type | Default | Description |
|---|---|---|---|
| `message` | `String` | required | Message text to display |
| `actionLabel` | `String?` | `null` | Optional action label |
| `withDismissAction` | `bool` | `false` | Whether to show a dismiss action |
| `duration` | `MiuixSnackbarDuration` | `MiuixSnackbarDuration.short` | Display duration |

### MiuixSnackbarData

Interaction data interface for snackbars.

| Method / Field | Type | Description |
|---|---|---|
| `visuals` | `MiuixSnackbarVisuals` (getter) | Visual data of the snackbar |
| `dismiss()` | `Future<void>` | Dismisses the snackbar |
| `performAction()` | `Future<void>` | Performs the snackbar action |

### MiuixSnackbarResult

Result enum for snackbar completion.

| Value | Description |
|---|---|
| `dismissed` | The snackbar was dismissed or timed out |
| `actionPerformed` | The user performed the snackbar action |

### MiuixSnackbarColors

Color configuration for snackbar cards. All 5 fields are required.

| Param | Type | Default | Description |
|---|---|---|---|
| `containerColor` | `Color` | required | Card background color |
| `contentColor` | `Color` | required | Message content color |
| `actionContentColor` | `Color` | required | Action label content color |
| `dismissActionContentColor` | `Color` | required | Dismiss action content color |
| `actionContainerColor` | `Color` | required | Action label capsule background color |

### MiuixSnackbarDefaults

Defaults for snackbars (private constructor, `static` fields only).

| Constant | Value | Description |
|---|---|---|
| `cornerRadius` | `16` | Default corner radius |
| `insideMargin` | `EdgeInsets.all(12)` | Default inner padding |
| `outerPadding` | `EdgeInsets.only(left: 12, right: 12, top: 8)` | Default outer padding |
| `actionCornerRadius` | `50` | Default action label capsule corner radius |
| `actionInsideMargin` | `EdgeInsets.symmetric(horizontal: 12)` | Default action label capsule inner padding |

| Static method | Returns | Description |
|---|---|---|
| `snackbarColors(context)` | `MiuixSnackbarColors` | Creates default snackbar colors from the current theme |

### MiuixSnackbarHostState

State object for the Snackbar Host, extending `ChangeNotifier`. Holds the snackbar queue; each `showSnackbar` adds an independent snackbar at the bottom of the queue, so multiple messages can be visible at once. The returned Future completes on timeout, dismiss, swipe-dismiss or action performed.

| Method | Returns | Description |
|---|---|---|
| `showSnackbar(message, {actionLabel, withDismissAction, duration})` | `Future<MiuixSnackbarResult>` | Enqueues a snackbar and returns its completion result |
| `newestSnackbarData()` | `Future<MiuixSnackbarData?>` | Returns the newest visible snackbar data |
| `oldestSnackbarData()` | `Future<MiuixSnackbarData?>` | Returns the oldest visible snackbar data |

**Example:**
```dart
final host = MiuixSnackbarHostState();
host.showSnackbar('Saved', actionLabel: 'Undo');
MiuixSnackbarHost(state: host);
```

### MiuixSnackbarHost

Manages the snackbar queue, auto-dismiss, enter/exit and bidirectional swipe-to-dismiss; the newest message sits at the bottom.

| Param | Type | Default | Description |
|---|---|---|---|
| `state` | `MiuixSnackbarHostState` | required | Host state |
| `canSwipeToDismiss` | `bool` | `true` | Allow horizontal swipe to dismiss |
| `builder` | `Widget Function(BuildContext, MiuixSnackbarData)?` | `null` | Custom card content, defaults to building `MiuixSnackbar` |
| `blurSigma` | `double` | `0.0` | Blur sigma passed to the default `MiuixSnackbar`; > 0 enables frosted-glass background |
| `blurBackgroundAlpha` | `double` | `0.55` | Background opacity passed to the default `MiuixSnackbar` when blur is enabled |

`MiuixSnackbarHostState` enqueues via `showSnackbar(message, {actionLabel, withDismissAction, duration})`, returning a `Future<MiuixSnackbarResult>`.

**Example:**
```dart
final host = MiuixSnackbarHostState();
// show
host.showSnackbar('Saved', actionLabel: 'Undo');
// mount (frosted-glass background)
MiuixSnackbarHost(state: host, blurSigma: 30);
```

### MiuixSnackbar

The snackbar card built by the host by default; can be used directly inside a custom `builder`.

| Param | Type | Default | Description |
|---|---|---|---|
| `data` | `MiuixSnackbarData` | required | Snackbar interaction data |
| `cornerRadius` | `double` | `16` | Card corner radius |
| `colors` | `MiuixSnackbarColors?` | `null` | Card colors, defaults to theme |
| `insideMargin` | `EdgeInsetsGeometry` | `EdgeInsets.all(12)` | Card inner padding |
| `blurSigma` | `double` | `0.0` | Gaussian blur sigma; > 0 enables HyperOS-style frosted-glass background (blurs content behind via `BackdropFilter`, container color becomes semi-transparent) |
| `blurBackgroundAlpha` | `double` | `0.55` | Container opacity when blur is enabled; lower = more transparent |

### MiuixFloatingToolbar

A floating toolbar: a self-contained container (squircle background + fixed-geometry shadow + optional stroke). Row/column orientation is decided by the caller inside `child`.

| Param | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | required | Content (caller arranges with Row/Column) |
| `color` | `Color?` | `null` | Background color, defaults to theme `surfaceContainer` |
| `cornerRadius` | `double` | `50` | Corner radius |
| `outSidePadding` | `EdgeInsetsGeometry` | `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` | Outer padding |
| `shadowElevation` | `double` | `4` | Shadow toggle (>0 shows; geometry fixed, not scaled) |
| `showDivider` | `bool` | `false` | Show a 0.75dp stroke |

**Example:**
```dart
MiuixFloatingToolbar(
  child: Row(mainAxisSize: MainAxisSize.min, children: const [/* buttons */]),
)
```

### MiuixFloatingToolbarDefaults

Defaults for floating toolbars (private constructor, `static` fields only).

| Constant | Value | Description |
|---|---|---|
| `cornerRadius` | `50` | Default corner radius (forms a capsule outline with short toolbar heights) |
| `outSidePadding` | `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` | Toolbar outer padding |

| Static method | Returns | Description |
|---|---|---|
| `defaultColor(context)` | `Color` | Default background color, theme `surfaceContainer` |

### MiuixProgressIndicatorColors

Color configuration for progress indicators. All 3 fields are required.

| Param | Type | Default | Description |
|---|---|---|---|
| `foregroundColor` | `Color` | required | Foreground color when enabled |
| `disabledForegroundColor` | `Color` | required | Foreground color when disabled |
| `backgroundColor` | `Color` | required | Track background color |

| Method | Returns | Description |
|---|---|---|
| `foreground(bool enabled)` | `Color` | Returns the foreground color based on `enabled` |
| `background()` | `Color` | Returns the track background color |

### MiuixProgressIndicatorDefaults

Defaults for progress indicators (private constructor, `static` fields only).

| Constant | Value | Description |
|---|---|---|
| `defaultLinearHeight` | `6` | Default linear indicator height |
| `defaultCircularStrokeWidth` | `4` | Default circular indicator stroke width |
| `defaultCircularSize` | `30` | Default circular indicator size |
| `defaultInfiniteStrokeWidth` | `2` | Default infinite indicator track ring width |
| `defaultInfiniteOrbitingDotSize` | `2` | Default infinite indicator orbiting dot size |
| `defaultInfiniteSize` | `20` | Default infinite indicator size |

| Static method | Returns | Description |
|---|---|---|
| `defaultColors(context)` | `MiuixProgressIndicatorColors` | Default colors for linear and circular progress indicators |

### MiuixLinearProgressIndicator

A Miuix-style linear progress indicator. When `progress` is `null` it shows a 1250ms linear looping animation.

| Param | Type | Default | Description |
|---|---|---|---|
| `progress` | `double?` | `null` | Progress (0–1); `null` for infinite loop |
| `colors` | `MiuixProgressIndicatorColors?` | `null` | Colors, defaults to theme |
| `height` | `double` | `6` | Track height |

### MiuixCircularProgressIndicator

A Miuix-style circular progress indicator. When `progress` is `null` the arc rotates and sweeps between 30° and 120°.

| Param | Type | Default | Description |
|---|---|---|---|
| `progress` | `double?` | `null` | Progress (0–1); `null` for infinite loop |
| `colors` | `MiuixProgressIndicatorColors?` | `null` | Colors, defaults to theme |
| `strokeWidth` | `double` | `4` | Arc stroke width |
| `size` | `double` | `30` | Indicator size |

### MiuixInfiniteProgressIndicator

An infinite progress indicator with a track ring and an orbiting dot.

| Param | Type | Default | Description |
|---|---|---|---|
| `color` | `Color` | `Color(0xFF888888)` | Color |
| `size` | `double` | `20` | Indicator size |
| `strokeWidth` | `double` | `2` | Track ring width |
| `orbitingDotSize` | `double` | `2` | Orbiting dot size |

**Example:**
```dart
const MiuixCircularProgressIndicator()          // infinite loop
const MiuixLinearProgressIndicator(progress: 0.6)
```

### MiuixRefreshState

Enum of visual states for the pull-to-refresh indicator.

| Value | Description |
|---|---|
| `idle` | Idle |
| `pulling` | Pulling, threshold not yet reached |
| `thresholdReached` | Refresh threshold reached |
| `refreshing` | Refreshing |
| `refreshComplete` | Refresh complete (fade-out transition) |

### MiuixPullToRefreshDefaults

Defaults for pull-to-refresh (private constructor, `static` fields only).

| Constant | Value | Description |
|---|---|---|
| `color` | `Color(0xFF888888)` | Indicator color |
| `circleSize` | `20` | Indicator circle size |
| `refreshThreshold` | `0.25` | Refresh trigger progress threshold (0–1) |
| `refreshTexts` | `['Pull down to refresh', 'Release to refresh', 'Refreshing...', 'Refreshed successfully']` | Per-state hint texts |
| `refreshTextStyle` | `TextStyle(fontSize: 14, fontWeight: bold, color: color)` | Hint text style |

### MiuixPullToRefreshController

Pull-to-refresh controller, extending `ChangeNotifier`. Holds the pull distance, progress and refresh visual state. `refreshThreshold` is the fraction of the full damped drag range that triggers a refresh, clamped to 0–1; the refresh business state is still hoisted by `MiuixPullToRefresh.isRefreshing`.

| Param | Type | Default | Description |
|---|---|---|---|
| `refreshThreshold` | `double` | `MiuixPullToRefreshDefaults.refreshThreshold` (0.25) | Trigger threshold, range 0–1 |

| Method / Field | Type | Description |
|---|---|---|
| `refreshState` | `MiuixRefreshState` (getter) | Current refresh visual state |
| `dragOffset` | `double` (getter) | Current damped pull distance (logical pixels) |
| `pullProgress` | `double` (getter) | Progress relative to the effective threshold |
| `fullDragProgress` | `double` (getter) | Progress relative to the full damped drag range |
| `visualProgress` | `double` (getter) | Indicator scale progress from zero to full size |
| `refreshThreshold` | `double` (getter/setter) | Trigger threshold; setter recomputes internal parameters |

### MiuixPullToRefresh

A Miuix-style pull-to-refresh container. `child` should contain a vertical scrollable; the refresh state is hoisted by the caller via `isRefreshing`.

| Param | Type | Default | Description |
|---|---|---|---|
| `isRefreshing` | `bool` | required | Refresh state hoisted by the caller |
| `onRefresh` | `VoidCallback` | required | Called after releasing past the threshold; set `isRefreshing` to true ASAP |
| `child` | `Widget` | required | Content (containing a vertical scrollable) |
| `controller` | `MiuixPullToRefreshController?` | `null` | Pull state controller, created internally when omitted |
| `contentPadding` | `EdgeInsetsGeometry` | `EdgeInsets.zero` | Content padding |
| `topAppBarScrollBehavior` | `MiuixScrollBehavior?` | `null` | Scroll behavior linked to the top app bar |
| `color` | `Color` | `Color(0xFF888888)` | Indicator color |
| `circleSize` | `double` | `20` | Indicator circle size |
| `refreshTexts` | `List<String>` | `MiuixPullToRefreshDefaults.refreshTexts` | Per-state hint texts |
| `refreshTextStyle` | `TextStyle` | `MiuixPullToRefreshDefaults.refreshTextStyle` | Hint text style |
| `onPullProgress` | `ValueChanged<double>?` | `null` | Live progress over the full damped drag range |

**Example:**
```dart
MiuixPullToRefresh(
  isRefreshing: refreshing,
  onRefresh: () => setState(() => refreshing = true),
  child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: const []),
)
```

