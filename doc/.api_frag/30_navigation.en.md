## Navigation & Scaffold

### MiuixScaffold

Miuix-style scaffold that arranges the top bar, bottom bar, floating action button, floating toolbar, snackbar, and popup layers; `content` receives the padding computed by the scaffold and applies it itself.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| topBar | Widget? | null | Top app bar, usually a MiuixTopAppBar |
| bottomBar | Widget? | null | Bottom bar, usually a MiuixNavigationBar |
| floatingActionButton | Widget? | null | Floating action button |
| floatingActionButtonPosition | MiuixFabPosition | MiuixFabPosition.end | Position of the FAB |
| floatingToolbar | Widget? | null | Floating toolbar |
| floatingToolbarPosition | MiuixToolbarPosition | MiuixToolbarPosition.bottomCenter | Position of the floating toolbar |
| snackbarHost | Widget? | null | Host for snackbars, usually a MiuixSnackbarHost |
| popupHost | Widget? | null | Host for popups and dialogs; defaults to MiuixPopupHost when null |
| containerColor | Color? | null | Background color, defaults to MiuixTheme.colors.surface; pass transparent for none |
| contentWindowInsets | EdgeInsets? | null | Window insets passed to content; falls back to MediaQuery.paddingOf(context) |
| content | MiuixScaffoldContentBuilder | required | Main body; the lambda receives the padding to apply at the content root |

**Example:**
```dart
MiuixScaffold(
  topBar: MiuixSmallTopAppBar(title: 'Home'),
  bottomBar: MiuixNavigationBar(children: [/* ... */]),
  content: (padding) => Padding(padding: padding, child: bodyList),
)
```

### MiuixScaffoldContentBuilder

Type alias for the `MiuixScaffold.content` slot. The scaffold first measures the top/bottom bars and system insets, then passes the `EdgeInsets` to be applied at the content root via this callback; the content should wrap its root with `Padding` itself.

**Signature:**

```dart
typedef MiuixScaffoldContentBuilder = Widget Function(EdgeInsets contentPadding);
```

| Parameter | Type | Description |
|---|---|---|
| `contentPadding` | `EdgeInsets` | Padding computed by the scaffold, to be applied at the content root |

### MiuixFabPosition

Position of the floating action button (FAB) within MiuixScaffold.

| Value | Description |
|---|---|
| start | Bottom start, above the bottom bar (if any) |
| center | Bottom center, above the bottom bar (if any) |
| end | Bottom end, above the bottom bar (if any) |
| endOverlay | Bottom end, overlaid on top of the bottom bar (if any) |

### MiuixToolbarPosition

Position of the floating toolbar within MiuixScaffold. Enum order is TopStart=0 ... BottomCenter=7.

| Value | Description |
|---|---|
| topStart | Top start |
| centerStart | Center start |
| bottomStart | Bottom start |
| topEnd | Top end |
| centerEnd | Center end |
| bottomEnd | Bottom end |
| topCenter | Top center |
| bottomCenter | Bottom center |

### MiuixTopAppBar

