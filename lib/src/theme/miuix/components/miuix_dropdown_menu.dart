// Miuix Flutter 移植版 - DropdownMenu / IconDropdownMenu
// 源自 compose-miuix-ui/miuix-preference 的 menu/OverlayDropdownMenu.kt、
// menu/WindowDropdownMenu.kt、menu/OverlayIconDropdownMenu.kt、
// menu/WindowIconDropdownMenu.kt。
// 以 BasicComponent / IconButton 为触发器，展开时测量锚点 Rect 并交给
// 已移植的 MiuixOverlayDropdownPopup / MiuixWindowDropdownPopup。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/miuix_theme.dart';
import 'miuix_basic_component.dart';
import 'miuix_dropdown.dart';
import 'miuix_dropdown_popup.dart';
import 'miuix_icon_button.dart';

/// Scaffold 内下拉菜单（单分组）。对应 Kotlin `OverlayDropdownMenu(entry)`。
class MiuixOverlayDropdownMenu extends StatelessWidget {
  const MiuixOverlayDropdownMenu({
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
    this.renderInRootScaffold = true,
    this.collapseOnSelection = true,
    this.onExpandedChange,
  }) : entries = const <MiuixDropdownEntry>[];

  /// Scaffold 内下拉菜单（多分组）。对应 Kotlin `OverlayDropdownMenu(entries)`。
  const MiuixOverlayDropdownMenu.entries({
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
    this.renderInRootScaffold = true,
    this.collapseOnSelection,
    this.onExpandedChange,
  }) : entry = null;

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
  final bool renderInRootScaffold;
  final bool? collapseOnSelection;
  final ValueChanged<bool>? onExpandedChange;

  List<MiuixDropdownEntry> get effectiveEntries =>
      entry != null ? <MiuixDropdownEntry>[entry!] : entries;

  @override
  Widget build(BuildContext context) {
    return _DropdownMenuBody(
      entries: effectiveEntries,
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
      collapseOnSelection: collapseOnSelection,
      onExpandedChange: onExpandedChange,
      windowLevel: false,
      renderInRootScaffold: renderInRootScaffold,
      useIconButton: false,
    );
  }
}

/// 窗口级下拉菜单（单分组）。对应 Kotlin `WindowDropdownMenu(entry)`。
class MiuixWindowDropdownMenu extends StatelessWidget {
  const MiuixWindowDropdownMenu({
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
    this.collapseOnSelection = true,
    this.onExpandedChange,
  }) : entries = const <MiuixDropdownEntry>[];

  /// 窗口级下拉菜单（多分组）。对应 Kotlin `WindowDropdownMenu(entries)`。
  const MiuixWindowDropdownMenu.entries({
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
    this.collapseOnSelection,
    this.onExpandedChange,
  }) : entry = null;

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
  final bool? collapseOnSelection;
  final ValueChanged<bool>? onExpandedChange;

  List<MiuixDropdownEntry> get effectiveEntries =>
      entry != null ? <MiuixDropdownEntry>[entry!] : entries;

  @override
  Widget build(BuildContext context) {
    return _DropdownMenuBody(
      entries: effectiveEntries,
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
      collapseOnSelection: collapseOnSelection,
      onExpandedChange: onExpandedChange,
      windowLevel: true,
      renderInRootScaffold: true,
      useIconButton: false,
    );
  }
}

