// Miuix Flutter 移植版 - CascadingListPopup
// 源自 compose-miuix-ui/miuix 的 overlay/window CascadingListPopup 与
// layout/CascadingListPopupLayout.kt。级联深度限制为 2。
// 主菜单复用 ListPopup 动效；子菜单以 0.95 主层缩放、半强度遮罩与弹簧展开复刻级联态。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import 'miuix_dropdown.dart';
import 'miuix_list_popup.dart';
import 'miuix_list_popup_host.dart';

/// Scaffold 内二级级联列表弹窗。对应 Kotlin `OverlayCascadingListPopup`。
class MiuixOverlayCascadingListPopup extends StatelessWidget {
  const MiuixOverlayCascadingListPopup({
    super.key,
    required this.show,
    required this.anchorBounds,
    required this.entries,
    required this.onDismissRequest,
    this.onDismissFinished,
    this.popupPositionProvider,
    this.alignment = MiuixPopupAlign.end,
    this.enableWindowDim = true,
    this.maxHeight,
    this.minWidth = 200,
    this.renderInRootScaffold = true,
    this.dropdownColors,
    this.collapseOnSelection = true,
  });

  final bool show;
  final Rect anchorBounds;
  final List<MiuixDropdownEntry> entries;
  final VoidCallback onDismissRequest;
  final VoidCallback? onDismissFinished;
  final MiuixPopupPositionProvider? popupPositionProvider;
  final MiuixPopupAlign alignment;
  final bool enableWindowDim;
  final double? maxHeight;
  final double minWidth;
  final bool renderInRootScaffold;
  final MiuixDropdownColors? dropdownColors;
  final bool collapseOnSelection;

  @override
  Widget build(BuildContext context) => _MiuixCascadingPopup(
    show: show,
    anchorBounds: anchorBounds,
    entries: entries,
    onDismissRequest: onDismissRequest,
    onDismissFinished: onDismissFinished,
    popupPositionProvider: popupPositionProvider,
    alignment: alignment,
    enableWindowDim: enableWindowDim,
    maxHeight: maxHeight,
    minWidth: minWidth,
    renderInRootScaffold: renderInRootScaffold,
    dropdownColors: dropdownColors,
    collapseOnSelection: collapseOnSelection,
    windowLevel: false,
  );
}

/// 窗口级二级级联列表弹窗。对应 Kotlin `WindowCascadingListPopup`。
class MiuixWindowCascadingListPopup extends StatelessWidget {
  const MiuixWindowCascadingListPopup({
    super.key,
    required this.show,
    required this.anchorBounds,
    required this.entries,
    required this.onDismissRequest,
    this.onDismissFinished,
    this.popupPositionProvider,
    this.alignment = MiuixPopupAlign.end,
    this.enableWindowDim = true,
    this.maxHeight,
    this.minWidth = 200,
    this.dropdownColors,
    this.collapseOnSelection = true,
  });

  final bool show;
  final Rect anchorBounds;
  final List<MiuixDropdownEntry> entries;
  final VoidCallback onDismissRequest;
  final VoidCallback? onDismissFinished;
  final MiuixPopupPositionProvider? popupPositionProvider;
  final MiuixPopupAlign alignment;
  final bool enableWindowDim;
  final double? maxHeight;
  final double minWidth;
  final MiuixDropdownColors? dropdownColors;
  final bool collapseOnSelection;

  @override
  Widget build(BuildContext context) => _MiuixCascadingPopup(
    show: show,
    anchorBounds: anchorBounds,
    entries: entries,
    onDismissRequest: onDismissRequest,
    onDismissFinished: onDismissFinished,
    popupPositionProvider: popupPositionProvider,
    alignment: alignment,
    enableWindowDim: enableWindowDim,
    maxHeight: maxHeight,
    minWidth: minWidth,
    renderInRootScaffold: true,
    dropdownColors: dropdownColors,
    collapseOnSelection: collapseOnSelection,
    windowLevel: true,
  );
}

class _MiuixCascadingPopup extends StatefulWidget {
  const _MiuixCascadingPopup({
    required this.show,
    required this.anchorBounds,
    required this.entries,
    required this.onDismissRequest,
    required this.onDismissFinished,
    required this.popupPositionProvider,
    required this.alignment,
    required this.enableWindowDim,
    required this.maxHeight,
    required this.minWidth,
    required this.renderInRootScaffold,
    required this.dropdownColors,
    required this.collapseOnSelection,
    required this.windowLevel,
  });

