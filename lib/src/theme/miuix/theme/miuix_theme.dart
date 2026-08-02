// Miuix Flutter 移植版 - 主题
// 源自 compose-miuix-ui/miuix 的 MiuixTheme.kt。
// 用 Flutter 的 InheritedWidget 替代 Compose 的 CompositionLocal。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import 'miuix_colors.dart';
import 'miuix_dynamic_colors.dart';
import 'miuix_platform_dynamic_colors.dart';
import 'miuix_text_styles.dart';

/// 不可变的 Miuix 主题数据，聚合 [colors]、[textStyles] 与 [brightness]。
@immutable
class MiuixThemeData {
  const MiuixThemeData({
    required this.colors,
    required this.textStyles,
    required this.brightness,
    this.fontWeightAdjustment = 0,
  });

  final MiuixColors colors;
  final MiuixTextStyles textStyles;
  final Brightness brightness;

  /// 全局字重偏移量（权重数值，100 为一档）。对应 Android Compose 平台自动施加的
  /// `Configuration.fontWeightAdjustment`，用于跟随系统字体粗细度。
  ///
  /// 组件在渲染文本时会把该偏移应用到最终字重上（未指定字重按 w400 处理）：
  /// +100 时正文 400→500、半粗标题 600→700、粗体标题 700→800。默认 0（不偏移）。
  /// 通常由 [MiuixSystemTheme] / [MiuixThemeController] 依据 `MediaQuery.boldText` 自动设置。
  final int fontWeightAdjustment;

  /// 浅色主题。
  factory MiuixThemeData.light({
    MiuixColors? colors,
    MiuixTextStyles? textStyles,
    int fontWeightAdjustment = 0,
  }) {
    return MiuixThemeData(
      colors: colors ?? lightColorScheme(),
      textStyles: textStyles ?? defaultTextStyles(),
      brightness: Brightness.light,
      fontWeightAdjustment: fontWeightAdjustment,
    );
  }

  /// 深色主题。
  factory MiuixThemeData.dark({
    MiuixColors? colors,
    MiuixTextStyles? textStyles,
    int fontWeightAdjustment = 0,
  }) {
    return MiuixThemeData(
      colors: colors ?? darkColorScheme(),
      textStyles: textStyles ?? defaultTextStyles(),
      brightness: Brightness.dark,
      fontWeightAdjustment: fontWeightAdjustment,
    );
  }

  /// 跟随系统亮度自动选择浅色/深色。
  factory MiuixThemeData.of(
    Brightness brightness, {
    MiuixColors? lightColors,
    MiuixColors? darkColors,
    MiuixTextStyles? textStyles,
    int fontWeightAdjustment = 0,
  }) {
    final isDark = brightness == Brightness.dark;
    return MiuixThemeData(
      colors: isDark ? (darkColors ?? darkColorScheme()) : (lightColors ?? lightColorScheme()),
      textStyles: textStyles ?? defaultTextStyles(),
      brightness: brightness,
      fontWeightAdjustment: fontWeightAdjustment,
    );
  }

  MiuixThemeData copyWith({
    MiuixColors? colors,
    MiuixTextStyles? textStyles,
    Brightness? brightness,
    int? fontWeightAdjustment,
  }) {
    return MiuixThemeData(
      colors: colors ?? this.colors,
      textStyles: textStyles ?? this.textStyles,
      brightness: brightness ?? this.brightness,
      fontWeightAdjustment: fontWeightAdjustment ?? this.fontWeightAdjustment,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MiuixThemeData &&
        other.colors == colors &&
        other.textStyles == textStyles &&
        other.brightness == brightness &&
        other.fontWeightAdjustment == fontWeightAdjustment;
  }

  @override
  int get hashCode => Object.hash(colors, textStyles, brightness, fontWeightAdjustment);
}

/// 提供 [MiuixThemeData] 给子树。对应 Kotlin 的 `MiuixTheme { ... }`。
///
/// 使用：
/// ```dart
/// MiuixTheme(
///   data: MiuixThemeData.light(),
///   child: MyApp(),
/// )
/// ```
class MiuixTheme extends InheritedWidget {
  const MiuixTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final MiuixThemeData data;

  /// 获取当前上下文的 [MiuixThemeData]。若未包裹则回退到浅色默认值。
  static MiuixThemeData of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<MiuixTheme>();
    return widget?.data ?? MiuixThemeData.light();
  }