/// Scaffold 内图标下拉菜单（单分组）。对应 Kotlin `OverlayIconDropdownMenu(entry)`。
class MiuixOverlayIconDropdownMenu extends StatelessWidget {
  const MiuixOverlayIconDropdownMenu({
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

  /// Scaffold 内图标下拉菜单（多分组）。对应 Kotlin `OverlayIconDropdownMenu(entries)`。
  const MiuixOverlayIconDropdownMenu.entries({
    super.key,
    required this.entries,
    this.enabled = true,
    this.maxHeight,
    this.dropdownColors,
    this.renderInRootScaffold = true,
    this.collapseOnSelection,
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
  final bool? collapseOnSelection;
  final ValueChanged<bool>? onExpandedChange;
  final Color? backgroundColor;
  final double cornerRadius;
  final double minHeight;
  final double minWidth;
  final Widget child;

  List<MiuixDropdownEntry> get effectiveEntries =>
      entry != null ? <MiuixDropdownEntry>[entry!] : entries;

  @override
  Widget build(BuildContext context) {
    return _DropdownMenuBody(
      entries: effectiveEntries,
      maxHeight: maxHeight,
      enabled: enabled,
      collapseOnSelection: collapseOnSelection,
      onExpandedChange: onExpandedChange,
      dropdownColors: dropdownColors,
      windowLevel: false,
      renderInRootScaffold: renderInRootScaffold,
      useIconButton: true,
      iconButtonBackgroundColor: backgroundColor,
      iconButtonCornerRadius: cornerRadius,
      iconButtonMinHeight: minHeight,
      iconButtonMinWidth: minWidth,
      iconButtonChild: child,
    );
  }
}

/// 窗口级图标下拉菜单（单分组）。对应 Kotlin `WindowIconDropdownMenu(entry)`。
class MiuixWindowIconDropdownMenu extends StatelessWidget {
  const MiuixWindowIconDropdownMenu({
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

  /// 窗口级图标下拉菜单（多分组）。对应 Kotlin `WindowIconDropdownMenu(entries)`。
  const MiuixWindowIconDropdownMenu.entries({
    super.key,
    required this.entries,
    this.enabled = true,
    this.maxHeight,
    this.dropdownColors,
    this.collapseOnSelection,
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
  final bool? collapseOnSelection;
  final ValueChanged<bool>? onExpandedChange;
  final Color? backgroundColor;
  final double cornerRadius;
  final double minHeight;
  final double minWidth;
  final Widget child;

  List<MiuixDropdownEntry> get effectiveEntries =>
      entry != null ? <MiuixDropdownEntry>[entry!] : entries;

  @override
  Widget build(BuildContext context) {
    return _DropdownMenuBody(
      entries: effectiveEntries,
      maxHeight: maxHeight,
      enabled: enabled,
      collapseOnSelection: collapseOnSelection,
      onExpandedChange: onExpandedChange,
      dropdownColors: dropdownColors,
      windowLevel: true,
      renderInRootScaffold: true,
      useIconButton: true,
      iconButtonBackgroundColor: backgroundColor,
      iconButtonCornerRadius: cornerRadius,
      iconButtonMinHeight: minHeight,
      iconButtonMinWidth: minWidth,
      iconButtonChild: child,
    );
  }
}

class _DropdownMenuBody extends StatefulWidget {
  const _DropdownMenuBody({
    required this.entries,
    this.title,
    this.titleColor,
    this.summary,
    this.summaryColor,
    this.dropdownColors,
    this.startAction,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.maxHeight,
    this.enabled = true,
    this.collapseOnSelection,
    this.onExpandedChange,
    required this.windowLevel,
    required this.renderInRootScaffold,
    required this.useIconButton,
    this.iconButtonBackgroundColor,
    this.iconButtonCornerRadius = MiuixIconButtonDefaults.cornerRadius,
    this.iconButtonMinHeight = MiuixIconButtonDefaults.minHeight,
    this.iconButtonMinWidth = MiuixIconButtonDefaults.minWidth,
    this.iconButtonChild,
  });

  final List<MiuixDropdownEntry> entries;
  final String? title;
  final MiuixBasicComponentColors? titleColor;
  final String? summary;
  final MiuixBasicComponentColors? summaryColor;
  final MiuixDropdownColors? dropdownColors;
  final Widget? startAction;
  final Widget? bottomAction;
  final EdgeInsetsGeometry insideMargin;
  final double? maxHeight;
  final bool enabled;
  final bool? collapseOnSelection;
  final ValueChanged<bool>? onExpandedChange;
  final bool windowLevel;
  final bool renderInRootScaffold;
  final bool useIconButton;
  final Color? iconButtonBackgroundColor;
  final double iconButtonCornerRadius;
  final double iconButtonMinHeight;
  final double iconButtonMinWidth;
  final Widget? iconButtonChild;

  @override
  State<_DropdownMenuBody> createState() => _DropdownMenuBodyState();
}

class _DropdownMenuBodyState extends State<_DropdownMenuBody> {
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
      // 展开前测量锚点位置
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
    final colors = widget.dropdownColors ??
        MiuixDropdownDefaults.dropdownColors(context);
    final theme = MiuixTheme.of(context);
    final actionColor = _actualEnabled
        ? theme.colors.onSurfaceVariantActions
        : theme.colors.disabledOnSecondaryVariant;

    final Widget popup = _hasEntries
        ? (widget.windowLevel
            ? MiuixWindowDropdownPopup.entries(
                key: const ValueKey<String>('dropdown-popup'),
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
                key: const ValueKey<String>('dropdown-popup'),
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

    if (widget.useIconButton) {
      return Stack(
        key: _anchorKey,
        children: <Widget>[
          MiuixIconButton(
            onPressed: _actualEnabled ? _handleClick : null,
            enabled: _actualEnabled,
            holdDownState: _holdDown,
            backgroundColor: widget.iconButtonBackgroundColor,
            cornerRadius: widget.iconButtonCornerRadius,
            minHeight: widget.iconButtonMinHeight,
            minWidth: widget.iconButtonMinWidth,
            child: widget.iconButtonChild!,
          ),
          popup,
        ],
      );
    }

    return MiuixBasicComponent(
      key: _anchorKey,
      insideMargin: widget.insideMargin,
      title: widget.title,
      titleColor: widget.titleColor,
      summary: widget.summary,
      summaryColor: widget.summaryColor,
      startAction: widget.startAction,
      endActions: <Widget>[
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
