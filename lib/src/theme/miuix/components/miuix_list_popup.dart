// Miuix Flutter 移植版 - ListPopup 基础组件
// 源自 compose-miuix-ui/miuix 的 basic/ListPopup.kt。
// 仅包含自动宽度列表、位置计算与视觉容器；挂载由统一 popup host 负责。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import '../foundation/miuix_squircle.dart';
import '../theme/miuix_motion.dart';
import '../theme/miuix_theme.dart';

/// 弹窗相对锚点的逻辑对齐方式。
enum MiuixPopupAlign { start, end, topStart, topEnd, bottomStart, bottomEnd }

MiuixPopupAlign _resolvePopupAlign(
  MiuixPopupAlign alignment,
  TextDirection direction,
) {
  if (direction == TextDirection.ltr) return alignment;
  return switch (alignment) {
    MiuixPopupAlign.start => MiuixPopupAlign.end,
    MiuixPopupAlign.end => MiuixPopupAlign.start,
    MiuixPopupAlign.topStart => MiuixPopupAlign.topEnd,
    MiuixPopupAlign.topEnd => MiuixPopupAlign.topStart,
    MiuixPopupAlign.bottomStart => MiuixPopupAlign.bottomEnd,
    MiuixPopupAlign.bottomEnd => MiuixPopupAlign.bottomStart,
  };
}

/// 供统一 popup host 使用的位置计算接口。
///
/// 所有坐标均为相对于窗口左上角的逻辑像素。实现不得自行读取
/// [MediaQuery]，因此同一算法可同时用于 Overlay 与窗口级 host。
abstract interface class MiuixPopupPositionProvider {
  const MiuixPopupPositionProvider();

  /// 计算弹窗左上角在窗口中的位置。
  Offset calculatePosition({
    required Rect anchorBounds,
    required Rect windowBounds,
    required TextDirection textDirection,
    required Size popupContentSize,
    required EdgeInsets popupMargin,
    required MiuixPopupAlign alignment,
  });

  /// 弹窗的额外外边距；方向性边距由调用方按当前文字方向解析。
  EdgeInsetsGeometry get margins;
}

/// Compose spring 的 Flutter 等价描述。
@immutable
class MiuixPopupSpringSpec {
  const MiuixPopupSpringSpec({
    required this.dampingRatio,
    required this.stiffness,
    required this.visibilityThreshold,
  });

  final double dampingRatio;
  final double stiffness;
  final double visibilityThreshold;

  SpringDescription get description => SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: stiffness,
    ratio: dampingRatio,
  );

  /// 创建供 `AnimationController.unbounded().animateWith(...)` 使用的模拟。
  SpringSimulation simulation(double from, double to, {double velocity = 0}) {
    return SpringSimulation(description, from, to, velocity)
      ..tolerance = Tolerance(
        distance: visibilityThreshold,
        velocity: visibilityThreshold,
      );
  }
}

/// Popup 补间动画的时长与曲线。
@immutable
class MiuixPopupTweenSpec {
  const MiuixPopupTweenSpec(this.duration, this.curve);

  final Duration duration;
  final Curve curve;
}

/// ListPopup 的尺寸、动效与默认位置策略。
class MiuixListPopupDefaults {
  MiuixListPopupDefaults._();

  static const double minWidth = 200;
  static const double minPopupHeight = 50;
  static const double cornerRadius = 16;

  static const MiuixPopupSpringSpec fractionAnimationSpec =
      MiuixPopupSpringSpec(
        dampingRatio: 0.82,
        stiffness: 362.5,
        visibilityThreshold: 0.0001,
      );
  static const MiuixPopupSpringSpec resetAnimationSpec = fractionAnimationSpec;
  static const MiuixPopupTweenSpec alphaEnterAnimationSpec =
      MiuixPopupTweenSpec(Duration(milliseconds: 200), Curves.fastOutSlowIn);
  static const MiuixPopupTweenSpec alphaExitAnimationSpec = MiuixPopupTweenSpec(
    Duration(milliseconds: 150),
    Curves.fastOutSlowIn,
  );
  static const MiuixPopupTweenSpec dimEnterAnimationSpec = MiuixPopupTweenSpec(
    Duration(milliseconds: 300),
    SinOutEasing(),
  );
  static const MiuixPopupTweenSpec dimExitAnimationSpec = MiuixPopupTweenSpec(
    Duration(milliseconds: 150),
    SinOutEasing(),
  );

