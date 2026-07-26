// Miuix Flutter 移植版 - Dropdown
// 源自 compose-miuix-ui/miuix 的 basic/Dropdown.kt。
// 仅含下拉选项行渲染 + 数据模型 + 颜色/默认值；弹层、触发器与级联子菜单在独立文件。
// 图标用 CustomPainter 复刻 ImageVector（evenOdd 填充，单色 tint 等价于按目标色填充路径）。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../theme/miuix_theme.dart';
import 'miuix_text.dart';

/// 下拉/微调器/下拉菜单中的一项。对应 Kotlin `DropdownItem`（旧名 `SpinnerEntry`）。
///
/// [children] 非空且非空列表时，此项成为子菜单触发器：级联弹层会渲染尾部箭头
/// 并在点击时展开子弹层（递归）；此时 [onClick] 被级联层消费而忽略。
@immutable
class MiuixDropdownItem {
  /// 常规构造。[text] 为显示文本，[enabled] 控制是否可点击，
  /// [selected] 标记选中态，[onClick] 为点击回调，[icon] 为前置图标，
  /// [summary] 为标题下方的摘要，[children] 为可选子菜单项。
  const MiuixDropdownItem({
    required this.text,
    this.enabled = true,
    this.selected = false,
    this.onClick,
    this.icon,
    this.summary,
    this.children,
  });

  /// 兼容旧 `SpinnerEntry` 的构造：以 [title]（可空，空则回退空串）作为文本。
  ///
  /// 对应 Kotlin `DropdownItem(icon, title, summary)` 次级构造函数。
  const MiuixDropdownItem.spinner({
    this.icon,
    String? title,
    this.summary,
  }) : text = title ?? '',
       enabled = true,
       selected = false,
       onClick = null,
       children = null;

  /// 项显示的文本。
  final String text;

  /// 是否可点击。
  final bool enabled;

  /// 是否处于选中态。
  final bool selected;

  /// 点击回调。当 [children] 非空且非空列表时被级联层消费而忽略。
  final VoidCallback? onClick;

  /// 前置图标（调用方提供的任意 Widget）。对应 Kotlin `@Composable (Modifier) -> Unit`。
  final Widget? icon;

  /// 标题下方的摘要文本。
  final String? summary;

  /// 可选子菜单项。非空且非空列表时此项成为子菜单触发器。
  final List<MiuixDropdownItem>? children;