  /// 仅读取，不建立依赖（用于不希望随主题重建的场景）。
  static MiuixThemeData? maybeOf(BuildContext context) {
    final widget =
        context.getInheritedWidgetOfExactType<MiuixTheme>();
    return widget?.data;
  }

  @override
  bool updateShouldNotify(MiuixTheme oldWidget) => data != oldWidget.data;
}

/// 一个便捷的 [Builder]，根据 [MediaData] 平台亮度自动套用浅色/深色主题。
/// 对应 Kotlin `ThemeController(ColorSchemeMode.System)` 的跟随系统行为。
class MiuixSystemTheme extends StatelessWidget {
  const MiuixSystemTheme({
    super.key,
    this.light,
    this.dark,
    this.textStyles,
    this.fontWeightAdjustment,
    this.boldTextFontWeightAdjustment = 100,
    required this.child,
  });

  /// 自定义浅色配色。默认 [lightColorScheme]。
  final MiuixColors? light;

  /// 自定义深色配色。默认 [darkColorScheme]。
  final MiuixColors? dark;

  /// 自定义文本样式。
  final MiuixTextStyles? textStyles;

  /// 显式指定全局字重偏移量（权重数值，100 为一档）。为 null（默认）时自动跟随系统
  /// `MediaQuery.boldText`：开启时加 [boldTextFontWeightAdjustment]，关闭时为 0。
  /// 见 [MiuixThemeData.fontWeightAdjustment]。
  final int? fontWeightAdjustment;

  /// 自动模式下，系统「粗体文字」开启时施加的字重偏移量，默认 +100（一档）。
  final int boldTextFontWeightAdjustment;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final adj = fontWeightAdjustment ??
        (MediaQuery.boldTextOf(context) ? boldTextFontWeightAdjustment : 0);
    return MiuixTheme(
      data: MiuixThemeData.of(
        brightness,
        lightColors: light,
        darkColors: dark,
        textStyles: textStyles,
        fontWeightAdjustment: adj,
      ),
      child: child,
    );
  }
}

/// 配色模式。对应 Kotlin `ColorSchemeMode`。
///
/// - [system]/[light]/[dark]：使用静态 light/dark 配色（跟随系统或强制）。
/// - [monetSystem]/[monetLight]/[monetDark]：动态取色（Monet）。有 keyColor 时按
///   种子生成；无 keyColor 时读平台壁纸（Android），其他平台回退固定种子。
enum MiuixColorSchemeMode {
  system,
  light,
  dark,
  monetSystem,
  monetLight,
  monetDark,
}
/// 管理并解析当前 Miuix 配色，向子树提供 [MiuixTheme]。对应 Kotlin `ThemeController`。
///
/// 按 [colorSchemeMode] 决定配色来源：
/// - system/light/dark → 直接用 [lightColors]/[darkColors]（跟随系统或强制明暗）。
/// - monet* → 动态取色：
///   - [keyColor] 非空 → 同步 [miuixColorsFromSeed]（纯 HCT 计算）。
///   - [keyColor] 为空 → 异步 [miuixPlatformDynamicColors]（Android 壁纸；其他平台回退
///     固定种子）。结果就绪前用 [miuixMonetSystemColors] 占位，避免闪烁。
///
/// 参数含义与原版一致。[isDark] 为 null 时跟随系统亮度（[MediaQuery.platformBrightnessOf]）。
class MiuixThemeController extends StatefulWidget {
  const MiuixThemeController({
    super.key,
    this.colorSchemeMode = MiuixColorSchemeMode.system,
    this.lightColors,
    this.darkColors,
    this.textStyles,
    this.fontWeightAdjustment,
    this.boldTextFontWeightAdjustment = 100,
    this.keyColor,
    this.colorSpec = MiuixThemeColorSpec.spec2021,
    this.paletteStyle = MiuixThemePaletteStyle.tonalSpot,
    this.isDark,
    required this.child,
  });

  /// 配色模式。对应 Kotlin `colorSchemeMode`。
  final MiuixColorSchemeMode colorSchemeMode;

  /// 浅色静态配色，默认 [lightColorScheme]。对应 Kotlin `lightColors`。
  final MiuixColors? lightColors;

  /// 深色静态配色，默认 [darkColorScheme]。对应 Kotlin `darkColors`。
  final MiuixColors? darkColors;

