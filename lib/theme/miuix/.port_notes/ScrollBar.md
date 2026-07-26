# 移植分析：ScrollBar

- 复杂度: high
- 预估行数: 430
- 未移植依赖(unportedDeps): 无
- 已移植依赖(portedDeps): MiuixTheme
- 计划公开 API(publicApi): MiuixVerticalScrollBar, MiuixHorizontalScrollBar, MiuixScrollBarColors, MiuixScrollBarDefaults, MiuixScrollBarAdapter
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
No blur/sensors/haptics/native popups. (1) Compose `hoverable`+`collectIsHoveredAsState` → Flutter `MouseRegion(onEnter/onExit)`; inert on touch, keep for desktop/web parity. isHighlighted = isHovered || isDragging (on mobile effectively = isDragging). (2) `snapshotFlow{adapter.scrollOffset}.drop(1)` → add a listener to ScrollPosition/ScrollController and skip the initial value; on each scroll set opacity=1 and (re)start the fade job. (3) Coroutine `animate(...tween...)` + `animateFloatAsState` → AnimationController(s) driven by TweenSequence, or TweenAnimationBuilder for the implicit width/alpha animations. (4) `Mutex`/`CoroutineStart.UNDISPATCHED` in onDragDelta → not needed; Dart is single-threaded, drop the lock and run drag math synchronously. (5) Compose `tween` default easing is FastOutSlowInEasing → use Curves.fastOutSlowIn for all three animations (NOT the MiuixMotion accel/decel curves). (6) Custom `Layout`/measure policy → wrap CustomPaint in a fixed cross-axis SizedBox (thumbWidth+endPadding*2 = 10.56) that fills the main axis; use LayoutBuilder/CustomPaint size to obtain containerSize. Typically placed in a Stack overlaying scroll content.

## 实现要点(keyNotes) — 严格按此复刻
DEFAULTS (ScrollBarDefaults, dp→logical px 1:1): ThumbWidth=3.64, EndPadding=3.46, ThumbMinLength=36, CornerRadius=UNSPECIFIED (defaults to animatedThumbWidthPx/2), FadeDelayMillis=1000, FadeDurationMillis=500, TouchTargetWidth=48, DragThumbWidth=6, ThumbAlpha=0.1, DragThumbAlpha=0.3, DragAnimationDurationMillis=150. Cross-axis size of the bar = thumbWidth + endPadding*2 = 10.56 (coerced to available). Model UNSPECIFIED via `double? cornerRadius` (null→thumbWidthPx/2).

COLORS: MiuixScrollBarColors{Color? thumbColor, Color? trackColor} (@immutable; use nullable = Kotlin Color.Unspecified). baseThumbColor = thumbColor ?? MiuixTheme.of(context).colors.onSurface. defaultAlpha = thumbColor!=null ? thumbColor.opacity : 0.1. highlightAlpha = thumbColor!=null ? thumbColor.opacity : 0.3. Final thumb paint color = baseThumbColor.withOpacity(animatedThumbAlpha * opacity). Track: only drawn if trackColor!=null, color = trackColor.withOpacity(trackColor.opacity * opacity). Defaults.scrollBarColors() returns both null. defaultColors(context) not strictly needed since onSurface is fetched at paint time.

ANIMATIONS (all Curves.fastOutSlowIn): (a) animatedThumbWidthPx: tween 150ms between DragThumbWidth(6) [highlighted] and thumbWidth(3.64). (b) animatedThumbAlpha: tween 150ms between highlightAlpha [highlighted] and defaultAlpha. (c) opacity fade: on highlight→cancel hideJob, opacity=1; on un-highlight (if opacity>0)→delay 1000ms then linear-ish animate opacity 1→0 over 500ms (tween default easing). Same fade also triggered by every scroll event. (d) displayedThumbLength: on first paint set = target; if abs(target-displayed)>=1 launch a 150ms tween to target (guard so only one active job); else snap. opacity starts at 0 (bar hidden until first scroll/hover/drag).

MEASURE: vertical → containerSize=maxHeight, bar width=(thumbWidth+endPadding*2) capped to maxWidth. horizontal → containerSize=maxWidth, bar height=(thumbWidth+endPadding*2) capped to maxHeight.

