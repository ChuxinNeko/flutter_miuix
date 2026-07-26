# 移植分析：SearchBar

- 复杂度: medium
- 预估行数: 330
- 未移植依赖(unportedDeps): Icon
- 已移植依赖(portedDeps): MiuixText, MiuixTheme, MiuixContentColor
- portedDepsNote: All colorScheme tokens (surfaceContainerHigh, onSurfaceContainerHigh, onSurfaceContainerHighest, primary) and textStyles.main verified present in lib/presentation/miuix/theme/miuix_colors.dart and miuix_text_styles.dart. No new tokens needed.
- 计划公开 API(publicApi): MiuixSearchBar, MiuixInputField, MiuixSearchBarDefaults
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
1) CAPSULE SHAPE IS *NOT* SQUIRCLE. The input field uses Compose `CircleShape` (fully rounded pill), applied both as background shape (color, shape=capsuleShape) and as clip on the clear-icon. Port with `StadiumBorder()` for the ShapeDecoration and a large `BorderRadius.circular(999)` / stadium clip for the clear button. Do NOT use MiuixSquircleBorder here.
2) `hasFocusReassignBug` (from miuix-core Utils; = Android SDK<=27, i.e. API 26-27 only) drives a workaround where the TextField is DISABLED while collapsed and a `pointerInput{detectTapGestures{onExpandedChange(true)}}` handles tap-to-expand. This bug does not exist on the Flutter targets — treat `workaroundEnabled = true` unconditionally: the pointerInput branch is dead code, and `enabled = enabled && workaroundEnabled` reduces to just `enabled`. Drop the whole workaround; keep only the plain focus-driven expand.
3) `NavigationBackHandler` + `rememberNavigationEventState(NavigationEventInfo.None)` (androidx.navigationevent, predictive-back API): back is intercepted only when `expanded`, and `onBackCompleted` calls `onExpandedChange(false)`. Closest Flutter: wrap the SearchBar in `PopScope(canPop: !expanded, onPopInvoked/onPopInvokedWithResult: (didPop){ if(!didPop) onExpandedChange(false); })`. The predictive-back swipe animation is not replicable; PopScope gives the correct collapse-on-back behavior.
4) IME: `KeyboardOptions(imeAction = ImeAction.Search)` -> `textInputAction: TextInputAction.search`; `KeyboardActions(onSearch = {onSearch(query)})` -> `onSubmitted: (_) => onSearch(query)`.
5) Focus: `collectIsFocusedAsState` -> FocusNode listener; `onFocusChanged{ if(isFocused) onExpandedChange(true) }` -> FocusNode listener firing onExpandedChange(true) on gaining focus; `focusRequester.requestFocus()` -> `focusNode.requestFocus()`; `focusManager.clearFocus()` -> `focusNode.unfocus()` (or FocusScope.of(context).unfocus()). Requesting focus programmatically will raise the soft keyboard, matching the Compose behavior.
6) The default leading (Search magnifier) and trailing (SearchCleanup / X) icons reference the unported miuix `Icon` + `MiuixIcons.Basic.Search`/`SearchCleanup` assets. These are a SOFT dependency: per the conventions icons are caller-provided Widgets, and the two defaults can be inlined with tinted Flutter glyphs (Icons.search tinted onSurfaceContainerHigh; Icons.cancel/close tinted onSurfaceContainerHighest) sized 24. SearchBar is therefore NOT blocked by porting Icon — it can be built now.

