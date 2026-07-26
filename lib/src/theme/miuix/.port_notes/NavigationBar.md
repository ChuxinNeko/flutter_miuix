# 移植分析：NavigationBar

- 复杂度: high
- 预估行数: 540
- 未移植依赖(unportedDeps): Badge, FloatingToolbar
- 已移植依赖(portedDeps): MiuixHorizontalDivider (miuix_divider.dart), MiuixText, MiuixSquircleBorder (miuix_squircle.dart), MiuixTheme, MiuixContentColor (optional, for icon tint)
- 计划公开 API(publicApi): MiuixNavigationBar, MiuixNavigationBarItem, MiuixFloatingNavigationBar, MiuixFloatingNavigationBarItem, MiuixNavigationBarDefaults, MiuixFloatingNavigationBarDefaults, MiuixNavigationBarDisplayMode (enum: iconAndText, iconOnly, iconWithSelectedLabel), MiuixNavigationItem (data class: label, icon)
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
Three native/platform items. (1) WindowInsets.captionBar (Android desktop/freeform window caption) — NO direct Flutter API; on mobile it is always 0, so the animatedCaptionBarHeight branch (300ms tween) is effectively a no-op. Treat caption bar bottom as 0 and note it. (2) WindowInsets.navigationBars bottom inset → MediaQuery.of(context).viewPadding.bottom (or padding.bottom); this is the system nav-bar / gesture-bar inset. (3) platform()==IOS check → import 'package:flutter/foundation.dart' and test defaultTargetPlatform == TargetPlatform.iOS. iOS branches: standard bar uses fixed 20 logical px instead of the nav-bar inset; FloatingNavigationBar uses fixed bottom padding 36. Also: Compose dropShadow (blur radius 10, black, alpha 0.2, no offset, no spread) → Flutter BoxShadow(color: Colors.black.withValues(alpha:0.2), blurRadius:10) on a rounded/squircle container; shadowElevation only GATES the shadow (>0), it does NOT scale blur. graphicsLayer{alpha=textAlpha} → Opacity/AnimatedOpacity. selectable(role=Role.Tab, indication=null) → Semantics(selected:, button:) + gesture WITHOUT ripple.

## 实现要点(keyNotes) — 严格按此复刻
This file ports to FIVE public pieces + 2 defaults + enum + data class. There is NO spring animation anywhere — every animation is Compose tween(durationMillis=300); Compose tween's default easing is FastOutSlowInEasing, so use Duration(milliseconds:300) + Curves.fastOutSlowIn (NOT linear) for all three animations (captionBar height, iconTopPadding, textAlpha).

PRESS FEEDBACK: items do NOT use MiuixPressable sink/tilt. Press changes the icon+label TINT ALPHA. Implement each item as a StatefulWidget with GestureDetector(onTapDown/onTapUp/onTapCancel, behavior: opaque) tracking a _pressed bool and rebuilding. No ripple/indication.

TINT LOGIC (both item types), base color = colorScheme.onSurfaceContainer:
- pressed && selected -> alpha 0.5 (SelectedPressedAlpha)
- pressed && !selected -> alpha 0.6 (UnselectedPressedAlpha)
- selected -> full opacity (alpha 1.0)
- else -> alpha 0.4 (UnselectedAlpha)
FloatingNavigationBar item uses the SAME numeric alphas (0.5/0.6/0.4). Label fontWeight = selected? Bold : Normal.

NavigationBarDefaults (all logical px): ItemHeight=64, IconSize=26, LabelFontSize=12, IconTopPadding=8, BottomPadding=8, SelectedPressedAlpha=0.5, UnselectedPressedAlpha=0.6, UnselectedAlpha=0.4.
FloatingNavigationBarDefaults: HorizontalOutSidePadding=36, ShadowElevation=1, HorizontalPadding=12, ItemSpacing=12, IconSize=28, IconPadding=10, alphas 0.5/0.6/0.4.
FloatingToolbarDefaults.CornerRadius=50 (only constant borrowed from FloatingToolbar — safe to inline as 50 rather than block on that port).

STANDARD NavigationBar: Column(width=infinity, background color default=colorScheme.surface). If showDivider(default true) -> MiuixHorizontalDivider at top. Then Row (SpaceBetween + each item weight(1f) => wrap each item in Expanded), verticalAlignment center. Provide display mode down the tree (InheritedWidget for LocalNavigationBarDisplayMode, default iconAndText). If defaultWindowInsetsPadding(default true) -> bottom spacer of height = navigationBarsPadding + animatedCaptionBarHeight, where navigationBarsPadding = (iOS? 20 : MediaQuery viewPadding.bottom). Wrap that spacer in GestureDetector(onTap:(){}, behavior: opaque)/AbsorbPointer so taps on the inset area are consumed.

