// Miuix Flutter 移植版 - ArrowPreference
// 源自 compose-miuix-preference/miuix 的 preference/ArrowPreference.kt。
// 在 BasicComponent 末尾追加一个右箭头图标，并复用其点击/按压/启用语义。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../theme/miuix_theme.dart';
import 'miuix_basic_component.dart';

/// ArrowPreference 末尾箭头的颜色配置。对应 Kotlin `EndActionColors`。
@immutable
class MiuixArrowPreferenceEndActionColors {
  const MiuixArrowPreferenceEndActionColors({
    required this.color,
    required this.disabledColor,
  });

  final Color color;
  final Color disabledColor;

  /// 根据 [enabled] 返回当前颜色。
  Color resolve(bool enabled) => enabled ? color : disabledColor;
}

/// ArrowPreference 默认值。对应 Kotlin `ArrowPreferenceDefaults`。
class MiuixArrowPreferenceDefaults {
  MiuixArrowPreferenceDefaults._();

  /// 末尾箭头的默认颜色：`onSurfaceVariantActions` / `disabledOnSecondaryVariant`。
  static MiuixArrowPreferenceEndActionColors endActionColors(
    BuildContext context,
  ) {
    final colors = MiuixTheme.of(context).colors;
    return MiuixArrowPreferenceEndActionColors(
      color: colors.onSurfaceVariantActions,
      disabledColor: colors.disabledOnSecondaryVariant,
    );
  }
}

/// 带右箭头的偏好设置行。对应 Kotlin `ArrowPreference`。
///
/// 在 [MiuixBasicComponent] 的末尾追加一个 10×16 的右箭头图标，
/// 颜色取自 [MiuixArrowPreferenceDefaults.endActionColors]。
/// RTL 布局下箭头自动水平翻转。点击行为复用 [MiuixBasicComponent] 的
/// 点击/按压/`holdDownState`/`enabled` 语义。
class MiuixArrowPreference extends StatelessWidget {
  const MiuixArrowPreference({
    super.key,
    required this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.startAction,
    this.endActions,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.onClick,
    this.holdDownState = false,
    this.enabled = true,
  });

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

  /// 末尾箭头之前的额外内容（可选）；以 `Row` 排列，水平方向 `min` 大小，
  /// 末端 8dp 间距，并以 `Flexible(loose)` 容纳，避免与箭头争抢空间。
  final List<Widget>? endActions;

  /// 底部内容（可选），位于主行下方。
  final Widget? bottomAction;

  /// 内边距，默认 [MiuixBasicComponentDefaults.insideMargin]。
  final EdgeInsetsGeometry insideMargin;

  /// 点击回调；为 null 时不可点击。
  final VoidCallback? onClick;

  /// 是否处于按压态（用于外部强制按下视觉效果）。
  final bool holdDownState;

  /// 是否启用。
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final endActionColors = MiuixArrowPreferenceDefaults.endActionColors(
      context,
    );
    final effectiveTitleColor =
        titleColor ?? MiuixBasicComponentDefaults.titleColor(context);
    final effectiveSummaryColor =
        summaryColor ?? MiuixBasicComponentDefaults.summaryColor(context);

    final hasExtraEndActions = endActions != null && endActions!.isNotEmpty;
    final List<Widget> endActionsWithArrow = <Widget>[
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
      _ArrowPreferenceEndAction(
        colors: endActionColors,
        enabled: enabled,
      ),
    ];

    return MiuixBasicComponent(
      title: title,
      titleColor: effectiveTitleColor,
      summary: summary,
      summaryColor: effectiveSummaryColor,
      startAction: startAction,
      endActions: endActionsWithArrow,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      onClick: onClick,
      holdDownState: holdDownState,
      enabled: enabled,
    );
  }
}

/// ArrowPreference 末尾的右箭头图标。对应 Kotlin `ArrowPreferenceEndAction`。
///
/// 固定 10×16 逻辑像素，RTL 下水平翻转。
class _ArrowPreferenceEndAction extends StatelessWidget {
  const _ArrowPreferenceEndAction({
    required this.colors,
    required this.enabled,
  });

  final MiuixArrowPreferenceEndActionColors colors;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tint = colors.resolve(enabled);
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

/// ArrowRight 箭头（'>'）画笔。源自 `icon/basic/ArrowRight.kt`，视口 10x16，evenOdd。
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
