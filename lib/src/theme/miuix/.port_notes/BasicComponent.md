# 移植分析：BasicComponent

- 复杂度: medium
- 预估行数: 290
- 未移植依赖(unportedDeps): 无
- 已移植依赖(portedDeps): MiuixText, MiuixTheme, MiuixPressable
- 计划公开 API(publicApi): MiuixBasicComponent, MiuixBasicComponentColors, MiuixBasicComponentDefaults
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
1) CUSTOM MEASURE/PLACE: The start/center/end row uses Compose `Layout{}` that (a) queries `endMeasurable.maxIntrinsicWidth(maxHeight)` and (b) sizes itself to `rowHeight = max(childHeights)`. Do NOT use `CustomMultiChildLayout`/`MultiChildLayoutDelegate` — its `getSize(constraints)` runs BEFORE children are laid out, so the layout height cannot depend on child heights. Port it as a small `MultiChildRenderObjectWidget` + custom `RenderBox` (with `ContainerRenderObjectMixin`/`RenderBoxContainerDefaultsMixin`). RenderBox exposes `child.getMaxIntrinsicWidth(height)` and `child.layout(constraints, parentUsesSize: true)`, letting you replicate the algorithm 1:1 and set `size` in `performLayout`. NOTE: a plain `Row` with `Expanded` center will NOT reproduce the exact 60% end-cap allocation. (Alternatively, since a child laid out under `maxWidth = endHardCap` naturally returns `min(intrinsicWidth, endHardCap)`, you can skip the explicit intrinsic query and just layout end with `maxWidth: endHardCap` — result is identical for content that sizes to its min.) 2) HOLD-DOWN STATE: `holdDownState:Boolean` drives `HoldDownObserver` which emits a HoldDown interaction consumed by the theme's `MiuixIndication`, adding a 0.10 overlay alpha (identical magnitude to a press). MiuixPressable currently has NO forced-held-down input. Recommend adding a `bool heldDown` param to MiuixPressable that adds `_kPressAlphaDelta` (0.10) to `_targetOverlayAlpha()` and animates via press-enter/press-exit springs. The hold-down overlay is only visible when the component is clickable (indication is attached by `clickable`), so guard accordingly. 3) ACCESSIBILITY: `onClickLabel` + `role: Role?` map to a `Semantics(button:/label:/onTap:)` wrapper (non-visual). 4) `interactionSource` param is Compose plumbing — drop it; MiuixPressable manages state internally.

## 实现要点(keyNotes) — 严格按此复刻
SOURCE: basic/Component.kt — two overloads of `BasicComponent`. Port as ONE `MiuixBasicComponent` widget with named params covering both (title/summary strings AND custom children).

OVERLOAD A (string): builds two MiuixText nodes as the center `content`:
- Title (only if `title != null`): `MiuixText(title, fontSize: textStyles.headline1.fontSize, fontWeight: FontWeight.w500 /*Medium*/, color: titleColor.color(enabled))`.
- Summary (only if `summary != null`): `MiuixText(summary, fontSize: textStyles.body2.fontSize, color: summaryColor.color(enabled))` (no weight override → inherits MiuixText default which is textStyles.main).
NOTE: only `.fontSize` is taken from headline1/body2; the rest of the style stays MiuixText's default (main). Both texts stacked in a start-aligned, center-arranged Column.

DEFAULTS (BasicComponentDefaults):
- InsideMargin = `PaddingValues(16.dp)` → `EdgeInsets.all(16)` (uniform).
- titleColor: color=`onBackground`, disabledColor=`disabledOnSecondaryVariant`.
- summaryColor: color=`onSurfaceVariantSummary`, disabledColor=`disabledOnSecondaryVariant`.
All 3 tokens exist in MiuixColors list → no new color tokens. headline1/body2 exist → no new text styles.

COLORS CLASS: `MiuixBasicComponentColors { final Color color; final Color disabledColor; Color resolve(bool enabled) => enabled ? color : disabledColor; }` (@immutable, const ctor). Mirror Kotlin `data class BasicComponentColors`.

