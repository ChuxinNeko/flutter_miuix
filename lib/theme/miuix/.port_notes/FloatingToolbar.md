# 移植分析：FloatingToolbar

- 复杂度: low
- 预估行数: 85
- 未移植依赖(unportedDeps): 无
- 已移植依赖(portedDeps): MiuixSquircleBorder, MiuixTheme
- 计划公开 API(publicApi): MiuixFloatingToolbar, MiuixFloatingToolbarDefaults
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
Kotlin renders the squircle via an AGSL/SkSL runtime shader (`squircleBackground`) with a fallback to RoundedCornerShape on API<33; Flutter side uses the already-ported path-based `MiuixSquircleBorder`, which is the established 1:1 approach in this project — no shader work needed. Compose `Modifier.dropShadow` is a soft ambient blur shadow → replicate with a single Flutter `BoxShadow(blurRadius:10, offset:Offset.zero, color: black@0.1)`; visually equivalent. `pointerInput{ detectTapGestures{} }` (tap-consume to block pass-through) → `GestureDetector(behavior: HitTestBehavior.opaque, onTap: (){})`. No blur/backdrop, sensors, haptics, or platform popups involved.

## 实现要点(keyNotes) — 严格按此复刻
SELF-CONTAINED CONTAINER — zero dependencies on any not-yet-ported component. It just wraps caller-supplied `content` (caller provides its own Row/Column; this widget has NO orientation logic despite the doc comment mentioning horizontal/vertical).

STRUCTURE (Kotlin Box modifier chain, outer→inner):
1) Padding(outSidePadding)  [default EdgeInsets.symmetric(horizontal:12, vertical:8)]
2) IF showDivider: squircleBackground(dividerLine, cornerRadius) then padding(0.75.dp)  → a 0.75dp ring of dividerLine color
3) IF shadowElevation>0: dropShadow(shape=RoundedCornerShape(cornerRadius), Shadow(radius=10.dp, color=Black, alpha=0.1f))
4) squircleBackground(color, cornerRadius)
5) pointerInput{ detectTapGestures{} }  (consume taps)
6) content()

RECOMMENDED FLUTTER IMPL (do NOT reuse MiuixSurface — its shadow params differ):
- Outer: Padding(padding: outSidePadding).
- DecoratedBox(decoration: ShapeDecoration(
    color: color,
    shape: MiuixSquircleBorder(cornerRadius: cornerRadius, enabled: cornerRadius>0,
             side: showDivider ? BorderSide(color: colors.dividerLine, width: 0.75) : BorderSide.none),
    shadows: shadowElevation>0 ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: Offset.zero, spreadRadius: 0)] : null),
    child: content)
- Wrap in GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {}) to consume taps so they do not fall through to widgets behind the toolbar; child buttons still win their own hit tests in Flutter's arena.

EXACT NUMBERS / DEFAULTS (MiuixFloatingToolbarDefaults):
- static const double cornerRadius = 50;
- static const EdgeInsets outSidePadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);  // PaddingValues(12.dp, 8.dp) = horizontal 12, vertical 8
- static Color defaultColor(BuildContext context) => MiuixTheme.of(context).colors.surfaceContainer;
- shadowElevation default = 4 (widget param default, NOT in defaults object in Kotlin).
- showDivider default = false.

CRITICAL SHADOW NUANCE: shadowElevation is ONLY a boolean gate (>0 shows shadow); the shadow geometry is FIXED at blur radius 10dp / black / alpha 0.10 / zero offset / zero spread regardless of the elevation value. Do not scale blur by shadowElevation. This differs from MiuixSurface (alpha 0.15, blur=elevation, offset (0, elevation*0.5)).

DIVIDER NUANCE: the 0.75dp value is verbatim (0.75.dp padding in Compose). Divider color = colors.dividerLine (in token list). Represent as a 0.75-wide BorderSide on the squircle border.

SQUIRCLE: extension defaults to 1.1 (SquircleDefaults.Extension; Min 1.0, Max 2.0) — handled internally by MiuixSquircleBorder, no need to pass. cornerRadius=50 with a short toolbar height yields a pill silhouette.

NO content color / LocalContentColor is set by this component — do NOT wrap in MiuixContentColor. NO text styles used. Color tokens surfaceContainer + dividerLine both already exist in MiuixColors.
