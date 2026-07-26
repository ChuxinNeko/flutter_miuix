// Miuix Flutter 移植版 - BasicComponent
// 源自 compose-miuix-ui/miuix 的 Component.kt。
// 使用自定义 RenderBox 精确复刻 start/center/end 的 2:5:3 测量约束。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../foundation/miuix_pressable.dart';
import '../theme/miuix_theme.dart';
import 'miuix_text.dart';

/// BasicComponent 颜色配置。对应 Kotlin `BasicComponentColors`。
@immutable
class MiuixBasicComponentColors {
  const MiuixBasicComponentColors({
    required this.color,
    required this.disabledColor,
  });

  final Color color;
  final Color disabledColor;

  /// 根据 [enabled] 返回当前颜色。
  Color resolve(bool enabled) => enabled ? color : disabledColor;
}

/// BasicComponent 默认值。对应 Kotlin `BasicComponentDefaults`。
class MiuixBasicComponentDefaults {
  MiuixBasicComponentDefaults._();

  /// 组件四周默认内边距，均为 16 逻辑像素。
  static const EdgeInsets insideMargin = EdgeInsets.all(16);

  /// 标题默认颜色。
  static MiuixBasicComponentColors titleColor(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return MiuixBasicComponentColors(
      color: colors.onBackground,
      disabledColor: colors.disabledOnSecondaryVariant,
    );
  }

  /// 摘要默认颜色。
  static MiuixBasicComponentColors summaryColor(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return MiuixBasicComponentColors(
      color: colors.onSurfaceVariantSummary,
      disabledColor: colors.disabledOnSecondaryVariant,
    );
  }
}

/// BasicComponent 的无障碍角色。对应 Compose `Role`。
enum MiuixBasicComponentRole {
  button,
  checkbox,
  radioButton,
  switchControl,
  tab,
  dropdownList,
}

/// 广泛用于扩展组件的 Miuix 基础行。对应 Kotlin `BasicComponent`。
///
/// 可直接传入 [title]/[summary]，也可用 [content] 替换中心内容。存在起始或
/// 结束操作时，内部 RenderBox 会先测量起始项，再把“剩余宽度减 8”中的最多
/// 60% 分给结束项，余量交给中心项；这正是源组件防止溢出破坏 2:5:3 布局的
/// 测量方式，而不是普通 `Row + Expanded`。
class MiuixBasicComponent extends StatelessWidget {
  const MiuixBasicComponent({
    super.key,
    this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.startAction,
    this.endActions,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.onClick,
    this.onClickLabel,
    this.role,
    this.holdDownState = false,
    this.enabled = true,
    this.content,
  });

  final String? title;
  final MiuixBasicComponentColors? titleColor;
  final String? summary;
  final MiuixBasicComponentColors? summaryColor;
  final Widget? startAction;
  final List<Widget>? endActions;
  final Widget? bottomAction;
  final EdgeInsetsGeometry insideMargin;
  final VoidCallback? onClick;
  final String? onClickLabel;
  final MiuixBasicComponentRole? role;
  final bool holdDownState;
  final bool enabled;

  /// 自定义中心内容；为 null 时由 [title] 与 [summary] 构建。
  final List<Widget>? content;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final effectiveEnabled = enabled && onClick != null;
    final resolvedTitleColor =
        titleColor ?? MiuixBasicComponentDefaults.titleColor(context);
    final resolvedSummaryColor =
        summaryColor ?? MiuixBasicComponentDefaults.summaryColor(context);
    final centerChildren = content ??
        <Widget>[
          if (title != null)
            MiuixText(
              title!,
              fontSize: theme.textStyles.headline1.fontSize,
              fontWeight: FontWeight.w500,
              color: resolvedTitleColor.resolve(enabled),
            ),
          if (summary != null)
            MiuixText(
              summary!,
              fontSize: theme.textStyles.body2.fontSize,
              color: resolvedSummaryColor.resolve(enabled),
            ),
        ];

    final center = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: centerChildren,
    );
    final hasSideActions = startAction != null || endActions != null;
    Widget mainContent;
    if (!hasSideActions) {
      mainContent = Align(alignment: AlignmentDirectional.centerStart, child: center);
    } else {
      mainContent = _BasicComponentRow(
        start: startAction == null
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [startAction!],
              ),
        center: center,
        end: endActions == null
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: endActions!,
                  ),
                ],
              ),
      );
    }

    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        mainContent,
        if (bottomAction != null) ...[
          const SizedBox(height: 8),
          bottomAction!,
        ],
      ],
    );
    body = Padding(padding: insideMargin, child: body);
    body = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: body,
    );

    if (effectiveEnabled && holdDownState) {
      body = Stack(
        fit: StackFit.passthrough,
        children: [
          body,
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: theme.colors.onBackground.withValues(alpha: 0.10),
              ),
            ),
          ),
        ],
      );
    }

    body = MiuixPressable(
      onPressed: effectiveEnabled ? onClick : null,
      enabled: effectiveEnabled,
      feedbackType: MiuixPressFeedbackType.none,
      child: body,
    );

    return Semantics(
      container: true,
      label: onClickLabel,
      enabled: effectiveEnabled,
      button: role == MiuixBasicComponentRole.button ||
          role == MiuixBasicComponentRole.dropdownList,
      checked: role == MiuixBasicComponentRole.checkbox ||
              role == MiuixBasicComponentRole.radioButton ||
              role == MiuixBasicComponentRole.switchControl
          ? false
          : null,
      onTap: effectiveEnabled ? onClick : null,
      child: SizedBox(width: double.infinity, child: body),
    );
  }
}

enum _BasicSlotType { start, center, end }

