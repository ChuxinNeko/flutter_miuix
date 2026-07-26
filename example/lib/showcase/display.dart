import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// 显示类组件演示：Text / Card / Badge / Divider / SmallTitle / BasicComponent。
///
/// 所有文本统一引用 miuix 文本样式预设；所有图标使用 [MiuixIcon] +
/// [MiuixIcons.extended] 矢量图标（不再使用 Material 默认图标）；同组演示均
/// 用 [GroupCard] 收拢为圆角卡片，与 miuix 设置页布局保持一致。
class DisplayShowcase extends StatelessWidget {
  const DisplayShowcase({super.key});

  /// 分组卡片内列表项的统一内边距，与 [PreferencesShowcase] 保持一致。
  static const _itemMargin =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  @override
  Widget build(BuildContext context) {
    final ts = MiuixTheme.of(context).textStyles;
    return ShowcasePage(
      title: '显示 Display',
      subtitle: 'Text / Card / Badge / Divider / SmallTitle / BasicComponent',
      sections: [
        ShowcaseSection('MiuixText', [_textStylesCard(context, ts)]),
        ShowcaseSection('MiuixCard', [_cardBlock(context, ts)]),
        ShowcaseSection('MiuixBadge · MiuixBadgedBox', [
          _badgeCard(context, ts),
        ]),
        ShowcaseSection('MiuixDivider', [_dividerCard(context, ts)]),
        ShowcaseSection('MiuixSmallTitle', [_smallTitleBlock(context, ts)]),
        ShowcaseSection('MiuixBasicComponent', [
          _basicComponentCard(context, ts),
        ]),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixText：按行展示每种文本样式预设
  // ─────────────────────────────────────────────
  Widget _textStylesCard(BuildContext context, MiuixTextStyles ts) {
    final summaryColor = MiuixTheme.of(context).colors.onSurfaceVariantSummary;
    final samples = <(String, TextStyle)>[
      ('title1', ts.title1),
      ('title2', ts.title2),
      ('title3', ts.title3),
      ('title4', ts.title4),
      ('headline1', ts.headline1),
      ('subtitle', ts.subtitle),
      ('main', ts.main),
      ('body1', ts.body1),
      ('body2', ts.body2),
      ('footnote1', ts.footnote1),
      ('footnote2', ts.footnote2),
    ];
    return GroupCard(
      children: [
        for (final (i, s) in samples.indexed) ...[
          if (i > 0) const IndentDivider(indent: 16),
          Padding(
            padding: _itemMargin,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: MiuixText('示例文本 Aa', style: s.$2)),
                MiuixText(
                  '${s.$1} · ${s.$2.fontSize?.toStringAsFixed(0)}sp',
                  style: ts.footnote2,
                  color: summaryColor,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixCard：主色卡片 + Sink / Tilt 按压反馈
  // ─────────────────────────────────────────────
  Widget _cardBlock(BuildContext context, MiuixTextStyles ts) {
    final colors = MiuixTheme.of(context).colors;
    return ShowcaseBlock(
      children: [
        MiuixCard(
          colors: MiuixCardColors(
            color: colors.primaryVariant,
            contentColor: colors.onPrimaryVariant,
          ),
          insideMargin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MiuixText('主色卡片', style: ts.title3),
              const SizedBox(height: 4),
              MiuixText(
                '使用 primaryVariant / onPrimaryVariant 配色，常用于强调态。',
                style: ts.body2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MiuixCard(
                insideMargin: const EdgeInsets.all(16),
                onPressed: () {},
                feedbackType: MiuixPressFeedbackType.sink,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MiuixText('Sink', style: ts.title4),
                    const SizedBox(height: 4),
                    MiuixText('按压下沉反馈', style: ts.body2),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MiuixCard(
                insideMargin: const EdgeInsets.all(16),
                onPressed: () {},
                feedbackType: MiuixPressFeedbackType.tilt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MiuixText('Tilt', style: ts.title4),
                    const SizedBox(height: 4),
                    MiuixText('按压倾斜反馈', style: ts.body2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixBadge · MiuixBadgedBox：圆点 / 数字 / 99+
  // ─────────────────────────────────────────────
  Widget _badgeCard(BuildContext context, MiuixTextStyles ts) {
    final colors = MiuixTheme.of(context).colors;
    // 与原始 BadgeDemo 一致：messages / email / settings / favoritesFill。
    final icons = <(String, String?)>[
      ('messages', null),
      ('email', '8'),
      ('settings', '99+'),
      ('favoritesFill', '5'),
    ];
    return GroupCard(
      children: [
        Padding(
          padding: _itemMargin,
          child: Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              for (final (name, label) in icons)
                MiuixBadgedBox(
                  badge: label == null
                      ? const MiuixBadge()
                      : MiuixBadge(child: MiuixText(label)),
                  child: MiuixIcon(
                    vector: MiuixIcons.extended.byName(name)!,
                    size: 28,
                    tint: colors.onBackground,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixDivider：水平 + 垂直分割线
  // ─────────────────────────────────────────────
  Widget _dividerCard(BuildContext context, MiuixTextStyles ts) {
    return GroupCard(
      children: [
        Padding(
          padding: _itemMargin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MiuixText('上方内容', style: ts.body1),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: MiuixHorizontalDivider(),
              ),
              MiuixText('下方内容', style: ts.body1),
            ],
          ),
        ),
        const IndentDivider(indent: 16),
        Padding(
          padding: _itemMargin,
          child: Row(
            children: [
              MiuixText('左', style: ts.body1),
              const SizedBox(width: 16),
              const SizedBox(
                height: 24,
                child: MiuixVerticalDivider(),
              ),
              const SizedBox(width: 16),
              MiuixText('右', style: ts.body1),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixSmallTitle：作为分组小标题的用法
  // ─────────────────────────────────────────────
  Widget _smallTitleBlock(BuildContext context, MiuixTextStyles ts) {
    final colors = MiuixTheme.of(context).colors;
    // ShowcaseBlock 水平内边距置零，让 SmallTitle 自带的 28 水平内边距生效，
    // 与下方 GroupCard（外 12 + 内 16 = 28）左对齐。
    return ShowcaseBlock(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
      children: [
        MiuixSmallTitle('分组小标题（默认）'),
        GroupCard(
          children: [
            MiuixBasicComponent(
              title: 'SmallTitle',
              summary: '14sp 加粗 · onBackgroundVariant',
              insideMargin: _itemMargin,
              onClick: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        MiuixSmallTitle(
          '分组小标题（自定义颜色）',
          textColor: colors.primary,
        ),
        GroupCard(
          children: [
            MiuixBasicComponent(
              title: '自定义 textColor',
              summary: '可用 primary / error 等强调色',
              insideMargin: _itemMargin,
              onClick: () {},
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MiuixBasicComponent：基础行的几种用法
  // ─────────────────────────────────────────────
  Widget _basicComponentCard(BuildContext context, MiuixTextStyles ts) {
    final colors = MiuixTheme.of(context).colors;
    return GroupCard(
      children: [
        const MiuixBasicComponent(
          title: 'BasicComponent',
          summary: 'Without onClick',
          insideMargin: _itemMargin,
        ),
        const IndentDivider(),
        MiuixBasicComponent(
          title: 'Wi-Fi',
          summary: 'Connected to MIUI-WiFi',
          insideMargin: _itemMargin,
          onClick: () {},
        ),
        const IndentDivider(),
        MiuixBasicComponent(
          title: 'Nickname',
          summary: 'A brief introduction',
          insideMargin: _itemMargin,
          startAction: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MiuixIcon(
              vector: MiuixIcons.extended.byName('contacts')!,
              size: 24,
              tint: colors.onBackground,
            ),
          ),
          onClick: () {},
        ),
        const IndentDivider(),
        const MiuixBasicComponent(
          title: 'Mobile Network',
          summary: 'SIM card not inserted',
          insideMargin: _itemMargin,
          enabled: false,
        ),
      ],
    );
  }
}
