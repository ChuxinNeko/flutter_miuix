// Miuix Flutter 移植版 - DatePicker
// 自制 HyperOS 风格日历日期选择器（月历网格 + 月份切换 + 选中态）。
// 不依赖 Kotlin 源，遵循 Miuix 设计 token（squircle、primary、surfaceContainer）。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../foundation/miuix_pressable.dart';
import '../foundation/miuix_squircle.dart';
import '../theme/miuix_motion.dart';
import '../theme/miuix_theme.dart';
import 'miuix_card.dart';
import 'miuix_icon.dart';
import 'miuix_icon_button.dart';
import 'miuix_text.dart';

/// 周起始日。对应 `DateTime.monday` / `DateTime.sunday` 的语义封装。
enum MiuixWeekStart {
  /// 周日开始（美式）。
  sunday,

  /// 周一开始（中式 / ISO 8601）。
  monday,
}

/// DatePicker 颜色配置。对应 HyperOS 日历配色 token。
@immutable
class MiuixDatePickerColors {
  const MiuixDatePickerColors({
    required this.backgroundColor,
    required this.headerColor,
    required this.weekdayColor,
    required this.weekendWeekdayColor,
    required this.dayColor,
    required this.weekendDayColor,
    required this.outOfMonthDayColor,
    required this.selectedDayColor,
    required this.selectedDayTextColor,
    required this.todayBorderColor,
    required this.disabledDayColor,
    required this.navigationIconColor,
  });

  /// 整个日历卡片背景色。
  final Color backgroundColor;

  /// 顶部"2026年7月"标题色。
  final Color headerColor;

  /// 工作日周名颜色（一/二/三/四/五）。
  final Color weekdayColor;

  /// 周末周名颜色（六/日）。
  final Color weekendWeekdayColor;

  /// 当月日期数字默认色。
  final Color dayColor;

  /// 当月周末数字色。
  final Color weekendDayColor;

  /// 非当月日期数字色（前后月填充格）。
  final Color outOfMonthDayColor;

  /// 选中态背景色。
  final Color selectedDayColor;

  /// 选中态文字色。
  final Color selectedDayTextColor;

  /// "今天"格子的边框色。
  final Color todayBorderColor;

  /// 禁用日期数字色。
  final Color disabledDayColor;

  /// 月份切换箭头颜色。
  final Color navigationIconColor;

  /// 默认配色：与 HyperOS 浅/深色主题一致。
  static MiuixDatePickerColors defaultColors(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    final isDark = MiuixTheme.of(context).brightness == Brightness.dark;
    return MiuixDatePickerColors(
      backgroundColor: c.surfaceContainer,
      headerColor: c.onBackground,
      weekdayColor: c.onSurfaceVariantSummary,
      weekendWeekdayColor: isDark ? const Color(0xFFFF7A7A) : const Color(0xFFE0413F),
      dayColor: c.onBackground,
      weekendDayColor: isDark ? const Color(0xFFFF7A7A) : const Color(0xFFE0413F),
      outOfMonthDayColor: c.onSurfaceVariantSummary,
      selectedDayColor: c.primary,
      selectedDayTextColor: c.onPrimary,
      todayBorderColor: c.primary,
      disabledDayColor: c.onSurfaceVariantSummary,
      navigationIconColor: c.onBackground,
    );
  }
}

/// DatePicker 默认尺寸。对应 HyperOS 视觉规范。
class MiuixDatePickerDefaults {
  MiuixDatePickerDefaults._();

  /// 卡片圆角，与 [MiuixCard] 一致。
  static const double cornerRadius = 16;

  /// 日期单元格圆角（squircle）。
  static const double cellCornerRadius = 12;

  /// 日期单元格高度。
  static const double cellHeight = 44;

  /// 周名行高度。
  static const double weekdayRowHeight = 28;

  /// 顶部月份切换器高度。
  static const double headerHeight = 44;

  /// 月份切换按钮尺寸。
  static const double navButtonSize = 36;

