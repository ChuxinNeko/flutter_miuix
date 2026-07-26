import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// 输入类组件演示：TextField / Switch / Checkbox / RadioButton / Slider /
/// RangeSlider / VerticalSlider。
///
/// 同组演示均用 [GroupCard] 收拢为圆角卡片（TextField / VerticalSlider 因
/// 布局需要用 [ShowcaseBlock]）；列表项统一用 [MiuixBasicComponent] 承载
/// 标签 + 控件，与 miuix 设置页布局保持一致；所有图标使用 [MiuixIcon] +
/// [MiuixIcons.extended] 矢量图标。
class InputsShowcase extends StatefulWidget {
  const InputsShowcase({super.key});

  @override
  State<InputsShowcase> createState() => _InputsShowcaseState();
}

class _InputsShowcaseState extends State<InputsShowcase> {
  // Switch states
  bool _wifiOn = true;
  bool _bluetoothOn = false;
  // Checkbox states
  bool? _triState = false;
  bool _checked = true;
  // Radio state
  int _radioValue = 0;
  // Slider states
  double _sliderValue = 0.4;
  double _steppedSliderValue = 2;
  double _keyPointSliderValue = 0.5;
  // RangeSlider states
  double _rangeStart = 0.2;
  double _rangeEnd = 0.7;
  double _steppedRangeStart = 2;
  double _steppedRangeEnd = 8;
  // VerticalSlider states
  double _verticalValue = 0.6;
  double _verticalReverseValue = 0.4;
  // TextField controller
  final _textController = TextEditingController(text: 'miuix');

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 分组卡片内列表项的统一内边距。
  static const _itemMargin =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: '输入 Input',
      subtitle: 'TextField / Switch / Checkbox / RadioButton / Slider',
      sections: [
        ShowcaseSection('MiuixTextField', [_textFieldBlock()]),
        ShowcaseSection('MiuixSwitch', [_switchCard()]),
        ShowcaseSection('MiuixCheckbox', [_checkboxCard()]),
        ShowcaseSection('MiuixRadioButton', [_radioCard()]),
        ShowcaseSection('MiuixSlider', [_sliderCard()]),
        ShowcaseSection('MiuixRangeSlider', [_rangeSliderCard()]),
        ShowcaseSection('MiuixVerticalSlider', [_verticalSliderBlock()]),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixTextField：用户名 / 密码 / 搜索 / 禁用
  // ─────────────────────────────────────────────
  // TextField 是连续输入块（非列表项），用 Padding + Column 统一收拢在
  // GroupCard 内，项之间用 SizedBox 间隔而非 IndentDivider。
  Widget _textFieldBlock() {
    return GroupCard(
      children: [
        Padding(
          padding: _itemMargin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MiuixTextField(
                controller: _textController,
                label: '用户名',
                onChanged: (v) {},
              ),
              const SizedBox(height: 12),
              MiuixTextField(
                label: '密码',
                obscureText: true,
                leadingIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: MiuixIcon(
                    vector: MiuixIcons.extended.byName('lock')!,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              MiuixTextField(
                label: '搜索',
                leadingIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: MiuixIcon(
                    vector: MiuixIcons.extended.byName('search')!,
                    size: 22,
                  ),
                ),
                trailingIcon: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: MiuixIcon(
                    vector: MiuixIcons.extended.byName('clear')!,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const MiuixTextField(
                label: '禁用',
                enabled: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixSwitch：Wi-Fi / 蓝牙 / 飞行模式（disabled）
  // ─────────────────────────────────────────────
  Widget _switchCard() {
    return GroupCard(
      children: [
        MiuixBasicComponent(
          title: 'Wi-Fi',
          summary: _wifiOn ? '已开启' : '已关闭',
          insideMargin: _itemMargin,
          endActions: [
            MiuixSwitch(
              value: _wifiOn,
              onChanged: (v) => setState(() => _wifiOn = v),
            ),
          ],
          onClick: () => setState(() => _wifiOn = !_wifiOn),
        ),
        const IndentDivider(),
        MiuixBasicComponent(
          title: '蓝牙',
          summary: _bluetoothOn ? '已开启' : '已关闭',
          insideMargin: _itemMargin,
          endActions: [
            MiuixSwitch(
              value: _bluetoothOn,
              onChanged: (v) => setState(() => _bluetoothOn = v),
            ),
          ],
          onClick: () => setState(() => _bluetoothOn = !_bluetoothOn),
        ),
        const IndentDivider(),
        const MiuixBasicComponent(
          title: '飞行模式',
          summary: '禁用态',
          insideMargin: _itemMargin,
          enabled: false,
          endActions: [
            MiuixSwitch(value: false, onChanged: null, enabled: false),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixCheckbox：三态 / 普通 / 禁用
  // ─────────────────────────────────────────────
  Widget _checkboxCard() {
    return GroupCard(
      children: [
        MiuixBasicComponent(
          title: '三态复选框',
          summary: _triState == null
              ? 'mixed'
              : (_triState! ? 'checked' : 'unchecked'),
          insideMargin: _itemMargin,
          startAction: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MiuixCheckbox(
              value: _triState,
              onChanged: (v) => setState(() => _triState = v),
            ),
          ),
          onClick: () => setState(() {
            _triState =
                _triState == null ? false : (_triState == false ? true : null);
          }),
        ),
        const IndentDivider(),
        MiuixBasicComponent(
          title: '已同意条款',
          summary: _checked ? 'checked' : 'unchecked',
          insideMargin: _itemMargin,
          startAction: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MiuixCheckbox(
              value: _checked,
              onChanged: (v) => setState(() => _checked = v ?? false),
            ),
          ),
          onClick: () => setState(() => _checked = !_checked),
        ),
        const IndentDivider(),
        const MiuixBasicComponent(
          title: '禁用项（未选中）',
          summary: 'disabled',
          insideMargin: _itemMargin,
          enabled: false,
          startAction: Padding(
            padding: EdgeInsets.only(right: 12),
            child: MiuixCheckbox(value: false, onChanged: null, enabled: false),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixRadioButton：3 个互斥选项
  // ─────────────────────────────────────────────
  Widget _radioCard() {
    return GroupCard(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const IndentDivider(),
          MiuixBasicComponent(
            title: '选项 $i',
            summary: _radioValue == i ? '已选中' : '未选中',
              insideMargin: _itemMargin,
            startAction: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: MiuixRadioButton(
                selected: _radioValue == i,
                onChanged: (s) => setState(() => _radioValue = i),
              ),
            ),
            onClick: () => setState(() => _radioValue = i),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixSlider：基础 / 步进 / 关键点 / 禁用
  // ─────────────────────────────────────────────
  Widget _sliderCard() {
    return GroupCard(
      children: [
        MiuixBasicComponent(
          title: '基础',
          summary: '${(_sliderValue * 100).round()}%',
          insideMargin: _itemMargin,
          bottomAction: MiuixSlider(
            value: _sliderValue,
            onValueChanged: (v) => setState(() => _sliderValue = v),
          ),
        ),
        const IndentDivider(),
        MiuixBasicComponent(
          title: '步进 (5)',
          summary: _steppedSliderValue.toStringAsFixed(0),
          insideMargin: _itemMargin,
          bottomAction: MiuixSlider(
            value: _steppedSliderValue,
            min: 0,
            max: 10,
            steps: 4,
            onValueChanged: (v) => setState(() => _steppedSliderValue = v),
          ),
        ),
        const IndentDivider(),
        MiuixBasicComponent(
          title: '关键点',
          summary: '${(_keyPointSliderValue * 100).round()}%',
          insideMargin: _itemMargin,
          bottomAction: MiuixSlider(
            value: _keyPointSliderValue,
            showKeyPoints: true,
            keyPoints: const [0.0, 0.25, 0.5, 0.75, 1.0],
            onValueChanged: (v) => setState(() => _keyPointSliderValue = v),
          ),
        ),
        const IndentDivider(),
        const MiuixBasicComponent(
          title: '禁用',
          summary: '50%',
          insideMargin: _itemMargin,
          enabled: false,
          bottomAction: MiuixSlider(
            value: 0.5,
            enabled: false,
            onValueChanged: null,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixRangeSlider：基础 / 步进 / 禁用
  // ─────────────────────────────────────────────
  Widget _rangeSliderCard() {
    return GroupCard(
      children: [
        MiuixBasicComponent(
          title: '基础',
          summary:
              '${(_rangeStart * 100).round()}% - ${(_rangeEnd * 100).round()}%',
          insideMargin: _itemMargin,
          // onValueChanged 回调参数是 Dart record (double, double)。
          bottomAction: MiuixRangeSlider(
            startValue: _rangeStart,
            endValue: _rangeEnd,
            onValueChanged: (v) => setState(() {
              _rangeStart = v.$1;
              _rangeEnd = v.$2;
            }),
          ),
        ),
        const IndentDivider(),
        MiuixBasicComponent(
          title: '步进 (10)',
          summary:
              '${_steppedRangeStart.toStringAsFixed(0)} - ${_steppedRangeEnd.toStringAsFixed(0)}',
          insideMargin: _itemMargin,
          bottomAction: MiuixRangeSlider(
            startValue: _steppedRangeStart,
            endValue: _steppedRangeEnd,
            min: 0,
            max: 10,
            steps: 9,
            showKeyPoints: true,
            onValueChanged: (v) => setState(() {
              _steppedRangeStart = v.$1;
              _steppedRangeEnd = v.$2;
            }),
          ),
        ),
        const IndentDivider(),
        const MiuixBasicComponent(
          title: '禁用',
          summary: '30% - 70%',
          insideMargin: _itemMargin,
          enabled: false,
          bottomAction: MiuixRangeSlider(
            startValue: 0.3,
            endValue: 0.7,
            enabled: false,
            onValueChanged: null,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixVerticalSlider：基础 / 反向 / 禁用
  // ─────────────────────────────────────────────
  // 纵向滑块读取父级 maxHeight，需固定高度容器。
  Widget _verticalSliderBlock() {
    return ShowcaseBlock(
      alignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 160,
          child: Row(
            // stretch 让每个纵向滑块获得紧约束高度 160；否则默认 center
            // 给的是 loose 高度，无子 CustomPaint 会坍缩成 0 高 → 不可见、
            // 点击无反应。
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MiuixVerticalSlider(
                value: _verticalValue,
                onValueChanged: (v) => setState(() => _verticalValue = v),
              ),
              MiuixVerticalSlider(
                value: _verticalReverseValue,
                reverseDirection: true,
                showKeyPoints: true,
                steps: 4,
                onValueChanged: (v) =>
                    setState(() => _verticalReverseValue = v),
              ),
              const MiuixVerticalSlider(
                value: 0.5,
                enabled: false,
                onValueChanged: null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
