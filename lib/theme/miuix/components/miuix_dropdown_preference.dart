// Miuix Flutter 移植版 - DropdownPreference
// 源自 compose-miuix-preference/miuix 的 preference/OverlayDropdownPreference.kt、
// preference/WindowDropdownPreference.kt。
// 在 BasicComponent 末尾追加选中值文本与下拉箭头，点击展开下拉弹窗。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/miuix_theme.dart';
import 'miuix_basic_component.dart';
import 'miuix_dropdown.dart';
import 'miuix_dropdown_popup.dart';
import 'miuix_text.dart';

/// Scaffold 内下拉偏好行（items + selectedIndex）。对应 Kotlin `OverlayDropdownPreference(items, selectedIndex)`。
class MiuixOverlayDropdownPreference extends StatelessWidget {
  const MiuixOverlayDropdownPreference({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.dropdownColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.showValue = true,
    this.renderInRootScaffold = true,
    this.collapseOnSelection = true,
    this.onExpandedChange,
    this.onSelectedIndexChange,
  })  : entry = null,
        entries = const <MiuixDropdownEntry>[];

  /// Scaffold 内下拉偏好行（单分组）。对应 Kotlin `OverlayDropdownPreference(entry)`。
  const MiuixOverlayDropdownPreference.entry({
    super.key,
    required this.entry,
    required this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.dropdownColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.showValue = true,
    this.renderInRootScaffold = true,
    this.collapseOnSelection = true,
    this.onExpandedChange,
  })  : items = const <String>[],
        selectedIndex = 0,
        entries = const <MiuixDropdownEntry>[],
        onSelectedIndexChange = null;

  /// Scaffold 内下拉偏好行（多分组）。对应 Kotlin `OverlayDropdownPreference(entries)`。
  const MiuixOverlayDropdownPreference.entries({
    super.key,
    required this.entries,
    required this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.dropdownColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.showValue = true,
    this.renderInRootScaffold = true,
    this.collapseOnSelection,
    this.onExpandedChange,
  })  : items = const <String>[],
        selectedIndex = 0,
        entry = null,
        onSelectedIndexChange = null;

  final List<String> items;
  final int selectedIndex;
  final MiuixDropdownEntry? entry;
  final List<MiuixDropdownEntry> entries;
  final String title;
  final MiuixBasicComponentColors? titleColor;
  final String? summary;
  final MiuixBasicComponentColors? summaryColor;
  final MiuixDropdownColors? dropdownColors;
  final Widget? startAction;
  final Widget? bottomAction;
  final EdgeInsetsGeometry insideMargin;
  final double? maxHeight;
  final bool enabled;
  final bool showValue;
  final bool renderInRootScaffold;
  final bool? collapseOnSelection;
  final ValueChanged<bool>? onExpandedChange;
  final ValueChanged<int>? onSelectedIndexChange;

