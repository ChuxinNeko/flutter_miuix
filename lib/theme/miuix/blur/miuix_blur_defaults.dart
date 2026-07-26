// Miuix Flutter 移植版 - Blur 默认值与颜色配置
// 源自 compose-miuix-ui/miuix 的 miuix-blur/BlurDefaults.kt。
// 定义模糊后应用的颜色调整（亮度/对比度/饱和度 + 分层 blend）与混合模式常量。
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 模糊后应用的颜色配置。对应 Kotlin `BlurColors`。
///
/// [blendColors] 按顺序叠加在模糊背景上；[brightness] 亮度调整 [-1,1]，0 无变化；
/// [contrast] 对比度乘子，1 无变化；[saturation] 饱和度乘子，1 无变化。
@immutable
class BlurColors {
  const BlurColors({
    this.blendColors = const [],
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
  });

  final List<BlendColorEntry> blendColors;
  final double brightness;
  final double contrast;
  final double saturation;

  @override
  bool operator ==(Object other) =>
      other is BlurColors &&
      listEquals(other.blendColors, blendColors) &&
      other.brightness == brightness &&
      other.contrast == contrast &&
      other.saturation == saturation;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(blendColors), brightness, contrast, saturation);
}

/// 叠加在模糊背景上的单个颜色 blend。对应 Kotlin `BlendColorEntry`。
@immutable
class BlendColorEntry {
  const BlendColorEntry(this.color, [this.mode = BlurBlendMode.srcOver]);

  final Color color;
  final BlurBlendMode mode;

  @override
  bool operator ==(Object other) =>
      other is BlendColorEntry && other.color == color && other.mode == mode;

  @override
  int get hashCode => Object.hash(color, mode);
}

/// 模糊颜色 blend 模式。对应 Kotlin `BlurBlendMode`（value class）。
///
/// 0-28 为标准 SkBlendMode（GPU 硬件处理）；>=100 为扩展自定义模式（Lab / 线性光 等，
/// 由 runtime shader 处理，见阶段 5D）。[value] 为原始模式标识。
@immutable
class BlurBlendMode {
  const BlurBlendMode(this.value);
  final int value;

  @override
  bool operator ==(Object other) =>
      other is BlurBlendMode && other.value == value;

  @override
  int get hashCode => value.hashCode;

  // region 标准 SkBlendMode (0-28)
  static const clear = BlurBlendMode(0);
  static const src = BlurBlendMode(1);
  static const dst = BlurBlendMode(2);
  static const srcOver = BlurBlendMode(3);
  static const dstOver = BlurBlendMode(4);
  static const srcIn = BlurBlendMode(5);
  static const dstIn = BlurBlendMode(6);
  static const srcOut = BlurBlendMode(7);
  static const dstOut = BlurBlendMode(8);
  static const srcAtop = BlurBlendMode(9);
  static const dstAtop = BlurBlendMode(10);
  static const xor = BlurBlendMode(11);
  static const plus = BlurBlendMode(12);
  static const modulate = BlurBlendMode(13);
  static const screen = BlurBlendMode(14);
  static const overlay = BlurBlendMode(15);
  static const darken = BlurBlendMode(16);
  static const lighten = BlurBlendMode(17);
  static const colorDodge = BlurBlendMode(18);
  static const colorBurn = BlurBlendMode(19);
  static const hardLight = BlurBlendMode(20);
  static const softLight = BlurBlendMode(21);
  static const difference = BlurBlendMode(22);
  static const exclusion = BlurBlendMode(23);
  static const multiply = BlurBlendMode(24);
  static const hue = BlurBlendMode(25);
  static const saturationMode = BlurBlendMode(26);
  static const colorMode = BlurBlendMode(27);
  static const luminosity = BlurBlendMode(28);
  // endregion

