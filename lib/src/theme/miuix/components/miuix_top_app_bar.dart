// Miuix Flutter 移植版 - TopAppBar
// 源自 compose-miuix-ui/miuix 的 TopAppBar.kt。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/miuix_text_styles.dart';
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

  /// 大标题淡出斜率。原版 `TopAppBarLayout`：
  /// `alpha = 1 - (collapsedFraction * 3)`——从折叠的第一个像素就开始淡出，
  /// 折叠 1/3 处大标题完全消失，早于小标题出现。
  static const double largeTitleFadeRate = 3.0;

  /// 小标题切换可见的折叠比例阈值。原版：`collapsedFraction * 3 >= 1`。
  static const double smallTitleRevealFraction = 1.0 / 3.0;

  /// 小标题出现过渡的上浮距离。原版用 folme 弹簧把 `translationY` 从 20 动画到 0。
  static const double smallTitleRisePx = 20.0;

  /// 短页面松手时的折叠去留阈值：折叠比例达到该值则停驻在折叠态，否则重新展开。
  static const double titleCoverHandoff = 0.50;
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
    // 忽略瞬时零值：父级重建时 Offstage 测量层尚未回填尺寸，expansion 会短暂
    // 为 0。若已持有有效负值上限，接受 0 会把 heightOffset 强制归零，折叠中的
    // 标题会闪一下重新展开。SmallTopAppBar 需要固定钉住时请改用 [pin]。
    if (value.abs() < 0.5 &&
        _heightOffsetLimit.isFinite &&
        _heightOffsetLimit < -1.0) {
      return;
    }
    if (_heightOffsetLimit == value) return;
    _heightOffsetLimit = value;
    // 上限变化后把当前偏移重新夹进新区间。
    heightOffset = _heightOffset;
    _notify();
  }

  /// 把折叠上限锁为 0（SmallTopAppBar 的 pinned 语义），绕过瞬时零值防护。
  void pin() {
    if (_heightOffsetLimit == 0 && _heightOffset == 0) return;
    _heightOffsetLimit = 0;
    _heightOffset = 0;
    _notify();
  }

  /// 当前折叠偏移量，被夹在 [heightOffsetLimit] 与 0 之间。
  double get heightOffset => _heightOffset;

  set heightOffset(double value) {
    final clamped = value.clamp(_heightOffsetLimit, 0.0);
    if (_heightOffset == clamped) return;
    _heightOffset = clamped;
    _notify();
  }

  /// TopAppBar 下方内容的累计滚动偏移量。
  double get contentOffset => _contentOffset;

  set contentOffset(double value) {
    // 仅记账不通知：折叠量已被钳制在端点时，每个滚动像素都通知会让监听者
    // 白白重建（可见为标题闪烁 / 无谓的重绘开销）。
    if (_contentOffset == value) return;
    _contentOffset = value;
  }

  bool _notifyScheduled = false;

  /// 布局/绘制阶段（滚动通知可能在 performLayout 中冒泡）直接 notifyListeners
  /// 会触发 "Build scheduled during frame"，此时延迟到帧末；其余阶段立即通知，
  /// 不引入任何一帧滞后。
  void _notify() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      if (_notifyScheduled) return;
      _notifyScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _notifyScheduled = false;
        notifyListeners();
      });
      return;
    }
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
/// 折叠量 [MiuixTopAppBarState.heightOffset] 直接锚定到内容滚动位置：
/// `heightOffset = -(pixels - minScrollExtent)`，再由 setter 钳到 [limit, 0]。
/// 只有内容滚回顶部对应位置，大标题才逐像素恢复；中途上/下滑不跳变。
///
/// 松手吸附（[snapOnRelease]，对应原版 `settleAppBar` 的 snap 段）：手指抬起
/// 时若停在折叠过渡区中段，把**列表本身**动画到全展开/全折叠的对应滚动
/// 位置。注意与早期（1.0.2–1.0.8）实现的关键区别：吸附动画的是 pixels 而非
/// heightOffset，折叠量始终是滚动位置的纯函数，不会重新引入"吸附后 offset 与
/// pixels 解耦、中部微下滑弹回大标题"的回归问题。
///
/// 短页面（可滚行程不足以靠滚动位置把标题保持在折叠态）走专用路径：回弹
/// 期间冻结折叠量，松手后按 [MiuixTopAppBarDefaults.titleCoverHandoff] 吸附到
/// 近端，避免橡皮筋回弹把折叠中的标题拉回展开（"回弹 + 闪烁"）。
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
    this.snapOnRelease = true,
    this.snapDuration = const Duration(milliseconds: 280),
    this.snapCurve = Curves.easeOutCubic,
    this.lockSmallTitleUntilTop = false,
  }) : state = state ?? MiuixTopAppBarState();

  @override
  final MiuixTopAppBarState state;

  /// 是否处理滚动事件。
  final bool Function()? canScroll;

  /// 松手时若停在折叠过渡区中段，把列表吸附到全展开/全折叠的近端。
  final bool snapOnRelease;

  /// 吸附动画时长与曲线（对应原版 `snapAnimationSpec`）。
  final Duration snapDuration;
  final Curve snapCurve;

  /// 可选增强（非原版行为，默认关闭）：标题折叠后保持小标题，直到用户发起
  /// **新手势**把内容拉回顶部才重新展开；惯性滚动碰巧到达顶部不触发展开，
  /// 避免阅读中标题在大/小态之间意外来回切换。
  final bool lockSmallTitleUntilTop;

  bool _snapInProgress = false;

  /// 吸附动画运行中。监听者可据此避免在吸附期间切换视觉状态造成闪烁。
  bool get isSnapInProgress => _snapInProgress;

  /// 松手后列表仍在越界回弹：回弹期间冻结标题，否则 pixels 回落会把折叠中
  /// 的标题渐渐拉回展开（用户感知为"松手后标题又弹回大标题"）。
  bool _frozenDuringOverscrollSpringBack = false;

  /// [lockSmallTitleUntilTop] 启用时：标题已折叠，在下一次新手势前保持冻结。
  bool _smallTitleLocked = false;

  @override
  bool get isPinned => false;

  bool handleScroll(ScrollNotification n) {
    if (canScroll != null && !canScroll!()) return false;
    // 只响应直接子滚动体的竖向滚动：页面内嵌套的横向/内层列表（depth > 0）
    // 不得驱动顶栏折叠，否则横滑一个内嵌列表也会牵动大标题。
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;

    final metrics = n.metrics;
    final pixels = metrics.pixels;
    final minExtent = metrics.minScrollExtent;
    final maxExtent = metrics.maxScrollExtent;

    // 短页面：最大可滚行程小于展开量，标题只能靠橡皮筋越界折叠，而越界
    // 松手必回弹——通用的位置同步会在回弹期间把标题重新拉回展开。走专用
    // 路径：回弹期冻结，松手后按阈值吸附到端点。
    final limit = state.heightOffsetLimit;
    final expansion = limit.isFinite ? -limit : 0.0;
    final canParkViaScroll =
        expansion <= 0 || (maxExtent - minExtent) >= expansion - 1.0;
    if (!canParkViaScroll) {
      return _handleShortPageScroll(n);
    }

    if (_snapInProgress && n is! ScrollEndNotification) {
      // 吸附动画运行期间仍按位置同步折叠量（保持 offset ≡ f(pixels)）。
      _syncOffsetToPosition(metrics);
      return false;
    }

    // 松手时列表仍在底部越界：后续回弹动画期间冻结标题。
    if (n is ScrollEndNotification &&
        pixels > maxExtent + 0.5 &&
        state.heightOffset < 0) {
      _frozenDuringOverscrollSpringBack = true;
    }
    // 新手势开始 → 清除冻结与小标题锁。
    if (n is ScrollStartNotification) {
      _frozenDuringOverscrollSpringBack = false;
      _smallTitleLocked = false;
    }
    if (_frozenDuringOverscrollSpringBack) {
      state.contentOffset = pixels;
      if (pixels <= maxExtent + 0.5) {
        // 回弹结束；重新同步一次并清除标志。
        _frozenDuringOverscrollSpringBack = false;
        _syncOffsetToPosition(metrics);
      }
      return false;
    }

    if (_smallTitleLocked) {
      // 当前手势/惯性期间保持小标题冻结。
      state.contentOffset = pixels;
      return false;
    }

    _syncOffsetToPosition(metrics);

    // 可选增强：折叠后锁定小标题，直到新手势。
    if (lockSmallTitleUntilTop &&
        state.heightOffset < -5.0 &&
        pixels > 0.5) {
      _smallTitleLocked = true;
    }

    if (snapOnRelease && n is ScrollEndNotification) {
      _snapToNearestEndpoint(n);
    }
    return false;
  }

  /// 短页面折叠处理（见 [handleScroll]）：手指按住时标题跟随橡皮筋越界行程，
  /// 但只有活跃拖拽才允许*重新展开*；回弹/惯性期间保持冻结，松手后按
  /// [MiuixTopAppBarDefaults.titleCoverHandoff] 吸附到近端，绝不停在半折叠态。
  bool _handleShortPageScroll(ScrollNotification n) {
    final metrics = n.metrics;
    final limit = state.heightOffsetLimit;
    if (!limit.isFinite || limit >= 0) {
      _syncOffsetToPosition(metrics);
      return false;
    }

    if (n is ScrollEndNotification) {
      // 回弹期标题一直冻结，当前折叠比例即松手时的比例——吸附到近端。
      final fraction = state.collapsedFraction;
      state.heightOffset =
          fraction >= MiuixTopAppBarDefaults.titleCoverHandoff ? limit : 0.0;
      state.contentOffset = metrics.pixels;
      return false;
    }

    final isActiveUserDrag =
        n is ScrollUpdateNotification && n.dragDetails != null;
    final scrolled = metrics.pixels - metrics.minScrollExtent;
    final desired = scrolled <= 0 ? 0.0 : -scrolled;
    final wouldExpand = desired > state.heightOffset + 0.01;

    if (wouldExpand && !isActiveUserDrag) {
      // 回弹/惯性：保持折叠中的标题冻结，不回弹。
      state.contentOffset = metrics.pixels;
      return false;
    }

    state.heightOffset = desired;
    state.contentOffset = metrics.pixels;
    return false;
  }

  /// 把折叠量直接锚定到内容滚动位置：距顶越远折叠越多，滚回顶部即恢复。
  ///
  /// `heightOffset = -(pixels - minScrollExtent)`（负值代表折叠）。setter 内部
  /// 已把值钳到 `[heightOffsetLimit, 0]`：
  /// - 超过展开量（pixels 很大）→ 钳到 limit，保持完全折叠（居中小标题）；
  /// - 越过顶部（iOS 回弹的负向 pixels 使表达式为正）→ 钳到 0，保持完全展开。
  ///
  /// 展开量未测出（limit 仍为 -∞）时不动作；limit==0（SmallTopAppBar 锁定为
  /// pinned）时强制保持展开。
  void _syncOffsetToPosition(ScrollMetrics metrics) {
    final limit = state.heightOffsetLimit;
    if (!limit.isFinite) return;
    if (limit == 0) {
      state.heightOffset = 0;
      return;
    }
    final scrolled = metrics.pixels - metrics.minScrollExtent;
    state.heightOffset = scrolled <= 0 ? 0.0 : -scrolled;
    state.contentOffset = metrics.pixels;
  }

  /// 松手吸附：fraction < 0.5 → 滚回全展开，否则滚到全折叠。对应原版
  /// `settleAppBar` 的 snap 段，但动画对象是列表位置而非 heightOffset，
  /// 保证折叠量与滚动位置永不解耦。
  void _snapToNearestEndpoint(ScrollEndNotification n) {
    final limit = state.heightOffsetLimit;
    if (!limit.isFinite || limit >= 0) return;
    final fraction = state.collapsedFraction;
    // 已停在端点——无需吸附。
    if (fraction <= 0.02 || fraction >= 0.98) return;

    final metrics = n.metrics;
    final expansion = -limit;
    final minExtent = metrics.minScrollExtent;
    final targetPixels =
        fraction < 0.5 ? minExtent : minExtent + expansion;

    final context = n.context;
    final ScrollPosition? position =
        context == null ? null : Scrollable.maybeOf(context)?.position;
    if (position == null || !position.hasPixels) return;
    if ((position.pixels - targetPixels).abs() < 0.5) return;

    _snapInProgress = true;
    // ScrollEndNotification 在滚动活动收尾过程中同步分发，此刻直接
    // animateTo 会被随后的 goIdle/goBallistic 立即顶替（吸附静默失效）。
    // 推迟到当前分发栈之外再启动。
    Future<void>.microtask(() {
      if (!position.hasPixels) {
        _snapInProgress = false;
        return;
      }
      position
          .animateTo(
            targetPixels.clamp(
              position.minScrollExtent,
              position.maxScrollExtent,
            ),
            duration: snapDuration,
            curve: snapCurve,
          )
          .whenComplete(() {
            _snapInProgress = false;
            if (position.hasPixels) {
              _syncOffsetToPosition(position);
            }
          });
    });
  }
}