  /// 复制此对象并覆盖部分字段。对应 Kotlin `data class copy(...)`。
  MiuixDropdownItem copyWith({
    String? text,
    bool? enabled,
    bool? selected,
    VoidCallback? onClick,
    Widget? icon,
    String? summary,
    List<MiuixDropdownItem>? children,
  }) {
    return MiuixDropdownItem(
      text: text ?? this.text,
      enabled: enabled ?? this.enabled,
      selected: selected ?? this.selected,
      onClick: onClick ?? this.onClick,
      icon: icon ?? this.icon,
      summary: summary ?? this.summary,
      children: children ?? this.children,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MiuixDropdownItem &&
        other.text == text &&
        other.enabled == enabled &&
        other.selected == selected &&
        other.onClick == onClick &&
        other.icon == icon &&
        other.summary == summary &&
        _listEquals(other.children, children);
  }

  @override
  int get hashCode => Object.hash(
    text,
    enabled,
    selected,
    onClick,
    icon,
    summary,
    children == null ? null : Object.hashAll(children!),
  );
}

bool _listEquals(List<MiuixDropdownItem>? a, List<MiuixDropdownItem>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// 一组下拉项。对应 Kotlin `DropdownEntry`。
///
/// 一个 [MiuixDropdownEntry] 表示下拉菜单中的一个视觉分组。分组标题为未来预留：
/// 原 MIUI 下拉样式当前无对应的分组标题呈现。
///
/// [enabled] 为 false 时该组所有项被禁用；为 true 时仍尊重各项自身的
/// [MiuixDropdownItem.enabled]。
@immutable
class MiuixDropdownEntry {
  const MiuixDropdownEntry({
    required this.items,
    this.enabled = true,
  });

  /// 本组内展示的项。
  final List<MiuixDropdownItem> items;

  /// 本组是否启用。
  final bool enabled;
}

/// 下拉选项行使用的颜色。对应 Kotlin `DropdownColors`（旧别名 `SpinnerColors`）。
@immutable
class MiuixDropdownColors {
  const MiuixDropdownColors({
    required this.contentColor,
    required this.summaryColor,
    required this.containerColor,
    required this.selectedContentColor,
    required this.selectedSummaryColor,
    required this.selectedContainerColor,
    required this.selectedIndicatorColor,
  });

  /// 未选中项的文本颜色。
  final Color contentColor;

  /// 未选中项的摘要文本颜色。
  final Color summaryColor;

  /// 未选中项的背景颜色。
  final Color containerColor;

  /// 选中项的文本颜色。
  final Color selectedContentColor;

  /// 选中项的摘要文本颜色。
  final Color selectedSummaryColor;

  /// 选中项的背景颜色。
  final Color selectedContainerColor;

  /// 选中指示图标（勾号）的颜色。
  final Color selectedIndicatorColor;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MiuixDropdownColors &&
        other.contentColor == contentColor &&
        other.summaryColor == summaryColor &&
        other.containerColor == containerColor &&
        other.selectedContentColor == selectedContentColor &&
        other.selectedSummaryColor == selectedSummaryColor &&
        other.selectedContainerColor == selectedContainerColor &&
        other.selectedIndicatorColor == selectedIndicatorColor;
  }

  @override
  int get hashCode => Object.hash(
    contentColor,
    summaryColor,
    containerColor,
    selectedContentColor,
    selectedSummaryColor,
    selectedContainerColor,
    selectedIndicatorColor,
  );
}

/// 下拉行的默认尺寸、间距与颜色。对应 Kotlin `DropdownDefaults`。
///
/// 所有 dp 值直接作为逻辑像素使用。
class MiuixDropdownDefaults {
  MiuixDropdownDefaults._();

  /// 对话框模式下的最小行高。
  static const double minHeight = 56;

  /// 对话框模式下的最小行宽。
  static const double minWidth = 200;

  /// 选中项尾部勾号的尺寸。
  static const double checkIconSize = 20;

  /// [MiuixDropdownArrowEndAction] 中上下箭头的尺寸（宽 x 高）。
  static const Size arrowSize = Size(10, 16);

  /// 拥有子菜单的行的尾部箭头尺寸（宽 x 高）。
  static const Size chevronSize = Size(10, 16);

  /// 前置图标单元格的最小尺寸。
  static const double iconMinSize = 26;

  /// 弹窗模式下内部图标/文本行的最大宽度。
  static const double maxItemTextWidth = 216;

  /// 弹窗模式下每行的水平内边距。
  static const double insideHorizontalPadding = 20;

  /// 对话框模式下每行的水平内边距。
  static const double dialogHorizontalPadding = 28;

  /// 弹窗模式下首/末行的上/下内边距。
  static const double firstLastVerticalPadding = 20;

  /// 弹窗模式下中间行、以及对话框模式下所有行的上/下内边距。
  static const double middleVerticalPadding = 12;

  /// 前置图标单元格与标题文本之间的间距。
  static const double iconEndPadding = 12;

  /// 标题/摘要块与尾部勾号之间的间距。
  static const double checkIconStartPadding = 12;

  /// 弹窗模式的默认颜色。对应 Kotlin `DropdownDefaults.dropdownColors()`。
  static MiuixDropdownColors dropdownColors(
    BuildContext context, {
    Color? contentColor,
    Color? summaryColor,
    Color? containerColor,
    Color? selectedContentColor,
    Color? selectedSummaryColor,
    Color? selectedContainerColor,
    Color? selectedIndicatorColor,
  }) {
    final c = MiuixTheme.of(context).colors;
    return MiuixDropdownColors(
      contentColor: contentColor ?? c.onSurfaceContainer,
      summaryColor: summaryColor ?? c.onSurfaceVariantSummary,
      containerColor: containerColor ?? c.surfaceContainer,
      selectedContentColor: selectedContentColor ?? c.primary,
      selectedSummaryColor: selectedSummaryColor ?? c.primary,
      selectedContainerColor: selectedContainerColor ?? c.surfaceContainer,
      selectedIndicatorColor: selectedIndicatorColor ?? c.primary,
    );
  }

