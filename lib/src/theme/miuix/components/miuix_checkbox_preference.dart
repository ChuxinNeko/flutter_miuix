// Miuix Flutter 移植版 - CheckboxPreference
// 源自 compose-miuix-preference/miuix 的 preference/CheckboxPreference.kt。
// 在 BasicComponent 的起始或末尾追加一个 MiuixCheckbox，行点击即切换复选框状态。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import 'miuix_basic_component.dart';
import 'miuix_checkbox.dart';

/// 复选框的位置。对应 Kotlin `CheckboxLocation`。
enum MiuixCheckboxLocation {
  /// 起始侧（标题之前）。
  start,

  /// 末尾侧（endActions 之后）。
  end,
}

/// 带复选框的偏好设置行。对应 Kotlin `CheckboxPreference`。
///
/// [MiuixCheckbox] 的位置由 [checkboxLocation] 决定。当 [value] 为 true 时
/// 复选框处于选中态。点击整行会触发 [onChanged] 并切换 [value]。
/// 复选框本身也可独立交互（当 [onChanged] 非空且 [enabled] 为 true 时）。
class MiuixCheckboxPreference extends StatelessWidget {
  const MiuixCheckboxPreference({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.checkboxColors,
    this.startAction,
    this.endActions,
    this.checkboxLocation = MiuixCheckboxLocation.start,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.holdDownState = false,
    this.enabled = true,
  });

  /// 行标题。
  final String title;

  /// 当前复选框状态。
  final bool value;

  /// 状态变更回调；为 null 时复选框与行均不可交互。
  final ValueChanged<bool>? onChanged;

  /// 标题颜色；为 null 时取 [MiuixBasicComponentDefaults.titleColor]。
  final MiuixBasicComponentColors? titleColor;

  /// 行摘要（可选）。
  final String? summary;

  /// 摘要颜色；为 null 时取 [MiuixBasicComponentDefaults.summaryColor]。
  final MiuixBasicComponentColors? summaryColor;

  /// 复选框颜色；为 null 时取 [MiuixCheckboxDefaults.checkboxColors]。
  final MiuixCheckboxColors? checkboxColors;

  /// 起始侧额外内容（可选）；位于复选框之后，带 5dp 末端间距。
  final Widget? startAction;

  /// 末尾额外内容（可选）；位于复选框之前，带 8dp 末端间距。
  final List<Widget>? endActions;

  /// 复选框位置，默认 [MiuixCheckboxLocation.start]。
  final MiuixCheckboxLocation checkboxLocation;

  /// 底部内容（可选），位于主行下方。
  final Widget? bottomAction;

  /// 内边距，默认 [MiuixBasicComponentDefaults.insideMargin]。
  final EdgeInsetsGeometry insideMargin;

  /// 是否处于按压态（用于外部强制按下视觉效果）。
  final bool holdDownState;

  /// 是否启用。
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleColor =
        titleColor ?? MiuixBasicComponentDefaults.titleColor(context);
    final effectiveSummaryColor =
        summaryColor ?? MiuixBasicComponentDefaults.summaryColor(context);
    final effectiveCheckboxColors =
        checkboxColors ?? MiuixCheckboxDefaults.checkboxColors(context);

    final bool interactive = enabled && onChanged != null;
    final ValueChanged<bool?>? checkboxCallback =
        interactive ? (bool? _) => onChanged!(!value) : null;

    final Widget checkboxWidget = MiuixCheckbox(
      value: value,
      onChanged: checkboxCallback,
      enabled: enabled,
      colors: effectiveCheckboxColors,
    );

    // 起始侧：复选框（如果在起始）+ 调用方 startAction。
    final Widget? startActionWidget;
    if (checkboxLocation == MiuixCheckboxLocation.start ||
        startAction != null) {
      startActionWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (checkboxLocation == MiuixCheckboxLocation.start)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 5),
              child: checkboxWidget,
            ),
          if (startAction != null)
            Flexible(
              fit: FlexFit.loose,
              flex: 1,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 5),
                child: startAction!,
              ),
            ),
        ],
      );
    } else {
      startActionWidget = null;
    }

    // 末尾侧：调用方 endActions + 复选框（如果在末尾）。
    final hasExtraEndActions = endActions != null && endActions!.isNotEmpty;
    final List<Widget>? endActionsWithCheckbox;
    if (hasExtraEndActions || checkboxLocation == MiuixCheckboxLocation.end) {
      endActionsWithCheckbox = <Widget>[
        if (hasExtraEndActions)
          Flexible(
            fit: FlexFit.loose,
            flex: 1,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: endActions!,
              ),
            ),
          ),
        if (checkboxLocation == MiuixCheckboxLocation.end) checkboxWidget,
      ];
    } else {
      endActionsWithCheckbox = null;
    }

    return MiuixBasicComponent(
      title: title,
      titleColor: effectiveTitleColor,
      summary: summary,
      summaryColor: effectiveSummaryColor,
      startAction: startActionWidget,
      endActions: endActionsWithCheckbox,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      onClick: interactive ? () => onChanged!(!value) : null,
      role: MiuixBasicComponentRole.checkbox,
      holdDownState: holdDownState,
      enabled: enabled,
    );
  }
}
