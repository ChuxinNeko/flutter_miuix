// Miuix Flutter 移植版 - TopAppBar
// 源自 compose-miuix-ui/miuix 的 TopAppBar.kt。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../theme/miuix_motion.dart';
import '../theme/miuix_theme.dart';
import 'miuix_text.dart';

/// TopAppBar 默认值。对应 Kotlin `TopAppBarDefaults`。
class MiuixTopAppBarDefaults {
  MiuixTopAppBarDefaults._();

  /// 标题水平内边距。
  static const double titlePadding = 26;

  /// 导航图标的起始内边距。
  static const double navigationIconPadding = 16;

  /// 操作图标的末端内边距。
  static const double actionIconPadding = 16;

  /// 折叠状态下 TopAppBar 的高度。
  static const double collapsedHeight = 52;

  /// SmallTopAppBar 的垂直中心高度。
  static const double smallTopAppBarCenterHeight = 50;

  /// 无副标题时大标题的底部内边距。
  static const double largeTitleBottomPadding = 4;

  /// 副标题的底部内边距。
  static const double subtitleBottomPadding = 8;

  /// 居中标题与导航/操作之间的横向余量比例。
  static const double titleWidthFraction = 0.9;
}

/// TopAppBar 的状态。对应 Kotlin `TopAppBarState`。
///
/// 持有折叠偏移量、内容滚动偏移量等，并通过 [notifyListeners] 通知监听者。
/// 通常由 [MiuixScrollBehavior] 持有并更新，由 [MiuixTopAppBar] 读取。
class MiuixTopAppBarState extends ChangeNotifier {
  MiuixTopAppBarState({
    double initialHeightOffsetLimit = double.negativeInfinity,
    double initialHeightOffset = 0,
    double initialContentOffset = 0,
  })  : _heightOffsetLimit = initialHeightOffsetLimit,
        _heightOffset = initialHeightOffset,
        _contentOffset = initialContentOffset;

  double _heightOffsetLimit;
  double _heightOffset;
  double _contentOffset;

  /// 折叠高度上限（负数，表示允许的最大折叠像素数）。
  double get heightOffsetLimit => _heightOffsetLimit;

  set heightOffsetLimit(double value) {
    if (_heightOffsetLimit == value) return;
    _heightOffsetLimit = value;
    notifyListeners();
  }

  /// 当前折叠偏移量，被夹在 [heightOffsetLimit] 与 0 之间。
  double get heightOffset => _heightOffset;

  set heightOffset(double value) {
    final clamped = value.clamp(_heightOffsetLimit, 0.0);
    if (_heightOffset == clamped) return;
    _heightOffset = clamped;
    notifyListeners();
  }

  /// TopAppBar 下方内容的累计滚动偏移量。
  double get contentOffset => _contentOffset;

  set contentOffset(double value) {
    if (_contentOffset == value) return;
    _contentOffset = value;
    notifyListeners();
  }

  /// 折叠百分比。`0.0` 完全展开，`1.0` 完全折叠。
  double get collapsedFraction {
    if (_heightOffsetLimit == 0 || _heightOffsetLimit.isInfinite) return 0;
    return (_heightOffset / _heightOffsetLimit).clamp(0.0, 1.0);
  }

  /// 内容与 TopAppBar 的重叠百分比。
  double get overlappedFraction {
    if (_heightOffsetLimit == 0 || _heightOffsetLimit.isInfinite) return 0;
    final v = 1 -
        (_heightOffsetLimit - _contentOffset)
                .clamp(_heightOffsetLimit, 0.0) /
            _heightOffsetLimit;
    return v.clamp(0.0, 1.0);
  }
}

/// 滚动行为抽象。对应 Kotlin `ScrollBehavior`。
abstract class MiuixScrollBehavior {
  MiuixTopAppBarState get state;

  /// 是否固定（不随滚动收起）。
  bool get isPinned;
}

