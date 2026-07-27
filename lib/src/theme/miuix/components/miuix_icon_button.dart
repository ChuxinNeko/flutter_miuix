// Miuix Flutter 移植版 - IconButton
// 源自 compose-miuix-ui/miuix 的 IconButton.kt。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../foundation/miuix_pressable.dart';
import '../foundation/miuix_squircle.dart';
import '../theme/miuix_theme.dart';

/// IconButton 默认值。对应 Kotlin `IconButtonDefaults`。
class MiuixIconButtonDefaults {
  MiuixIconButtonDefaults._();

  static const double minWidth = 40;
  static const double minHeight = 40;
  /// 圆形（直径 40）。
  static const double cornerRadius = 40;
}

/// Miuix 风格的图标按钮。对应 Kotlin `IconButton`。
class MiuixIconButton extends StatelessWidget {
  const MiuixIconButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.enabled = true,
    this.backgroundColor,
    this.cornerRadius = MiuixIconButtonDefaults.cornerRadius,
    this.minHeight = MiuixIconButtonDefaults.minHeight,
    this.minWidth = MiuixIconButtonDefaults.minWidth,
    this.holdDownState = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool enabled;

  /// 背景色，null 表示透明。
  final Color? backgroundColor;

  final double cornerRadius;
  final double minHeight;
  final double minWidth;

  /// 强制按住视觉态。对应 Kotlin `holdDownState`，下拉菜单展开期间置 true。
  final bool holdDownState;

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = enabled && onPressed != null;
    final shape = MiuixSquircleBorder(cornerRadius: cornerRadius);
    final radius = BorderRadius.circular(cornerRadius);

    // widthFactor/heightFactor=1：Center 贴内容尺寸（再由 ConstrainedBox 保证
    // 最小 40）。对应 Compose `defaultMinSize + contentAlignment=Center`。
    // 不设 factor 时 Center 会在有界宽松约束下撑满可用空间——顶栏测量层就
    // 曾把导航图标测成整屏宽，导致折叠标题避让到屏幕外。
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );

    if (backgroundColor != null) {
      content = DecoratedBox(
        decoration: ShapeDecoration(color: backgroundColor!, shape: shape),
        child: content,
      );
    }

    if (effectiveEnabled && holdDownState) {
      content = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          content,
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: MiuixTheme.of(context)
                    .colors
                    .onBackground
                    .withValues(alpha: 0.10),
              ),
            ),
          ),
        ],
      );
    }

    return MiuixPressable(
      onPressed: effectiveEnabled ? onPressed : null,
      enabled: effectiveEnabled,
      borderRadius: radius,
      child: content,
    );
  }
}
