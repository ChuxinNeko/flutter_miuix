import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// 菜单与选择类组件演示。
///
/// 涵盖 miuix 的下拉/微调偏好行与下拉/级联菜单：
/// - [MiuixOverlayDropdownPreference] / [MiuixWindowDropdownPreference]
/// - [MiuixOverlaySpinnerPreference] / [MiuixWindowSpinnerPreference]
/// - [MiuixOverlayIconDropdownMenu]（图标触发的下拉菜单）
/// - [MiuixOverlayIconCascadingDropdownMenu]（带子菜单的级联菜单）
///
/// Overlay 变体在 [MiuixScaffold] 内绘制弹层；Window 变体在窗口顶层绘制，
/// 适合桌面/大屏。二者 API 一致，仅弹层挂载位置不同。
class MenusShowcase extends StatefulWidget {
  const MenusShowcase({super.key});

  @override
  State<MenusShowcase> createState() => _MenusShowcaseState();
}

class _MenusShowcaseState extends State<MenusShowcase> {
  // 下拉偏好选中态。
  int _overlayDropdown = 0;
  int _windowDropdown = 0;
  int _groupedA = 0;
  int _groupedB = 0;

  // 微调偏好选中态。
  int _overlaySpinner = 0;
  int _dialogSpinner = 2;

  static const _itemMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  static const _shortOptions = ['选项 1', '选项 2', '选项 3', '选项 4'];
  static const _longOptions = [
    '选项 1',
    '较长的选项 2',
    '更长一些的选项 3',
    '相当长的选项 4',
    '非常非常长的选项 5',
    '长到需要滚动的选项 6',
  ];

