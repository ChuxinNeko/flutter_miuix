# 移植分析：Badge

- 复杂度: medium
- 预估行数: 175
- 未移植依赖(unportedDeps): 无
- 已移植依赖(portedDeps): MiuixTheme, MiuixContentColor, MiuixText
- 计划公开 API(publicApi): MiuixBadgedBox, MiuixBadge, MiuixBadgeDefaults, MiuixBadgeDefaults.size, MiuixBadgeDefaults.largeSize, MiuixBadgeDefaults.containerColor(context), MiuixBadgeDefaults.contentColor(context)
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
Compose HorizontalRuler/VerticalRuler (BadgeTopRuler/BadgeEndRuler + Modifier.badgeBounds) is a Compose 1.7 layout feature with no Flutter equivalent. It only clamps the badge inside NavigationBar/NavigationRail item bounds; for a standalone BadgedBox the rulers are +INF/-INF so clamping is a no-op. Closest Flutter approach: implement the unbounded default placement via CustomMultiChildLayout now, and expose an optional (endBound/topBound) clamp param that Nav components can supply once ported — instead of reimplementing rulers. Second concern: LineHeightStyle(alignment=Center) for vertically centering the single-line label → reproduce with TextStyle.height=16/11 plus TextLeadingDistribution.even (baked into the theme-override main style, since MiuixText doesn't accept a leadingDistribution arg). Third: FirstBaseline/LastBaseline alignment-line republication doesn't map to Flutter's baseline model; drop it (only affects a baseline-aligning parent, not present here).

## 实现要点(keyNotes) — 严格按此复刻
Badge.kt has ZERO dependencies on other unported miuix components — it imports ONLY theme (LocalContentColor, LocalTextStyles, MiuixTheme). Colors error/onError and textStyle footnote2 are all already present. Safe to port immediately; it unblocks NavigationBar/NavigationRail (they call the internal badgeBounds()/rulers). Exposes two widgets + a defaults class.

EXACT CONSTANTS (dp = logical px, verbatim):
- BadgeDefaults.Size = 6 (icon-only "dot" badge min size)
- BadgeDefaults.LargeSize = 16 (min size when content present)
- containerColor = colors.error ; contentColor = colors.onError
- shape = CircleShape → use StadiumBorder (fully-rounded pill). A 6x6 dot renders as a circle; a content pill has fully-rounded ends. Do NOT use a fixed cornerRadius.
- BadgeWithContentHorizontalPadding = 4 (EdgeInsets.symmetric(horizontal:4), applied ONLY when content != null)
- BadgeWithContentHorizontalOffset = 12 ; BadgeWithContentVerticalOffset = 14 (offsets used when badge HAS content)
- BadgeOffset = 6 (offset used on BOTH axes when NO content)

MiuixBadge widget:
- size = content != null ? 16 : 6.
- Structure: Row (verticalAlignment center, horizontalArrangement center) with ConstrainedBox(minWidth:size, minHeight:size) + ShapeDecoration(color: containerColor, shape: StadiumBorder()). Add horizontal:4 padding only when content != null. Content is caller-provided Widget? (default null → empty dot).
- content styling is the ONE subtle part. Source wraps content in ProvideContentColorTextStyle: it (a) provides contentColor as LocalContentColor, and (b) MERGES footnote2 (11sp) into LocalTextStyles.main, then further copies lineHeight=16.sp + LineHeightStyle(alignment=Center, trim=None). Because our ported MiuixText reads MiuixTheme.of(context).textStyles.main (NOT DefaultTextStyle) and resolves color = color ?? base.color ?? MiuixContentColor.of(context), the faithful reproduction is: wrap content in MiuixContentColor(color: contentColor, child: MiuixTheme(data: theme.copyWith(textStyles: theme.textStyles.copy(main: theme.textStyles.main.merge(theme.textStyles.footnote2).copyWith(height: 16/11, leadingDistribution: TextLeadingDistribution.even))), child: content)). The merge yields fontSize 11; height:16/11 (~1.4545) reproduces the 16sp line box; leadingDistribution.even reproduces LineHeightStyle center alignment (extra leading split evenly above/below to vertically center the digits). Wrapping DefaultTextStyle alone will NOT work because MiuixText ignores it — must override the MiuixTheme textStyles.main.

MiuixBadgedBox layout (custom measure): use CustomMultiChildLayout + MultiChildLayoutDelegate with two LayoutId children "anchor" and "badge".
- anchor child = content wrapped in a centered Box (Alignment.center); badge child = the badge.
- Measure anchor with incoming constraints; the overall widget size = anchor size (width x height). Measure badge with LOOSE height (BoxConstraints.loose or minHeight:0) so text isn't stretched.
- hasContent = badgeSize.width > 6 (compares measured badge width against BadgeDefaults.Size). Empty Badge() measures 6 wide → false; content badge ≥16 → true. This inference exactly mirrors the source.
- hOffset = hasContent ? 12 : 6 ; vOffset = hasContent ? 14 : 6.
- Place anchor at (0,0). Default (standalone, no ruler bounds) placement: badgeX = anchorWidth - hOffset ; badgeY = vOffset - badgeHeight. Concretely: content badge (h=16) → badgeY = 14-16 = -2 (hangs 2px above anchor top, right edge inset 12px from anchor right); dot badge (h=6) → badgeY = 6-6 = 0 (flush top, inset 6px). Badge is positioned top-END corner of the anchor.
- Source clamps with rulers: badgeX = min(anchorW - hOffset, endRuler - badgeW); badgeY = max(vOffset - badgeH, topRuler). With no rulers provided endRuler=+INF and topRuler=-INF, so clamping is a no-op → the default formulas above are EXACT for standalone use. NavigationBar/Rail apply badgeBounds() which sets endRuler=itemWidth, topRuler=0 to keep the badge inside the item. Port the unbounded default now; optionally expose an optional clamp param (endBound/topBound doubles, default null=unbounded) so Nav components can pass item bounds later — do NOT try to replicate the Compose Ruler API.
- placeRelative is RTL-aware (mirrors X). For 1:1 you may read Directionality and mirror when RTL; app is mobile — a simple LTR top-right placement is acceptable if RTL isn't used, but note it.
- The source also republishes anchor-only FirstBaseline/LastBaseline as the widget's baselines; Flutter baseline propagation differs and this only matters if a parent baseline-aligns the BadgedBox — safe to skip (note as a minor fidelity gap).

Defaults class per conventions: class MiuixBadgeDefaults { MiuixBadgeDefaults._(); static const double size = 6; static const double largeSize = 16; static Color containerColor(BuildContext c) => MiuixTheme.of(c).colors.error; static Color contentColor(BuildContext c) => MiuixTheme.of(c).colors.onError; } Also keep internal consts (badgeWithContentHorizontalPadding=4, offsets 12/14/6) private in the file.
