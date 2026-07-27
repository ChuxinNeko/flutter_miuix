// Miuix Flutter 移植版 - 统一弹窗注册、分层与过渡基础设施
// 源自 compose-miuix-ui 的 MiuixPopupUtils.kt。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' show sin;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

/// 弹窗内容过渡的构建器。
typedef MiuixPopupTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

/// 描述一次进入或退出过渡。
///
/// [builder] 接收始终限制在 0 到 1 的进度；0 表示完全隐藏，1 表示完全显示。
/// 进入阶段设置 [spring] 时使用弹簧模拟，否则使用 [duration] 与 [curve]。
@immutable
class MiuixPopupTransition {
  const MiuixPopupTransition({
    required this.builder,
    required this.duration,
    this.curve = Curves.linear,
    this.spring,
    this.visibilityThreshold = 0.0001,
  });

  final MiuixPopupTransitionBuilder builder;
  final Duration duration;
  final Curve curve;
  final SpringDescription? spring;
  final double visibilityThreshold;

  Widget build(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    return builder(context, _ClampedAnimation(animation), child);
  }

  /// 只改变透明度的过渡。
  factory MiuixPopupTransition.fade({
    required Duration duration,
    Curve curve = Curves.linear,
    SpringDescription? spring,
    double visibilityThreshold = 0.0001,
  }) {
    return MiuixPopupTransition(
      duration: duration,
      curve: curve,
      spring: spring,
      visibilityThreshold: visibilityThreshold,
      builder: (context, animation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

/// Kotlin 默认过渡的 Flutter 等价定义。
class MiuixPopupDefaults {
  MiuixPopupDefaults._();

  static const Curve _decelerate15 = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve _sinOut = _SinOutCurve();

  static final SpringDescription _largeDialogSpring =
      SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: 438.6,
        ratio: 0.9,
      );
  static final SpringDescription _smallDialogSpring =
      SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: 450,
        ratio: 0.88,
      );

  /// 对话框遮罩进入：300ms、减速曲线。
  static final MiuixPopupTransition dialogDimEnter =
      MiuixPopupTransition.fade(
        duration: const Duration(milliseconds: 300),
        curve: _decelerate15,
      );

  /// 对话框遮罩退出：250ms、减速曲线。
  static final MiuixPopupTransition dialogDimExit =
      MiuixPopupTransition.fade(
        duration: const Duration(milliseconds: 250),
        curve: _decelerate15,
      );

  /// 普通弹窗遮罩进入：300ms、正弦缓出。
  static final MiuixPopupTransition popupDimEnter =
      MiuixPopupTransition.fade(
        duration: const Duration(milliseconds: 300),
        curve: _sinOut,
      );

  /// 普通弹窗遮罩退出：150ms、正弦缓出。
  static final MiuixPopupTransition popupDimExit =
      MiuixPopupTransition.fade(
        duration: const Duration(milliseconds: 150),
        curve: _sinOut,
      );

  /// 普通弹窗内容进入：200ms 淡入。
  static final MiuixPopupTransition popupEnter =
      MiuixPopupTransition.fade(
        duration: const Duration(milliseconds: 200),
      );

  /// 普通弹窗内容退出：150ms 淡出。
  static final MiuixPopupTransition popupExit =
      MiuixPopupTransition.fade(
        duration: const Duration(milliseconds: 150),
      );

  /// 大屏对话框内容以淡入和 0.8→1 缩放弹簧进入。
  static final MiuixPopupTransition largeDialogEnter = MiuixPopupTransition(
    duration: const Duration(milliseconds: 300),
    spring: _largeDialogSpring,
    builder: (context, animation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1).animate(animation),
          child: child,
        ),
      );
    },
  );

  /// 大屏对话框内容淡出并缩放至 0.8。
  static final MiuixPopupTransition largeDialogExit = MiuixPopupTransition(
    duration: const Duration(milliseconds: 200),
    curve: _decelerate15,
    builder: (context, animation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1).animate(animation),
          child: child,
        ),
      );
    },
  );

  /// 小屏对话框从自身高度的下方弹簧滑入。
  static final MiuixPopupTransition smallDialogEnter = MiuixPopupTransition(
    duration: const Duration(milliseconds: 300),
    spring: _smallDialogSpring,
    builder: (context, animation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );

  /// 小屏对话框向自身高度的下方滑出。
  static final MiuixPopupTransition smallDialogExit = MiuixPopupTransition(
    duration: const Duration(milliseconds: 200),
    curve: _decelerate15,
    builder: (context, animation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}

/// 控制一个对话框或普通弹窗的显示状态。
///
/// 控制器可在布局组件重建时保持不变，也可直接监听 [visibleListenable]。
class MiuixPopupController extends ChangeNotifier
    implements ValueListenable<bool> {
  MiuixPopupController({
    bool visible = false,
    // ignore: prefer_initializing_formals
  }) : _visible = visible;

  bool _visible;

  bool get visible => _visible;

  /// [ValueListenable] 的当前值，等同于 [visible]。
  @override
  bool get value => _visible;

  ValueListenable<bool> get visibleListenable => this;

  set visible(bool value) {
    if (_visible == value) return;
    _visible = value;
    notifyListeners();
  }

  void show() => visible = true;

  void dismiss() => visible = false;

  void toggle() => visible = !visible;
}

/// 注册表中的统一弹窗条目。
///
/// 通常无需手工创建；使用 [MiuixDialogLayout] 或 [MiuixPopupLayout] 注册。
abstract class MiuixPopupEntry extends ChangeNotifier {
  MiuixPopupEntry({
    required this.controller,
    required this.content,
    this.enterTransition,
    this.exitTransition,
    this.enableWindowDim = true,
    this.dimEnterTransition,
    this.dimExitTransition,
  });

  final MiuixPopupController controller;
  double zIndex = 0;
  WidgetBuilder content;
  MiuixPopupTransition? enterTransition;
  MiuixPopupTransition? exitTransition;
  bool enableWindowDim;
  MiuixPopupTransition? dimEnterTransition;
  MiuixPopupTransition? dimExitTransition;

  /// 是否已被宿主（MiuixDialogLayout/MiuixPopupLayout 的 State）放弃所有权。
  /// 为 true 时，HostedEntry 在退出动画结束、entry 从 registry 移除后负责
  /// dispose 本 entry；为 false 时 entry 仍由宿主持有，HostedEntry 不得 dispose
  /// ——否则宿主再次 show 对话框时 _visibilityChanged 会往已 dispose 的
  /// ChangeNotifier 上 addListener，抛 use-after-dispose。
  bool orphaned = false;

  bool _disposed = false;

  /// 是否已释放。
  bool get isDisposed => _disposed;

  /// dispose 幂等化：宿主 Layout State 与 HostedEntry 可能在同一帧被卸载
  /// （例如承载弹层的路由整体 pop），两侧的 orphaned 判断会同时成立并各自
  /// 调用 dispose——第二次调用直接忽略，避免 use-after-dispose 断言。
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }

  bool get isDialog;

  void updateBase({
    required WidgetBuilder content,
    required MiuixPopupTransition? enterTransition,
    required MiuixPopupTransition? exitTransition,
    required bool enableWindowDim,
    required MiuixPopupTransition? dimEnterTransition,
    required MiuixPopupTransition? dimExitTransition,
  }) {
    this.content = content;
    this.enterTransition = enterTransition;
    this.exitTransition = exitTransition;
    this.enableWindowDim = enableWindowDim;
    this.dimEnterTransition = dimEnterTransition;
    this.dimExitTransition = dimExitTransition;
    notifyListeners();
  }
}

/// 对话框条目。
class MiuixDialogEntry extends MiuixPopupEntry {
  MiuixDialogEntry({
    required super.controller,
    required super.content,
    super.enterTransition,
    super.exitTransition,
    super.enableWindowDim,
    super.dimEnterTransition,
    super.dimExitTransition,
    this.enableAutoLargeScreen = true,
    this.dimAlpha,
    this.onDismissFinished,
  });

  bool enableAutoLargeScreen;
  ValueListenable<double>? dimAlpha;
  VoidCallback? onDismissFinished;

  @override
  bool get isDialog => true;

  void updateDialog({
    required bool enableAutoLargeScreen,
    required ValueListenable<double>? dimAlpha,
    required VoidCallback? onDismissFinished,
  }) {
    this.enableAutoLargeScreen = enableAutoLargeScreen;
    this.dimAlpha = dimAlpha;
    this.onDismissFinished = onDismissFinished;
    notifyListeners();
  }
}

/// 普通弹窗条目。
class MiuixPlainPopupEntry extends MiuixPopupEntry {
  MiuixPlainPopupEntry({
    required super.controller,
    required super.content,
    super.enterTransition,
    super.exitTransition,
    super.enableWindowDim,
    super.dimEnterTransition,
    super.dimExitTransition,
    this.enableBackHandler = true,
  });

  bool enableBackHandler;

  @override
  bool get isDialog => false;

  void updatePopup({required bool enableBackHandler}) {
    this.enableBackHandler = enableBackHandler;
    notifyListeners();
  }
}

/// 保存某一挂载层中的对话框与普通弹窗，并按注册顺序分配 z-order。
class MiuixPopupRegistry extends ChangeNotifier {
  MiuixPopupRegistry();

  /// 未安装 [MiuixPopupScope] 时使用的进程级后备注册表。
  static final MiuixPopupRegistry fallback = MiuixPopupRegistry();

  final List<MiuixDialogEntry> _dialogs = <MiuixDialogEntry>[];
  final List<MiuixPlainPopupEntry> _popups = <MiuixPlainPopupEntry>[];
  double _nextZIndex = 1;

  List<MiuixDialogEntry> get dialogs =>
      List<MiuixDialogEntry>.unmodifiable(_dialogs);
  List<MiuixPlainPopupEntry> get popups =>
      List<MiuixPlainPopupEntry>.unmodifiable(_popups);
  bool get isEmpty => _dialogs.isEmpty && _popups.isEmpty;

  bool contains(MiuixPopupEntry entry) =>
      entry is MiuixDialogEntry
          ? _dialogs.contains(entry)
          : _popups.contains(entry);

  void add(MiuixPopupEntry entry) {
    if (contains(entry)) return;
    entry.zIndex = _nextZIndex++;
    if (entry is MiuixDialogEntry) {
      _dialogs.add(entry);
    } else {
      _popups.add(entry as MiuixPlainPopupEntry);
    }
    entry.controller.addListener(_entryChanged);
    entry.addListener(_entryChanged);
    notifyListeners();
  }

  void remove(MiuixPopupEntry entry) {
    final bool removed = entry is MiuixDialogEntry
        ? _dialogs.remove(entry)
        : _popups.remove(entry);
    if (!removed) return;
    entry.controller.removeListener(_entryChanged);
    entry.removeListener(_entryChanged);
    if (isEmpty) _nextZIndex = 1;
    notifyListeners();
  }

  Iterable<MiuixPopupEntry> get entries sync* {
    yield* _dialogs;
    yield* _popups;
  }

  void _entryChanged() => notifyListeners();
}

/// 为子树提供 local/root 两级弹窗注册表。
///
/// 每个 Scope 都有自己的 local 注册表；嵌套 Scope 默认继承最外层 root。
/// [establishRoot] 可显式建立新的 root 边界。
class MiuixPopupScope extends StatefulWidget {
  const MiuixPopupScope({
    super.key,
    required this.child,
    this.registry,
    this.establishRoot = false,
  });

  final Widget child;
  final MiuixPopupRegistry? registry;
  final bool establishRoot;

  static MiuixPopupRegistry of(
    BuildContext context, {
    bool root = false,
  }) {
    final data = context
        .dependOnInheritedWidgetOfExactType<_MiuixPopupScopeData>();
    if (data == null) return MiuixPopupRegistry.fallback;
    return root ? data.rootRegistry : data.localRegistry;
  }

  static MiuixPopupRegistry? maybeOf(
    BuildContext context, {
    bool root = false,
  }) {
    final data = context
        .dependOnInheritedWidgetOfExactType<_MiuixPopupScopeData>();
    if (data == null) return null;
    return root ? data.rootRegistry : data.localRegistry;
  }

  @override
  State<MiuixPopupScope> createState() => _MiuixPopupScopeState();
}

class _MiuixPopupScopeState extends State<MiuixPopupScope> {
  late MiuixPopupRegistry _ownedRegistry;

  @override
  void initState() {
    super.initState();
    _ownedRegistry = MiuixPopupRegistry();
  }

  @override
  Widget build(BuildContext context) {
    final local = widget.registry ?? _ownedRegistry;
    final parent = context
        .dependOnInheritedWidgetOfExactType<_MiuixPopupScopeData>();
    final root = widget.establishRoot
        ? local
        : (parent?.rootRegistry ?? local);
    return _MiuixPopupScopeData(
      localRegistry: local,
      rootRegistry: root,
      child: widget.child,
    );
  }
}

class _MiuixPopupScopeData extends InheritedWidget {
  const _MiuixPopupScopeData({
    required this.localRegistry,
    required this.rootRegistry,
    required super.child,
  });

  final MiuixPopupRegistry localRegistry;
  final MiuixPopupRegistry rootRegistry;

  @override
  bool updateShouldNotify(_MiuixPopupScopeData oldWidget) {
    return localRegistry != oldWidget.localRegistry ||
        rootRegistry != oldWidget.rootRegistry;
  }
}

/// 在当前 Scope 中注册一个对话框；自身不绘制任何内容。
class MiuixDialogLayout extends StatefulWidget {
  const MiuixDialogLayout({
    super.key,
    required this.controller,
    required this.content,
    this.enterTransition,
    this.exitTransition,
    this.enableWindowDim = true,
    this.enableAutoLargeScreen = true,
    this.dimEnterTransition,
    this.dimExitTransition,
    this.dimAlpha,
    this.onDismissFinished,
    this.renderInRoot = true,
  });

  final MiuixPopupController controller;
  final WidgetBuilder? content;
  final MiuixPopupTransition? enterTransition;
  final MiuixPopupTransition? exitTransition;
  final bool enableWindowDim;
  final bool enableAutoLargeScreen;
  final MiuixPopupTransition? dimEnterTransition;
  final MiuixPopupTransition? dimExitTransition;
  final ValueListenable<double>? dimAlpha;
  final VoidCallback? onDismissFinished;
  final bool renderInRoot;

  @override
  State<MiuixDialogLayout> createState() => _MiuixDialogLayoutState();
}

class _MiuixDialogLayoutState extends State<MiuixDialogLayout> {
  late MiuixDialogEntry _entry;
  MiuixPopupRegistry? _registry;

  @override
  void initState() {
    super.initState();
    _entry = _createEntry();
    widget.controller.addListener(_visibilityChanged);
  }

  MiuixDialogEntry _createEntry() => MiuixDialogEntry(
    controller: widget.controller,
    content: widget.content ?? (_) => const SizedBox.shrink(),
    enterTransition: widget.enterTransition,
    exitTransition: widget.exitTransition,
    enableWindowDim: widget.enableWindowDim,
    dimEnterTransition: widget.dimEnterTransition,
    dimExitTransition: widget.dimExitTransition,
    enableAutoLargeScreen: widget.enableAutoLargeScreen,
    dimAlpha: widget.dimAlpha,
    onDismissFinished: widget.onDismissFinished,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _moveTo(MiuixPopupScope.of(context, root: widget.renderInRoot));
  }

  @override
  void didUpdateWidget(MiuixDialogLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_visibilityChanged);
      if (_registry?.contains(_entry) ?? false) _registry!.remove(_entry);
      _entry.dispose();
      _entry = _createEntry();
      widget.controller.addListener(_visibilityChanged);
    }
    _entry.updateBase(
      content: widget.content ?? (_) => const SizedBox.shrink(),
      enterTransition: widget.enterTransition,
      exitTransition: widget.exitTransition,
      enableWindowDim: widget.enableWindowDim,
      dimEnterTransition: widget.dimEnterTransition,
      dimExitTransition: widget.dimExitTransition,
    );
    _entry.updateDialog(
      enableAutoLargeScreen: widget.enableAutoLargeScreen,
      dimAlpha: widget.dimAlpha,
      onDismissFinished: widget.onDismissFinished,
    );
    if (widget.content == null && widget.controller.visible) {
      widget.controller.dismiss();
    }
    _moveTo(MiuixPopupScope.of(context, root: widget.renderInRoot));
  }

  void _moveTo(MiuixPopupRegistry registry) {
    if (identical(_registry, registry)) {
      if (widget.controller.visible && !registry.contains(_entry)) {
        registry.add(_entry);
      }
      return;
    }
    if (_registry?.contains(_entry) ?? false) _registry!.remove(_entry);
    _registry = registry;
    if (widget.content != null) registry.add(_entry);
  }

  void _visibilityChanged() {
    if (widget.controller.visible && widget.content != null) {
      _registry?.add(_entry);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_visibilityChanged);
    if (widget.controller.visible) widget.controller.dismiss();
    _entry.orphaned = true;
    if (!(_registry?.contains(_entry) ?? false)) _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// 在当前 Scope 中注册一个普通弹窗；自身不绘制任何内容。
class MiuixPopupLayout extends StatefulWidget {
  const MiuixPopupLayout({
    super.key,
    required this.controller,
    required this.content,
    this.enterTransition,
    this.exitTransition,
    this.enableWindowDim = true,
    this.enableBackHandler = true,
    this.dimEnterTransition,
    this.dimExitTransition,
    this.renderInRoot = true,
  });

  final MiuixPopupController controller;
  final WidgetBuilder? content;
  final MiuixPopupTransition? enterTransition;
  final MiuixPopupTransition? exitTransition;
  final bool enableWindowDim;
  final bool enableBackHandler;
  final MiuixPopupTransition? dimEnterTransition;
  final MiuixPopupTransition? dimExitTransition;
  final bool renderInRoot;

  @override
  State<MiuixPopupLayout> createState() => _MiuixPopupLayoutState();
}

class _MiuixPopupLayoutState extends State<MiuixPopupLayout> {
  late MiuixPlainPopupEntry _entry;
  MiuixPopupRegistry? _registry;

  @override
  void initState() {
    super.initState();
    _entry = _createEntry();
    widget.controller.addListener(_visibilityChanged);
  }

  MiuixPlainPopupEntry _createEntry() => MiuixPlainPopupEntry(
    controller: widget.controller,
    content: widget.content ?? (_) => const SizedBox.shrink(),
    enterTransition: widget.enterTransition,
    exitTransition: widget.exitTransition,
    enableWindowDim: widget.enableWindowDim,
    dimEnterTransition: widget.dimEnterTransition,
    dimExitTransition: widget.dimExitTransition,
    enableBackHandler: widget.enableBackHandler,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _moveTo(MiuixPopupScope.of(context, root: widget.renderInRoot));
  }

  @override
  void didUpdateWidget(MiuixPopupLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_visibilityChanged);
      if (_registry?.contains(_entry) ?? false) _registry!.remove(_entry);
      _entry.dispose();
      _entry = _createEntry();
      widget.controller.addListener(_visibilityChanged);
    }
    _entry.updateBase(
      content: widget.content ?? (_) => const SizedBox.shrink(),
      enterTransition: widget.enterTransition,
      exitTransition: widget.exitTransition,
      enableWindowDim: widget.enableWindowDim,
      dimEnterTransition: widget.dimEnterTransition,
      dimExitTransition: widget.dimExitTransition,
    );
    _entry.updatePopup(enableBackHandler: widget.enableBackHandler);
    if (widget.content == null && widget.controller.visible) {
      widget.controller.dismiss();
    }
    _moveTo(MiuixPopupScope.of(context, root: widget.renderInRoot));
  }

  void _moveTo(MiuixPopupRegistry registry) {
    if (identical(_registry, registry)) {
      if (widget.controller.visible && !registry.contains(_entry)) {
        registry.add(_entry);
      }
      return;
    }
    if (_registry?.contains(_entry) ?? false) _registry!.remove(_entry);
    _registry = registry;
    if (widget.content != null) registry.add(_entry);
  }

  void _visibilityChanged() {
    if (widget.controller.visible && widget.content != null) {
      _registry?.add(_entry);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_visibilityChanged);
    if (widget.controller.visible) widget.controller.dismiss();
    _entry.orphaned = true;
    if (!(_registry?.contains(_entry) ?? false)) _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// 绘制注册表中的所有条目，拦截下层指针，并处理最上层普通弹窗的返回键。
///
/// [child] 非空时 Host 可直接作为应用根部的 Stack 包装器；在 Scaffold 的最高层使用时
/// 可省略 [child]。默认遮罩颜色与 Miuix 浅色 `windowDimming` 一致。
class MiuixPopupHost extends StatefulWidget {
  const MiuixPopupHost({
    super.key,
    this.child,
    this.registry,
    this.windowDimmingColor = const Color(0x4D000000),
  });

  final Widget? child;
  final MiuixPopupRegistry? registry;
  final Color windowDimmingColor;

  @override
  State<MiuixPopupHost> createState() => _MiuixPopupHostState();
}

class _MiuixPopupHostState extends State<MiuixPopupHost> {
  MiuixPopupRegistry? _registry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attach(widget.registry ?? MiuixPopupScope.of(context));
  }

  @override
  void didUpdateWidget(MiuixPopupHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attach(widget.registry ?? MiuixPopupScope.of(context));
  }

  void _attach(MiuixPopupRegistry registry) {
    if (identical(_registry, registry)) return;
    _registry?.removeListener(_changed);
    _registry = registry..addListener(_changed);
  }

  void _changed() {
    if (!mounted) return;
    // registry 的 add/remove/_entryChanged 经常在子树（如 MiuixDialogLayout）
    // 的 didUpdateWidget / didChangeDependencies 中被同步触发，此时本 widget
    // 可能正处于 build 阶段。直接 setState 会抛 "setState during build"。
    // build 阶段延后到帧末执行，其它阶段立即执行。
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  MiuixPlainPopupEntry? get _topBackPopup {
    final candidates = _registry?.popups.where(
      (entry) => entry.enableBackHandler && entry.controller.visible,
    );
    if (candidates == null || candidates.isEmpty) return null;
    return candidates.reduce((a, b) => a.zIndex > b.zIndex ? a : b);
  }

  @override
  void dispose() {
    _registry?.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registry = _registry ?? MiuixPopupRegistry.fallback;
    final entries = registry.entries.toList()
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    final topBackPopup = _topBackPopup;

    return PopScope<Object?>(
      canPop: topBackPopup == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _topBackPopup?.controller.dismiss();
      },
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (widget.child != null) widget.child!,
          for (final entry in entries)
            Positioned.fill(
              key: ObjectKey(entry),
              child: _MiuixHostedEntry(
                entry: entry,
                registry: registry,
                windowDimmingColor: widget.windowDimmingColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _MiuixHostedEntry extends StatefulWidget {
  const _MiuixHostedEntry({
    required this.entry,
    required this.registry,
    required this.windowDimmingColor,
  });

  final MiuixPopupEntry entry;
  final MiuixPopupRegistry registry;
  final Color windowDimmingColor;

  @override
  State<_MiuixHostedEntry> createState() => _MiuixHostedEntryState();
}

class _MiuixHostedEntryState extends State<_MiuixHostedEntry>
    with TickerProviderStateMixin {
  late AnimationController _contentController;
  late AnimationController _dimController;
  bool _pendingOpen = false;
  bool _lastTarget = false;
  bool _contentDismissed = true;
  bool _dimDismissed = true;
  bool _removalScheduled = false;
  bool _needsInitialOpen = false;
  // 本 State 的 element 是否处于 deactivated（已从树上摘下但尚未 unmount）。
  // 共享的 controller 可能在别处（如 MiuixDialogLayout.dispose 里 dismiss()）
  // 于本 element deactivated 期间同步 notifyListeners，此时 mounted 仍为 true，
  // 但任何 inherited 查找（MediaQuery.of 等）都会抛 "deactivated ancestor" 断言。
  bool _deactivated = false;

  @override
  void activate() {
    super.activate();
    _deactivated = false;
  }

  @override
  void deactivate() {
    _deactivated = true;
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController.unbounded(vsync: this)
      ..addStatusListener(_contentStatus);
    _dimController = AnimationController.unbounded(vsync: this)
      ..addStatusListener(_dimStatus);
    widget.entry.controller.addListener(_visibilityChanged);
    widget.entry.addListener(_entryChanged);
    _lastTarget = widget.entry.controller.visible;
    // 不能在这里直接 _open()：_open() → _animateIn → _enterTransition 会调用
    // isMiuixLargeScreen(context) 读取 inherited widget，而 initState 阶段
    // context 尚未就绪，会抛 "dependOnInheritedWidgetOfExactType() called
    // before initState() completed"。延后到 didChangeDependencies 执行。
    _needsInitialOpen = _lastTarget;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_needsInitialOpen) {
      _needsInitialOpen = false;
      _open();
    }
  }

  @override
  void didUpdateWidget(_MiuixHostedEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry != widget.entry) {
      oldWidget.entry.controller.removeListener(_visibilityChanged);
      oldWidget.entry.removeListener(_entryChanged);
      widget.entry.controller.addListener(_visibilityChanged);
      widget.entry.addListener(_entryChanged);
      _lastTarget = widget.entry.controller.visible;
    }
  }

  void _entryChanged() {
    _safeSetState();
  }

  void _visibilityChanged() {
    // element 已摘下（整体销毁中，如 MiuixDialogLayout.dispose 里 dismiss()）：
    // 跳过全部动画与 inherited 查找——_close() → _exitTransition 会读
    // MediaQuery，deactivated 期间必抛 "deactivated ancestor" 断言。
    if (_deactivated || !mounted) {
      _lastTarget = widget.entry.controller.visible;
      return;
    }
    final newTarget = widget.entry.controller.visible;
    if (newTarget) {
      if ((_contentController.isAnimating || _dimController.isAnimating) &&
          !_lastTarget) {
        _pendingOpen = true;
      } else {
        _open();
      }
    } else {
      _pendingOpen = false;
      // 收起键盘只是锦上添花；element 已 deactivated 时读 context 会抛断言，
      // 跳过即可（此时通常正在整体销毁，键盘处理已无意义）。
      if (!_deactivated &&
          mounted &&
          widget.entry is MiuixDialogEntry &&
          (MediaQuery.maybeOf(context)?.viewInsets.bottom ?? 0) > 0) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      _close();
    }
    _lastTarget = newTarget;
    _safeSetState();
  }

  /// 安全地触发重建。controller/entry 的 notifyListeners 经常在子树
  /// （MiuixOverlayDialog / MiuixDialogLayout）的 didUpdateWidget 中被同步
  /// 触发，此时本 widget 处于 build 阶段，直接 setState 会抛异常。
  /// build 阶段延后到帧末执行，其它阶段立即执行避免动画延迟。
  void _safeSetState() {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  MiuixPopupTransition get _enterTransition {
    final custom = widget.entry.enterTransition;
    if (custom != null) return custom;
    if (widget.entry is MiuixDialogEntry) {
      final dialog = widget.entry as MiuixDialogEntry;
      return isMiuixLargeScreen(context) && dialog.enableAutoLargeScreen
          ? MiuixPopupDefaults.largeDialogEnter
          : MiuixPopupDefaults.smallDialogEnter;
    }
    return MiuixPopupDefaults.popupEnter;
  }

  MiuixPopupTransition get _exitTransition {
    final custom = widget.entry.exitTransition;
    if (custom != null) return custom;
    if (widget.entry is MiuixDialogEntry) {
      final dialog = widget.entry as MiuixDialogEntry;
      return isMiuixLargeScreen(context) && dialog.enableAutoLargeScreen
          ? MiuixPopupDefaults.largeDialogExit
          : MiuixPopupDefaults.smallDialogExit;
    }
    return MiuixPopupDefaults.popupExit;
  }

  MiuixPopupTransition get _dimEnterTransition =>
      widget.entry.dimEnterTransition ??
      (widget.entry.isDialog
          ? MiuixPopupDefaults.dialogDimEnter
          : MiuixPopupDefaults.popupDimEnter);

  MiuixPopupTransition get _dimExitTransition =>
      widget.entry.dimExitTransition ??
      (widget.entry.isDialog
          ? MiuixPopupDefaults.dialogDimExit
          : MiuixPopupDefaults.popupDimExit);

  void _open() {
    _removalScheduled = false;
    _contentDismissed = false;
    _dimDismissed = false;
    _animateIn(_contentController, _enterTransition);
    _animateIn(_dimController, _dimEnterTransition);
  }

  void _close() {
    _animateOut(_contentController, _exitTransition);
    _animateOut(_dimController, _dimExitTransition);
  }

  void _animateIn(
    AnimationController controller,
    MiuixPopupTransition transition,
  ) {
    final spring = transition.spring;
    if (spring != null) {
      controller.animateWith(
        SpringSimulation(
          spring,
          controller.value,
          1,
          controller.velocity,
          tolerance: Tolerance(
            distance: transition.visibilityThreshold,
            velocity: transition.visibilityThreshold,
          ),
        ),
      );
    } else {
      controller.animateTo(
        1,
        duration: transition.duration,
        curve: transition.curve,
      );
    }
  }

  void _animateOut(
    AnimationController controller,
    MiuixPopupTransition transition,
  ) {
    // 必须用 animateBack 而不是 animateTo：animateTo 内部会把 _direction
    // 置为 forward，动画结束时 _tick 会把 status 设成 completed 而非 dismissed，
    // 导致 _contentStatus/_dimStatus（只监听 dismissed）永不触发，entry 永不
    // 从 registry 移除，blocker 永久拦截指针事件。
    controller.animateBack(
      0,
      duration: transition.duration,
      curve: transition.curve,
    );
  }

  void _contentStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _contentDismissed = true;
      _settledHidden();
      if (mounted) setState(() {});
    }
  }

  void _dimStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _dimDismissed = true;
      _settledHidden();
      if (mounted) setState(() {});
    }
  }

  void _settledHidden() {
    if (!_contentDismissed || !_dimDismissed) return;
    if (_pendingOpen && widget.entry.controller.visible) {
      _pendingOpen = false;
      _open();
      return;
    }
    if (widget.entry.controller.visible || _removalScheduled) return;
    _removalScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.entry.controller.visible) return;
      if (widget.entry is MiuixDialogEntry) {
        (widget.entry as MiuixDialogEntry).onDismissFinished?.call();
      }
      widget.registry.remove(widget.entry);
    });
  }

  @override
  void dispose() {
    widget.entry.controller.removeListener(_visibilityChanged);
    widget.entry.removeListener(_entryChanged);
    _contentController
      ..removeStatusListener(_contentStatus)
      ..dispose();
    _dimController
      ..removeStatusListener(_dimStatus)
      ..dispose();
    // 仅当宿主（MiuixDialogLayout/MiuixPopupLayout）已 dispose、把 entry 标记为
    // orphaned 时才由 HostedEntry 接管 dispose。否则 entry 仍归宿主所有，宿主可能
    // 再次 show 对话框并复用该 entry。
    if (widget.entry.orphaned &&
        !widget.registry.contains(widget.entry)) {
      widget.entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    // 当弹窗完全隐藏（内容与遮罩动画均已结束且控制器不可见）时不渲染任何内容。
    // 否则下层 [Listener]（behavior: opaque）即使在 [FadeTransition] 透明度为 0
    // 时仍会命中拦截指针事件——[RenderAnimatedOpacity] 未重写 hitTest，导致
    // 初始 show=false 的对话框注册后立刻冻结整页交互。
    if (_contentDismissed &&
        _dimDismissed &&
        !entry.controller.visible &&
        !_pendingOpen) {
      return const SizedBox.shrink();
    }
    final blocker = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {},
      onPointerMove: (_) {},
      onPointerUp: (_) {},
      onPointerCancel: (_) {},
      child: entry.enableWindowDim
          ? _DimLayer(
              entry: entry,
              color: widget.windowDimmingColor,
            )
          : const SizedBox.expand(),
    );

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        _dimEnterTransition.build(context, _dimController, blocker),
        _enterTransition.build(
          context,
          _contentController,
          // 包一层 Material 提供 DefaultTextStyle / TextTheme，避免内容里的
          // MiuixText、MiuixTextButton 等因找不到 Material 祖先而出现黄色下划线。
          // 用 transparency 类型不引入额外背景色，对话框自身的背景由内容负责。
          SizedBox.expand(
            child: Material(
              type: MaterialType.transparency,
              child: Builder(builder: entry.content),
            ),
          ),
        ),
      ],
    );
  }
}

