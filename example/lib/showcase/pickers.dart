import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// 选择器与取色类组件演示。
///
/// - [MiuixNumberPicker]：滚轮数字选择器（支持自定义标签、循环、范围）。
/// - [MiuixColorPicker]：多色彩空间取色器（HSV / OkHSV / OkLab / OkLch）。
/// - [MiuixColorPalette]：网格调色板（色相 × 明度）。
/// - [MiuixDatePicker]：HyperOS 风格日历日期选择器（月历网格 + 月份切换）。
class PickersShowcase extends StatefulWidget {
  const PickersShowcase({super.key});

  @override
  State<PickersShowcase> createState() => _PickersShowcaseState();
}

class _PickersShowcaseState extends State<PickersShowcase> {
  int _hour = 8;
  int _minute = 30;
  int _brightness = 5;

  Color _pickerColor = const Color(0xFF3482FF);
  MiuixColorSpace _colorSpace = MiuixColorSpace.hsv;

  Color _paletteColor = const Color(0xFFFF5B29);

  DateTime _selectedDate = DateTime(2026, 7, 26);

  // 日期滚轮对话框状态。
  bool _showDatePickerDialog = false;
  late int _dialogYear;
  late int _dialogMonth;
  late int _dialogDay;
  static const int _dateMinYear = 2020;
  static const int _dateMaxYear = 2030;

  static const _spaceNames = ['HSV', 'OkHSV', 'OkLab', 'OkLch'];
  static const _spaces = [
    MiuixColorSpace.hsv,
    MiuixColorSpace.okhsv,
    MiuixColorSpace.oklab,
    MiuixColorSpace.oklch,
  ];

