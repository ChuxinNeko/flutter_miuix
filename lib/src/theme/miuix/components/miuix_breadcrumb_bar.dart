// Miuix Flutter 移植版 - BreadcrumbBar
// 源自 compose-miuix-ui/miuix 的 BreadcrumbBar.kt。
// 用可滚动 Row、后帧测量和内联路径绘制复刻胶囊面包屑及自动居中。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../theme/miuix_motion.dart';
import '../theme/miuix_theme.dart';
import 'miuix_text.dart';

/// 对应 Kotlin `BreadcrumbItem` 的单个路径段。
@immutable
class MiuixBreadcrumbItem {
  const MiuixBreadcrumbItem({required this.path, this.text});

  /// 用于重建完整路径的路径段。
  final String path;

  /// 显示文本；为 null 时显示 [path]。
  final String? text;
}

/// 对应 Kotlin `BreadcrumbBarColors` 的颜色配置。
@immutable
class MiuixBreadcrumbBarColors {
  const MiuixBreadcrumbBarColors({
    required this.color,
    required this.highlightColor,
    required this.disabledColor,
    required this.separatorColor,
    required this.backgroundColor,
    required this.highlightBackgroundColor,
    required this.disabledBackgroundColor,
  });

  final Color color;
  final Color highlightColor;
  final Color disabledColor;
  final Color separatorColor;
  final Color backgroundColor;
  final Color highlightBackgroundColor;
  final Color disabledBackgroundColor;
}

/// 对应 Kotlin `BreadcrumbBarDefaults` 的默认值。
class MiuixBreadcrumbBarDefaults {
  MiuixBreadcrumbBarDefaults._();

  static const EdgeInsets insideMargin = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
  static const double itemHeight = 32;
  static const double itemHorizontalPadding = 10;
  static const double itemMaxWidth = 160;

  /// 从当前 Miuix 主题构造默认颜色。
  static MiuixBreadcrumbBarColors defaultColors(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return MiuixBreadcrumbBarColors(
      color: colors.onBackground.withValues(alpha: 0.55),
      highlightColor: colors.primary,
      disabledColor: colors.disabledOnSecondaryVariant,
      separatorColor: colors.onSurfaceVariantActions,
      backgroundColor: colors.onBackground.withValues(alpha: 0.1),
      highlightBackgroundColor: colors.primary.withValues(alpha: 0.2),
      disabledBackgroundColor: colors.disabledSecondaryVariant,
    );
  }
}

/// 对应 Kotlin `BreadcrumbBar` 的横向面包屑导航栏。
///
/// 内容溢出时横向滚动；[highlightIndex] 为负数时同时关闭高亮和自动居中。
class MiuixBreadcrumbBar extends StatefulWidget {
  const MiuixBreadcrumbBar({
    super.key,
    required this.items,
    required this.onItemClick,
    this.highlightIndex,
    this.enabled = true,
    this.colors,
    this.insideMargin = MiuixBreadcrumbBarDefaults.insideMargin,
    this.itemMaxWidth = MiuixBreadcrumbBarDefaults.itemMaxWidth,
    this.scrollController,
  });

  final List<MiuixBreadcrumbItem> items;
  final ValueChanged<int> onItemClick;

  /// 高亮索引；null 表示最后一项，负数表示禁用高亮。
  final int? highlightIndex;
  final bool enabled;
  final MiuixBreadcrumbBarColors? colors;
  final EdgeInsets insideMargin;
  final double itemMaxWidth;
  final ScrollController? scrollController;

  @override
  State<MiuixBreadcrumbBar> createState() => _MiuixBreadcrumbBarState();
}

class _MiuixBreadcrumbBarState extends State<MiuixBreadcrumbBar> {
  late ScrollController _controller;
  final GlobalKey _viewportKey = GlobalKey();
  final GlobalKey _highlightKey = GlobalKey();
  bool _didInitialCenter = false;

  int get _highlightIndex => widget.highlightIndex ?? widget.items.length - 1;

  @override
  void initState() {
    super.initState();
    _controller = widget.scrollController ?? ScrollController();
    _scheduleCenter(animate: false);
  }

