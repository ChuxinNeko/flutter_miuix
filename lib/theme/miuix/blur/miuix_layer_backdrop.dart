// Miuix Flutter 移植版 - 图层背景捕获
// 源自 compose-miuix-ui/miuix 的 miuix-blur/LayerBackdropModifier.kt（Modifier.layerBackdrop）。
// 用一个 RenderProxyBox 在每帧把子树绘制录进 ui.Image 快照，并上报全局坐标，
// 供 MiuixLayerBackdrop 提供给模糊组件按偏移取样。等价 Compose 的 GraphicsLayer 录制。
// SPDX-License-Identifier: Apache-2.0

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'miuix_backdrop.dart';

/// 捕获子树渲染输出到 [backdrop]，供模糊组件当背景取样。对应 Kotlin `Modifier.layerBackdrop`。
///
/// 放在"应作为模糊背景出现"的容器上：
/// ```dart
/// MiuixLayerBackdropCapture(
///   backdrop: backdrop,
///   child: MyBackground(),
/// )
/// ```
class MiuixLayerBackdropCapture extends SingleChildRenderObjectWidget {
  const MiuixLayerBackdropCapture({
    super.key,
    required this.backdrop,
    required Widget super.child,
  });

  final MiuixLayerBackdrop backdrop;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLayerBackdropCapture(
      backdrop: backdrop,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderLayerBackdropCapture)
      ..backdrop = backdrop
      ..devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
  }
}

class _RenderLayerBackdropCapture extends RenderProxyBox {
  _RenderLayerBackdropCapture({
    required this._backdrop,
    required this._devicePixelRatio,
  });

  MiuixLayerBackdrop _backdrop;
  MiuixLayerBackdrop get backdrop => _backdrop;
  set backdrop(MiuixLayerBackdrop value) {
    if (identical(_backdrop, value)) return;
    _backdrop = value;
    markNeedsPaint();
  }

  double _devicePixelRatio;
  double get devicePixelRatio => _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (_devicePixelRatio == value) return;
    _devicePixelRatio = value;
    markNeedsPaint();
  }

  // 作为独立重绘边界，Flutter 会为本节点分配一个 OffsetLayer；我们直接对该真实图层
  // 做 toImageSync 快照，避免重录子树导致的图层重入问题。
  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    // 本节点是重绘边界，super.paint 会把子树画进本节点的 OffsetLayer([layer])。
    // 在帧绘制结束后异步快照该图层。
    _scheduleCapture();
  }

  bool _captureScheduled = false;

  void _scheduleCapture() {
    if (_captureScheduled || !hasSize || size.isEmpty) return;
    _captureScheduled = true;
    // 帧结束后再快照，避免在 paint 阶段改状态触发同帧重入。
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _captureScheduled = false;
      if (!attached || !hasSize || size.isEmpty) return;
      _capture();
    });
  }

  void _capture() {
    final offsetLayer = layer;
    if (offsetLayer is! OffsetLayer) return;
    final dpr = _devicePixelRatio;
    // 对本重绘边界图层做同步出图（bounds 用本地 paintBounds，pixelRatio=dpr）。
    final ui.Image image = offsetLayer.toImageSync(
      Offset.zero & size,
      pixelRatio: dpr,
    );
    final global = localToGlobal(Offset.zero);
    _backdrop.updateSnapshot(image, global, dpr);
  }
}
