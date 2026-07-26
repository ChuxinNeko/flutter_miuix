# 移植分析：TabRow

- 复杂度: high
- 预估行数: 520
- 未移植依赖(unportedDeps): 无
- 已移植依赖(portedDeps): MiuixText, MiuixSquircleBorder, addSquircleRect, SquircleDefaults, MiuixTheme, MiuixContentColor
- 计划公开 API(publicApi): MiuixTabRow, MiuixTabRowWithContour, MiuixTabRowColors, MiuixTabRowDefaults
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
Squircle corners: Kotlin uses an AGSL runtime shader (falls back to RoundedCornerShape). The already-ported MiuixSquircleBorder (cubic-bezier path, control 0.643, extension 1.1) is the accepted Flutter approximation — use it for the pill (ShapeDecoration) and the tab border. squircleBorder nuance: Kotlin insets the stroke by halfStroke and uses innerRadius = cornerRadius - halfStroke; MiuixSquircleBorder.paint strokes the outer path centered, so half the 1dp stroke bleeds outward. For 1:1 crispness the porter should draw an inset squircle border via a CustomPainter (addSquircleRect on size (w-width,h-height), radius (r-width/2), translated by width/2) rather than relying on MiuixSquircleBorder.side. overscrollEffect=null → wrap the horizontal ListView/SingleChildScrollView in a ScrollConfiguration/ScrollBehavior that removes the overscroll glow (or ClampingScrollPhysics without glow). Compose animateScrollToItem has NO fixed spec (internal fling+spring) — approximate the auto-centering scroll with scrollController.animateTo(target, duration ~250-300ms, curve MiuixMotion.standardDecelerate/Curves.easeOut); jumpTo on first settle. Semantics: Role.Tab + CollectionInfo(1 row, N cols) + per-tab CollectionItemInfo → Flutter Semantics(selected:, inMutuallyExclusiveGroup: true). Tabs have NO press ripple by default (indication defaults to null → plain selectable); use GestureDetector(onTap) / MiuixPressable feedbackType none — do not add a ripple.

## 实现要点(keyNotes) — 严格按此复刻
TWO public widgets sharing a private base: MiuixTabRow and MiuixTabRowWithContour. Build as StatefulWidget + LayoutBuilder (BoxWithConstraints → get maxWidth) + a horizontal scroll view with a ScrollController.

=== MiuixTabRowDefaults constants (dp = logical px) ===
TabRow: height 42, cornerRadius 12, minWidth 76, maxWidth 98, default itemSpacing 9.
TabRowWithContour: height 45, cornerRadius 8, minWidth 62, maxWidth 84, default itemSpacing 5.
Also (contour only): contourPadding = 5, outerCornerRadius = cornerRadius + contourPadding (=13 default). Tab horizontal padding (TabRow item only): 12. Tab border width: unselected 1dp, selected 0dp. contentAlignment default = Alignment.center. squircle extension default 1.1.

=== MiuixTabRowColors (default via MiuixTabRowDefaults.defaultColors(context)) ===
backgroundColor = colors.surface; contentColor = colors.onSurfaceVariantSummary; selectedBackgroundColor = colors.surfaceContainer; selectedContentColor = colors.onBackground. Methods: backgroundColor(selected)=selected?selectedBg:bg; contentColor(selected)=selected?selectedContent:content. tabBorder outline color = colors.outline.

=== calculateTabWidth(tabCount, minW, maxW, spacing, availableWidth) — port VERBATIM ===
if tabCount==0 → return minW. totalSpacing = tabCount>1 ? (tabCount-1)*spacing : 0. contentWidth = availableWidth - totalSpacing. if contentWidth<=0 → minW. else idealWidth = contentWidth/tabCount; if idealWidth<minW → minW; else if idealWidth>maxW → { totalMaxWidth = maxW*tabCount + totalSpacing; if totalMaxWidth<availableWidth → idealWidth else maxW } (note: the else-branch is effectively dead — when ideal>max the condition is always true, so tabs fill available width and maxW is bypassed; replicate anyway); else → idealWidth. Net: tabs evenly fill available width, floored at minW; when many tabs hit minW the row scrolls. Recompute when tabs.length/minW/maxW/availableWidth/spacing change.
availableWidth for TabRow = full maxWidth. For contour = maxWidth - contourPadding*2.

