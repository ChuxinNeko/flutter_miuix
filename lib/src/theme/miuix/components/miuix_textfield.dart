// Miuix Flutter 移植版 - TextField
// 源自 compose-miuix-ui/miuix 的 TextField.kt。
// 浮动标签、聚焦时 squircle 边框动画、leading/trailing icon。
// SPDX-License-Identifier: Apache-2.0

import 'dart:ui';

import 'package:flutter/material.dart';

import '../foundation/miuix_squircle.dart';
import '../theme/miuix_theme.dart';

/// TextField 颜色配置。对应 Kotlin `TextFieldColors`。
@immutable
class MiuixTextFieldColors {
  const MiuixTextFieldColors({
    required this.backgroundColor,
    required this.labelColor,
    required this.borderColor,
  });

  /// 背景色。对应 Kotlin `backgroundColor`，默认 `secondaryContainer`。
  final Color backgroundColor;

  /// 标签色。对应 Kotlin `labelColor`，默认 `onSecondaryContainer`。
  final Color labelColor;

  /// 聚焦边框色。对应 Kotlin `borderColor`，默认 `primary`。
  final Color borderColor;
}

class MiuixTextFieldDefaults {
  MiuixTextFieldDefaults._();

  /// 默认圆角。
  static const double cornerRadius = 16;

  /// 默认内边距（水平/垂直）。
  static const EdgeInsets insideMargin = EdgeInsets.all(16);

  /// 聚焦时边框宽度。
  static const double borderWidth = 2;

  /// 标签浮动时字号。
  static const double labelFontSizeFloating = 10;

  /// 标签正常时字号。
  static const double labelFontSizeNormal = 17;

  static MiuixTextFieldColors textFieldColors(BuildContext context) {
    final c = MiuixTheme.of(context).colors;
    return MiuixTextFieldColors(
      backgroundColor: c.secondaryContainer,
      labelColor: c.onSecondaryContainer,
      borderColor: c.primary,
    );
  }
}

/// 标签动画状态。对应 Kotlin `LabelAnimState`。
enum _LabelAnimState { hidden, placeholder, normal, floating }

/// Miuix 风格的文本输入框。对应 Kotlin `TextField`。
class MiuixTextField extends StatefulWidget {
  const MiuixTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.label = '',
    this.useLabelAsPlaceholder = false,
    this.enabled = true,
    this.readOnly = false,
    this.textStyle,
    this.leadingIcon,
    this.trailingIcon,
    this.singleLine = false,
    this.maxLines,
    this.minLines,
    this.colors,
    this.cornerRadius = MiuixTextFieldDefaults.cornerRadius,
    this.insideMargin = MiuixTextFieldDefaults.insideMargin,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
    this.obscureText = false,
    this.cursorColor,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String label;
  final bool useLabelAsPlaceholder;
  final bool enabled;
  final bool readOnly;
  final TextStyle? textStyle;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool singleLine;
  final int? maxLines;
  final int? minLines;
  final MiuixTextFieldColors? colors;
  final double cornerRadius;
  final EdgeInsets insideMargin;
  final TextInputType? keyboardType;

  /// 键盘 action 按钮类型。对应 Kotlin `keyboardOptions.imeAction`。
  final TextInputAction? textInputAction;

  /// 输入大小写策略。对应 Kotlin `keyboardOptions.capitalization`。
  final TextCapitalization textCapitalization;

  /// 键盘 action 触发时回调。对应 Kotlin `onKeyboardAction` / `keyboardActions`。
  final ValueChanged<String>? onSubmitted;

  final bool obscureText;
  final Color? cursorColor;

  /// 挂载后是否自动聚焦并唤起键盘（常用于对话框内的输入框）。
  final bool autofocus;

  @override
  State<MiuixTextField> createState() => _MiuixTextFieldState();
}