  /// 创建下拉菜单的位置策略。
  static MiuixPopupPositionProvider dropdownPositionProvider({
    double verticalMargin = 8,
    double horizontalMargin = 0,
  }) {
    return _DropdownPositionProvider(
      verticalMargin: verticalMargin,
      horizontalMargin: horizontalMargin,
    );
  }

  static final MiuixPopupPositionProvider dropdownPosition =
      dropdownPositionProvider();
  static const MiuixPopupPositionProvider contextMenuPosition =
      _ContextMenuPositionProvider();
}

class _DropdownPositionProvider implements MiuixPopupPositionProvider {
  const _DropdownPositionProvider({
    required this.verticalMargin,
    required this.horizontalMargin,
  });

  final double verticalMargin;
  final double horizontalMargin;

  @override
  EdgeInsetsGeometry get margins => EdgeInsets.symmetric(
    horizontal: horizontalMargin,
    vertical: verticalMargin,
  );

  @override
  Offset calculatePosition({
    required Rect anchorBounds,
    required Rect windowBounds,
    required TextDirection textDirection,
    required Size popupContentSize,
    required EdgeInsets popupMargin,
    required MiuixPopupAlign alignment,
  }) {
    final resolved = _resolvePopupAlign(alignment, textDirection);
    final x = resolved == MiuixPopupAlign.end
        ? anchorBounds.right - popupContentSize.width - popupMargin.right
        : anchorBounds.left + popupMargin.left;
    final y = _fallbackVerticalPosition(
      anchorBounds,
      windowBounds,
      popupContentSize.height,
      popupMargin,
    );
    return _clampPopupOffset(
      Offset(x, y),
      windowBounds,
      popupContentSize,
      popupMargin,
    );
  }
}

class _ContextMenuPositionProvider implements MiuixPopupPositionProvider {
  const _ContextMenuPositionProvider();

  @override
  EdgeInsetsGeometry get margins => EdgeInsets.zero;

  @override
  Offset calculatePosition({
    required Rect anchorBounds,
    required Rect windowBounds,
    required TextDirection textDirection,
    required Size popupContentSize,
    required EdgeInsets popupMargin,
    required MiuixPopupAlign alignment,
  }) {
    final resolved = _resolvePopupAlign(alignment, textDirection);
    late final double x;
    late final double y;
    switch (resolved) {
      case MiuixPopupAlign.topStart:
        x = anchorBounds.left + popupMargin.left;
        y = anchorBounds.bottom + popupMargin.top;
      case MiuixPopupAlign.topEnd:
        x = anchorBounds.right - popupContentSize.width - popupMargin.right;
        y = anchorBounds.bottom + popupMargin.top;
      case MiuixPopupAlign.bottomStart:
        x = anchorBounds.left + popupMargin.left;
        y = anchorBounds.top - popupContentSize.height - popupMargin.bottom;
      case MiuixPopupAlign.bottomEnd:
        x = anchorBounds.right - popupContentSize.width - popupMargin.right;
        y = anchorBounds.top - popupContentSize.height - popupMargin.bottom;
      case MiuixPopupAlign.start:
      case MiuixPopupAlign.end:
        x = resolved == MiuixPopupAlign.end
            ? anchorBounds.right - popupContentSize.width - popupMargin.right
            : anchorBounds.left + popupMargin.left;
        y = _fallbackVerticalPosition(
          anchorBounds,
          windowBounds,
          popupContentSize.height,
          popupMargin,
        );
    }
    return _clampPopupOffset(
      Offset(x, y),
      windowBounds,
      popupContentSize,
      popupMargin,
    );
  }
}

double _fallbackVerticalPosition(
  Rect anchor,
  Rect window,
  double popupHeight,
  EdgeInsets margin,
) {
  if (window.bottom - anchor.bottom > popupHeight) {
    return anchor.bottom + margin.bottom;
  }
  if (anchor.top - window.top > popupHeight) {
    return anchor.top - popupHeight - margin.top;
  }
  return anchor.top + anchor.height / 2 - popupHeight / 2;
}

Offset _clampPopupOffset(
  Offset offset,
  Rect window,
  Size popupSize,
  EdgeInsets margin,
) {
  final maxX = math.max(
    window.left,
    window.right - popupSize.width - margin.right,
  );
  final maxY = window.bottom - popupSize.height - margin.bottom;
  final minY = math.min(window.top + margin.top, maxY);
  return Offset(
    offset.dx.clamp(window.left, maxX),
    offset.dy.clamp(minY, maxY),
  );
}