  /// 卡片内边距。
  static const EdgeInsets insideMargin = EdgeInsets.all(16);

  /// 月份切换动画时长。
  static const Duration monthSwitchDuration = Duration(milliseconds: 280);

  /// 选中态颜色过渡时长。
  static const Duration selectionDuration = Duration(milliseconds: 200);
}

/// Miuix 风格的日历日期选择器（单选）。
///
/// 视觉对应 HyperOS 系统日历：
/// - 顶部居中显示年月，左右两侧为圆形切换按钮。
/// - 第二行为周名行（一/二/三/四/五/六/日）。
/// - 下方为 6 行 × 7 列日期网格，左右滑动切换月份。
/// - 选中态为 primary 圆形/squircle 背景；今天有 primary 描边；非当月日期半透明。
///
/// 不对应 Kotlin 源（Miuix 原库未提供日期选择器），为 Flutter 移植版自制组件。
class MiuixDatePicker extends StatefulWidget {
  const MiuixDatePicker({
    super.key,
    this.initialDate,
    this.currentDate,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
    this.onHeaderTap,
    this.selectableDayPredicate,
    this.weekStart = MiuixWeekStart.monday,
    this.colors,
    this.showOutOfMonthDays = true,
    this.cellHeight = MiuixDatePickerDefaults.cellHeight,
  });

  /// 初始选中日期。null 表示不预选。
  final DateTime? initialDate;

  /// "今天"参照日期，默认 [DateTime.now]。
  final DateTime? currentDate;

  /// 可选最早日期。默认 1970-01-01。
  final DateTime? firstDate;

  /// 可选最晚日期。默认 2100-12-31。
  final DateTime? lastDate;

  /// 选中日期变化回调。
  final ValueChanged<DateTime>? onDateChanged;

  /// 顶部"年月"标题点击回调。
  ///
  /// 用于接入快速选择交互（如弹出滚轮对话框让用户上下滑动选年/月/日）。
  /// 不传时标题呈静态文本。
  final VoidCallback? onHeaderTap;

  /// 自定义某日是否可选。返回 false 时该日呈禁用态。
  final bool Function(DateTime)? selectableDayPredicate;

  /// 周起始日，默认周一。
  final MiuixWeekStart weekStart;

  /// 颜色配置，默认取 [MiuixDatePickerColors.defaultColors]。
  final MiuixDatePickerColors? colors;

  /// 是否显示当月外的填充日期（前后月尾/头）。默认 true。
  final bool showOutOfMonthDays;

  /// 日期单元格高度，默认 44。
  final double cellHeight;

  @override
  State<MiuixDatePicker> createState() => _MiuixDatePickerState();
}

class _MiuixDatePickerState extends State<MiuixDatePicker> {
  late final DateTime _firstDate;
  late final DateTime _lastDate;
  late final DateTime _today;

  late DateTime _selectedDate;
  late DateTime _displayedMonth; // 该月第一天
  late final PageController _pageController;
  late final int _initialPage;
  late final int _pageCount;

  @override
  void initState() {
    super.initState();
    _firstDate = _dateOnly(widget.firstDate ?? DateTime(1970, 1, 1));
    _lastDate = _dateOnly(widget.lastDate ?? DateTime(2100, 12, 31));
    _today = _dateOnly(widget.currentDate ?? DateTime.now());

    final initial = widget.initialDate != null
        ? _clampDate(_dateOnly(widget.initialDate!), _firstDate, _lastDate)
        : null;

    _selectedDate = initial ?? _today;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);

    // Page 索引：以 _firstDate 所在月为 0。
    _initialPage = _monthDiff(_firstDate, _displayedMonth);
    _pageCount = _monthDiff(_firstDate, _lastDate) + 1;
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _clampDate(DateTime d, DateTime lo, DateTime hi) {
    if (d.isBefore(lo)) return lo;
    if (d.isAfter(hi)) return hi;
    return d;
  }