/// 把滚动事件桥接到 [MiuixExitUntilCollapsedScrollBehavior] 的监听器。
///
/// 包裹任意可滚动组件，把每个滚动通知转给 behavior 换算折叠量。
/// 折叠量按位置直接映射，无需动画控制器/vsync，故为无状态组件。
class MiuixScrollBehaviorListener extends StatelessWidget {
  const MiuixScrollBehaviorListener({
    super.key,
    required this.behavior,
    required this.child,
  });

  final MiuixExitUntilCollapsedScrollBehavior behavior;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: behavior.handleScroll,
      child: child,
    );
  }
}

/// 创建一个默认的 [MiuixExitUntilCollapsedScrollBehavior]。
MiuixExitUntilCollapsedScrollBehavior miuixScrollBehavior({
  MiuixTopAppBarState? state,
  bool Function()? canScroll,
  bool snapOnRelease = true,
  Duration snapDuration = const Duration(milliseconds: 280),
  Curve snapCurve = Curves.easeOutCubic,
  bool lockSmallTitleUntilTop = false,
}) {
  return MiuixExitUntilCollapsedScrollBehavior(
    state: state,
    canScroll: canScroll,
    snapOnRelease: snapOnRelease,
    snapDuration: snapDuration,
    snapCurve: snapCurve,
    lockSmallTitleUntilTop: lockSmallTitleUntilTop,
  );
}