/// 弹窗位于锚点的哪一侧，以及贴近锚点的哪条横向边。
@immutable
class MiuixPopupLayoutPosition {
  const MiuixPopupLayoutPosition({
    required this.showBelow,
    required this.showAbove,
    required this.isRightAligned,
  });

  final bool showBelow;
  final bool showAbove;
  final bool isRightAligned;

  bool get showMiddle => !showBelow && !showAbove;
}

/// popup host 定位、缩放与揭示动画所需的完整布局信息。
@immutable
class MiuixListPopupLayoutInfo {
  const MiuixListPopupLayoutInfo({
    required this.windowBounds,
    required this.popupMargin,
    required this.calculatedOffset,
    required this.effectiveTransformOrigin,
    required this.localTransformOrigin,
    required this.popupLayoutPosition,
  });

  final Rect windowBounds;
  final EdgeInsets popupMargin;

  /// 弹窗左上角窗口坐标。内容尚未测量时为 [Offset.zero]。
  final Offset calculatedOffset;

  /// 归一化的窗口坐标原点，供统一 popup host 的全局动效使用。
  final Offset effectiveTransformOrigin;

  /// 归一化的弹窗局部原点，供 [MiuixListPopupContent] 使用。
  final Offset localTransformOrigin;
  final MiuixPopupLayoutPosition popupLayoutPosition;
}

/// 将变换原点中的 NaN 和负数归零；正值（包括大于 1）保持原样。
Offset safeTransformOrigin(double x, double y) {
  final safeX = x.isNaN || x < 0 ? 0.0 : x;
  final safeY = y.isNaN || y < 0 ? 0.0 : y;
  return Offset(safeX, safeY);
}

/// 从窗口安全区、锚点与已测量内容计算 popup host 所需布局信息。
///
/// [parentBounds] 必须是窗口坐标。首次构建可传 [Size.zero]；此时返回预测
/// 原点，待 [MiuixListPopupContent.onPopupContentSizeChange] 回报后重新计算。
MiuixListPopupLayoutInfo computeListPopupLayoutInfo(
  BuildContext context, {
  required MiuixPopupAlign alignment,
  required MiuixPopupPositionProvider popupPositionProvider,
  required Rect parentBounds,
  required Size popupContentSize,
}) {
  final media = MediaQuery.of(context);
  final direction = Directionality.of(context);
  final containerSize = media.size;
  final viewPadding = media.viewPadding;
  final padding = media.padding;
  final windowBounds = Rect.fromLTRB(
    viewPadding.left,
    padding.top,
    containerSize.width - viewPadding.right,
    containerSize.height - padding.bottom,
  );
  final popupMargin = popupPositionProvider.margins.resolve(direction);
  final resolved = _resolvePopupAlign(alignment, direction);
  final predictedX = switch (resolved) {
    MiuixPopupAlign.end ||
    MiuixPopupAlign.topEnd ||
    MiuixPopupAlign.bottomEnd => parentBounds.right - popupMargin.right,
    _ => parentBounds.left + popupMargin.left,
  };
  final predictedY = switch (resolved) {
    MiuixPopupAlign.bottomStart ||
    MiuixPopupAlign.bottomEnd => parentBounds.top - popupMargin.bottom,
    _ => parentBounds.bottom + popupMargin.bottom,
  };
  final predictedOrigin = safeTransformOrigin(
    predictedX / containerSize.width,
    predictedY / containerSize.height,
  );

  if (popupContentSize == Size.zero) {
    final rightAligned = switch (resolved) {
      MiuixPopupAlign.end ||
      MiuixPopupAlign.topEnd ||
      MiuixPopupAlign.bottomEnd => true,
      _ => false,
    };
    final position = MiuixPopupLayoutPosition(
      showBelow: true,
      showAbove: false,
      isRightAligned: rightAligned,
    );
    return MiuixListPopupLayoutInfo(
      windowBounds: windowBounds,
      popupMargin: popupMargin,
      calculatedOffset: Offset.zero,
      effectiveTransformOrigin: predictedOrigin,
      localTransformOrigin: Offset(rightAligned ? 1 : 0, 0),
      popupLayoutPosition: position,
    );
  }

  final offset = popupPositionProvider.calculatePosition(
    anchorBounds: parentBounds,
    windowBounds: windowBounds,
    textDirection: direction,
    popupContentSize: popupContentSize,
    popupMargin: popupMargin,
    alignment: alignment,
  );
  final popupCenterY = offset.dy + popupContentSize.height / 2;
  final anchorCenterY = parentBounds.top + parentBounds.height / 2;
  final showBelow = popupCenterY > anchorCenterY;
  final showAbove = popupCenterY < anchorCenterY;
  final distanceLeft = (offset.dx - parentBounds.left).abs();
  final distanceRight =
      (offset.dx + popupContentSize.width - parentBounds.right).abs();
  final rightAligned = distanceRight < distanceLeft;
  final position = MiuixPopupLayoutPosition(
    showBelow: showBelow,
    showAbove: showAbove,
    isRightAligned: rightAligned,
  );
  final cornerX = rightAligned ? offset.dx + popupContentSize.width : offset.dx;
  final cornerY = position.showMiddle
      ? offset.dy + popupContentSize.height / 2
      : showBelow
      ? offset.dy
      : offset.dy + popupContentSize.height;
  final localY = position.showMiddle ? 0.5 : (showAbove ? 1.0 : 0.0);
  return MiuixListPopupLayoutInfo(
    windowBounds: windowBounds,
    popupMargin: popupMargin,
    calculatedOffset: offset,
    effectiveTransformOrigin: safeTransformOrigin(
      cornerX / containerSize.width,
      cornerY / containerSize.height,
    ),
    localTransformOrigin: Offset(rightAligned ? 1 : 0, localY),
    popupLayoutPosition: position,
  );
}