  /// 文本样式，默认 [defaultTextStyles]。
  final MiuixTextStyles? textStyles;

  /// 显式指定全局字重偏移量（权重数值，100 为一档）。为 null（默认）时自动跟随系统
  /// `MediaQuery.boldText`：开启时加 [boldTextFontWeightAdjustment]，关闭时为 0。
  /// 见 [MiuixThemeData.fontWeightAdjustment]。
  final int? fontWeightAdjustment;

  /// 自动模式下，系统「粗体文字」开启时施加的字重偏移量，默认 +100（一档）。
  final int boldTextFontWeightAdjustment;

  /// 动态取色的种子色。对应 Kotlin `keyColor`。为 null 时 monet 模式走平台壁纸取色。
  final Color? keyColor;

  /// 配色规范版本。对应 Kotlin `colorSpec`。
  final MiuixThemeColorSpec colorSpec;

  /// palette 风格。对应 Kotlin `paletteStyle`。
  final MiuixThemePaletteStyle paletteStyle;

  /// 是否深色。null 时跟随系统。对应 Kotlin `isDark`。
  final bool? isDark;

  final Widget child;

  @override
  State<MiuixThemeController> createState() => _MiuixThemeControllerState();
}

class _MiuixThemeControllerState extends State<MiuixThemeController> {
  /// 平台壁纸取色结果缓存（keyColor 为空的 monet 模式）。
  MiuixColors? _platformColors;

  /// 上次平台取色对应的 dark，用于变化时重新加载。
  bool? _platformDark;

  bool get _needsPlatform =>
      widget.keyColor == null &&
      (widget.colorSchemeMode == MiuixColorSchemeMode.monetSystem ||
          widget.colorSchemeMode == MiuixColorSchemeMode.monetLight ||
          widget.colorSchemeMode == MiuixColorSchemeMode.monetDark);

  void _maybeLoadPlatform(bool dark) {
    if (!_needsPlatform) return;
    if (_platformColors != null && _platformDark == dark) return;
    _platformDark = dark;
    miuixPlatformDynamicColors(dark: dark).then((colors) {
      if (!mounted) return;
      setState(() => _platformColors = colors);
    });
  }

  @override
  Widget build(BuildContext context) {
    final MiuixColors light = widget.lightColors ?? lightColorScheme();
    final MiuixColors dark = widget.darkColors ?? darkColorScheme();
    final bool systemDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    late final MiuixColors colors;
    late final Brightness brightness;

    switch (widget.colorSchemeMode) {
      case MiuixColorSchemeMode.system:
        final bool d = widget.isDark ?? systemDark;
        colors = d ? dark : light;
        brightness = d ? Brightness.dark : Brightness.light;
      case MiuixColorSchemeMode.light:
        colors = light;
        brightness = Brightness.light;
      case MiuixColorSchemeMode.dark:
        colors = dark;
        brightness = Brightness.dark;
      case MiuixColorSchemeMode.monetSystem:
        final bool d = widget.isDark ?? systemDark;
        brightness = d ? Brightness.dark : Brightness.light;
        colors = _resolveMonet(d);
      case MiuixColorSchemeMode.monetLight:
        brightness = Brightness.light;
        colors = _resolveMonet(false);
      case MiuixColorSchemeMode.monetDark:
        brightness = Brightness.dark;
        colors = _resolveMonet(true);
    }

    return MiuixTheme(
      data: MiuixThemeData(
        colors: colors,
        textStyles: widget.textStyles ?? defaultTextStyles(),
        brightness: brightness,
        fontWeightAdjustment: widget.fontWeightAdjustment ??
            (MediaQuery.boldTextOf(context) ? widget.boldTextFontWeightAdjustment : 0),
      ),
      child: widget.child,
    );
  }

  /// 解析 monet 模式配色：有种子同步生成；无种子用平台取色（占位+异步加载）。
  MiuixColors _resolveMonet(bool dark) {
    final Color? seed = widget.keyColor;
    if (seed != null) {
      return miuixColorsFromSeed(
        seed: seed,
        colorSpec: widget.colorSpec,
        paletteStyle: widget.paletteStyle,
        dark: dark,
      );
    }
    // 无种子：触发（或复用缓存的）平台壁纸取色；未就绪时用固定种子占位。
    _maybeLoadPlatform(dark);
    return _platformColors ?? miuixMonetSystemColors(dark: dark);
  }
}