/// "折叠到顶部为止"的滚动行为。对应 Kotlin `ExitUntilCollapsedScrollBehavior`。
///
/// 上滑时优先折叠 TopAppBar，完全折叠后才让下方内容滚动；
/// 下滑时优先展开 TopAppBar。
///
/// 用法：
/// ```dart
/// final behavior = miuixScrollBehavior();
/// MiuixScrollBehaviorListener(
///   behavior: behavior,
///   child: ListView(...),
/// );
/// MiuixTopAppBar(title: 'Title', scrollBehavior: behavior);
/// ```
class MiuixExitUntilCollapsedScrollBehavior
    implements MiuixScrollBehavior {
  MiuixExitUntilCollapsedScrollBehavior({
    MiuixTopAppBarState? state,
    this.canScroll,
  }) : state = state ?? MiuixTopAppBarState();

  @override
  final MiuixTopAppBarState state;

  /// 是否处理滚动事件。
  final bool Function()? canScroll;

  @override
  bool get isPinned => false;

  AnimationController? _snapController;

  void _attachVsync(TickerProvider vsync) {
    _snapController ??= AnimationController.unbounded(vsync: vsync);
    _snapController!.addListener(_driveSnap);
  }

  void _detachVsync() {
    _snapController?.removeListener(_driveSnap);
    _snapController?.dispose();
    _snapController = null;
  }

  void _driveSnap() {
    if (_snapController != null) {
      state.heightOffset = _snapController!.value;
    }
  }

  bool handleScroll(ScrollNotification n) {
    if (canScroll != null && !canScroll!()) return false;
    // 只响应直接子滚动体的竖向滚动：页面内嵌套的横向/内层列表（depth > 0）
    // 不得驱动顶栏折叠，否则横滑一个内嵌列表也会牵动大标题。
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    if (n is ScrollStartNotification) {
      // 新滚动手势开始：停掉上一次松手的吸附动画。否则残留动画会与手势
      // 输入争抢 heightOffset——例如折叠到底后，被上一次"吸附回展开"的
      // 动画重新拉开。
      _snapController?.stop();
    } else if (n is ScrollUpdateNotification) {
      final delta = n.scrollDelta ?? 0.0;
      if (delta == 0) return false;
      _applyGatedDelta(n.metrics, delta);
    } else if (n is OverscrollNotification) {
      // Android ClampingScrollPhysics 到顶后不再发 ScrollUpdate（delta 被物理层
      // 钳成 0），顶部继续下拉只会发 overscroll<0 的 OverscrollNotification。
      // 这正对应 Kotlin onPostScroll 里"内容到顶后的剩余下滑量"——用它驱动展开，
      // clamping 物理下大标题才能重新展开。
      if (n.overscroll < 0 && n.metrics.pixels <= n.metrics.minScrollExtent) {
        state.heightOffset = state.heightOffset - n.overscroll;
      }
    } else if (n is ScrollEndNotification) {
      _scheduleSnap();
    }
    return false;
  }

  /// 把滚动增量映射为顶栏折叠增量——仅统计发生在顶部过渡区间内的行程。
  ///
  /// 对应 Kotlin `ExitUntilCollapsedScrollBehavior` 的语义：上滑折叠，下滑仅在
  /// 内容回到顶部后展开。Flutter 的 NotificationListener 拿不到 Compose
  /// nestedScroll 的"消费/剩余"信息，等价改写为按内容位置门控：
  ///
  /// - 过渡区间 = [minScrollExtent, minScrollExtent + 展开量]；
  /// - 上滑（delta > 0）：只统计 minScrollExtent 以上的行程（忽略 iOS 回弹
  ///   归位段），不设上界——吸附展开后在列表中部继续上滑仍可折叠；
  /// - 下滑（delta < 0）：只统计过渡区上界以下的行程——列表中部下滑门控量
  ///   恒为 0，大标题保持折叠；滚回顶部区间才逐像素展开（含 iOS 弹性下拉
  ///   越过顶部的负偏移段）。
  ///
  /// Flutter 的 scrollDelta 与 Compose 的 available.y 符号相反：
  /// delta > 0 为上滑（pixels 增加），应折叠（heightOffset → 负）。
  void _applyGatedDelta(ScrollMetrics metrics, double delta) {
    final minExtent = metrics.minScrollExtent;
    final after = metrics.pixels; // 通知携带的是本次滚动后的位置。
    final before = after - delta;
    final limit = state.heightOffsetLimit;
    // 展开量未测出（limit 仍为 -∞）时无从门控，退回全量累加。
    final zoneTop = limit.isFinite ? minExtent - limit : double.infinity;

    final double gated;
    if (delta > 0) {
      gated = math.max(after, minExtent) - math.max(before, minExtent);
    } else {
      gated = math.min(after, zoneTop) - math.min(before, zoneTop);
    }
    if (gated != 0) {
      state.heightOffset = state.heightOffset - gated;
    }
    // contentOffset 只在 TopAppBar 处于折叠/折叠中时累积；
    // 完全展开后继续下滑不再增加正偏移（对齐 Kotlin onPostFling 的 contentOffset=0 重置语义）。
    if (state.heightOffset < 0) {
      state.contentOffset = state.contentOffset - delta;
    } else {
      state.contentOffset = 0;
    }
  }

  void _scheduleSnap() {
    final controller = _snapController;
    if (controller == null) return;
    final offset = state.heightOffset;
    if (offset == 0 || offset == state.heightOffsetLimit) return;
    final fraction = state.collapsedFraction;
    final target = fraction < 0.5 ? 0.0 : state.heightOffsetLimit;
    final spring = folmeSpring(damping: 1.0, response: 0.3);
    controller.animateWith(
      _SpringSimulation(spring, offset, target),
    );
  }
}

