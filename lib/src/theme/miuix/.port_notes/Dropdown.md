# 移植分析：Dropdown

- 复杂度: medium
- 预估行数: 310
- 未移植依赖(unportedDeps): 无
- 已移植依赖(portedDeps): MiuixText, MiuixTheme, MiuixContentColor
- 计划公开 API(publicApi): MiuixDropdownItem (data class, was DropdownItem), MiuixDropdownEntry (data class, was DropdownEntry), MiuixDropdownColors (@immutable colors class), MiuixDropdownDefaults (defaults class: static consts + dropdownColors(context) + dialogDropdownColors(context)), MiuixDropdownImpl (the item-row renderer widget, was DropdownImpl) — plus a text-only convenience factory/ctor mirroring the second overload, MiuixDropdownArrowEndAction (trailing up/down arrow action widget, was RowScope.DropdownArrowEndAction)
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
No native concerns in this file. No blur, no sensors, no haptics, no platform popups (the popup/overlay/blur lives in the separate ListPopup/MiuixPopupUtils files, not here). The only Compose-specific bits are: (1) ImageVector icons rendered via Image+ColorFilter — replicate 1:1 with CustomPainter using the exact path data (evenOdd fill, single solid color); no blend-mode logic needed since the source vectors are solid-black fills tinted with SrcIn, equivalent to filling the path with the target color. (2) Compose `Modifier.selectable` accessibility roles (Role.RadioButton for leaf rows, Role.Button for submenu triggers) → Flutter Semantics(selected:, inMutuallyExclusiveGroup: for radio / button: for submenu). (3) `drawBehind{drawRect}` background → plain rectangular ColoredBox/DecoratedBox (no corner rounding at this layer).

## 实现要点(keyNotes) — 严格按此复刻
SCOPE: This file (Dropdown.kt) contains ONLY the option-row renderer + data models + colors/defaults. It does NOT contain the popup trigger, the popup container, submenu cascading, or any overlay logic — those live in separate files (ListPopup / SuperDropdown / MiuixPopupUtils, to be ported later). So this port has ZERO unported-component deps and can be built immediately. `children`/`onClick`/`hasSubmenu` are just data fields consumed by the future cascading layer; here `hasSubmenu` only switches the trailing icon (chevron vs check) and semantics role.

NO SQUIRCLE, NO ANIMATION, NO SPRING in this file. Background is a plain solid rect (Compose `drawBehind { drawRect(bg) }`) — use a ColoredBox / DecoratedBox with a rectangular (un-rounded) fill. No press feedback ripple is configured (rows draw their own bg); use GestureDetector(onTap) gated by `enabled`, NOT MiuixPressable, to match. Wrap in Semantics(selected: isSelected, button: hasSubmenu, inMutuallyExclusiveGroup/ radio: !hasSubmenu).

EXACT DEFAULTS (DropdownDefaults, all dp = logical px):
- MinHeight = 56 (dialog mode min row height)
- MinWidth = 200 (dialog mode min row width)
- CheckIconSize = 20 (trailing check drawn at 20x20)
- ArrowSize = 10 x 16 (up-down arrow in ArrowEndAction)
- ChevronSize = 10 x 16 (submenu chevron)
- IconMinSize = 26 (leading icon cell min width & height)
- MaxItemTextWidth = 216 (popup-mode max width of inner icon+text row)
- InsideHorizontalPadding = 20 (row horizontal padding, popup mode)
- DialogHorizontalPadding = 28 (row horizontal padding, dialog mode)
- FirstLastVerticalPadding = 20 (top pad on first row / bottom pad on last row, popup mode only)
- MiddleVerticalPadding = 12 (top/bottom pad for middle rows in popup; ALL rows top/bottom in dialog mode)
- IconEndPadding = 12 (gap after leading icon cell)
- CheckIconStartPadding = 12 (gap before trailing check/chevron)

