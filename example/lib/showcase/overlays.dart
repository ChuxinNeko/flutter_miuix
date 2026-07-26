import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// 浮层类组件演示：底部弹窗 + 下拉菜单 + 悬浮工具栏。
///
/// - [MiuixOverlayBottomSheet]：声明式底部弹窗（`show` 控制显隐，从底部滑入，
///   带拖拽手柄，可下拉关闭）。
/// - [MiuixOverlayDropdownMenu]：列表项风格的下拉菜单（单分组/多分组）。
/// - [MiuixOverlayIconDropdownMenu]：图标按钮风格的下拉菜单。
/// - [MiuixFloatingToolbar]：胶囊形悬浮工具栏容器（横/纵布局由内容自定）。
class OverlaysShowcase extends StatefulWidget {
  const OverlaysShowcase({super.key});

  @override
  State<OverlaysShowcase> createState() => _OverlaysShowcaseState();
}

class _OverlaysShowcaseState extends State<OverlaysShowcase> {
  bool _showSheet = false;
  bool _showActionSheet = false;
  int _toolbarSelected = 0;
  int _counter = 0;

  // Dropdown 演示状态
  int _selectedFontSize = 1;
  String _lastAction = '尚未选择';

  static const EdgeInsets _cardPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);
  static const List<String> _fontSizes = <String>['小', '标准', '大'];

  @override
  Widget build(BuildContext context) {
    final ts = MiuixTheme.of(context).textStyles;
    final colors = MiuixTheme.of(context).colors;
    return ShowcasePage(
      title: '浮层 Overlays',
      subtitle: 'BottomSheet / DropdownMenu / FloatingToolbar',
      overlay: Stack(
        children: [
          // 基础底部弹窗：滚动内容。
          MiuixOverlayBottomSheet(
            show: _showSheet,
            title: '底部弹窗',
            onDismissRequest: () => setState(() => _showSheet = false),
            content: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MiuixText(
                    '底部弹窗从屏幕底部滑入，顶部带拖拽手柄，可下拉关闭。'
                    '内容区域可放置任意 Flutter 组件。',
                    style: ts.body1,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: MiuixTextButton(
                      '知道了',
                      onPressed: () => setState(() => _showSheet = false),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 操作列表弹窗：分组卡片风格的操作项。
          MiuixOverlayBottomSheet(
            show: _showActionSheet,
            title: '选择操作',
            onDismissRequest: () => setState(() => _showActionSheet = false),
            content: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              child: GroupCard(
                padding: EdgeInsets.zero,
                children: [
                  for (final (i, action) in const [
                    ('分享', 'share'),
                    ('编辑', 'edit'),
                    ('删除', 'delete'),
                  ].indexed) ...[
                    if (i > 0) const IndentDivider(),
                    MiuixBasicComponent(
                      title: action.$1,
                      startAction: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: MiuixIcon(
                          vector: MiuixIcons.extended.byName(action.$2)!,
                          size: 24,
                        ),
                      ),
                      insideMargin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      onClick: () => setState(() => _showActionSheet = false),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      sections: [
        ShowcaseSection('MiuixOverlayBottomSheet', [
          GroupCard(children: [
            Padding(
              padding: _cardPadding,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  MiuixButton(
                    onPressed: () => setState(() => _showSheet = true),
                    child: MiuixText('基础弹窗', style: ts.button),
                  ),
                  MiuixButton(
                    onPressed: () => setState(() => _showActionSheet = true),
                    child: MiuixText('操作列表', style: ts.button),
                  ),
                ],
              ),
            ),
          ]),
        ]),
        ShowcaseSection('MiuixOverlayDropdownMenu', [
          GroupCard(children: [
            // 单分组下拉菜单：选中即关闭，显示选中状态。
            MiuixOverlayDropdownMenu(
              entry: MiuixDropdownEntry(items: [
                for (var i = 0; i < _fontSizes.length; i++)
                  MiuixDropdownItem(
                    text: _fontSizes[i],
                    selected: _selectedFontSize == i,
                    onClick: () => setState(() => _selectedFontSize = i),
                  ),
              ]),
              title: '字体大小',
              summary: _fontSizes[_selectedFontSize],
            ),
            const IndentDivider(),
            // 多分组下拉菜单：操作菜单，分组分隔。
            MiuixOverlayDropdownMenu.entries(
              entries: [
                MiuixDropdownEntry(items: [
                  MiuixDropdownItem(
                    text: '分享',
                    icon: MiuixIcon(
                      vector: MiuixIcons.extended.byName('share')!,
                      size: 24,
                      tint: colors.onBackground,
                    ),
                    onClick: () => setState(() => _lastAction = '已分享'),
                  ),
                  MiuixDropdownItem(
                    text: '编辑',
                    icon: MiuixIcon(
                      vector: MiuixIcons.extended.byName('edit')!,
                      size: 24,
                      tint: colors.onBackground,
                    ),
                    onClick: () => setState(() => _lastAction = '已编辑'),
                  ),
                ]),
                MiuixDropdownEntry(items: [
                  MiuixDropdownItem(
                    text: '删除',
                    icon: MiuixIcon(
                      vector: MiuixIcons.extended.byName('delete')!,
                      size: 24,
                      tint: colors.error,
                    ),
                    onClick: () => setState(() => _lastAction = '已删除'),
                  ),
                ]),
              ],
              title: '操作菜单',
              summary: _lastAction,
              collapseOnSelection: true,
            ),
          ]),
          const SizedBox(height: 12),
          // 图标下拉菜单：用 IconButton 触发。
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                MiuixOverlayIconDropdownMenu(
                  entry: MiuixDropdownEntry(items: [
                    MiuixDropdownItem(
                      text: '复制',
                      icon: MiuixIcon(
                        vector: MiuixIcons.extended.byName('copy')!,
                        size: 24,
                        tint: colors.onBackground,
                      ),
                      onClick: () => setState(() => _lastAction = '已复制'),
                    ),
                    MiuixDropdownItem(
                      text: '粘贴',
                      icon: MiuixIcon(
                        vector: MiuixIcons.extended.byName('paste')!,
                        size: 24,
                        tint: colors.onBackground,
                      ),
                      onClick: () => setState(() => _lastAction = '已粘贴'),
                    ),
                    MiuixDropdownItem(
                      text: '剪切',
                      icon: MiuixIcon(
                        vector: MiuixIcons.extended.byName('cut')!,
                        size: 24,
                        tint: colors.onBackground,
                      ),
                      onClick: () => setState(() => _lastAction = '已剪切'),
                    ),
                  ]),
                  child: MiuixIcon(
                    vector: MiuixIcons.extended.byName('more')!,
                    size: 24,
                    tint: colors.onBackground,
                  ),
                ),
                const SizedBox(width: 12),
                MiuixText('图标下拉菜单', style: ts.body2),
              ],
            ),
          ),
        ]),
        ShowcaseSection('MiuixFloatingToolbar（横向）', [
          ShowcaseBlock(
            alignment: CrossAxisAlignment.center,
            children: [
              MiuixFloatingToolbar(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (i, name) in const [
                      'undo',
                      'redo',
                      'edit',
                      'share',
                    ].indexed) ...[
                      if (i > 0) const SizedBox(width: 4),
                      MiuixIconButton(
                        onPressed: () => setState(() => _toolbarSelected = i),
                        backgroundColor: _toolbarSelected == i
                            ? colors.tertiaryContainer
                            : null,
                        child: MiuixIcon(
                          vector: MiuixIcons.extended.byName(name)!,
                          size: 24,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ]),
        ShowcaseSection('MiuixFloatingToolbar（纵向 + 描边）', [
          ShowcaseBlock(
            alignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MiuixFloatingToolbar(
                    cornerRadius: 24,
                    showDivider: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MiuixIconButton(
                          onPressed: () => setState(() => _counter++),
                          child: MiuixIcon(
                            vector: MiuixIcons.extended.byName('add')!,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        MiuixIconButton(
                          onPressed: () => setState(() => _counter--),
                          child: MiuixIcon(
                            vector: MiuixIcons.extended.byName('remove')!,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // 显示计数，证明工具栏内按钮点击有响应。
                  MiuixText('$_counter', style: ts.title1),
                ],
              ),
            ],
          ),
        ]),
      ],
    );
  }
}
