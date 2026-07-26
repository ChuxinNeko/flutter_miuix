// Miuix Flutter 移植版 - Checkbox
// 源自 compose-miuix-ui/miuix 的 Checkbox.kt。
// 26dp 圆形背景 + 带 trim 动画的勾号，支持 On/Off/Indeterminate 三态。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/miuix_pressable.dart';
import '../theme/miuix_theme.dart';

/// Checkbox 颜色配置。对应 Kotlin `CheckboxColors`。
@immutable
class MiuixCheckboxColors {
  const MiuixCheckboxColors({
    required this.checkedForegroundColor,
    required this.uncheckedForegroundColor,
    required this.disabledCheckedForegroundColor,
    required this.disabledUncheckedForegroundColor,
    required this.checkedBackgroundColor,
    required this.uncheckedBackgroundColor,
    required this.disabledCheckedBackgroundColor,
    required this.disabledUncheckedBackgroundColor,
  });

  final Color checkedForegroundColor;
  final Color uncheckedForegroundColor;
  final Color disabledCheckedForegroundColor;
  final Color disabledUncheckedForegroundColor;
  final Color checkedBackgroundColor;
  final Color uncheckedBackgroundColor;
  final Color disabledCheckedBackgroundColor;
  final Color disabledUncheckedBackgroundColor;
}

class MiuixCheckboxDefaults {
  MiuixCheckboxDefaults._();

  static const double size = 26;

  static MiuixCheckboxColors checkboxColors(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    return MiuixCheckboxColors(
      checkedForegroundColor: c.onPrimary,
      uncheckedForegroundColor: c.secondary,
      disabledCheckedForegroundColor: c.disabledOnPrimary,
      disabledUncheckedForegroundColor: c.disabledOnPrimary,
      checkedBackgroundColor: c.primary,
      uncheckedBackgroundColor: c.secondary,
      disabledCheckedBackgroundColor: c.disabledPrimary,
      disabledUncheckedBackgroundColor: c.disabledSecondary,
    );
  }
}

/// Miuix 风格的复选框。对应 Kotlin `Checkbox`。
///
/// [value]：true=On，false=Off，null=Indeterminate。
class MiuixCheckbox extends StatefulWidget {
  const MiuixCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.colors,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;
  final MiuixCheckboxColors? colors;

  @override
  State<MiuixCheckbox> createState() => _MiuixCheckboxState();
}