LAYOUT (outer Row: verticalAlignment=center, horizontalArrangement=SpaceBetween):
- Container modifier: dialog mode = ConstrainedBox(minHeight:56, minWidth:200) + fill available width + EdgeInsets.symmetric(horizontal:28); popup mode = EdgeInsets.symmetric(horizontal:20). Then add EdgeInsets.only(top: additionalTop, bottom: additionalBottom).
- additionalTop = (!dialogMode && isFirst) ? 20 : 12 ; additionalBottom = (!dialogMode && isLast) ? 20 : 12. In dialog mode both are always 12. Defaults: isFirst = index==0, isLast = index==optionSize-1.
- IMPORTANT SpaceBetween nuance: popup mode outer Row is wrap-content (no fillMaxWidth) → use MainAxisSize.min so SpaceBetween is inert and the trailing icon simply follows the text with its 12 start-padding. Dialog mode uses full width → MainAxisSize.max so the trailing icon is pushed to the trailing edge.
- Inner row (icon+text, Start arrangement, center vertical): popup mode wrap it in ConstrainedBox(maxWidth:216); dialog mode no width limit.
  - Leading icon cell (if item.icon!=null): ConstrainedBox(minWidth:26, minHeight:26) + Padding(right:12). item.icon is a caller-supplied widget (Kotlin @Composable (Modifier)->Unit → Dart Widget?).
  - Column: title Text(fontSize = textStyles.body1.fontSize, fontWeight = FontWeight.w500 (Medium), color = titleColor); if summary!=null a second Text(fontSize = textStyles.body2.fontSize, default weight, color = summaryColor). Use MiuixText.
- Trailing icon (with Padding(left:12)): if hasSubmenu → ArrowRight chevron sized 10x16; else → Check sized 20x20 (padding+size = CheckIconBaseModifier / ChevronIconBaseModifier).

COLOR LOGIC (branch order matters):
- backgroundColor = isSelected ? selectedContainerColor : containerColor.
- checkColor = !isSelected ? transparent : (!enabled ? disabledOnSecondaryVariant : selectedIndicatorColor). (unselected rows draw a fully-transparent check — keep it drawn for layout stability.)
- titleColor = !enabled ? disabledOnSecondaryVariant : (isSelected ? selectedContentColor : contentColor).
- summaryColor = !enabled ? disabledOnSecondaryVariant : (isSelected ? selectedSummaryColor : summaryColor).
- chevronColor (submenu) = !enabled ? disabledOnSecondaryVariant : (isSelected ? selectedContentColor : summaryColor).

DEFAULT COLOR SETS (all tokens exist in MiuixColors list — NO new tokens):
- dropdownColors() [popup]: contentColor=onSurfaceContainer, summaryColor=onSurfaceVariantSummary, containerColor=surfaceContainer, selectedContentColor=primary, selectedSummaryColor=primary, selectedContainerColor=surfaceContainer, selectedIndicatorColor=primary.
- dialogDropdownColors(): contentColor=onSurfaceContainer, summaryColor=onSurfaceVariantSummary, containerColor=Colors.transparent, selectedContentColor=onTertiaryContainer, selectedSummaryColor=onTertiaryContainer, selectedContainerColor=tertiaryContainer, selectedIndicatorColor=onTertiaryContainer.
Map to MiuixDropdownDefaults.dropdownColors(context)/dialogDropdownColors(context) reading MiuixTheme.of(context).colors.

