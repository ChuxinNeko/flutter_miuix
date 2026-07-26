# 移植分析：ListPopup

- 复杂度: very-high
- 预估行数: 560
- 未移植依赖(unportedDeps): MiuixPopupUtils
- 已移植依赖(portedDeps): addSquircleRect, MiuixSquircleBorder, SinOutEasing, MiuixTheme
- 计划公开 API(publicApi): MiuixListPopupColumn (widget), MiuixPopupPositionProvider (abstract interface), MiuixPopupAlign (enum: start,end,topStart,topEnd,bottomStart,bottomEnd), MiuixListPopupDefaults (class: static specs + dropdownPositionProvider() + contextMenuPositionProvider + minWidth + minPopupHeight), MiuixPopupLayoutPosition (@immutable data class: showBelow,showAbove,isRightAligned), MiuixListPopupLayoutInfo (@immutable data class), computeListPopupLayoutInfo() (replaces rememberListPopupLayoutInfo), MiuixListPopupContent (widget), safeTransformOrigin() (internal helper)
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
Window insets: windowBounds is derived from displayCutout / statusBars / navigationBars / captionBar WindowInsets. Flutter equivalent: MediaQueryData — status-bar top = padding.top, nav-bar bottom = padding.bottom, cutout left/right = viewPadding.left/right (or displayFeatures for notch). captionBar is a desktop/ChromeOS window titlebar inset — treat as 0 on mobile. containerSize (LocalWindowInfo.containerSize) = MediaQuery.size (full window). Compute these in computeListPopupLayoutInfo(BuildContext).