  /// 对话框模式的默认颜色。对应 Kotlin `DropdownDefaults.dialogDropdownColors()`。
  static MiuixDropdownColors dialogDropdownColors(
    BuildContext context, {
    Color? contentColor,
    Color? summaryColor,
    Color? containerColor,
    Color? selectedContentColor,
    Color? selectedSummaryColor,
    Color? selectedContainerColor,
    Color? selectedIndicatorColor,
  }) {
    final c = MiuixTheme.of(context).colors;
    return MiuixDropdownColors(
      contentColor: contentColor ?? c.onSurfaceContainer,
      summaryColor: summaryColor ?? c.onSurfaceVariantSummary,
      containerColor: containerColor ?? Colors.transparent,
      selectedContentColor: selectedContentColor ?? c.onTertiaryContainer,
      selectedSummaryColor: selectedSummaryColor ?? c.onTertiaryContainer,
      selectedContainerColor: selectedContainerColor ?? c.tertiaryContainer,
      selectedIndicatorColor: selectedIndicatorColor ?? c.onTertiaryContainer,
    );
  }
}

/// 尾部的上下箭头动作图标。对应 Kotlin `RowScope.DropdownArrowEndAction`。
///
/// 以 [MiuixDropdownDefaults.arrowSize]（10 x 16）绘制，垂直居中，
/// 颜色由 [actionColor] 决定。通常放在触发行的尾部，指示可展开下拉。
class MiuixDropdownArrowEndAction extends StatelessWidget {
  const MiuixDropdownArrowEndAction({
    super.key,
    required this.actionColor,
  });

  /// 箭头的填充颜色。对应 Kotlin `ColorFilter.tint(actionColor)`。
  final Color actionColor;

  @override
  Widget build(BuildContext context) {
    // Compose 中通过 RowScope.align(CenterVertically) 垂直居中。
    return Center(
      widthFactor: 1,
      child: SizedBox(
        width: MiuixDropdownDefaults.arrowSize.width,
        height: MiuixDropdownDefaults.arrowSize.height,
        child: CustomPaint(
          painter: _MiuixVectorIconPainter(
            paths: _arrowUpDownPaths,
            viewport: _arrowViewport,
            color: actionColor,
          ),
        ),
      ),
    );
  }
}

/// 下拉选项行的渲染实现。对应 Kotlin `DropdownImpl`（含旧 `SpinnerItemImpl`）。
///
/// 本组件仅负责单行的呈现与点击；弹层、触发器与级联子菜单在独立文件中。
class MiuixDropdownImpl extends StatelessWidget {
  /// 以 [MiuixDropdownItem] 渲染一行。
  ///
  /// [optionSize] 为选项总数；[isSelected] 表示是否选中；[index] 为当前项下标；
  /// [dropdownColors] 为配色，默认取 [MiuixDropdownDefaults.dropdownColors]；
  /// [_enabled] 默认取 [item].enabled，禁用行忽略点击并使用禁用文本色；
  /// [dialogMode] 表示对话框模式；[hasSubmenu] 为 true 时该行作为子菜单触发器：
  /// 尾部显示箭头而非选中勾号，无障碍角色变为按钮；
  /// [_isFirst]/[_isLast] 控制弹窗模式下首/末行的更大内边距，默认按 [index] 推断，
  /// 多分组调用方应传入全局标志以便仅真正的首/末行获得额外内边距；
  /// [onSelectedIndexChange] 在选中时以 [index] 回调。
  const MiuixDropdownImpl({
    super.key,
    required this.item,
    required this.optionSize,
    required this.isSelected,
    required this.index,
    required this.onSelectedIndexChange,
    this.dropdownColors,
    this._enabled,
    this.dialogMode = false,
    this.hasSubmenu = false,
    this._isFirst,
    this._isLast,
  });

