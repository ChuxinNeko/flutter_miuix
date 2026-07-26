# 移植分析：ProgressIndicator

- 复杂度: medium
- 预估行数: 330
- 未移植依赖(unportedDeps): 无
- 已移植依赖(portedDeps): MiuixTheme
- portedDepsNote: Only uses MiuixTheme.of(context).colors for default colors. No MiuixText/Surface/Pressable/Squircle/Icon needed. No text styles. Pure CustomPainter + AnimationController work.
- 计划公开 API(publicApi): MiuixLinearProgressIndicator, MiuixCircularProgressIndicator, MiuixInfiniteProgressIndicator, MiuixProgressIndicatorColors, MiuixProgressIndicatorDefaults
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
None material. Everything is pure Canvas drawing + Tween/keyframe animation — no blur, sensors, haptics, or platform popups. Two exact-fidelity gotchas: (1) Flutter's Canvas.drawArc takes angles in RADIANS (0 = 3 o'clock, positive = clockwise, same convention as Compose which uses DEGREES) — so every Compose degree value must be multiplied by pi/180. (2) Compose Color.Gray == const Color(0xFF888888); do NOT map InfiniteProgressIndicator's default `color` to Flutter's Colors.grey (0xFF9E9E9E) — hardcode const Color(0xFF888888). Accessibility: Compose sets progressBarRangeInfo semantics; wrap each CustomPaint in a Semantics(value/label) widget to preserve it (visual fidelity unaffected either way).

## 实现要点(keyNotes) — 严格按此复刻
THREE independent widgets + colors + defaults, all in one file components/miuix_progress_indicator.dart. No unported deps.

=== DEFAULTS (MiuixProgressIndicatorDefaults, private ctor) ===
static const double defaultLinearHeight = 6;
static const double defaultCircularStrokeWidth = 4;
static const double defaultCircularSize = 30;
static const double defaultInfiniteStrokeWidth = 2;
static const double defaultInfiniteOrbitingDotSize = 2;
static const double defaultInfiniteSize = 20;
static MiuixProgressIndicatorColors defaultColors(BuildContext context): foreground=colors.primary, disabledForeground=colors.disabledPrimarySlider, background=colors.secondaryContainer.

=== MiuixProgressIndicatorColors (@immutable, const, final fields) ===
foregroundColor, disabledForegroundColor, backgroundColor. Method foreground(bool enabled) => enabled ? foregroundColor : disabledForegroundColor; background() => backgroundColor. All three indicators call foreground(true) and background() (always enabled path in source).

=== MiuixLinearProgressIndicator ===
Params: modifier(n/a), progress (double? null=indeterminate), colors, height (default 6). Layout: full width (double.infinity / expand horizontally) x height. CustomPaint fills width.
DETERMINATE (progress != null): p = progress.clamp(0,1). cornerRadius = height/2. Paint background: RRect of full (w,h) with Radius.circular(cornerRadius), fill color=background. minWidth = cornerRadius*2 (== height). progressWidth = minWidth + (w - minWidth) * p. Paint foreground: RRect(0,0,progressWidth,height) same radius, fill=foreground. NOTE even at p=0 a pill of width==height shows.
INDETERMINATE (progress == null): AnimationController(duration 1250ms)..repeat(), LINEAR (use controller.value directly, no curve — Compose uses LinearEasing tween 0f->1f Restart). Paint background RRect full size radius=height/2. Then loop i in 0..2 calling drawSegment(t=controller.value, i, foreground):
  drawSegment: position = t - i*(0.45+0.55)  [i.e. t - i*1.0]; adjustedPos = ((position % 1) + 1) % 1; cornerRadius = height/2 (Radius.circular).
    if (adjustedPos < 1 - 0.45 == 0.55): draw RRect at (w*adjustedPos, 0) size (w*0.45, height).
    else: draw RRect at (w*adjustedPos,0) size (w*(1-adjustedPos), height); remainingWidth = adjustedPos+0.45-1; if remainingWidth>0 draw RRect at (0,0) size (w*remainingWidth, height).
  IMPORTANT fidelity note: since the per-segment offset (0.45+0.55) is exactly 1.0, all 3 segments compute the SAME adjustedPos and draw on top of each other — visually one 45%-wide pill sliding left→right wrapping around. Replicate the loop and formula EXACTLY (keep the 0.45+0.55 literal, keep the 3-iteration loop) rather than "simplifying" to one draw.