  /// 两个日期相差的月数（a 所在月 - b 所在月）。
  static int _monthDiff(DateTime b, DateTime a) =>
      (a.year - b.year) * 12 + (a.month - b.month);

  static DateTime _monthFromPage(DateTime base, int page) =>
      DateTime(base.year + page ~/ 12, base.month + page % 12);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSelectable(DateTime day) {
    if (day.isBefore(_firstDate) || day.isAfter(_lastDate)) return false;
    return widget.selectableDayPredicate?.call(day) ?? true;
  }

  void _onDayTapped(DateTime day) {
    if (!_isSelectable(day)) return;
    setState(() {
      final bool monthChanged = day.year != _selectedDate.year ||
          day.month != _selectedDate.month;
      // 若点了非当月填充格，切换到对应月。
      if (monthChanged) {
        final newPage = _monthDiff(_firstDate, DateTime(day.year, day.month));
        _pageController.animateToPage(
          newPage,
          duration: MiuixDatePickerDefaults.monthSwitchDuration,
          curve: MiuixMotion.standardDecelerate,
        );
      }
      _selectedDate = day;
      _displayedMonth = DateTime(day.year, day.month);
    });
    widget.onDateChanged?.call(day);
  }

  void _prevMonth() {
    final current = _pageController.page?.round() ?? _initialPage;
    if (current <= 0) return;
    _pageController.previousPage(
      duration: MiuixDatePickerDefaults.monthSwitchDuration,
      curve: MiuixMotion.standardDecelerate,
    );
  }

