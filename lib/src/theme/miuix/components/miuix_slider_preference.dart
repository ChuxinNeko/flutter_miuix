// Miuix Flutter 移植版 - SliderPreference / RangeSliderPreference
// 源自 compose-miuix-preference/miuix 的 preference/SliderPreference.kt。
// 在 BasicComponent 的底部区域放置 MiuixSlider / MiuixRangeSlider；
// 末尾区域可显示当前值文本与（当 onClick 非空时）右箭头图标。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../theme/miuix_theme.dart';
import 'miuix_arrow_preference.dart';
import 'miuix_basic_component.dart';
import 'miuix_slider.dart';
import 'miuix_text.dart';

/// 带滑块的偏好设置行。对应 Kotlin `SliderPreference`。
///
/// [MiuixSlider] 放置在 [MiuixBasicComponent] 的底部区域（[bottomAction] 之下）。
/// 末尾区域可显示 [valueText] 与 [endActions]；当 [onClick] 非空时追加右箭头图标。
class MiuixSliderPreference extends StatelessWidget {
  const MiuixSliderPreference({
    super.key,
    required this.value,
    required this.onValueChange,
    this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.startAction,
    this.valueText,
    this.endActions,
    this.bottomAction,
    this.onClick,
    this.holdDownState = false,
    this.enabled = true,
    this.min = 0.0,
    this.max = 1.0,
    this.steps = 0,
    this.onValueChangeFinished,
    this.reverseDirection = false,
    this.sliderHeight = MiuixSliderDefaults.minHeight,
    this.sliderColors,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
    this.showKeyPoints = false,
    this.keyPoints,
    this.magnetThreshold = 0.02,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
  })  : assert(steps >= 0, 'steps should be >= 0'),
        assert(min < max, 'min should be less than max');

  /// 当前滑块值；会被夹到 [min]..[max]。
  final double value;

  /// 值变更回调。
  final ValueChanged<double> onValueChange;

  /// 行标题（可选）。
  final String? title;

  /// 标题颜色；为 null 时取 [MiuixBasicComponentDefaults.titleColor]。
  final MiuixBasicComponentColors? titleColor;

  /// 行摘要（可选）。
  final String? summary;

  /// 摘要颜色；为 null 时取 [MiuixBasicComponentDefaults.summaryColor]。
  final MiuixBasicComponentColors? summaryColor;

  /// 起始侧内容（可选）。
  final Widget? startAction;

  /// 末尾区域显示的当前值文本（可选）；样式为 `body2.fontSize`，
  /// 颜色为 `onSurfaceVariantActions`（禁用时 `disabledOnSecondaryVariant`）。
  final String? valueText;

  /// 末尾区域 [valueText] 之后的额外内容（可选）。
  final List<Widget>? endActions;

  /// 底部滑块上方的额外内容（可选）。
  final Widget? bottomAction;

  /// 点击回调；非空时末尾追加右箭头图标，整行可点击。
  final VoidCallback? onClick;

  /// 是否处于按压态。
  final bool holdDownState;

  /// 是否启用。
  final bool enabled;

  /// 滑块最小值。
  final double min;

  /// 滑块最大值。
  final double max;

  /// 离散步进数；0 表示连续。
  final int steps;

  /// 值变更结束回调。
  final VoidCallback? onValueChangeFinished;

  /// 是否反向（从右向左递增）。
  final bool reverseDirection;

  /// 滑块高度。
  final double sliderHeight;

  /// 滑块颜色；为 null 时取 [MiuixSliderDefaults.sliderColors]。
  final MiuixSliderColors? sliderColors;

  /// 触感反馈类型。
  final MiuixSliderHapticEffect hapticEffect;

  /// 是否显示关键点。
  final bool showKeyPoints;

  /// 自定义关键点；为 null 时使用 [steps] 推导。
  final List<double>? keyPoints;

  /// 磁吸阈值（0..1）。
  final double magnetThreshold;

  /// 内边距。
  final EdgeInsetsGeometry insideMargin;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final colors = theme.colors;
    final effectiveTitleColor =
        titleColor ?? MiuixBasicComponentDefaults.titleColor(context);
    final effectiveSummaryColor =
        summaryColor ?? MiuixBasicComponentDefaults.summaryColor(context);
    final effectiveSliderColors =
        sliderColors ?? MiuixSliderDefaults.sliderColors(context);