=== Layout — MiuixTabRow ===
Root: width=infinity, height=height, plain RECTANGULAR background = backgroundColor(false) (surface, NO corners). Compute tabWidth via calculateTabWidth. itemPitch = tabWidth + itemSpacing. Selected pill: a Box width=tabWidth, full height, ShapeDecoration(color: backgroundColor(true), shape: MiuixSquircleBorder(cornerRadius: cornerRadius)). Pill x (screen) = round(selectedIndex*itemPitch - scrollOffset), where scrollOffset = scrollController.offset (pixels, since all items are equal width). Round offset to whole px. Tabs list: horizontal, spacing BETWEEN items = itemSpacing (no leading/trailing pad), verticalAlignment center. Each tab = _TabItem.
_TabItem (TabRow): width=tabWidth, full height, squircle border (width isSelected?0:1, color outline, radius cornerRadius, INSET by halfStroke, innerRadius=r-halfStroke), horizontal padding 12, alignment=contentAlignment, GestureDetector onTap→onTabSelected(index). Text: MiuixText(color: contentColor(isSelected), fontWeight isSelected?bold:normal, fontSize = textStyles.body1.fontSize (16), maxLines 1, ellipsis).

=== Layout — MiuixTabRowWithContour ===
Root: width=infinity, height=height, NO plain background. Outer Box: fill, ShapeDecoration(color: backgroundColor(false), shape: MiuixSquircleBorder(cornerRadius: outerCornerRadius=13)), then padding(contourPadding=5) around inner content. Inner has an ANIMATED indicator: indicatorOffset (animated double). Pill x = round(indicatorOffset - scrollOffset), width=tabWidth, full height, ShapeDecoration(backgroundColor(true), MiuixSquircleBorder(cornerRadius)). _TabItemWithContour: width=tabWidth, full height, NO border, NO horizontal padding, alignment=contentAlignment, tap→select. Text fontSize = textStyles.body2.fontSize (14), same weight/ellipsis rules.

=== Selection + scroll behavior (critical fidelity) ===
Track lastSettledSelectedTabIndex (init -1, reset when scroll controller/list changes). On selectedTabIndex change:
(1) Auto-center scroll: centerOffset = (availableWidth - tabWidth)/2 (contour: availableWidth already minus contourPadding*2); targetScroll = selectedIndex*itemPitch - centerOffset, clamp [0, maxScrollExtent]. If lastSettled<0 OR lastSettled==selectedIndex → jumpTo(target) (INSTANT, e.g. initial build). Else → animateTo(target) (see platformConcerns for spec). Then lastSettled=selectedIndex.
(2) Indicator: MiuixTabRow indicator has NO independent animation — it is pinned to selectedIndex*itemPitch and moves only as scrollOffset animates (glued to its tab). MiuixTabRowWithContour indicator animates its own position: target = selectedIndex*itemPitch; if first-settle/equal → snap; else animate with Tween duration 200ms, Curves.linear (LinearEasing). This gives the contour version a visible sliding pill while the row also scrolls.

RECOMMENDED clean Flutter structure: put the pill INSIDE the scrollable content as a Positioned/Stack behind the Row of tabs (SingleChildScrollView → SizedBox(width: totalContentWidth) → Stack[Positioned pill at itemLeft, Row of tabs]). Then the pill scrolls with content automatically and the "- scrollOffset" term is implicit — no scroll listener needed for MiuixTabRow. For MiuixTabRowWithContour, animate the pill's Positioned.left with the 200ms linear tween. Only if replicating literally: keep pill outside scroll and subtract scrollController.offset via a listener/AnimatedBuilder. Either yields identical visuals.

No enums. No popup/overlay infra. Fully standalone among the unported set — orderable first.
