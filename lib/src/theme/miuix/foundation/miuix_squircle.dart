// Miuix Flutter 移植版 - Squircle 超椭圆圆角
// 源自 compose-miuix-ui/miuix-squircle 的 SquirclePath.kt。
// HyperOS 标志性的平滑圆角，用三次贝塞尔（控制比例 0.643）逼近超椭圆。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Squircle 共享默认常量。
class SquircleDefaults {
  SquircleDefaults._();

  /// 圆角瓦片尺寸相对 [cornerRadius] 的倍数。1.0=圆弧，1.1=连续圆角。
  static const double extension = 1.1;

  /// [extension] 的下限。
  static const double extensionMin = 1.0;

  /// [extension] 的上限。
  static const double extensionMax = 2.0;
}

/// Cubic Bézier 控制比例，与原库的 SDF 预烘焙值保持一致。
const double _kSquircleControl = 0.643;

/// 向 [path] 追加一个 squircle 圆角矩形。对应 Kotlin `Path.addSquircleRect`。
///
/// [width]/[height] 为像素尺寸，非正则不追加任何内容。
/// [cornerRadius] 会被夹到短边的一半。
/// [extension] 控制圆角瓦片相对 [cornerRadius] 的倍数，被夹到
/// [SquircleDefaults.extensionMin]..[SquircleDefaults.extensionMax]。
/// [enabled] 为 false 时退化为普通圆角矩形。
void addSquircleRect(
  Path path,
  double width,
  double height,
  double cornerRadius, {
  double extension = SquircleDefaults.extension,
  bool enabled = true,
}) {
  if (width <= 0 || height <= 0) return;
  if (!enabled) {
    final radius = cornerRadius.clamp(0.0, math.min(width, height) * 0.5);
    if (radius <= 0) {
      path.addRect(Rect.fromLTWH(0, 0, width, height));
    } else {
      path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        Radius.circular(radius),
      ));
    }
    return;
  }
  final extClamped =
      extension.clamp(SquircleDefaults.extensionMin, SquircleDefaults.extensionMax);
  final halfMin = math.min(width, height) * 0.5;
  final tile = (cornerRadius * extClamped).clamp(0.0, halfMin);
  if (tile <= 0) {
    path.addRect(Rect.fromLTWH(0, 0, width, height));
    return;
  }
  final handle = tile * (1.0 - _kSquircleControl);
  path
    ..moveTo(tile, 0)
    ..lineTo(width - tile, 0)
    ..cubicTo(width - handle, 0, width, handle, width, tile)
    ..lineTo(width, height - tile)
    ..cubicTo(width, height - handle, width - handle, height, width - tile, height)
    ..lineTo(tile, height)
    ..cubicTo(handle, height, 0, height - handle, 0, height - tile)
    ..lineTo(0, tile)
    ..cubicTo(0, handle, handle, 0, tile, 0)
    ..close();
}

/// 一个 [ShapeBorder]，轮廓为 squircle。可直接用于 [ShapeDecoration]、
/// [PhysicalShape]、[Material] 等。
class MiuixSquircleBorder extends ShapeBorder {
  const MiuixSquircleBorder({
    this.cornerRadius = 0.0,
    this.extension = SquircleDefaults.extension,
    this.enabled = true,
    this.side = BorderSide.none,
  });

  /// 圆角半径（逻辑像素）。
  final double cornerRadius;

  /// 圆角瓦片倍数，默认 1.1。
  final double extension;

  /// 是否启用 squircle；false 则退化为普通圆角。
  final bool enabled;

  /// 边框。
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    addSquircleRect(
      path,
      rect.width,
      rect.height,
      cornerRadius,
      extension: extension,
      enabled: enabled,
    );
    return path.shift(rect.topLeft);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side == BorderSide.none) return;
    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, side.toPaint());
  }

  @override
  ShapeBorder scale(double t) {
    return MiuixSquircleBorder(
      cornerRadius: cornerRadius * t,
      extension: extension,
      enabled: enabled,
      side: side.scale(t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MiuixSquircleBorder &&
        other.cornerRadius == cornerRadius &&
        other.extension == extension &&
        other.enabled == enabled &&
        other.side == side;
  }

  @override
  int get hashCode =>
      Object.hash(cornerRadius, extension, enabled, side);
}
