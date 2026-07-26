// Miuix Flutter 移植版 - Badge
// 源自 compose-miuix-ui/miuix 的 Badge.kt。
// 使用自定义 RenderBox 复刻徽标相对锚点的测量与 RTL 放置。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../foundation/miuix_content_color.dart';
import '../theme/miuix_theme.dart';

const double _badgeWithContentHorizontalPadding = 4;
const double _badgeWithContentHorizontalOffset = 12;
const double _badgeWithContentVerticalOffset = 14;
const double _badgeOffset = 6;

/// Badge 默认值。对应 Kotlin `BadgeDefaults`。
class MiuixBadgeDefaults {
  MiuixBadgeDefaults._();

  /// 无内容圆点徽标的默认尺寸。
  static const double size = 6;

  /// 含内容徽标的默认最小尺寸。
  static const double largeSize = 16;

  /// 默认容器色，对应主题的 `error`。
  static Color containerColor(BuildContext context) =>
      MiuixTheme.of(context).colors.error;

  /// 默认内容色，对应主题的 `onError`。
  static Color contentColor(BuildContext context) =>
      MiuixTheme.of(context).colors.onError;
}

/// Miuix 风格徽标。对应 Kotlin `Badge`。
///
/// [child] 为 null 时绘制 6×6 圆点；否则使用至少 16×16 的胶囊，左右各保留
/// 4 逻辑像素，并将内容默认文字样式设为 11sp、16sp 行框。
class MiuixBadge extends StatelessWidget {
  const MiuixBadge({
    super.key,
    this.containerColor,
    this.contentColor,
    this.child,
  });

  final Color? containerColor;
  final Color? contentColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final hasContent = child != null;
    final minimum = hasContent
        ? MiuixBadgeDefaults.largeSize
        : MiuixBadgeDefaults.size;
    final background =
        containerColor ?? MiuixBadgeDefaults.containerColor(context);
    final foreground = contentColor ?? MiuixBadgeDefaults.contentColor(context);

    Widget? content;
    if (child != null) {
      final fontSize = theme.textStyles.footnote2.fontSize ?? 11;
      final badgeMainStyle = theme.textStyles.main
          .merge(theme.textStyles.footnote2)
          .copyWith(
            height: 16 / fontSize,
            leadingDistribution: TextLeadingDistribution.even,
          );
      content = MiuixContentColor(
        color: foreground,
        child: MiuixTheme(
          data: theme.copyWith(
            textStyles: theme.textStyles.copy(main: badgeMainStyle),
          ),
          child: child!,
        ),
      );
    }

