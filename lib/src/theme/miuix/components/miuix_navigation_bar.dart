// Miuix Flutter 移植版 - NavigationBar
// 源自 compose-miuix-ui/miuix 的 NavigationBar.kt。
// 用隐式 300ms 选择动画、方向感知的 badge 锚点与无涟漪手势复刻 Compose 行为。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../foundation/miuix_squircle.dart';
import '../theme/miuix_text_styles.dart';
import '../theme/miuix_theme.dart';
import 'miuix_divider.dart';

/// 导航项显示模式。对应 Kotlin `NavigationBarDisplayMode`。
enum MiuixNavigationBarDisplayMode {
  /// 始终显示图标和文本。
  iconAndText,

  /// 仅显示图标。
  iconOnly,

  /// 始终显示图标，仅为选中项显示文本。
  iconWithSelectedLabel,
}

/// 导航栏颜色。集中保存普通与悬浮导航栏使用的主题色。
@immutable
class MiuixNavigationBarColors {
  const MiuixNavigationBarColors({
    required this.background,
    required this.floatingBackground,
    required this.content,
    required this.divider,
  });

  /// 普通导航栏背景色。
  final Color background;

  /// 悬浮导航栏背景色。
  final Color floatingBackground;

  /// 图标和标签的基础颜色；状态透明度在此颜色之上计算。
  final Color content;

  /// 分隔线和悬浮描边颜色。
  final Color divider;
}

/// 普通导航栏默认值。对应 Kotlin `NavigationBarDefaults`。
class MiuixNavigationBarDefaults {
  MiuixNavigationBarDefaults._();

  static const double itemHeight = 64;
  static const double iconSize = 26;
  static const double labelFontSize = 12;
  static const double iconTopPadding = 8;
  static const double bottomPadding = 8;
  static const double selectedPressedAlpha = 0.5;
  static const double unselectedPressedAlpha = 0.6;
  static const double unselectedAlpha = 0.4;
  static const Duration selectionAnimationDuration = Duration(
    milliseconds: 300,
  );

  /// 从当前 Miuix 主题创建导航栏默认颜色。
  static MiuixNavigationBarColors defaultColors(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return MiuixNavigationBarColors(
      background: colors.surface,
      floatingBackground: colors.surfaceContainer,
      content: colors.onSurfaceContainer,
      divider: colors.dividerLine,
    );
  }
}

/// 悬浮导航栏默认值。对应 Kotlin `FloatingNavigationBarDefaults`。
class MiuixFloatingNavigationBarDefaults {
  MiuixFloatingNavigationBarDefaults._();

  static const double horizontalOutSidePadding = 36;
  static const double shadowElevation = 1;
  static const double horizontalPadding = 12;
  static const double itemSpacing = 12;
  static const double iconSize = 28;
  static const double iconPadding = 10;
  static const double selectedPressedAlpha = 0.5;
  static const double unselectedPressedAlpha = 0.6;
  static const double unselectedAlpha = 0.4;

  /// 与 Kotlin `FloatingToolbarDefaults.CornerRadius` 一致。
  static const double cornerRadius = 50;

  /// 从当前 Miuix 主题创建导航栏默认颜色。
  static MiuixNavigationBarColors defaultColors(BuildContext context) =>
      MiuixNavigationBarDefaults.defaultColors(context);
}

/// 导航项数据。对应 Kotlin `NavigationItem`。
@immutable
class MiuixNavigationItem {
  const MiuixNavigationItem({
    required this.label,
    required this.icon,
    this.badge,
  });

  /// 可访问性标签及默认可见标签文本。
  final String label;

  /// 图标槽；组件会通过 [IconTheme] 提供尺寸和状态色。
  final Widget icon;

  /// 可选 badge 槽，锚定在图标的顶部末端。
  final Widget? badge;
}

