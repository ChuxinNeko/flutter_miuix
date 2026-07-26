// Miuix Flutter 移植版 - 纹理模糊（基础）
// 源自 compose-miuix-ui/miuix 的 miuix-blur/TextureEffect.kt（Modifier.textureBlur）。
// 阶段 5A：对 backdrop 快照做高斯模糊 + 颜色控制，裁成 shape，再叠上子内容。
// 模糊交给 Skia/Impeller 的 ui.ImageFilter.blur（内部为可分离两趟 + 逐级降采样，
// 无颗粒），sigma 仍取原版 BLUR_RADIUS_TO_SIGMA=0.45；颜色控制用等价颜色矩阵。
// SPDX-License-Identifier: Apache-2.0

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'miuix_backdrop.dart';
import 'miuix_blur_defaults.dart';

/// 对 [backdrop] 提供的背景做模糊并叠加子内容。对应 Kotlin `Modifier.textureBlur`。
///
/// [shape] 决定裁剪形状（[ShapeBorder]，null=矩形）；[blurRadius] 模糊半径（dp）；
/// [colors] 模糊后颜色调整；[enabled] 为 false 时直接画子内容。
class MiuixTextureBlur extends StatelessWidget {
  const MiuixTextureBlur({
    super.key,
    required this.backdrop,
    this.shape,
    this.blurRadius = MiuixBlurDefaults.blurRadius,
    this.colors = const BlurColors(),
    this.enabled = true,
    this.child,
  });

  final MiuixBackdrop backdrop;
  final ShapeBorder? shape;
  final double blurRadius;
  final BlurColors colors;
  final bool enabled;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final child = this.child ?? const SizedBox.expand();
    if (!enabled) {
      // 禁用：直接画子内容（可能带 shape 裁剪）。
      return _maybeClip(child);
    }
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return _maybeClip(
      _TextureBlurRenderWidget(
        backdrop: backdrop,
        blurRadius: blurRadius,
        colors: colors,
        devicePixelRatio: dpr,
        child: child,
      ),
    );
  }

  Widget _maybeClip(Widget inner) {
    if (shape == null) return inner;
    return ClipPath(clipper: ShapeBorderClipper(shape: shape!), child: inner);
  }
}

class _TextureBlurRenderWidget extends SingleChildRenderObjectWidget {
  const _TextureBlurRenderWidget({
    required this.backdrop,
    required this.blurRadius,
    required this.colors,
    required this.devicePixelRatio,
    required Widget super.child,
  });

  final MiuixBackdrop backdrop;
  final double blurRadius;
  final BlurColors colors;
  final double devicePixelRatio;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderTextureBlur(
      backdrop: backdrop,
      blurRadius: blurRadius,
      colors: colors,
      devicePixelRatio: devicePixelRatio,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderTextureBlur)
      ..backdrop = backdrop
      ..blurRadius = blurRadius
      ..colors = colors
      ..devicePixelRatio = devicePixelRatio;
  }
}

class _RenderTextureBlur extends RenderProxyBox {
  _RenderTextureBlur({
    required this._backdrop,
    required this._blurRadius,
    required this._colors,
    required this._devicePixelRatio,
  }) {
    _backdrop.addListener(markNeedsPaint);
  }

  MiuixBackdrop _backdrop;
  MiuixBackdrop get backdrop => _backdrop;
  set backdrop(MiuixBackdrop value) {
    if (identical(_backdrop, value)) return;
    _backdrop.removeListener(markNeedsPaint);
    _backdrop = value..addListener(markNeedsPaint);
    markNeedsPaint();
  }

  double _blurRadius;
  set blurRadius(double v) {
    if (_blurRadius == v) return;
    _blurRadius = v;
    markNeedsPaint();
  }

  BlurColors _colors;
  set colors(BlurColors v) {
    if (_colors == v) return;
    _colors = v;
    markNeedsPaint();
  }

  double _devicePixelRatio;
  set devicePixelRatio(double v) {
    if (_devicePixelRatio == v) return;
    _devicePixelRatio = v;
    markNeedsPaint();
  }