  void _nextMonth() {
    final current = _pageController.page?.round() ?? _initialPage;
    if (current >= _pageCount - 1) return;
    _pageController.nextPage(
      duration: MiuixDatePickerDefaults.monthSwitchDuration,
      curve: MiuixMotion.standardDecelerate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixDatePickerColors.defaultColors(context);
    final theme = MiuixTheme.of(context);

    return MiuixCard(
      cornerRadius: MiuixDatePickerDefaults.cornerRadius,
      colors: MiuixCardColors(
        color: colors.backgroundColor,
        contentColor: colors.dayColor,
      ),
      insideMargin: MiuixDatePickerDefaults.insideMargin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(colors, theme),
          SizedBox(height: widget.cellHeight * 0.25),
          _buildWeekdayRow(colors, theme),
          SizedBox(height: widget.cellHeight * 0.15),
          _buildPageView(colors, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(MiuixDatePickerColors colors, MiuixThemeData theme) {
    return SizedBox(
      height: MiuixDatePickerDefaults.headerHeight,
      child: Row(
        children: [
          _buildNavButton(
            icon: Icons.chevron_left,
            colors: colors,
            onTap: _prevMonth,
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (context, _) {
                // 用当前页码定位"显示中"的月份；动画过程中保留稳定值，避免标题闪烁。
                final page = (_pageController.hasClients
                    ? _pageController.page?.round()
                    : null) ?? _initialPage;
                final month = _monthFromPage(_firstDate, page);
                final label = _formatMonthLabel(month);
                final textWidget = MiuixText(
                  label,
                  style: theme.textStyles.title4,
                  color: colors.headerColor,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                );
                // 标题可点击：用于接入快速选择交互（滚轮对话框）。
                // 不传 onHeaderTap 时为静态文本，无按压反馈。
                if (widget.onHeaderTap == null) return textWidget;
                return MiuixPressable(
                  onPressed: widget.onHeaderTap,
                  feedbackType: MiuixPressFeedbackType.sink,
                  sinkAmount: 0.94,
                  borderRadius:
                      BorderRadius.circular(MiuixDatePickerDefaults.cellCornerRadius),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        textWidget,
                        const SizedBox(width: 4),
                        MiuixIcon(
                          icon: Icons.arrow_drop_down,
                          size: 20,
                          tint: colors.headerColor,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildNavButton(
            icon: Icons.chevron_right,
            colors: colors,
            onTap: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required MiuixDatePickerColors colors,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: MiuixDatePickerDefaults.navButtonSize,
      height: MiuixDatePickerDefaults.navButtonSize,
      child: MiuixIconButton(
        onPressed: onTap,
        child: Icon(icon, size: 22, color: colors.navigationIconColor),
      ),
    );
  }

  Widget _buildWeekdayRow(MiuixDatePickerColors colors, MiuixThemeData theme) {
    // 周名序列：周一开头 → 一二三四五六日；周日开头 → 日一二三四五六。
    final weekdays = widget.weekStart == MiuixWeekStart.monday
        ? const ['一', '二', '三', '四', '五', '六', '日']
        : const ['日', '一', '二', '三', '四', '五', '六'];
    final isWeekend = widget.weekStart == MiuixWeekStart.monday
        ? const [false, false, false, false, false, true, true]
        : const [true, false, false, false, false, false, true];

    return SizedBox(
      height: MiuixDatePickerDefaults.weekdayRowHeight,
      child: Row(
        children: [
          for (int i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: MiuixText(
                  weekdays[i],
                  style: theme.textStyles.footnote1,
                  color: isWeekend[i]
                      ? colors.weekendWeekdayColor
                      : colors.weekdayColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageView(MiuixDatePickerColors colors, MiuixThemeData theme) {
    return SizedBox(
      height: widget.cellHeight * 6, // 固定 6 行高度，避免月份切换时高度跳变。
      child: PageView.builder(
        controller: _pageController,
        itemCount: _pageCount,
        itemBuilder: (context, page) {
          final month = _monthFromPage(_firstDate, page);
          return _buildMonthGrid(month, colors, theme);
        },
        onPageChanged: (page) {
          final month = _monthFromPage(_firstDate, page);
          setState(() {
            _displayedMonth = month;
          });
        },
      ),
    );
  }

  Widget _buildMonthGrid(
    DateTime month,
    MiuixDatePickerColors colors,
    MiuixThemeData theme,
  ) {
    final cells = _buildCellsForMonth(month, colors, theme);
    return Column(
      children: [
        for (int r = 0; r < 6; r++)
          SizedBox(
            height: widget.cellHeight,
            child: Row(
              children: [
                for (int c = 0; c < 7; c++)
                  Expanded(child: cells[r * 7 + c]),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建一个月的 42 个单元格（6 行 × 7 列）。
  List<Widget> _buildCellsForMonth(
    DateTime month,
    MiuixDatePickerColors colors,
    MiuixThemeData theme,
  ) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // 该月 1 号是周几（DateTime.weekday：周一=1 … 周日=7）。
    final firstWeekday = firstOfMonth.weekday;
    final int leadingBlanks = widget.weekStart == MiuixWeekStart.monday
        ? firstWeekday - 1
        : firstWeekday % 7;

    final daysInMonth = _daysInMonth(month.year, month.month);
    // 前一个月的最后几天（用于填充首行空位）。
    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final daysInPrevMonth = _daysInMonth(prevMonth.year, prevMonth.month);

    final List<Widget> cells = <Widget>[];

    // 前置（上月尾部）。
    for (int i = 0; i < leadingBlanks; i++) {
      final day = daysInPrevMonth - leadingBlanks + 1 + i;
      final date = DateTime(prevMonth.year, prevMonth.month, day);
      cells.add(
        widget.showOutOfMonthDays
            ? _buildDayCell(
                date: date,
                inCurrentMonth: false,
                colors: colors,
                theme: theme,
              )
            : const SizedBox(),
      );
    }

    // 当月。
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      cells.add(
        _buildDayCell(
          date: date,
          inCurrentMonth: true,
          colors: colors,
          theme: theme,
        ),
      );
    }

    // 后置（下月头部）补满 42 格。
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    int trailingDay = 1;
    while (cells.length < 42) {
      final date = DateTime(nextMonth.year, nextMonth.month, trailingDay++);
      cells.add(
        widget.showOutOfMonthDays
            ? _buildDayCell(
                date: date,
                inCurrentMonth: false,
                colors: colors,
                theme: theme,
              )
            : const SizedBox(),
      );
    }

    return cells;
  }

  Widget _buildDayCell({
    required DateTime date,
    required bool inCurrentMonth,
    required MiuixDatePickerColors colors,
    required MiuixThemeData theme,
  }) {
    final bool isSelected = _isSameDay(date, _selectedDate);
    final bool isToday = _isSameDay(date, _today);
    final bool isWeekend = date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;
    final bool selectable = _isSelectable(date);

    // 文字颜色优先级：选中 > 禁用 > 非当月 > 周末 > 普通。
    Color textColor;
    if (isSelected) {
      textColor = colors.selectedDayTextColor;
    } else if (!selectable) {
      textColor = colors.disabledDayColor;
    } else if (!inCurrentMonth) {
      textColor = colors.outOfMonthDayColor;
    } else if (isWeekend) {
      textColor = colors.weekendDayColor;
    } else {
      textColor = colors.dayColor;
    }

    // 非当月 + 不显示填充格的情况已被外层替换为空 SizedBox；这里仅处理透明度。
    final double opacity = inCurrentMonth ? 1.0 : 0.4;

    final Widget textWidget = MiuixText(
      '${date.day}',
      style: theme.textStyles.body1,
      color: textColor,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
    );

    // 选中态：primary 圆形/squircle 背景。
    Widget content = textWidget;
    if (isSelected) {
      content = AnimatedContainer(
        duration: MiuixDatePickerDefaults.selectionDuration,
        curve: MiuixMotion.standardDecelerate,
        decoration: ShapeDecoration(
          color: colors.selectedDayColor,
          shape: MiuixSquircleBorder(
            cornerRadius: MiuixDatePickerDefaults.cellCornerRadius,
          ),
        ),
        padding: EdgeInsets.zero,
        child: Center(child: textWidget),
      );
    } else if (isToday) {
      // 今天：primary 描边，无填充。
      content = Container(
        decoration: ShapeDecoration(
          shape: MiuixSquircleBorder(
            cornerRadius: MiuixDatePickerDefaults.cellCornerRadius,
            side: BorderSide(color: colors.todayBorderColor, width: 1.5),
          ),
        ),
        child: Center(child: textWidget),
      );
    } else {
      content = Center(child: textWidget);
    }

    // 整格可点击：用 MiuixPressable 提供 sink 反馈（与 HyperOS 按压一致）。
    // 不可选日期不响应点击，但仍渲染（呈禁用态色）。
    final bool canTap = selectable && inCurrentMonth;
    final cell = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Opacity(opacity: opacity, child: content),
    );

    if (!canTap) {
      return cell;
    }

    return _PressableDayCell(
      onTap: () => _onDayTapped(date),
      child: cell,
    );
  }

  /// 计算指定年月的天数。
  int _daysInMonth(int year, int month) {
    // 下个月 0 号 = 这个月最后一天。
    return DateTime(year, month + 1, 0).day;
  }

  /// "2026年7月" / "July 2026" 格式化。
  /// 使用 locale 感知的 Intl 太重，这里用本地化字符串映射，中文为默认。
  String _formatMonthLabel(DateTime month) {
    const monthNames = [
      '1月', '2月', '3月', '4月', '5月', '6月',
      '7月', '8月', '9月', '10月', '11月', '12月',
    ];
    return '${month.year}年 ${monthNames[month.month - 1]}';
  }
}

/// 单个日期单元格的可点击包装。
///
/// 用 [MiuixPressable] 提供 sink 反馈，遮罩裁剪为 squircle 圆角，
/// 与 HyperOS 列表项按压一致。独立为 Stateful 以承载 spring 动画。
class _PressableDayCell extends StatelessWidget {
  const _PressableDayCell({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MiuixPressable(
      onPressed: onTap,
      feedbackType: MiuixPressFeedbackType.sink,
      sinkAmount: 0.88,
      borderRadius: BorderRadius.circular(MiuixDatePickerDefaults.cellCornerRadius),
      child: child,
    );
  }
}