  final bool show;
  final Rect anchorBounds;
  final List<MiuixDropdownEntry> entries;
  final VoidCallback onDismissRequest;
  final VoidCallback? onDismissFinished;
  final MiuixPopupPositionProvider? popupPositionProvider;
  final MiuixPopupAlign alignment;
  final bool enableWindowDim;
  final double? maxHeight;
  final double minWidth;
  final bool renderInRootScaffold;
  final MiuixDropdownColors? dropdownColors;
  final bool collapseOnSelection;
  final bool windowLevel;

  @override
  State<_MiuixCascadingPopup> createState() => _MiuixCascadingPopupState();
}

class _MiuixCascadingPopupState extends State<_MiuixCascadingPopup> {
  MiuixDropdownItem? _expanded;

  void _outsideDismiss() {
    if (_expanded != null) {
      setState(() => _expanded = null);
    } else {
      widget.onDismissRequest();
    }
  }

  @override
  void didUpdateWidget(_MiuixCascadingPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.show && oldWidget.show) _expanded = null;
  }

  @override
  Widget build(BuildContext context) {
    final MiuixDropdownColors colors =
        widget.dropdownColors ?? MiuixDropdownDefaults.dropdownColors(context);
    final Widget body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: _expanded == null
          ? _primary(colors)
          : _secondary(_expanded!, colors),
    );

    if (widget.windowLevel) {
      return MiuixWindowListPopup(
        show: widget.show,
        anchorBounds: widget.anchorBounds,
        popupPositionProvider: widget.popupPositionProvider,
        alignment: widget.alignment,
        enableWindowDim: widget.enableWindowDim,
        onDismissRequest: _outsideDismiss,
        onDismissFinished: widget.onDismissFinished,
        maxHeight: widget.maxHeight,
        minWidth: widget.minWidth,
        content: body,
      );
    }
    return MiuixOverlayListPopup(
      show: widget.show,
      anchorBounds: widget.anchorBounds,
      popupPositionProvider: widget.popupPositionProvider,
      alignment: widget.alignment,
      enableWindowDim: widget.enableWindowDim,
      onDismissRequest: _outsideDismiss,
      onDismissFinished: widget.onDismissFinished,
      maxHeight: widget.maxHeight,
      minWidth: widget.minWidth,
      renderInRootScaffold: widget.renderInRootScaffold,
      content: body,
    );
  }

  Widget _primary(MiuixDropdownColors colors) {
    final List<MiuixDropdownItem> items = widget.entries
        .where((entry) => entry.enabled)
        .expand((entry) => entry.items)
        .toList(growable: false);
    return MiuixListPopupColumn(
      key: const ValueKey<String>('primary'),
      children: <Widget>[
        for (int index = 0; index < items.length; index++)
          MiuixDropdownImpl(
            item: items[index],
            optionSize: items.length,
            isSelected: items[index].selected,
            index: index,
            dropdownColors: colors,
            hasSubmenu: items[index].children?.isNotEmpty ?? false,
            isFirst: index == 0,
            isLast: index == items.length - 1,
            onSelectedIndexChange: (_) {
              final MiuixDropdownItem item = items[index];
              if (item.children?.isNotEmpty ?? false) {
                setState(() => _expanded = item);
              } else {
                item.onClick?.call();
                if (widget.collapseOnSelection) widget.onDismissRequest();
              }
            },
          ),
      ],
    );
  }

  Widget _secondary(MiuixDropdownItem trigger, MiuixDropdownColors colors) {
    final List<MiuixDropdownItem> children = trigger.children!;
    final List<MiuixDropdownItem> rows = <MiuixDropdownItem>[
      MiuixDropdownItem(
        text: trigger.text,
        icon: trigger.icon,
        summary: trigger.summary,
        onClick: () => setState(() => _expanded = null),
      ),
      ...children,
    ];
    return MiuixListPopupColumn(
      key: ValueKey<MiuixDropdownItem>(trigger),
      children: <Widget>[
        for (int index = 0; index < rows.length; index++)
          MiuixDropdownImpl(
            item: rows[index],
            optionSize: rows.length,
            isSelected: index == 0 ? false : rows[index].selected,
            index: index,
            dropdownColors: colors,
            hasSubmenu: index == 0,
            isFirst: index == 0,
            isLast: index == rows.length - 1,
            onSelectedIndexChange: (_) {
              if (index == 0) {
                setState(() => _expanded = null);
                return;
              }
              rows[index].onClick?.call();
              if (widget.collapseOnSelection) {
                setState(() => _expanded = null);
                widget.onDismissRequest();
              }
            },
          ),
      ],
    );
  }
}