ICONS — reproduce as CustomPainter (filled path, PathFillType.evenOdd, single solid color = the computed color; Compose ColorFilter.tint / BlendModeColorFilter(SrcIn) on a black-filled vector is just "fill with color"). Scale path viewport to the target box.
- Check: viewport 56x56, rendered in a 20x20 box (scale = boxSize/56). Path (evenOdd): M46.8171,18.1514 C48.0496,16.6624 47.8417,14.4561 46.3527,13.2235 C44.8636,11.991 42.6573,12.1989 41.4247,13.6879 L22.9535,36.0031 L13.4007,26.4502 C12.0338,25.0833 9.8177,25.0833 8.4509,26.4502 C7.0841,27.817 7.0841,30.0331 8.4509,31.3999 L20.7077,43.6567 C21.7243,44.6733 23.2108,44.9338 24.4682,44.4381 C25.0159,44.2302 25.5189,43.8818 25.9192,43.3982 Z (a rounded-cap checkmark).
- ArrowRight (chevron '>'): viewport 10x16, box 10x16 (scale 1). Path (evenOdd): M1.65,1.469 C1.929,1.19 2.381,1.19 2.66,1.469 L8.721,7.53 C9.0,7.809 9.0,8.261 8.721,8.54 L2.66,14.601 C2.381,14.88 1.929,14.88 1.65,14.601 C1.371,14.322 1.371,13.87 1.65,13.591 L7.205,8.035 L1.65,2.479 C1.371,2.2 1.371,1.748 1.65,1.469 Z.
- ArrowUpDown (used only by MiuixDropdownArrowEndAction; two stacked chevrons, up on top, down on bottom): viewport 10x16, box 10x16 (scale 1), evenOdd. Subpath1 (up): M2.397,4.7384 L4.5688,2.5665 L5.0075,2.1278 L5.4266,2.5469 L7.5985,4.7187 L8.531,5.6512 C8.8282,5.9485 9.3102,5.9485 9.6075,5.6512 C9.9047,5.354 9.9047,4.872 9.6075,4.5747 L8.675,3.6423 L6.5031,1.4704 L5.5706,0.5379 C5.3595,0.3267 5.0551,0.2656 4.7899,0.3544 C4.6561,0.3855 4.5291,0.4532 4.4248,0.5575 L3.4924,1.49 L1.3205,3.6619 L0.388,4.5943 C0.0907,4.8916 0.0907,5.3736 0.388,5.6708 C0.6853,5.9681 1.1672,5.9681 1.4645,5.6708 L2.397,4.7384 Z. Subpath2 (down): M2.397,11.257 L4.5688,13.4289 L5.0075,13.8675 L5.4266,13.4485 L7.5985,11.2766 L8.531,10.3441 C8.8282,10.0468 9.3102,10.0468 9.6075,10.3441 C9.9047,10.6414 9.9047,11.1233 9.6075,11.4206 L8.675,12.3531 L6.5031,14.525 L5.5706,15.4574 C5.3594,15.6686 5.0551,15.7298 4.7899,15.6409 C4.6561,15.6098 4.5291,15.5421 4.4248,15.4378 L3.4924,14.5053 L1.3205,12.3335 L0.388,11.401 C0.0907,11.1037 0.0907,10.6217 0.388,10.3245 C0.6853,10.0272 1.1672,10.0272 1.4645,10.3245 L2.397,11.257 Z. MiuixDropdownArrowEndAction sizes it 10x16 and center-vertical aligns; color from an `actionColor` param.

DATA MODELS:
- MiuixDropdownItem { String text; bool enabled=true; bool selected=false; VoidCallback? onClick; Widget? icon; String? summary; List<MiuixDropdownItem>? children; }. Kotlin has a secondary ctor (icon,title,summary) for SpinnerEntry compat → mirror with a named factory or default params (title→text ?? '').
- MiuixDropdownEntry { List<MiuixDropdownItem> items; bool enabled=true; } (group; enabled=false disables all items).
- MiuixDropdownColors: 7 final Color fields (contentColor, summaryColor, containerColor, selectedContentColor, selectedSummaryColor, selectedContainerColor, selectedIndicatorColor), @immutable const ctor.

DEPRECATED (do NOT port, or add thin aliases only if trivial): SpinnerItemImpl, SpinnerDefaults, typealias SpinnerColors=DropdownColors, typealias SpinnerEntry=DropdownItem. Recommend omitting — no runtime cost, keeps port clean.

The `Text` calls resolve to miuix basic Text (same package) → MiuixText. body1/body2 fontSize come from MiuixTheme.of(context).textStyles.
