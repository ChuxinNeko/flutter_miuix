// Miuix Flutter 移植版 - 内容色传递
// 对应 Compose 的 `LocalContentColor`，由 Surface/Card/Button 等容器向下传递，
// 供 MiuixText 等子组件默认取色。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';

/// 向子树传递一个默认的"内容色"（文字/图标色）。
class MiuixContentColor extends InheritedWidget {
  const MiuixContentColor({
    super.key,
    required this.color,
    required super.child,
  });

  final Color color;

  /// 获取最近祖先的内容色；未包裹时返回黑色。
  static Color of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<MiuixContentColor>();
    return widget?.color ?? const Color(0xFF000000);
  }

  @override
  bool updateShouldNotify(MiuixContentColor oldWidget) =>
      color != oldWidget.color;
}
