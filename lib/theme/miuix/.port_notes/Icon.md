# 移植分析：Icon

- 复杂度: low
- 预估行数: 95
- 未移植依赖(unportedDeps): 无
- 已移植依赖(portedDeps): MiuixContentColor
- 计划公开 API(publicApi): MiuixIcon, MiuixIconDefaults
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
1) toolingGraphicsLayer() (line 143) is Compose preview/inspector tooling only, no runtime rendering effect. Ignore it entirely in Flutter; nothing to replicate. 2) The ColorProducer overload (lines 170-191) uses drawWithCache + obtainGraphicsLayer() + record{drawContent()} + deferred ColorFilter.tint(it()) so a frequently-changing tint (animations/scroll) re-draws WITHOUT recomposing. Flutter closest: accept an optional Color Function()? tintProducer and re-read at paint time via AnimatedBuilder/RepaintBoundary, or simplest and visually identical - just take a plain Color? tint and let the caller drive it with ValueListenableBuilder. This is a perf optimization, not a visual difference. 3) Kotlin's Painter/ImageVector/ImageBitmap input types do not map to Flutter - per conventions line 47 the Flutter port accepts an IconData and/or a caller-supplied Widget. No native blur/sensor/haptics involved.

## 实现要点(keyNotes) — 严格按此复刻
SCOPE: Icon.kt has 4 Compose Icon(...) overloads - (a) ImageVector, (b) ImageBitmap, (c) Painter [MAIN impl, lines 123-148], (d) Painter+ColorProducer [lines 170-191]. Overloads (a)/(b) just wrap their input in a painter and delegate to (c). Per conventions line 47, Flutter does NOT reproduce painter/vector/bitmap types - expose ONE MiuixIcon that the caller feeds a Flutter icon into. IconButton mentioned in doc comments is NOT a code dependency.

RECOMMENDED DART API: MiuixIcon widget with: IconData? icon, Widget? child (raw widget for custom/multicolor icons), Color? tint (default null -> resolve to MiuixContentColor.of(context)), String? contentDescription, double? size. Add MiuixIconDefaults._() with static const double defaultSize = 24; (from DefaultIconSizeModifier = Modifier.size(24.dp), line 204).

TINT SEMANTICS (critical): default tint = LocalContentColor.current -> tint ?? MiuixContentColor.of(context). In Compose Color.Unspecified means NO tint (null ColorFilter, line 131) - used for multicolor icons. Replicate with an explicit sentinel compared by identity (e.g. a static const kMiuixTintUnspecified) matching tint == Color.Unspecified at line 131; when unspecified render child WITHOUT any color filter.

APPLYING TINT: Compose ColorFilter.tint(color) uses BlendMode.SrcIn by default. In Flutter: for an IconData, build Icon(icon, color: resolvedTint, size: resolvedSize, semanticLabel: contentDescription) - Material Icon already tints via SrcIn and defaults size 24, matching miuix exactly. For an arbitrary Widget/image needing tint, wrap in ColorFiltered(colorFilter: ColorFilter.mode(resolvedTint, BlendMode.srcIn), child: child).

CONTENT SCALE: .paint(painter, contentScale = ContentScale.Fit) (line 145) -> BoxFit.contain when drawing an image/child into a sized box.

SIZE FALLBACK: 24.dp is applied ONLY when the painter has no intrinsic size (intrinsicSize == Size.Unspecified or both width&height infinite - see defaultSizeFor/isInfinite, lines 193-201). Icons with intrinsic size keep their own size. Flutter mapping: size ?? MiuixIconDefaults.defaultSize (24) for IconData; for a raw Widget with its own size, do not force 24 unless size is given. Material's Icon already implements this 24 default.

SEMANTICS: contentDescription!=null -> Semantics(label: contentDescription, image: true, child: ...) (Role.Image -> image: true). When contentDescription==null, no Semantics wrapper (matches else Modifier). Material Icon(icon, semanticLabel:) already emits image semantics.

NO colorScheme/textStyles tokens referenced (inherited content color only) -> no new tokens. No corner radius, padding, spacer, or animation params in this file. No popup/overlay infra. File header per conventions: // Miuix Flutter port - Icon.