    // 用 UnconstrainedBox 阻断父级的有界 maxWidth：Container 在同时拥有
    // child 与 alignment 时会试图 expand 到父级 maxWidth（Flutter 与 Compose
    // `Box` 的语义差异），而 MiuixBadgedBox.performLayout 会把外层 Wrap/Row
    // 的有界宽度透传给 badge，导致徽标被拉成超宽胶囊。UnconstrainedBox 让
    // Container 按自然尺寸（padding + child，不小于 minWidth/minHeight）测量。
    return Semantics(
      container: true,
      child: UnconstrainedBox(
        child: Container(
          constraints: BoxConstraints(minWidth: minimum, minHeight: minimum),
          padding: hasContent
              ? const EdgeInsets.symmetric(
                  horizontal: _badgeWithContentHorizontalPadding,
                )
              : null,
          decoration: ShapeDecoration(
            color: background,
            shape: const StadiumBorder(),
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}

/// 将徽标放置在锚点右上角的容器。对应 Kotlin `BadgedBox`。
///
/// 组件尺寸完全由 [child] 决定，徽标可越过其边界。含内容徽标右端内缩 12、
/// 顶部重叠 14；圆点徽标两个方向均偏移 6。放置会随 RTL 镜像。
/// [topBound] 与 [endBound] 对应 Kotlin ruler 的可选夹取边界，默认不夹取。
class MiuixBadgedBox extends MultiChildRenderObjectWidget {
  MiuixBadgedBox({
    super.key,
    required Widget badge,
    required Widget child,
    this.topBound,
    this.endBound,
  }) : super(children: <Widget>[
          _BadgeSlot(slot: _BadgeSlotType.anchor, child: child),
          _BadgeSlot(slot: _BadgeSlotType.badge, child: badge),
        ]);

  final double? topBound;
  final double? endBound;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderBadgedBox(
        textDirection: Directionality.of(context),
        topBound: topBound,
        endBound: endBound,
      );

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderBadgedBox)
      ..textDirection = Directionality.of(context)
      ..topBound = topBound
      ..endBound = endBound;
  }
}

enum _BadgeSlotType { anchor, badge }

class _BadgeSlot extends ParentDataWidget<_BadgeParentData> {
  const _BadgeSlot({required this.slot, required super.child});

  final _BadgeSlotType slot;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as _BadgeParentData;
    if (parentData.slot != slot) {
      parentData.slot = slot;
      final parent = renderObject.parent;
      if (parent is RenderObject) parent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => MiuixBadgedBox;
}

class _BadgeParentData extends ContainerBoxParentData<RenderBox> {
  _BadgeSlotType? slot;
}

class _RenderBadgedBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BadgeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BadgeParentData> {
  _RenderBadgedBox({
    required TextDirection textDirection,
    double? topBound,
    double? endBound,
    // ignore: prefer_initializing_formals
  })  : _textDirection = textDirection,
        // ignore: prefer_initializing_formals
        _topBound = topBound,
        // ignore: prefer_initializing_formals
        _endBound = endBound;

  TextDirection _textDirection;
  double? _topBound;
  double? _endBound;

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  set topBound(double? value) {
    if (_topBound == value) return;
    _topBound = value;
    markNeedsLayout();
  }

  set endBound(double? value) {
    if (_endBound == value) return;
    _endBound = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _BadgeParentData) {
      child.parentData = _BadgeParentData();
    }
  }

  RenderBox get _anchor => _childFor(_BadgeSlotType.anchor);
  RenderBox get _badge => _childFor(_BadgeSlotType.badge);

  RenderBox _childFor(_BadgeSlotType slot) {
    RenderBox? child = firstChild;
    while (child != null) {
      final data = child.parentData! as _BadgeParentData;
      if (data.slot == slot) return child;
      child = data.nextSibling;
    }
    throw StateError('MiuixBadgedBox 缺少 $slot 子节点。');
  }

  @override
  void performLayout() {
    final anchor = _anchor;
    final badge = _badge;
    anchor.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(anchor.size);

    badge.layout(
      constraints.copyWith(minHeight: 0),
      parentUsesSize: true,
    );
    final hasContent = badge.size.width > MiuixBadgeDefaults.size;
    final horizontalOffset = hasContent
        ? _badgeWithContentHorizontalOffset
        : _badgeOffset;
    final verticalOffset = hasContent
        ? _badgeWithContentVerticalOffset
        : _badgeOffset;

    var logicalX = size.width - horizontalOffset;
    if (_endBound != null) {
      logicalX = mathMin(logicalX, _endBound! - badge.size.width);
    }
    var y = verticalOffset - badge.size.height;
    if (_topBound != null) y = mathMax(y, _topBound!);
    final physicalX = _textDirection == TextDirection.ltr
        ? logicalX
        : size.width - logicalX - badge.size.width;

    (anchor.parentData! as _BadgeParentData).offset = Offset.zero;
    (badge.parentData! as _BadgeParentData).offset = Offset(physicalX, y);
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _anchor.getMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _anchor.getMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _anchor.getMinIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _anchor.getMaxIntrinsicHeight(width);

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      _anchor.getDistanceToActualBaseline(baseline);

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

double mathMin(double a, double b) => a < b ? a : b;
double mathMax(double a, double b) => a > b ? a : b;