  // region 扩展自定义模式 (>=100)，由 runtime shader 实现（阶段 5D）
  static const linearLight = BlurBlendMode(100);
  static const linearLightWithGreyscale = BlurBlendMode(101);
  static const miDifference = BlurBlendMode(102);
  static const labLightenWithGreyscale = BlurBlendMode(103);
  static const labDarkenWithGreyscale = BlurBlendMode(105);
  static const lab = BlurBlendMode(106);
  static const linearLightLab = BlurBlendMode(107);
  static const miColorDodge = BlurBlendMode(118);
  static const miColorBurn = BlurBlendMode(119);
  static const plusDarker = BlurBlendMode(120);
  static const plusLighter = BlurBlendMode(121);
  static const alphaBlend = BlurBlendMode(200);
  static const miSaturation = BlurBlendMode(201);
  static const miBrightness = BlurBlendMode(202);
  static const miLuminance = BlurBlendMode(203);
  // endregion
}

/// 模糊效果默认值。对应 Kotlin `BlurDefaults` + BlurEffect.kt 内部常量。
class MiuixBlurDefaults {
  MiuixBlurDefaults._();

  /// 默认模糊半径（dp）。对应 `BlurDefaults.BlurRadius`。
  static const double blurRadius = 20.0;

  /// 默认噪声抖动系数（抗色带）。对应 `BlurDefaults.NoiseCoefficient`。
  static const double noiseCoefficient = 0.0045;

  /// progressive blur 的默认噪声系数（0=禁用）。对应 `BlurDefaults.ProgressiveNoiseCoefficient`。
  static const double progressiveNoiseCoefficient = 0.0;

  /// 最大模糊半径（dp）。对应 `BlurDefaults.MaxBlurRadius`。
  static const double maxBlurRadius = 150.0;

  /// 模糊半径 → 高斯 sigma 的转换系数。对应 `BLUR_RADIUS_TO_SIGMA`。
  static const double blurRadiusToSigma = 0.45;

  /// 模糊核触及范围（源像素）。对应 `BLUR_KERNEL_REACH`。
  static const int blurKernelReach = 13;

  /// 便捷构造 [BlurColors]。对应 `BlurDefaults.blurColors`。
  static BlurColors blurColors({
    List<BlendColorEntry> blendColors = const [],
    double brightness = 0.0,
    double contrast = 1.0,
    double saturation = 1.0,
  }) =>
      BlurColors(
        blendColors: blendColors,
        brightness: brightness,
        contrast: contrast,
        saturation: saturation,
      );
}

/// 由 [BlurColors] 的 brightness/contrast/saturation 构造等价的 [ColorFilter]。
///
/// 应用顺序与原版 COLOR_CONTROLS_SHADER 一致：亮度 → 对比度 → 饱和度。
/// 亮度用线性近似（原版在 gamma2.2 空间，视觉差异可忽略，且默认 0 时不参与）。
/// 若三者皆为恒等（无变化），返回 null。
ColorFilter? buildBlurColorFilter(BlurColors c) {
  final hasBrightness = c.brightness != 0.0;
  final hasContrast = c.contrast != 1.0;
  final hasSaturation = c.saturation != 1.0;
  if (!hasBrightness && !hasContrast && !hasSaturation) return null;

  List<double> m = _identityColorMatrix();
  if (hasBrightness) m = _mulColorMatrix(_brightnessColorMatrix(c.brightness), m);
  if (hasContrast) m = _mulColorMatrix(_contrastColorMatrix(c.contrast), m);
  if (hasSaturation) m = _mulColorMatrix(_saturationColorMatrix(c.saturation), m);
  return ColorFilter.matrix(m);
}

// 4x5 颜色矩阵（行主序，长度 20）：R'=m0*R+m1*G+m2*B+m3*A+m4，加项 m4 为 0..255 值域。
List<double> _identityColorMatrix() => <double>[
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0, //
      0, 0, 1, 0, 0, //
      0, 0, 0, 1, 0, //
    ];