/// 用于驱动 [MiuixTopAppBarState.heightOffset] 的弹簧模拟。
class _SpringSimulation extends Simulation {
  _SpringSimulation(this.desc, double start, double end)
      : _sim = SpringSimulation(desc, start, end, 0);

  final SpringDescription desc;
  final SpringSimulation _sim;

  @override
  double x(double time) => _sim.x(time);

  @override
  double dx(double time) => _sim.dx(time);

  @override
  bool isDone(double time) => _sim.isDone(time);
}

/// 把滚动事件桥接到 [MiuixExitUntilCollapsedScrollBehavior] 的监听器。
///
/// 包裹任意可滚动组件，自动处理折叠/展开以及手势结束后的吸附动画。
class MiuixScrollBehaviorListener extends StatefulWidget {
  const MiuixScrollBehaviorListener({
    super.key,
    required this.behavior,
    required this.child,
  });

  final MiuixExitUntilCollapsedScrollBehavior behavior;
  final Widget child;

  @override
  State<MiuixScrollBehaviorListener> createState() =>
      _MiuixScrollBehaviorListenerState();
}

class _MiuixScrollBehaviorListenerState
    extends State<MiuixScrollBehaviorListener> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.behavior._attachVsync(this);
  }

  @override
  void didUpdateWidget(covariant MiuixScrollBehaviorListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.behavior != widget.behavior) {
      oldWidget.behavior._detachVsync();
      widget.behavior._attachVsync(this);
    }
  }

  @override
  void dispose() {
    widget.behavior._detachVsync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: widget.behavior.handleScroll,
      child: widget.child,
    );
  }
}

/// 创建一个默认的 [MiuixExitUntilCollapsedScrollBehavior]。
MiuixExitUntilCollapsedScrollBehavior miuixScrollBehavior({
  MiuixTopAppBarState? state,
  bool Function()? canScroll,
}) {
  return MiuixExitUntilCollapsedScrollBehavior(
    state: state,
    canScroll: canScroll,
  );
}

/// 大标题可折叠的 TopAppBar。对应 Kotlin `TopAppBar`。
///
/// 必须配合 [MiuixScrollBehavior] 使用才能实现折叠/展开。
/// 不传入 [scrollBehavior] 时表现为静态展开状态。
class MiuixTopAppBar extends StatefulWidget {
  const MiuixTopAppBar({
    super.key,
    required this.title,
    this.color,
    this.titleColor,
    this.largeTitle,
    this.largeTitleColor,
    this.subtitle = '',
    this.subtitleColor,
    this.navigationIcon,
    this.actions,
    this.scrollBehavior,
    this.defaultWindowInsetsPadding = true,
    this.titlePadding = MiuixTopAppBarDefaults.titlePadding,
    this.navigationIconPadding = MiuixTopAppBarDefaults.navigationIconPadding,
    this.actionIconPadding = MiuixTopAppBarDefaults.actionIconPadding,
    this.bottomContent,
    this.blurred = false,
    this.blurRadius = 24,
    this.blurTintAlpha = 0.55,
  });

