// Miuix Flutter 移植版 - DropdownPopup / DropdownDialog
// 源自 compose-miuix-ui/miuix 的 popup/DropdownEntriesContent.kt、
// popup/OverlayDropdownPopup.kt 与 popup/WindowDropdownPopup.kt。
// 复用已移植的 MiuixOverlayListPopup/MiuixWindowListPopup/MiuixOverlayDialog 与
// MiuixDropdownImpl，按弹窗/对话框两种模式组织 [MiuixDropdownEntry] 分组与分隔线。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'miuix_divider.dart';
import 'miuix_dropdown.dart';
import 'miuix_button.dart';
import 'miuix_list_popup.dart';
import 'miuix_list_popup_host.dart';
import 'miuix_overlay_dialog.dart';

/// 在弹窗容器内渲染 [MiuixDropdownEntry] 分组列表。对应 Kotlin `DropdownEntriesPopupContent`。
///
/// 内部计算弹窗全局的 first/last：仅整个弹窗的第一行与最后一行获得更大的首/末内边距；
/// 分组边界回退到中间行内边距。分组之间插入 1.5dp 分隔线（水平/垂直各 4dp 边距）。
///
/// 调用方负责将其放入 [MiuixListPopupColumn] 之类的滚动容器中。本组件本身不滚动。
class MiuixDropdownEntriesPopupContent extends StatelessWidget {
  const MiuixDropdownEntriesPopupContent({
    super.key,
    required this.entries,
    required this.dropdownColors,
    required this.onItemClick,
  });

  /// 一组或多组下拉项。每组之间以分隔线分隔。
  final List<MiuixDropdownEntry> entries;

  /// 下拉行配色。
  final MiuixDropdownColors dropdownColors;

  /// 项点击回调，参数为 `(entryIdx, itemIdx)`。
  final void Function(int entryIdx, int itemIdx) onItemClick;

