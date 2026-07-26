// Miuix Flutter 移植版 - 按压反馈
// 源自 compose-miuix-ui/miuix 的 utils/Pressable.kt、MiuixIndication.kt 与 PressFeedback.kt。
// 用 Flutter 手势、键盘 Action、Semantics 与 spring 动画复刻按压交互。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme/miuix_motion.dart';
import '../theme/miuix_theme.dart';

/// 按压视觉反馈类型。对应 Kotlin `PressFeedbackType`。
enum MiuixPressFeedbackType {
  /// 无反馈（仅按压遮罩）。
  none,

  /// 按下时轻微下沉缩放。
  sink,

  /// 按下时根据触点位置倾斜（3D）。
  tilt,
}

const double _kHoverAlphaDelta = 0.06;
const double _kFocusAlphaDelta = 0.08;
const double _kPressAlphaDelta = 0.10;

/// 复刻 Kotlin 端的 spring 规格。
SpringDescription _pressEnterSpring() => folmeSpring(damping: 1.0, response: 0.2);
SpringDescription _pressExitSpring() =>
    folmeSpring(damping: 0.95, response: 0.35);
SpringDescription _hoverEnterSpring() => folmeSpring(damping: 1.0, response: 0.6);
SpringDescription _hoverExitSpring() =>
    folmeSpring(damping: 0.96, response: 0.2);

/// Miuix 风格的可按压容器。在子节点之上叠加一层半透明遮罩，按下/悬停/聚焦时
/// 通过 spring 驱动 alpha 变化，可选叠加 sink（下沉缩放）或 tilt（3D 倾斜）反馈。
///
/// 这是对 Kotlin 端 `MiuixIndication` + `SinkFeedback`/`TiltFeedback` 的合并实现。
class MiuixPressable extends StatefulWidget {
  const MiuixPressable({
    super.key,
    required this.onPressed,
    required this.child,
    this.enabled = true,
    this.feedbackType = MiuixPressFeedbackType.none,
    this.sinkAmount = 0.94,
    this.tiltAmount = 8.0,
    this.overlayColor,
    this.borderRadius,
    this.shape,
    this.heldDown = false,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    this.button = true,
    this.behavior = HitTestBehavior.opaque,
    this.onLongPress,
  });

  /// 点击回调。为 null 时 [enabled] 视为 false。
  final VoidCallback? onPressed;

  /// 子节点。
  final Widget child;

  /// 是否启用。
  final bool enabled;

  /// 额外的按压反馈类型。
  final MiuixPressFeedbackType feedbackType;

  /// sink 反馈的缩放目标（默认 0.94）。
  final double sinkAmount;

  /// tilt 反馈的最大倾角（度，默认 8）。
  final double tiltAmount;

  /// 遮罩颜色。默认取自 [MiuixTheme] 的 `onBackground`。
  final Color? overlayColor;

  /// 用于裁剪遮罩与反馈的圆角。null 表示不裁剪。
  ///
  /// 与 [shape] 二选一：若同时提供，[shape] 优先。
  final BorderRadius? borderRadius;

  /// 用于裁剪遮罩与反馈的任意形状（如 squircle/stadium）。
  ///
  /// 提供时优先于 [borderRadius]，遮罩与反馈将按该形状裁剪。
  final ShapeBorder? shape;

  /// 外部强制的“按下保持”状态。对应 Kotlin `HoldDownInteraction`：
  /// 当父组件（如 Preference、弹出菜单项）需要在指针释放后仍保持按压外观时置为 true。
  final bool heldDown;

  /// 是否自动获取焦点。
  final bool autofocus;

  /// 外部焦点节点。
  final FocusNode? focusNode;

  /// 无障碍标签。为 null 时由子节点自身语义提供。
  final String? semanticLabel;

  /// 是否将该容器标记为按钮语义。对多数可点击容器为 true；
  /// 对 Checkbox/Switch 等有专用语义的控件可置为 false，由外层补充语义。
  final bool button;

  /// 点击测试行为。
  final HitTestBehavior behavior;

  /// 长按回调。
  final VoidCallback? onLongPress;