/// 亮度：b>0 向白色混合 c*(1-b)+b；b<0 缩放 c*(1+b)。
List<double> _brightnessColorMatrix(double b) {
  final double scale = b > 0 ? (1 - b) : (1 + b);
  final double add = b > 0 ? b * 255.0 : 0.0;
  return <double>[
    scale, 0, 0, 0, add, //
    0, scale, 0, 0, add, //
    0, 0, scale, 0, add, //
    0, 0, 0, 1, 0, //
  ];
}

/// 对比度：绕 0.5 缩放，c'=(c-0.5)*k+0.5。
List<double> _contrastColorMatrix(double k) {
  final double add = (0.5 - 0.5 * k) * 255.0;
  return <double>[
    k, 0, 0, 0, add, //
    0, k, 0, 0, add, //
    0, 0, k, 0, add, //
    0, 0, 0, 1, 0, //
  ];
}

/// 饱和度：绕亮度保真地缩放，luma 系数与原着色器一致 (0.2126,0.7152,0.0722)。
List<double> _saturationColorMatrix(double s) {
  const double lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final double sr = (1 - s) * lr;
  final double sg = (1 - s) * lg;
  final double sb = (1 - s) * lb;
  return <double>[
    sr + s, sg, sb, 0, 0, //
    sr, sg + s, sb, 0, 0, //
    sr, sg, sb + s, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

/// 两个 4x5 颜色矩阵相乘（隐含末行 [0,0,0,0,1]），结果为 a∘b（先 b 后 a）。
List<double> _mulColorMatrix(List<double> a, List<double> b) {
  final out = List<double>.filled(20, 0);
  for (int row = 0; row < 4; row++) {
    for (int col = 0; col < 5; col++) {
      double sum = 0;
      for (int k = 0; k < 4; k++) {
        sum += a[row * 5 + k] * b[k * 5 + col];
      }
      if (col == 4) sum += a[row * 5 + 4];
      out[row * 5 + col] = sum;
    }
  }
  return out;
}

/// 把 [BlurBlendMode] 映射到 Flutter 原生 [BlendMode]（仅标准模式 0-28）。
///
/// 标准 SkBlendMode 与 Flutter [BlendMode] 一一对应，可用「在模糊层上叠色块 + 该
/// BlendMode」直接实现（无需着色器）。扩展模式（>=100，Lab/线性光等）返回 null，
/// 需 runtime shader（暂未移植，见 5D 说明）。
BlendMode? miuixStandardBlendMode(BlurBlendMode mode) {
  switch (mode.value) {
    case 0:
      return BlendMode.clear;
    case 1:
      return BlendMode.src;
    case 2:
      return BlendMode.dst;
    case 3:
      return BlendMode.srcOver;
    case 4:
      return BlendMode.dstOver;
    case 5:
      return BlendMode.srcIn;
    case 6:
      return BlendMode.dstIn;
    case 7:
      return BlendMode.srcOut;
    case 8:
      return BlendMode.dstOut;
    case 9:
      return BlendMode.srcATop;
    case 10:
      return BlendMode.dstATop;
    case 11:
      return BlendMode.xor;
    case 12:
      return BlendMode.plus;
    case 13:
      return BlendMode.modulate;
    case 14:
      return BlendMode.screen;
    case 15:
      return BlendMode.overlay;
    case 16:
      return BlendMode.darken;
    case 17:
      return BlendMode.lighten;
    case 18:
      return BlendMode.colorDodge;
    case 19:
      return BlendMode.colorBurn;
    case 20:
      return BlendMode.hardLight;
    case 21:
      return BlendMode.softLight;
    case 22:
      return BlendMode.difference;
    case 23:
      return BlendMode.exclusion;
    case 24:
      return BlendMode.multiply;
    case 25:
      return BlendMode.hue;
    case 26:
      return BlendMode.saturation;
    case 27:
      return BlendMode.color;
    case 28:
      return BlendMode.luminosity;
    default:
      return null; // 扩展模式，需 shader
  }
}