## 实现要点(keyNotes) — 严格按此复刻
TWO widgets + one defaults class. Source has `SearchBar` (container) and `InputField` (the text field) as independent public composables; the caller wires them (passes an InputField as SearchBar's `inputField` slot). Mirror this: `MiuixSearchBar` takes an `inputField` Widget builder/child, `MiuixInputField` is a standalone stateful widget.

=== MiuixSearchBarDefaults (all dp/sp -> logical px 1:1) ===
- insideMargin: DpSize(width=12, height=0) -> expose as EdgeInsets or a {width:12,height:0} pair. Applied as `padding(vertical=height=0, horizontal=width=12)` around the inputField box.
- inputFieldMinHeight = 45
- inputFieldFontSize = 17
- leadingIconStartPadding = 16, leadingIconEndPadding = 8
- trailingIconStartPadding = 8, trailingIconEndPadding = 16

=== MiuixSearchBar (Column) ===
Column(child):
  Row(fillMaxWidth, crossAxis=center):
    - Flexible/Expanded(weight 1): Padding(vertical: insideMargin.height=0, horizontal: insideMargin.width=12) { inputField }
    - outsideEndAction (nullable): wrapped in AnimatedVisibility(visible=expanded, enter = expandHorizontally()+slideInHorizontally(initialOffsetX={it}), exit = shrinkHorizontally()+slideOutHorizontally(targetOffsetX={it})). It slides in FROM THE RIGHT (offset = +full width) while expanding horizontally. Flutter: ClipRect + AnimatedSize (horizontal) + SlideTransition (begin Offset(1,0) -> Offset.zero) + reverse on collapse. Only rendered when outsideEndAction != null.
  AnimatedVisibility(visible=expanded) { content() }  // default = expandVertically()+fadeIn() / shrinkVertically()+fadeOut(). Flutter: AnimatedSize/SizeTransition (vertical) + FadeTransition, or ClipRect+Align size animation. content is a ColumnScope slot -> Flutter: List<Widget> or a builder placed in the Column.
PopScope wraps the whole thing (see platformConcerns #3).

Compose AnimatedVisibility default animation specs (use for all the above): expandHorizontally/expandVertically/shrink* default = `spring(stiffness = Spring.StiffnessMediumLow = 400, visibilityThreshold = IntSize/IntOffset)`, dampingRatio = 1.0 (no bounce); slideIn/slideOut default = `spring(stiffness = 400, dampingRatio = 1.0)`; fadeIn/fadeOut default = `spring(stiffness = 400)`. In Flutter approximate with `folmeSpring` or a Curves.easeOut ~250-300ms if spring is awkward; note the no-bounce, stiffness-400 character.

=== MiuixInputField (StatefulWidget) ===
State: internal FocusNode (if none provided), an alpha AnimationController(value 1.0) for `textAlpha`, focus-listener.
- capsuleShape = CircleShape (stadium/pill).
- background color param default = colorScheme.surfaceContainerHigh (pass Color.transparent when a backdrop-blur is drawn behind).
- Layout (decorationBox): Box(background: color, shape: stadium, align: centerStart) > Row(fillMaxWidth, center):
    [leadingIcon] then Expanded(weight1, heightIn min=45, align centerStart){ label Text + innerTextField overlay } then [trailingIcon].
- DEFAULT leadingIcon = Search icon, Padding(start:16, end:8), tint = onSurfaceContainerHigh, size 24. (nullable override)
- DEFAULT trailingIcon = AnimatedVisibility(visible = query.isNotEmpty(), enter fadeIn / exit fadeOut) { Box(Padding(start:8,end:16), align centerStart){ clear-icon clipped stadium, clickable -> onQueryChange('') , tint = onSurfaceContainerHighest, size 24 } }. Use FadeTransition/AnimatedSwitcher on query-empty toggle. Tap via GestureDetector (NO ripple).
- Text (input) style = textStyles.main.copyWith(fontWeight FontWeight.w500 = Medium) .merge(caller textStyle) .copyWith(color = MiuixContentColor.of(context)  // == LocalContentColor.current). cursorColor = colorScheme.primary. singleLine -> maxLines:1.
- LABEL: labelText = (query.isEmpty && !expanded) ? label : ''  (i.e. shown ONLY when empty AND collapsed; disappears once expanded even if empty). Label style = TextStyle(fontSize:17, fontWeight:w500).merge(caller textStyle), color = onSurfaceContainerHigh. Rendered as an overlay Text BEHIND innerTextField (both in the same centerStart Box). Implement with a Stack: label Text underneath, then the innerTextField wrapped in Opacity/FadeTransition(alpha = textAlpha controller value).
- innerTextField uses Flutter TextField with InputDecoration(isDense:true, contentPadding: zero, border: none) like the existing miuix_textfield.dart pattern.

Expand/collapse effect (LaunchedEffect(expanded) — replicate in didUpdateWidget when `expanded` changes):
  if expanded becomes true: focusNode.requestFocus() (raises keyboard).
  else if it was focused: `await Future.delayed(100ms)`; if query.isNotEmpty: alphaController.animateTo(0) (fade text out), then onQueryChange(''), then alphaController.value = 1.0 (snap back); then focusNode.unfocus(). textAlpha default Animatable spring ~ stiffness Medium(1500)/damping1 -> a quick ~150ms fade; a 120-160ms FadeTransition is a faithful approximation.
Also onFocusChanged listener: when node gains focus -> onExpandedChange(true).

Header comment must note: capsule = stadium (not squircle); Android API26-27 focus workaround dropped; back handled via PopScope.