class _MiuixTextFieldState extends State<MiuixTextField>
    with TickerProviderStateMixin {
  late final AnimationController _labelController;
  late final AnimationController _borderController;

  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;

  TextEditingController get _controller =>
      widget.controller ?? _internalController!;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    // 必须先创建内部 controller / focusNode，因为下方 _isFloating 会访问 _controller.text。
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
    _labelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: _isFloating ? 1.0 : 0.0,
    );
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      value: 0.0,
    );
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(MiuixTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      if (widget.controller == null && _internalController == null) {
        _internalController = TextEditingController();
      }
      _controller.addListener(_onTextChanged);
      _onTextChanged();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      if (widget.focusNode == null && _internalFocusNode == null) {
        _internalFocusNode = FocusNode();
      }
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _labelController.dispose();
    _borderController.dispose();
    _internalController?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  _LabelAnimState get _labelState {
    final text = _controller.text;
    if (widget.label.isEmpty) return _LabelAnimState.hidden;
    if (widget.useLabelAsPlaceholder && text.isNotEmpty) {
      return _LabelAnimState.placeholder;
    }
    if (text.isNotEmpty) return _LabelAnimState.floating;
    return _LabelAnimState.normal;
  }

  bool get _isFloating => _labelState == _LabelAnimState.floating;

  /// 是否显示标签。对应 Kotlin `labelState != Hidden && != Placeholder`。
  bool get _showLabel =>
      _labelState == _LabelAnimState.normal ||
      _labelState == _LabelAnimState.floating;

  void _onTextChanged() {
    final shouldFloat = _isFloating;
    if (shouldFloat && _labelController.value != 1.0) {
      _labelController.forward();
    } else if (!shouldFloat && _labelController.value != 0.0) {
      _labelController.reverse();
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _borderController.forward();
    } else {
      _borderController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        widget.colors ?? MiuixTextFieldDefaults.textFieldColors(context);
    final theme = MiuixTheme.of(context);
    final baseStyle = widget.textStyle ?? theme.textStyles.main;
    final textStyle = baseStyle.copyWith(color: theme.colors.onBackground);
    final cursorColor = widget.cursorColor ?? colors.borderColor;

    return AnimatedBuilder(
      animation: Listenable.merge([_labelController, _borderController]),
      builder: (context, _) {
        final labelProgress = _labelController.value;
        final borderProgress = _borderController.value;
        final borderWidth = borderProgress * MiuixTextFieldDefaults.borderWidth;
        final borderColor = Color.lerp(
                colors.backgroundColor, colors.borderColor, borderProgress)!;

        return GestureDetector(
          // 整块区域可点击聚焦（对应 Compose 版整个输入框可点）：背景、内边距、
          // 非交互图标区域点击均唤起键盘。内部 TextField / trailing 按钮等更深层
          // 的手势在竞技场中优先，不受影响。
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled
              ? () {
                  if (!_focusNode.hasFocus) _focusNode.requestFocus();
                }
              : null,
          child: DecoratedBox(
          decoration: ShapeDecoration(
            color: colors.backgroundColor,
            shape: MiuixSquircleBorder(
              cornerRadius: widget.cornerRadius,
              side: borderWidth > 0
                  ? BorderSide(color: borderColor, width: borderWidth)
                  : BorderSide.none,
            ),
          ),
          child: Padding(
            // insideMargin 语义为“每侧”边距（对应 Kotlin DpSize.height/width，
            // 均为单侧值 16）。故取 .top/.bottom 单侧值，不能用 .vertical
            // （=top+bottom=32），否则上下各 padding 32 → 高度翻倍。
            padding: EdgeInsets.only(
              top: widget.insideMargin.top,
              bottom: widget.insideMargin.bottom,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.leadingIcon != null) widget.leadingIcon!,
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      // 单侧值：用 .left/.right，不能用 .horizontal（=left+right）。
                      left: widget.leadingIcon != null
                          ? 0
                          : widget.insideMargin.left,
                      right: widget.trailingIcon != null
                          ? 0
                          : widget.insideMargin.right,
                    ),
                    child: _buildTextArea(
                      textStyle: textStyle,
                      cursorColor: cursorColor,
                      labelColor: colors.labelColor,
                      labelProgress: labelProgress,
                    ),
                  ),
                ),
                if (widget.trailingIcon != null) widget.trailingIcon!,
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildTextArea({
    required TextStyle textStyle,
    required Color cursorColor,
    required Color labelColor,
    required double labelProgress,
  }) {
    // 对应 Kotlin insideMargin.height / 2（单侧值的一半 = 8）。
    final floatOffset = widget.insideMargin.top / 2 * labelProgress;
    final labelFontSize = lerpDouble(
      MiuixTextFieldDefaults.labelFontSizeNormal,
      MiuixTextFieldDefaults.labelFontSizeFloating,
      labelProgress,
    )!;

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        // 输入框：Floating 时下移，腾出标签空间
        Padding(
          padding: EdgeInsets.only(top: floatOffset),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            style: textStyle,
            cursorColor: cursorColor,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            obscureText: widget.obscureText,
            // obscureText 时 Flutter 强制要求 maxLines=1；singleLine 也强制单行。
            maxLines: (widget.singleLine || widget.obscureText)
                ? 1
                : widget.maxLines,
            minLines: widget.minLines,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
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
        // 标签：Floating 时上移。必须 IgnorePointer——RenderParagraph 参与命中
        // 测试且 Stack 命中即止，否则占位/标签文字会吞掉点击，点在文字上
        // 无法聚焦唤起键盘。
        if (_showLabel)
          IgnorePointer(
            child: Transform.translate(
              offset: Offset(0, -floatOffset),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: labelFontSize,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
