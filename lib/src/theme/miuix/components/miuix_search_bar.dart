// Miuix Flutter 移植版 - SearchBar
// 源自 compose-miuix-ui/miuix 的 SearchBar.kt。
// 胶囊使用 StadiumBorder（非 squircle）；PopScope 处理返回，省略 Android 26-27 原生焦点补丁。
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:flutter/material.dart';

import '../foundation/miuix_content_color.dart';
import '../icon/miuix_basic_icons.dart';
import '../theme/miuix_text_styles.dart';
import '../theme/miuix_theme.dart';
import 'miuix_icon.dart';

/// 对应 Kotlin `SearchBarDefaults` 的默认值。
class MiuixSearchBarDefaults {
  MiuixSearchBarDefaults._();

  static const EdgeInsets insideMargin = EdgeInsets.symmetric(horizontal: 12);
  static const double inputFieldMinHeight = 45;
  static const double inputFieldFontSize = 17;
  static const double leadingIconStartPadding = 16;
  static const double leadingIconEndPadding = 8;
  static const double trailingIconStartPadding = 8;
  static const double trailingIconEndPadding = 16;
  static const Duration visibilityDuration = Duration(milliseconds: 275);
  static const Duration textFadeDuration = Duration(milliseconds: 150);
}

/// 对应 Kotlin `SearchBar` 的搜索栏容器。
///
/// [expanded] 时显示尾部动作与结果内容，并拦截系统返回以先收起搜索栏。
class MiuixSearchBar extends StatelessWidget {
  const MiuixSearchBar({
    super.key,
    required this.inputField,
    required this.onExpandedChange,
    required this.content,
    this.insideMargin = MiuixSearchBarDefaults.insideMargin,
    this.expanded = false,
    this.outsideEndAction,
  });