  /// 分组卡片内块状内容的内边距。
  static const _itemMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  @override
  Widget build(BuildContext context) {
    final ts = MiuixTheme.of(context).textStyles;
    return ShowcasePage(
      title: '选择器 Pickers',
      subtitle: 'NumberPicker / ColorPicker / ColorPalette',
      overlay: _buildDatePickerDialog(ts),
      sections: [
        ShowcaseSection('MiuixNumberPicker（时间滚轮）', [
          GroupCard(children: [
            Padding(
              padding: _itemMargin,
              child: Column(
                children: [
                  MiuixText(
                    '当前时间：${_two(_hour)}:${_two(_minute)}',
                    style: ts.title4,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: MiuixNumberPicker(
                            value: _hour,
                            min: 0,
                            max: 23,
                            wrapAround: true,
                            label: _two,
                            onValueChanged: (v) => setState(() => _hour = v),
                          ),
                        ),
                        MiuixText(':', style: ts.title2),
                        Expanded(
                          child: MiuixNumberPicker(
                            value: _minute,
                            min: 0,
                            max: 59,
                            wrapAround: true,
                            label: _two,
                            onValueChanged: (v) => setState(() => _minute = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ]),
        ShowcaseSection('MiuixNumberPicker（自定义标签）', [
          GroupCard(children: [
            Padding(
              padding: _itemMargin,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MiuixText('屏幕亮度', style: ts.title4),
                  const SizedBox(height: 4),
                  MiuixText(
                    '当前 $_brightness 档 · visibleItemCount = 3',
                    style: ts.footnote2,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 132,
                    child: MiuixNumberPicker(
                      value: _brightness,
                      min: 0,
                      max: 10,
                      visibleItemCount: 3,
                      label: (v) => '$v 档',
                      onValueChanged: (v) => setState(() => _brightness = v),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ]),
        _colorPickerSection(ts),
        _colorPaletteSection(ts),
        _datePickerSection(ts),
      ],
    );
  }

  ShowcaseSection _colorPickerSection(MiuixTextStyles ts) {
    return ShowcaseSection('MiuixColorPicker', [
      GroupCard(children: [
        Padding(
          padding: _itemMargin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MiuixText('多色彩空间取色器', style: ts.title4),
              const SizedBox(height: 4),
              MiuixText(
                '切换色彩空间 · 实时预览',
                style: ts.footnote2,
              ),
              const SizedBox(height: 12),
              // 色彩空间切换。stretch 让 TabRow 占满宽度，
              // 否则 start 对齐会让 TabRow 拿不到正确可用宽度，
              // 导致 tabWidth 计算错误、Tab 无法点击。
              MiuixTabRow(
                tabs: _spaceNames,
                selectedTabIndex: _spaces.indexOf(_colorSpace),
                onTabSelected: (i) => setState(() => _colorSpace = _spaces[i]),
              ),
              const SizedBox(height: 16),
              MiuixColorPicker(
                color: _pickerColor,
                colorSpace: _colorSpace,
                onColorChanged: (c) => setState(() => _pickerColor = c),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _pickerColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: MiuixTheme.of(context).colors.dividerLine,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  MiuixText(_hex(_pickerColor), style: ts.body2),
                ],
              ),
            ],
          ),
        ),
      ]),
    ]);
  }

  ShowcaseSection _colorPaletteSection(MiuixTextStyles ts) {
    return ShowcaseSection('MiuixColorPalette', [
      GroupCard(children: [
        Padding(
          padding: _itemMargin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MiuixText('网格调色板', style: ts.title4),
              const SizedBox(height: 4),
              MiuixText(
                '色相 × 明度 · 点击选色',
                style: ts.footnote2,
              ),
              const SizedBox(height: 12),
              MiuixColorPalette(
                color: _paletteColor,
                onColorChanged: (c) => setState(() => _paletteColor = c),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _paletteColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: MiuixTheme.of(context).colors.dividerLine,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  MiuixText(_hex(_paletteColor), style: ts.body2),
                ],
              ),
            ],
          ),
        ),
      ]),
    ]);
  }

  ShowcaseSection _datePickerSection(MiuixTextStyles ts) {
    return ShowcaseSection('MiuixDatePicker', [
      GroupCard(children: [
        Padding(
          padding: _itemMargin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MiuixText('日历选择器', style: ts.title4),
              const SizedBox(height: 4),
              MiuixText(
                '月历网格 · 左右滑动切换月份 · 周一开始',
                style: ts.footnote2,
              ),
              const SizedBox(height: 16),
              MiuixDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2020, 1, 1),
                lastDate: DateTime(2030, 12, 31),
                weekStart: MiuixWeekStart.monday,
                onDateChanged: (d) => setState(() => _selectedDate = d),
                onHeaderTap: _openDatePickerDialog,
              ),
              const SizedBox(height: 12),
              _buildDateChip(ts),
            ],
          ),
        ),
      ]),
    ]);
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  static String _formatDate(DateTime d) {
    return '${d.year}年${d.month}月${d.day}日 周${_weekdayName(d.weekday)}';
  }

  static String _weekdayName(int weekday) {
    const names = ['', '一', '二', '三', '四', '五', '六', '日'];
    return names[weekday];
  }

  static String _hex(Color c) {
    int ch(double x) => (x * 255).round() & 0xff;
    final r = ch(c.r), g = ch(c.g), b = ch(c.b);
    return '#${((1 << 24) | (r << 16) | (g << 8) | b).toRadixString(16).substring(1).toUpperCase()}';
  }

  /// 当前选中日期的纯展示芯片。
  Widget _buildDateChip(MiuixTextStyles ts) {
    final colors = MiuixTheme.of(context).colors;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: MiuixText(
              '${_selectedDate.day}',
              style: ts.body2,
              color: colors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        MiuixText(_formatDate(_selectedDate), style: ts.body2),
      ],
    );
  }

  void _openDatePickerDialog() {
    setState(() {
      _dialogYear = _selectedDate.year;
      _dialogMonth = _selectedDate.month;
      _dialogDay = _selectedDate.day;
      _showDatePickerDialog = true;
    });
  }

  void _confirmDatePickerDialog() {
    setState(() {
      _selectedDate = DateTime(_dialogYear, _dialogMonth, _dialogDay);
      _showDatePickerDialog = false;
    });
  }

  /// 对话框内年/月变化时，按新月份天数 clamp 当前日。
  int _daysInDialogMonth() => DateTime(_dialogYear, _dialogMonth + 1, 0).day;

  void _onDialogYearChanged(int v) {
    setState(() {
      _dialogYear = v;
      final max = _daysInDialogMonth();
      if (_dialogDay > max) _dialogDay = max;
    });
  }

  void _onDialogMonthChanged(int v) {
    setState(() {
      _dialogMonth = v;
      final max = _daysInDialogMonth();
      if (_dialogDay > max) _dialogDay = max;
    });
  }

  Widget _buildDatePickerDialog(MiuixTextStyles ts) {
    if (!_showDatePickerDialog) return const SizedBox.shrink();
    final maxDay = _daysInDialogMonth();
    // MiuixNumberPicker 默认字号为 title1(32sp)，3 列均分对话框宽度时
    // "2026 年" 会被 ellipsis 截断成 "2026…"。改用 title3(20sp) 并去掉
    // label 空格，让年/月/日都能完整显示。
    final pickerStyle = ts.title3.copyWith(fontWeight: FontWeight.w600);
    return MiuixOverlayDialog(
      show: _showDatePickerDialog,
      title: '选择日期',
      onDismissRequest: () => setState(() => _showDatePickerDialog = false),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: MiuixNumberPicker(
                    value: _dialogYear,
                    min: _dateMinYear,
                    max: _dateMaxYear,
                    textStyle: pickerStyle,
                    label: (v) => '$v年',
                    onValueChanged: _onDialogYearChanged,
                  ),
                ),
                Expanded(
                  child: MiuixNumberPicker(
                    value: _dialogMonth,
                    min: 1,
                    max: 12,
                    wrapAround: true,
                    textStyle: pickerStyle,
                    label: (v) => '$v月',
                    onValueChanged: _onDialogMonthChanged,
                  ),
                ),
                Expanded(
                  child: MiuixNumberPicker(
                    value: _dialogDay,
                    min: 1,
                    max: maxDay,
                    wrapAround: true,
                    textStyle: pickerStyle,
                    label: (v) => '$v日',
                    onValueChanged: (v) => setState(() => _dialogDay = v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MiuixTextButton(
                '取消',
                onPressed: () =>
                    setState(() => _showDatePickerDialog = false),
              ),
              const SizedBox(width: 12),
              MiuixButton(
                onPressed: _confirmDatePickerDialog,
                child: MiuixText('确认', style: ts.button),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
