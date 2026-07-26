# 移植分析：Scaffold

- 复杂度: high
- 预估行数: 400
- 未移植依赖(unportedDeps): MiuixPopupUtils
- 已移植依赖(portedDeps): MiuixSurface, MiuixTheme
- 计划公开 API(publicApi): MiuixScaffold (widget), MiuixFabPosition (enum: start, center, end, endOverlay), MiuixToolbarPosition (enum: topStart, centerStart, bottomStart, topEnd, centerEnd, bottomEnd, topCenter, bottomCenter), MiuixScaffoldContentBuilder = Widget Function(EdgeInsets contentPadding) (typedef)
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
Window insets: WindowInsets.systemBars.union(displayCutout) → MediaQuery.paddingOf(context); the onConsumedWindowInsetsChanged/exclude(consumed) behavior maps to MediaQuery.padding already being reduced by ancestor SafeArea/MediaQuery.removePadding (no direct equivalent to per-layout consumed-inset callback, but the MediaQuery reduction achieves the same nested-scaffold result). SubcomposeLayout (measure bars, then subcompose body with computed padding) has no Flutter analog — closest is a custom RenderObject or CustomMultiChildLayout writing bar heights into a ValueNotifier<EdgeInsets> and rebuilding only the body via ValueListenableBuilder (one-frame settle). RTL layoutDirection → Directionality.of(context). Nested/root popup+dialog state propagation (LocalRoot*States ?: local) → InheritedWidget with maybeOf null-fallback. No blur/sensor/haptic concerns in this file.

## 实现要点(keyNotes) — 严格按此复刻
DEPENDENCY REALITY: Only hard unported dep is MiuixPopupUtils. Scaffold's default `popupHost = { MiuixPopupHost() }` and it wires 4 composition locals: LocalPopupStates, LocalDialogStates, LocalRootDialogStates, LocalRootPopupStates (defined in utils/MiuixPopupUtils.kt lines 595-598). Root-state logic: `rootDialogStates = LocalRootDialogStates.current ?: dialogStates` and `rootPopupStates = LocalRootPopupStates.current ?: popupStates` — a nested Scaffold reuses the ancestor's root state lists; a top-level Scaffold becomes the root. Port these as InheritedWidgets with a maybe-of null-check. `popupStates`/`dialogStates` are per-Scaffold `mutableStateListOf` — model as a small state object (e.g. lists held in a State). If MiuixPopupUtils isn't ported yet, the port can temporarily accept an optional `popupHost` widget defaulting to SizedBox.shrink() and stub the 4 providers, but do NOT ship that as final. OverlayDialog is only in doc comments — not a code dep. All slot params (topBar/bottomBar/fab/toolbar/snackbar) are caller-supplied builders, NOT build-order blockers.

COLORS/STYLES: containerColor default = MiuixTheme.of(context).colors.surface. Surface wrapper supplies onSurface as content color (already handled by MiuixSurface). No text styles, no new tokens.

CONSTANTS (verbatim): FabSpacing = 12.dp; FloatingToolbarSpacing = 4.dp. FabPosition values Start=0,Center=1,End=2,EndOverlay=3. ToolbarPosition values TopStart=0,CenterStart=1,BottomStart=2,TopEnd=3,CenterEnd=4,BottomEnd=5,TopCenter=6,BottomCenter=7. Default floatingActionButtonPosition = End; default floatingToolbarPosition = BottomCenter.

