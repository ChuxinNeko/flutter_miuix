// Miuix Flutter 移植版 - TabRow
// 源自 compose-miuix-ui/miuix 的 TabRow.kt。
// 用横向滚动 Stack、squircle 指示器和内缩描边复刻两种标签栏。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/miuix_squircle.dart';
import '../theme/miuix_motion.dart';
import '../theme/miuix_theme.dart';
import 'miuix_text.dart';

/// 对应 Kotlin `TabRowColors` 的颜色配置。
@immutable
class MiuixTabRowColors {
  const MiuixTabRowColors({
    required this.backgroundColor,
    required this.contentColor,
    required this.selectedBackgroundColor,
    required this.selectedContentColor,
  });

  final Color backgroundColor;
  final Color contentColor;
  final Color selectedBackgroundColor;
  final Color selectedContentColor;

  Color background(bool selected) =>
      selected ? selectedBackgroundColor : backgroundColor;
  Color content(bool selected) =>
      selected ? selectedContentColor : contentColor;
}

/// 对应 Kotlin `TabRowDefaults` 的默认值。
class MiuixTabRowDefaults {
  MiuixTabRowDefaults._();

  static const double tabRowHeight = 42;
  static const double tabRowWithContourHeight = 45;
  static const double tabRowCornerRadius = 12;
  static const double tabRowWithContourCornerRadius = 8;
  static const double tabRowMinWidth = 76;
  static const double tabRowWithContourMinWidth = 62;
  static const double tabRowMaxWidth = 98;
  static const double tabRowWithContourMaxWidth = 84;
  static const double tabRowItemSpacing = 9;
  static const double contourItemSpacing = 5;
  static const double contourPadding = 5;
  static const double itemHorizontalPadding = 12;
  static const double borderWidth = 1;

  static MiuixTabRowColors defaultColors(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return MiuixTabRowColors(
      backgroundColor: colors.surface,
      contentColor: colors.onSurfaceVariantSummary,
      selectedBackgroundColor: colors.surfaceContainer,
      selectedContentColor: colors.onBackground,
    );
  }
}

/// 对应 Kotlin `TabRow` 的 Miuix 标签栏。
class MiuixTabRow extends StatelessWidget {
  const MiuixTabRow({
    super.key,
    required this.tabs,
    required this.selectedTabIndex,
    required this.onTabSelected,
    this.colors,
    this.minWidth = MiuixTabRowDefaults.tabRowMinWidth,
    this.maxWidth = MiuixTabRowDefaults.tabRowMaxWidth,
    this.height = MiuixTabRowDefaults.tabRowHeight,
    this.cornerRadius = MiuixTabRowDefaults.tabRowCornerRadius,
    this.itemSpacing = MiuixTabRowDefaults.tabRowItemSpacing,
    this.contentAlignment = Alignment.center,
    this.scrollController,
  });

  final List<String> tabs;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final MiuixTabRowColors? colors;
  final double minWidth;
  final double maxWidth;
  final double height;
  final double cornerRadius;
  final double itemSpacing;
  final AlignmentGeometry contentAlignment;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => _TabRowBase(
    tabs: tabs,
    selectedTabIndex: selectedTabIndex,
    onTabSelected: onTabSelected,
    colors: colors,
    minWidth: minWidth,
    maxWidth: maxWidth,
    height: height,
    cornerRadius: cornerRadius,
    itemSpacing: itemSpacing,
    contentAlignment: contentAlignment,
    scrollController: scrollController,
    contour: false,
  );
}

/// 对应 Kotlin `TabRowWithContour` 的带外轮廓标签栏。
class MiuixTabRowWithContour extends StatelessWidget {
  const MiuixTabRowWithContour({
    super.key,
    required this.tabs,
    required this.selectedTabIndex,
    required this.onTabSelected,
    this.colors,
    this.minWidth = MiuixTabRowDefaults.tabRowWithContourMinWidth,
    this.maxWidth = MiuixTabRowDefaults.tabRowWithContourMaxWidth,
    this.height = MiuixTabRowDefaults.tabRowWithContourHeight,
    this.cornerRadius = MiuixTabRowDefaults.tabRowWithContourCornerRadius,
    this.itemSpacing = MiuixTabRowDefaults.contourItemSpacing,
    this.contentAlignment = Alignment.center,
    this.scrollController,
  });

  final List<String> tabs;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final MiuixTabRowColors? colors;
  final double minWidth;
  final double maxWidth;
  final double height;
  final double cornerRadius;
  final double itemSpacing;
  final AlignmentGeometry contentAlignment;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => _TabRowBase(
    tabs: tabs,
    selectedTabIndex: selectedTabIndex,
    onTabSelected: onTabSelected,
    colors: colors,
    minWidth: minWidth,
    maxWidth: maxWidth,
    height: height,
    cornerRadius: cornerRadius,
    itemSpacing: itemSpacing,
    contentAlignment: contentAlignment,
    scrollController: scrollController,
    contour: true,
  );
}

class _TabRowBase extends StatefulWidget {
  const _TabRowBase({
    required this.tabs,
    required this.selectedTabIndex,
    required this.onTabSelected,
    required this.colors,
    required this.minWidth,
    required this.maxWidth,
    required this.height,
    required this.cornerRadius,
    required this.itemSpacing,
    required this.contentAlignment,
    required this.scrollController,
    required this.contour,
  });

  final List<String> tabs;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final MiuixTabRowColors? colors;
  final double minWidth;
  final double maxWidth;
  final double height;
  final double cornerRadius;
  final double itemSpacing;
  final AlignmentGeometry contentAlignment;
  final ScrollController? scrollController;
  final bool contour;

  @override
  State<_TabRowBase> createState() => _TabRowBaseState();
}

