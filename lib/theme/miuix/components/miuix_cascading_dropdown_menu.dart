// Miuix Flutter 移植版 - IconCascadingDropdownMenu
// 源自 compose-miuix-ui/miuix-preference 的 menu/OverlayIconCascadingDropdownMenu.kt、
// menu/WindowIconCascadingDropdownMenu.kt。
// 以 IconButton 为触发器，展开时测量锚点 Rect 并交给已移植的
// MiuixOverlayCascadingListPopup / MiuixWindowCascadingListPopup。
// 子项 [MiuixDropdownItem.children] 非空时成为子菜单触发器，级联深度限制为 2。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'miuix_cascading_list_popup.dart';
import 'miuix_dropdown.dart';
import 'miuix_icon_button.dart';

/// Scaffold 内图标级联下拉菜单（单分组）。对应 Kotlin `OverlayIconCascadingDropdownMenu(entry)`。
class MiuixOverlayIconCascadingDropdownMenu extends StatelessWidget {
  const MiuixOverlayIconCascadingDropdownMenu({
    super.key,
    required this.entry,
    this.enabled = true,
    this.maxHeight,
    this.dropdownColors,
    this.renderInRootScaffold = true,
    this.collapseOnSelection = true,
    this.onExpandedChange,
    this.backgroundColor,
    this.cornerRadius = MiuixIconButtonDefaults.cornerRadius,
    this.minHeight = MiuixIconButtonDefaults.minHeight,
    this.minWidth = MiuixIconButtonDefaults.minWidth,
    required this.child,
  }) : entries = const <MiuixDropdownEntry>[];

  /// Scaffold 内图标级联下拉菜单（多分组）。对应 Kotlin `OverlayIconCascadingDropdownMenu(entries)`。
  const MiuixOverlayIconCascadingDropdownMenu.entries({
    super.key,
    required this.entries,
    this.enabled = true,
    this.maxHeight,
    this.dropdownColors,
    this.renderInRootScaffold = true,
    this.collapseOnSelection = true,
    this.onExpandedChange,
    this.backgroundColor,
    this.cornerRadius = MiuixIconButtonDefaults.cornerRadius,
    this.minHeight = MiuixIconButtonDefaults.minHeight,
    this.minWidth = MiuixIconButtonDefaults.minWidth,
    required this.child,
  }) : entry = null;

  final MiuixDropdownEntry? entry;
  final List<MiuixDropdownEntry> entries;
  final bool enabled;
  final double? maxHeight;
  final MiuixDropdownColors? dropdownColors;
  final bool renderInRootScaffold;
  final bool collapseOnSelection;
  final ValueChanged<bool>? onExpandedChange;
  final Color? backgroundColor;
  final double cornerRadius;
  final double minHeight;
  final double minWidth;
  final Widget child;

  List<MiuixDropdownEntry> get effectiveEntries =>
      entry != null ? <MiuixDropdownEntry>[entry!] : entries;

  @override
  Widget build(BuildContext context) => _CascadingDropdownMenuBody(
    entries: effectiveEntries,
    enabled: enabled,
    maxHeight: maxHeight,
    dropdownColors: dropdownColors,
    collapseOnSelection: collapseOnSelection,
    onExpandedChange: onExpandedChange,
    windowLevel: false,
    renderInRootScaffold: renderInRootScaffold,
    backgroundColor: backgroundColor,
    cornerRadius: cornerRadius,
    minHeight: minHeight,
    minWidth: minWidth,
    child: child,
  );
}

/// 窗口级图标级联下拉菜单（单分组）。对应 Kotlin `WindowIconCascadingDropdownMenu(entry)`。
class MiuixWindowIconCascadingDropdownMenu extends StatelessWidget {
  const MiuixWindowIconCascadingDropdownMenu({
    super.key,
    required this.entry,
    this.enabled = true,
    this.maxHeight,
    this.dropdownColors,
    this.collapseOnSelection = true,
    this.onExpandedChange,
    this.backgroundColor,
    this.cornerRadius = MiuixIconButtonDefaults.cornerRadius,
    this.minHeight = MiuixIconButtonDefaults.minHeight,
    this.minWidth = MiuixIconButtonDefaults.minWidth,
    required this.child,
  }) : entries = const <MiuixDropdownEntry>[];

  /// 窗口级图标级联下拉菜单（多分组）。对应 Kotlin `WindowIconCascadingDropdownMenu(entries)`。
  const MiuixWindowIconCascadingDropdownMenu.entries({
    super.key,
    required this.entries,
    this.enabled = true,
    this.maxHeight,
    this.dropdownColors,
    this.collapseOnSelection = true,
    this.onExpandedChange,
    this.backgroundColor,
    this.cornerRadius = MiuixIconButtonDefaults.cornerRadius,
    this.minHeight = MiuixIconButtonDefaults.minHeight,
    this.minWidth = MiuixIconButtonDefaults.minWidth,
    required this.child,
  }) : entry = null;

