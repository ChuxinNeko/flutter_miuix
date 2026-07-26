import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// 基础能力演示：squircle 平滑圆角 + 滚动到边界触觉反馈。
///
/// - [MiuixSquircleBorder]：miuix 全库使用的 G2 连续曲率圆角（相比普通圆角更"饱满"）。
/// - [MiuixScrollEndHaptic]：可滚动内容被惯性甩到边界时触发一次触觉反馈。
class FoundationShowcase extends StatefulWidget {
  const FoundationShowcase({super.key});

  @override
  State<FoundationShowcase> createState() => _FoundationShowcaseState();
}

class _FoundationShowcaseState extends State<FoundationShowcase> {
  double _radius = 24;
  MiuixHapticFeedbackType _haptic = MiuixHapticFeedbackType.textHandleMove;

  static const _hapticNames = ['选择', '轻', '中', '重'];
  static const _haptics = [
    MiuixHapticFeedbackType.textHandleMove,
    MiuixHapticFeedbackType.lightImpact,
    MiuixHapticFeedbackType.mediumImpact,
    MiuixHapticFeedbackType.heavyImpact,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    final ts = MiuixTheme.of(context).textStyles;
    return ShowcasePage(
      title: '基础 Foundation',
      subtitle: 'Squircle / ScrollEndHaptic',
      sections: [
        ShowcaseSection('MiuixSquircleBorder', [
          ShowcaseBlock(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShapeSample(
                  label: 'Squircle',
                  color: colors.primary,
                  border: MiuixSquircleBorder(cornerRadius: _radius),
                ),
                _ShapeSample(
                  label: '普通圆角',
                  color: colors.secondary,
                  border: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_radius),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                MiuixText('圆角 ${_radius.round()}', style: ts.body2),
                Expanded(
                  child: MiuixSlider(
                    value: _radius,
                    min: 0,
                    max: 48,
                    onValueChanged: (v) => setState(() => _radius = v),
                  ),
                ),
              ],
            ),
          ]),
        ]),
        ShowcaseSection('MiuixScrollEndHaptic', [
          ShowcaseBlock(children: [
            MiuixText('触觉类型', style: ts.body2),
            const SizedBox(height: 8),
            MiuixTabRow(
              tabs: _hapticNames,
              selectedTabIndex: _haptics.indexOf(_haptic),
              onTabSelected: (i) => setState(() => _haptic = _haptics[i]),
            ),
            const SizedBox(height: 12),
            MiuixText(
              '把下面的列表快速甩到顶部或底部，触边时会有一次震动反馈。',
              style: ts.body2,
              color: colors.onSurfaceVariantSummary,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: MiuixCard(
                insideMargin: EdgeInsets.zero,
                child: ClipRect(
                  // key 让切换触觉类型时重建，应用新的反馈类型。
                  child: MiuixScrollEndHaptic(
                    key: ValueKey(_haptic),
                    hapticFeedbackType: _haptic,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 20,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: MiuixText('可滚动项 ${i + 1}', style: ts.body1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ]),
      ],
    );
  }
}

/// 单个形状示例：用给定 [border] 裁剪的色块。
class _ShapeSample extends StatelessWidget {
  const _ShapeSample({
    required this.label,
    required this.color,
    required this.border,
  });

  final String label;
  final Color color;
  final ShapeBorder border;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: ShapeDecoration(color: color, shape: border),
        ),
        const SizedBox(height: 8),
        MiuixText(label, style: MiuixTheme.of(context).textStyles.body2),
      ],
    );
  }
}