/// 普通底部导航栏。对应 Kotlin `NavigationBar`。
///
/// [children] 通常由 2 到 5 个 [MiuixNavigationBarItem] 组成；每项会被
/// `Expanded` 等分。底部系统区在 iOS 固定为 20，其余平台使用
/// `MediaQuery.viewPadding.bottom`。Compose 的 caption-bar inset 在移动端恒为
/// 0，Flutter 没有等价 API，因此不额外增加 caption-bar 高度。
class MiuixNavigationBar extends StatelessWidget {
  const MiuixNavigationBar({
    super.key,
    required this.children,
    this.color,
    this.colors,
    this.showDivider = true,
    this.defaultWindowInsetsPadding = true,
    this.mode = MiuixNavigationBarDisplayMode.iconAndText,
  }) : assert(children.length >= 2 && children.length <= 5);

  final List<Widget> children;
  final Color? color;
  final MiuixNavigationBarColors? colors;
  final bool showDivider;
  final bool defaultWindowInsetsPadding;
  final MiuixNavigationBarDisplayMode mode;

  @override
  Widget build(BuildContext context) {
    final resolvedColors =
        colors ?? MiuixNavigationBarDefaults.defaultColors(context);
    final bottomInset = defaultWindowInsetsPadding
        ? (defaultTargetPlatform == TargetPlatform.iOS
              ? 20.0
              : MediaQuery.viewPaddingOf(context).bottom)
        : 0.0;

    return ColoredBox(
      color: color ?? resolvedColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDivider)
            MiuixHorizontalDivider(color: resolvedColors.divider),
          _NavigationBarScope(
            mode: mode,
            colors: resolvedColors,
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (final child in children) Expanded(child: child),
                ],
              ),
            ),
          ),
          if (defaultWindowInsetsPadding)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: SizedBox(width: double.infinity, height: bottomInset),
            ),
        ],
      ),
    );
  }
}

/// 普通导航项。对应 Kotlin `NavigationBarItem`。
///
/// [icon] 和 [labelWidget] 是槽位；未提供 [labelWidget] 时使用 [label] 构造
/// 文本。整个导航项只暴露一个选项卡语义节点，装饰性图标和可见文本不会被
/// 屏幕阅读器重复朗读。
class MiuixNavigationBarItem extends StatefulWidget {
  const MiuixNavigationBarItem({
    super.key,
    required this.selected,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.labelWidget,
    this.enabled = true,
    this.badge,
  });

  final bool selected;
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final Widget? labelWidget;
  final bool enabled;
  final Widget? badge;

  @override
  State<MiuixNavigationBarItem> createState() => _MiuixNavigationBarItemState();
}

class _MiuixNavigationBarItemState extends State<MiuixNavigationBarItem> {
  bool _pressed = false;

  bool get _effectiveEnabled => widget.enabled && widget.onPressed != null;

