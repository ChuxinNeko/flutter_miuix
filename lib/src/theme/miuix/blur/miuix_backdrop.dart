// Miuix Flutter 移植版 - Backdrop 抽象
// 源自 compose-miuix-ui/miuix 的 miuix-blur/Backdrop.kt + LayerBackdrop.kt。
// Backdrop 定义"模糊表面背后要绘制的内容"如何提供；MiuixLayerBackdrop 通过
// 一个被捕获的图层快照（ui.Image）+ 全局坐标提供背景，供模糊组件按偏移取样。
// SPDX-License-Identifier: Apache-2.0

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// 背景内容提供者。对应 Kotlin `interface Backdrop`。
///
/// 模糊组件（[MiuixTextureBlur] 等）通过它拿到"自己背后的内容"来做模糊。
/// 阶段 5A 只实现 [MiuixLayerBackdrop]（图层快照捕获）。
abstract class MiuixBackdrop extends ChangeNotifier {
  /// 是否需要布局坐标来正确定位（图层型 backdrop 为 true）。
  /// 对应 Kotlin `isCoordinatesDependent`。
  bool get isCoordinatesDependent;

  /// 当前可用于取样的背景快照；未捕获时为 null。
  ui.Image? get snapshot;

  /// 背景快照在全局（窗口）坐标系中的左上角位置。用于与模糊表面对齐。
  Offset? get globalOffset;

  /// 快照的设备像素比（快照按此比例录制）。
  double get pixelRatio;
}

/// 通过捕获的图层快照提供背景的 [MiuixBackdrop]。对应 Kotlin `LayerBackdrop`。
///
/// 用 [MiuixLayerBackdropCapture] 包裹背景容器来录制其渲染输出，再把本对象传给
/// 模糊组件。用 [rememberMiuixLayerBackdrop] 或直接 `MiuixLayerBackdrop()` 创建，
/// 需在 dispose 时释放。
class MiuixLayerBackdrop extends MiuixBackdrop {
  MiuixLayerBackdrop();

  @override
  bool get isCoordinatesDependent => true;

  ui.Image? _snapshot;
  Offset? _globalOffset;
  double _pixelRatio = 1.0;

  @override
  ui.Image? get snapshot => _snapshot;

  @override
  Offset? get globalOffset => _globalOffset;

  @override
  double get pixelRatio => _pixelRatio;

  /// 由 [MiuixLayerBackdropCapture] 在每帧录制后调用，更新快照与坐标。
  ///
  /// 旧快照在替换后被释放（Flutter 的 [ui.Image] 需显式 dispose）。
  void updateSnapshot(ui.Image image, Offset globalOffset, double pixelRatio) {
    final old = _snapshot;
    _snapshot = image;
    _globalOffset = globalOffset;
    _pixelRatio = pixelRatio;
    // 先通知再释放旧图，避免正在使用旧图的绘制被拉黑。
    notifyListeners();
    if (old != null && !identical(old, image)) {
      old.dispose();
    }
  }

  @override
  void dispose() {
    _snapshot?.dispose();
    _snapshot = null;
    super.dispose();
  }
}