=== MiuixCircularProgressIndicator ===
Params: progress(double? null=indeterminate), colors, strokeWidth (default 4), size (default 30). Box size x size. strokeWidthPx=strokeWidth; radius=(size - strokeWidth)/2; center=(size/2,size/2). Arc rect = Rect.fromLTWH(strokeWidth/2, strokeWidth/2, 2*radius, 2*radius).
Background ring: drawCircle(center, radius, Paint..style=stroke..strokeWidth=strokeWidthPx..color=background) — default butt cap (full circle, cap irrelevant).
DETERMINATE: p=clamp(0,1). minSweep=0.1(deg). sweepDeg = 0.1 + (360-0.1)*p. drawArc(rect, startAngle=(-90)*pi/180, sweep=sweepDeg*pi/180, useCenter=false, Paint..stroke..strokeWidth=strokeWidthPx..strokeCap=StrokeCap.round..color=foreground). Start at top (-90deg).
INDETERMINATE: TWO animations (different periods → use TickerProviderStateMixin with two controllers, or one 4000ms lcm — simplest: two controllers).
  rotationAnim: 0->360 over 1000ms, LINEAR, repeat (controller.value*360).
  sweepAnim: keyframes over 1600ms Restart: value 30 at 0ms, 120 at 800ms (LinearEasing), 30 at 1600ms (LinearEasing). Implement with a 1600ms AnimationController..repeat() driving TweenSequence<double>([item Tween(30->120) weight 1, item Tween(120->30) weight 1]) (equal 800ms halves, linear). initial/target 30/120 in source are overridden by keyframes — the actual path is 30→120→30.
  drawArc(rect, startAngle=rotationDeg*pi/180, sweep=sweepDeg*pi/180, useCenter=false, stroke round cap, foreground).

=== MiuixInfiniteProgressIndicator ===
Params: color (default const Color(0xFF888888) — Compose Color.Gray, NOT Colors.grey), size(default 20), strokeWidth(default 2), orbitingDotSize(default 2). Box size x size. Always animated (no determinate mode).
  rotation: 0->360 over 800ms LINEAR repeat.
  strokeWidthPx=strokeWidth; orbitingDotSizePx=orbitingDotSize; center=(w/2,h/2); radius=(size - strokeWidth)/2.
  Draw ring: drawCircle(center, radius, Paint..stroke..strokeWidth=strokeWidthPx..strokeCap=round..color) — full circle.
  orbitRadius = radius - 2*orbitingDotSizePx. angle = rotation(deg)*pi/180. dotCenter = center + Offset(orbitRadius*cos(angle), orbitRadius*sin(angle)). drawCircle(dotCenter, radius=orbitingDotSizePx, Paint..fill..color) — filled dot orbiting.

=== IMPL STRUCTURE ===
Linear & Circular: StatefulWidget when indeterminate (needs controller(s)); can be one widget that lazily creates controller(s) only when progress==null, disposing when switching to determinate — or simplest: always StatefulWidget, create controllers in initState with repeat(), and in paint branch on progress==null. Circular needs 2 controllers (TickerProviderStateMixin). Linear needs 1 (SingleTickerProviderStateMixin). Infinite needs 1. Use CustomPaint with a painter taking the animated values + colors; drive repaint via AnimatedBuilder or passing controller as Listenable to CustomPaint(repaint:). Each painter's shouldRepaint compares animated value + colors.

All dp values are logical pixels 1:1. File header per conventions. Chinese /// docs, first line "对应 Kotlin LinearProgressIndicator/CircularProgressIndicator/InfiniteProgressIndicator".