  void _setPressed(bool value) {
    if (_pressed == value || !_effectiveEnabled) return;
    setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(MiuixNavigationBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_effectiveEnabled) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final scope = _NavigationBarScope.maybeOf(context);
    final mode = scope?.mode ?? MiuixNavigationBarDisplayMode.iconAndText;
    final resolvedColors =
        scope?.colors ?? MiuixNavigationBarDefaults.defaultColors(context);
    final tint = _itemTint(
      resolvedColors.content,
      selected: widget.selected,
      pressed: _pressed,
      selectedPressedAlpha: MiuixNavigationBarDefaults.selectedPressedAlpha,
      unselectedPressedAlpha: MiuixNavigationBarDefaults.unselectedPressedAlpha,
      unselectedAlpha: MiuixNavigationBarDefaults.unselectedAlpha,
    );

    Widget content;
    switch (mode) {
      case MiuixNavigationBarDisplayMode.iconAndText:
        content = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _NavigationIconSlot(
              icon: widget.icon,
              badge: widget.badge,
              iconSize: MiuixNavigationBarDefaults.iconSize,
              topPadding: MiuixNavigationBarDefaults.iconTopPadding,
              tint: tint,
            ),
            _NavigationLabel(
              label: widget.label,
              labelWidget: widget.labelWidget,
              tint: tint,
              selected: widget.selected,
            ),
          ],
        );
      case MiuixNavigationBarDisplayMode.iconOnly:
        content = Center(
          child: _NavigationIconSlot(
            icon: widget.icon,
            badge: widget.badge,
            iconSize: MiuixNavigationBarDefaults.iconSize,
            tint: tint,
          ),
        );
      case MiuixNavigationBarDisplayMode.iconWithSelectedLabel:
        final defaultPadding =
            (MiuixNavigationBarDefaults.itemHeight -
                MiuixNavigationBarDefaults.iconSize) /
            2;
        content = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _NavigationIconSlot(
              icon: widget.icon,
              badge: widget.badge,
              iconSize: MiuixNavigationBarDefaults.iconSize,
              topPadding: widget.selected
                  ? MiuixNavigationBarDefaults.iconTopPadding
                  : defaultPadding,
              animateTopPadding: true,
              tint: tint,
            ),
            AnimatedOpacity(
              opacity: widget.selected ? 1 : 0,
              duration: MiuixNavigationBarDefaults.selectionAnimationDuration,
              curve: Curves.fastOutSlowIn,
              child: _NavigationLabel(
                label: widget.label,
                labelWidget: widget.labelWidget,
                tint: tint,
                selected: widget.selected,
              ),
            ),
          ],
        );
    }

    return Semantics(
      container: true,
      label: widget.label,
      selected: widget.selected,
      enabled: _effectiveEnabled,
      button: true,
      onTap: _effectiveEnabled ? widget.onPressed : null,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _effectiveEnabled ? widget.onPressed : null,
          child: SizedBox(
            width: double.infinity,
            height: MiuixNavigationBarDefaults.itemHeight,
            child: content,
          ),
        ),
      ),
    );
  }
}

/// 悬浮式底部导航栏。对应 Kotlin `FloatingNavigationBar`。
///
/// 内容按自身宽度排列，不参与等分；项目之间固定间隔 12。阴影的几何固定为
/// 黑色 20%、blurRadius=10，[shadowElevation] 仅控制是否显示阴影。
class MiuixFloatingNavigationBar extends StatelessWidget {
  const MiuixFloatingNavigationBar({
    super.key,
    required this.children,
    this.color,
    this.colors,
    this.cornerRadius = MiuixFloatingNavigationBarDefaults.cornerRadius,
    this.horizontalAlignment = AlignmentDirectional.center,
    this.horizontalOutSidePadding =
        MiuixFloatingNavigationBarDefaults.horizontalOutSidePadding,
    this.shadowElevation = MiuixFloatingNavigationBarDefaults.shadowElevation,
    this.showDivider = false,
    this.defaultWindowInsetsPadding = true,
  }) : assert(children.length >= 2 && children.length <= 5);

  final List<Widget> children;
  final Color? color;
  final MiuixNavigationBarColors? colors;
  final double cornerRadius;
  final AlignmentGeometry horizontalAlignment;
  final double horizontalOutSidePadding;
  final double shadowElevation;
  final bool showDivider;

  /// 是否应用默认 caption-bar inset。移动端该 inset 为 0；保留此参数以对齐源 API。
  final bool defaultWindowInsetsPadding;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final resolvedAlignment = horizontalAlignment.resolve(direction);
    final resolvedColors =
        colors ?? MiuixFloatingNavigationBarDefaults.defaultColors(context);
    final navigationInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomPadding = defaultTargetPlatform == TargetPlatform.iOS
        ? 36.0
        : (navigationInset != 0 ? 26 + navigationInset : 36.0);
    final shape = MiuixSquircleBorder(
      cornerRadius: cornerRadius,
      enabled: cornerRadius > 0,
      side: showDivider
          ? BorderSide(color: resolvedColors.divider, width: 0.75)
          : BorderSide.none,
    );

