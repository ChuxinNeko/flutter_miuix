// Miuix Flutter 移植版 - NavigationRail
// 源自 compose-miuix-ui/miuix 的 NavigationRail.kt。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../foundation/miuix_pressable.dart';
import '../foundation/miuix_squircle.dart';
import '../icon/miuix_basic_icons.dart';
import '../theme/miuix_motion.dart';
import '../theme/miuix_text_styles.dart';
import '../theme/miuix_theme.dart';
import 'miuix_icon.dart';

/// 导航栏的展开状态。
enum MiuixNavigationRailValue { collapsed, expanded }

/// 控制 [MiuixNavigationRail] 展开与折叠的状态对象。
///
/// Flutter 没有 Compose `rememberSaveable` 对应的进程恢复机制；如需跨进程
/// 保存，请由业务层持久化 [currentValue] 并作为 [initialValue] 恢复。
class MiuixNavigationRailState extends ChangeNotifier {
  MiuixNavigationRailState({
    MiuixNavigationRailValue initialValue = MiuixNavigationRailValue.collapsed,
  }) : _currentValue = initialValue;

  MiuixNavigationRailValue _currentValue;

  /// 当前展开状态。
  MiuixNavigationRailValue get currentValue => _currentValue;

  /// 当前是否展开。
  bool get isExpanded => _currentValue == MiuixNavigationRailValue.expanded;

  /// 展开导航栏。
  void expand() => _setValue(MiuixNavigationRailValue.expanded);

  /// 折叠导航栏。
  void collapse() => _setValue(MiuixNavigationRailValue.collapsed);

  /// 在展开与折叠之间切换。
  void toggle() => isExpanded ? collapse() : expand();

  void _setValue(MiuixNavigationRailValue value) {
    if (_currentValue == value) return;
    _currentValue = value;
    notifyListeners();
  }
}

/// [MiuixNavigationRailState] 的控制器别名。
typedef MiuixNavigationRailController = MiuixNavigationRailState;

/// 导航栏颜色配置。
@immutable
class MiuixNavigationRailColors {
  const MiuixNavigationRailColors({
    required this.background,
    required this.content,
    required this.indicator,
    required this.divider,
  });

  final Color background;
  final Color content;
  final Color indicator;
  final Color divider;
}

/// NavigationRail 默认值。对应 Kotlin `NavigationRailDefaults`。
class MiuixNavigationRailDefaults {
  MiuixNavigationRailDefaults._();

  static const double minWidth = 80;
  static const double expandedWidth = 240;
  static const double verticalPadding = 24;
  static const double headerSpacing = 24;
  static const double iconSize = 28;
  static const double iconTextSpacing = 4;
  static const double itemVerticalPadding = 12;
  static const double labelFontSize = 12;
  static const double expandedLabelFontSize = 16;
  static const double expandedItemHorizontalMargin = 12;
  static const double expandedItemCornerRadius = 16;
  static const double collapsedIndicatorVerticalPadding = 4;
  static const double expandedItemContentHorizontalPadding = 14;
  static const double expandedItemContentVerticalPadding = 14;
  static const double expandedItemIconTextSpacing = 16;
  static const String expandContentDescription = 'Expand navigation rail';
  static const String collapseContentDescription = 'Collapse navigation rail';

  /// 从当前 Miuix 主题创建默认颜色。
  static MiuixNavigationRailColors colors(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return MiuixNavigationRailColors(
      background: colors.surface,
      content: colors.onSurfaceContainer,
      indicator: colors.surfaceContainerHigh,
      divider: colors.dividerLine,
    );
  }
}

