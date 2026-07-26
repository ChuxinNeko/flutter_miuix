# 移植分析：FloatingActionButton

- 复杂度: low
- 预估行数: 85
- 未移植依赖(unportedDeps): 无
- 已移植依赖(portedDeps): MiuixTheme, MiuixContentColor, MiuixPressable, MiuixSurface, folmeSpring
- 计划公开 API(publicApi): MiuixFloatingActionButton, MiuixFloatingActionButtonDefaults
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
Two approximations, no true native features. (1) Compose Surface uses graphicsLayer(shadowElevation=4.dp) which renders a real Material ambient+key elevation shadow; Flutter has no direct equivalent, so approximate with a single BoxShadow using the existing MiuixSurface formula (black@0.15, blurRadius=4, offset (0,2)) for consistency across the port. (2) CircleShape (RoundedCornerShape 50%) maps exactly to Flutter's StadiumBorder (circle for square bounds, pill for rectangular) — use ShapeBorderClipper for content clipping. The MiuixIndication press overlay (onBackground @ alpha 0.10, spring enter damping1.0/response0.2, exit damping0.95/response0.35) is reproduced via MiuixPressable's overlayColor. No blur, sensors, haptics, or platform popups involved.

## 实现要点(keyNotes) — 严格按此复刻
FloatingActionButton.kt is a tiny wrapper: it calls the clickable Surface overload with shape=CircleShape, color=containerColor, shadowElevation, then centers content inside a defaultMinSize(60,60) Box. NO other miuix component is used; content is caller-supplied, so unportedDeps is empty.

EXACT DEFAULTS (FloatingActionButtonDefaults):
- MinWidth = 60.dp, MinHeight = 60.dp  (these are MINIMUMS via Modifier.defaultMinSize — content may exceed them)
- ShadowElevation = 4.dp
- shape default = CircleShape (Compose CircleShape == RoundedCornerShape(50%): a perfect circle for a square, a pill/stadium for a rectangle)
- containerColor default = colorScheme.primary
- contentAlignment = Alignment.Center
- semantics role = Button

CONTENT-COLOR QUIRK (replicate exactly): the FAB does NOT pass contentColor to Surface, so it inherits Surface's default contentColor = colors.onSurface (NOT onPrimary). Propagate colors.onSurface via MiuixContentColor so a caller-supplied MiuixIcon tints to onSurface unless overridden. All tokens used (primary, onSurface, and onBackground for the press overlay) are already in the MiuixColors list, so newColorTokens/newTextStyles are empty. No text styles used.

RECOMMENDED FLUTTER IMPLEMENTATION (build directly, do NOT force squircle):
The ported MiuixSurface only exposes cornerRadius+squircle and has no press feedback, so it cannot represent a true CircleShape and cannot reproduce Surface's clickable indication. Build the FAB directly instead:
1. Expose `final ShapeBorder shape` defaulting to `const StadiumBorder()` — this is the correct Flutter equivalent of CircleShape (circle for square, pill for rect). Do NOT default to MiuixSquircleBorder.
2. Params: `onPressed` (VoidCallback), `shape` (default StadiumBorder), `containerColor` (Color?, default theme.colors.primary), `shadowElevation` (double, default 4), `minWidth` (double, default 60), `minHeight` (double, default 60), `child` (Widget). Add `enabled` (bool, default true) mapping to Surface's clickable enabled.
3. Layout: `ConstrainedBox(constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight)) → Center(child: child)` to mirror defaultMinSize + Alignment.Center. (Surface uses propagateMinConstraints=true; ConstrainedBox+Center reproduces the min-size behavior.)
4. Background + shadow: `DecoratedBox(decoration: ShapeDecoration(color: containerColor, shape: shape, shadows: shadowElevation>0 ? [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: shadowElevation, offset: Offset(0, shadowElevation*0.5))] : null))`. Reuse the EXISTING MiuixSurface shadow formula verbatim (blur=elevation=4, offset=(0,2), black@0.15) for cross-component consistency.
5. Clip content to the shape (Surface does .clip(shape)): wrap the pressable+content in `ClipPath(clipper: ShapeBorderClipper(shape))`, OR use `Container(decoration: ..., clipBehavior: Clip.antiAlias, child: ...)`. Note the shadow must render OUTSIDE the clip, so keep the ShapeDecoration/shadow layer on the outermost box and clip only the interior overlay+content.
6. Press feedback: Surface's clickable uses LocalIndication = MiuixIndication(color = colors.onBackground), an OVERLAY indication (NOT sink/tilt). Use `MiuixPressable(onPressed:, enabled:, feedbackType: MiuixPressFeedbackType.none, overlayColor: theme.colors.onBackground, child: ...)` and let MiuixPressable draw/animate the overlay. If MiuixPressable does not internally apply the alpha deltas, pass overlayColor with alpha 0.10 (PRESS_ALPHA_DELTA; hover 0.06, focus 0.08). Indication springs from MiuixIndication: press-enter folmeSpring(damping:1.0, response:0.2), press-exit folmeSpring(damping:0.95, response:0.35), hover-enter (1.0,0.6), hover-exit (0.96,0.2) — use these only if you hand-roll the overlay animation rather than relying on MiuixPressable.
7. Wrap the whole thing in Semantics(button: true).

DEFAULTS CLASS: `class MiuixFloatingActionButtonDefaults { MiuixFloatingActionButtonDefaults._(); static const double minWidth = 60; static const double minHeight = 60; static const double shadowElevation = 4; static const ShapeBorder shape = StadiumBorder(); }`.
