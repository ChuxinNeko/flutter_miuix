// Miuix Flutter 移植版 - SpinnerPreference
// 源自 compose-miuix-preference/miuix 的 preference/OverlaySpinnerPreference.kt、
// preference/WindowSpinnerPreference.kt。
// 在 BasicComponent 末尾追加选中值文本与下拉箭头，点击展开下拉弹窗或对话框。
// 与 DropdownPreference 的区别：items 为 List<DropdownItem>（保留 icon/summary 等），
// 且支持对话框模式（dialogButtonString 非空时）。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/miuix_theme.dart';
import 'miuix_basic_component.dart';
import 'miuix_dropdown.dart';
import 'miuix_dropdown_popup.dart';
import 'miuix_text.dart';

/// Scaffold 内下拉偏好行（items + selectedIndex）。对应 Kotlin
/// `OverlaySpinnerPreference(items, selectedIndex)`。
///
/// [dialogButtonString] 非空时使用对话框模式（`OverlayDropdownDialog`），
/// 为空时使用弹窗模式（`OverlayDropdownPopup`）。
class MiuixOverlaySpinnerPreference extends StatelessWidget {
  const MiuixOverlaySpinnerPreference({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.title,
    this.dialogButtonString,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.spinnerColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.showValue = true,
    this.renderInRootScaffold = true,
    this.collapseOnSelection,
    this.onExpandedChange,
    this.onSelectedIndexChange,
  })  : entry = null,
        entries = const <MiuixDropdownEntry>[];

  /// Scaffold 内下拉偏好行（单分组）。对应 Kotlin `OverlaySpinnerPreference(entry)`。
  const MiuixOverlaySpinnerPreference.entry({
    super.key,
    required this.entry,
    required this.title,
    this.dialogButtonString,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.spinnerColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.showValue = true,
    this.renderInRootScaffold = true,
    this.collapseOnSelection = true,
    this.onExpandedChange,
  })  : items = const <MiuixDropdownItem>[],
        selectedIndex = 0,
        entries = const <MiuixDropdownEntry>[],
        onSelectedIndexChange = null;

  /// Scaffold 内下拉偏好行（多分组）。对应 Kotlin `OverlaySpinnerPreference(entries)`。
  const MiuixOverlaySpinnerPreference.entries({
    super.key,
    required this.entries,
    required this.title,
    this.dialogButtonString,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.spinnerColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.showValue = true,
    this.renderInRootScaffold = true,
    this.collapseOnSelection,
    this.onExpandedChange,
  })  : items = const <MiuixDropdownItem>[],
        selectedIndex = 0,
        entry = null,
        onSelectedIndexChange = null;