  /// 文本便捷构造，对应 Kotlin 第二个 `DropdownImpl(text, ...)` 重载。
  ///
  /// 内部以 [text] 与 [enabled] 构造一个 [MiuixDropdownItem]。
  MiuixDropdownImpl.text({
    Key? key,
    required String text,
    required int optionSize,
    required bool isSelected,
    required int index,
    required ValueChanged<int> onSelectedIndexChange,
    MiuixDropdownColors? dropdownColors,
    bool enabled = true,
    bool dialogMode = false,
  }) : this(
         key: key,
         item: MiuixDropdownItem(text: text, enabled: enabled),
         optionSize: optionSize,
         isSelected: isSelected,
         index: index,
         onSelectedIndexChange: onSelectedIndexChange,
         dropdownColors: dropdownColors,
         enabled: enabled,
         dialogMode: dialogMode,
       );

  /// 当前选项的数据。
  final MiuixDropdownItem item;

  /// 选项总数。
  final int optionSize;

  /// 是否选中。
  final bool isSelected;

  /// 当前项下标。
  final int index;

  /// 选中回调，以 [index] 触发。
  final ValueChanged<int> onSelectedIndexChange;

  /// 行配色。null 时取 [MiuixDropdownDefaults.dropdownColors]。
  final MiuixDropdownColors? dropdownColors;

  /// 对话框模式。
  final bool dialogMode;

  /// 是否作为子菜单触发器。
  final bool hasSubmenu;

  final bool? _enabled;
  final bool? _isFirst;
  final bool? _isLast;

  /// 是否可点击。默认取 [item].enabled。
  bool get enabled => _enabled ?? item.enabled;

  /// 是否为整个弹层的首行。默认 `index == 0`。
  bool get isFirst => _isFirst ?? (index == 0);

  /// 是否为整个弹层的末行。默认 `index == optionSize - 1`。
  bool get isLast => _isLast ?? (index == optionSize - 1);

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final colors =
        dropdownColors ?? MiuixDropdownDefaults.dropdownColors(context);
    final disabledColor = theme.colors.disabledOnSecondaryVariant;

    final additionalTopPadding = (!dialogMode && isFirst)
        ? MiuixDropdownDefaults.firstLastVerticalPadding
        : MiuixDropdownDefaults.middleVerticalPadding;
    final additionalBottomPadding = (!dialogMode && isLast)
        ? MiuixDropdownDefaults.firstLastVerticalPadding
        : MiuixDropdownDefaults.middleVerticalPadding;

    final backgroundColor = isSelected
        ? colors.selectedContainerColor
        : colors.containerColor;

    final checkColor = !isSelected
        ? const Color(0x00000000)
        : (!enabled ? disabledColor : colors.selectedIndicatorColor);

    final titleColor = !enabled
        ? disabledColor
        : (isSelected ? colors.selectedContentColor : colors.contentColor);

    final summaryColor = !enabled
        ? disabledColor
        : (isSelected ? colors.selectedSummaryColor : colors.summaryColor);

    // 子菜单箭头使用更柔和的 summaryColor，避免触发行与选中/叶子项抢视觉。
    final chevronColor = !enabled
        ? disabledColor
        : (isSelected ? colors.selectedContentColor : colors.summaryColor);