/// 自动将所有列表项统一为前八项中最宽项宽度的可滚动列。
///
/// 宽度限制为 200–288 逻辑像素；高度内在测量只统计前八项，与原实现
/// 一致。建议由 popup host 在外层提供最大高度约束。
class MiuixListPopupColumn extends StatelessWidget {
  const MiuixListPopupColumn({
    super.key,
    required this.children,
    this.scrollController,
    this.physics,
  });

  final List<Widget> children;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: SingleChildScrollView(
        controller: scrollController,
        physics: physics ?? const ClampingScrollPhysics(),
        child: _IntrinsicPopupColumn(children: children),
      ),
    );
  }
}

class _IntrinsicPopupColumn extends MultiChildRenderObjectWidget {
  const _IntrinsicPopupColumn({required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderIntrinsicPopupColumn();
}

class _PopupColumnParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderIntrinsicPopupColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _PopupColumnParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _PopupColumnParentData> {
  static const int _maxItemsForWidth = 8;
  static const int _maxItemsForHeight = 8;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PopupColumnParentData) {
      child.parentData = _PopupColumnParentData();
    }
  }

  double _listWidth(BoxConstraints constraints, double height) {
    var widest = 0.0;
    var child = firstChild;
    var count = 0;
    while (child != null && count < _maxItemsForWidth) {
      widest = math.max(widest, child.getMaxIntrinsicWidth(height));
      child = childAfter(child);
      count++;
    }
    final parentMax = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : MiuixListPopupDefaults.minWidth + 88;
    final upper = math.min(math.max(288.0, constraints.minWidth), parentMax);
    final lower = math.min(
      math.max(MiuixListPopupDefaults.minWidth, constraints.minWidth),
      upper,
    );
    return widest.clamp(lower, upper);
  }

  @override
  void performLayout() {
    final width = _listWidth(constraints, constraints.maxHeight);
    final childConstraints = BoxConstraints(
      minWidth: width,
      maxWidth: width,
      maxHeight: constraints.maxHeight,
    );
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      final parentData = child.parentData! as _PopupColumnParentData;
      parentData.offset = Offset(0, height);
      height += child.size.height;
      child = parentData.nextSibling;
    }
    size = constraints.constrain(Size(width, height));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final width = _listWidth(constraints, constraints.maxHeight);
    var height = 0.0;
    var child = firstChild;
    while (child != null) {
      height += child
          .getDryLayout(BoxConstraints(minWidth: width, maxWidth: width))
          .height;
      child = childAfter(child);
    }
    return constraints.constrain(Size(width, height));
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _listWidth(const BoxConstraints(), height);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _listWidth(const BoxConstraints(), height);