  @override
  Widget build(BuildContext context) {
    final int lastEntryIdx = entries.length - 1;
    final List<Widget> children = <Widget>[];
    for (int entryIdx = 0; entryIdx < entries.length; entryIdx++) {
      final entry = entries[entryIdx];
      final int lastItemIdx = entry.items.length - 1;
      final bool isFirstEntry = entryIdx == 0;
      final bool isLastEntry = entryIdx == lastEntryIdx;
      for (int itemIdx = 0; itemIdx < entry.items.length; itemIdx++) {
        final option = entry.items[itemIdx];
        children.add(MiuixDropdownImpl(
          key: ValueKey<String>('dropdown-$entryIdx-$itemIdx'),
          item: option,
          optionSize: entry.items.length,
          isSelected: option.selected,
          index: itemIdx,
          dropdownColors: dropdownColors,
          enabled: entry.enabled && option.enabled,
          isFirst: isFirstEntry && itemIdx == 0,
          isLast: isLastEntry && itemIdx == lastItemIdx,
          onSelectedIndexChange: (idx) => onItemClick(entryIdx, idx),
        ));
      }
      if (entryIdx != lastEntryIdx) {
        children.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: MiuixHorizontalDivider(thickness: 1.5),
        ));
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// 在对话框容器内渲染 [MiuixDropdownEntry] 分组列表（[ListView] 子项列表）。
/// 对应 Kotlin `LazyListScope.dropdownEntriesDialogItems`。
///
/// 对话框模式使用统一的垂直内边距，不传播弹窗全局 first/last。分组之间同样插入
/// 1.5dp 分隔线。返回的 [Widget] 列表可直接作为 [ListView] / [Column] 的 children。
class MiuixDropdownEntriesDialogItems extends StatelessWidget {
  const MiuixDropdownEntriesDialogItems({
    super.key,
    required this.entries,
    required this.dropdownColors,
    required this.onItemClick,
  });

  final List<MiuixDropdownEntry> entries;
  final MiuixDropdownColors dropdownColors;
  final void Function(int entryIdx, int itemIdx) onItemClick;

  @override
  Widget build(BuildContext context) {
    final int lastEntryIdx = entries.length - 1;
    final List<Widget> children = <Widget>[];
    for (int entryIdx = 0; entryIdx < entries.length; entryIdx++) {
      final entry = entries[entryIdx];
      final int lastItemIdx = entry.items.length - 1;
      for (int itemIdx = 0; itemIdx < entry.items.length; itemIdx++) {
        final item = entry.items[itemIdx];
        children.add(MiuixDropdownImpl(
          key: ValueKey<String>('dialog-$entryIdx-$itemIdx'),
          item: item,
          optionSize: entry.items.length,
          isSelected: item.selected,
          index: itemIdx,
          dropdownColors: dropdownColors,
          enabled: entry.enabled && item.enabled,
          dialogMode: true,
          onSelectedIndexChange: (idx) => onItemClick(entryIdx, idx),
        ));
        // 在每组最后一项之后插入分隔线，除非是最后一组
        if (itemIdx == lastItemIdx && entryIdx != lastEntryIdx) {
          children.add(KeyedSubtree(
            key: ValueKey<String>('divider-$entryIdx'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: MiuixHorizontalDivider(thickness: 1.5),
            ),
          ));
        }
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// Scaffold 内下拉弹窗（单分组）。对应 Kotlin `OverlayDropdownPopup(entry)`。
class MiuixOverlayDropdownPopup extends StatelessWidget {
  const MiuixOverlayDropdownPopup({
    super.key,
    required this.entry,
    required this.show,
    required this.anchorBounds,
    required this.onDismiss,
    required this.onDismissFinished,
    this.maxHeight,
    required this.dropdownColors,
    this.renderInRootScaffold = true,
    this.collapseOnSelection = true,
  }) : entries = const <MiuixDropdownEntry>[];

  /// Scaffold 内下拉弹窗（多分组）。对应 Kotlin `OverlayDropdownPopup(entries)`。
  ///
  /// [collapseOnSelection] 默认值为 `entries.length <= 1`，与源码一致：单分组时
  /// 选中即关闭；多分组（动作菜单）时默认不关闭。
  const MiuixOverlayDropdownPopup.entries({
    super.key,
    required this.entries,
    required this.show,
    required this.anchorBounds,
    required this.onDismiss,
    required this.onDismissFinished,
    this.maxHeight,
    required this.dropdownColors,
    this.renderInRootScaffold = true,
    this.collapseOnSelection,
  }) : entry = null;

  final MiuixDropdownEntry? entry;
  final List<MiuixDropdownEntry> entries;
  final bool show;
  final Rect anchorBounds;
  final VoidCallback onDismiss;
  final VoidCallback onDismissFinished;
  final double? maxHeight;
  final MiuixDropdownColors dropdownColors;
  final bool renderInRootScaffold;
  final bool? collapseOnSelection;

  bool get _collapse =>
      collapseOnSelection ?? (effectiveEntries.length <= 1);

  List<MiuixDropdownEntry> get effectiveEntries =>
      entry != null ? <MiuixDropdownEntry>[entry!] : entries;

  @override
  Widget build(BuildContext context) {
    final list = effectiveEntries;
    final bool collapse = _collapse;
    void onItemClicked(int entryIdx, int itemIdx) {
      HapticFeedback.selectionClick();
      final e = list.elementAtOrNull(entryIdx);
      e?.items.elementAtOrNull(itemIdx)?.onClick?.call();
      if (collapse) onDismiss();
    }

    return MiuixOverlayListPopup(
      show: show,
      anchorBounds: anchorBounds,
      alignment: MiuixPopupAlign.end,
      onDismissRequest: onDismiss,
      onDismissFinished: onDismissFinished,
      maxHeight: maxHeight,
      renderInRootScaffold: renderInRootScaffold,
      content: MiuixListPopupColumn(
        children: <Widget>[
          MiuixDropdownEntriesPopupContent(
            entries: list,
            dropdownColors: dropdownColors,
            onItemClick: onItemClicked,
          ),
        ],
      ),
    );
  }
}

/// 窗口级下拉弹窗（单分组）。对应 Kotlin `WindowDropdownPopup(entry)`。
class MiuixWindowDropdownPopup extends StatelessWidget {
  const MiuixWindowDropdownPopup({
    super.key,
    required this.entry,
    required this.show,
    required this.anchorBounds,
    required this.onDismiss,
    required this.onDismissFinished,
    this.maxHeight,
    required this.dropdownColors,
    this.collapseOnSelection = true,
  }) : entries = const <MiuixDropdownEntry>[];

  /// 窗口级下拉弹窗（多分组）。对应 Kotlin `WindowDropdownPopup(entries)`。
  const MiuixWindowDropdownPopup.entries({
    super.key,
    required this.entries,
    required this.show,
    required this.anchorBounds,
    required this.onDismiss,
    required this.onDismissFinished,
    this.maxHeight,
    required this.dropdownColors,
    this.collapseOnSelection,
  }) : entry = null;

  final MiuixDropdownEntry? entry;
  final List<MiuixDropdownEntry> entries;
  final bool show;
  final Rect anchorBounds;
  final VoidCallback onDismiss;
  final VoidCallback onDismissFinished;
  final double? maxHeight;
  final MiuixDropdownColors dropdownColors;
  final bool? collapseOnSelection;

  bool get _collapse =>
      collapseOnSelection ?? (effectiveEntries.length <= 1);

  List<MiuixDropdownEntry> get effectiveEntries =>
      entry != null ? <MiuixDropdownEntry>[entry!] : entries;

  @override
  Widget build(BuildContext context) {
    final list = effectiveEntries;
    final bool collapse = _collapse;
    void onItemClicked(int entryIdx, int itemIdx) {
      HapticFeedback.selectionClick();
      final e = list.elementAtOrNull(entryIdx);
      e?.items.elementAtOrNull(itemIdx)?.onClick?.call();
      if (collapse) onDismiss();
    }

    return MiuixWindowListPopup(
      show: show,
      anchorBounds: anchorBounds,
      alignment: MiuixPopupAlign.end,
      onDismissRequest: onDismiss,
      onDismissFinished: onDismissFinished,
      maxHeight: maxHeight,
      content: MiuixListPopupColumn(
        children: <Widget>[
          MiuixDropdownEntriesPopupContent(
            entries: list,
            dropdownColors: dropdownColors,
            onItemClick: onItemClicked,
          ),
        ],
      ),
    );
  }
}

/// Scaffold 内下拉对话框（单分组）。对应 Kotlin `OverlayDropdownDialog(entry)`。
class MiuixOverlayDropdownDialog extends StatelessWidget {
  const MiuixOverlayDropdownDialog({
    super.key,
    required this.entry,
    required this.title,
    required this.dialogButtonString,
    required this.show,
    required this.onDismiss,
    required this.onDismissFinished,
    required this.dropdownColors,
    this.renderInRootScaffold = true,
    this.collapseOnSelection = true,
  }) : entries = const <MiuixDropdownEntry>[];

  /// Scaffold 内下拉对话框（多分组）。对应 Kotlin `OverlayDropdownDialog(entries)`。
  const MiuixOverlayDropdownDialog.entries({
    super.key,
    required this.entries,
    required this.title,
    required this.dialogButtonString,
    required this.show,
    required this.onDismiss,
    required this.onDismissFinished,
    required this.dropdownColors,
    this.renderInRootScaffold = true,
    this.collapseOnSelection,
  }) : entry = null;

  final MiuixDropdownEntry? entry;
  final List<MiuixDropdownEntry> entries;
  final String title;
  final String dialogButtonString;
  final bool show;
  final VoidCallback onDismiss;
  final VoidCallback onDismissFinished;
  final MiuixDropdownColors dropdownColors;
  final bool renderInRootScaffold;
  final bool? collapseOnSelection;

  bool get _collapse =>
      collapseOnSelection ?? (effectiveEntries.length <= 1);

  List<MiuixDropdownEntry> get effectiveEntries =>
      entry != null ? <MiuixDropdownEntry>[entry!] : entries;

  @override
  Widget build(BuildContext context) {
    final list = effectiveEntries;
    final bool collapse = _collapse;
    void onItemClicked(int entryIdx, int itemIdx) {
      HapticFeedback.selectionClick();
      final e = list.elementAtOrNull(entryIdx);
      e?.items.elementAtOrNull(itemIdx)?.onClick?.call();
      if (collapse) onDismiss();
    }

    return MiuixOverlayDialog(
      show: show,
      title: title,
      onDismissRequest: onDismiss,
      onDismissFinished: onDismissFinished,
      insideMargin: const Size(0, 24),
      renderInRootScaffold: renderInRootScaffold,
      content: _DropdownDialogContentBody(
        entries: list,
        dropdownColors: dropdownColors,
        onItemClick: onItemClicked,
        dialogButtonString: dialogButtonString,
        onDismiss: onDismiss,
      ),
    );
  }
}

/// 窗口级下拉对话框（单分组）。对应 Kotlin `WindowDropdownDialog(entry)`。
///
/// Flutter 中无独立 OS 窗口层；本组件以 [MiuixOverlayDialog] 的 `renderInRootScaffold: true`
/// 注册至根 Overlay，作为 Compose `WindowDialog` 的等价物。
class MiuixWindowDropdownDialog extends StatelessWidget {
  const MiuixWindowDropdownDialog({
    super.key,
    required this.entry,
    required this.title,
    required this.dialogButtonString,
    required this.show,
    required this.onDismiss,
    required this.onDismissFinished,
    required this.dropdownColors,
    this.collapseOnSelection = true,
  }) : entries = const <MiuixDropdownEntry>[];

  /// 窗口级下拉对话框（多分组）。对应 Kotlin `WindowDropdownDialog(entries)`。
  const MiuixWindowDropdownDialog.entries({
    super.key,
    required this.entries,
    required this.title,
    required this.dialogButtonString,
    required this.show,
    required this.onDismiss,
    required this.onDismissFinished,
    required this.dropdownColors,
    this.collapseOnSelection,
  }) : entry = null;

  final MiuixDropdownEntry? entry;
  final List<MiuixDropdownEntry> entries;
  final String title;
  final String dialogButtonString;
  final bool show;
  final VoidCallback onDismiss;
  final VoidCallback onDismissFinished;
  final MiuixDropdownColors dropdownColors;
  final bool? collapseOnSelection;

  bool get _collapse =>
      collapseOnSelection ?? (effectiveEntries.length <= 1);

  List<MiuixDropdownEntry> get effectiveEntries =>
      entry != null ? <MiuixDropdownEntry>[entry!] : entries;

  @override
  Widget build(BuildContext context) {
    final list = effectiveEntries;
    final bool collapse = _collapse;
    void onItemClicked(int entryIdx, int itemIdx) {
      HapticFeedback.selectionClick();
      final e = list.elementAtOrNull(entryIdx);
      e?.items.elementAtOrNull(itemIdx)?.onClick?.call();
      if (collapse) onDismiss();
    }

    return MiuixOverlayDialog(
      show: show,
      title: title,
      onDismissRequest: onDismiss,
      onDismissFinished: onDismissFinished,
      insideMargin: const Size(0, 24),
      renderInRootScaffold: true,
      content: _DropdownDialogContentBody(
        entries: list,
        dropdownColors: dropdownColors,
        onItemClick: onItemClicked,
        dialogButtonString: dialogButtonString,
        onDismiss: onDismiss,
      ),
    );
  }
}

/// 下拉对话框内容主体：上方列表 + 下方 TextButton。
///
/// 复刻 Kotlin 自定义 `Layout { LazyColumn + TextButton }` 的测量逻辑：
/// 先测量按钮，再将剩余高度分配给列表。大屏（约束有界）下列表滚动；小屏（无界）
/// 下列表按内在高度展开。
class _DropdownDialogContentBody extends StatelessWidget {
  const _DropdownDialogContentBody({
    required this.entries,
    required this.dropdownColors,
    required this.onItemClick,
    required this.dialogButtonString,
    required this.onDismiss,
  });

  final List<MiuixDropdownEntry> entries;
  final MiuixDropdownColors dropdownColors;
  final void Function(int entryIdx, int itemIdx) onItemClick;
  final String dialogButtonString;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final Widget button = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 0),
      child: SizedBox(
        width: double.infinity,
        child: MiuixTextButton(
          dialogButtonString,
          onPressed: onDismiss,
          minHeight: 50,
        ),
      ),
    );

    final Widget listItems = MiuixDropdownEntriesDialogItems(
      entries: entries,
      dropdownColors: dropdownColors,
      onItemClick: onItemClick,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool bounded = constraints.maxHeight.isFinite;
        if (bounded) {
          // 有界（大屏）：列表填充剩余高度，超出时滚动。
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[listItems],
                ),
              ),
              button,
            ],
          );
        }
        // 无界（小屏）：列表按内在高度展开，无滚动。
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[listItems],
            ),
            button,
          ],
        );
      },
    );
  }
}
