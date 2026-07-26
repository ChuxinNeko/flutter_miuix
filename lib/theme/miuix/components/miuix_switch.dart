// Miuix Flutter 移植版 - Switch
// 源自 compose-miuix-ui/miuix 的 Switch.kt。
// 49x28 胶囊轨道 + 20dp 圆形 thumb，按下/悬停/拖拽时 thumb 放大至 1.127，
// 支持点击切换与水平拖拽切换。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme/miuix_motion.dart';
import '../theme/miuix_theme.dart';

/// Switch 颜色配置。对应 Kotlin `SwitchColors`。
@immutable
class MiuixSwitchColors {
  const MiuixSwitchColors({
    required this.checkedThumbColor,
    required this.uncheckedThumbColor,
    required this.disabledCheckedThumbColor,
    required this.disabledUncheckedThumbColor,
    required this.checkedTrackColor,
    required this.uncheckedTrackColor,
    required this.disabledCheckedTrackColor,
    required this.disabledUncheckedTrackColor,
  });

  final Color checkedThumbColor;
  final Color uncheckedThumbColor;
  final Color disabledCheckedThumbColor;
  final Color disabledUncheckedThumbColor;
  final Color checkedTrackColor;
  final Color uncheckedTrackColor;
  final Color disabledCheckedTrackColor;
  final Color disabledUncheckedTrackColor;
}

class MiuixSwitchDefaults {
  MiuixSwitchDefaults._();

  static const double trackWidth = 49;
  static const double trackHeight = 28;
  static const double thumbSize = 20;
  static const double thumbOffsetOff = 4;
  static const double thumbOffsetOn = 25;
  static const double thumbScaleActive = 1.127;

  static MiuixSwitchColors switchColors(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    return MiuixSwitchColors(
      checkedThumbColor: c.onPrimary,
      uncheckedThumbColor: c.onSecondary,
      disabledCheckedThumbColor: c.disabledOnPrimary,
      disabledUncheckedThumbColor: c.disabledOnSecondary,
      checkedTrackColor: c.primary,
      uncheckedTrackColor: c.secondary,
      disabledCheckedTrackColor: c.disabledPrimary,
      disabledUncheckedTrackColor: c.disabledSecondary,
    );
  }
}

/// Miuix 风格的开关。对应 Kotlin `Switch`。
class MiuixSwitch extends StatefulWidget {
  const MiuixSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.colors,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final MiuixSwitchColors? colors;

  @override
  State<MiuixSwitch> createState() => _MiuixSwitchState();
}