    final bool showArrow = onClick != null;
    final bool showEndArea =
        valueText != null || endActions != null || showArrow;

    final List<Widget>? endActionsWithArrow;
    if (showEndArea) {
      final hasExtraEndActions = endActions != null && endActions!.isNotEmpty;
      endActionsWithArrow = <Widget>[
        if (valueText != null || hasExtraEndActions)
          Flexible(
            fit: FlexFit.loose,
            flex: 1,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (valueText != null)
                    MiuixText(
                      valueText!,
                      fontSize: theme.textStyles.body2.fontSize,
                      color: enabled
                          ? colors.onSurfaceVariantActions
                          : colors.disabledOnSecondaryVariant,
                    ),
                  if (hasExtraEndActions) ...endActions!,
                ],
              ),
            ),
          ),
        if (showArrow)
          _SliderPreferenceArrowIcon(enabled: enabled),
      ];
    } else {
      endActionsWithArrow = null;
    }

    return MiuixBasicComponent(
      title: title,
      titleColor: effectiveTitleColor,
      summary: summary,
      summaryColor: effectiveSummaryColor,
      startAction: startAction,
      endActions: endActionsWithArrow,
      bottomAction: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ?bottomAction,
          MiuixSlider(
            value: value,
            onValueChanged: onValueChange,
            enabled: enabled,
            min: min,
            max: max,
            steps: steps,
            onValueChangeFinished: onValueChangeFinished,
            reverseDirection: reverseDirection,
            height: sliderHeight,
            colors: effectiveSliderColors,
            hapticEffect: hapticEffect,
            showKeyPoints: showKeyPoints,
            keyPoints: keyPoints,
            magnetThreshold: magnetThreshold,
          ),
        ],
      ),
      insideMargin: insideMargin,
      onClick: onClick,
      holdDownState: holdDownState,
      enabled: enabled,
    );
  }
}

/// 带范围滑块的偏好设置行。对应 Kotlin `RangeSliderPreference`。
///
/// [MiuixRangeSlider] 放置在 [MiuixBasicComponent] 的底部区域（[bottomAction] 之下）。
/// 末尾区域可显示 [valueText] 与 [endActions]；当 [onClick] 非空时追加右箭头图标。
class MiuixRangeSliderPreference extends StatelessWidget {
  const MiuixRangeSliderPreference({
    super.key,
    required this.startValue,
    required this.endValue,
    required this.onValueChange,
    this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.startAction,
    this.valueText,
    this.endActions,
    this.bottomAction,
    this.onClick,
    this.holdDownState = false,
    this.enabled = true,
    this.min = 0.0,
    this.max = 1.0,
    this.steps = 0,
    this.onValueChangeFinished,
    this.sliderHeight = MiuixSliderDefaults.minHeight,
    this.sliderColors,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
    this.showKeyPoints = false,
    this.keyPoints,
    this.magnetThreshold = 0.02,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
  })  : assert(steps >= 0, 'steps should be >= 0'),
        assert(min < max, 'min should be less than max');

  /// 起始值；会被夹到 [min]..[max]。
  final double startValue;

  /// 结束值；会被夹到 [min]..[max]。
  final double endValue;

  /// 值变更回调，参数为 `(newStart, newEnd)`。
  final ValueChanged<(double, double)> onValueChange;

  /// 行标题（可选）。
  final String? title;

  /// 标题颜色。
  final MiuixBasicComponentColors? titleColor;

  /// 行摘要（可选）。
  final String? summary;

  /// 摘要颜色。
  final MiuixBasicComponentColors? summaryColor;

  /// 起始侧内容（可选）。
  final Widget? startAction;

  /// 末尾区域显示的当前值文本（可选）。
  final String? valueText;

  /// 末尾区域额外内容（可选）。
  final List<Widget>? endActions;

  /// 底部滑块上方的额外内容（可选）。
  final Widget? bottomAction;

  /// 点击回调；非空时末尾追加右箭头图标，整行可点击。
  final VoidCallback? onClick;

  /// 是否处于按压态。
  final bool holdDownState;

  /// 是否启用。
  final bool enabled;

  /// 滑块最小值。
  final double min;

  /// 滑块最大值。
  final double max;

  /// 离散步进数。
  final int steps;

  /// 值变更结束回调。
  final VoidCallback? onValueChangeFinished;

  /// 滑块高度。
  final double sliderHeight;

  /// 滑块颜色。
  final MiuixSliderColors? sliderColors;