  final Widget inputField;
  final ValueChanged<bool> onExpandedChange;
  final Widget content;
  final EdgeInsets insideMargin;
  final bool expanded;
  final Widget? outsideEndAction;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !expanded,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && expanded) onExpandedChange(false);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(padding: insideMargin, child: inputField),
              ),
              if (outsideEndAction != null)
                ClipRect(
                  child: AnimatedAlign(
                    duration: MiuixSearchBarDefaults.visibilityDuration,
                    curve: Curves.easeOut,
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: expanded ? 1 : 0,
                    child: AnimatedSlide(
                      duration: MiuixSearchBarDefaults.visibilityDuration,
                      curve: Curves.easeOut,
                      offset: expanded ? Offset.zero : const Offset(1, 0),
                      child: outsideEndAction,
                    ),
                  ),
                ),
            ],
          ),
          ClipRect(
            child: AnimatedAlign(
              duration: MiuixSearchBarDefaults.visibilityDuration,
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              heightFactor: expanded ? 1 : 0,
              child: AnimatedOpacity(
                duration: MiuixSearchBarDefaults.visibilityDuration,
                curve: Curves.easeOut,
                opacity: expanded ? 1 : 0,
                child: content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 对应 Kotlin `InputField` 的 Miuix 搜索输入框。
class MiuixInputField extends StatefulWidget {
  const MiuixInputField({
    super.key,
    required this.query,
    required this.onQueryChange,
    required this.onSearch,
    required this.expanded,
    required this.onExpandedChange,
    this.label = '',
    this.enabled = true,
    this.textStyle,
    this.color,
    this.leadingIcon,
    this.trailingIcon,
    this.focusNode,
  });

  final String query;
  final ValueChanged<String> onQueryChange;
  final ValueChanged<String> onSearch;
  final bool expanded;
  final ValueChanged<bool> onExpandedChange;
  final String label;
  final bool enabled;
  final TextStyle? textStyle;
  final Color? color;
  final Widget? leadingIcon;

  /// 自定义尾图标；null 时使用带淡入淡出的默认清除按钮。
  final Widget? trailingIcon;
  final FocusNode? focusNode;

  @override
  State<MiuixInputField> createState() => _MiuixInputFieldState();
}

class _MiuixInputFieldState extends State<MiuixInputField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late final AnimationController _textAlpha;
  // 持久化 controller：绝不每帧重建，否则会丢弃 IME 的 composing 区，导致中文
  // 等合成输入被反复重新插入（如输入 "ji" 变成 "jjijiji"）。外部 query 仅在与
  // 当前文本不同时才覆盖（见 didUpdateWidget），合成期间不打断。
  late final TextEditingController _controller;
  Timer? _collapseTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
    _textAlpha = AnimationController(
      vsync: this,
      duration: MiuixSearchBarDefaults.textFadeDuration,
      value: 1,
    );
    if (widget.expanded) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNode.requestFocus(),
      );
    }
  }

  @override
  void didUpdateWidget(MiuixInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 仅当外部 query 与字段当前文本不同才覆盖（程序化置入 / 清空 / 折叠）。
    // 用户正在输入时 query 与 _controller.text 相等，跳过覆盖以保住 composing。
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      if (oldWidget.focusNode == null) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }
    if (oldWidget.expanded != widget.expanded) {
      _collapseTimer?.cancel();
      if (widget.expanded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focusNode.requestFocus();
        });
      } else if (_focusNode.hasFocus) {
        _collapseTimer = Timer(const Duration(milliseconds: 100), _collapse);
      }
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) widget.onExpandedChange(true);
  }

  Future<void> _collapse() async {
    if (!mounted) return;
    if (widget.query.isNotEmpty) {
      await _textAlpha.animateTo(0, curve: Curves.fastOutSlowIn);
      if (!mounted) return;
      widget.onQueryChange('');
      _textAlpha.value = 1;
    }
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    _textAlpha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final foreground = MiuixContentColor.of(context);
    final inputStyle = theme.textStyles.main
        .copyWith(fontWeight: FontWeight.w500)
        .merge(widget.textStyle)
        .copyWith(color: foreground)
        .withMiuixWeight(theme.fontWeightAdjustment);
    final labelStyle =
        const TextStyle(
              fontSize: MiuixSearchBarDefaults.inputFieldFontSize,
              fontWeight: FontWeight.w500,
            )
            .merge(widget.textStyle)
            .copyWith(color: theme.colors.onSurfaceContainerHigh)
            .withMiuixWeight(theme.fontWeightAdjustment);
    final showLabel = widget.query.isEmpty && !widget.expanded;

    final leading =
        widget.leadingIcon ??
        MiuixIcon(
          vector: MiuixIcons.basic.search,
          tint: theme.colors.onSurfaceContainerHigh,
          contentDescription: 'Search',
        );
    final trailing =
        widget.trailingIcon ??
        AnimatedSwitcher(
          duration: MiuixSearchBarDefaults.visibilityDuration,
          child: widget.query.isEmpty
              ? const SizedBox.shrink(key: ValueKey(false))
              : Semantics(
                  key: const ValueKey(true),
                  button: true,
                  label: '清除搜索',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.enabled
                        ? () => widget.onQueryChange('')
                        : null,
                    child: MiuixIcon(
                      vector: MiuixIcons.basic.searchCleanup,
                      tint: theme.colors.onSurfaceContainerHighest,
                      contentDescription: 'Search Cleanup',
                    ),
                  ),
                ),
        );

    return Semantics(
      enabled: widget.enabled,
      textField: true,
      onTap: widget.enabled ? _focusNode.requestFocus : null,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: widget.color ?? theme.colors.surfaceContainerHigh,
          shape: const StadiumBorder(),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: MiuixSearchBarDefaults.leadingIconStartPadding,
                end: MiuixSearchBarDefaults.leadingIconEndPadding,
              ),
              child: leading,
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: MiuixSearchBarDefaults.inputFieldMinHeight,
                ),
                child: Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    if (showLabel) Text(widget.label, style: labelStyle),
                    FadeTransition(
                      opacity: _textAlpha,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        maxLines: 1,
                        textInputAction: TextInputAction.search,
                        style: inputStyle,
                        cursorColor: theme.colors.primary,
                        onChanged: widget.onQueryChange,
                        onSubmitted: (_) => widget.onSearch(widget.query),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: MiuixSearchBarDefaults.trailingIconStartPadding,
                end: MiuixSearchBarDefaults.trailingIconEndPadding,
              ),
              child: trailing,
            ),
          ],
        ),
      ),
    );
  }
}