/// 适合宽屏使用、可选展开控制器的 Miuix 导航栏。
///
/// [state] 为空时使用经典折叠布局且不显示切换按钮；非空时，栏宽、项目布局、
/// 选中背景和字号共享同一条弹簧动画。项目通过 [MiuixNavigationRailItem]
/// 自动取得动画信息。背景先于安全区留白绘制，因此可延伸到起始侧系统区域。
class MiuixNavigationRail extends StatefulWidget {
  const MiuixNavigationRail({
    super.key,
    required this.children,
    this.state,
    this.header,
    this.colors,
    this.showDivider = true,
    this.defaultWindowInsetsPadding = true,
    this.minWidth = MiuixNavigationRailDefaults.minWidth,
    this.expandedWidth = MiuixNavigationRailDefaults.expandedWidth,
    this.expandContentDescription =
        MiuixNavigationRailDefaults.expandContentDescription,
    this.collapseContentDescription =
        MiuixNavigationRailDefaults.collapseContentDescription,
    this.scrollController,
    this.iconSize = MiuixNavigationRailDefaults.iconSize,
    this.itemVerticalPadding =
        MiuixNavigationRailDefaults.itemVerticalPadding,
    this.expandedItemVerticalPadding =
        MiuixNavigationRailDefaults.expandedItemContentVerticalPadding,
    this.labelFontSize = MiuixNavigationRailDefaults.labelFontSize,
    this.expandedLabelFontSize =
        MiuixNavigationRailDefaults.expandedLabelFontSize,
  });

  final List<Widget> children;
  final MiuixNavigationRailState? state;
  final Widget? header;
  final MiuixNavigationRailColors? colors;
  final bool showDivider;
  final bool defaultWindowInsetsPadding;
  final double minWidth;
  final double expandedWidth;
  final String expandContentDescription;
  final String collapseContentDescription;
  final ScrollController? scrollController;

  /// 项目图标尺寸。默认 [MiuixNavigationRailDefaults.iconSize]（28，原版值）。
  /// 减小它会同时降低项目高度（折叠/展开态都变矮）。
  final double iconSize;

  /// 折叠态项目上下内边距。默认 [MiuixNavigationRailDefaults.itemVerticalPadding]（12）。
  final double itemVerticalPadding;

  /// 展开态项目上下内边距。默认
  /// [MiuixNavigationRailDefaults.expandedItemContentVerticalPadding]（14）。
  /// 减小它可直接降低展开态每项高度。
  final double expandedItemVerticalPadding;

  /// 折叠态标签字号。默认 [MiuixNavigationRailDefaults.labelFontSize]（12）。
  final double labelFontSize;

  /// 展开态标签字号。默认 [MiuixNavigationRailDefaults.expandedLabelFontSize]（16）。
  final double expandedLabelFontSize;

  @override
  State<MiuixNavigationRail> createState() => _MiuixNavigationRailState();
}