class _TabRowBaseState extends State<_TabRowBase> {
  late ScrollController _controller;
  int _lastSettled = -1;

  @override
  void initState() {
    super.initState();
    _controller = widget.scrollController ?? ScrollController();
  }

  @override
  void didUpdateWidget(_TabRowBase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      if (oldWidget.scrollController == null) _controller.dispose();
      _controller = widget.scrollController ?? ScrollController();
      _lastSettled = -1;
    }
  }

  void _centerSelected(double available, double tabWidth) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_controller.hasClients || widget.tabs.isEmpty) return;
      final index = widget.selectedTabIndex.clamp(0, widget.tabs.length - 1);
      final pitch = tabWidth + widget.itemSpacing;
      final target = (index * pitch - (available - tabWidth) / 2).clamp(
        0.0,
        _controller.position.maxScrollExtent,
      );
      final animate = _lastSettled >= 0 && _lastSettled != index;
      _lastSettled = index;
      if (animate) {
        await _controller.animateTo(
          target,
          duration: const Duration(milliseconds: 275),
          curve: MiuixMotion.standardDecelerate,
        );
      } else {
        _controller.jumpTo(target);
      }
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixTabRowDefaults.defaultColors(context);
    final padding = widget.contour ? MiuixTabRowDefaults.contourPadding : 0.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
        final available = math.max(0.0, width - padding * 2);
        final tabWidth = _calculateTabWidth(
          widget.tabs.length,
          widget.minWidth,
          widget.maxWidth,
          widget.itemSpacing,
          available,
        );
        _centerSelected(available, tabWidth);
        final totalWidth = widget.tabs.isEmpty
            ? 0.0
            : tabWidth * widget.tabs.length +
                  widget.itemSpacing * (widget.tabs.length - 1);
        final selected = widget.tabs.isEmpty
            ? 0
            : widget.selectedTabIndex.clamp(0, widget.tabs.length - 1);
        final indicatorLeft = selected * (tabWidth + widget.itemSpacing);

        Widget scrollContent = SizedBox(
          width: totalWidth,
          height: widget.height - padding * 2,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: widget.contour && _lastSettled >= 0
                    ? const Duration(milliseconds: 200)
                    : Duration.zero,
                curve: Curves.linear,
                left: indicatorLeft,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: colors.background(true),
                    shape: MiuixSquircleBorder(
                      cornerRadius: widget.cornerRadius,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < widget.tabs.length; i++) ...[
                    if (i > 0) SizedBox(width: widget.itemSpacing),
                    _TabItem(
                      text: widget.tabs[i],
                      index: i,
                      count: widget.tabs.length,
                      selected: selected == i,
                      width: tabWidth,
                      contour: widget.contour,
                      cornerRadius: widget.cornerRadius,
                      alignment: widget.contentAlignment,
                      color: colors.content(selected == i),
                      outlineColor: MiuixTheme.of(context).colors.outline,
                      onTap: () => widget.onTabSelected(i),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
        scrollContent = SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: scrollContent,
        );
        final body = Padding(
          padding: EdgeInsets.all(padding),
          child: scrollContent,
        );
        return SizedBox(
          width: double.infinity,
          height: widget.height,
          child: widget.contour
              ? DecoratedBox(
                  decoration: ShapeDecoration(
                    color: colors.background(false),
                    shape: MiuixSquircleBorder(
                      cornerRadius: widget.cornerRadius + padding,
                    ),
                  ),
                  child: body,
                )
              : ColoredBox(color: colors.background(false), child: body),
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.text,
    required this.index,
    required this.count,
    required this.selected,
    required this.width,
    required this.contour,
    required this.cornerRadius,
    required this.alignment,
    required this.color,
    required this.outlineColor,
    required this.onTap,
  });

  final String text;
  final int index;
  final int count;
  final bool selected;
  final double width;
  final bool contour;
  final double cornerRadius;
  final AlignmentGeometry alignment;
  final Color color;
  final Color outlineColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      width: width,
      height: double.infinity,
      padding: contour
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(
              horizontal: MiuixTabRowDefaults.itemHorizontalPadding,
            ),
      alignment: alignment,
      child: MiuixText(
        text,
        color: color,
        fontSize: contour
            ? MiuixTheme.of(context).textStyles.body2.fontSize
            : MiuixTheme.of(context).textStyles.body1.fontSize,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    if (!contour && !selected) {
      child = CustomPaint(
        foregroundPainter: _InsetSquircleBorderPainter(
          color: outlineColor,
          radius: cornerRadius,
        ),
        child: child,
      );
    }
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: '$text，标签 ${index + 1} / $count',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _InsetSquircleBorderPainter extends CustomPainter {
  const _InsetSquircleBorderPainter({
    required this.color,
    required this.radius,
  });
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = MiuixTabRowDefaults.borderWidth;
    final inset = stroke / 2;
    final path = Path();
    addSquircleRect(
      path,
      size.width - stroke,
      size.height - stroke,
      math.max(0, radius - inset),
    );
    canvas.drawPath(
      path.shift(Offset(inset, inset)),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_InsetSquircleBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

double _calculateTabWidth(
  int tabCount,
  double minWidth,
  double maxWidth,
  double spacing,
  double availableWidth,
) {
  if (tabCount == 0) return minWidth;
  final totalSpacing = tabCount > 1 ? (tabCount - 1) * spacing : 0.0;
  final contentWidth = availableWidth - totalSpacing;
  if (contentWidth <= 0) return minWidth;
  final idealWidth = contentWidth / tabCount;
  if (idealWidth < minWidth) return minWidth;
  if (idealWidth > maxWidth) {
    final totalMaxWidth = maxWidth * tabCount + totalSpacing;
    return totalMaxWidth < availableWidth ? idealWidth : maxWidth;
  }
  return idealWidth;
}