  final String title;

  /// 背景色。默认 `MiuixTheme.colors.surface`。
  final Color? color;

  /// 折叠后小标题颜色。
  final Color? titleColor;

  /// 大标题，默认与 [title] 相同。
  final String? largeTitle;

  /// 大标题颜色。
  final Color? largeTitleColor;

  /// 副标题（展开时显示在大标题下方，折叠时显示在小标题下方）。
  final String subtitle;

  /// 副标题颜色。
  final Color? subtitleColor;

  /// 导航图标（leading）。
  final Widget? navigationIcon;

  /// 操作图标（trailing）。
  final List<Widget>? actions;

  /// 控制折叠/展开的滚动行为。
  final MiuixScrollBehavior? scrollBehavior;

  /// 是否应用默认窗口内边距。
  final bool defaultWindowInsetsPadding;

  /// 标题水平内边距。
  final double titlePadding;

  /// 导航图标起始内边距。
  final double navigationIconPadding;

  /// 操作图标末端内边距。
  final double actionIconPadding;

  /// 标题区域下方的附加内容。
  final Widget? bottomContent;

  /// 是否启用毛玻璃背景（增强，非原版行为）。为 true 时顶栏背景变为对**身后已绘制内容**
  /// （通常是滚动到栏下方的 body）的实时高斯模糊 + 半透明色调，实现"内容透过顶栏虚化"。
  ///
  /// 用 [BackdropFilter] 实现，无需额外捕获——只要顶栏在可滚动内容**之上**绘制即可
  /// （MiuixScaffold 的 topBar 正是画在 body 之上）。为 false 时保持原版纯色背景。
  final bool blurred;

  /// 毛玻璃模糊半径（dp）。仅 [blurred] 为 true 时生效。
  final double blurRadius;

  /// 毛玻璃上叠加的背景色调不透明度 [0,1]。仅 [blurred] 为 true 时生效。
  /// 太高会盖住模糊、太低对比不足；默认 0.55。
  final double blurTintAlpha;

  @override
  State<MiuixTopAppBar> createState() => _MiuixTopAppBarState();
}

class _MiuixTopAppBarState extends State<MiuixTopAppBar> {
  // 用于测量大标题真实尺寸（决定 expansion / heightOffsetLimit）。
  // 大标题/副标题/导航/操作/bottomContent 尺寸用 Offstage 测量；
  // 主标题文字尺寸改由 TextPainter 在 build 中动态测量（字号随 fraction 连续插值）。
  final GlobalKey _largeTitleKey = GlobalKey();
  final GlobalKey _navigationIconKey = GlobalKey();
  final GlobalKey _actionsKey = GlobalKey();
  final GlobalKey _subtitleKey = GlobalKey();
  final GlobalKey _bottomContentKey = GlobalKey();

  Size? _largeTitleSize;
  Size? _navigationIconSize;
  Size? _actionsSize;
  Size? _subtitleSize;
  Size? _bottomContentSize;
  bool _measured = false;

  // 主标题纯文字尺寸缓存（不随 fraction 变化，仅在 widget.title 变化时重算）。
  // 避免每帧创建 TextPainter 做文字 shaping（昂贵），解决滚动掉帧。
  String? _measuredTitle;
  double _largeTitleTextHeight = 0;
  double _smallTitleTextHeight = 0;
  double _smallTitleTextWidth = 0;

  @override
  void didUpdateWidget(covariant MiuixTopAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 文字/图标内容变化时尺寸需重测。
    if (oldWidget.title != widget.title ||
        oldWidget.subtitle != widget.subtitle ||
        oldWidget.largeTitle != widget.largeTitle ||
        oldWidget.navigationIcon != widget.navigationIcon ||
        oldWidget.actions != widget.actions ||
        oldWidget.bottomContent != widget.bottomContent) {
      _measured = false;
    }
  }