  final MiuixDropdownEntry? entry;
  final List<MiuixDropdownEntry> entries;
  final bool enabled;
  final double? maxHeight;
  final MiuixDropdownColors? dropdownColors;
  final bool collapseOnSelection;
  final ValueChanged<bool>? onExpandedChange;
  final Color? backgroundColor;
  final double cornerRadius;
  final double minHeight;
  final double minWidth;
  final Widget child;

  List<MiuixDropdownEntry> get effectiveEntries =>
      entry != null ? <MiuixDropdownEntry>[entry!] : entries;

  @override
  Widget build(BuildContext context) => _CascadingDropdownMenuBody(
    entries: effectiveEntries,
    enabled: enabled,
    maxHeight: maxHeight,
    dropdownColors: dropdownColors,
    collapseOnSelection: collapseOnSelection,
    onExpandedChange: onExpandedChange,
    windowLevel: true,
    renderInRootScaffold: true,
    backgroundColor: backgroundColor,
    cornerRadius: cornerRadius,
    minHeight: minHeight,
    minWidth: minWidth,
    child: child,
  );
}

class _CascadingDropdownMenuBody extends StatefulWidget {
  const _CascadingDropdownMenuBody({
    required this.entries,
    required this.enabled,
    required this.maxHeight,
    required this.dropdownColors,
    required this.collapseOnSelection,
    required this.onExpandedChange,
    required this.windowLevel,
    required this.renderInRootScaffold,
    required this.backgroundColor,
    required this.cornerRadius,
    required this.minHeight,
    required this.minWidth,
    required this.child,
  });

  final List<MiuixDropdownEntry> entries;
  final bool enabled;
  final double? maxHeight;
  final MiuixDropdownColors? dropdownColors;
  final bool collapseOnSelection;
  final ValueChanged<bool>? onExpandedChange;
  final bool windowLevel;
  final bool renderInRootScaffold;
  final Color? backgroundColor;
  final double cornerRadius;
  final double minHeight;
  final double minWidth;
  final Widget child;

  @override
  State<_CascadingDropdownMenuBody> createState() =>
      _CascadingDropdownMenuBodyState();
}

class _CascadingDropdownMenuBodyState
    extends State<_CascadingDropdownMenuBody> {
  final GlobalKey _anchorKey = GlobalKey();
  bool _expanded = false;
  bool _holdDown = false;
  Rect _anchorBounds = Rect.zero;

  List<MiuixDropdownEntry> get _nonEmptyEntries =>
      widget.entries.where((e) => e.items.isNotEmpty).toList(growable: false);

  bool get _hasEntries => _nonEmptyEntries.isNotEmpty;
  bool get _actualEnabled => widget.enabled && _hasEntries;

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

  @override
  Widget build(BuildContext context) {
    final Widget popup = _hasEntries
        ? (widget.windowLevel
            ? MiuixWindowCascadingListPopup(
                key: const ValueKey<String>('cascading-popup'),
                show: _expanded,
                anchorBounds: _anchorBounds,
                entries: _nonEmptyEntries,
                onDismissRequest: _onDismiss,
                onDismissFinished: _onDismissFinished,
                maxHeight: widget.maxHeight,
                dropdownColors: widget.dropdownColors,
                collapseOnSelection: widget.collapseOnSelection,
              )
            : MiuixOverlayCascadingListPopup(
                key: const ValueKey<String>('cascading-popup'),
                show: _expanded,
                anchorBounds: _anchorBounds,
                entries: _nonEmptyEntries,
                onDismissRequest: _onDismiss,
                onDismissFinished: _onDismissFinished,
                maxHeight: widget.maxHeight,
                dropdownColors: widget.dropdownColors,
                renderInRootScaffold: widget.renderInRootScaffold,
                collapseOnSelection: widget.collapseOnSelection,
              ))
        : const SizedBox.shrink();

    return Stack(
      key: _anchorKey,
      children: <Widget>[
        MiuixIconButton(
          onPressed: _actualEnabled ? _handleClick : null,
          enabled: _actualEnabled,
          holdDownState: _holdDown,
          backgroundColor: widget.backgroundColor,
          cornerRadius: widget.cornerRadius,
          minHeight: widget.minHeight,
          minWidth: widget.minWidth,
          child: widget.child,
        ),
        popup,
      ],
    );
  }
}