class _MiuixSwitchState extends State<MiuixSwitch>
    with TickerProviderStateMixin {
  late final AnimationController _thumbPos;
  late final AnimationController _thumbScale;
  bool _isPressed = false;
  bool _isHovered = false;
  bool _isDragging = false;
  double _dragOffset = 0; // 相对静止位置的偏移，正值向开方向

  /// 当前是否为 RTL 布局。thumb 位置与拖拽方向据此镜像。
  bool get _isRtl => Directionality.of(context) == TextDirection.rtl;

  @override
  void initState() {
    super.initState();
    _thumbPos = AnimationController.unbounded(
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
    );
    _thumbScale = AnimationController.unbounded(vsync: this, value: 1.0);
  }

  @override
  void didUpdateWidget(MiuixSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animateThumbPos(widget.value ? 1.0 : 0.0);
    }
  }

  @override
  void dispose() {
    _thumbPos.dispose();
    _thumbScale.dispose();
    super.dispose();
  }

  bool get _effectiveEnabled => widget.enabled && widget.onChanged != null;

  void _animateThumbPos(double target) {
    _thumbPos.animateWith(_SpringSim(
      folmeSpring(damping: 0.7, response: _responseFromStiffness(987)),
      start: _thumbPos.value,
      end: target,
    ));
  }

  void _updateScale() {
    // 对应 Kotlin：isPressed || isDragged || isHovered → 1.127，禁用时恒为 1。
    final active = _isPressed || _isDragging || _isHovered;
    final target = (!widget.enabled)
        ? 1.0
        : (active ? MiuixSwitchDefaults.thumbScaleActive : 1.0);
    _thumbScale.animateWith(_SpringSim(
      folmeSpring(damping: 0.6, response: _responseFromStiffness(987)),
      start: _thumbScale.value,
      end: target,
    ));
  }

  double _responseFromStiffness(double stiffness) {
    // stiffness = (2π/response)² → response = 2π/√stiffness
    return 2 * math.pi / math.sqrt(stiffness);
  }

  void _toggle() {
    widget.onChanged?.call(!widget.value);
    HapticFeedback.lightImpact();
  }

  void _onDragStart() {
    // 进入拖拽态：清除 tap 的按下态（避免 scale 状态混淆），并重置累计偏移。
    _isPressed = false;
    _isDragging = true;
    _dragOffset = 0;
    _updateScale();
  }

  void _onDragUpdate(double dx) {
    setState(() {
      // RTL 下向左拖拽为"开"方向，需镜像 dx。
      final delta = _isRtl ? -dx : dx;
      // dx 累计到 _dragOffset，范围 [-21, 21]（off→on 距离 21px）
      _dragOffset = (_dragOffset + delta).clamp(-21.0, 21.0);
      final base = widget.value ? 1.0 : 0.0;
      final dragProgress = (_dragOffset / 21.0).clamp(-1.0, 1.0);
      _thumbPos.value = (base + dragProgress).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd() {
    if (_dragOffset.abs() > 21.0 / 2) {
      _toggle();
    }
    _isDragging = false;
    setState(() => _dragOffset = 0);
    _updateScale();
    _animateThumbPos(widget.value ? 1.0 : 0.0);
  }

  void _onDragCancel() {
    // 拖拽被系统取消（如被父级手势竞争抢占）：复位状态并弹回静止位置。
    _isDragging = false;
    setState(() => _dragOffset = 0);
    _updateScale();
    _animateThumbPos(widget.value ? 1.0 : 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        widget.colors ?? MiuixSwitchDefaults.switchColors(context);
    final enabled = _effectiveEnabled;
    final trackColor = widget.value
        ? (enabled ? colors.checkedTrackColor : colors.disabledCheckedTrackColor)
        : (enabled
            ? colors.uncheckedTrackColor
            : colors.disabledUncheckedTrackColor);
    final thumbColor = widget.value
        ? (enabled
            ? colors.checkedThumbColor
            : colors.disabledCheckedThumbColor)
        : (enabled
            ? colors.uncheckedThumbColor
            : colors.disabledUncheckedThumbColor);

    return Semantics(
      // 对应 Kotlin `Role.Switch` + `toggleableState` + `disabled()`：
      // 向无障碍服务暴露开关的 toggled/enabled 语义。
      // enabled 语义跟随 widget.enabled（对应 Kotlin 的 `if (!enabled) disabled()`），
      // 而 tap action 仅在存在回调且启用时可用。
      container: true,
      toggled: widget.value,
      enabled: widget.enabled,
      onTap: enabled ? _toggle : null,
      child: MouseRegion(
        onEnter: enabled ? (_) { _isHovered = true; _updateScale(); } : null,
        onExit: enabled ? (_) { _isHovered = false; _updateScale(); } : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled
              ? (_) {
                  _isPressed = true;
                  _updateScale();
                }
              : null,
          onTapUp: enabled
              ? (_) {
                  // 普通点击：切换并复位按下态，避免 thumb scale 卡在放大状态。
                  _isPressed = false;
                  _toggle();
                  _updateScale();
                }
              : null,
          onTapCancel: enabled
              ? () {
                  _isPressed = false;
                  _updateScale();
                }
              : null,
          onHorizontalDragStart: enabled ? (_) => _onDragStart() : null,
          onHorizontalDragUpdate: enabled
              ? (d) => _onDragUpdate(d.delta.dx)
              : null,
          onHorizontalDragEnd: enabled ? (_) => _onDragEnd() : null,
          onHorizontalDragCancel: enabled ? _onDragCancel : null,
          child: SizedBox(
            width: MiuixSwitchDefaults.trackWidth,
            height: MiuixSwitchDefaults.trackHeight,
            child: Stack(
              children: [
                // 轨道
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(
                          MiuixSwitchDefaults.trackHeight / 2),
                    ),
                  ),
                ),
                // Thumb
                AnimatedBuilder(
                  animation: Listenable.merge([_thumbPos, _thumbScale]),
                  builder: (context, _) {
                    final pos = _thumbPos.value;
                    final offset = MiuixSwitchDefaults.thumbOffsetOff +
                        (MiuixSwitchDefaults.thumbOffsetOn -
                                MiuixSwitchDefaults.thumbOffsetOff) *
                            pos;
                    final scale = _thumbScale.value;
                    final size = MiuixSwitchDefaults.thumbSize * scale;
                    final left =
                        offset - (size - MiuixSwitchDefaults.thumbSize) / 2;
                    final thumb = Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: thumbColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    );
                    // RTL 下从右侧起算，镜像 thumb 位置。
                    return Positioned(
                      left: _isRtl ? null : left,
                      right: _isRtl ? left : null,
                      top: (MiuixSwitchDefaults.trackHeight - size) / 2,
                      child: thumb,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpringSim extends Simulation {
  _SpringSim(SpringDescription desc,
      {required double start, required double end})
      : _sim = SpringSimulation(desc, start, end, 0);

  final SpringSimulation _sim;

  @override
  double x(double time) => _sim.x(time);

  @override
  double dx(double time) => _sim.dx(time);

  @override
  bool isDone(double time) => _sim.isDone(time);
}