  void _scheduleMeasure() {
    if (_measured) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      void measure(GlobalKey k, Size? current, ValueSetter<Size> setter) {
        final ctx = k.currentContext;
        if (ctx == null) return;
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize && box.size != current) {
          setter(box.size);
        }
      }

      measure(_largeTitleKey, _largeTitleSize, (s) => _largeTitleSize = s);
      measure(_navigationIconKey, _navigationIconSize,
          (s) => _navigationIconSize = s);
      measure(_actionsKey, _actionsSize, (s) => _actionsSize = s);
      measure(_subtitleKey, _subtitleSize, (s) => _subtitleSize = s);
      measure(_bottomContentKey, _bottomContentSize,
          (s) => _bottomContentSize = s);
      if (mounted) {
        _measured = true;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final colors = theme.colors;
    final bgColor = widget.color ?? colors.surface;
    final titleColor = widget.titleColor ?? colors.onSurface;
    final largeTitleColor = widget.largeTitleColor ?? colors.onSurface;
    final subtitleColor =
        widget.subtitleColor ?? colors.onSurfaceVariantSummary;

    final behavior = widget.scrollBehavior;
    final largeTitleText = widget.largeTitle ?? widget.title;
    final hasSubtitle = widget.subtitle.isNotEmpty;
    final collapsedHeight = MiuixTopAppBarDefaults.collapsedHeight;

    // 大标题尺寸（包含 subtitle，来自 Offstage 测量），用于计算 expansion 与
    // heightOffsetLimit。渲染层不再用此尺寸，改用 TextPainter 测量纯文字高度。
    final largeTitleHeight = _largeTitleSize?.height ?? 0;
    final expansion = largeTitleHeight.clamp(0.0, double.infinity);

    // 主标题的"大字号"与"小字号"样式（不随 fraction 变化，定义在 builder 外避免每帧重建）。
    final largeTitleStyle = theme.textStyles.title1.copyWith(
      color: largeTitleColor,
      fontWeight: FontWeight.normal,
    );
    final smallTitleStyle = theme.textStyles.title3.copyWith(
      color: titleColor,
      fontWeight: FontWeight.w500,
    );

    // 测量并缓存大/小字号下的文字尺寸：只在 widget.title 变化时重算，
    // 滚动时不创建任何 TextPainter（文字 shaping 昂贵，每帧调用会掉帧）。
    if (_measuredTitle != widget.title) {
      _measuredTitle = widget.title;
      final largeTp = TextPainter(
        text: TextSpan(text: widget.title, style: largeTitleStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: double.infinity);
      _largeTitleTextHeight = largeTp.height;
      largeTp.dispose();
      final smallTp = TextPainter(
        text: TextSpan(text: widget.title, style: smallTitleStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: double.infinity);
      _smallTitleTextHeight = smallTp.height;
      _smallTitleTextWidth = smallTp.width;
      smallTp.dispose();
    }

    final verticalCenter = collapsedHeight / 2;

    // 副标题高度（用于 contentTop 计算）。
    final smallSubtitleHeight =
        hasSubtitle ? (_subtitleSize?.height ?? 0.0) : 0.0;
    final expandedBottomPadding = hasSubtitle
        ? MiuixTopAppBarDefaults.subtitleBottomPadding
        : MiuixTopAppBarDefaults.largeTitleBottomPadding;
    final bottomContentHeight = _bottomContentSize?.height ?? 0.0;

    _scheduleMeasure();

    final mediaQuery = MediaQuery.of(context);
    final horizontalPadding = widget.defaultWindowInsetsPadding
        ? mediaQuery.padding.horizontal
        : 0.0;

    final navWidth = _navigationIconSize?.width ?? 0.0;
    final navHeight = _navigationIconSize?.height ?? 0.0;
    final actionsWidth = _actionsSize?.width ?? 0.0;
    final actionsHeight = _actionsSize?.height ?? 0.0;

    final contentWidth = mediaQuery.size.width - horizontalPadding * 2;

    Widget body = AnimatedBuilder(
      animation: behavior?.state ?? const AlwaysStoppedAnimation<double>(0),
      builder: (context, _) {
        final curFraction = behavior?.state.collapsedFraction ?? 0.0;
        final curOffset = behavior?.state.heightOffset ?? 0.0;
        final effectiveOffset = curOffset.isFinite ? curOffset : 0.0;
        final curExpansion = largeTitleHeight.clamp(0.0, double.infinity);
        final curCollapseFraction = curExpansion > 0
            ? (effectiveOffset.abs() / curExpansion).clamp(0.0, 1.0)
            : 0.0;
        final curBarHeight = curExpansion > 0
            ? collapsedHeight + curExpansion * (1 - curCollapseFraction)
            : collapsedHeight;

        // === 主标题连续插值（关键帧动画） ===
        // 端点 A（fraction=0）：title1 字号(32)，左对齐，垂直中心 = collapsedHeight + largeHeight/2
        // 端点 B（fraction=1）：title3 字号(20)，水平居中（避开 nav/actions），垂直中心 = verticalCenter
        // 字号/颜色用 TextStyle.lerp，位置基于垂直中心插值，实现丝滑过渡。
        // 性能：大/小字号尺寸已缓存（_largeTitleTextHeight 等），当前字号高度用 lerp 近似，
        // 滚动时每帧 0 个 TextPainter。
        final curTitleStyle = TextStyle.lerp(
          largeTitleStyle,
          smallTitleStyle,
          curFraction,
        )!;
        // 当前字号下的文字高度（线性插值近似，字体 metrics 近似线性，视觉差异不可见）。
        final curTitleHeight = lerpDouble(
            _largeTitleTextHeight, _smallTitleTextHeight, curFraction)!;

        // 端点 A：左对齐
        final largeLeft = widget.titlePadding;
        final largeCenterY = collapsedHeight + _largeTitleTextHeight / 2;

        // 端点 B：水平居中（避开 nav/actions），垂直中心 = verticalCenter。
        // 文字宽度先按 nav/actions 之间的可用区间钳制：超长标题按钳制后的
        // 宽度参与定位，再由 Positioned 上的 maxWidth 约束触发省略号。
        final smallAvailWidth =
            math.max(0.0, contentWidth - navWidth - actionsWidth);
        final smallTitleWidth = math.min(_smallTitleTextWidth, smallAvailWidth);
        var smallLeft = (contentWidth - smallTitleWidth) / 2;
        if (smallLeft < navWidth) {
          smallLeft = navWidth;
        } else if (smallLeft + smallTitleWidth > contentWidth - actionsWidth) {
          smallLeft = contentWidth - actionsWidth - smallTitleWidth;
        }
        // 防御性钳制：无论 nav/actions 测量结果如何，折叠目标绝不超出可视范围。
        smallLeft = smallLeft.clamp(
          0.0,
          math.max(0.0, contentWidth - smallTitleWidth),
        );
        final smallCenterY = verticalCenter;

        // 位置插值（基于垂直中心，top 用当前字号高度反算以保证垂直居中）
        final curLeft = lerpDouble(largeLeft, smallLeft, curFraction)!;
        final curCenterY =
            lerpDouble(largeCenterY, smallCenterY, curFraction)!;
        final curTitleTop = curCenterY - curTitleHeight / 2;
        // 当前可用宽度：大端点右侧留 titlePadding 对称边距，小端点避开 actions；
        // Positioned 不约束宽度，须显式限制才能让 ellipsis 生效。
        final curTitleMaxWidth = math.max(
          0.0,
          contentWidth -
              curLeft -
              lerpDouble(widget.titlePadding, actionsWidth, curFraction)!,
        );

        // === 副标题连续插值（如果有） ===
        // 大状态：紧贴大标题底部，左对齐
        // 小状态：紧贴小标题底部，水平居中
        final subtitleWidth = _subtitleSize?.width ?? 0.0;
        final largeSubtitleBottom =
            largeCenterY + _largeTitleTextHeight / 2 + 2.0;
        final smallSubtitleBottom =
            smallCenterY + _smallTitleTextHeight / 2 + 2.0;
        final curSubtitleTop = hasSubtitle
            ? lerpDouble(largeSubtitleBottom, smallSubtitleBottom, curFraction)!
            : 0.0;
        final smallSubtitleLeft =
            (contentWidth - math.min(subtitleWidth, smallAvailWidth)) / 2;
        final curSubtitleLeft = hasSubtitle
            ? lerpDouble(largeLeft, smallSubtitleLeft, curFraction)!
            : 0.0;
        final curSubtitleMaxWidth = math.max(
          0.0,
          contentWidth -
              curSubtitleLeft -
              lerpDouble(widget.titlePadding, actionsWidth, curFraction)!,
        );

        // === contentTop / layoutHeight（用于 bottomContent 定位与 Stack 高度） ===
        final smallTitleBottomForLayout =
            verticalCenter + _smallTitleTextHeight / 2;
        final curContentTop = math.max(
          curBarHeight + expandedBottomPadding,
          smallTitleBottomForLayout +
              (hasSubtitle ? smallSubtitleHeight + 2.0 : 0.0) +
              expandedBottomPadding,
        );
        final curLayoutHeight = curContentTop + bottomContentHeight;

        return SizedBox(
          width: contentWidth,
          height: curLayoutHeight,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 主标题（字号/位置/颜色随 fraction 连续插值）
              Positioned(
                left: curLeft,
                top: curTitleTop,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: curTitleMaxWidth),
                  child: Text(
                    widget.title,
                    style: curTitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // 副标题（位置随 fraction 连续插值，字号固定 body2）
              if (hasSubtitle)
                Positioned(
                  left: curSubtitleLeft,
                  top: curSubtitleTop,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: curSubtitleMaxWidth),
                    child: Text(
                      widget.subtitle,
                      style: theme.textStyles.body2
                          .copyWith(color: subtitleColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

              // 导航图标（垂直居中）
              if (widget.navigationIcon != null)
                Positioned(
                  left: widget.navigationIconPadding,
                  top: verticalCenter - navHeight / 2,
                  child: widget.navigationIcon!,
                ),

              // 操作图标（垂直居中，右对齐）
              if (widget.actions?.isNotEmpty ?? false)
                Positioned(
                  right: widget.actionIconPadding,
                  top: verticalCenter - actionsHeight / 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.actions!,
                  ),
                ),

              // bottomContent（固定在 contentTop 位置）
              if (widget.bottomContent != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: curContentTop,
                  child: widget.bottomContent!,
                ),
            ],
          ),
        );
      },
    );

    // 测量层：与显示层一致的 widget 树，用 Offstage 测出真实尺寸。
    Widget measurer = Offstage(
      offstage: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 大标题测量：需要以无最大高度约束测量。
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
            ),
            child: Padding(
              key: _largeTitleKey,
              padding: EdgeInsets.symmetric(horizontal: widget.titlePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MiuixText(
                    largeTitleText,
                    style: theme.textStyles.title1,
                    color: largeTitleColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasSubtitle)
                    MiuixText(
                      widget.subtitle,
                      style: theme.textStyles.body2,
                      color: subtitleColor,
                    ),
                ],
              ),
            ),
          ),
          if (widget.navigationIcon != null)
            Padding(
              key: _navigationIconKey,
              padding: EdgeInsets.only(left: widget.navigationIconPadding),
              child: widget.navigationIcon!,
            ),
          if (widget.actions?.isNotEmpty ?? false)
            Padding(
              key: _actionsKey,
              padding: EdgeInsets.only(right: widget.actionIconPadding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.actions!,
              ),
            ),
          Padding(
            key: _subtitleKey,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: MiuixText(
              widget.subtitle,
              style: theme.textStyles.body2,
              color: subtitleColor,
            ),
          ),
          if (widget.bottomContent != null)
            KeyedSubtree(
              key: _bottomContentKey,
              child: widget.bottomContent!,
            ),
        ],
      ),
    );

    // 同步滚动行为状态：把 heightOffsetLimit 设置为大标题的展开量。
    if (behavior != null) {
      final limit = -expansion;
      if (behavior.state.heightOffsetLimit != limit) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) behavior.state.heightOffsetLimit = limit;
        });
      }
    }

    final Widget foreground = SafeArea(
      top: true,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Stack(
          children: [
            ClipRect(child: body),
            measurer,
          ],
        ),
      ),
    );

    if (!widget.blurred) {
      // 原版：纯色不透明背景。
      return Material(color: bgColor, child: foreground);
    }

    // 增强：毛玻璃背景。用 BackdropFilter 模糊身后已绘制内容（scaffold 里 topBar 画在
    // body 之上，故 body 就是它的 backdrop），再叠一层半透明 bgColor 色调 + 前景标题。
    // sigma 取原版 BLUR_RADIUS_TO_SIGMA=0.45。BackdropFilter 自带按图层边界裁剪，
    // 不会溢出顶栏；且实时取正下方像素，无捕获、无坐标偏移、无 1 帧延迟。
    final sigma = widget.blurRadius.clamp(0.0, 150.0) * 0.45;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: ColoredBox(
                  color: bgColor.withValues(alpha: widget.blurTintAlpha),
                ),
              ),
            ),
          ),
          foreground,
        ],
      ),
    );
  }
}

