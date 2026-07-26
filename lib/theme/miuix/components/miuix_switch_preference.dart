// Miuix Flutter 移植版 - SwitchPreference
// 源自 compose-miuix-preference/miuix 的 preference/SwitchPreference.kt。
// 在 BasicComponent 末尾追加一个 MiuixSwitch，行点击即切换开关状态。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import 'miuix_basic_component.dart';
import 'miuix_switch.dart';

/// 带开关的偏好设置行。对应 Kotlin `SwitchPreference`。
///
/// 在 [MiuixBasicComponent] 的末尾追加一个 [MiuixSwitch]；
/// 点击整行会触发 [onChanged] 并切换 [value]。开关本身也可独立交互。
class MiuixSwitchPreference extends StatelessWidget {
  const MiuixSwitchPreference({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.startAction,
    this.endActions,
    this.bottomAction,
    this.switchColors,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.holdDownState = false,
    this.enabled = true,
  });

  /// 当前开关状态。
  final bool value;

  /// 开关状态变更回调（非空）。
  final ValueChanged<bool> onChanged;

  /// 行标题。
  final String title;

  /// 标题颜色；为 null 时取 [MiuixBasicComponentDefaults.titleColor]。
  final MiuixBasicComponentColors? titleColor;

  /// 行摘要（可选）。
  final String? summary;

  /// 摘要颜色；为 null 时取 [MiuixBasicComponentDefaults.summaryColor]。
  final MiuixBasicComponentColors? summaryColor;

  /// 起始侧内容（可选）。
  final Widget? startAction;

  /// 开关之前的额外内容（可选）；以 `Row` 排列，末端 8dp 间距，
  /// 并以 `Flexible(loose)` 容纳，避免与开关争抢空间。
  final List<Widget>? endActions;

  /// 底部内容（可选），位于主行下方。
  final Widget? bottomAction;

  /// 开关颜色；为 null 时取 [MiuixSwitchDefaults.switchColors]。
  final MiuixSwitchColors? switchColors;

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
    final effectiveSwitchColors =
        switchColors ?? MiuixSwitchDefaults.switchColors(context);

    final hasExtraEndActions = endActions != null && endActions!.isNotEmpty;
    final List<Widget> endActionsWithSwitch = <Widget>[
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
      MiuixSwitch(
        value: value,
        onChanged: onChanged,
        enabled: enabled,
        colors: effectiveSwitchColors,
      ),
    ];

    return MiuixBasicComponent(
      title: title,
      titleColor: effectiveTitleColor,
      summary: summary,
      summaryColor: effectiveSummaryColor,
      startAction: startAction,
      endActions: endActionsWithSwitch,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      onClick: enabled ? () => onChanged(!value) : null,
      role: MiuixBasicComponentRole.switchControl,
      holdDownState: holdDownState,
      enabled: enabled,
    );
  }
}
