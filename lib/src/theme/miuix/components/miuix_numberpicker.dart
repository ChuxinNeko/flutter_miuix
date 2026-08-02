// Miuix Flutter 移植版 - NumberPicker
// 源自 compose-miuix-ui/miuix 的 NumberPicker.kt。
// 垂直滚动数字选择器，中心选中，远离中心的项渐隐缩小，支持循环与惯性 snap。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme/miuix_text_styles.dart';
import '../theme/miuix_theme.dart';

/// NumberPicker 颜色配置。对应 Kotlin `NumberPickerColors`。
@immutable
class MiuixNumberPickerColors {
  const MiuixNumberPickerColors({
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.disabledSelectedTextColor,
    required this.disabledUnselectedTextColor,
  });

  final Color selectedTextColor;
  final Color unselectedTextColor;
  final Color disabledSelectedTextColor;
  final Color disabledUnselectedTextColor;

  Color selectedTextColorFor(bool enabled) =>
      enabled ? selectedTextColor : disabledSelectedTextColor;
  Color unselectedTextColorFor(bool enabled) =>
      enabled ? unselectedTextColor : disabledUnselectedTextColor;
}

class MiuixNumberPickerDefaults {
  MiuixNumberPickerDefaults._();

  /// 每项高度。
  static const double itemHeight = 45;

  static MiuixNumberPickerColors colors(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    return MiuixNumberPickerColors(
      selectedTextColor: c.onSurface,
      unselectedTextColor: c.onSurfaceSecondary,
      disabledSelectedTextColor: c.disabledOnSecondary,
      disabledUnselectedTextColor: c.disabledOnSecondary,
    );
  }
}

/// Miuix 风格的垂直数字选择器。对应 Kotlin `NumberPicker`。
class MiuixNumberPicker extends StatefulWidget {
  const MiuixNumberPicker({
    super.key,
    required this.value,
    required this.onValueChanged,
    this.enabled = true,
    this.min = 0,
    this.max = 10,
    this.label,
    this.visibleItemCount = 5,
    this.wrapAround = false,
    this.colors,
    this.textStyle,
    this.itemHeight = MiuixNumberPickerDefaults.itemHeight,
  })  : assert(
            visibleItemCount % 2 == 1 && visibleItemCount >= 3,
            'visibleItemCount must be odd and at least 3'),
        assert(min <= max, 'range must not be empty');

  final int value;
  final ValueChanged<int>? onValueChanged;
  final bool enabled;
  final int min;
  final int max;
  final String Function(int)? label;
  final int visibleItemCount;
  final bool wrapAround;
  final MiuixNumberPickerColors? colors;
  final TextStyle? textStyle;
  final double itemHeight;

  @override
  State<MiuixNumberPicker> createState() => _MiuixNumberPickerState();
}