    final spacedChildren = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index != 0) {
        spacedChildren.add(
          const SizedBox(width: MiuixFloatingNavigationBarDefaults.itemSpacing),
        );
      }
      spacedChildren.add(children[index]);
    }

    final outsideStart = resolvedAlignment.x < 0
        ? horizontalOutSidePadding
        : 0.0;
    final outsideEnd = resolvedAlignment.x > 0 ? horizontalOutSidePadding : 0.0;

    return Padding(
      padding: EdgeInsetsDirectional.only(start: outsideStart, end: outsideEnd),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Align(
          alignment: horizontalAlignment,
          child: _NavigationBarScope(
            mode: MiuixNavigationBarDisplayMode.iconOnly,
            colors: resolvedColors,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: color ?? resolvedColors.floatingBackground,
                  shape: shape,
                  shadows: shadowElevation > 0
                      ? const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 10),
                        ]
                      : null,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal:
                          MiuixFloatingNavigationBarDefaults.horizontalPadding,
                    ),
                    child: Semantics(
                      container: true,
                      explicitChildNodes: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: spacedChildren,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 悬浮导航项。对应 Kotlin `FloatingNavigationBarItem`。
class MiuixFloatingNavigationBarItem extends StatefulWidget {
  const MiuixFloatingNavigationBarItem({
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
  State<MiuixFloatingNavigationBarItem> createState() =>
      _MiuixFloatingNavigationBarItemState();
}

class _MiuixFloatingNavigationBarItemState
    extends State<MiuixFloatingNavigationBarItem> {
  bool _pressed = false;

  bool get _effectiveEnabled => widget.enabled && widget.onPressed != null;

  void _setPressed(bool value) {
    if (_pressed == value || !_effectiveEnabled) return;
    setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(MiuixFloatingNavigationBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_effectiveEnabled) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedColors =
        _NavigationBarScope.maybeOf(context)?.colors ??
        MiuixFloatingNavigationBarDefaults.defaultColors(context);
    final tint = _itemTint(
      resolvedColors.content,
      selected: widget.selected,
      pressed: _pressed,
      selectedPressedAlpha:
          MiuixFloatingNavigationBarDefaults.selectedPressedAlpha,
      unselectedPressedAlpha:
          MiuixFloatingNavigationBarDefaults.unselectedPressedAlpha,
      unselectedAlpha: MiuixFloatingNavigationBarDefaults.unselectedAlpha,
    );

    return Semantics(
      container: true,
      label: widget.label,
      selected: widget.selected,
      enabled: _effectiveEnabled,
      button: true,
      onTap: _effectiveEnabled ? widget.onPressed : null,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _effectiveEnabled ? widget.onPressed : null,
          child: Padding(
            padding: const EdgeInsets.all(
              MiuixFloatingNavigationBarDefaults.iconPadding,
            ),
            child: _FloatingIconBadge(
              icon: widget.icon,
              badge: widget.badge,
              tint: tint,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationLabel extends StatelessWidget {
  const _NavigationLabel({
    required this.label,
    required this.labelWidget,
    required this.tint,
    required this.selected,
  });

  final String label;
  final Widget? labelWidget;
  final Color tint;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: MiuixNavigationBarDefaults.bottomPadding,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: tint,
          fontSize: MiuixNavigationBarDefaults.labelFontSize,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ).withMiuixWeight(MiuixTheme.of(context).fontWeightAdjustment),
        textAlign: TextAlign.center,
        child: labelWidget ?? Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

class _NavigationIconSlot extends StatelessWidget {
  const _NavigationIconSlot({
    required this.icon,
    required this.badge,
    required this.iconSize,
    required this.tint,
    this.topPadding = 0,
    this.animateTopPadding = false,
  });

  final Widget icon;
  final Widget? badge;
  final double iconSize;
  final Color tint;
  final double topPadding;
  final bool animateTopPadding;

  @override
  Widget build(BuildContext context) {
    final iconChild = IconTheme.merge(
      data: IconThemeData(color: tint, size: iconSize),
      child: SizedBox.square(
        dimension: iconSize,
        child: Center(child: icon),
      ),
    );

    return AnimatedContainer(
      duration: animateTopPadding
          ? MiuixNavigationBarDefaults.selectionAnimationDuration
          : Duration.zero,
      curve: Curves.fastOutSlowIn,
      height: iconSize + topPadding,
      child: _BadgedAnchor(
        anchor: iconChild,
        badge: badge,
        topPadding: topPadding,
      ),
    );
  }
}

class _FloatingIconBadge extends StatelessWidget {
  const _FloatingIconBadge({
    required this.icon,
    required this.badge,
    required this.tint,
  });

  final Widget icon;
  final Widget? badge;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final iconChild = IconTheme.merge(
      data: IconThemeData(
        color: tint,
        size: MiuixFloatingNavigationBarDefaults.iconSize,
      ),
      child: SizedBox.square(
        dimension: MiuixFloatingNavigationBarDefaults.iconSize,
        child: Center(child: icon),
      ),
    );
    if (badge == null) return iconChild;
    return SizedBox.square(
      dimension: MiuixFloatingNavigationBarDefaults.iconSize,
      child: _BadgedAnchor(anchor: iconChild, badge: badge),
    );
  }
}

class _BadgedAnchor extends StatelessWidget {
  const _BadgedAnchor({
    required this.anchor,
    required this.badge,
    this.topPadding = 0,
  });

  final Widget anchor;
  final Widget? badge;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    if (badge == null) {
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: anchor,
      );
    }
    return CustomMultiChildLayout(
      delegate: _BadgeLayoutDelegate(
        topPadding: topPadding,
        textDirection: Directionality.of(context),
      ),
      children: [
        LayoutId(id: _BadgeChild.anchor, child: anchor),
        LayoutId(id: _BadgeChild.badge, child: badge!),
      ],
    );
  }
}

enum _BadgeChild { anchor, badge }

class _BadgeLayoutDelegate extends MultiChildLayoutDelegate {
  _BadgeLayoutDelegate({required this.topPadding, required this.textDirection});

  final double topPadding;
  final TextDirection textDirection;

  @override
  void performLayout(Size size) {
    final anchorSize = layoutChild(
      _BadgeChild.anchor,
      BoxConstraints.loose(size),
    );
    final badgeSize = layoutChild(
      _BadgeChild.badge,
      BoxConstraints.loose(size),
    );
    final anchorX = (size.width - anchorSize.width) / 2;
    positionChild(_BadgeChild.anchor, Offset(anchorX, topPadding));

    final hasContent = badgeSize.width > 6;
    final horizontalOffset = hasContent ? 12.0 : 6.0;
    final verticalOffset = hasContent ? 14.0 : 6.0;
    final logicalEndX = math.min(
      anchorX + anchorSize.width - horizontalOffset,
      size.width - badgeSize.width,
    );
    final x = textDirection == TextDirection.ltr
        ? logicalEndX
        : size.width - logicalEndX - badgeSize.width;
    final y = math.max(topPadding - badgeSize.height + verticalOffset, 0.0);
    positionChild(_BadgeChild.badge, Offset(math.max(0, x), y));
  }

  @override
  bool shouldRelayout(_BadgeLayoutDelegate oldDelegate) =>
      topPadding != oldDelegate.topPadding ||
      textDirection != oldDelegate.textDirection;
}

class _NavigationBarScope extends InheritedWidget {
  const _NavigationBarScope({
    required this.mode,
    required this.colors,
    required super.child,
  });

  final MiuixNavigationBarDisplayMode mode;
  final MiuixNavigationBarColors colors;

  static _NavigationBarScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_NavigationBarScope>();

  @override
  bool updateShouldNotify(_NavigationBarScope oldWidget) =>
      mode != oldWidget.mode || colors != oldWidget.colors;
}

Color _itemTint(
  Color base, {
  required bool selected,
  required bool pressed,
  required double selectedPressedAlpha,
  required double unselectedPressedAlpha,
  required double unselectedAlpha,
}) {
  if (pressed) {
    return base.withValues(
      alpha: selected ? selectedPressedAlpha : unselectedPressedAlpha,
    );
  }
  return selected ? base : base.withValues(alpha: unselectedAlpha);
}