    // 内部图标+文本行：弹窗模式限宽 216，对话框模式不限。
    Widget innerRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (item.icon != null)
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: MiuixDropdownDefaults.iconMinSize,
              minHeight: MiuixDropdownDefaults.iconMinSize,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                end: MiuixDropdownDefaults.iconEndPadding,
              ),
              child: item.icon,
            ),
          ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MiuixText(
                item.text,
                fontSize: theme.textStyles.body1.fontSize,
                fontWeight: FontWeight.w500,
                color: titleColor,
              ),
              if (item.summary != null)
                MiuixText(
                  item.summary!,
                  fontSize: theme.textStyles.body2.fontSize,
                  color: summaryColor,
                ),
            ],
          ),
        ),
      ],
    );
    if (!dialogMode) {
      innerRow = ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: MiuixDropdownDefaults.maxItemTextWidth,
        ),
        child: innerRow,
      );
    }

    // 尾部图标：子菜单触发器显示箭头（10x16），否则显示勾号（20x20）。
    final Widget trailing = hasSubmenu
        ? Padding(
            padding: const EdgeInsetsDirectional.only(
              start: MiuixDropdownDefaults.checkIconStartPadding,
            ),
            child: SizedBox(
              width: MiuixDropdownDefaults.chevronSize.width,
              height: MiuixDropdownDefaults.chevronSize.height,
              child: CustomPaint(
                painter: _MiuixVectorIconPainter(
                  paths: _arrowRightPaths,
                  viewport: _arrowViewport,
                  color: chevronColor,
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsetsDirectional.only(
              start: MiuixDropdownDefaults.checkIconStartPadding,
            ),
            child: SizedBox(
              width: MiuixDropdownDefaults.checkIconSize,
              height: MiuixDropdownDefaults.checkIconSize,
              child: CustomPaint(
                painter: _MiuixVectorIconPainter(
                  paths: _checkPaths,
                  viewport: _checkViewport,
                  color: checkColor,
                ),
              ),
            ),
          );

    // 外层行：弹窗模式 wrap-content（MainAxisSize.min），对话框模式 fillMaxWidth。
    // 两种模式都用 SpaceBetween：弹窗模式下若父级 min 宽度约束存在（列表列）则
    // 箭头被推到尾部；无约束时排布退化为紧贴。
    final Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: dialogMode ? MainAxisSize.max : MainAxisSize.min,
      children: <Widget>[innerRow, trailing],
    );

    final padding = EdgeInsets.only(
      left: dialogMode
          ? MiuixDropdownDefaults.dialogHorizontalPadding
          : MiuixDropdownDefaults.insideHorizontalPadding,
      right: dialogMode
          ? MiuixDropdownDefaults.dialogHorizontalPadding
          : MiuixDropdownDefaults.insideHorizontalPadding,
      top: additionalTopPadding,
      bottom: additionalBottomPadding,
    );

    Widget sized = Padding(padding: padding, child: row);
    if (dialogMode) {
      sized = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: MiuixDropdownDefaults.minWidth,
          minHeight: MiuixDropdownDefaults.minHeight,
        ),
        child: sized,
      );
    }

    // 背景为纯矩形填充（对应 Compose drawBehind { drawRect }），无圆角、无按压涟漪。
    final Widget content = ColoredBox(color: backgroundColor, child: sized);

    return Semantics(
      selected: isSelected,
      button: hasSubmenu,
      inMutuallyExclusiveGroup: !hasSubmenu,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onSelectedIndexChange(index) : null,
        child: content,
      ),
    );
  }
}

/// 以视口坐标绘制单色矢量图标的 painter。
///
/// 复刻 Compose 的 `ImageVector` + `ColorFilter.tint`（SrcIn）：源矢量为纯黑填充，
/// SrcIn tint 等价于直接以目标色填充路径。填充类型为 [PathFillType.evenOdd]。
class _MiuixVectorIconPainter extends CustomPainter {
  const _MiuixVectorIconPainter({
    required this.paths,
    required this.viewport,
    required this.color,
  });

  /// 视口坐标下的路径（已设 evenOdd 填充）。
  final Path paths;

  /// 路径的视口尺寸。
  final Size viewport;