class _MiuixNumberPickerState extends State<MiuixNumberPicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _offset;

  bool _isDragging = false;
  bool _isUserScrolling = false;
  int _lastHapticIndex = 0;

  @override
  void initState() {
    super.initState();
    _offset = AnimationController.unbounded(vsync: this, value: 0.0);
    _offset.addListener(_onOffsetChanged);
    _lastHapticIndex = _currentIndex;
  }

  @override
  void didUpdateWidget(MiuixNumberPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.min != widget.min ||
        oldWidget.max != widget.max) {
      // 外部 value 变化时，重置偏移
      if (!_isDragging) {
        _offset.value = 0.0;
      }
      _lastHapticIndex = _currentIndex;
    }
  }

  @override
  void dispose() {
    _offset.removeListener(_onOffsetChanged);
    _offset.dispose();
    super.dispose();
  }

  bool get _effectiveEnabled =>
      widget.enabled && widget.onValueChanged != null;

  int get _itemCount => widget.max - widget.min + 1;
  int get _currentIndex => widget.value.clamp(widget.min, widget.max) - widget.min;
  int get _halfVisible => widget.visibleItemCount ~/ 2;

  String _labelFor(int value) =>
      widget.label?.call(value) ?? value.toString();

  int _computeEffectiveIndex() {
    final rawIndex = _currentIndex + _offset.value.round();
    if (widget.wrapAround) {
      return ((rawIndex % _itemCount) + _itemCount) % _itemCount;
    }
    return rawIndex.clamp(0, _itemCount - 1);
  }

  void _onOffsetChanged() {
    final effectiveIndex = _computeEffectiveIndex();
    if (effectiveIndex != _lastHapticIndex) {
      if (_isUserScrolling) {
        HapticFeedback.selectionClick();
      }
      _lastHapticIndex = effectiveIndex;
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_effectiveEnabled) return;
    var newOffset = _offset.value - details.delta.dy / widget.itemHeight;
    if (!widget.wrapAround) {
      newOffset = newOffset.clamp(
        -_currentIndex.toDouble(),
        (_itemCount - 1 - _currentIndex).toDouble(),
      );
    }
    _offset.value = newOffset;
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_effectiveEnabled) return;
    _isDragging = false;

    // fling：带初速度的 spring 动画到最近项
    final velocityItems =
        -details.velocity.pixelsPerSecond.dy / widget.itemHeight;
    var target = _offset.value.round().toDouble();
    if (!widget.wrapAround) {
      target = target.clamp(
        -_currentIndex.toDouble(),
        (_itemCount - 1 - _currentIndex).toDouble(),
      );
    }

    _offset
        .animateWith(
          SpringSimulation(
            const SpringDescription(mass: 1, stiffness: 400, damping: 26.0),
            _offset.value,
            target,
            velocityItems,
          ),
        )
        .then((_) {
      final offsetInt = _offset.value.round();
      int newIndex;
      if (widget.wrapAround) {
        newIndex =
            ((_currentIndex + offsetInt) % _itemCount + _itemCount) %
                _itemCount;
      } else {
        newIndex = (_currentIndex + offsetInt).clamp(0, _itemCount - 1);
      }
      final newValue = widget.min + newIndex;
      _offset.value = 0.0;
      _isUserScrolling = false;
      if (newValue != widget.value) {
        widget.onValueChanged?.call(newValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        widget.colors ?? MiuixNumberPickerDefaults.colors(context);
    final theme = MiuixTheme.of(context);
    final baseStyle = widget.textStyle ?? theme.textStyles.title1;
    final textStyle = baseStyle
        .copyWith(fontWeight: FontWeight.w600)
        .withMiuixWeight(theme.fontWeightAdjustment);
    final enabled = _effectiveEnabled;
    final selectedColor = colors.selectedTextColorFor(enabled);
    final unselectedColor = colors.unselectedTextColorFor(enabled);
    final totalHeight = widget.itemHeight * widget.visibleItemCount;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: enabled
          ? (_) {
              _offset.stop();
              _isDragging = true;
              _isUserScrolling = true;
            }
          : null,
      onVerticalDragUpdate: enabled ? _onDragUpdate : null,
      onVerticalDragEnd: enabled ? _onDragEnd : null,
      child: SizedBox(
        height: totalHeight,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _offset,
            builder: (context, _) {
              final totalOffset = _offset.value;
              final centerItemOffset = totalOffset - totalOffset.roundToDouble();
              final roundedOffset = totalOffset.round();

              return Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = -_halfVisible - 1;
                      i <= _halfVisible + 1;
                      i++)
                    _buildItem(
                      i: i,
                      currentIndex: _currentIndex,
                      roundedOffset: roundedOffset,
                      centerItemOffset: centerItemOffset,
                      textStyle: textStyle,
                      selectedColor: selectedColor,
                      unselectedColor: unselectedColor,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required int i,
    required int currentIndex,
    required int roundedOffset,
    required double centerItemOffset,
    required TextStyle textStyle,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final rawItemIndex = currentIndex + i + roundedOffset;
    int itemIndex;
    if (widget.wrapAround) {
      itemIndex =
          ((rawItemIndex % _itemCount) + _itemCount) % _itemCount;
    } else {
      if (rawItemIndex < 0 || rawItemIndex >= _itemCount) {
        return const SizedBox.shrink();
      }
      itemIndex = rawItemIndex;
    }

    final distanceFromCenter = i.toDouble() - centerItemOffset;
    final normalizedDistance =
        (distanceFromCenter.abs() / (_halfVisible + 0.5)).clamp(0.0, 1.0);

    final alpha = (1.0 - normalizedDistance) * (1.0 - normalizedDistance * 0.5);
    final scale = 1.0 - 0.2 * normalizedDistance;
    final yOffset = distanceFromCenter * widget.itemHeight;

    final textColor = Color.lerp(
        selectedColor, unselectedColor, normalizedDistance)!;

    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: alpha,
          child: Text(
            _labelFor(widget.min + itemIndex),
            style: textStyle.copyWith(color: textColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
