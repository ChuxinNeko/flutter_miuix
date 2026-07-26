// Miuix Flutter 移植版 - RadioButtonPreference
// 源自 compose-miuix-preference/miuix 的 preference/RadioButtonPreference.kt。
// 在 BasicComponent 的起始或末尾追加一个 MiuixRadioButton；
// 选中态会改变标题与摘要的颜色，点击行触发 onClick 并给出触感反馈。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/miuix_theme.dart';
import 'miuix_basic_component.dart';
import 'miuix_radiobutton.dart';

/// 单选按钮的位置。对应 Kotlin `RadioButtonLocation`。
enum MiuixRadioButtonLocation {
  /// 起始侧（标题之前）。
  start,

  /// 末尾侧（endActions 之后）。
  end,
}

/// RadioButtonPreference 标题与摘要的颜色配置。
/// 对应 Kotlin `RadioButtonPreferenceColors`。
///
/// 根据 [selected] 切换 titleColor/summaryColor：选中时使用 `selected*Color`，
/// 否则使用基础 `*Color`。
@immutable
class MiuixRadioButtonPreferenceColors {
  const MiuixRadioButtonPreferenceColors({
    required this.titleColor,
    required this.selectedTitleColor,
    required this.summaryColor,
    required this.selectedSummaryColor,
  });

  final MiuixBasicComponentColors titleColor;
  final MiuixBasicComponentColors selectedTitleColor;
  final MiuixBasicComponentColors summaryColor;
  final MiuixBasicComponentColors selectedSummaryColor;

  /// 根据 [selected] 返回当前标题颜色。
  MiuixBasicComponentColors resolveTitleColor(bool selected) =>
      selected ? selectedTitleColor : titleColor;

  /// 根据 [selected] 返回当前摘要颜色。
  MiuixBasicComponentColors resolveSummaryColor(bool selected) =>
      selected ? selectedSummaryColor : summaryColor;
}

/// RadioButtonPreference 默认值。对应 Kotlin `RadioButtonPreferenceDefaults`。
class MiuixRadioButtonPreferenceDefaults {
  MiuixRadioButtonPreferenceDefaults._();

  /// 标题与摘要的默认颜色：未选中时使用 `onBackground`/`onSurfaceVariantSummary`，
  /// 选中时使用 `primary`。
  static MiuixRadioButtonPreferenceColors radioButtonPreferenceColors(
    BuildContext context,
  ) {
    final colors = MiuixTheme.of(context).colors;
    return MiuixRadioButtonPreferenceColors(
      titleColor: MiuixBasicComponentColors(
        color: colors.onBackground,
        disabledColor: colors.disabledOnSecondaryVariant,
      ),
      selectedTitleColor: MiuixBasicComponentColors(
        color: colors.primary,
        disabledColor: colors.disabledOnSecondaryVariant,
      ),
      summaryColor: MiuixBasicComponentColors(
        color: colors.onSurfaceVariantSummary,
        disabledColor: colors.disabledOnSecondaryVariant,
      ),
      selectedSummaryColor: MiuixBasicComponentColors(
        color: colors.primary,
        disabledColor: colors.disabledOnSecondaryVariant,
      ),
    );
  }
}

/// 带单选按钮的偏好设置行。对应 Kotlin `RadioButtonPreference`。
///
/// [MiuixRadioButton] 的位置由 [radioButtonLocation] 决定。当 [selected] 为
/// true 时单选按钮处于选中态，且标题/摘要颜色切换为 `primary`。
/// 点击整行会触发 [onClick] 并给出触感反馈（已选中→ToggleOff，未选中→ToggleOn）。
class MiuixRadioButtonPreference extends StatelessWidget {
  const MiuixRadioButtonPreference({
    super.key,
    required this.title,
    required this.selected,
    this.onClick,
    this.summary,
    this.colors,
    this.radioButtonColors,
    this.startAction,
    this.endActions,
    this.radioButtonLocation = MiuixRadioButtonLocation.start,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.holdDownState = false,
    this.enabled = true,
  });

  /// 行标题。
  final String title;

  /// 是否处于选中态。
  final bool selected;

  /// 点击回调；为 null 时行不可点击。
  final VoidCallback? onClick;

  /// 行摘要（可选）。
  final String? summary;

  /// 标题/摘要颜色；为 null 时取
  /// [MiuixRadioButtonPreferenceDefaults.radioButtonPreferenceColors]。
  final MiuixRadioButtonPreferenceColors? colors;

  /// 单选按钮颜色；为 null 时取 [MiuixRadioButtonDefaults.radioButtonColors]。
  final MiuixRadioButtonColors? radioButtonColors;

  /// 起始侧额外内容（可选）；位于单选按钮之后，带 5dp 末端间距。
  final Widget? startAction;

  /// 末尾额外内容（可选）；位于单选按钮之前，带 8dp 末端间距。
  final List<Widget>? endActions;

  /// 单选按钮位置，默认 [MiuixRadioButtonLocation.start]。
  final MiuixRadioButtonLocation radioButtonLocation;

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
    final effectiveColors = colors ??
        MiuixRadioButtonPreferenceDefaults.radioButtonPreferenceColors(context);
    final effectiveRadioButtonColors = radioButtonColors ??
        MiuixRadioButtonDefaults.radioButtonColors(context);

    final bool interactive = enabled && onClick != null;
    // 单选按钮在 Kotlin 中 onClick=null（仅作视觉指示），整行点击触发 onClick。
    // 为保持视觉启用态（MiuixRadioButton 把 onChanged=null 视为禁用并变灰），
    // 这里把行的点击行为同样挂到单选按钮上：点击单选按钮也会触发 onClick。
    final ValueChanged<bool>? radioButtonCallback =
        interactive ? (_) => _tap() : null;

    final Widget radioButtonWidget = MiuixRadioButton(
      selected: selected,
      onChanged: radioButtonCallback,
      enabled: enabled,
      colors: effectiveRadioButtonColors,
    );

    // 起始侧：单选按钮（如果在起始）+ 调用方 startAction。
    final Widget? startActionWidget;
    if (radioButtonLocation == MiuixRadioButtonLocation.start ||
        startAction != null) {
      startActionWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (radioButtonLocation == MiuixRadioButtonLocation.start)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 5),
              child: radioButtonWidget,
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

    // 末尾侧：调用方 endActions + 单选按钮（如果在末尾）。
    final hasExtraEndActions = endActions != null && endActions!.isNotEmpty;
    final List<Widget>? endActionsWithRadioButton;
    if (hasExtraEndActions ||
        radioButtonLocation == MiuixRadioButtonLocation.end) {
      endActionsWithRadioButton = <Widget>[
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
        if (radioButtonLocation == MiuixRadioButtonLocation.end)
          radioButtonWidget,
      ];
    } else {
      endActionsWithRadioButton = null;
    }

    return MiuixBasicComponent(
      title: title,
      titleColor: effectiveColors.resolveTitleColor(selected),
      summary: summary,
      summaryColor: effectiveColors.resolveSummaryColor(selected),
      startAction: startActionWidget,
      endActions: endActionsWithRadioButton,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      onClick: interactive ? _tap : null,
      role: MiuixBasicComponentRole.radioButton,
      holdDownState: holdDownState,
      enabled: enabled,
    );
  }

  /// 触发 [onClick] 并给出触感反馈。对应 Kotlin
  /// `currentHapticFeedback.performHapticFeedback(if (selected) ToggleOff else ToggleOn)`。
  /// Flutter 无 ToggleOn/Off 直接对应，统一使用 `selectionClick`。
  void _tap() {
    onClick!();
    HapticFeedback.selectionClick();
  }
}