  /// 填充颜色。
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (color.a == 0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.save();
    canvas.scale(size.width / viewport.width, size.height / viewport.height);
    canvas.drawPath(paths, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MiuixVectorIconPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.paths != paths ||
      oldDelegate.viewport != viewport;
}

const Size _checkViewport = Size(56, 56);
const Size _arrowViewport = Size(10, 16);

/// Check 勾号路径。源自 `icon/basic/Check.kt`，视口 56x56，evenOdd。
final Path _checkPaths = Path()
  ..fillType = PathFillType.evenOdd
  ..moveTo(46.8171, 18.1514)
  ..cubicTo(48.0496, 16.6624, 47.8417, 14.4561, 46.3527, 13.2235)
  ..cubicTo(44.8636, 11.991, 42.6573, 12.1989, 41.4247, 13.6879)
  ..lineTo(22.9535, 36.0031)
  ..lineTo(13.4007, 26.4502)
  ..cubicTo(12.0338, 25.0833, 9.8177, 25.0833, 8.4509, 26.4502)
  ..cubicTo(7.0841, 27.817, 7.0841, 30.0331, 8.4509, 31.3999)
  ..lineTo(20.7077, 43.6567)
  ..cubicTo(21.7243, 44.6733, 23.2108, 44.9338, 24.4682, 44.4381)
  ..cubicTo(25.0159, 44.2302, 25.5189, 43.8818, 25.9192, 43.3982)
  ..lineTo(46.8171, 18.1514)
  ..close();

/// ArrowRight 箭头（'>'）路径。源自 `icon/basic/ArrowRight.kt`，视口 10x16，evenOdd。
final Path _arrowRightPaths = Path()
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

/// ArrowUpDown 上下箭头路径。源自 `icon/basic/ArrowUpDown.kt`，视口 10x16，evenOdd。
final Path _arrowUpDownPaths = Path()
  ..fillType = PathFillType.evenOdd
  ..moveTo(2.397, 4.7384)
  ..lineTo(4.5688, 2.5665)
  ..lineTo(5.0075, 2.1278)
  ..lineTo(5.4266, 2.5469)
  ..lineTo(7.5985, 4.7187)
  ..lineTo(8.531, 5.6512)
  ..cubicTo(8.8282, 5.9485, 9.3102, 5.9485, 9.6075, 5.6512)
  ..cubicTo(9.9047, 5.354, 9.9047, 4.872, 9.6075, 4.5747)
  ..lineTo(8.675, 3.6423)
  ..lineTo(6.5031, 1.4704)
  ..lineTo(5.5706, 0.5379)
  ..cubicTo(5.3595, 0.3267, 5.0551, 0.2656, 4.7899, 0.3544)
  ..cubicTo(4.6561, 0.3855, 4.5291, 0.4532, 4.4248, 0.5575)
  ..lineTo(3.4924, 1.49)
  ..lineTo(1.3205, 3.6619)
  ..lineTo(0.388, 4.5943)
  ..cubicTo(0.0907, 4.8916, 0.0907, 5.3736, 0.388, 5.6708)
  ..cubicTo(0.6853, 5.9681, 1.1672, 5.9681, 1.4645, 5.6708)
  ..lineTo(2.397, 4.7384)
  ..close()
  ..moveTo(2.397, 11.257)
  ..lineTo(4.5688, 13.4289)
  ..lineTo(5.0075, 13.8675)
  ..lineTo(5.4266, 13.4485)
  ..lineTo(7.5985, 11.2766)
  ..lineTo(8.531, 10.3441)
  ..cubicTo(8.8282, 10.0468, 9.3102, 10.0468, 9.6075, 10.3441)
  ..cubicTo(9.9047, 10.6414, 9.9047, 11.1233, 9.6075, 11.4206)
  ..lineTo(8.675, 12.3531)
  ..lineTo(6.5031, 14.525)
  ..lineTo(5.5706, 15.4574)
  ..cubicTo(5.3594, 15.6686, 5.0551, 15.7298, 4.7899, 15.6409)
  ..cubicTo(4.6561, 15.6098, 4.5291, 15.5421, 4.4248, 15.4378)
  ..lineTo(3.4924, 14.5053)
  ..lineTo(1.3205, 12.3335)
  ..lineTo(0.388, 11.401)
  ..cubicTo(0.0907, 11.1037, 0.0907, 10.6217, 0.388, 10.3245)
  ..cubicTo(0.6853, 10.0272, 1.1672, 10.0272, 1.4645, 10.3245)
  ..lineTo(2.397, 11.257)
  ..close();