isSquircleEnabled(): source = LocalSquircleEnabled && isRuntimeShaderSupported() (skia runtime-shader gate). The ported Dart squircle is pure-path (no shader), so it is effectively ALWAYS on — pass enabled:true to addSquircleRect in popupClipReveal (matching the conventions' MiuixSquircleBorder(enabled: cornerRadius>0) stance). No shader/runtime-support branch needed.

graphicsLayer (scale + alpha + transformOrigin as a draw-time layer that does NOT affect layout) → Transform.scale(alignment:) + Opacity; both are draw-only in Flutter so layout/size reporting stays natural, matching Compose semantics.

Custom intrinsic-driven measurement (ListPopupColumn measures widest child's maxIntrinsicWidth then lays all at that fixed width) has no direct standard-widget analog — needs a custom MultiChildRenderObjectWidget/RenderBox. CustomMultiChildLayout is insufficient because it cannot query child intrinsics.

Predictive-back gesture (NavigationBackHandler/backProgress) is in the mounting layer, not this file; Flutter closest is PopScope + a predictive-back progress listener, but it is out of scope for this primitives file.

verticalScroll(scrollState) → SingleChildScrollView + ScrollController.

## 实现要点(keyNotes) — 严格按此复刻
SCOPE: This file is the ListPopup PRIMITIVES layer only (auto-width column, position math, layout-info, scaling/clip content container). It has NO dependency on any not-yet-ported component and depends only on already-ported infra (squircle, SinOutEasing, MiuixTheme). The public dropdown/context-menu widget that actually MOUNTS the popup lives in separate files (layout/ListPopupLayout.kt + overlay/window/) and needs overlay/dialog infra (see unportedDeps=MiuixPopupUtils). Port this file first; the mounting layer is companion work.

=== ListPopupColumn (auto-width column) ===
Constants: MAX_ITEMS_FOR_WIDTH=8, MAX_ITEMS_FOR_HEIGHT=8, minPx=200dp, maxPx=288dp. Custom measure: width = widest maxIntrinsicWidth over FIRST 8 children, clamped into [lower,upper] where upper=max(288,parentMin).coerceAtMost(parentMax), lower=max(200,parentMin).coerceAtMost(upper). All children then measured at that FIXED width (tight) and stacked vertically (sum of heights). minIntrinsicHeight uses maxIntrinsicWidth(inf) clamped simply to [200,288], then sums minIntrinsicHeight of first 8 children at that width. Modifier chain: focusGroup + height(IntrinsicSize.Min) + verticalScroll. Flutter: this needs a custom MultiChildRenderObjectWidget + RenderBox (CustomMultiChildLayout cannot drive off child intrinsics) that reads children getMaxIntrinsicWidth, clamps, lays out at fixed width, stacks; wrap in SingleChildScrollView for verticalScroll. The outer maxHeight bound comes from the mounting layer.

=== ListPopupDefaults animation specs (VERBATIM) ===
FractionAnimationSpec = spring(dampingRatio=0.82, stiffness=362.5, visibilityThreshold=0.0001) — drives scale/clip-reveal 0→1.
ResetAnimationSpec = identical spring (0.82/362.5/0.0001) — settles after back gesture.
AlphaEnterAnimationSpec = tween(200ms) ; AlphaExitAnimationSpec = tween(150ms). Compose tween default easing is FastOutSlowInEasing → Flutter Curves.fastOutSlowIn.
DimEnterAnimationSpec = tween(300ms, SinOutEasing) ; DimExitAnimationSpec = tween(150ms, SinOutEasing). Use ported SinOutEasing.
MinWidth=200dp, MinPopupHeight=50dp.
SPRING CONVERSION: do NOT use folmeSpring (response-based). Use SpringDescription.withDampingRatio(mass:1.0, stiffness:362.5, ratio:0.82) — Compose spring mass defaults to 1.0, so this is exact. visibilityThreshold 0.0001 → simulation Tolerance(distance:1e-4, velocity:1e-4). Drive with AnimationController.unbounded(vsync)..animateWith(SpringSimulation(...)).

=== Position providers ===
dropdownPositionProvider(verticalMargin=8dp, horizontalMargin=0dp): margins = EdgeInsets.symmetric(h:horizontalMargin, v:verticalMargin). offsetX = (align==End) ? anchor.right - popupW - margin.right : anchor.left + margin.left. offsetY: if (window.bottom-anchor.bottom > popupH) below→anchor.bottom+margin.bottom; elif (anchor.top-window.top > popupH) above→anchor.top-popupH-margin.top; else middle→anchor.top+anchor.height/2-popupH/2. Then clamp x into [window.left, (window.right-popupW-margin.right).atLeast(window.left)] and y into [(window.top+margin.top).atMost(window.bottom-popupH-margin.bottom), window.bottom-popupH-margin.bottom].
DropdownPositionProvider = dropdownPositionProvider() singleton.
ContextMenuPositionProvider (margins 0): TopStart→(anchor.left+m.left, anchor.bottom+m.top); TopEnd→(anchor.right-popupW-m.right, anchor.bottom+m.top); BottomStart→(anchor.left+m.left, anchor.top-popupH-m.bottom); BottomEnd→(anchor.right-popupW-m.right, anchor.top-popupH-m.bottom); Start/End fallback = same below/above/middle logic as dropdown. Same final clamps.
RTL: Align.resolve(dir) flips Start<->End, TopStart<->TopEnd, BottomStart<->BottomEnd when dir==RTL. Mobile app is LTR-only but keep the flip for 1:1.

=== Layout info (rememberListPopupLayoutInfo) ===
windowBounds = Rect(left=displayCutout.left, top=statusBars.top, right=containerW-displayCutout.right, bottom=containerH-navBar.bottom-captionBar.bottom). popupMargin = insets from provider.getMargins() rounded to px. predictedTransformOrigin (used before content measured): xInWindow = End/TopEnd/BottomEnd ? parent.right-margin.right : parent.left+margin.left ; yInWindow = Bottom* ? parent.top-margin.bottom : parent.bottom+margin.bottom ; origin = safeTransformOrigin(x/containerW, y/containerH). After measure: popupLayoutPosition computed from calculatedOffset — popupCenterY=offset.y+popupH/2, anchorCenterY=parent.top+parent.h/2; showBelow=popupCenterY>anchorCenterY, showAbove=popupCenterY<anchorCenterY; isRightAligned = |(offset.x+popupW)-parent.right| < |offset.x-parent.left|. effectiveTransformOrigin: cornerX = isRightAligned ? offset.x+popupW : offset.x ; cornerY = middle ? offset.y+popupH/2 : below ? offset.y : above ? offset.y+popupH : offset.y ; origin=(cornerX/containerW, cornerY/containerH). localTransformOrigin (used by content scale): pivotX = isRightAligned?1:0, pivotY = middle?0.5 : below?0 : above?1 : 0. safeTransformOrigin clamps NaN/negative → 0.

=== ListPopupContent (the visual container — CORE port target) ===
cornerRadius=16dp. backgroundColor = colorScheme.surfaceContainer. Modifier ORDER (matters): graphicsLayer{ scale=0.15+0.85*fraction; scaleX=scaleY=scale; alpha=alphaProgress(); transformOrigin=localTransformOrigin } → user modifier → onGloballyPositioned(report size) → popupClipReveal → background(surfaceContainer). Flutter mapping: Transform.scale(scale, alignment: Alignment(localOrigin.x*2-1, localOrigin.y*2-1) i.e. isRightAligned?1:-1 for x, middle?0/below?-1/above?1 for y) wrapping Opacity(alpha) wrapping ClipPath(reveal clipper) wrapping ColoredBox(surfaceContainer) wrapping content. IMPORTANT: report the NATURAL (unscaled) content size — Transform.scale is draw-only and does not affect layout, so measure the child via a RenderObject size-reporting widget placed between the transform and the clip (matching onGloballyPositioned semantics). fractionProgress and alphaProgress are passed as callbacks () => value*(1-backProgress) by the mounting layer.

=== popupClipReveal (directional clip-reveal) ===
progress = fraction.clamp(0,1); if <=0 draw nothing. visibleHeight = height*progress. clipStart = showBelow?0 : showAbove?height*(1-progress) : height*(0.5-0.5*progress). Build squircle path via addSquircleRect(width, visibleHeight, cornerRadius, enabled). If clipStart==0: clip at top and draw content. Else: translate canvas down by clipStart, clip to the band, translate content back up by clipStart before drawing (band moves but content stays anchored). Reveal grows from top when below, from bottom when above, from center outward when middle. Flutter: implement as a custom CustomClipper<Path>+ClipPath driven by an Animation, OR a CustomPainter that saves layer, clips, paints child — but since it must clip a live child widget, use ClipPath with an animated CustomClipper returning the squircle band at the correct offset (getClip returns path shifted by clipStart). Because the child must be drawn un-shifted while the clip is shifted, the clip path itself should be positioned at [0, clipStart, width, clipStart+visibleHeight] as a squircle rect (equivalent to translate+clip+translate-back).

=== Enter/exit orchestration (lives in mounting layer, but explains the callbacks) ===
Enter: internalVisible=true; backProgress.snap(0); launch fraction→1(spring), alpha→1(tween200), dim→1(tween300 sinOut). Exit: fraction→0(spring), dim→0(tween150 sinOut); alpha→0(tween150) is the MASTER timing — when alpha finishes, snap fraction/alpha/dim/back to 0, unmount, invoke onDismissFinished. Dim layer alpha = dimProgress*(1-backProgress) over colorScheme.windowDimming (windowDimming token IS in the list). Content fraction/alpha both multiplied by (1-backProgress) for predictive-back shrink.

Colors used: only surfaceContainer here (in-list). windowDimming used by the dim layer in the mounting file (also in-list). No text styles in this file.