  @override
  State<MiuixPressable> createState() => _MiuixPressableState();
}

class _MiuixPressableState extends State<MiuixPressable>
    with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHovered = false;
  bool _isFocused = false;

  // 遮罩 alpha 的 spring 动画。
  late final AnimationController _overlayController;

  // sink 缩放的 spring 动画。
  late final AnimationController _sinkController;

  // tilt 的 spring 动画。
  late final AnimationController _tiltXController;
  late final AnimationController _tiltYController;
  double _tiltXTarget = 0.0;
  double _tiltYTarget = 0.0;
  Alignment _tiltOrigin = Alignment.center;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController.unbounded(vsync: this);
    _sinkController = AnimationController.unbounded(vsync: this)
      ..value = 1.0;
    _tiltXController = AnimationController.unbounded(vsync: this);
    _tiltYController = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _sinkController.dispose();
    _tiltXController.dispose();
    _tiltYController.dispose();
    super.dispose();
  }

  bool get _effectiveEnabled => widget.enabled && widget.onPressed != null;

  double _targetOverlayAlpha() {
    var target = 0.0;
    if (_isHovered) target += _kHoverAlphaDelta;
    if (_isFocused) target += _kFocusAlphaDelta;
    if (_isPressed || widget.heldDown) target += _kPressAlphaDelta;
    return target;
  }

  @override
  void didUpdateWidget(MiuixPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.heldDown != widget.heldDown) {
      // heldDown 变化时按对应方向重放遮罩与反馈动画。
      _animateOverlay(
        widget.heldDown ? _pressEnterSpring() : _pressExitSpring(),
      );
      switch (widget.feedbackType) {
        case MiuixPressFeedbackType.sink:
          _animateSink();
          break;
        case MiuixPressFeedbackType.tilt:
        case MiuixPressFeedbackType.none:
          break;
      }
    }
  }

  void _animateOverlay(SpringDescription spring) {
    final target = _targetOverlayAlpha();
    _overlayController.animateWith(_SpringSimulation(
      spring,
      start: _overlayController.value,
      end: target,
    ));
  }

  void _animateSink() {
    final target = (_isPressed || widget.heldDown) ? widget.sinkAmount : 1.0;
    _sinkController.animateWith(_SpringSimulation(
      folmeSpring(damping: 0.8, response: 0.4),
      start: _sinkController.value,
      end: target,
    ));
  }

  void _animateTilt() {
    final tx = _isPressed ? _tiltXTarget : 0.0;
    final ty = _isPressed ? _tiltYTarget : 0.0;
    _tiltXController.animateWith(_SpringSimulation(
      folmeSpring(damping: 0.6, response: 0.4),
      start: _tiltXController.value,
      end: tx,
    ));
    _tiltYController.animateWith(_SpringSimulation(
      folmeSpring(damping: 0.6, response: 0.4),
      start: _tiltYController.value,
      end: ty,
    ));
  }

  void _setPressed(bool value, {Offset? position}) {
    if (_isPressed == value) return;
    _isPressed = value;
    if (value && position != null && widget.feedbackType == MiuixPressFeedbackType.tilt) {
      // 根据触点位置计算倾斜方向与原点。
      _tiltOrigin = Alignment(
        position.dx < 0.5 ? 1.0 : -1.0,
        position.dy < 0.5 ? 1.0 : -1.0,
      );
      _tiltXTarget = (position.dy < 0.5 ? 1.0 : -1.0) * widget.tiltAmount;
      _tiltYTarget = (position.dx < 0.5 ? -1.0 : 1.0) * widget.tiltAmount;
    }
    _animateOverlay(value ? _pressEnterSpring() : _pressExitSpring());
    switch (widget.feedbackType) {
      case MiuixPressFeedbackType.sink:
        _animateSink();
        break;
      case MiuixPressFeedbackType.tilt:
        _animateTilt();
        break;
      case MiuixPressFeedbackType.none:
        break;
    }
  }

  void _setHovered(bool value) {
    if (_isHovered == value) return;
    _isHovered = value;
    _animateOverlay(value ? _hoverEnterSpring() : _hoverExitSpring());
  }

  void _setFocused(bool value) {
    if (_isFocused == value) return;
    _isFocused = value;
    _animateOverlay(value ? _hoverEnterSpring() : _hoverExitSpring());
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _effectiveEnabled;
    final theme = MiuixTheme.maybeOf(context);
    final overlayColor =
        widget.overlayColor ?? theme?.colors.onBackground ?? const Color(0xFF000000);
    final radius = widget.borderRadius;
    final shape = widget.shape;

    Widget content = widget.child;

    // 倾斜/下沉反馈：用 AnimatedBuilder 包一层 Transform。
    if (widget.feedbackType == MiuixPressFeedbackType.sink) {
      content = AnimatedBuilder(
        animation: _sinkController,
        builder: (context, child) => Transform.scale(
          scale: _sinkController.value,
          child: child,
        ),
        child: content,
      );
    } else if (widget.feedbackType == MiuixPressFeedbackType.tilt) {
      content = AnimatedBuilder(
        animation: Listenable.merge([_tiltXController, _tiltYController]),
        builder: (context, child) => Transform(
          alignment: _tiltOrigin,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_tiltXController.value * 0.0174533)
            ..rotateY(_tiltYController.value * 0.0174533),
          child: child,
        ),
        child: content,
      );
    }

    // 遮罩层。
    content = Stack(
      fit: StackFit.passthrough,
      children: [
        content,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _overlayController,
              builder: (context, _) {
                final alpha = _overlayController.value;
                if (alpha <= 0) return const SizedBox.shrink();
                final resolved =
                    overlayColor.withValues(alpha: alpha.clamp(0.0, 1.0));
                if (shape != null) {
                  return DecoratedBox(
                    decoration: ShapeDecoration(
                      color: resolved,
                      shape: shape,
                    ),
                  );
                }
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: resolved,
                    borderRadius: radius,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );

    if (shape != null) {
      content = ClipPath(
        clipper: ShapeBorderClipper(
          shape: shape,
          textDirection: Directionality.maybeOf(context),
        ),
        child: content,
      );
    } else if (radius != null) {
      content = ClipRRect(borderRadius: radius, child: content);
    }

    void handleActivate() {
      if (!enabled) return;
      _setPressed(false);
      widget.onPressed!();
    }

    content = GestureDetector(
      behavior: widget.behavior,
      onTapDown: enabled
          ? (d) {
              final box = context.findRenderObject() as RenderBox?;
              final size = box?.size ?? Size.zero;
              final pos = size.isEmpty
                  ? const Offset(0.5, 0.5)
                  : Offset(
                      (d.localPosition.dx / size.width).clamp(0.0, 1.0),
                      (d.localPosition.dy / size.height).clamp(0.0, 1.0),
                    );
              _setPressed(true, position: pos);
            }
          : null,
      onTapUp: enabled
          ? (_) {
              _setPressed(false);
              widget.onPressed!();
            }
          : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onLongPress: enabled ? widget.onLongPress : null,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: enabled ? (_) => _setHovered(true) : null,
        onExit: enabled ? (_) => _setHovered(false) : null,
        child: FocusableActionDetector(
          enabled: enabled,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          onShowFocusHighlight: enabled ? _setFocused : null,
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                handleActivate();
                return null;
              },
            ),
          },
          child: content,
        ),
      ),
    );

    return Semantics(
      button: widget.button,
      enabled: enabled,
      label: widget.semanticLabel,
      onTap: enabled ? handleActivate : null,
      child: content,
    );
  }
}

/// 用 [SpringDescription] 驱动的简单模拟，把 [AnimationController.animateWith]
/// 接到 SpringSimulation 上。
class _SpringSimulation extends Simulation {
  _SpringSimulation(this.desc, {required double start, required double end})
      : _simulation = SpringSimulation(desc, start, end, 0);

  final SpringDescription desc;
  final SpringSimulation _simulation;

  @override
  double x(double time) => _simulation.x(time);

  @override
  double dx(double time) => _simulation.dx(time);

  @override
  bool isDone(double time) => _simulation.isDone(time);
}