NavigationBarItem Column: height=64 (ItemHeight), horizontalAlignment=center. verticalArrangement = (iconAndText || iconWithSelectedLabel)? Top : Center (mainAxisAlignment.start vs center). Three modes:
- iconAndText: icon in badged box with EdgeInsets.only(top:8), Icon size 26 tinted; then label with EdgeInsets.only(bottom:8), fontSize 12, center, tint color, fontWeight.
- iconWithSelectedLabel: defaultPadding=(64-26)/2=19. iconTopPadding animates selected?8:19 (300ms fastOutSlowIn). textAlpha animates selected?1:0 (300ms). Icon wrapped in animated top Padding (Compose custom layout just adds top padding above the icon: report height = iconHeight+topPadding, place at y=topPadding). Label uses same bottom:8 padding wrapped in Opacity(textAlpha). Label is ALWAYS in the tree (just faded), so item height is stable.
- iconOnly (else): icon in badged box, no padding, size 26, verticalArrangement center; semantic label = label (this branch passes contentDescription).

FLOATING NavigationBar: default color=colorScheme.surfaceContainer, cornerRadius=50, horizontalAlignment=center, outside padding=36, shadowElevation=1, showDivider=false. Outer Column(width=infinity) with EdgeInsets(left: align==start?36:0, right: align==end?36:0). Inner Row (mainAxisSize.min, wraps content, NOT weighted): children spaced by 12 (ItemSpacing) — use SizedBox(width:12) between or Row spacing. Modifier chain order matters (outer->inner): padding(bottom = bottomPaddingValue) is OUTSIDE the background (space below the pill), then defaultMinSize minHeight=52, then (if defaultWindowInsetsPadding) extra bottom padding = animatedCaptionBarHeight, then (if showDivider) a 0.75px dividerLine squircle ring: squircleBackground(dividerLine, r=50) + EdgeInsets.all(0.75) + inner squircleBackground(color) => a 0.75px outline of colorScheme.dividerLine around the fill; then (if shadowElevation>0) dropShadow blurRadius 10 black@0.2; then squircleBackground(color, r=50) fill; then user modifier; then EdgeInsets horizontal=12 (HorizontalPadding); Align(horizontalAlignment). Consume taps on the Row (GestureDetector opaque). bottomPaddingValue = iOS?36 : (navBarInset!=0 ? 26+navBarInset : 36).
Build the pill with ShapeDecoration(color:, shape: MiuixSquircleBorder(cornerRadius:50, enabled:true)) + a BoxShadow; the divider ring is a slightly larger squircle behind, inset 0.75.

FloatingNavigationBarItem Column: horizontalAlignment center, icon in badged box with EdgeInsets.all(10) (IconPadding vertical+horizontal), Icon size 28 tinted, semantic label=label. NO visible text label (label only used as accessibility description).

ICONS: Kotlin passes ImageVector rendered via Image + ColorFilter.tint(tint). In Flutter accept `IconData icon` and render Icon(icon, size: 26/28, color: tint), OR accept a Widget and wrap with MiuixContentColor(color: tint). Not a hard dep on the unported MiuixIcon.

BADGE: the optional `badge` param anchors to the icon's top-end corner via Badge.kt's BadgedBox + Modifier.badgeBounds() (rulers clamp the badge inside the item bounds). This is the real unported dependency — port Badge first (it supplies BadgedBox, Badge, badgeBounds, BadgeDefaults). BadgedBox geometry to replicate: size = anchor size; hasContent = badgeWidth > 6 (BadgeDefaults.Size); offsets: hasContent -> (h:12, v:14) else (6,6); badgeX = min(anchorW - hOffset, itemW - badgeW); badgeY = max(-badgeH + vOffset, 0). In Flutter this is a Stack with the anchor + a Positioned badge clamped to item bounds. Since badge is nullable/optional, an item without a badge is just the plain icon (no Stack). Colors used: surface, surfaceContainer, onSurfaceContainer, dividerLine — all exist in MiuixColors; no new tokens. Label uses MiuixText default (textStyles.main) with fontSize 12 override — no new text styles.