class _MiuixNavigationRailState extends State<MiuixNavigationRail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController.unbounded(vsync: this)
      ..value = widget.state?.isExpanded == true ? 1 : 0;
    widget.state?.addListener(_syncState);
  }

  @override
  void didUpdateWidget(covariant MiuixNavigationRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      oldWidget.state?.removeListener(_syncState);
      widget.state?.addListener(_syncState);
      _syncState();
    }
  }

  void _syncState() {
    final target = widget.state?.isExpanded == true ? 1.0 : 0.0;
    _progress.animateWith(
      SpringSimulation(
        folmeSpring(damping: 1, response: 0.35),
        _progress.value,
        target,
        0,
      ),
    );
  }

  @override
  void dispose() {
    widget.state?.removeListener(_syncState);
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixNavigationRailDefaults.colors(context);
    final media = MediaQuery.of(context);
    final direction = Directionality.of(context);
    final startInset = widget.defaultWindowInsetsPadding
        ? (direction == TextDirection.ltr
              ? media.padding.left
              : media.padding.right)
        : 0.0;
    final topInset = widget.defaultWindowInsetsPadding
        ? media.padding.top
        : 0.0;
    final bottomInset = widget.defaultWindowInsetsPadding
        ? media.padding.bottom
        : 0.0;

    return ColoredBox(
      color: colors.background,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: startInset),
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            final fraction = _progress.value.clamp(0.0, 1.0);
            final width = widget.state == null
                ? widget.minWidth
                : lerpDouble(
                    widget.minWidth,
                    math.max(widget.expandedWidth, widget.minWidth),
                    fraction,
                  )!;
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: width,
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    padding: EdgeInsets.only(
                      top:
                          topInset +
                          MiuixNavigationRailDefaults.verticalPadding,
                      bottom:
                          bottomInset +
                          MiuixNavigationRailDefaults.verticalPadding,
                    ),
                    child: Semantics(
                      container: true,
                      explicitChildNodes: true,
                      child: _MiuixNavigationRailScope(
                        progress: widget.state == null ? null : fraction,
                        collapsedWidth: widget.minWidth,
                        colors: colors,
                        iconSize: widget.iconSize,
                        itemVerticalPadding: widget.itemVerticalPadding,
                        expandedItemVerticalPadding:
                            widget.expandedItemVerticalPadding,
                        labelFontSize: widget.labelFontSize,
                        expandedLabelFontSize: widget.expandedLabelFontSize,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.state != null) ...[
                              _RailToggle(
                                state: widget.state!,
                                fraction: fraction,
                                collapsedWidth: widget.minWidth,
                                expandedLabel:
                                    widget.collapseContentDescription,
                                collapsedLabel: widget.expandContentDescription,
                                color: colors.content,
                              ),
                              const SizedBox(
                                height:
                                    MiuixNavigationRailDefaults.headerSpacing,
                              ),
                            ],
                            if (widget.header != null) ...[
                              Center(child: widget.header),
                              const SizedBox(
                                height:
                                    MiuixNavigationRailDefaults.headerSpacing,
                              ),
                            ],
                            ...widget.children,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.showDivider)
                  SizedBox(
                    width: 0.75,
                    child: ColoredBox(color: colors.divider),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RailToggle extends StatelessWidget {
  const _RailToggle({
    required this.state,
    required this.fraction,
    required this.collapsedWidth,
    required this.expandedLabel,
    required this.collapsedLabel,
    required this.color,
  });

  final MiuixNavigationRailState state;
  final double fraction;
  final double collapsedWidth;
  final String expandedLabel;
  final String collapsedLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const size =
        MiuixNavigationRailDefaults.iconSize +
        MiuixNavigationRailDefaults.expandedItemContentHorizontalPadding * 2;
    final collapsedX = (collapsedWidth - size) / 2;
    final x = lerpDouble(
      collapsedX,
      MiuixNavigationRailDefaults.expandedItemHorizontalMargin,
      fraction,
    )!;
    return SizedBox(
      height: size,
      child: Stack(
        children: [
          PositionedDirectional(
            start: x,
            child: Semantics(
              button: true,
              label: state.isExpanded ? expandedLabel : collapsedLabel,
              child: ExcludeSemantics(
                child: MiuixPressable(
                  onPressed: state.toggle,
                  borderRadius: BorderRadius.circular(size / 2),
                  child: SizedBox.square(
                    dimension: size,
                    child: Center(
                      child: MiuixIcon(
                        vector: MiuixIcons.basic.sidebar,
                        size: MiuixNavigationRailDefaults.iconSize,
                        tint: color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 导航栏项目，支持图标、标签以及可选徽标槽位。
///
/// [badge] 是任意 Widget，由本文件自包含地锚定到图标右上角，无需依赖尚未移植的
/// Badge 组件。图标为装饰内容，项目语义仅朗读 [label]。
class MiuixNavigationRailItem extends StatelessWidget {
  const MiuixNavigationRailItem({
    super.key,
    required this.selected,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.enabled = true,
    this.badge,
  });

  final bool selected;
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final bool enabled;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final scope = _MiuixNavigationRailScope.of(context);
    final effectiveEnabled = enabled && onPressed != null;
    final contentColor =
        scope?.colors.content ??
        MiuixNavigationRailDefaults.colors(context).content;
    // 尺寸从 scope 取（可被 MiuixNavigationRail 的可选参数覆盖）；无 scope 时回退默认常量。
    final iconSize = scope?.iconSize ?? MiuixNavigationRailDefaults.iconSize;
    final collapsedPad =
        scope?.itemVerticalPadding ??
        MiuixNavigationRailDefaults.itemVerticalPadding;
    final expandedPad =
        scope?.expandedItemVerticalPadding ??
        MiuixNavigationRailDefaults.expandedItemContentVerticalPadding;
    final collapsedFontSize =
        scope?.labelFontSize ?? MiuixNavigationRailDefaults.labelFontSize;
    final expandedFontSize =
        scope?.expandedLabelFontSize ??
        MiuixNavigationRailDefaults.expandedLabelFontSize;
    final tintedIcon = ColorFiltered(
      colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
      child: SizedBox.square(
        dimension: iconSize,
        child: FittedBox(fit: BoxFit.contain, child: icon),
      ),
    );
    final iconWithBadge = _BadgedIcon(icon: tintedIcon, badge: badge);
    final fraction = scope?.progress;

    Widget result;
    if (fraction == null) {
      result = Padding(
        padding: EdgeInsets.symmetric(vertical: collapsedPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWithBadge,
            const SizedBox(height: MiuixNavigationRailDefaults.iconTextSpacing),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: contentColor,
                fontSize: collapsedFontSize,
                fontWeight: FontWeight.w500,
              ).withMiuixWeight(MiuixTheme.of(context).fontWeightAdjustment),
            ),
          ],
        ),
      );
      result = MiuixPressable(
        onPressed: effectiveEnabled ? onPressed : null,
        enabled: effectiveEnabled,
        child: SizedBox(width: double.infinity, child: result),
      );
    } else {
      result = _ExpandableRailItem(
        fraction: fraction,
        collapsedWidth: scope!.collapsedWidth,
        selected: selected,
        enabled: effectiveEnabled,
        onPressed: onPressed,
        icon: iconWithBadge,
        label: label,
        colors: scope.colors,
        iconSize: iconSize,
        collapsedPad: collapsedPad,
        expandedPad: expandedPad,
        collapsedFontSize: collapsedFontSize,
        expandedFontSize: expandedFontSize,
      );
    }

    return Semantics(
      container: true,
      selected: selected,
      enabled: effectiveEnabled,
      button: true,
      label: label,
      onTap: effectiveEnabled ? onPressed : null,
      child: ExcludeSemantics(child: result),
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({required this.icon, this.badge});

  final Widget icon;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    if (badge == null) return icon;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        PositionedDirectional(top: -4, end: -8, child: badge!),
      ],
    );
  }
}

class _ExpandableRailItem extends StatelessWidget {
  const _ExpandableRailItem({
    required this.fraction,
    required this.collapsedWidth,
    required this.selected,
    required this.enabled,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.colors,
    required this.iconSize,
    required this.collapsedPad,
    required this.expandedPad,
    required this.collapsedFontSize,
    required this.expandedFontSize,
  });

  final double fraction;
  final double collapsedWidth;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final MiuixNavigationRailColors colors;
  final double iconSize;
  final double collapsedPad;
  final double expandedPad;
  final double collapsedFontSize;
  final double expandedFontSize;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: colors.content,
      fontSize: lerpDouble(collapsedFontSize, expandedFontSize, fraction),
      fontWeight: FontWeight.w500,
    ).withMiuixWeight(MiuixTheme.of(context).fontWeightAdjustment);
    return MiuixPressable(
      onPressed: enabled ? onPressed : null,
      enabled: enabled,
      borderRadius: BorderRadius.circular(
        MiuixNavigationRailDefaults.expandedItemCornerRadius,
      ),
      child: CustomMultiChildLayout(
        delegate: _RailItemLayoutDelegate(
          fraction: fraction,
          collapsedWidth: collapsedWidth,
          iconSize: iconSize,
          collapsedPad: collapsedPad,
          expandedPad: expandedPad,
          collapsedFontSize: collapsedFontSize,
          expandedFontSize: expandedFontSize,
        ),
        children: [
          LayoutId(
            id: _RailSlot.indicator,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: selected ? colors.indicator : Colors.transparent,
                shape: const MiuixSquircleBorder(
                  cornerRadius:
                      MiuixNavigationRailDefaults.expandedItemCornerRadius,
                ),
              ),
            ),
          ),
          LayoutId(id: _RailSlot.icon, child: icon),
          LayoutId(
            id: _RailSlot.label,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: labelStyle,
            ),
          ),
        ],
      ),
    );
  }
}

enum _RailSlot { indicator, icon, label }

class _RailItemLayoutDelegate extends MultiChildLayoutDelegate {
  _RailItemLayoutDelegate({
    required this.fraction,
    required this.collapsedWidth,
    required this.iconSize,
    required this.collapsedPad,
    required this.expandedPad,
    required this.collapsedFontSize,
    required this.expandedFontSize,
  });

  final double fraction;
  final double collapsedWidth;
  final double iconSize;
  final double collapsedPad;
  final double expandedPad;
  final double collapsedFontSize;
  final double expandedFontSize;

  // 文字高度粗略估算系数（近似行高，仅用于 getSize 定尺；performLayout 用实测值定位）。
  static const double _fontHeightFactor = 1.35;

  @override
  Size getSize(BoxConstraints constraints) {
    final width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : collapsedWidth;
    // 折叠态：上下 pad + 图标 + 指示器上下 pad(4*2) + 图标文字间距(4) + 标签行高。
    final collapsedHeight = collapsedPad +
        iconSize +
        MiuixNavigationRailDefaults.collapsedIndicatorVerticalPadding * 2 +
        MiuixNavigationRailDefaults.iconTextSpacing +
        collapsedFontSize * _fontHeightFactor +
        collapsedPad;
    // 展开态：上下 pad + max(图标, 标签行高)。
    final expandedHeight = expandedPad * 2 +
        math.max(iconSize, expandedFontSize * _fontHeightFactor);
    return constraints.constrain(
      Size(width, lerpDouble(collapsedHeight, expandedHeight, fraction)!),
    );
  }

  @override
  void performLayout(Size size) {
    const margin = MiuixNavigationRailDefaults.expandedItemHorizontalMargin;
    const inset =
        MiuixNavigationRailDefaults.expandedItemContentHorizontalPadding;
    const expandedSpacing =
        MiuixNavigationRailDefaults.expandedItemIconTextSpacing;
    final topPad = collapsedPad;
    const collapsedSpacing = MiuixNavigationRailDefaults.iconTextSpacing;
    const collapsedIndicatorPad =
        MiuixNavigationRailDefaults.collapsedIndicatorVerticalPadding;
    final expandedPad = this.expandedPad;

    final iconSize = layoutChild(_RailSlot.icon, const BoxConstraints());
    final expandedLabelMax = math.max(
      0.0,
      size.width - margin * 2 - inset * 2 - iconSize.width - expandedSpacing,
    );
    final labelMax = lerpDouble(size.width, expandedLabelMax, fraction)!;
    final labelSize = layoutChild(
      _RailSlot.label,
      BoxConstraints(maxWidth: labelMax, maxHeight: size.height),
    );

    final collapsedHeight =
        topPad +
        iconSize.height +
        collapsedIndicatorPad * 2 +
        collapsedSpacing +
        labelSize.height +
        topPad;
    final expandedHeight =
        expandedPad * 2 + math.max(iconSize.height, labelSize.height);
    final height = lerpDouble(
      collapsedHeight,
      expandedHeight,
      fraction,
    )!.roundToDouble();

    final collapsedIconX = (collapsedWidth - iconSize.width) / 2;
    final expandedIconX = margin + inset;
    final iconX = lerpDouble(
      collapsedIconX,
      expandedIconX,
      fraction,
    )!.roundToDouble();
    final iconY = lerpDouble(
      topPad + collapsedIndicatorPad,
      (height - iconSize.height) / 2,
      fraction,
    )!.roundToDouble();

    final indicatorPad = lerpDouble(
      collapsedIndicatorPad,
      expandedPad,
      fraction,
    )!.roundToDouble();
    final indicatorHeight = iconSize.height + indicatorPad * 2;
    final indicatorX = lerpDouble(
      collapsedIconX - inset,
      margin,
      fraction,
    )!.roundToDouble();
    final indicatorWidth = math.max(
      0.0,
      lerpDouble(
        iconSize.width + inset * 2,
        size.width - margin * 2,
        fraction,
      )!.roundToDouble(),
    );
    layoutChild(
      _RailSlot.indicator,
      BoxConstraints.tight(Size(indicatorWidth, indicatorHeight)),
    );
    positionChild(
      _RailSlot.indicator,
      Offset(indicatorX, iconY - indicatorPad),
    );
    positionChild(_RailSlot.icon, Offset(iconX, iconY));

    final collapsedLabelX =
        collapsedIconX + iconSize.width / 2 - labelSize.width / 2;
    final expandedLabelX = margin + inset + iconSize.width + expandedSpacing;
    final labelX = math.max(
      0.0,
      lerpDouble(collapsedLabelX, expandedLabelX, fraction)!.roundToDouble(),
    );
    final collapsedLabelY =
        topPad + iconSize.height + collapsedIndicatorPad * 2 + collapsedSpacing;
    final labelY = lerpDouble(
      collapsedLabelY,
      (height - labelSize.height) / 2,
      fraction,
    )!.roundToDouble();
    positionChild(_RailSlot.label, Offset(labelX, labelY));
  }

  @override
  bool shouldRelayout(covariant _RailItemLayoutDelegate oldDelegate) =>
      fraction != oldDelegate.fraction ||
      collapsedWidth != oldDelegate.collapsedWidth ||
      iconSize != oldDelegate.iconSize ||
      collapsedPad != oldDelegate.collapsedPad ||
      expandedPad != oldDelegate.expandedPad ||
      collapsedFontSize != oldDelegate.collapsedFontSize ||
      expandedFontSize != oldDelegate.expandedFontSize;
}

class _MiuixNavigationRailScope extends InheritedWidget {
  const _MiuixNavigationRailScope({
    required this.progress,
    required this.collapsedWidth,
    required this.colors,
    required this.iconSize,
    required this.itemVerticalPadding,
    required this.expandedItemVerticalPadding,
    required this.labelFontSize,
    required this.expandedLabelFontSize,
    required super.child,
  });

  final double? progress;
  final double collapsedWidth;
  final MiuixNavigationRailColors colors;
  final double iconSize;
  final double itemVerticalPadding;
  final double expandedItemVerticalPadding;
  final double labelFontSize;
  final double expandedLabelFontSize;

  static _MiuixNavigationRailScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MiuixNavigationRailScope>();

  @override
  bool updateShouldNotify(_MiuixNavigationRailScope oldWidget) =>
      progress != oldWidget.progress ||
      collapsedWidth != oldWidget.collapsedWidth ||
      colors != oldWidget.colors ||
      iconSize != oldWidget.iconSize ||
      itemVerticalPadding != oldWidget.itemVerticalPadding ||
      expandedItemVerticalPadding != oldWidget.expandedItemVerticalPadding ||
      labelFontSize != oldWidget.labelFontSize ||
      expandedLabelFontSize != oldWidget.expandedLabelFontSize;
}