  /// 带颜色色块图标的微调项（对应原版 RoundedRectanglePainter + 颜色）。
  List<MiuixDropdownItem> get _spinnerItems => const [
        (text: '红色', color: Color(0xFFFF5B29)),
        (text: '绿色', color: Color(0xFF36D167)),
        (text: '蓝色', color: Color(0xFF3482FF)),
        (text: '黄色', color: Color(0xFFFFB21D)),
      ]
          .map((o) => MiuixDropdownItem(
                text: o.text,
                summary: 'RGB 色块',
                icon: _ColorSwatch(color: o.color),
              ))
          .toList();

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: '菜单选择 Menus',
      subtitle: 'Dropdown / Spinner / CascadingMenu',
      sections: [
        _dropdownPreferenceSection(),
        _spinnerPreferenceSection(),
        _menuSection(),
      ],
    );
  }

  /// 下拉偏好行：单分组 + 多分组，Overlay / Window 两种弹层挂载。
  ShowcaseSection _dropdownPreferenceSection() {
    // 多分组：两个分组，各自独立选中态，展开选择时不自动收起。
    final groupedEntries = [
      MiuixDropdownEntry(
        items: [
          for (var i = 0; i < 2; i++)
            MiuixDropdownItem(
              text: '分组 A · 选项 ${i + 1}',
              selected: _groupedA == i,
              onClick: () => setState(() => _groupedA = i),
            ),
        ],
      ),
      MiuixDropdownEntry(
        items: [
          for (var i = 0; i < 3; i++)
            MiuixDropdownItem(
              text: '分组 B · 选项 ${i + 1}',
              enabled: i != 1, // 中间项禁用，演示逐项禁用能力。
              selected: _groupedB == i,
              onClick: () => setState(() => _groupedB = i),
            ),
        ],
      ),
    ];

    return ShowcaseSection('下拉偏好 DropdownPreference', [
      GroupCard(children: [
        MiuixOverlayDropdownPreference(
          title: '下拉偏好 (Overlay)',
          summary: '在 Scaffold 内弹层',
          items: _shortOptions,
          selectedIndex: _overlayDropdown,
          insideMargin: _itemMargin,
          onSelectedIndexChange: (i) => setState(() => _overlayDropdown = i),
        ),
        const IndentDivider(),
        MiuixWindowDropdownPreference(
          title: '下拉偏好 (Window)',
          summary: '长列表 · 窗口顶层弹层',
          items: _longOptions,
          selectedIndex: _windowDropdown,
          insideMargin: _itemMargin,
          onSelectedIndexChange: (i) => setState(() => _windowDropdown = i),
        ),
        const IndentDivider(),
        MiuixOverlayDropdownPreference.entries(
          title: '多分组下拉偏好',
          summary: 'A=${_groupedA + 1} · B=${_groupedB + 1}',
          entries: groupedEntries,
          collapseOnSelection: false,
          insideMargin: _itemMargin,
        ),
        const IndentDivider(),
        const MiuixOverlayDropdownPreference(
          title: '禁用下拉偏好',
          summary: 'enabled = false',
          items: ['唯一选项'],
          selectedIndex: 0,
          enabled: false,
          insideMargin: _itemMargin,
        ),
      ]),
    ]);
  }

  /// 微调偏好行：带图标/摘要的选项，普通弹层与对话框模式。
  ShowcaseSection _spinnerPreferenceSection() {
    return ShowcaseSection('微调偏好 SpinnerPreference', [
      GroupCard(children: [
        MiuixOverlaySpinnerPreference(
          title: '微调偏好 (Overlay)',
          summary: '带色块图标',
          items: _spinnerItems,
          selectedIndex: _overlaySpinner,
          insideMargin: _itemMargin,
          onSelectedIndexChange: (i) => setState(() => _overlaySpinner = i),
        ),
        const IndentDivider(),
        MiuixWindowSpinnerPreference(
          title: '对话框微调 (Window)',
          summary: '弹出对话框选择',
          dialogButtonString: '确定',
          items: _spinnerItems,
          selectedIndex: _dialogSpinner,
          insideMargin: _itemMargin,
          onSelectedIndexChange: (i) => setState(() => _dialogSpinner = i),
        ),
        const IndentDivider(),
        MiuixOverlaySpinnerPreference(
          title: '禁用微调偏好',
          summary: 'enabled = false',
          items: const [MiuixDropdownItem(text: '选项')],
          selectedIndex: 0,
          enabled: false,
          insideMargin: _itemMargin,
        ),
      ]),
    ]);
  }

  /// 图标触发的下拉 / 级联菜单。
  ShowcaseSection _menuSection() {
    // 级联菜单：末级带子菜单。
    final cascadingEntry = MiuixDropdownEntry(
      items: [
        const MiuixDropdownItem(text: '新建'),
        const MiuixDropdownItem(text: '打开'),
        MiuixDropdownItem(
          text: '分享到',
          children: const [
            MiuixDropdownItem(text: '微信'),
            MiuixDropdownItem(text: '邮件'),
            MiuixDropdownItem(text: '复制链接'),
          ],
        ),
        const MiuixDropdownItem(text: '删除'),
      ],
    );

    return ShowcaseSection('菜单 Menu', [
      GroupCard(children: [
        MiuixBasicComponent(
          title: '下拉菜单',
          summary: '点击右侧图标展开选项',
          insideMargin: _itemMargin,
          endActions: [
            MiuixOverlayIconDropdownMenu(
              entry: MiuixDropdownEntry(
                items: [
                  const MiuixDropdownItem(text: '编辑'),
                  const MiuixDropdownItem(text: '复制'),
                  const MiuixDropdownItem(text: '重命名'),
                  const MiuixDropdownItem(text: '删除'),
                ],
              ),
              child: MiuixIcon(vector: MiuixIcons.extended.byName('more')!),
            ),
          ],
        ),
        const IndentDivider(),
        MiuixBasicComponent(
          title: '级联菜单',
          summary: '支持子菜单嵌套（分享到 → 微信/邮件/复制链接）',
          insideMargin: _itemMargin,
          endActions: [
            MiuixOverlayIconCascadingDropdownMenu(
              entry: cascadingEntry,
              child: MiuixIcon(vector: MiuixIcons.extended.byName('more')!),
            ),
          ],
        ),
      ]),
    ]);
  }
}

/// 微调项左侧的圆角色块图标（对应原版 RoundedRectanglePainter）。
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