class _DimLayer extends StatelessWidget {
  const _DimLayer({required this.entry, required this.color});

  final MiuixPopupEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (entry case MiuixDialogEntry(dimAlpha: final alpha?)) {
      return ValueListenableBuilder<double>(
        valueListenable: alpha,
        builder: (context, value, child) {
          final factor = value.clamp(0.0, 1.0);
          final effectiveAlpha = (color.a * factor * 255).round().clamp(0, 255);
          return ColoredBox(color: color.withAlpha(effectiveAlpha));
        },
      );
    }
    return ColoredBox(color: color);
  }
}

class _ClampedAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  _ClampedAnimation(this.parent);

  @override
  final Animation<double> parent;

  @override
  double get value => parent.value.clamp(0.0, 1.0);
}

class _SinOutCurve extends Curve {
  const _SinOutCurve();

  @override
  double transformInternal(double t) {
    return sin(t * 1.5707963267948966);
  }
}

/// 判断当前逻辑窗口是否满足 Miuix 大屏阈值：宽至少 840、高至少 480。
bool isMiuixLargeScreen(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return size.width >= 840 && size.height >= 480;
}

/// 与 Kotlin 静态工具类一致的便捷入口。
class MiuixPopupUtils {
  MiuixPopupUtils._();

  static Widget dialogLayout({
    Key? key,
    required MiuixPopupController controller,
    required WidgetBuilder? content,
    MiuixPopupTransition? enterTransition,
    MiuixPopupTransition? exitTransition,
    bool enableWindowDim = true,
    bool enableAutoLargeScreen = true,
    MiuixPopupTransition? dimEnterTransition,
    MiuixPopupTransition? dimExitTransition,
    ValueListenable<double>? dimAlpha,
    VoidCallback? onDismissFinished,
    bool renderInRoot = true,
  }) {
    return MiuixDialogLayout(
      key: key,
      controller: controller,
      content: content,
      enterTransition: enterTransition,
      exitTransition: exitTransition,
      enableWindowDim: enableWindowDim,
      enableAutoLargeScreen: enableAutoLargeScreen,
      dimEnterTransition: dimEnterTransition,
      dimExitTransition: dimExitTransition,
      dimAlpha: dimAlpha,
      onDismissFinished: onDismissFinished,
      renderInRoot: renderInRoot,
    );
  }

  static Widget popupLayout({
    Key? key,
    required MiuixPopupController controller,
    required WidgetBuilder? content,
    MiuixPopupTransition? enterTransition,
    MiuixPopupTransition? exitTransition,
    bool enableWindowDim = true,
    bool enableBackHandler = true,
    MiuixPopupTransition? dimEnterTransition,
    MiuixPopupTransition? dimExitTransition,
    bool renderInRoot = true,
  }) {
    return MiuixPopupLayout(
      key: key,
      controller: controller,
      content: content,
      enterTransition: enterTransition,
      exitTransition: exitTransition,
      enableWindowDim: enableWindowDim,
      enableBackHandler: enableBackHandler,
      dimEnterTransition: dimEnterTransition,
      dimExitTransition: dimExitTransition,
      renderInRoot: renderInRoot,
    );
  }
}