  final List<MiuixDropdownItem> items;
  final int selectedIndex;
  final MiuixDropdownEntry? entry;
  final List<MiuixDropdownEntry> entries;
  final String title;
  final String? dialogButtonString;
  final MiuixBasicComponentColors? titleColor;
  final String? summary;
  final MiuixBasicComponentColors? summaryColor;
  final MiuixDropdownColors? spinnerColors;
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
    // items + selectedIndex 模式：复制原项以保留 icon/summary 等，覆盖 selected 与 onClick。
    // 对应 Kotlin `items.mapIndexed { index, item -> item.copy(selected = ..., onClick = { onSelectedIndexChange?.invoke(index); item.onClick?.invoke() }) }`。
    return <MiuixDropdownEntry>[
      MiuixDropdownEntry(
        items: List<MiuixDropdownItem>.generate(items.length, (index) {
          final original = items[index];
          return original.copyWith(
            selected: index == selectedIndex,
            onClick: () {
              onSelectedIndexChange?.call(index);
              original.onClick?.call();
            },
          );
        }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _SpinnerPreferenceBody(
      entries: _effectiveEntries,
      title: title,
      dialogButtonString: dialogButtonString,
      titleColor: titleColor,
      summary: summary,
      summaryColor: summaryColor,
      spinnerColors: spinnerColors,
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

/// 窗口级下拉偏好行（items + selectedIndex）。对应 Kotlin
/// `WindowSpinnerPreference(items, selectedIndex)`。
///
/// 窗口级组件在 Flutter 中以根 Overlay 渲染，故无 `renderInRootScaffold` 参数。
class MiuixWindowSpinnerPreference extends StatelessWidget {
  const MiuixWindowSpinnerPreference({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.title,
    this.dialogButtonString,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.spinnerColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.showValue = true,
    this.collapseOnSelection,
    this.onExpandedChange,
    this.onSelectedIndexChange,
  })  : entry = null,
        entries = const <MiuixDropdownEntry>[];

  /// 窗口级下拉偏好行（单分组）。对应 Kotlin `WindowSpinnerPreference(entry)`。
  const MiuixWindowSpinnerPreference.entry({
    super.key,
    required this.entry,
    required this.title,
    this.dialogButtonString,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.spinnerColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.showValue = true,
    this.collapseOnSelection = true,
    this.onExpandedChange,
  })  : items = const <MiuixDropdownItem>[],
        selectedIndex = 0,
        entries = const <MiuixDropdownEntry>[],
        onSelectedIndexChange = null;

  /// 窗口级下拉偏好行（多分组）。对应 Kotlin `WindowSpinnerPreference(entries)`。
  const MiuixWindowSpinnerPreference.entries({
    super.key,
    required this.entries,
    required this.title,
    this.dialogButtonString,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.spinnerColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.showValue = true,
    this.collapseOnSelection,
    this.onExpandedChange,
  })  : items = const <MiuixDropdownItem>[],
        selectedIndex = 0,
        entry = null,
        onSelectedIndexChange = null;

  final List<MiuixDropdownItem> items;
  final int selectedIndex;
  final MiuixDropdownEntry? entry;
  final List<MiuixDropdownEntry> entries;
  final String title;
  final String? dialogButtonString;
  final MiuixBasicComponentColors? titleColor;
  final String? summary;
  final MiuixBasicComponentColors? summaryColor;
  final MiuixDropdownColors? spinnerColors;
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
          final original = items[index];
          return original.copyWith(
            selected: index == selectedIndex,
            onClick: () {
              onSelectedIndexChange?.call(index);
              original.onClick?.call();
            },
          );
        }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _SpinnerPreferenceBody(
      entries: _effectiveEntries,
      title: title,
      dialogButtonString: dialogButtonString,
      titleColor: titleColor,
      summary: summary,
      summaryColor: summaryColor,
      spinnerColors: spinnerColors,
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

class _SpinnerPreferenceBody extends StatefulWidget {
  const _SpinnerPreferenceBody({
    required this.entries,
    required this.title,
    required this.dialogButtonString,
    required this.titleColor,
    required this.summary,
    required this.summaryColor,
    required this.spinnerColors,
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
  final String? dialogButtonString;
  final MiuixBasicComponentColors? titleColor;
  final String? summary;
  final MiuixBasicComponentColors? summaryColor;
  final MiuixDropdownColors? spinnerColors;
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
  State<_SpinnerPreferenceBody> createState() => _SpinnerPreferenceBodyState();
}

class _SpinnerPreferenceBodyState extends State<_SpinnerPreferenceBody> {
  final GlobalKey _anchorKey = GlobalKey();
  bool _expanded = false;
  bool _holdDown = false;
  Rect _anchorBounds = Rect.zero;

  bool get _isDialogMode => widget.dialogButtonString != null;

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
    // 弹窗模式需要锚点矩形用于定位；对话框模式居中展示，无需锚点。
    if (!_isDialogMode && !_expanded) {
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
    // 对话框模式默认取 dialogDropdownColors，弹窗模式默认取 dropdownColors。
    final colors = widget.spinnerColors ??
        (_isDialogMode
            ? MiuixDropdownDefaults.dialogDropdownColors(context)
            : MiuixDropdownDefaults.dropdownColors(context));
    final theme = MiuixTheme.of(context);
    final actionColor = _actualEnabled
        ? theme.colors.onSurfaceVariantActions
        : theme.colors.disabledOnSecondaryVariant;

    final Widget overlay = _hasEntries
        ? (_isDialogMode
            ? (widget.windowLevel
                ? MiuixWindowDropdownDialog.entries(
                    key: const ValueKey<String>('spinner-pref-dialog'),
                    entries: _nonEmptyEntries,
                    title: widget.title,
                    dialogButtonString: widget.dialogButtonString!,
                    show: _expanded,
                    onDismiss: _onDismiss,
                    onDismissFinished: _onDismissFinished,
                    dropdownColors: colors,
                    collapseOnSelection: _collapse,
                  )
                : MiuixOverlayDropdownDialog.entries(
                    key: const ValueKey<String>('spinner-pref-dialog'),
                    entries: _nonEmptyEntries,
                    title: widget.title,
                    dialogButtonString: widget.dialogButtonString!,
                    show: _expanded,
                    onDismiss: _onDismiss,
                    onDismissFinished: _onDismissFinished,
                    dropdownColors: colors,
                    renderInRootScaffold: widget.renderInRootScaffold,
                    collapseOnSelection: _collapse,
                  ))
            : (widget.windowLevel
                ? MiuixWindowDropdownPopup.entries(
                    key: const ValueKey<String>('spinner-pref-popup'),
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
                    key: const ValueKey<String>('spinner-pref-popup'),
                    entries: _nonEmptyEntries,
                    show: _expanded,
                    anchorBounds: _anchorBounds,
                    onDismiss: _onDismiss,
                    onDismissFinished: _onDismissFinished,
                    maxHeight: widget.maxHeight,
                    dropdownColors: colors,
                    renderInRootScaffold: widget.renderInRootScaffold,
                    collapseOnSelection: _collapse,
                  )))
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
        overlay,
      ],
      bottomAction: widget.bottomAction,
      onClick: _actualEnabled ? _handleClick : null,
      role: MiuixBasicComponentRole.dropdownList,
      holdDownState: _holdDown,
      enabled: _actualEnabled,
    );
  }
}
