import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// 主题游乐场入口：动态取色 / 文本样式 / 配色角色 / 图标浏览。
class ThemingShowcase extends StatelessWidget {
  const ThemingShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    const margin = EdgeInsets.symmetric(horizontal: 16, vertical: 14);
    final entries = <(String, String, Widget)>[
      ('动态取色', 'MiuixThemeController · 种子色 → 整套配色', const _DynamicThemePage()),
      ('文本样式', 'MiuixTextStyles 全部预设', const _TextStylesPage()),
      ('字重跟随', 'fontWeightAdjustment · 跟随系统字体粗细度', const _FontWeightPage()),
      ('配色角色', 'MiuixColors 全部语义角色', const _ColorRolesPage()),
      ('图标浏览', 'MiuixIcons.extended · 5 字重', const _IconBrowserPage()),
    ];
    return ShowcasePage(
      title: '主题 Theming',
      subtitle: 'DynamicColor / TextStyles / Colors / Icons',
      sections: [
        ShowcaseSection('浏览', [
          GroupCard(children: [
            for (final (i, e) in entries.indexed) ...[
              if (i > 0) const IndentDivider(),
              MiuixArrowPreference(
                title: e.$1,
                summary: e.$2,
                insideMargin: margin,
                onClick: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => e.$3),
                ),
              ),
            ],
          ]),
        ]),
      ],
    );
  }
}

/// 动态取色演示：选种子色 + 明暗，实时把一组预览组件重新着色。
class _DynamicThemePage extends StatefulWidget {
  const _DynamicThemePage();

  @override
  State<_DynamicThemePage> createState() => _DynamicThemePageState();
}

class _DynamicThemePageState extends State<_DynamicThemePage> {
  Color _seed = const Color(0xFF3482FF);
  bool _dark = false;
  MiuixThemePaletteStyle _style = MiuixThemePaletteStyle.tonalSpot;
  bool _switchOn = true;
  double _slider = 0.6;

  static const _seeds = [
    Color(0xFF3482FF),
    Color(0xFFFF5B29),
    Color(0xFF36D167),
    Color(0xFFFFB21D),
    Color(0xFF8E5BFF),
    Color(0xFFEB4B96),
  ];

  static const _styleNames = ['TonalSpot', 'Vibrant', 'Expressive', 'Neutral'];
  static const _styles = [
    MiuixThemePaletteStyle.tonalSpot,
    MiuixThemePaletteStyle.vibrant,
    MiuixThemePaletteStyle.expressive,
    MiuixThemePaletteStyle.neutral,
  ];