  @override
  void detach() {
    _backdrop.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _backdrop.addListener(markNeedsPaint);
  }

  @override
  void dispose() {
    _backdrop.removeListener(markNeedsPaint);
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final image = _backdrop.snapshot;
    final backdropGlobal = _backdrop.globalOffset;
    if (image == null || backdropGlobal == null || size.isEmpty) {
      // 背景未就绪：只画子内容。
      super.paint(context, offset);
      return;
    }

    final dpr = _devicePixelRatio;
    // 本区域左上角在快照像素坐标中的偏移。
    final selfGlobal = localToGlobal(Offset.zero);
    final offX = (selfGlobal.dx - backdropGlobal.dx) * dpr;
    final offY = (selfGlobal.dy - backdropGlobal.dy) * dpr;

    // sigma 取逻辑像素（画布未缩放，Skia 会按画布变换换算到设备像素）。
    final radius = _blurRadius.clamp(0.0, MiuixBlurDefaults.maxBlurRadius);
    final sigma = radius * MiuixBlurDefaults.blurRadiusToSigma;

    // 采样背景快照时向外扩一圈（约 3σ），让模糊边缘有真实邻域内容，
    // 避免因取样区外为透明而产生边缘变暗（透明渗入）。
    final marginLogical = sigma <= 0 ? 0.0 : (sigma * 3.0).ceilToDouble();
    final mPx = marginLogical * dpr;
    final wPx = size.width * dpr;
    final hPx = size.height * dpr;

    // 快照像素坐标里的取样区（含 margin），裁进快照边界内。
    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();
    final srcL = (offX - mPx).clamp(0.0, imgW);
    final srcT = (offY - mPx).clamp(0.0, imgH);
    final srcR = (offX + wPx + mPx).clamp(0.0, imgW);
    final srcB = (offY + hPx + mPx).clamp(0.0, imgH);
    if (srcR <= srcL || srcB <= srcT) {
      // 与快照无重叠（罕见）：只画子内容。
      super.paint(context, offset);
      return;
    }
    final src = Rect.fromLTRB(srcL, srcT, srcR, srcB);
    // 目标区按同一像素→逻辑映射（1:1 不拉伸）：logical = offset + (srcPx - off)/dpr。
    final dst = Rect.fromLTRB(
      offset.dx + (srcL - offX) / dpr,
      offset.dy + (srcT - offY) / dpr,
      offset.dx + (srcR - offX) / dpr,
      offset.dy + (srcB - offY) / dpr,
    );

    final canvas = context.canvas;
    final colorFilter = buildBlurColorFilter(_colors);
    final selfRect = offset & size;

    // 关键：把绘制裁进自身边界。dst 向外扩了 3σ margin（让高斯有真实邻域、避免边缘
    // 变暗），但那圈模糊光晕**只应参与采样、不应画到组件外**。无 shape 裁剪时
    // （如顶栏 Positioned.fill 毛玻璃），不裁会导致模糊溢出组件边框。
    canvas.save();
    canvas.clipRect(selfRect);

    // 若有颜色控制：先包一层带 colorFilter 的 layer，使颜色在模糊「之后」作用
    // （对应原版 blur → color controls 的顺序）。
    if (colorFilter != null) {
      canvas.saveLayer(selfRect, Paint()..colorFilter = colorFilter);
    }

    final blurPaint = Paint()..filterQuality = FilterQuality.medium;
    if (sigma > 0) {
      blurPaint.imageFilter =
          ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.clamp);
    }
    canvas.drawImageRect(image, src, dst, blurPaint);

    // blend 颜色层：标准 SkBlendMode 直接用 Flutter BlendMode 叠色块（对应 blendColors）。
    for (final entry in _colors.blendColors) {
      final bm = miuixStandardBlendMode(entry.mode);
      if (bm == null) continue; // 扩展模式暂跳过（需 shader）
      canvas.drawRect(selfRect, Paint()
        ..color = entry.color
        ..blendMode = bm);
    }

    if (colorFilter != null) canvas.restore();
    canvas.restore(); // clipRect

    // 子内容画在模糊之上。
    super.paint(context, offset);
  }
}

