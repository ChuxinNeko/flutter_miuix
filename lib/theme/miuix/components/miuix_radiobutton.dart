// Miuix Flutter 移植版 - RadioButton
// 源自 compose-miuix-ui/miuix 的 RadioButton.kt。
// 26dp，选中时显示带 trim 动画的勾号（无背景圆），颜色取 primary。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/miuix_pressable.dart';
import '../theme/miuix_theme.dart';

/// RadioButton 颜色配置。对应 Kotlin `RadioButtonColors`。
@immutable
class MiuixRadioButtonColors {
  const MiuixRadioButtonColors({
    required this.selectedColor,
    required this.disabledSelectedColor,
  });

  final Color selectedColor;
  final Color disabledSelectedColor;
}

class MiuixRadioButtonDefaults {
  MiuixRadioButtonDefaults._();

  static const double size = 26;

  static MiuixRadioButtonColors radioButtonColors(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    return MiuixRadioButtonColors(
      selectedColor: c.primary,
      disabledSelectedColor: c.disabledPrimary,
    );
  }
}

/// Miuix 风格的单选按钮。对应 Kotlin `RadioButton`。
class MiuixRadioButton extends StatefulWidget {
  const MiuixRadioButton({
    super.key,
    required this.selected,
    this.onChanged,
    this.enabled = true,
    this.colors,
  });

  final bool selected;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final MiuixRadioButtonColors? colors;

  @override
  State<MiuixRadioButton> createState() => _MiuixRadioButtonState();
}

class _MiuixRadioButtonState extends State<MiuixRadioButton>
    with TickerProviderStateMixin {
  late final AnimationController _alpha;
  late final AnimationController _trim;

  @override
  void initState() {
    super.initState();
    _alpha = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: widget.selected ? 1.0 : 0.0,
    );
    _trim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.selected ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(MiuixRadioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _alpha.animateTo(widget.selected ? 1.0 : 0.0,
        curve: Curves.fastOutSlowIn);
    _trim.animateTo(widget.selected ? 1.0 : 0.0, curve: Curves.fastOutSlowIn);
  }

  @override
  void dispose() {
    _alpha.dispose();
    _trim.dispose();
    super.dispose();
  }

  bool get _effectiveEnabled => widget.enabled && widget.onChanged != null;

  void _handleTap() {
    if (!_effectiveEnabled || widget.selected) return;
    widget.onChanged?.call(true);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        widget.colors ?? MiuixRadioButtonDefaults.radioButtonColors(context);
    final enabled = _effectiveEnabled;
    final color = enabled
        ? colors.selectedColor
        : colors.disabledSelectedColor;

    return MiuixPressable(
      onPressed: _effectiveEnabled ? _handleTap : null,
      feedbackType: MiuixPressFeedbackType.sink,
      sinkAmount: 0.85,
      child: SizedBox(
        width: MiuixRadioButtonDefaults.size,
        height: MiuixRadioButtonDefaults.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_alpha, _trim]),
          builder: (context, _) => CustomPaint(
            painter: _RadioButtonPainter(
              color: color,
              alpha: _alpha.value,
              trim: _trim.value,
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioButtonPainter extends CustomPainter {
  _RadioButtonPainter({
    required this.color,
    required this.alpha,
    required this.trim,
  });

  final Color color;
  final double alpha;
  final double trim;

  @override
  void paint(Canvas canvas, Size size) {
    if (alpha <= 0 || trim <= 0) return;

    // 勾号坐标（viewport 56x56）：start(10.9,29) middle(23.1,40.8) end(44,16)
    final vp = 56.0;
    final w = size.width;
    final cx = w / 2;
    final cy = size.height / 2;
    final vc = vp / 2;
    Offset toCanvas(double x, double y) => Offset(
          cx + (x - vc) / vp * w,
          cy + (y - vc) / vp * size.height,
        );
    final start = toCanvas(10.9, 29);
    final mid = toCanvas(23.1, 40.8);
    final end = toCanvas(44, 16);

    final strokeWidth = 7.0 / vp * w;
    final paint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final firstLen = (mid - start).distance;
    final secondLen = (end - mid).distance;
    final total = firstLen + secondLen;
    final endDist = total * trim;

    final path = Path()..moveTo(start.dx, start.dy);
    if (endDist <= firstLen) {
      final r = endDist / firstLen;
      path.lineTo(
        start.dx + (mid.dx - start.dx) * r,
        start.dy + (mid.dy - start.dy) * r,
      );
    } else {
      path.lineTo(mid.dx, mid.dy);
      final r = ((endDist - firstLen) / secondLen).clamp(0.0, 1.0);
      path.lineTo(
        mid.dx + (end.dx - mid.dx) * r,
        mid.dy + (end.dy - mid.dy) * r,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RadioButtonPainter oldDelegate) =>
      color != oldDelegate.color ||
      alpha != oldDelegate.alpha ||
      trim != oldDelegate.trim;
}
