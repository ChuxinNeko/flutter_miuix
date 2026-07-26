// Miuix Flutter 移植版 - Snackbar
// 源自 compose-miuix-ui/miuix 的 Snackbar.kt。
// 用 ChangeNotifier、逐项动画与水平拖动复刻消息队列、进退场和滑动关闭。
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../foundation/miuix_content_color.dart';
import '../foundation/miuix_squircle.dart';
import '../icon/miuix_basic_icons.dart';
import '../theme/miuix_theme.dart';
import 'miuix_button.dart';
import 'miuix_icon.dart';
import 'miuix_text.dart';

/// Snackbar 显示时长。对应 Kotlin `SnackbarDuration`。
sealed class MiuixSnackbarDuration {
  const MiuixSnackbarDuration();

  /// 短时显示（4000ms）。
  static const MiuixSnackbarDuration short = MiuixSnackbarShortDuration();

  /// 长时显示（10000ms）。
  static const MiuixSnackbarDuration long = MiuixSnackbarLongDuration();

  /// 一直显示，直至主动关闭。
  static const MiuixSnackbarDuration indefinite =
      MiuixSnackbarIndefiniteDuration();

  /// 创建自定义显示时长；[durationMillis] 必须大于零。
  const factory MiuixSnackbarDuration.custom(int durationMillis) =
      MiuixSnackbarCustomDuration;

  Duration? get _duration;
}

/// Snackbar 短时显示。对应 Kotlin `SnackbarDuration.Short`。
final class MiuixSnackbarShortDuration extends MiuixSnackbarDuration {
  const MiuixSnackbarShortDuration();

  @override
  Duration get _duration => const Duration(milliseconds: 4000);
}

/// Snackbar 长时显示。对应 Kotlin `SnackbarDuration.Long`。
final class MiuixSnackbarLongDuration extends MiuixSnackbarDuration {
  const MiuixSnackbarLongDuration();

  @override
  Duration get _duration => const Duration(milliseconds: 10000);
}

/// Snackbar 无限期显示。对应 Kotlin `SnackbarDuration.Indefinite`。
final class MiuixSnackbarIndefiniteDuration extends MiuixSnackbarDuration {
  const MiuixSnackbarIndefiniteDuration();

  @override
  Duration? get _duration => null;
}

/// Snackbar 自定义显示时长。对应 Kotlin `SnackbarDuration.Custom`。
final class MiuixSnackbarCustomDuration extends MiuixSnackbarDuration {
  const MiuixSnackbarCustomDuration(this.durationMillis)
    : assert(durationMillis > 0, 'durationMillis 必须大于 0');

  /// 显示毫秒数。
  final int durationMillis;

  @override
  Duration get _duration => Duration(milliseconds: durationMillis);
}

/// Snackbar 完成结果。对应 Kotlin `SnackbarResult`。
enum MiuixSnackbarResult {
  /// Snackbar 被关闭或超时消失。
  dismissed,

  /// 用户执行了 Snackbar 操作。
  actionPerformed,
}

/// Snackbar 的可视数据。对应 Kotlin `SnackbarVisuals`。
@immutable
class MiuixSnackbarVisuals {
  const MiuixSnackbarVisuals({
    required this.message,
    this.actionLabel,
    this.withDismissAction = false,
    this.duration = MiuixSnackbarDuration.short,
  });

  /// 显示的消息文本。
  final String message;

  /// 可选操作标签。
  final String? actionLabel;

  /// 是否显示关闭操作。
  final bool withDismissAction;

  /// 显示时长。
  final MiuixSnackbarDuration duration;
}

/// Snackbar 的交互数据。对应 Kotlin `SnackbarData`。
abstract interface class MiuixSnackbarData {
  /// Snackbar 的可视数据。
  MiuixSnackbarVisuals get visuals;

  /// 关闭 Snackbar。
  Future<void> dismiss();

