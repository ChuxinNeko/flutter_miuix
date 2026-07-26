import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// Item 卡片 / Preference 列表项演示。
///
/// miuix 的"item 卡片"体系基于 [MiuixBasicComponent]，并提供 7 个 preference 变体：
/// Arrow / Switch / Checkbox / RadioButton / Slider / Dropdown / Spinner。
///
/// **分组卡片模式**：用 [MiuixCard] 包裹 [Column]，把同组 preference 装进一个圆角卡片，
/// 项之间用 [MiuixHorizontalDivider] 分隔。这是 miuix demo 推荐的设置页布局。
class PreferencesShowcase extends StatefulWidget {
  const PreferencesShowcase({super.key});

  @override
  State<PreferencesShowcase> createState() => _PreferencesShowcaseState();
}

class _PreferencesShowcaseState extends State<PreferencesShowcase> {
  bool _wifi = true;
  bool _bluetooth = false;
  bool _notify = false;
  bool _location = true;
  int _themeIndex = 0;
  double _brightness = 0.7;
  double _fontSize = 0.5;
  double _priceStart = 200;
  double _priceEnd = 700;

  static const _themeOptions = ['跟随系统', '浅色', '深色'];

  /// 分组卡片内 preference 项的紧凑内边距。
  static const _itemMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: '列表项 Item',
      subtitle: 'BasicComponent / Arrow / Switch / Checkbox / RadioButton / Slider',
      sections: [
        ShowcaseSection('基础项（MiuixBasicComponent）', [
          GroupCard(children: [
            MiuixBasicComponent(
              title: '通用列表项',
              summary: '可点击、可带起始图标与末尾操作',
              startAction: MiuixIcon(vector: MiuixIcons.extended.byName('info')!),
              insideMargin: _itemMargin,
              onClick: () {},
            ),
            const IndentDivider(),
            MiuixBasicComponent(
              title: '带末尾开关',
              summary: '整行可点击切换',
              insideMargin: _itemMargin,
              endActions: [
                MiuixSwitch(
                  value: _location,
                  onChanged: (v) => setState(() => _location = v),
                ),
              ],
              onClick: () => setState(() => _location = !_location),
            ),
            const IndentDivider(),
            MiuixBasicComponent(
              title: '带末尾徽标',
              summary: 'endActions 槽位可放任意 widget',
              insideMargin: _itemMargin,
              endActions: const [
                MiuixBadge(child: Text('新')),
              ],
              onClick: () {},
            ),
            const IndentDivider(),
            const MiuixBasicComponent(
              title: '禁用项',
              summary: 'enabled = false',
              insideMargin: _itemMargin,
              enabled: false,
            ),
          ]),
        ]),
        ShowcaseSection('箭头跳转项（MiuixArrowPreference）', [
          GroupCard(children: [
            MiuixArrowPreference(
              title: '账号与安全',
              summary: '密码、双重验证',
              startAction: MiuixIcon(vector: MiuixIcons.extended.byName('lock')!),
              insideMargin: _itemMargin,
              onClick: () {},
            ),
            const IndentDivider(),
            MiuixArrowPreference(
              title: '通用设置',
              summary: '通知、存储、电池',
              startAction: MiuixIcon(vector: MiuixIcons.extended.byName('settings')!),
              insideMargin: _itemMargin,
              onClick: () {},
            ),
            const IndentDivider(),
            MiuixArrowPreference(
              title: '关于本机',
              summary: '版本号、协议、反馈',
              insideMargin: _itemMargin,
              onClick: () {},
            ),
          ]),
        ]),
        ShowcaseSection('开关项（MiuixSwitchPreference）', [
          GroupCard(children: [
            MiuixSwitchPreference(
              title: 'Wi-Fi',
              summary: _wifi ? '已连接' : '已关闭',
              value: _wifi,
              onChanged: (v) => setState(() => _wifi = v),
              insideMargin: _itemMargin,
            ),
            const IndentDivider(),
            MiuixSwitchPreference(
              title: '蓝牙',
              summary: _bluetooth ? '已开启' : '已关闭',
              value: _bluetooth,
              onChanged: (v) => setState(() => _bluetooth = v),
              insideMargin: _itemMargin,
            ),
            const IndentDivider(),
            const MiuixSwitchPreference(
              title: '不可用开关',
              summary: 'enabled = false',
              value: false,
              onChanged: _noOp,
              enabled: false,
              insideMargin: _itemMargin,
            ),
          ]),
        ]),
        ShowcaseSection('复选项（MiuixCheckboxPreference）', [
          GroupCard(children: [
            MiuixCheckboxPreference(
              title: '消息推送',
              summary: _notify ? '已启用' : '已禁用',
              value: _notify,
              onChanged: (v) => setState(() => _notify = v),
              insideMargin: _itemMargin,
            ),
            const IndentDivider(),
            const MiuixCheckboxPreference(
              title: '禁用复选',
              value: true,
              onChanged: _noOp,
              enabled: false,
              insideMargin: _itemMargin,
            ),
          ]),
        ]),
        ShowcaseSection('单选项（MiuixRadioButtonPreference）', [
          GroupCard(
            children: [
              for (var i = 0; i < _themeOptions.length; i++) ...[
                if (i > 0) const IndentDivider(),
                MiuixRadioButtonPreference(
                  title: '主题：${_themeOptions[i]}',
                  selected: _themeIndex == i,
                  onClick: () => setState(() => _themeIndex = i),
                  insideMargin: _itemMargin,
                ),
              ],
            ],
          ),
        ]),
        ShowcaseSection('滑块项（MiuixSliderPreference）', [
          GroupCard(children: [
            MiuixSliderPreference(
              title: '亮度',
              summary: '当前 ${(_brightness * 100).round()}%',
              value: _brightness,
              min: 0.2,
              max: 1.0,
              steps: 7,
              insideMargin: _itemMargin,
              onValueChange: (v) => setState(() => _brightness = v),
            ),
            const IndentDivider(),
            MiuixSliderPreference(
              title: '字号',
              summary: '当前 ${(_fontSize * 100).round()}%',
              value: _fontSize,
              min: 0.0,
              max: 1.0,
              steps: 4,
              insideMargin: _itemMargin,
              onValueChange: (v) => setState(() => _fontSize = v),
            ),
          ]),
        ]),
        ShowcaseSection('范围滑块项（MiuixRangeSliderPreference）', [
          GroupCard(children: [
            // 回调名是 onValueChange，参数为 record (double, double)。
            MiuixRangeSliderPreference(
              title: '价格区间',
              summary: '¥${_priceStart.round()} - ¥${_priceEnd.round()}',
              startValue: _priceStart,
              endValue: _priceEnd,
              min: 0,
              max: 1000,
              steps: 9,
              showKeyPoints: true,
              insideMargin: _itemMargin,
              onValueChange: (v) => setState(() {
                _priceStart = v.$1;
                _priceEnd = v.$2;
              }),
            ),
            const IndentDivider(),
            const MiuixRangeSliderPreference(
              title: '不可用范围',
              summary: 'enabled = false',
              startValue: 0.3,
              endValue: 0.7,
              enabled: false,
              onValueChange: _noOpRange,
              insideMargin: _itemMargin,
            ),
          ]),
        ]),
        ShowcaseSection('混合分组（推荐用法）', [
          GroupCard(children: [
            MiuixSwitchPreference(
              title: '推送通知',
              summary: _notify ? '已启用' : '已禁用',
              value: _notify,
              onChanged: (v) => setState(() => _notify = v),
              insideMargin: _itemMargin,
            ),
            const IndentDivider(),
            MiuixSliderPreference(
              title: '亮度',
              summary: '当前 ${(_brightness * 100).round()}%',
              value: _brightness,
              min: 0.2,
              max: 1.0,
              steps: 7,
              insideMargin: _itemMargin,
              onValueChange: (v) => setState(() => _brightness = v),
            ),
            const IndentDivider(),
            MiuixArrowPreference(
              title: '更多设置',
              summary: '深色模式、字体、动画',
              insideMargin: _itemMargin,
              onClick: () {},
            ),
          ]),
        ]),
      ],
    );
  }

  static void _noOp(bool _) {}

  static void _noOpRange((double, double) _) {}
}
