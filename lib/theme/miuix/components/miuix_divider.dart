// Miuix Flutter 移植版 - Divider
// 源自 compose-miuix-ui/miuix 的 Divider.kt。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../theme/miuix_theme.dart';

/// Divider 默认值。对应 Kotlin `DividerDefaults`。
class MiuixDividerDefaults {
  MiuixDividerDefaults._();

  /// 默认厚度 0.75dp。
  static const double thickness = 0.75;

  /// 默认颜色，取自 `MiuixTheme.colors.dividerLine`。
  static Color dividerColor(BuildContext context) =>
      MiuixTheme.of(context).colors.dividerLine;
}

/// 水平分隔线。对应 Kotlin `HorizontalDivider`。
class MiuixHorizontalDivider extends StatelessWidget {
  const MiuixHorizontalDivider({
    super.key,
    this.thickness = MiuixDividerDefaults.thickness,
    this.color,
  });

  final double thickness;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? MiuixDividerDefaults.dividerColor(context);
    return SizedBox(
      width: double.infinity,
      height: thickness,
      child: CustomPaint(
        painter: _HorizontalLinePainter(color: c, thickness: thickness),
      ),
    );
  }
}

/// 垂直分隔线。对应 Kotlin `VerticalDivider`。
class MiuixVerticalDivider extends StatelessWidget {
  const MiuixVerticalDivider({
    super.key,
    this.thickness = MiuixDividerDefaults.thickness,
    this.color,
  });

  final double thickness;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? MiuixDividerDefaults.dividerColor(context);
    return SizedBox(
      height: double.infinity,
      width: thickness,
      child: CustomPaint(
        painter: _VerticalLinePainter(color: c, thickness: thickness),
      ),
    );
  }
}

class _HorizontalLinePainter extends CustomPainter {
  const _HorizontalLinePainter({required this.color, required this.thickness});

  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final half = thickness / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness;
    canvas.drawLine(
      Offset(0, half),
      Offset(size.width, half),
      paint,
    );
  }

  @override
  bool shouldRepaint(_HorizontalLinePainter oldDelegate) =>
      color != oldDelegate.color || thickness != oldDelegate.thickness;
}

class _VerticalLinePainter extends CustomPainter {
  const _VerticalLinePainter({required this.color, required this.thickness});

  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final half = thickness / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness;
    canvas.drawLine(
      Offset(half, 0),
      Offset(half, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_VerticalLinePainter oldDelegate) =>
      color != oldDelegate.color || thickness != oldDelegate.thickness;
}
