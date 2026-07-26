// Miuix Flutter 移植版 - Card
// 源自 compose-miuix-ui/miuix 的 Card.kt。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../foundation/miuix_content_color.dart';
import '../foundation/miuix_pressable.dart';
import '../foundation/miuix_squircle.dart';
import '../theme/miuix_theme.dart';

/// Card 颜色配置。对应 Kotlin `CardColors`。
@immutable
class MiuixCardColors {
  const MiuixCardColors({required this.color, required this.contentColor});

  final Color color;
  final Color contentColor;
}

/// Card 默认值。对应 Kotlin `CardDefaults`。
class MiuixCardDefaults {
  MiuixCardDefaults._();

  /// 默认圆角半径。
  static const double cornerRadius = 16;

  /// 默认内边距。
  static const EdgeInsets insideMargin = EdgeInsets.zero;

  /// 默认颜色：surfaceContainer / onSurfaceContainer。
  static MiuixCardColors defaultColors(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    return MiuixCardColors(
      color: c.surfaceContainer,
      contentColor: c.onSurfaceContainer,
    );
  }
}

/// Miuix 风格的 Card。对应 Kotlin `Card`。
///
/// 使用 squircle 圆角，向下传递 [MiuixContentColor]。
/// 传入 [onPressed] 时可点击，并可选 sink/tilt 按压反馈。
class MiuixCard extends StatelessWidget {
  const MiuixCard({
    super.key,
    this.cornerRadius = MiuixCardDefaults.cornerRadius,
    this.insideMargin = MiuixCardDefaults.insideMargin,
    this.colors,
    this.onPressed,
    this.onLongPress,
    this.feedbackType = MiuixPressFeedbackType.none,
    this.child,
  });

  /// 圆角半径。
  final double cornerRadius;

  /// 内边距。
  final EdgeInsetsGeometry insideMargin;

  /// 颜色配置，默认取 [MiuixCardDefaults.defaultColors]。
  final MiuixCardColors? colors;

  /// 点击回调。
  final VoidCallback? onPressed;

  /// 长按回调。
  final VoidCallback? onLongPress;

  /// 按压反馈类型（sink/tilt）。
  final MiuixPressFeedbackType feedbackType;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final cardColors = colors ?? MiuixCardDefaults.defaultColors(context);
    final radius = BorderRadius.circular(cornerRadius);
    final shape = MiuixSquircleBorder(
      cornerRadius: cornerRadius,
      enabled: cornerRadius > 0,
    );

    Widget content = Padding(
      padding: insideMargin,
      child: child,
    );

    content = MiuixContentColor(
      color: cardColors.contentColor,
      child: DecoratedBox(
        decoration: ShapeDecoration(color: cardColors.color, shape: shape),
        child: content,
      ),
    );

    if (onPressed != null || onLongPress != null) {
      content = MiuixPressable(
        onPressed: onPressed,
        onLongPress: onLongPress,
        feedbackType: feedbackType,
        borderRadius: radius,
        child: content,
      );
    } else if (feedbackType != MiuixPressFeedbackType.none) {
      // 仅有反馈但无点击：仍包裹以应用反馈（罕见用法）。
      content = MiuixPressable(
        onPressed: null,
        feedbackType: feedbackType,
        borderRadius: radius,
        child: content,
      );
    }

    return content;
  }
}