  /// 执行 Snackbar 操作。
  Future<void> performAction();
}

@immutable
class _MiuixSnackbarEntry {
  const _MiuixSnackbarEntry({
    required this.id,
    required this.data,
    this.visible = true,
  });

  final int id;
  final MiuixSnackbarData data;
  final bool visible;

  _MiuixSnackbarEntry copyWith({bool? visible}) =>
      _MiuixSnackbarEntry(id: id, data: data, visible: visible ?? this.visible);
}

class _MiuixSnackbarData implements MiuixSnackbarData {
  _MiuixSnackbarData({required this.visuals, required this.onComplete});

  @override
  final MiuixSnackbarVisuals visuals;
  final Future<void> Function(MiuixSnackbarResult result) onComplete;
  bool _completed = false;

  Future<void> _complete(MiuixSnackbarResult result) async {
    if (_completed) return;
    _completed = true;
    await onComplete(result);
  }

  @override
  Future<void> dismiss() => _complete(MiuixSnackbarResult.dismissed);

  @override
  Future<void> performAction() =>
      _complete(MiuixSnackbarResult.actionPerformed);
}

/// Snackbar Host 状态。对应 Kotlin `SnackbarHostState`。
///
/// 每次 [showSnackbar] 都在队列底部加入一个独立 Snackbar；多个消息可同时
/// 显示。返回的 Future 会在超时、关闭、滑动关闭或操作执行后完成。
class MiuixSnackbarHostState extends ChangeNotifier {
  final List<_MiuixSnackbarEntry> _entries = <_MiuixSnackbarEntry>[];
  int _idCounter = 0;

  List<_MiuixSnackbarEntry> get _currentSnackbars =>
      List<_MiuixSnackbarEntry>.unmodifiable(_entries);

  /// 返回当前最新的可见 Snackbar 数据。
  Future<MiuixSnackbarData?> newestSnackbarData() async {
    for (final entry in _entries) {
      if (entry.visible) return entry.data;
    }
    return null;
  }

  /// 返回当前最旧的可见 Snackbar 数据。
  Future<MiuixSnackbarData?> oldestSnackbarData() async {
    for (final entry in _entries.reversed) {
      if (entry.visible) return entry.data;
    }
    return null;
  }

  /// 显示一个 Snackbar。对应 Kotlin `showSnackbar`。
  Future<MiuixSnackbarResult> showSnackbar(
    String message, {
    String? actionLabel,
    bool withDismissAction = false,
    MiuixSnackbarDuration duration = MiuixSnackbarDuration.short,
  }) {
    final completer = Completer<MiuixSnackbarResult>();
    final id = ++_idCounter;
    final visuals = MiuixSnackbarVisuals(
      message: message,
      actionLabel: actionLabel,
      withDismissAction: withDismissAction,
      duration: duration,
    );
    late final _MiuixSnackbarData data;
    data = _MiuixSnackbarData(
      visuals: visuals,
      onComplete: (result) async {
        if (!completer.isCompleted) completer.complete(result);
        _hideEntry(id);
      },
    );
    _entries.insert(0, _MiuixSnackbarEntry(id: id, data: data));
    notifyListeners();
    return completer.future;
  }

  void _hideEntry(int id) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1 || !_entries[index].visible) return;
    _entries[index] = _entries[index].copyWith(visible: false);
    notifyListeners();
  }

  void _removeEntry(int id) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index == -1) return;
    _entries.removeAt(index);
    notifyListeners();
  }
}

/// Snackbar Host。对应 Kotlin `SnackbarHost`。
///
/// Host 统一管理队列、自动关闭、进退场和双向滑动关闭。最新消息位于底部；
/// [builder] 可让上层在后续 Scaffold 集成时替换卡片外观。
class MiuixSnackbarHost extends StatelessWidget {
  const MiuixSnackbarHost({
    super.key,
    required this.state,
    this.canSwipeToDismiss = true,
    this.builder,
    this.blurSigma = 0.0,
    this.blurBackgroundAlpha = 0.55,
  });