/// 小标题静态 TopAppBar。对应 Kotlin `SmallTopAppBar`。
///
/// 不参与折叠/展开，固定显示居中标题。如传入 [scrollBehavior]，
/// 会把 state 的 [MiuixTopAppBarState.heightOffsetLimit] 锁为 0
/// （pinned 效果），让共享同一 behavior 的其他 TopAppBar 仍可正常滚动。
class MiuixSmallTopAppBar extends StatelessWidget {
  const MiuixSmallTopAppBar({
    super.key,
    required this.title,
    this.color,
    this.titleColor,
    this.subtitle = '',
    this.subtitleColor,
    this.navigationIcon,
    this.actions,
    this.scrollBehavior,
    this.defaultWindowInsetsPadding = true,
    this.titlePadding = MiuixTopAppBarDefaults.titlePadding,
    this.navigationIconPadding = MiuixTopAppBarDefaults.navigationIconPadding,
    this.actionIconPadding = MiuixTopAppBarDefaults.actionIconPadding,
    this.bottomContent,
  });

  final String title;
  final Color? color;
  final Color? titleColor;
  final String subtitle;
  final Color? subtitleColor;
  final Widget? navigationIcon;
  final List<Widget>? actions;
  final MiuixScrollBehavior? scrollBehavior;
  final bool defaultWindowInsetsPadding;
  final double titlePadding;
  final double navigationIconPadding;
  final double actionIconPadding;
  final Widget? bottomContent;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final colors = theme.colors;
    final bgColor = color ?? colors.surface;
    final txtColor = titleColor ?? colors.onSurface;
    final subColor = subtitleColor ?? colors.onSurfaceVariantSummary;

