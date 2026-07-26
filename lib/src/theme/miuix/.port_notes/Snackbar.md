# 移植分析：Snackbar

- 复杂度: very-high
- 预估行数: 490
- 未移植依赖(unportedDeps): Icon
- 已移植依赖(portedDeps): MiuixText, MiuixTextButton, MiuixButtonColors, MiuixButtonDefaults, MiuixSquircleBorder, MiuixContentColor, MiuixTheme, folmeSpring, MiuixMotion
- portedDepsNote: MiuixTextButton takes colors: MiuixButtonColors?. Source uses ButtonDefaults.textButtonColorsPrimary(color=actionContainerColor, textColor=actionContentColor); map to MiuixButtonColors(color: actionContainerColor, contentColor: actionContentColor, disabledColor: ..., disabledContentColor: ...). squircleBackground → ShapeDecoration(color:, shape: MiuixSquircleBorder(cornerRadius:16)). LocalContentColor provides → wrap body in MiuixContentColor(color: contentColor, child:).
- 计划公开 API(publicApi): MiuixSnackbarDuration (sealed: short/long/indefinite/custom(ms)), MiuixSnackbarResult (enum: dismissed, actionPerformed), MiuixSnackbarVisuals, MiuixSnackbarData (abstract), MiuixSnackbarHostState (extends ChangeNotifier), MiuixSnackbarHost (widget), MiuixSnackbar (widget), MiuixSnackbarColors, MiuixSnackbarDefaults
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
1) AccessibilityManager.calculateRecommendedTimeoutMillis (extends timeout for a11y) has NO Flutter equivalent — drop it and use base durations (Short 4000ms, Long 10000ms, Indefinite = null/never, Custom = value). 2) Compose AnimatedVisibility default springs are not exposed — approximate with Flutter SpringDescription/AnimationController or duration+curve; slide/expand use spring stiffness≈400 dampingRatio 1 (StiffnessMediumLow, no bounce → response≈0.31s), the non-newest exit fadeOut uses spring stiffness=1500 dampingRatio 1 (StiffnessMedium → response≈0.16s). 3) anchoredDraggable swipe-to-dismiss (full-width anchors ±width, 50% positional threshold, fling) → closest is Dismissible(direction: DismissDirection.horizontal, dismissThresholds: {horizontal:0.5}) or a custom horizontal-drag GestureDetector + SlideTransition; on dismiss call data.dismiss(). 4) Compose dropShadow (blur only, no offset) → BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius:10, offset: Offset.zero) placed in ShapeDecoration.shadows using the squircle shape. 5) Semantics: liveRegion Polite + traversalGroup → Semantics(liveRegion:true, container:true). 6) Mutex/CompletableDeferred concurrency → use Dart Completer<MiuixSnackbarResult> per entry; a plain re-entrancy bool guards double-complete (Dart is single-threaded so no real mutex needed).

## 实现要点(keyNotes) — 严格按此复刻
STRUCTURE: This is a full snackbar SYSTEM, not one widget. Port 4 data types + host-state + host + card.

DEFAULTS (MiuixSnackbarDefaults, all logical px): cornerRadius=16; insideMargin=EdgeInsets.all(12); outerPadding=EdgeInsets.only(left:12,right:12,top:8); actionCornerRadius=50; actionInsideMargin=EdgeInsets.symmetric(horizontal:12,vertical:0); private hostBottomPadding=12.

DURATIONS (toMillis, ignore a11y): Indefinite→never auto-dismiss; Long→10000ms; Short→4000ms; Custom→durationMillis (must be >0, assert).

DEFAULT COLORS (snackbarColors from MiuixTheme.of(context).colors): containerColor=onSecondaryVariant; contentColor=secondaryVariant; actionContentColor=onPrimary; dismissActionContentColor=onSurfaceContainerVariant; actionContainerColor=primary. MiuixSnackbarColors is @immutable with 5 final Color fields (containerColor, contentColor, actionContentColor, dismissActionContentColor, actionContainerColor).