/// 大标题可折叠的 TopAppBar。对应 Kotlin `TopAppBar`（`TopAppBarLayout`）。
///
/// 折叠过渡与原版一致，采用双层结构而非字号连续插值：
/// - 展开态：仅显示左对齐大标题（`title1` 32sp）；
/// - 大标题住在折叠带下方的独立裁剪层里，随折叠偏移上移并在带下缘被
///   裁掉；从折叠第一个像素开始淡出（`alpha = 1 - fraction * 3`，原版
///   公式），折叠 1/3 处完全消失；
/// - 小标题在折叠 1/3 处阈值翻转，以弹簧曲线淡入 + 上浮 20px 出现，
///   重新展开时更快收回——对应原版 folme 弹簧规格。
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

class _MiuixTopAppBarState extends State<MiuixTopAppBar>
    with SingleTickerProviderStateMixin {
  // 用于测量大标题真实尺寸（决定 expansion / heightOffsetLimit）。
  // 大标题/副标题/导航/操作/bottomContent 尺寸用 Offstage 测量；
  // 标题纯文字尺寸用 TextPainter 测量并缓存（仅标题文字变化时重算）。
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

  // 主标题纯文字尺寸缓存（不随 fraction 变化，仅在标题文字变化时重算）。
  // 避免每帧创建 TextPainter 做文字 shaping（昂贵），解决滚动掉帧。
  String? _measuredTitle;
  String? _measuredLargeTitle;
  double _largeTitleTextHeight = 0;
  double _smallTitleTextHeight = 0;
  double _smallTitleTextWidth = 0;

  /// 小标题显隐过渡。原版用 folme 弹簧（show: damping 1.0 / response 0.3s；
  /// hide: response 0.15s）驱动透明度 0→1 叠加 translationY 从
  /// [MiuixTopAppBarDefaults.smallTitleRisePx] 上浮到 0。
  late final AnimationController _smallTitleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 150),
  );
  late final Animation<double> _smallTitleAnim = CurvedAnimation(
    parent: _smallTitleController,
    curve: Curves.easeOutCubic,
  );

  /// 首次构建前为 null——用于把控制器直接定位到当前可见性而不播放动画
  /// （原版同样用当前可见性初始化 Animatable：已折叠状态下新建的 State
  /// 不得重播淡入，否则表现为标题闪烁）。
  bool? _smallTitleShown;

  @override
  void dispose() {
    _smallTitleController.dispose();
    super.dispose();
  }

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
    ).withMiuixWeight(theme.fontWeightAdjustment);
    final smallTitleStyle = theme.textStyles.title3.copyWith(
      color: titleColor,
      fontWeight: FontWeight.w500,
    ).withMiuixWeight(theme.fontWeightAdjustment);

    // 测量并缓存大/小字号下的文字尺寸：只在标题文字变化时重算，
    // 滚动时不创建任何 TextPainter（文字 shaping 昂贵，每帧调用会掉帧）。
    if (_measuredTitle != widget.title ||
        _measuredLargeTitle != largeTitleText) {
      _measuredTitle = widget.title;
      _measuredLargeTitle = largeTitleText;
      final largeTp = TextPainter(
        text: TextSpan(text: largeTitleText, style: largeTitleStyle),
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
      animation: Listenable.merge([
        if (behavior != null) behavior.state,
        _smallTitleController,
      ]),
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

        // === 小标题阈值开关（原版 boolean derivedStateOf） ===
        // 跨过 1/3 折叠时翻转一次，由弹簧曲线驱动透明度 + 上浮过渡；
        // 而非每帧跟随 fraction。
        final smallVisible = curFraction >=
            MiuixTopAppBarDefaults.smallTitleRevealFraction;
        if (_smallTitleShown == null) {
          // 首次构建：直接定位到当前状态，不播放动画。
          _smallTitleShown = smallVisible;
          _smallTitleController.value = smallVisible ? 1.0 : 0.0;
        } else if (smallVisible != _smallTitleShown) {
          _smallTitleShown = smallVisible;
          if (smallVisible) {
            _smallTitleController.forward();
          } else {
            _smallTitleController.reverse();
          }
        }

        // === 大标题：原版公式 `alpha = 1 - (collapsedFraction * 3)` ===
        // 从折叠的第一个像素就开始淡出，1/3 处完全消失，早于小标题出现。
        final largeOpacity = (1.0 -
                curFraction * MiuixTopAppBarDefaults.largeTitleFadeRate)
            .clamp(0.0, 1.0);
        final smallOpacity = _smallTitleAnim.value;
        final smallTitleRise = MiuixTopAppBarDefaults.smallTitleRisePx *
            (1.0 - _smallTitleAnim.value);

        // 大标题端点：左对齐，随折叠偏移上移。
        final largeLeft = widget.titlePadding;
        final largeTitleMaxWidth = math.max(
          0.0,
          contentWidth - largeLeft - widget.titlePadding,
        );

        // 小标题端点：水平居中（避开 nav/actions），垂直中心 = verticalCenter。
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
        final smallTitleTop = verticalCenter - _smallTitleTextHeight / 2;
        final smallTitleMaxWidth = math.max(
          0.0,
          contentWidth - smallLeft - actionsWidth,
        );

        // 小副标题：居中紧贴小标题下方，与小标题共用透明度/上浮（原版
        // smallSubtitle 与 title 共用同一对 Animatable）。
        final subtitleWidth = _subtitleSize?.width ?? 0.0;
        final smallSubtitleLeft =
            (contentWidth - math.min(subtitleWidth, smallAvailWidth)) / 2;

        // === contentTop / layoutHeight（用于 bottomContent 定位与 Stack 高度） ===
        final smallTitleBottomForLayout =
            verticalCenter + _smallTitleTextHeight / 2;
        final curContentTop = math.max(
          curBarHeight + expandedBottomPadding,
          smallTitleBottomForLayout +
              (hasSubtitle ? smallSubtitleHeight : 0.0) +
              expandedBottomPadding,
        );
        final curLayoutHeight = curContentTop + bottomContentHeight;

        return SizedBox(
          width: contentWidth,
          height: curLayoutHeight,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // === 下层：大标题（+ 大副标题），严格位于折叠带之下 ===
              // 图层起点在折叠带下缘（top = collapsedHeight），字形随折叠
              // 偏移上移并在该边缘被裁掉——两层彼此独立，大标题永远不会
              // 进入折叠带，无论背景是纯色还是毛玻璃（对应原版 largeTitle
              // Box 的 `padding(top = CollapsedHeight)` + 整栏 clipToBounds）。
              Positioned(
                top: collapsedHeight,
                left: 0,
                right: 0,
                height: _largeTitleTextHeight +
                    (hasSubtitle ? smallSubtitleHeight : 0.0),
                child: ClipRect(
                  child: Stack(
                    children: [
                      Positioned(
                        left: largeLeft,
                        top: effectiveOffset,
                        child: Opacity(
                          opacity: largeOpacity,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: largeTitleMaxWidth,
                            ),
                            child: Text(
                              largeTitleText,
                              style: largeTitleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      // 大副标题与大标题同层同偏移同透明度（原版同一 Column）。
                      if (hasSubtitle)
                        Positioned(
                          left: largeLeft,
                          top: _largeTitleTextHeight + effectiveOffset,
                          child: Opacity(
                            opacity: largeOpacity,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: largeTitleMaxWidth,
                              ),
                              child: Text(
                                widget.subtitle,
                                style: theme.textStyles.body2
                                    .copyWith(color: subtitleColor)
                                    .withMiuixWeight(theme.fontWeightAdjustment),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // === 上层：折叠带内的小标题（阈值弹簧：透明度 + 上浮） ===
              if (smallOpacity > 0.001)
                Positioned(
                  left: smallLeft,
                  top: smallTitleTop + smallTitleRise,
                  child: Opacity(
                    opacity: smallOpacity,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: smallTitleMaxWidth),
                      child: Text(
                        widget.title,
                        style: smallTitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

              // 小副标题（居中紧贴小标题下方，与小标题同步显隐）。
              if (hasSubtitle && smallOpacity > 0.001)
                Positioned(
                  left: smallSubtitleLeft,
                  top: smallTitleBottomForLayout + smallTitleRise,
                  child: Opacity(
                    opacity: smallOpacity,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: smallAvailWidth),
                      child: Text(
                        widget.subtitle,
                        style: theme.textStyles.body2
                            .copyWith(color: subtitleColor)
                            .withMiuixWeight(theme.fontWeightAdjustment),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

    // SideEffect 等价：把折叠上限钉住为 0（绕过瞬时零值防护）。
    final behavior = scrollBehavior;
    if (behavior != null && behavior.state.heightOffsetLimit != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        behavior.state.pin();
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