  @override
  Widget build(BuildContext context) {
    // 用选中的种子/风格/明暗生成整套 miuix 配色。
    final colors = miuixColorsFromSeed(
      seed: _seed,
      paletteStyle: _style,
      dark: _dark,
    );
    return _SubPage(
      title: '动态取色',
      subtitle: 'MiuixThemeController',
      children: [
        MiuixSmallTitle('种子色'),
        _Pad(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in _seeds)
                GestureDetector(
                  onTap: () => setState(() => _seed = c),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _seed == c
                            ? MiuixTheme.of(context).colors.onBackground
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        MiuixSmallTitle('调色风格'),
        _Pad(
          child: MiuixTabRow(
            tabs: _styleNames,
            selectedTabIndex: _styles.indexOf(_style),
            onTabSelected: (i) => setState(() => _style = _styles[i]),
          ),
        ),
        MiuixSmallTitle('明暗'),
        _Pad(
          child: Row(
            children: [
              MiuixText('深色模式',
                  style: MiuixTheme.of(context).textStyles.body1),
              const Spacer(),
              MiuixSwitch(
                value: _dark,
                onChanged: (v) => setState(() => _dark = v),
              ),
            ],
          ),
        ),
        MiuixSmallTitle('实时预览'),
        _Pad(
          // 用生成的配色包裹预览区，展示动态取色对整个子树的影响。
          child: MiuixTheme(
            data: MiuixThemeData(
              colors: colors,
              textStyles: MiuixTheme.of(context).textStyles,
              brightness: _dark ? Brightness.dark : Brightness.light,
            ),
            child: _PreviewPanel(
              switchOn: _switchOn,
              slider: _slider,
              onSwitch: (v) => setState(() => _switchOn = v),
              onSlider: (v) => setState(() => _slider = v),
            ),
          ),
        ),
      ],
    );
  }
}

/// 动态取色预览面板：一张卡片里放常用组件，随主题重新着色。
class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.switchOn,
    required this.slider,
    required this.onSwitch,
    required this.onSlider,
  });

  final bool switchOn;
  final double slider;
  final ValueChanged<bool> onSwitch;
  final ValueChanged<double> onSlider;

  @override
  Widget build(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    final ts = MiuixTheme.of(context).textStyles;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MiuixText('预览标题', style: ts.title3, color: colors.onBackground),
          const SizedBox(height: 12),
          MiuixCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MiuixText('开关', style: ts.body1),
                    ),
                    MiuixSwitch(value: switchOn, onChanged: onSwitch),
                  ],
                ),
                const SizedBox(height: 12),
                MiuixSlider(value: slider, onValueChanged: onSlider),
                const SizedBox(height: 12),
                Row(
                  children: [
                    MiuixButton(
                      onPressed: () {},
                      child: MiuixText('主按钮', style: ts.button),
                    ),
                    const SizedBox(width: 12),
                    MiuixTextButton('文本按钮', onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 文本样式浏览：列出 MiuixTextStyles 全部预设及其字号。
class _TextStylesPage extends StatelessWidget {
  const _TextStylesPage();

  @override
  Widget build(BuildContext context) {
    final ts = MiuixTheme.of(context).textStyles;
    final samples = <(String, TextStyle)>[
      ('title1', ts.title1),
      ('title2', ts.title2),
      ('title3', ts.title3),
      ('title4', ts.title4),
      ('headline1', ts.headline1),
      ('headline2', ts.headline2),
      ('subtitle', ts.subtitle),
      ('main', ts.main),
      ('body1', ts.body1),
      ('body2', ts.body2),
      ('button', ts.button),
      ('footnote1', ts.footnote1),
      ('footnote2', ts.footnote2),
    ];
    return _SubPage(
      title: '文本样式',
      subtitle: 'MiuixTextStyles',
      children: [
        MiuixSmallTitle('预设'),
        _Pad(
          child: GroupCard(
            padding: EdgeInsets.zero,
            children: [
              for (final (i, s) in samples.indexed) ...[
                if (i > 0) const IndentDivider(indent: 16),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(child: MiuixText('示例文本 Aa', style: s.$2)),
                      MiuixText(
                        '${s.$1} · ${s.$2.fontSize?.toStringAsFixed(0)}',
                        style: ts.footnote2,
                        color: MiuixTheme.of(context)
                            .colors
                            .onSurfaceVariantSummary,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 字重跟随系统演示：切换 fontWeightAdjustment，预览正文/标题/组件一起变粗。
class _FontWeightPage extends StatefulWidget {
  const _FontWeightPage();

  @override
  State<_FontWeightPage> createState() => _FontWeightPageState();
}

class _FontWeightPageState extends State<_FontWeightPage> {
  static const _labels = ['0（默认）', '+100', '+200'];
  static const _values = [0, 100, 200];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final base = MiuixTheme.of(context);
    final adjustment = _values[_index];
    final boldText = MediaQuery.boldTextOf(context);
    return _SubPage(
      title: '字重跟随',
      subtitle: 'fontWeightAdjustment',
      children: [
        MiuixSmallTitle('偏移档位（100 为一档）'),
        _Pad(
          child: MiuixTabRow(
            tabs: _labels,
            selectedTabIndex: _index,
            onTabSelected: (i) => setState(() => _index = i),
          ),
        ),
        _Pad(
          child: MiuixText(
            '对应 Android Compose 平台自动施加的 Configuration.fontWeightAdjustment：'
            '把偏移整体加到每段文字最终字重上（正文 400→500、半粗 600→700、粗体 700→800）。'
            '默认 MiuixSystemTheme / MiuixThemeController 会读系统「粗体文字」自动跟随。\n'
            '当前系统 boldText：${boldText ? '开启' : '关闭'}。',
            style: base.textStyles.footnote1,
            color: base.colors.onSurfaceVariantSummary,
          ),
        ),
        MiuixSmallTitle('实时预览'),
        _Pad(
          // 用局部主题注入 fontWeightAdjustment，展示对整个子树文字的整体影响。
          child: MiuixTheme(
            data: base.copyWith(fontWeightAdjustment: adjustment),
            child: Builder(
              builder: (context) {
                final ts = MiuixTheme.of(context).textStyles;
                final colors = MiuixTheme.of(context).colors;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MiuixText('大标题 title1', style: ts.title1),
                      const SizedBox(height: 8),
                      MiuixText('副标题 subtitle（bold）', style: ts.subtitle),
                      const SizedBox(height: 8),
                      MiuixText('正文 body1，未指定字重时随系统变粗', style: ts.body1),
                      const SizedBox(height: 12),
                      MiuixCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            MiuixBasicComponent(
                              title: '列表项标题',
                              summary: '摘要文字',
                            ),
                            const IndentDivider(),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  MiuixButton(
                                    onPressed: () {},
                                    child: MiuixText('主按钮', style: ts.button),
                                  ),
                                  const SizedBox(width: 12),
                                  MiuixTextButton('文本按钮', onPressed: () {}),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// 配色角色浏览：网格展示 MiuixColors 常用语义角色。
class _ColorRolesPage extends StatelessWidget {
  const _ColorRolesPage();

  @override
  Widget build(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    final roles = <(String, Color)>[
      ('primary', c.primary),
      ('onPrimary', c.onPrimary),
      ('primaryContainer', c.primaryContainer),
      ('secondary', c.secondary),
      ('secondaryContainer', c.secondaryContainer),
      ('tertiaryContainer', c.tertiaryContainer),
      ('error', c.error),
      ('errorContainer', c.errorContainer),
      ('background', c.background),
      ('onBackground', c.onBackground),
      ('surface', c.surface),
      ('surfaceVariant', c.surfaceVariant),
      ('surfaceContainer', c.surfaceContainer),
      ('surfaceContainerHigh', c.surfaceContainerHigh),
      ('surfaceContainerHighest', c.surfaceContainerHighest),
      ('outline', c.outline),
      ('dividerLine', c.dividerLine),
      ('onSurface', c.onSurface),
    ];
    return _SubPage(
      title: '配色角色',
      subtitle: 'MiuixColors',
      children: [
        MiuixSmallTitle('语义角色'),
        _Pad(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final r in roles) _ColorChip(name: r.$1, color: r.$2),
            ],
          ),
        ),
      ],
    );
  }
}

/// 单个配色角色的色卡。
class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    return SizedBox(
      width: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.dividerLine),
            ),
          ),
          const SizedBox(height: 6),
          MiuixText(
            name,
            style: MiuixTheme.of(context).textStyles.footnote2,
            color: c.onSurfaceVariantSummary,
          ),
        ],
      ),
    );
  }
}

/// 图标浏览：按字重展示 MiuixIcons.extended 全部图标。
class _IconBrowserPage extends StatefulWidget {
  const _IconBrowserPage();

  @override
  State<_IconBrowserPage> createState() => _IconBrowserPageState();
}

class _IconBrowserPageState extends State<_IconBrowserPage> {
  MiuixIconWeight _weight = MiuixIconWeight.regular;

  static const _weightNames = ['Light', 'Normal', 'Regular', 'Medium', 'Demi'];
  static const _weights = [
    MiuixIconWeight.light,
    MiuixIconWeight.normal,
    MiuixIconWeight.regular,
    MiuixIconWeight.medium,
    MiuixIconWeight.demibold,
  ];

  @override
  Widget build(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    final names = MiuixIcons.extended.names;
    return _SubPage(
      title: '图标浏览',
      subtitle: '${names.length} 个扩展图标 · 5 字重',
      children: [
        MiuixSmallTitle('字重'),
        _Pad(
          child: MiuixTabRow(
            tabs: _weightNames,
            selectedTabIndex: _weights.indexOf(_weight),
            onTabSelected: (i) => setState(() => _weight = _weights[i]),
          ),
        ),
        MiuixSmallTitle('全部图标'),
        _Pad(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final name in names)
                SizedBox(
                  width: 56,
                  child: Column(
                    children: [
                      MiuixIcon(
                        vector: MiuixIcons.extended.byName(name, _weight)!,
                        size: 28,
                        tint: c.onBackground,
                      ),
                      const SizedBox(height: 4),
                      MiuixText(
                        name,
                        style: MiuixTheme.of(context).textStyles.footnote2,
                        color: c.onSurfaceVariantSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 子页骨架：带返回按钮的 Scaffold + 滚动列表。
class _SubPage extends StatelessWidget {
  const _SubPage({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return MiuixScaffold(
      topBar: MiuixTopAppBar(
        title: title,
        subtitle: subtitle,
        navigationIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: MiuixIconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ),
      ),
      content: (padding) => Material(
        type: MaterialType.transparency,
        child: ListView(
          padding: padding.copyWith(bottom: 32),
          children: children,
        ),
      ),
    );
  }
}

/// 统一水平内边距的容器。
class _Pad extends StatelessWidget {
  const _Pad({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: child,
    );
  }
}