  List<MiuixDropdownEntry> get _effectiveEntries {
    if (entry != null) return <MiuixDropdownEntry>[entry!];
    if (entries.isNotEmpty) {
      return entries.where((e) => e.items.isNotEmpty).toList(growable: false);
    }
    // items + selectedIndex 模式：构造单分组
    return <MiuixDropdownEntry>[
      MiuixDropdownEntry(
        items: List<MiuixDropdownItem>.generate(items.length, (index) {
          return MiuixDropdownItem(
            text: items[index],
            selected: index == selectedIndex,
            onClick: () => onSelectedIndexChange?.call(index),
          );
        }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _DropdownPreferenceBody(
      entries: _effectiveEntries,
      title: title,
      titleColor: titleColor,
      summary: summary,
      summaryColor: summaryColor,
      dropdownColors: dropdownColors,
      startAction: startAction,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      maxHeight: maxHeight,
      enabled: enabled,
      showValue: showValue,
      collapseOnSelection: collapseOnSelection,
      onExpandedChange: onExpandedChange,
      windowLevel: false,
      renderInRootScaffold: renderInRootScaffold,
    );
  }
}

/// 窗口级下拉偏好行（items + selectedIndex）。对应 Kotlin `WindowDropdownPreference(items, selectedIndex)`。
class MiuixWindowDropdownPreference extends StatelessWidget {
  const MiuixWindowDropdownPreference({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.dropdownColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.showValue = true,
    this.collapseOnSelection = true,
    this.onExpandedChange,
    this.onSelectedIndexChange,
  })  : entry = null,
        entries = const <MiuixDropdownEntry>[];

  /// 窗口级下拉偏好行（单分组）。对应 Kotlin `WindowDropdownPreference(entry)`。
  const MiuixWindowDropdownPreference.entry({
    super.key,
    required this.entry,
    required this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.dropdownColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.showValue = true,
    this.collapseOnSelection = true,
    this.onExpandedChange,
  })  : items = const <String>[],
        selectedIndex = 0,
        entries = const <MiuixDropdownEntry>[],
        onSelectedIndexChange = null;

  /// 窗口级下拉偏好行（多分组）。对应 Kotlin `WindowDropdownPreference(entries)`。
  const MiuixWindowDropdownPreference.entries({
    super.key,
    required this.entries,
    required this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.dropdownColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.showValue = true,
    this.collapseOnSelection,
    this.onExpandedChange,
  })  : items = const <String>[],
        selectedIndex = 0,
        entry = null,
        onSelectedIndexChange = null;

  final List<String> items;
  final int selectedIndex;
  final MiuixDropdownEntry? entry;
  final List<MiuixDropdownEntry> entries;
  final String title;
  final MiuixBasicComponentColors? titleColor;
  final String? summary;
  final MiuixBasicComponentColors? summaryColor;
  final MiuixDropdownColors? dropdownColors;
  final Widget? startAction;
  final Widget? bottomAction;
  final EdgeInsetsGeometry insideMargin;
  final double? maxHeight;
  final bool enabled;
  final bool showValue;
  final bool? collapseOnSelection;
  final ValueChanged<bool>? onExpandedChange;
  final ValueChanged<int>? onSelectedIndexChange;

  List<MiuixDropdownEntry> get _effectiveEntries {
    if (entry != null) return <MiuixDropdownEntry>[entry!];
    if (entries.isNotEmpty) {
      return entries.where((e) => e.items.isNotEmpty).toList(growable: false);
    }
    return <MiuixDropdownEntry>[
      MiuixDropdownEntry(
        items: List<MiuixDropdownItem>.generate(items.length, (index) {
          return MiuixDropdownItem(
            text: items[index],
            selected: index == selectedIndex,
            onClick: () => onSelectedIndexChange?.call(index),
          );
        }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _DropdownPreferenceBody(
      entries: _effectiveEntries,
      title: title,
      titleColor: titleColor,
      summary: summary,
      summaryColor: summaryColor,
      dropdownColors: dropdownColors,
      startAction: startAction,
      bottomAction: bottomAction,
      insideMargin: insideMargin,
      maxHeight: maxHeight,
      enabled: enabled,
      showValue: showValue,
      collapseOnSelection: collapseOnSelection,
      onExpandedChange: onExpandedChange,
      windowLevel: true,
      renderInRootScaffold: true,
    );
  }
}

class _DropdownPreferenceBody extends StatefulWidget {
  const _DropdownPreferenceBody({
    required this.entries,
    required this.title,
    required this.titleColor,
    required this.summary,
    required this.summaryColor,
    required this.dropdownColors,
    required this.startAction,
    required this.bottomAction,
    required this.insideMargin,
    required this.maxHeight,
    required this.enabled,
    required this.showValue,
    required this.collapseOnSelection,
    required this.onExpandedChange,
    required this.windowLevel,
    required this.renderInRootScaffold,
  });

  final List<MiuixDropdownEntry> entries;
  final String title;
  final MiuixBasicComponentColors? titleColor;
  final String? summary;
  final MiuixBasicComponentColors? summaryColor;
  final MiuixDropdownColors? dropdownColors;
  final Widget? startAction;
  final Widget? bottomAction;
  final EdgeInsetsGeometry insideMargin;
  final double? maxHeight;
  final bool enabled;
  final bool showValue;
  final bool? collapseOnSelection;
  final ValueChanged<bool>? onExpandedChange;
  final bool windowLevel;
  final bool renderInRootScaffold;

  @override
  State<_DropdownPreferenceBody> createState() =>
      _DropdownPreferenceBodyState();
}

class _DropdownPreferenceBodyState extends State<_DropdownPreferenceBody> {
  final GlobalKey _anchorKey = GlobalKey();
  bool _expanded = false;
  bool _holdDown = false;
  Rect _anchorBounds = Rect.zero;

  List<MiuixDropdownEntry> get _nonEmptyEntries =>
      widget.entries.where((e) => e.items.isNotEmpty).toList(growable: false);

  bool get _hasEntries => _nonEmptyEntries.isNotEmpty;
  bool get _actualEnabled => widget.enabled && _hasEntries;

  bool get _collapse =>
      widget.collapseOnSelection ?? (_nonEmptyEntries.length <= 1);

  void _setExpanded(bool expanded) {
    if (_expanded == expanded) return;
    setState(() => _expanded = expanded);
    widget.onExpandedChange?.call(expanded);
  }

  void _handleClick() {
    if (!_actualEnabled) return;
    if (!_expanded) {
      final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final topLeft = box.localToGlobal(Offset.zero);
        _anchorBounds = topLeft & box.size;
      }
    }
    _setExpanded(!_expanded);
    if (_expanded) {
      setState(() => _holdDown = true);
      HapticFeedback.selectionClick();
    }
  }

  void _onDismiss() => _setExpanded(false);
  void _onDismissFinished() {
    if (!mounted) return;
    setState(() => _holdDown = false);
  }

  /// 选中值的拼接文本。对应 Kotlin `nonEmptyEntries.flatMap { it.items }.filter { it.selected }.map { it.text }.joinToString("\n")`。
  String? get _selectedValueText {
    final List<String> selected = <String>[];
    for (final entry in _nonEmptyEntries) {
      for (final item in entry.items) {
        if (item.selected && item.text.isNotEmpty) {
          selected.add(item.text);
        }
      }
    }
    return selected.isEmpty ? null : selected.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.dropdownColors ??
        MiuixDropdownDefaults.dropdownColors(context);
    final theme = MiuixTheme.of(context);
    final actionColor = _actualEnabled
        ? theme.colors.onSurfaceVariantActions
        : theme.colors.disabledOnSecondaryVariant;

    final Widget popup = _hasEntries
        ? (widget.windowLevel
            ? MiuixWindowDropdownPopup.entries(
                key: const ValueKey<String>('dropdown-pref-popup'),
                entries: _nonEmptyEntries,
                show: _expanded,
                anchorBounds: _anchorBounds,
                onDismiss: _onDismiss,
                onDismissFinished: _onDismissFinished,
                maxHeight: widget.maxHeight,
                dropdownColors: colors,
                collapseOnSelection: _collapse,
              )
            : MiuixOverlayDropdownPopup.entries(
                key: const ValueKey<String>('dropdown-pref-popup'),
                entries: _nonEmptyEntries,
                show: _expanded,
                anchorBounds: _anchorBounds,
                onDismiss: _onDismiss,
                onDismissFinished: _onDismissFinished,
                maxHeight: widget.maxHeight,
                dropdownColors: colors,
                renderInRootScaffold: widget.renderInRootScaffold,
                collapseOnSelection: _collapse,
              ))
        : const SizedBox.shrink();

    final String? valueText =
        (widget.showValue && _hasEntries) ? _selectedValueText : null;

    return MiuixBasicComponent(
      key: _anchorKey,
      insideMargin: widget.insideMargin,
      title: widget.title,
      titleColor: widget.titleColor,
      summary: widget.summary,
      summaryColor: widget.summaryColor,
      startAction: widget.startAction,
      endActions: <Widget>[
        if (valueText != null)
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: MiuixText(
                valueText,
                fontSize: theme.textStyles.body2.fontSize,
                color: actionColor,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        MiuixDropdownArrowEndAction(actionColor: actionColor),
        popup,
      ],
      bottomAction: widget.bottomAction,
      onClick: _actualEnabled ? _handleClick : null,
      role: MiuixBasicComponentRole.dropdownList,
      holdDownState: _holdDown,
      enabled: _actualEnabled,
    );
  }
}