class _MiuixCheckboxState extends State<MiuixCheckbox>
    with TickerProviderStateMixin {
  late final AnimationController _alpha;
  late final AnimationController _trim;
  late final AnimationController _indet;

  @override
  void initState() {
    super.initState();
    _alpha = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: _isOnOrIndet(widget.value) ? 1.0 : 0.0,
    );
    _trim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: _isOnOrIndet(widget.value) ? 1.0 : 0.0,
    );
    _indet = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.value == null ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(MiuixCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final onOrIndet = _isOnOrIndet(widget.value);
    _alpha.animateTo(onOrIndet ? 1.0 : 0.0,
        curve: Curves.fastOutSlowIn);
    _trim.animateTo(onOrIndet ? 1.0 : 0.0, curve: Curves.fastOutSlowIn);
    _indet.animateTo(widget.value == null ? 1.0 : 0.0,
        curve: Curves.fastOutSlowIn);
  }

  @override
  void dispose() {
    _alpha.dispose();
    _trim.dispose();
    _indet.dispose();
    super.dispose();
  }

  static bool _isOnOrIndet(bool? v) => v != false;

  bool get _effectiveEnabled => widget.enabled && widget.onChanged != null;

  void _handleTap() {
    if (!_effectiveEnabled) return;
    // On → Off, Off → On, Indeterminate → On
    final next = widget.value == null
        ? true
        : (widget.value == true ? false : true);
    widget.onChanged?.call(next);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        widget.colors ?? MiuixCheckboxDefaults.checkboxColors(context);
    final enabled = _effectiveEnabled;
    final isOn = _isOnOrIndet(widget.value);
    final bgColor = isOn
        ? (enabled
            ? colors.checkedBackgroundColor
            : colors.disabledCheckedBackgroundColor)
        : (enabled
            ? colors.uncheckedBackgroundColor
            : colors.disabledUncheckedBackgroundColor);
    final fgColor = isOn
        ? (enabled
            ? colors.checkedForegroundColor
            : colors.disabledCheckedForegroundColor)
        : (enabled
            ? colors.uncheckedForegroundColor
            : colors.disabledUncheckedForegroundColor);

    return MiuixPressable(
      onPressed: _effectiveEnabled ? _handleTap : null,
      feedbackType: MiuixPressFeedbackType.sink,
      sinkAmount: 0.85,
      borderRadius: BorderRadius.circular(MiuixCheckboxDefaults.size / 2),
      child: SizedBox(
        width: MiuixCheckboxDefaults.size,
        height: MiuixCheckboxDefaults.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_alpha, _trim, _indet]),
          builder: (context, _) => CustomPaint(
            painter: _CheckboxPainter(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              alpha: _alpha.value,
              trim: _trim.value,
              indet: _indet.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckboxPainter extends CustomPainter {
  _CheckboxPainter({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.alpha,
    required this.trim,
    required this.indet,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final double alpha;
  final double trim; // 0=off, 1=on
  final double indet; // 0=normal, 1=indeterminate

  @override
  void paint(Canvas canvas, Size size) {
    // 背景
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        size.width / 2, bgPaint);

    if (alpha <= 0) return;

    // 勾号坐标（viewport 23x23）：start(5,9.4) middle(10.3,14.9) end(17.9,5.1)
    final vp = 23.0;
    final w = size.width;
    final cx = w / 2;
    final cy = size.height / 2;
    final vc = vp / 2;
    Offset toCanvas(double x, double y) => Offset(
          cx + (x - vc) / vp * w,
          cy + (y - vc) / vp * size.height,
        );

    var start = toCanvas(5, 9.4);
    var mid = toCanvas(10.3, 14.9);
    var end = toCanvas(17.9, 5.1);

    // indeterminate 时把各点向中心 y 拉近，形成水平横杠。
    start = Offset(start.dx, _lerp(start.dy, cy, indet));
    mid = Offset(_lerp(mid.dx, cx, indet), _lerp(mid.dy, cy, indet));
    end = Offset(end.dx, _lerp(end.dy, cy, indet));

    final strokeWidth = w * 0.09;
    final paint = Paint()
      ..color = foregroundColor.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // trim: off 时 trimStart=0.1/trimEnd=0.1，on 时 0.186/0.803
    final trimStart = _lerp(0.1, 0.186, trim);
    final trimEnd = _lerp(0.1, 0.803, trim);

    final firstLen = (mid - start).distance;
    final secondLen = (end - mid).distance;
    final total = firstLen + secondLen;
    final startDist = total * trimStart;
    final endDist = total * trimEnd;

    final path = Path();
    if (endDist > 0 && startDist < firstLen) {
      final sR = (startDist / firstLen).clamp(0.0, 1.0);
      final eR = (endDist / firstLen).clamp(0.0, 1.0);
      final p1 = Offset(
          start.dx + (mid.dx - start.dx) * sR,
          start.dy + (mid.dy - start.dy) * sR);
      final p2 = Offset(
          start.dx + (mid.dx - start.dx) * eR,
          start.dy + (mid.dy - start.dy) * eR);
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
    }
    if (endDist > firstLen) {
      final sR =
          ((startDist - firstLen) / secondLen).clamp(0.0, 1.0);
      final eR = ((endDist - firstLen) / secondLen).clamp(0.0, 1.0);
      final p1 = Offset(
          mid.dx + (end.dx - mid.dx) * sR,
          mid.dy + (end.dy - mid.dy) * sR);
      final p2 = Offset(
          mid.dx + (end.dx - mid.dx) * eR,
          mid.dy + (end.dy - mid.dy) * eR);
      if (startDist < firstLen) {
        path.lineTo(p2.dx, p2.dy);
      } else {
        path.moveTo(p1.dx, p1.dy);
        path.lineTo(p2.dx, p2.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(_CheckboxPainter oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor ||
      foregroundColor != oldDelegate.foregroundColor ||
      alpha != oldDelegate.alpha ||
      trim != oldDelegate.trim ||
      indet != oldDelegate.indet;
}