  /// Host 状态。
  final MiuixSnackbarHostState state;

  /// 是否允许向任一水平方向滑动关闭。
  final bool canSwipeToDismiss;

  /// 自定义 Snackbar 内容；默认构建 [MiuixSnackbar]。
  ///
  /// 传入后 [blurSigma] / [blurBackgroundAlpha] 对默认构建无效（需在自定义
  /// builder 内部自行传给 [MiuixSnackbar]）。
  final Widget Function(BuildContext context, MiuixSnackbarData data)? builder;

  /// 默认构建 [MiuixSnackbar] 时传入的模糊强度。> 0 启用毛玻璃背景。
  final double blurSigma;

  /// 默认构建 [MiuixSnackbar] 时传入的背景不透明度。
  final double blurBackgroundAlpha;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final entries = state._currentSnackbars;
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: _hostBottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                for (var index = entries.length - 1; index >= 0; index--)
                  _MiuixSnackbarHostItem(
                    key: ValueKey<int>(entries[index].id),
                    entry: entries[index],
                    isNewest: index == 0,
                    canSwipeToDismiss: canSwipeToDismiss,
                    onRemoved: () => state._removeEntry(entries[index].id),
                    child:
                        builder?.call(context, entries[index].data) ??
                        MiuixSnackbar(
                          data: entries[index].data,
                          blurSigma: blurSigma,
                          blurBackgroundAlpha: blurBackgroundAlpha,
                        ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiuixSnackbarHostItem extends StatefulWidget {
  const _MiuixSnackbarHostItem({
    super.key,
    required this.entry,
    required this.isNewest,
    required this.canSwipeToDismiss,
    required this.onRemoved,
    required this.child,
  });

  final _MiuixSnackbarEntry entry;
  final bool isNewest;
  final bool canSwipeToDismiss;
  final VoidCallback onRemoved;
  final Widget child;

  @override
  State<_MiuixSnackbarHostItem> createState() => _MiuixSnackbarHostItemState();
}

class _MiuixSnackbarHostItemState extends State<_MiuixSnackbarHostItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  double _dragOffset = 0;
  double _width = 0;
  bool _dragging = false;
  bool _removalScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 310),
            reverseDuration: const Duration(milliseconds: 310),
          )
          ..addStatusListener(_handleAnimationStatus)
          ..forward();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _MiuixSnackbarHostItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.visible && !widget.entry.visible) {
      _timer?.cancel();
      _controller.reverse();
    }
  }

  void _startTimer() {
    final duration = widget.entry.data.visuals.duration._duration;
    if (duration == null) return;
    _timer = Timer(duration, () {
      if (!_dragging && mounted && widget.entry.visible) {
        unawaited(widget.entry.data.dismiss());
      }
    });
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed || widget.entry.visible) return;
    if (_removalScheduled) return;
    _removalScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onRemoved());
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.canSwipeToDismiss || !widget.entry.visible) return;
    setState(() => _dragOffset += details.delta.dx);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.canSwipeToDismiss || !widget.entry.visible) return;
    _dragging = false;
    final velocity = details.primaryVelocity ?? 0;
    final passedThreshold = _width > 0 && _dragOffset.abs() >= _width * 0.5;
    final flung = velocity.abs() >= 700;
    if (passedThreshold || flung) {
      final direction = _dragOffset == 0 ? velocity.sign : _dragOffset.sign;
      setState(() => _dragOffset = direction * (_width == 0 ? 1 : _width));
      unawaited(widget.entry.data.dismiss());
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth.isFinite) _width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: widget.canSwipeToDismiss
              ? (_) => _dragging = true
              : null,
          onHorizontalDragUpdate: widget.canSwipeToDismiss
              ? _handleDragUpdate
              : null,
          onHorizontalDragEnd: widget.canSwipeToDismiss ? _handleDragEnd : null,
          onHorizontalDragCancel: widget.canSwipeToDismiss
              ? () {
                  _dragging = false;
                  setState(() => _dragOffset = 0);
                }
              : null,
          child: AnimatedBuilder(
            animation: _controller,
            child: widget.child,
            builder: (context, child) {
              final value = Curves.easeOutCubic.transform(_controller.value);
              final exitingNewest = !widget.entry.visible && widget.isNewest;
              final verticalOffset = widget.entry.visible || exitingNewest
                  ? _hostBottomPadding * (1 - value)
                  : 0.0;
              final opacity = !widget.entry.visible && !widget.isNewest
                  ? _controller.value
                  : 1.0;
              return SizeTransition(
                sizeFactor: _controller,
                alignment: AlignmentDirectional.topCenter,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(_dragOffset, verticalOffset),
                    child: child,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Snackbar 卡片。对应 Kotlin `Snackbar`。
///
/// [blurSigma] > 0 时启用高斯模糊半透明材质背景（HyperOS 风格毛玻璃）：
/// 用 [BackdropFilter] 模糊身后内容，叠加半透明 [MiuixSnackbarColors.containerColor]。
/// 默认 0，保持原版纯色背景。
class MiuixSnackbar extends StatelessWidget {
  const MiuixSnackbar({
    super.key,
    required this.data,
    this.cornerRadius = MiuixSnackbarDefaults.cornerRadius,
    this.colors,
    this.insideMargin = MiuixSnackbarDefaults.insideMargin,
    this.blurSigma = 0.0,
    this.blurBackgroundAlpha = 0.55,
  });

  /// Snackbar 交互数据。
  final MiuixSnackbarData data;

  /// 卡片圆角半径。
  final double cornerRadius;

  /// 卡片颜色；默认取当前 Miuix 主题。
  final MiuixSnackbarColors? colors;

  /// 卡片内部边距。
  final EdgeInsetsGeometry insideMargin;

  /// 高斯模糊强度（sigma）。> 0 时启用毛玻璃背景，0 为原版纯色背景。
  ///
  /// 推荐 25~40。仅在背景内容能透过来时有效（如悬浮在列表之上）。
  final double blurSigma;

  /// 启用模糊时背景色的不透明度（0~1），默认 0.55。
  /// 越小越透，模糊背景内容越可见。
  final double blurBackgroundAlpha;

  @override
  Widget build(BuildContext context) {
    final visuals = data.visuals;
    final effectiveColors =
        colors ?? MiuixSnackbarDefaults.snackbarColors(context);
    final actionLabel = visuals.actionLabel;
    final actionColors = MiuixButtonColors(
      color: effectiveColors.actionContainerColor,
      disabledColor: effectiveColors.actionContainerColor,
      contentColor: effectiveColors.actionContentColor,
      disabledContentColor: effectiveColors.actionContentColor,
    );

    final shape = MiuixSquircleBorder(
      cornerRadius: cornerRadius,
      enabled: cornerRadius > 0,
    );
    final useBlur = blurSigma > 0;
    // 模糊模式下背景色降为半透明，让模糊背景内容透过来。
    final containerColor = useBlur
        ? effectiveColors.containerColor.withValues(alpha: blurBackgroundAlpha)
        : effectiveColors.containerColor;

    Widget card = DecoratedBox(
      decoration: ShapeDecoration(
        color: containerColor,
        shape: shape,
        shadows: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset.zero,
          ),
        ],
      ),
      child: MiuixContentColor(
        color: effectiveColors.contentColor,
        // 提供 Material 祖先：MiuixSurface 不提供 DefaultTextStyle，
        // 不包 Material 会导致内部 MiuixText 出现黄色下划线。
        child: Material(
          type: MaterialType.transparency,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: insideMargin,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: MiuixText(
                      visuals.message,
                      color: effectiveColors.contentColor,
                      style: MiuixTheme.of(context).textStyles.body2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (actionLabel != null && actionLabel.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: MiuixTextButton(
                        actionLabel,
                        onPressed: () => unawaited(data.performAction()),
                        cornerRadius:
                            MiuixSnackbarDefaults.actionCornerRadius,
                        minWidth: 26,
                        minHeight: 26,
                        colors: actionColors,
                        insideMargin:
                            MiuixSnackbarDefaults.actionInsideMargin,
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                    ),
                  if (visuals.withDismissAction)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Semantics(
                        button: true,
                        label: '关闭',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => unawaited(data.dismiss()),
                          child: MiuixIcon(
                            vector: MiuixIcons.basic.close,
                            size: 20,
                            tint:
                                effectiveColors.dismissActionContentColor,
                            contentDescription: 'Dismiss',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // 毛玻璃模式：用 squircle clip + BackdropFilter 包裹卡片背景层。
    // 阴影由外层 DecoratedBox 提供（在 clip 之外，不会被裁掉）。
    if (useBlur) {
      card = DecoratedBox(
        decoration: ShapeDecoration(
          color: const Color(0x00000000),
          shape: shape,
          shadows: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset.zero,
            ),
          ],
        ),
        child: ClipPath(
          clipper: _SquircleClipper(shape),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
            ),
            child: card,
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      liveRegion: true,
      child: Padding(
        padding: MiuixSnackbarDefaults.outerPadding,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: card,
        ),
      ),
    );
  }
}

/// 用 [ShapeBorder.getOuterPath] 包装的 squircle 裁剪器，供 [ClipPath] 使用。
class _SquircleClipper extends CustomClipper<ui.Path> {
  const _SquircleClipper(this.shape);

  final ShapeBorder shape;

  @override
  ui.Path getClip(ui.Size size) =>
      shape.getOuterPath(Offset.zero & size);

  @override
  bool shouldReclip(_SquircleClipper old) => shape != old.shape;
}

/// Snackbar 颜色配置。对应 Kotlin `SnackbarColors`。
@immutable
class MiuixSnackbarColors {
  const MiuixSnackbarColors({
    required this.containerColor,
    required this.contentColor,
    required this.actionContentColor,
    required this.dismissActionContentColor,
    required this.actionContainerColor,
  });

  /// 卡片背景色。
  final Color containerColor;

  /// 消息内容色。
  final Color contentColor;

  /// 操作标签内容色。
  final Color actionContentColor;

  /// 关闭操作内容色。
  final Color dismissActionContentColor;

  /// 操作标签胶囊背景色。
  final Color actionContainerColor;
}

/// Snackbar 默认值。对应 Kotlin `SnackbarDefaults`。
class MiuixSnackbarDefaults {
  MiuixSnackbarDefaults._();

  /// 默认圆角半径。
  static const double cornerRadius = 16;

  /// 默认内部边距。
  static const EdgeInsets insideMargin = EdgeInsets.all(12);

  /// 默认外部边距。
  static const EdgeInsets outerPadding = EdgeInsets.only(
    left: 12,
    right: 12,
    top: 8,
  );

  /// 操作标签胶囊的默认圆角半径。
  static const double actionCornerRadius = 50;

  /// 操作标签胶囊的默认内部边距。
  static const EdgeInsets actionInsideMargin = EdgeInsets.symmetric(
    horizontal: 12,
  );

  /// 从当前主题创建默认 Snackbar 颜色。对应 Kotlin `snackbarColors`。
  static MiuixSnackbarColors snackbarColors(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return MiuixSnackbarColors(
      containerColor: colors.onSecondaryVariant,
      contentColor: colors.secondaryVariant,
      actionContentColor: colors.onPrimary,
      dismissActionContentColor: colors.onSurfaceContainerVariant,
      actionContainerColor: colors.primary,
    );
  }
}

const double _hostBottomPadding = 12;