  @override
  void didUpdateWidget(MiuixBreadcrumbBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      if (oldWidget.scrollController == null) _controller.dispose();
      _controller = widget.scrollController ?? ScrollController();
      _didInitialCenter = false;
    }
    final oldIndex = oldWidget.highlightIndex ?? oldWidget.items.length - 1;
    if (oldIndex != _highlightIndex) {
      _scheduleCenter(animate: _didInitialCenter);
    } else if (oldWidget.items != widget.items) {
      _scheduleCenter(animate: false);
    }
  }

  void _scheduleCenter({required bool animate}) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _center(animate));
  }

  Future<void> _center(bool animate) async {
    if (!mounted || _highlightIndex < 0 || !_controller.hasClients) return;
    final itemBox =
        _highlightKey.currentContext?.findRenderObject() as RenderBox?;
    final viewportBox =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (itemBox == null || viewportBox == null || !itemBox.hasSize) return;
    final viewportWidth = _controller.position.viewportDimension;
    if (viewportWidth <= 0 || itemBox.size.width <= 0) return;
    final screenX =
        itemBox.localToGlobal(Offset.zero).dx -
        viewportBox.localToGlobal(Offset.zero).dx;
    final contentX = _controller.offset + screenX;
    final target = (contentX - (viewportWidth - itemBox.size.width) / 2).clamp(
      0.0,
      _controller.position.maxScrollExtent,
    );
    _didInitialCenter = true;
    if (animate) {
      await _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: MiuixMotion.standardDecelerate,
      );
    } else {
      _controller.jumpTo(target);
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        widget.colors ?? MiuixBreadcrumbBarDefaults.defaultColors(context);
    final children = <Widget>[];
    for (var index = 0; index < widget.items.length; index++) {
      if (index > 0) {
        children.add(
          _BreadcrumbSeparator(
            color: widget.enabled
                ? colors.separatorColor
                : colors.disabledColor,
          ),
        );
      }
      final highlighted = _highlightIndex >= 0 && index == _highlightIndex;
      children.add(
        KeyedSubtree(
          key: highlighted ? _highlightKey : null,
          child: _BreadcrumbSegment(
            text: widget.items[index].text ?? widget.items[index].path,
            highlighted: highlighted,
            enabled: widget.enabled,
            colors: colors,
            maxWidth: widget.itemMaxWidth,
            onTap: () => widget.onItemClick(index),
          ),
        ),
      );
    }
    _scheduleCenter(animate: false);
    return SingleChildScrollView(
      key: _viewportKey,
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: widget.insideMargin,
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _BreadcrumbSegment extends StatelessWidget {
  const _BreadcrumbSegment({
    required this.text,
    required this.highlighted,
    required this.enabled,
    required this.colors,
    required this.maxWidth,
    required this.onTap,
  });

  final String text;
  final bool highlighted;
  final bool enabled;
  final MiuixBreadcrumbBarColors colors;
  final double maxWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = !enabled
        ? colors.disabledBackgroundColor
        : highlighted
        ? colors.highlightBackgroundColor
        : colors.backgroundColor;
    final foreground = !enabled
        ? colors.disabledColor
        : highlighted
        ? colors.highlightColor
        : colors.color;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          height: MiuixBreadcrumbBarDefaults.itemHeight,
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(
            horizontal: MiuixBreadcrumbBarDefaults.itemHorizontalPadding,
          ),
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: background,
            shape: const StadiumBorder(),
          ),
          child: MiuixText(
            text,
            color: foreground,
            fontSize: MiuixTheme.of(context).textStyles.body2.fontSize,
            fontWeight: highlighted ? FontWeight.w500 : FontWeight.w400,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _BreadcrumbSeparator extends StatelessWidget {
  const _BreadcrumbSeparator({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget arrow = CustomPaint(
      size: const Size(10, 16),
      painter: _ChevronPainter(color),
    );
    if (Directionality.of(context) == TextDirection.rtl) {
      arrow = Transform.flip(flipX: true, child: arrow);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: arrow,
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(1.65, 1.469)
      ..cubicTo(1.929, 1.19, 2.381, 1.19, 2.66, 1.469)
      ..lineTo(8.721, 7.53)
      ..cubicTo(9, 7.809, 9, 8.261, 8.721, 8.54)
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
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.color != color;
}

/// 对应 Kotlin `joinToPath`，用 [separator] 拼接所有路径段。
extension MiuixBreadcrumbItemsPath on List<MiuixBreadcrumbItem> {
  String joinToPath({String separator = '/'}) =>
      map((item) => item.path).join(separator);
}