  /// 触感反馈类型。
  final MiuixSliderHapticEffect hapticEffect;

  /// 是否显示关键点。
  final bool showKeyPoints;

  /// 自定义关键点。
  final List<double>? keyPoints;

  /// 磁吸阈值。
  final double magnetThreshold;

  /// 内边距。
  final EdgeInsetsGeometry insideMargin;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final colors = theme.colors;
    final effectiveTitleColor =
        titleColor ?? MiuixBasicComponentDefaults.titleColor(context);
    final effectiveSummaryColor =
        summaryColor ?? MiuixBasicComponentDefaults.summaryColor(context);
    final effectiveSliderColors =
        sliderColors ?? MiuixSliderDefaults.sliderColors(context);

    final bool showArrow = onClick != null;
    final bool showEndArea =
        valueText != null || endActions != null || showArrow;

    final List<Widget>? endActionsWithArrow;
    if (showEndArea) {
      final hasExtraEndActions = endActions != null && endActions!.isNotEmpty;
      endActionsWithArrow = <Widget>[
        if (valueText != null || hasExtraEndActions)
          Flexible(
            fit: FlexFit.loose,
            flex: 1,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (valueText != null)
                    MiuixText(
                      valueText!,
                      fontSize: theme.textStyles.body2.fontSize,
                      color: enabled
                          ? colors.onSurfaceVariantActions
                          : colors.disabledOnSecondaryVariant,
                    ),
                  if (hasExtraEndActions) ...endActions!,
                ],
              ),
            ),
          ),
        if (showArrow) _SliderPreferenceArrowIcon(enabled: enabled),
      ];
    } else {
      endActionsWithArrow = null;
    }

    return MiuixBasicComponent(
      title: title,
      titleColor: effectiveTitleColor,
      summary: summary,
      summaryColor: effectiveSummaryColor,
      startAction: startAction,
      endActions: endActionsWithArrow,
      bottomAction: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ?bottomAction,
          MiuixRangeSlider(
            startValue: startValue,
            endValue: endValue,
            onValueChanged: onValueChange,
            enabled: enabled,
            min: min,
            max: max,
            steps: steps,
            onValueChangeFinished: onValueChangeFinished,
            height: sliderHeight,
            colors: effectiveSliderColors,
            hapticEffect: hapticEffect,
            showKeyPoints: showKeyPoints,
            keyPoints: keyPoints,
            magnetThreshold: magnetThreshold,
          ),
        ],
      ),
      insideMargin: insideMargin,
      onClick: onClick,
      holdDownState: holdDownState,
      enabled: enabled,
    );
  }
}

/// 滑块偏好行末尾的右箭头图标。对应 Kotlin `SliderPreferenceArrowIcon`。
///
/// 复用 [MiuixArrowPreferenceDefaults.endActionColors] 的颜色；
/// 固定 10×16 逻辑像素，RTL 下水平翻转。
class _SliderPreferenceArrowIcon extends StatelessWidget {
  const _SliderPreferenceArrowIcon({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final endActionColors =
        MiuixArrowPreferenceDefaults.endActionColors(context);
    final tint = endActionColors.resolve(enabled);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      width: 10,
      height: 16,
      child: Transform.scale(
        scaleX: isRtl ? -1 : 1,
        child: CustomPaint(
          painter: _ArrowRightPainter(color: tint),
        ),
      ),
    );
  }
}

/// ArrowRight 箭头画笔。视口 10x16，evenOdd。源自 `icon/basic/ArrowRight.kt`。
class _ArrowRightPainter extends CustomPainter {
  const _ArrowRightPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(1.65, 1.469)
      ..cubicTo(1.929, 1.19, 2.381, 1.19, 2.66, 1.469)
      ..lineTo(8.721, 7.53)
      ..cubicTo(9.0, 7.809, 9.0, 8.261, 8.721, 8.54)
      ..lineTo(2.66, 14.601)
      ..cubicTo(2.381, 14.88, 1.929, 14.88, 1.65, 14.601)
      ..cubicTo(1.371, 14.322, 1.371, 13.87, 1.65, 13.591)
      ..lineTo(7.205, 8.035)
      ..lineTo(1.65, 2.479)
      ..cubicTo(1.371, 2.2, 1.371, 1.748, 1.65, 1.469)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ArrowRightPainter oldDelegate) =>
      oldDelegate.color != color;
}