    // SideEffect 等价：把 heightOffsetLimit 锁为 0。
    final behavior = scrollBehavior;
    if (behavior != null && behavior.state.heightOffsetLimit != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        behavior.state.heightOffsetLimit = 0;
      });
    }

    final mediaQuery = MediaQuery.of(context);
    final horizontalPadding =
        defaultWindowInsetsPadding ? mediaQuery.padding.horizontal : 0.0;

    final hasSubtitle = subtitle.isNotEmpty;
    final centerHeight = MiuixTopAppBarDefaults.smallTopAppBarCenterHeight;

    return Material(
      color: bgColor,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: centerHeight,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    if (navigationIcon != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: navigationIconPadding),
                          child: navigationIcon!,
                        ),
                      ),
                    if (actions?.isNotEmpty ?? false)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding:
                              EdgeInsets.only(right: actionIconPadding),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: actions!,
                          ),
                        ),
                      ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: titlePadding),
                        child: MiuixText(
                          title,
                          style: theme.textStyles.title3,
                          color: txtColor,
                          fontWeight: FontWeight.w500,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasSubtitle)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: titlePadding),
                  child: Center(
                    child: MiuixText(
                      subtitle,
                      style: theme.textStyles.body2,
                      color: subColor,
                    ),
                  ),
                ),
              ?bottomContent,
            ],
          ),
        ),
      ),
    );
  }
}