LAYOUT ENGINE: Kotlin uses SubcomposeLayout so it can measure topBar/bottomBar, compute a contentPadding, THEN subcompose body with that padding. Flutter has no subcompose-after-measure. Faithful approach: CustomMultiChildLayout + MultiChildLayoutDelegate is not enough alone because the body BUILDER needs bar heights at build time. Recommended: keep a `ValueNotifier<EdgeInsets> _contentPadding` (mirrors miuix's single mutable `paddingHolder` PaddingValues that updates during measure without recomposing the whole scaffold); a custom layout/RenderBox writes bar heights into it during layout; wrap the body in `ValueListenableBuilder<EdgeInsets>` so only the content rebuilds when padding changes (one-frame settle, imperceptible; typically stable after first frame). Body is measured/placed at full size (0,0) with loose constraints — it fills the whole scaffold; the CONTENT applies the padding itself (like extendBody + extendBodyBehindAppBar always true). content signature = `Widget Function(EdgeInsets contentPadding)`.

contentPadding computation: top = topBar present ? topBarHeight : insets.top; bottom = bottomBar present ? bottomBarHeight : insets.bottom; start = insets.left; end = insets.right. "present" = placeable width==0 && height==0 → empty. Insets come from contentWindowInsets.asPaddingValues.

WINDOW INSETS: default contentWindowInsets = WindowInsets.systemBars.union(WindowInsets.displayCutout) → Flutter `MediaQuery.paddingOf(context)`. topInset/leftInset/rightInset/bottomInset are read as pixels. `onConsumedWindowInsetsChanged { safeInsets = contentWindowInsets.exclude(consumed) }` → Flutter's MediaQuery.padding is already reduced by ancestor SafeArea/MediaQuery.removePadding, so reading MediaQuery.paddingOf gives the equivalent excluded value; nested scaffolds under a SafeArea naturally get reduced padding. Note this mapping in a comment.

MEASUREMENT CONSTRAINTS: snackbar, fab, floatingToolbar are each measured with looseConstraints.offset(-leftInset-rightInset, -bottomInset) (available minus horizontal insets and bottom inset). topBar, bottomBar, body, popup use full loose constraints.

PLACEMENT / DRAW ORDER (bottom→top): 1) body at (0,0); 2) topBar at (0,0); 3) snackbar; 4) bottomBar at (0, layoutHeight - bottomBarHeight); 5) floatingToolbar; 6) fab; 7) popup at (0,0) topmost. (Measurement order differs — popup is measured first — but this is the paint/Stack order.)

FAB horizontal offset (RTL-aware): Start → LTR: FabSpacing+leftInset ; RTL: layoutWidth-FabSpacing-fabWidth-rightInset. End/EndOverlay → LTR: layoutWidth-FabSpacing-fabWidth-rightInset ; RTL: FabSpacing+leftInset. Center(else) → (layoutWidth-fabWidth+leftInset-rightInset)/2.
FAB vertical: fabOffsetFromBottom = (bottomBar empty || position==EndOverlay) ? fabHeight+FabSpacing+bottomInset : bottomBarHeight+fabHeight+FabSpacing. FAB placed at (fabLeftOffset, layoutHeight-fabOffsetFromBottom). If fab empty, skip.

SNACKBAR: snackbarOffsetFromBottom = snackbarHeight==0 ? 0 : snackbarHeight + (fabOffsetFromBottom ?? (bottomBar present ? bottomBarHeight : null) ?? bottomInset). Placed at x=(layoutWidth-snackbarWidth+leftInset-rightInset)/2, y=layoutHeight-snackbarOffsetFromBottom.

FLOATING TOOLBAR: availableWidth = layoutWidth-leftInset-rightInset; availableHeight = layoutHeight-topBarHeight-topInset-bottomInset. Use position.toAlignment() to align a box of (toolbarWidth,toolbarHeight) inside (availableWidth,availableHeight) respecting layoutDirection (Alignment.align → in Flutter compute via Alignment.inscribe or manual: x = align.x fraction over free width, etc.). Final x = leftInset + alignedX; y = topBarHeight + topInset + alignedY - FloatingToolbarSpacing (note the -4.dp lift). Skip if toolbar empty.

RTL: honor Directionality.of(context) for start/end padding and FAB Start/End resolution. The Alignment.vertical/horizontal helper extensions in the file are unused by the placement path (only toAlignment is) — you can skip porting them.

FLUTTER MECHANISM: Best to implement as a dedicated RenderBox (extends RenderBox with slotted children) or a StatefulWidget wrapping a custom MultiChildRenderObjectWidget to replicate measure-then-feed-padding; a simpler CustomMultiChildLayout works if paired with the ValueNotifier+ValueListenableBuilder body-rebuild trick above. Surface wrapper → MiuixSurface(color: containerColor, child: ...). Provide FabPlacement as a private helper class (left,width,height).