OUTER BOX / CLICK: Modifier chain is `.heightIn(min = 56.dp).fillMaxWidth().then(clickable).padding(insideMargin)` (outer→inner). So: min height 56, full width; the clickable+overlay area is the FULL 56×fullWidth box INCLUDING the 16 padding; content is inset by insideMargin. Port:
  ConstrainedBox(minHeight:56) → SizedBox width infinity (fillMaxWidth) → MiuixPressable(onPressed: (enabled && onClick!=null) ? onClick : null, heldDown: holdDownState, feedbackType: MiuixPressFeedbackType.none, borderRadius: null /*rectangular overlay, MiuixIndication uses drawRect, no rounding*/, overlayColor: null /*defaults to onBackground = MiuixIndication(color=onBackground)*/) → Padding(insideMargin) → the column below.
Clickable ONLY when `enabled && onClick != null`; otherwise plain (no pressable, pass onPressed:null). Vertical arrangement Center: use ConstrainedBox(minHeight:56) around Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center) — Column will stretch to the 56 min from constraints and center its content.

BRANCH 1 (startAction==null && endActions==null): just Column(mainAxisAlignment: center, crossAxisAlignment: start) with content children — no custom layout.

BRANCH 2 (start or end present): custom 3-slot row (start / center / end), vertically centered. spacer = 8.dp (`8.dp.roundToPx()` → 8 logical px). Slots:
  - start: Column(center, crossStart) { startAction }
  - center: Column(center, crossStart) { content }  (title/summary or custom)
  - end: Column(center, crossEnd) { Row { endActions } }  (endActions is RowScope → in Flutter a Row(mainAxisSize.min) of the endActions widgets, right-aligned)

MEASURE ALGORITHM (verbatim, all in logical px):
  spacer = 8
  measure start with loose (min 0). startW = startWidth or 0. startSpacer = startW>0 ? 8 : 0.
  widthAfterStart = max(0, maxWidth - startW - startSpacer)
  endIntrinsic = end.maxIntrinsicWidth(maxHeight) or 0
  endHardCap = max(0, widthAfterStart - 8) * 6 / 10   // 60% of remaining-minus-one-spacer
  endTarget = min(endIntrinsic, endHardCap)
  measure end with maxWidth = endTarget (loose min). endW = endWidth or 0. endSpacer = endW>0 ? 8 : 0.
  widthForCenter = max(0, widthAfterStart - endW - endSpacer)
  measure center with maxWidth = widthForCenter.
  rowHeight = max(startH, centerH, endH)
  layoutHeight = rowHeight.coerceIn(minHeight, maxHeight==Infinity ? rowHeight : maxHeight)
  final size: width = maxWidth (full), height = layoutHeight.
PLACEMENT (LTR; use placeRelative semantics):
  startTop = max(0, rowHeight - startH) / 2
  centerTop = (rowHeight - centerH) / 2
  endTop = max(0, rowHeight - endH) / 2
  start at (0, startTop)
  center at (startW + startSpacer, centerTop)
  end at (maxWidth - endW, endTop)   // right-aligned to the box edge, NOT after center
Integer division `* 6 / 10` in Kotlin is int math; keep it as (…).floor()/round-to-int equivalent — use `(x * 6 / 10)` on ints or `(x * 0.6)` then floor to match.

BOTTOM ACTION: if bottomAction != null → after the row/center, add SizedBox(height: 8) then the bottomAction widget (full width, below the main row). This is inside the outer Column.

HOLD-DOWN: see platformConcerns — add `heldDown` to MiuixPressable adding 0.10 alpha via press springs; only meaningful when clickable.

MiuixIndication overlay params (already in MiuixPressable): hover +0.06, focus +0.08, press +0.10, holdDown +0.10; springs — pressEnter folmeSpring(damping 1.0, response 0.2), pressExit folmeSpring(damping 0.95, response 0.35), hoverEnter (1.0, 0.6), hoverExit (0.96, 0.2). Overlay is a full-size rectangle (drawRect), no corner rounding.

API SHAPE (suggested): MiuixBasicComponent({Key? key, String? title, MiuixBasicComponentColors? titleColor, String? summary, MiuixBasicComponentColors? summaryColor, Widget? startAction, List<Widget>? endActions, Widget? bottomAction, EdgeInsets insideMargin = MiuixBasicComponentDefaults.insideMargin, VoidCallback? onClick, String? onClickLabel, bool holdDownState = false, bool enabled = true, List<Widget>? content}). MiuixBasicComponentDefaults: private ctor, `static const EdgeInsets insideMargin = EdgeInsets.all(16)`, `static MiuixBasicComponentColors titleColor(BuildContext)` and `summaryColor(BuildContext)` reading MiuixTheme.of(context).colors.