TRACK PADDING (EdgeInsets): beforeTrackPaddingPx = vertical?top:left; afterTrackPaddingPx = vertical?bottom:right; total = before+after. adapter.trackSize = (containerSize - round(total)).clamp(0, inf).

DRAW GUARD: skip if containerSize==0 || opacity<=0 || thumbSize>=trackSize (no bar when content fits). cornerRadiusPx = cornerRadius==null ? thumbWidthPx/2 : cornerRadius. Use RRect with circular radius cr.
VERTICAL: track rect topLeft=(width - thumbWidthPx - endPaddingPx, beforeTrackPaddingPx), size=(thumbWidthPx, height - totalTrackPaddingPx). thumb rect topLeft=(width - thumbWidthPx - endPaddingPx, beforeTrackPaddingPx + position), size=(thumbWidthPx, displayedThumbLength).
HORIZONTAL: track topLeft=(beforeTrackPaddingPx, height - thumbWidthPx - endPaddingPx), size=(width - totalTrackPaddingPx, thumbWidthPx). thumb topLeft=(beforeTrackPaddingPx + position, height - thumbWidthPx - endPaddingPx), size=(displayedThumbLength, thumbWidthPx). thumbOffset = beforeTrackPaddingPx + position (position from adapter math below).

SLIDERADAPTER MATH (port verbatim as plain class, doubles): contentSize=adapter.contentSize; viewportSize; maxScrollOffset=(contentSize-viewportSize).clamp(0,inf). visiblePart = contentSize==0 ? 1.0 : (viewportSize/contentSize).clamp(-inf,1.0). thumbSize = (trackSize*visiblePart).clamp(minThumbPx, inf) [minThumbPx=ThumbMinLength=36]. scrollScale: extraBar=trackSize-thumbSize, extraContent=maxScrollOffset; = extraContent==0 ? 1.0 : extraBar/extraContent. rawPosition=scrollScale*scrollOffset. position = reverseLayout ? trackSize-thumbSize-rawPosition : rawPosition. thumbPixelRange = [round(position), round(position)+round(thumbSize)) (used only for hit-test).

DRAG onDragDelta(delta): dragDelta = isVertical?delta.dy:delta.dx; maxPosition=maxScrollOffset*scrollScale; current=position; target=(current+dragDelta+unscrolledDragDistance).clamp(0,maxPosition); sliderDelta=target-current; setPosition(current+sliderDelta); unscrolledDragDistance += dragDelta - sliderDelta. setPosition(value): raw = reverseLayout ? trackSize-thumbSize-value : value; adapter.scrollTo(raw/scrollScale) → ScrollPosition.jumpTo(raw/scrollScale). onDragStarted resets unscrolledDragDistance=0.

GESTURE (RawGestureDetector or Listener within the bar's touch strip): touchTargetPx=48. On pointer down: inStrip = vertical ? localPos.dx >= width-48 : localPos.dy >= height-48; abort if not. touchPos = vertical?dy:dx; adjusted = touchPos - beforeTrackPaddingPx; abort if adjusted < range.start || > range.end (drag only when touching the thumb). Else isDragging=true, opacity=1, cancel fade, then follow drag: onDragDelta(positionChange), consume. On up/cancel: isDragging=false (fade job restarts via highlight effect).

ADAPTER PORT: replace the 3 Kotlin adapters with ONE MiuixScrollBarAdapter wrapping a ScrollController (or ScrollPosition): scrollOffset=position.pixels, viewportSize=position.viewportDimension, contentSize=position.maxScrollExtent+viewportDimension, scrollTo(x)=position.jumpTo(x.clamp(0,maxScrollExtent)). This is exactly what ScrollStateAdapter does and is uniform across ListView/GridView/SingleChildScrollView, so LazyList/LazyGrid line-averaging logic is unnecessary in Flutter. Two public widgets MiuixVerticalScrollBar/MiuixHorizontalScrollBar take (adapter/ScrollController, reverseLayout=false, trackPadding=EdgeInsets.zero, colors, thumbWidth, cornerRadius(null default), thumbMinLength, endPadding); both delegate to a private _MiuixScrollBar(isVertical:).