SNACKBAR CARD (MiuixSnackbar) layout, outer→inner:
- Padding(outerPadding: L12/R12/T8).
- Decoration: ShapeDecoration(shape: MiuixSquircleBorder(cornerRadius:16), color: containerColor, shadows:[BoxShadow(black @0.1 alpha, blurRadius:10, offset zero)]). (Source: dropShadow uses RoundedCornerShape(16) but fill uses squircle — use squircle for both.)
- GestureDetector(onTap:(){}) to consume taps so they don't pass through.
- Wrap content in MiuixContentColor(color: contentColor).
- Row(crossAxisAlignment: center, constraints minHeight:48, padding: insideMargin=12):
  * Expanded(child: MiuixText(message, style: textStyles.body2, color: contentColor, maxLines:2, overflow: ellipsis)).  [weight(1f)]
  * If actionLabel not null/empty: Padding(left:12) → MiuixTextButton(actionLabel, cornerRadius:50, minWidth:26, minHeight:26, insideMargin: EdgeInsets.symmetric(horizontal:12,vertical:0), textStyle: TextStyle(fontSize:15), colors: MiuixButtonColors(color: actionContainerColor, contentColor: actionContentColor,...), onPressed: () => data.performAction()).
  * If withDismissAction: Padding(left:8) → GestureDetector(no ripple, onTap: data.dismiss()) wrapping close icon SizedBox(20x20): Icon(Icons.close /or ported MiuixIcon(Close), size:20, color: dismissActionContentColor).

HOST (MiuixSnackbarHost): params state, canSwipeToDismiss=true (default), builder content=(data)=>MiuixSnackbar(data). Layout: Align(bottomCenter) → ListView/Column reversed (reverseLayout=true, newest at index 0 shown at BOTTOM), verticalArrangement Top, horizontalAlignment center, bottom contentPadding=12 (hostBottomPadding). Iterate state.currentSnackbars keyed by entry.id. STACKING: multiple snackbars stack; zIndex=(count-index) so newest (index0) is on top — in Flutter, list order + the reversed layout handles paint order; ensure newest bottom-most and above others.

PER-ITEM BEHAVIOR:
- On show: MutableTransitionState false→true (animate in). Enter anim = slideInVertically(from +12px = hostBottomPadding) + expandVertically(expandFrom top, clip:false). In Flutter: SizeTransition(axisAlignment:-1 i.e. top) + SlideTransition/Transform.translate(0,12→0).
- Auto-dismiss: after toMillis delay (Timer), if not currently swiped, call entry.data.dismiss(). Indefinite = no timer.
- Swipe: if user swipes past 50% width in either direction → dismiss.
- Exit anim differs by position: index==0 (newest/bottom) → slideOutVertically(to +12px) + shrinkVertically(towards top, clip:false); OTHERS → fadeOut(spring stiffness1500) + shrinkVertically(towards top, clip:false). After exit idle, removeEntry from list.

STATE (MiuixSnackbarHostState): holds List<SnackbarEntry{id:int, data, visible:bool=true}> as ChangeNotifier; idCounter; async showSnackbar(message, {actionLabel, withDismissAction=false, duration=Short}) → returns Future<MiuixSnackbarResult> via Completer. New entries insert at index 0. data.dismiss() completes with Dismissed + marks entry visible=false (copyWith); data.performAction() completes with ActionPerformed + hides. Guard against double-complete with a completed bool. removeEntry(entry) removes after exit anim finishes. newestSnackbarData()=first visible, oldestSnackbarData()=last visible.

FILE HEADER: use the mandated 4-line Apache header referencing Snackbar.kt. One file: components/miuix_snackbar.dart. Chinese /// docs, first line "对应 Kotlin Snackbar/SnackbarHost/SnackbarHostState".