Collapsible large-title top app bar. Requires a MiuixScrollBehavior to collapse/expand; without scrollBehavior it stays statically expanded.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| title | String | required | Title text |
| color | Color? | null | Background color, defaults to MiuixTheme.colors.surface |
| titleColor | Color? | null | Collapsed small-title color |
| largeTitle | String? | null | Large title, defaults to title |
| largeTitleColor | Color? | null | Large-title color |
| subtitle | String | '' | Subtitle (shown below the large title when expanded, below the small title when collapsed) |
| subtitleColor | Color? | null | Subtitle color |
| navigationIcon | Widget? | null | Navigation (leading) icon |
| actions | List\<Widget\>? | null | Action (trailing) icons |
| scrollBehavior | MiuixScrollBehavior? | null | Scroll behavior controlling collapse/expand |
| defaultWindowInsetsPadding | bool | true | Whether to apply default window insets padding |
| titlePadding | double | MiuixTopAppBarDefaults.titlePadding (26) | Title horizontal padding |
| navigationIconPadding | double | MiuixTopAppBarDefaults.navigationIconPadding (16) | Navigation icon start padding |
| actionIconPadding | double | MiuixTopAppBarDefaults.actionIconPadding (16) | Action icon end padding |
| bottomContent | Widget? | null | Extra content below the title area |
| blurred | bool | false | Enable frosted-glass background (enhancement, not in the original). When true, the background becomes a real-time Gaussian blur of the **already-painted content behind it** plus a translucent tint ("content blurs through the bar"). Implemented with `BackdropFilter`; requires the bar to paint above the scrollable content (MiuixScaffold's topBar does). |
| blurRadius | double | 24 | Frosted-glass blur radius (dp), only when blurred=true; sigma = blurRadius × 0.45 |
| blurTintAlpha | double | 0.55 | Opacity [0,1] of the background tint over the blur, only when blurred=true. Too high hides the blur, too low lacks contrast |

**Example:**
```dart
final behavior = miuixScrollBehavior();
MiuixTopAppBar(
  title: 'Title',
  subtitle: 'Subtitle',
  scrollBehavior: behavior,
  navigationIcon: MiuixIcon(vector: MiuixIcons.basic.back),
);

// Frosted-glass bar (content blurs through)
MiuixScaffold(
  topBar: const MiuixTopAppBar(title: 'Home', blurred: true),
  content: (padding) => ListView(padding: padding, children: [/* ... */]),
);
```

### MiuixSmallTopAppBar

Static small-title top app bar. Does not collapse/expand and shows a centered title; if a scrollBehavior is passed, it locks the state's heightOffsetLimit to 0 (pinned effect).

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| title | String | required | Title text |
| color | Color? | null | Background color, defaults to MiuixTheme.colors.surface |
| titleColor | Color? | null | Title color |
| subtitle | String | '' | Subtitle (centered below the title) |
| subtitleColor | Color? | null | Subtitle color |
| navigationIcon | Widget? | null | Navigation (leading) icon |
| actions | List\<Widget\>? | null | Action (trailing) icons |
| scrollBehavior | MiuixScrollBehavior? | null | When set, locks the shared behavior to pinned |
| defaultWindowInsetsPadding | bool | true | Whether to apply default window insets padding |
| titlePadding | double | MiuixTopAppBarDefaults.titlePadding (26) | Title horizontal padding |
| navigationIconPadding | double | MiuixTopAppBarDefaults.navigationIconPadding (16) | Navigation icon start padding |
| actionIconPadding | double | MiuixTopAppBarDefaults.actionIconPadding (16) | Action icon end padding |
| bottomContent | Widget? | null | Extra content below the title area |

**Example:**
```dart
MiuixSmallTopAppBar(title: 'Settings', subtitle: 'v1.0')
```

### MiuixTopAppBarState

State for the top app bar (extends ChangeNotifier). Holds the collapse offset, content scroll offset, etc.; usually held and updated by a MiuixScrollBehavior and read by MiuixTopAppBar.

| Parameter | Type | Default | Description |
|---|---|---|---|
| initialHeightOffsetLimit | double | double.negativeInfinity | Collapse height limit (negative; max collapsible pixels) |
| initialHeightOffset | double | 0 | Initial collapse offset |
| initialContentOffset | double | 0 | Initial content scroll offset |

Key properties: `heightOffsetLimit`, `heightOffset` (clamped between the limit and 0), `contentOffset`, `collapsedFraction` (0 expanded, 1 collapsed), `overlappedFraction`.

### MiuixScrollBehavior

Scroll behavior abstraction. Exposes `state` (MiuixTopAppBarState) and `isPinned` (whether it is fixed and does not collapse on scroll).

### MiuixExitUntilCollapsedScrollBehavior

"Exit until collapsed" scroll behavior. Scrolling up collapses the top app bar first, then scrolls the content below; scrolling down expands the top app bar first. Implements MiuixScrollBehavior; `isPinned` is always false.

| Parameter | Type | Default | Description |
|---|---|---|---|
| state | MiuixTopAppBarState? | new MiuixTopAppBarState() if omitted | Associated state |
| canScroll | bool Function()? | null | Whether to handle scroll events |

### MiuixScrollBehaviorListener

Listener bridging scroll events to a MiuixExitUntilCollapsedScrollBehavior; wrap any scrollable to automatically handle collapse/expand and the snap animation after a gesture ends.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| behavior | MiuixExitUntilCollapsedScrollBehavior | required | Scroll behavior |
| child | Widget | required | The wrapped scrollable child |

**Example:**
```dart
final behavior = miuixScrollBehavior();
MiuixScrollBehaviorListener(
  behavior: behavior,
  child: ListView(children: [/* ... */]),
);
```

### miuixScrollBehavior

Top-level function that creates a default MiuixExitUntilCollapsedScrollBehavior.

| Parameter | Type | Default | Description |
|---|---|---|---|
| state | MiuixTopAppBarState? | null | Associated state |
| canScroll | bool Function()? | null | Whether to handle scroll events |

Returns: `MiuixExitUntilCollapsedScrollBehavior`

### MiuixTopAppBarDefaults

Top app bar defaults (private constructor, static constants only).

| Constant | Value | Description |
|---|---|---|
| titlePadding | 26 | Title horizontal padding |
| navigationIconPadding | 16 | Navigation icon start padding |
| actionIconPadding | 16 | Action icon end padding |
| collapsedHeight | 52 | Collapsed top app bar height |
| smallTopAppBarCenterHeight | 50 | SmallTopAppBar vertical center height |
| largeTitleBottomPadding | 4 | Large-title bottom padding when no subtitle |
| subtitleBottomPadding | 8 | Subtitle bottom padding |
| titleWidthFraction | 0.9 | Horizontal margin ratio between centered title and nav/actions |

### MiuixNavigationBar

Standard bottom navigation bar. children is usually 2 to 5 MiuixNavigationBarItem widgets (asserts length 2..5), each Expanded evenly.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| children | List\<Widget\> | required | Navigation items (length must be 2..5) |
| color | Color? | null | Background color; falls back to colors.background |
| colors | MiuixNavigationBarColors? | null | Color config; falls back to theme defaults |
| showDivider | bool | true | Whether to show the top divider |
| defaultWindowInsetsPadding | bool | true | Whether to add bottom system-inset padding |
| mode | MiuixNavigationBarDisplayMode | MiuixNavigationBarDisplayMode.iconAndText | Item display mode |

**Example:**
```dart
MiuixNavigationBar(
  children: [
    MiuixNavigationBarItem(selected: index == 0, onPressed: () {}, icon: icon0, label: 'Home'),
    MiuixNavigationBarItem(selected: index == 1, onPressed: () {}, icon: icon1, label: 'Me'),
  ],
)
```

### MiuixNavigationBarItem

Standard navigation item. icon and labelWidget are slots; when labelWidget is omitted, text is built from label.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| selected | bool | required | Whether selected |
| onPressed | VoidCallback? | required | Tap callback; disabled when null |
| icon | Widget | required | Icon slot |
| label | String | required | Accessibility label and default visible text |
| labelWidget | Widget? | null | Custom label widget |
| enabled | bool | true | Whether enabled |
| badge | Widget? | null | Badge slot, anchored at the top-end of the icon |

### MiuixFloatingNavigationBar

Floating bottom navigation bar. Items lay out at their own width (not evenly divided) with a fixed 12 spacing (asserts children length 2..5).

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| children | List\<Widget\> | required | Navigation items (length must be 2..5) |
| color | Color? | null | Background color; falls back to colors.floatingBackground |
| colors | MiuixNavigationBarColors? | null | Color config; falls back to theme defaults |
| cornerRadius | double | MiuixFloatingNavigationBarDefaults.cornerRadius (50) | Corner radius |
| horizontalAlignment | AlignmentGeometry | AlignmentDirectional.center | Horizontal alignment |
| horizontalOutSidePadding | double | MiuixFloatingNavigationBarDefaults.horizontalOutSidePadding (36) | Outer horizontal padding |
| shadowElevation | double | MiuixFloatingNavigationBarDefaults.shadowElevation (1) | Whether to show shadow (>0 shows; shadow fixed to black 20%, blurRadius=10) |
| showDivider | bool | false | Whether to show an outline |
| defaultWindowInsetsPadding | bool | true | Whether to apply default caption-bar inset (0 on mobile) |

**Example:**
```dart
MiuixFloatingNavigationBar(
  children: [
    MiuixFloatingNavigationBarItem(selected: true, onPressed: () {}, icon: icon0, label: 'Home'),
    MiuixFloatingNavigationBarItem(selected: false, onPressed: () {}, icon: icon1, label: 'Me'),
  ],
)
```

### MiuixFloatingNavigationBarItem

Floating navigation item.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| selected | bool | required | Whether selected |
| onPressed | VoidCallback? | required | Tap callback; disabled when null |
| icon | Widget | required | Icon slot |
| label | String | required | Accessibility label |
| enabled | bool | true | Whether enabled |
| badge | Widget? | null | Badge slot |

### MiuixNavigationItem

Navigation item data (@immutable).

| Parameter | Type | Default | Description |
|---|---|---|---|
| label | String | required | Accessibility label and default visible label text |
| icon | Widget | required | Icon slot; the component provides size and state color via IconTheme |
| badge | Widget? | null | Optional badge slot, anchored at the top-end of the icon |

### MiuixNavigationBarDisplayMode

Item display mode.

| Value | Description |
|---|---|
| iconAndText | Always show icon and text |
| iconOnly | Show icon only |
| iconWithSelectedLabel | Always show icon, show text only for the selected item |

### MiuixNavigationBarColors

Navigation bar colors, holding theme colors for both standard and floating bars (@immutable).

| Parameter | Type | Default | Description |
|---|---|---|---|
| background | Color | required | Standard bar background color |
| floatingBackground | Color | required | Floating bar background color |
| content | Color | required | Base color for icons and labels; state alpha is computed on top |
| divider | Color | required | Divider and floating-outline color |

### MiuixNavigationBarDefaults

Standard navigation bar defaults (private constructor).

| Constant | Value | Description |
|---|---|---|
| itemHeight | 64 | Item height |
| iconSize | 26 | Icon size |
| labelFontSize | 12 | Label font size |
| iconTopPadding | 8 | Icon top padding |
| bottomPadding | 8 | Bottom padding |
| selectedPressedAlpha | 0.5 | Selected + pressed alpha |
| unselectedPressedAlpha | 0.6 | Unselected + pressed alpha |
| unselectedAlpha | 0.4 | Unselected alpha |
| selectionAnimationDuration | 300ms | Selection animation duration |

Static method `defaultColors(BuildContext) → MiuixNavigationBarColors`: builds default colors from the current theme.

### MiuixFloatingNavigationBarDefaults

Floating navigation bar defaults (private constructor).

| Constant | Value | Description |
|---|---|---|
| horizontalOutSidePadding | 36 | Outer horizontal padding |
| shadowElevation | 1 | Shadow toggle |
| horizontalPadding | 12 | Inner horizontal padding |
| itemSpacing | 12 | Item spacing |
| iconSize | 28 | Icon size |
| iconPadding | 10 | Icon padding |
| selectedPressedAlpha | 0.5 | Selected + pressed alpha |
| unselectedPressedAlpha | 0.6 | Unselected + pressed alpha |
| unselectedAlpha | 0.4 | Unselected alpha |
| cornerRadius | 50 | Corner radius, matches FloatingToolbarDefaults.CornerRadius |

Static method `defaultColors(BuildContext) → MiuixNavigationBarColors`: delegates to MiuixNavigationBarDefaults.defaultColors.

### MiuixNavigationRail

Miuix navigation rail for wide screens with an optional expand controller. When state is null it uses the classic collapsed layout without a toggle button; when non-null, the rail width, item layout, selected background, and font size share one spring animation.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| children | List\<Widget\> | required | Navigation items, usually MiuixNavigationRailItem |
| state | MiuixNavigationRailState? | null | Expand/collapse state; no toggle button when null |
| header | Widget? | null | Header content at the top |
| colors | MiuixNavigationRailColors? | null | Color config; falls back to theme defaults |
| showDivider | bool | true | Whether to show the trailing divider |
| defaultWindowInsetsPadding | bool | true | Whether to apply default window insets padding |
| minWidth | double | MiuixNavigationRailDefaults.minWidth (80) | Collapsed width |
| expandedWidth | double | MiuixNavigationRailDefaults.expandedWidth (240) | Expanded width |
| expandContentDescription | String | MiuixNavigationRailDefaults.expandContentDescription ('Expand navigation rail') | A11y description for expand button |
| collapseContentDescription | String | MiuixNavigationRailDefaults.collapseContentDescription ('Collapse navigation rail') | A11y description for collapse button |
| scrollController | ScrollController? | null | Internal scroll controller |
| iconSize | double | MiuixNavigationRailDefaults.iconSize (28) | Item icon size; reducing it also lowers item height (both collapsed and expanded) |
| itemVerticalPadding | double | MiuixNavigationRailDefaults.itemVerticalPadding (12) | Collapsed-state item vertical padding |
| expandedItemVerticalPadding | double | MiuixNavigationRailDefaults.expandedItemContentVerticalPadding (14) | Expanded-state item vertical padding; reducing it directly lowers expanded item height |
| labelFontSize | double | MiuixNavigationRailDefaults.labelFontSize (12) | Collapsed-state label font size |
| expandedLabelFontSize | double | MiuixNavigationRailDefaults.expandedLabelFontSize (16) | Expanded-state label font size |

> The last 5 size parameters are enhancements; their defaults preserve the original values (non-breaking), for optionally compacting rail items.

**Example:**
```dart
final railState = MiuixNavigationRailState();
MiuixNavigationRail(
  state: railState,
  children: [
    MiuixNavigationRailItem(selected: true, onPressed: () {}, icon: icon0, label: 'Home'),
    MiuixNavigationRailItem(selected: false, onPressed: () {}, icon: icon1, label: 'Settings'),
  ],
)
```

### MiuixNavigationRailItem

Navigation rail item supporting icon, label, and an optional badge slot. The icon is decorative; the item semantics only announce label.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| selected | bool | required | Whether selected |
| onPressed | VoidCallback? | required | Tap callback; disabled when null |
| icon | Widget | required | Icon slot |
| label | String | required | Label text (announced for a11y) |
| enabled | bool | true | Whether enabled |
| badge | Widget? | null | Badge slot, anchored at the top-end of the icon |

### MiuixNavigationRailState

State object controlling expand/collapse of MiuixNavigationRail (extends ChangeNotifier). Aliased as MiuixNavigationRailController.

| Parameter | Type | Default | Description |
|---|---|---|---|
| initialValue | MiuixNavigationRailValue | MiuixNavigationRailValue.collapsed | Initial expand state |

Key members: `currentValue`, `isExpanded`, `expand()`, `collapse()`, `toggle()`.

### MiuixNavigationRailController

Type alias for MiuixNavigationRailState (`typedef MiuixNavigationRailController = MiuixNavigationRailState`).

### MiuixNavigationRailValue

Expand state enum for the navigation rail.

| Value | Description |
|---|---|
| collapsed | Collapsed |
| expanded | Expanded |

### MiuixNavigationRailColors

Navigation rail color config (@immutable).

| Parameter | Type | Default | Description |
|---|---|---|---|
| background | Color | required | Background color |
| content | Color | required | Content (icon/label) color |
| indicator | Color | required | Selected indicator color |
| divider | Color | required | Divider color |

### MiuixNavigationRailDefaults

NavigationRail defaults (private constructor).

| Constant | Value | Description |
|---|---|---|
| minWidth | 80 | Collapsed width |
| expandedWidth | 240 | Expanded width |
| verticalPadding | 24 | Vertical padding |
| headerSpacing | 24 | Header spacing |
| iconSize | 28 | Icon size |
| iconTextSpacing | 4 | Icon-to-text spacing |
| itemVerticalPadding | 12 | Item vertical padding |
| labelFontSize | 12 | Collapsed label font size |
| expandedLabelFontSize | 16 | Expanded label font size |
| expandedItemHorizontalMargin | 12 | Expanded item horizontal margin |
| expandedItemCornerRadius | 16 | Expanded item corner radius |
| collapsedIndicatorVerticalPadding | 4 | Collapsed indicator vertical padding |
| expandedItemContentHorizontalPadding | 14 | Expanded item content horizontal padding |
| expandedItemContentVerticalPadding | 14 | Expanded item content vertical padding |
| expandedItemIconTextSpacing | 16 | Expanded item icon-to-text spacing |
| expandContentDescription | 'Expand navigation rail' | Expand description |
| collapseContentDescription | 'Collapse navigation rail' | Collapse description |

Static method `colors(BuildContext) → MiuixNavigationRailColors`: builds default colors from the current theme.

### MiuixTabRow

Miuix tab row. Horizontally scrollable, with the selected tab indicated by a squircle background.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| tabs | List\<String\> | required | Tab text labels |
| selectedTabIndex | int | required | Selected tab index |
| onTabSelected | ValueChanged\<int\> | required | Selection callback |
| colors | MiuixTabRowColors? | null | Color config; falls back to theme defaults |
| minWidth | double | MiuixTabRowDefaults.tabRowMinWidth (76) | Min width per tab |
| maxWidth | double | MiuixTabRowDefaults.tabRowMaxWidth (98) | Max width per tab |
| height | double | MiuixTabRowDefaults.tabRowHeight (42) | Tab row height |
| cornerRadius | double | MiuixTabRowDefaults.tabRowCornerRadius (12) | Indicator corner radius |
| itemSpacing | double | MiuixTabRowDefaults.tabRowItemSpacing (9) | Item spacing |
| contentAlignment | AlignmentGeometry | Alignment.center | Tab content alignment |
| scrollController | ScrollController? | null | Horizontal scroll controller |

**Example:**
```dart
MiuixTabRow(
  tabs: ['All', 'Unread', 'Archived'],
  selectedTabIndex: index,
  onTabSelected: (i) => setState(() => index = i),
)
```

### MiuixTabRowWithContour

Tab row with an outer contour. Wraps the whole row in a squircle frame; the indicator has a 200ms move animation.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| tabs | List\<String\> | required | Tab text labels |
| selectedTabIndex | int | required | Selected tab index |
| onTabSelected | ValueChanged\<int\> | required | Selection callback |
| colors | MiuixTabRowColors? | null | Color config; falls back to theme defaults |
| minWidth | double | MiuixTabRowDefaults.tabRowWithContourMinWidth (62) | Min width per tab |
| maxWidth | double | MiuixTabRowDefaults.tabRowWithContourMaxWidth (84) | Max width per tab |
| height | double | MiuixTabRowDefaults.tabRowWithContourHeight (45) | Tab row height |
| cornerRadius | double | MiuixTabRowDefaults.tabRowWithContourCornerRadius (8) | Indicator corner radius |
| itemSpacing | double | MiuixTabRowDefaults.contourItemSpacing (5) | Item spacing |
| contentAlignment | AlignmentGeometry | Alignment.center | Tab content alignment |
| scrollController | ScrollController? | null | Horizontal scroll controller |

**Example:**
```dart
MiuixTabRowWithContour(
  tabs: ['Day', 'Week', 'Month'],
  selectedTabIndex: index,
  onTabSelected: (i) => setState(() => index = i),
)
```

### MiuixTabRowColors

Tab row color config (@immutable). Provides `background(bool)` and `content(bool)` helpers.

| Parameter | Type | Default | Description |
|---|---|---|---|
| backgroundColor | Color | required | Unselected background color |
| contentColor | Color | required | Unselected content color |
| selectedBackgroundColor | Color | required | Selected background color |
| selectedContentColor | Color | required | Selected content color |

### MiuixTabRowDefaults

Tab row defaults (private constructor).

| Constant | Value | Description |
|---|---|---|
| tabRowHeight | 42 | TabRow height |
| tabRowWithContourHeight | 45 | Contour variant height |
| tabRowCornerRadius | 12 | TabRow corner radius |
| tabRowWithContourCornerRadius | 8 | Contour variant corner radius |
| tabRowMinWidth | 76 | TabRow min tab width |
| tabRowWithContourMinWidth | 62 | Contour variant min tab width |
| tabRowMaxWidth | 98 | TabRow max tab width |
| tabRowWithContourMaxWidth | 84 | Contour variant max tab width |
| tabRowItemSpacing | 9 | TabRow item spacing |
| contourItemSpacing | 5 | Contour variant item spacing |
| contourPadding | 5 | Contour variant padding |
| itemHorizontalPadding | 12 | Tab horizontal padding |
| borderWidth | 1 | Border width |

Static method `defaultColors(BuildContext) → MiuixTabRowColors`: builds default colors from the current theme.

### MiuixBreadcrumbBar

Horizontal breadcrumb bar. Scrolls horizontally when content overflows; a negative highlightIndex disables both highlighting and auto-centering.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| items | List\<MiuixBreadcrumbItem\> | required | Breadcrumb segments |
| onItemClick | ValueChanged\<int\> | required | Callback when a segment is tapped |
| highlightIndex | int? | null | Highlight index; null means the last item, negative disables highlight |
| enabled | bool | true | Whether enabled |
| colors | MiuixBreadcrumbBarColors? | null | Color config; falls back to theme defaults |
| insideMargin | EdgeInsets | MiuixBreadcrumbBarDefaults.insideMargin (h:12/v:8) | Inner padding |
| itemMaxWidth | double | MiuixBreadcrumbBarDefaults.itemMaxWidth (160) | Max width per segment |
| scrollController | ScrollController? | null | Horizontal scroll controller |

**Example:**
```dart
MiuixBreadcrumbBar(
  items: [
    MiuixBreadcrumbItem(path: 'root', text: 'Root'),
    MiuixBreadcrumbItem(path: 'docs'),
  ],
  onItemClick: (i) {},
)
```

### MiuixBreadcrumbItem

A single path segment (@immutable).

| Parameter | Type | Default | Description |
|---|---|---|---|
| path | String | required | Path segment used to rebuild the full path |
| text | String? | null | Display text; shows path when null |

### MiuixBreadcrumbItemsPath

An extension on `List<MiuixBreadcrumbItem>`. Joins all path segments' `path` field with a separator, useful for rebuilding the full path.

| Method signature | Returns | Description |
|---|---|---|
| `joinToPath({String separator = '/'})` | `String` | Joins all items' `path` field with `separator` |

**Example:**
```dart
final items = [
  MiuixBreadcrumbItem(path: 'home'),
  MiuixBreadcrumbItem(path: 'docs'),
  MiuixBreadcrumbItem(path: 'api'),
];
final full = items.joinToPath(); // 'home/docs/api'
```

### MiuixBreadcrumbBarColors

Breadcrumb color config (@immutable).

| Parameter | Type | Default | Description |
|---|---|---|---|
| color | Color | required | Normal segment foreground color |
| highlightColor | Color | required | Highlighted segment foreground color |
| disabledColor | Color | required | Disabled foreground color |
| separatorColor | Color | required | Separator chevron color |
| backgroundColor | Color | required | Normal segment background color |
| highlightBackgroundColor | Color | required | Highlighted segment background color |
| disabledBackgroundColor | Color | required | Disabled background color |

### MiuixBreadcrumbBarDefaults

Breadcrumb defaults (private constructor).

| Constant | Value | Description |
|---|---|---|
| insideMargin | EdgeInsets(h:12, v:8) | Inner padding |
| itemHeight | 32 | Segment height |
| itemHorizontalPadding | 10 | Segment horizontal padding |
| itemMaxWidth | 160 | Segment max width |

Static method `defaultColors(BuildContext) → MiuixBreadcrumbBarColors`: builds default colors from the current theme.

### MiuixVerticalScrollBar

Vertical scroll bar. Supports hover/drag highlight and auto fade-out.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| adapter | MiuixScrollBarAdapter | required | Bound scroll adapter |
| reverseLayout | bool | false | Whether to reverse layout |
| trackPadding | EdgeInsets | EdgeInsets.zero | Track padding |
| colors | MiuixScrollBarColors | MiuixScrollBarDefaults.colors | Color config |
| thumbWidth | double | MiuixScrollBarDefaults.thumbWidth (3.64) | Thumb width |
| cornerRadius | double? | null | Corner radius; defaults to thumbWidth/2 when null |
| thumbMinLength | double | MiuixScrollBarDefaults.thumbMinLength (36) | Minimum thumb length |
| endPadding | double | MiuixScrollBarDefaults.endPadding (3.46) | End padding |

**Example:**
```dart
final controller = ScrollController();
Stack(children: [
  ListView(controller: controller, children: [/* ... */]),
  Positioned(right: 0, top: 0, bottom: 0,
    child: MiuixVerticalScrollBar(adapter: MiuixScrollBarAdapter(controller))),
])
```

### MiuixHorizontalScrollBar

Horizontal scroll bar. Parameters are identical to MiuixVerticalScrollBar.

| Parameter | Type | Default | Description |
|---|---|---|---|
| key | Key? | — | Widget key |
| adapter | MiuixScrollBarAdapter | required | Bound scroll adapter |
| reverseLayout | bool | false | Whether to reverse layout |
| trackPadding | EdgeInsets | EdgeInsets.zero | Track padding |
| colors | MiuixScrollBarColors | MiuixScrollBarDefaults.colors | Color config |
| thumbWidth | double | MiuixScrollBarDefaults.thumbWidth (3.64) | Thumb width |
| cornerRadius | double? | null | Corner radius; defaults to thumbWidth/2 when null |
| thumbMinLength | double | MiuixScrollBarDefaults.thumbMinLength (36) | Minimum thumb length |
| endPadding | double | MiuixScrollBarDefaults.endPadding (3.46) | End padding |

### MiuixScrollBarAdapter

Unified adapter over a Flutter ScrollController.

| Parameter | Type | Default | Description |
|---|---|---|---|
| controller | ScrollController | required (positional) | The scroll controller to adapt |

Key members: `scrollOffset`, `viewportSize`, `contentSize`, `maxScrollOffset`, `scrollTo(double)` (jump to a content offset, clamped to the valid range).

### MiuixScrollBarColors

Scroll bar colors; null means unset (@immutable).

| Parameter | Type | Default | Description |
|---|---|---|---|
| thumbColor | Color? | null | Thumb color |
| trackColor | Color? | null | Track color |

### MiuixScrollBarDefaults

Scroll bar defaults (private constructor).

| Constant | Value | Description |
|---|---|---|
| thumbWidth | 3.64 | Thumb width |
| endPadding | 3.46 | End padding |
| thumbMinLength | 36 | Minimum thumb length |
| fadeDelayMillis | 1000 | Fade delay (ms) |
| fadeDurationMillis | 500 | Fade duration (ms) |
| touchTargetWidth | 48 | Touch target width |
| dragThumbWidth | 6 | Thumb width while dragging |
| thumbAlpha | 0.1 | Default thumb alpha |
| dragThumbAlpha | 0.3 | Thumb alpha while dragging |
| dragAnimationDurationMillis | 150 | Drag highlight animation duration (ms) |
| colors | MiuixScrollBarColors() | Default colors (all null) |

Static method `defaultColors(BuildContext) → MiuixScrollBarColors`: returns the default colors.