class _BasicComponentRow extends MultiChildRenderObjectWidget {
  _BasicComponentRow({
    Widget? start,
    required Widget center,
    Widget? end,
  }) : super(children: [
          if (start != null)
            _BasicSlot(slot: _BasicSlotType.start, child: start),
          _BasicSlot(slot: _BasicSlotType.center, child: center),
          if (end != null) _BasicSlot(slot: _BasicSlotType.end, child: end),
        ]);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBasicComponentRow(textDirection: Directionality.of(context));

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderBasicComponentRow renderObject,
  ) {
    renderObject.textDirection = Directionality.of(context);
  }
}

class _BasicSlot extends ParentDataWidget<_BasicParentData> {
  const _BasicSlot({required this.slot, required super.child});

  final _BasicSlotType slot;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as _BasicParentData;
    if (parentData.slot != slot) {
      parentData.slot = slot;
      final parent = renderObject.parent;
      if (parent is RenderObject) parent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _BasicComponentRow;
}

class _BasicParentData extends ContainerBoxParentData<RenderBox> {
  _BasicSlotType? slot;
}

class _RenderBasicComponentRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BasicParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BasicParentData> {
  _RenderBasicComponentRow({
    required TextDirection textDirection,
    // ignore: prefer_initializing_formals
  }) : _textDirection = textDirection;

  static const double _spacer = 8;
  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _BasicParentData) {
      child.parentData = _BasicParentData();
    }
  }

  RenderBox? _childFor(_BasicSlotType slot) {
    RenderBox? child = firstChild;
    while (child != null) {
      final data = child.parentData! as _BasicParentData;
      if (data.slot == slot) return child;
      child = data.nextSibling;
    }
    return null;
  }

  @override
  void performLayout() {
    final start = _childFor(_BasicSlotType.start);
    final center = _childFor(_BasicSlotType.center)!;
    final end = _childFor(_BasicSlotType.end);
    final maxWidth = constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
    final maxHeight = constraints.maxHeight;
    final loose = constraints.copyWith(minWidth: 0, minHeight: 0);

    start?.layout(loose, parentUsesSize: true);
    final startWidth = start?.size.width ?? 0;
    final startSpacer = startWidth > 0 ? _spacer : 0.0;
    final widthAfterStart = math.max(0.0, maxWidth - startWidth - startSpacer);

    final endIntrinsic = end?.getMaxIntrinsicWidth(maxHeight) ?? 0;
    final endHardCap = (math.max(0.0, widthAfterStart - _spacer) * 0.6).floorToDouble();
    final endTarget = math.min(endIntrinsic, endHardCap);
    end?.layout(
      loose.copyWith(maxWidth: endTarget),
      parentUsesSize: true,
    );
    final endWidth = end?.size.width ?? 0;
    final endSpacer = endWidth > 0 ? _spacer : 0.0;
    final centerWidth =
        math.max(0.0, widthAfterStart - endWidth - endSpacer);
    center.layout(
      loose.copyWith(maxWidth: centerWidth),
      parentUsesSize: true,
    );

    final startHeight = start?.size.height ?? 0;
    final endHeight = end?.size.height ?? 0;
    final rowHeight = math.max(
      startHeight,
      math.max(center.size.height, endHeight),
    );
    final layoutHeight = constraints.constrainHeight(rowHeight);
    final layoutWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth(startWidth + startSpacer + center.size.width + endSpacer + endWidth);
    size = Size(layoutWidth, layoutHeight);

    void place(RenderBox? child, double logicalX, double y) {
      if (child == null) return;
      final x = _textDirection == TextDirection.ltr
          ? logicalX
          : size.width - logicalX - child.size.width;
      (child.parentData! as _BasicParentData).offset = Offset(x, y);
    }

    place(start, 0, math.max(0.0, rowHeight - startHeight) / 2);
    place(
      center,
      startWidth + startSpacer,
      (rowHeight - center.size.height) / 2,
    );
    place(
      end,
      size.width - endWidth,
      math.max(0.0, rowHeight - endHeight) / 2,
    );
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final start = _childFor(_BasicSlotType.start);
    final center = _childFor(_BasicSlotType.center)!;
    final end = _childFor(_BasicSlotType.end);
    final startWidth = start?.getMinIntrinsicWidth(height) ?? 0;
    final centerWidth = center.getMinIntrinsicWidth(height);
    final endWidth = end?.getMinIntrinsicWidth(height) ?? 0;
    return startWidth +
        (startWidth > 0 ? _spacer : 0) +
        centerWidth +
        (endWidth > 0 ? _spacer : 0) +
        endWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final start = _childFor(_BasicSlotType.start);
    final center = _childFor(_BasicSlotType.center)!;
    final end = _childFor(_BasicSlotType.end);
    final startWidth = start?.getMaxIntrinsicWidth(height) ?? 0;
    final centerWidth = center.getMaxIntrinsicWidth(height);
    final endWidth = end?.getMaxIntrinsicWidth(height) ?? 0;
    return startWidth +
        (startWidth > 0 ? _spacer : 0) +
        centerWidth +
        (endWidth > 0 ? _spacer : 0) +
        endWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _intrinsicHeight(width, minimum: true);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _intrinsicHeight(width, minimum: false);

  double _intrinsicHeight(double width, {required bool minimum}) {
    double heightFor(RenderBox? child) {
      if (child == null) return 0;
      return minimum
          ? child.getMinIntrinsicHeight(width)
          : child.getMaxIntrinsicHeight(width);
    }

    return math.max(
      heightFor(_childFor(_BasicSlotType.start)),
      math.max(
        heightFor(_childFor(_BasicSlotType.center)),
        heightFor(_childFor(_BasicSlotType.end)),
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
