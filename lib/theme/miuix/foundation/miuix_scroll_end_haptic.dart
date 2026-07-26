// Miuix Flutter 移植版 - 滚动到边界触觉反馈
// 源自 compose-miuix-ui/miuix 的 utils/ScrollEndHaptic.kt。
// Compose 用 NestedScrollConnection 的 onPreScroll/onPostFling 判定「惯性甩到顶/底
// 边界」并触发一次触觉；Flutter 用 NotificationListener<ScrollNotification> 监听
// Overscroll（甩到边界的越界通知）+ ScrollUpdate（离开边界时复位）复刻同一状态机。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

/// 触觉反馈类型。对应 Kotlin `HapticFeedbackType`。
///
/// 默认 [textHandleMove]：与 Android `TextHandleMove` 一样是轻微的「咔哒」触感，
/// 映射到 Flutter 的 [HapticFeedback.selectionClick]。
enum MiuixHapticFeedbackType {
  /// 轻微选择反馈（默认）。对应 Android `TextHandleMove`。
  textHandleMove,

  /// 轻碰。
  lightImpact,

  /// 中等碰撞。
  mediumImpact,

  /// 重碰撞。
  heavyImpact,
}

Future<void> _perform(MiuixHapticFeedbackType type) {
  switch (type) {
    case MiuixHapticFeedbackType.textHandleMove:
      return HapticFeedback.selectionClick();
    case MiuixHapticFeedbackType.lightImpact:
      return HapticFeedback.lightImpact();
    case MiuixHapticFeedbackType.mediumImpact:
      return HapticFeedback.mediumImpact();
    case MiuixHapticFeedbackType.heavyImpact:
      return HapticFeedback.heavyImpact();
  }
}

// 阈值，对应 Kotlin 的三个常量。
const double _preScrollResetThreshold = 1.0;
const double _postFlingOverscrollThreshold = 1.0;

enum _BoundaryState { idle, topHit, bottomHit }

/// 当可滚动内容被**惯性甩到**起始/末尾边界时触发一次触觉反馈。
/// 对应 Kotlin `Modifier.scrollEndHaptic()`。
///
/// 用法：用它包裹含有可滚动子组件（如 [ListView]、[SingleChildScrollView]）的子树：
/// ```dart
/// MiuixScrollEndHaptic(
///   child: ListView(children: [...]),
/// )
/// ```
///
/// 语义与原版一致：从边界往内容方向滚动时复位状态；仅在「甩动越界且被消费的速度
/// 不算太小」时触发，且每次触边只触发一次，避免连续抖动。
class MiuixScrollEndHaptic extends StatefulWidget {
  const MiuixScrollEndHaptic({
    super.key,
    this.hapticFeedbackType = MiuixHapticFeedbackType.textHandleMove,
    required this.child,
  });

  /// 触觉类型。对应 Kotlin `hapticFeedbackType`（默认 TextHandleMove）。
  final MiuixHapticFeedbackType hapticFeedbackType;

  final Widget child;

  @override
  State<MiuixScrollEndHaptic> createState() => _MiuixScrollEndHapticState();
}

class _MiuixScrollEndHapticState extends State<MiuixScrollEndHaptic> {
  _BoundaryState _state = _BoundaryState.idle;

  bool _onNotification(ScrollNotification n) {
    if (n is ScrollUpdateNotification) {
      // 从边界往内容方向滚动 → 复位。scrollDelta>0 表示向下（内容上移），
      // 对应从顶部边界离开；<0 反之。阈值同 Kotlin PRE_SCROLL_RESET_THRESHOLD。
      final delta = n.scrollDelta ?? 0.0;
      if (_state == _BoundaryState.topHit && delta > _preScrollResetThreshold) {
        _state = _BoundaryState.idle;
      } else if (_state == _BoundaryState.bottomHit &&
          delta < -_preScrollResetThreshold) {
        _state = _BoundaryState.idle;
      }
    } else if (n is OverscrollNotification) {
      // 仅处理惯性甩动（无拖拽手指）越界，对应 onPostFling；拖拽越界(dragDetails!=null)不触发。
      if (n.dragDetails != null) return false;
      final over = n.overscroll;
      if (over < -_postFlingOverscrollThreshold) {
        // 甩过顶部边界。
        if (_state != _BoundaryState.topHit) {
          _perform(widget.hapticFeedbackType);
          _state = _BoundaryState.topHit;
        }
      } else if (over > _postFlingOverscrollThreshold) {
        // 甩过底部边界。
        if (_state != _BoundaryState.bottomHit) {
          _perform(widget.hapticFeedbackType);
          _state = _BoundaryState.bottomHit;
        }
      }
    }
    return false; // 不拦截通知，继续向上冒泡。
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: widget.child,
    );
  }
}