  @override
  double computeMinIntrinsicHeight(double width) {
    var widest = 0.0;
    var child = firstChild;
    var count = 0;
    while (child != null && count < _maxItemsForWidth) {
      widest = math.max(widest, child.getMaxIntrinsicWidth(double.infinity));
      child = childAfter(child);
      count++;
    }
    final listWidth = widest.clamp(200.0, 288.0);
    var height = 0.0;
    child = firstChild;
    count = 0;
    while (child != null && count < _maxItemsForHeight) {
      height += child.getMinIntrinsicHeight(listWidth);
      child = childAfter(child);
      count++;
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// 承载列表内容的缩放、淡入淡出与定向 squircle 揭示容器。
///
/// [animation] 可传入 host 的一个或多个控制器合并后的 [Listenable]，以便
/// 不重建 widget 即逐帧读取进度；为 null 时由父级重建驱动。
class MiuixListPopupContent extends StatelessWidget {
  const MiuixListPopupContent({
    super.key,
    required this.popupContentSize,
    required this.onPopupContentSizeChange,
    required this.fractionProgress,
    required this.alphaProgress,
    required this.popupLayoutPosition,
    required this.localTransformOrigin,
    required this.child,
    this.animation,
    this.backgroundColor,
    this.cornerRadius = MiuixListPopupDefaults.cornerRadius,
  });

  final Size popupContentSize;
  final ValueChanged<Size> onPopupContentSizeChange;
  final double Function() fractionProgress;
  final double Function() alphaProgress;
  final MiuixPopupLayoutPosition popupLayoutPosition;
  final Offset localTransformOrigin;
  final Widget child;
  final Listenable? animation;
  final Color? backgroundColor;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    Widget buildAnimated(BuildContext context, Widget? _) {
      final fraction = fractionProgress();
      final alpha = alphaProgress().clamp(0.0, 1.0);
      final scale = 0.15 + 0.85 * fraction;
      final alignment = Alignment(
        localTransformOrigin.dx * 2 - 1,
        localTransformOrigin.dy * 2 - 1,
      );
      return Transform.scale(
        scale: scale,
        alignment: alignment,
        child: Opacity(
          opacity: alpha,
          child: _SizeReporter(
            previousSize: popupContentSize,
            onSizeChange: onPopupContentSizeChange,
            child: ClipPath(
              clipper: _PopupRevealClipper(
                progress: fraction,
                position: popupLayoutPosition,
                cornerRadius: cornerRadius,
              ),
              child: ColoredBox(
                color:
                    backgroundColor ??
                    MiuixTheme.of(context).colors.surfaceContainer,
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: animation == null
          ? buildAnimated(context, null)
          : AnimatedBuilder(animation: animation!, builder: buildAnimated),
    );
  }
}

class _PopupRevealClipper extends CustomClipper<Path> {
  const _PopupRevealClipper({
    required this.progress,
    required this.position,
    required this.cornerRadius,
  });

  final double progress;
  final MiuixPopupLayoutPosition position;
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final value = progress.clamp(0.0, 1.0);
    if (value <= 0 || size.isEmpty) return Path();
    final visibleHeight = size.height * value;
    final start = position.showBelow
        ? 0.0
        : position.showAbove
        ? size.height * (1 - value)
        : size.height * (0.5 - 0.5 * value);
    final path = Path();
    addSquircleRect(
      path,
      size.width,
      visibleHeight,
      cornerRadius,
      enabled: true,
    );
    return path.shift(Offset(0, start));
  }

  @override
  bool shouldReclip(_PopupRevealClipper oldClipper) {
    return oldClipper.progress != progress ||
        oldClipper.position != position ||
        oldClipper.cornerRadius != cornerRadius;
  }
}

class _SizeReporter extends SingleChildRenderObjectWidget {
  const _SizeReporter({
    required this.previousSize,
    required this.onSizeChange,
    required super.child,
  });

  final Size previousSize;
  final ValueChanged<Size> onSizeChange;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSizeReporter(
    previousSize: previousSize,
    onSizeChange: onSizeChange,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSizeReporter renderObject,
  ) {
    renderObject
      ..previousSize = previousSize
      ..onSizeChange = onSizeChange;
  }
}

class _RenderSizeReporter extends RenderProxyBox {
  _RenderSizeReporter({
    required Size previousSize,
    required ValueChanged<Size> onSizeChange,
    // ignore: prefer_initializing_formals
  }) : _previousSize = previousSize,
       // ignore: prefer_initializing_formals
       _onSizeChange = onSizeChange;

  Size _previousSize;
  ValueChanged<Size> _onSizeChange;
  Size? _scheduledSize;

  set previousSize(Size value) => _previousSize = value;
  set onSizeChange(ValueChanged<Size> value) => _onSizeChange = value;

  @override
  void performLayout() {
    super.performLayout();
    if (size == _previousSize || size == _scheduledSize) return;
    _scheduledSize = size;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reported = _scheduledSize;
      _scheduledSize = null;
      if (attached && reported != null && reported != _previousSize) {
        _onSizeChange(reported);
      }
    });
  }
}
