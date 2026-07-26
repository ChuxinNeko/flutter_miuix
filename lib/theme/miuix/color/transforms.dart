// Miuix Flutter 移植版 - 颜色空间变换
// 源自 compose-miuix-ui/miuix 的 color/core/Transforms.kt。
// 保留 OkLab、OkLCH、HSV 与 OkHSV 的原始数学、色域裁剪和缓存行为。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'hsv.dart';

/// 对应 Kotlin `Transforms`，提供纯颜色空间变换算法。
abstract final class Transforms {
  static const double _pi = math.pi;

  /// 对应 Kotlin `rgbToOkLab`，将 0..1 的 sRGB 向量转换为 OkLab。
  static List<double> rgbToOkLab(List<double> color) {
    final l = _cbrt(
      0.4122214708 * color[0] +
          0.5363325363 * color[1] +
          0.0514459929 * color[2],
    );
    final m = _cbrt(
      0.2119034982 * color[0] +
          0.6806995451 * color[1] +
          0.1073969566 * color[2],
    );
    final s = _cbrt(
      0.0883024619 * color[0] +
          0.2817188376 * color[1] +
          0.6299787005 * color[2],
    );

    return <double>[
      0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
      1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
      0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
    ];
  }

  /// 对应 Kotlin `okLabToRgb`，转换为各分量裁剪至 0..1 的 sRGB。
  static List<double> okLabToRgb(List<double> color) {
    final l1 = color[0] + 0.3963377774 * color[1] + 0.2158037573 * color[2];
    final m1 = color[0] - 0.1055613458 * color[1] - 0.0638541728 * color[2];
    final s1 = color[0] - 0.0894841775 * color[1] - 1.2914855480 * color[2];

    final l = l1 * l1 * l1;
    final m = m1 * m1 * m1;
    final s = s1 * s1 * s1;

    return <double>[
      (4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s).clamp(0.0, 1.0),
      (-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s).clamp(0.0, 1.0),
      (-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s).clamp(0.0, 1.0),
    ];
  }

  /// 对应 Kotlin `okLabToOklch`，返回 `[l, c, h]`。
  static List<double> okLabToOklch(List<double> lab) {
    final l = lab[0];
    final a = lab[1];
    final b = lab[2];
    final c = math.sqrt(a * a + b * b);
    var h = _toDegrees(math.atan2(b, a));
    if (h < 0.0) h += 360.0;
    return <double>[l, c, h];
  }

  /// 对应 Kotlin `oklchToOkLab`，返回 `[l, a, b]`。
  static List<double> oklchToOkLab(List<double> lch) {
    final hRad = _toRadians(lch[2]);
    return <double>[lch[0], lch[1] * math.cos(hRad), lch[1] * math.sin(hRad)];
  }

  /// 对应 Kotlin `okLabToColor`，将 OkLab 转换为 Flutter sRGB [Color]。
  static Color okLabToColor(List<double> okLab, [double alpha = 1.0]) {
    final rgb = okLabToRgb(okLab);
    return Color.from(alpha: alpha, red: rgb[0], green: rgb[1], blue: rgb[2]);
  }

  /// 对应 Kotlin `oklchToColor`；色度按典型 sRGB 色域裁剪至 0..0.4。
  static Color oklchToColor(
    double l,
    double c,
    double h, [
    double alpha = 1.0,
  ]) {
    return okLabToColor(oklchToOkLab(normalizeOklch(l, c, h)), alpha);
  }

  /// 对应 Kotlin `colorToOkLab`，忽略输入颜色的 alpha。
  static List<double> colorToOkLab(Color color) =>
      rgbToOkLab(<double>[color.r, color.g, color.b]);

  /// 对应 Kotlin `colorToOklch`，规范化明度、色度和色相。
  static List<double> colorToOklch(Color color) {
    final lch = okLabToOklch(colorToOkLab(color));
    var h = lch[2] % 360.0;
    if (h < 0.0) h += 360.0;
    return <double>[lch[0].clamp(0.0, 1.0), lch[1].clamp(0.0, 0.4), h];
  }

  /// 对应 Kotlin `rgbToHsv`，原地写入长度至少为 3 的 [hsv]。
  static void rgbToHsv(int r, int g, int b, List<double> hsv) {
    final rf = r / 255.0;
    final gf = g / 255.0;
    final bf = b / 255.0;
    final maximum = math.max(rf, math.max(gf, bf));
    final minimum = math.min(rf, math.min(gf, bf));
    final delta = maximum - minimum;

    final double hue;
    if (delta == 0.0) {
      hue = 0.0;
    } else if (maximum == rf) {
      hue = (60.0 * ((gf - bf) / delta) + 360.0) % 360.0;
    } else if (maximum == gf) {
      hue = (60.0 * ((bf - rf) / delta) + 120.0) % 360.0;
    } else {
      hue = (60.0 * ((rf - gf) / delta) + 240.0) % 360.0;
    }

    hsv[0] = hue.clamp(0.0, 360.0);
    hsv[1] = (maximum > 0.0 ? delta / maximum : 0.0).clamp(0.0, 1.0);
    hsv[2] = maximum.clamp(0.0, 1.0);
  }

  /// 对应 Kotlin `colorToHsv`；先按源码截断为 8 位 sRGB 再转换。
  static List<double> colorToHsv(Color color) {
    final hsv = List<double>.filled(3, 0.0);
    rgbToHsv(
      (color.r * 255.0).truncate(),
      (color.g * 255.0).truncate(),
      (color.b * 255.0).truncate(),
      hsv,
    );
    return hsv;
  }

  /// 对应 Kotlin `srgbToOkhsv`，返回 h/s/v 均为 0..1 的 OkHSV。
  static List<double> srgbToOkhsv(double r, double g, double b) {
    final lab = _linearSrgbToOklab(
      _srgbTransferFunctionInv(r),
      _srgbTransferFunctionInv(g),
      _srgbTransferFunctionInv(b),
    );
    final c = math.sqrt(lab[1] * lab[1] + lab[2] * lab[2]);
    final a = c == 0.0 ? 0.0 : lab[1] / c;
    final bDirection = c == 0.0 ? 0.0 : lab[2] / c;
    final l = lab[0];
    final h = 0.5 + (0.5 * math.atan2(-lab[2], -lab[1])) / _pi;

    final stMax = _getSTMax(a, bDirection);
    final sMax = stMax[0];
    const s0 = 0.5;
    final tMax = stMax[1];
    final k = 1.0 - s0 / sMax;
    final t = tMax / (c + l * tMax);
    final lv = t * l;
    final cv = t * c;
    final lvt = _toeInv(lv);
    final cvt = (cv * lvt) / lv;
    final rgbScale = _oklabToLinearSrgb(lvt, a * cvt, bDirection * cvt);
    final scaleL = _cbrt(
      1.0 /
          math.max(
            math.max(rgbScale[0], rgbScale[1]),
            math.max(rgbScale[2], 0.0),
          ),
    );

    var l2 = _toe(l / scaleL);
    final v = l2 / lv;
    final s = ((s0 + tMax) * cv) / (tMax * s0 + tMax * k * cv);
    return <double>[h, s, v];
  }

  /// 对应 Kotlin `okhsvToSrgb`，输入 h/s/v 均使用 0..1。
  static List<double> okhsvToSrgb(double h, double s, double v) {
    final a = math.cos(2.0 * _pi * h);
    final b = math.sin(2.0 * _pi * h);
    final stMax = _getSTMax(a, b);
    final sMax = stMax[0];
    const s0 = 0.5;
    final tMax = stMax[1];
    final k = 1.0 - s0 / sMax;
    final denominator = s0 + tMax - tMax * k * s;
    final lv = 1.0 - (s * s0) / denominator;
    final cv = (s * tMax * s0) / denominator;
    var l = v * lv;
    var c = v * cv;
    final lvt = _toeInv(lv);
    final cvt = (cv * lvt) / lv;
    final lNew = _toeInv(l);
    c = (c * lNew) / l;
    l = lNew;
    final rgbScale = _oklabToLinearSrgb(lvt, a * cvt, b * cvt);
    final scaleL = _cbrt(
      1.0 /
          math.max(
            math.max(rgbScale[0], rgbScale[1]),
            math.max(rgbScale[2], 0.0),
          ),
    );
    l *= scaleL;
    c *= scaleL;
    final rgb = _oklabToLinearSrgb(l, c * a, c * b);
    return <double>[
      _srgbTransferFunction(rgb[0]),
      _srgbTransferFunction(rgb[1]),
      _srgbTransferFunction(rgb[2]),
    ];
  }

  /// 对应 Kotlin `colorToOkhsv`，忽略输入颜色的 alpha。
  static List<double> colorToOkhsv(Color color) =>
      srgbToOkhsv(color.r, color.g, color.b);

  /// 对应 Kotlin `okhsvToColor`，不额外裁剪 OkHSV 或 alpha 输入。
  static Color okhsvToColor(
    double h,
    double s,
    double v, [
    double alpha = 1.0,
  ]) {
    final rgb = okhsvToSrgb(h, s, v);
    return Color.from(alpha: alpha, red: rgb[0], green: rgb[1], blue: rgb[2]);
  }

  /// 对应 Kotlin `generateHsvHueColors`，生成 36 个高饱和 HSV 色相样本。
  static List<Color> generateHsvHueColors() => List<Color>.generate(
    36,
    (i) => Hsv(i / 36.0 * 360.0, 100.0, 100.0).toColor(),
    growable: false,
  );

  /// 对应 Kotlin `generateOkHsvHueColors`，生成 36 个感知平滑样本。
  static List<Color> generateOkHsvHueColors() => List<Color>.generate(
    36,
    (i) => okhsvToColor(i / 36.0, 1.0, 1.0),
    growable: false,
  );

  static final Map<String, List<Color>> _okLchHueCache =
      <String, List<Color>>{};

  /// 对应 Kotlin `generateOkLchHueColors`，并按百分位明度/色度及步数缓存。
  static List<Color> generateOkLchHueColors(
    double l,
    double c, [
    int steps = 36,
  ]) {
    final lClamped = l.clamp(0.0, 1.0);
    final cClamped = c.clamp(0.0, 1.0);
    final key =
        '${(lClamped * 100.0).truncate()}:'
        '${(cClamped * 100.0).truncate()}:$steps';
    return _okLchHueCache.putIfAbsent(key, () {
      final cInternal = cClamped * 0.4;
      return List<Color>.generate(
        steps,
        (i) => oklchToColor(lClamped, cInternal, i / steps.toDouble() * 360.0),
        growable: false,
      );
    });
  }

  /// 对应 Kotlin `normalizeOklch`，裁剪至安全范围并规范化色相角。
  static List<double> normalizeOklch(double l, double c, double h) {
    var hue = h % 360.0;
    if (hue < 0.0) hue += 360.0;
    return <double>[l.clamp(0.0, 1.0), c.clamp(0.0, 0.4), hue];
  }

  static double _srgbTransferFunction(double a) => 0.0031308 >= a
      ? 12.92 * a
      : 1.055 * math.pow(a, 0.4166666666666667) - 0.055;

  static double _srgbTransferFunctionInv(double a) =>
      0.04045 < a ? math.pow((a + 0.055) / 1.055, 2.4).toDouble() : a / 12.92;

  static List<double> _linearSrgbToOklab(double r, double g, double b) {
    final l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
    final m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
    final s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;
    final lc = _cbrt(l);
    final mc = _cbrt(m);
    final sc = _cbrt(s);
    return <double>[
      0.2104542553 * lc + 0.793617785 * mc - 0.0040720468 * sc,
      1.9779984951 * lc - 2.428592205 * mc + 0.4505937099 * sc,
      0.0259040371 * lc + 0.7827717662 * mc - 0.808675766 * sc,
    ];
  }

  static List<double> _oklabToLinearSrgb(double l, double a, double b) {
    final lc = l + 0.3963377774 * a + 0.2158037573 * b;
    final mc = l - 0.1055613458 * a - 0.0638541728 * b;
    final sc = l - 0.0894841775 * a - 1.291485548 * b;
    final ll = lc * lc * lc;
    final ml = mc * mc * mc;
    final sl = sc * sc * sc;
    return <double>[
      4.0767416621 * ll - 3.3077115913 * ml + 0.2309699292 * sl,
      -1.2684380046 * ll + 2.6097574011 * ml - 0.3413193965 * sl,
      -0.0041960863 * ll - 0.7034186147 * ml + 1.707614701 * sl,
    ];
  }

  static double _toe(double x) {
    const k1 = 0.206;
    const k2 = 0.03;
    const k3 = (1.0 + k1) / (1.0 + k2);
    final d = k3 * x - k1;
    return 0.5 * (d + math.sqrt(d * d + 4.0 * k2 * k3 * x));
  }

  static double _toeInv(double x) {
    const k1 = 0.206;
    const k2 = 0.03;
    const k3 = (1.0 + k1) / (1.0 + k2);
    return (x * x + k1 * x) / (k3 * (x + k2));
  }

  static double _computeMaxSaturation(double a, double b) {
    late final double k0;
    late final double k1;
    late final double k2;
    late final double k3;
    late final double k4;
    late final double wl;
    late final double wm;
    late final double ws;

    if (-1.88170328 * a - 0.80936493 * b > 1.0) {
      k0 = 1.19086277;
      k1 = 1.76576728;
      k2 = 0.59662641;
      k3 = 0.75515197;
      k4 = 0.56771245;
      wl = 4.0767416621;
      wm = -3.3077115913;
      ws = 0.2309699292;
    } else if (1.81444104 * a - 1.19445276 * b > 1.0) {
      k0 = 0.73956515;
      k1 = -0.45954404;
      k2 = 0.08285427;
      k3 = 0.1254107;
      k4 = 0.14503204;
      wl = -1.2684380046;
      wm = 2.6097574011;
      ws = -0.3413193965;
    } else {
      k0 = 1.35733652;
      k1 = -0.00915799;
      k2 = -1.1513021;
      k3 = -0.50559606;
      k4 = 0.00692167;
      wl = -0.0041960863;
      wm = -0.7034186147;
      ws = 1.707614701;
    }

    var s = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b;
    final kl = 0.3963377774 * a + 0.2158037573 * b;
    final km = -0.1055613458 * a - 0.0638541728 * b;
    final ks = -0.0894841775 * a - 1.291485548 * b;
    final lc = 1.0 + s * kl;
    final mc = 1.0 + s * km;
    final sc = 1.0 + s * ks;
    final ll = lc * lc * lc;
    final ml = mc * mc * mc;
    final sl = sc * sc * sc;
    final lds = 3.0 * kl * lc * lc;
    final mds = 3.0 * km * mc * mc;
    final sds = 3.0 * ks * sc * sc;
    final lds2 = 6.0 * kl * kl * lc;
    final mds2 = 6.0 * km * km * mc;
    final sds2 = 6.0 * ks * ks * sc;
    final f = wl * ll + wm * ml + ws * sl;
    final f1 = wl * lds + wm * mds + ws * sds;
    final f2 = wl * lds2 + wm * mds2 + ws * sds2;
    s -= (f * f1) / (f1 * f1 - 0.5 * f * f2);
    return s;
  }

  static List<double> _findCusp(double a, double b) {
    final sCusp = _computeMaxSaturation(a, b);
    final rgbAtMax = _oklabToLinearSrgb(1.0, sCusp * a, sCusp * b);
    final lCusp = _cbrt(
      1.0 / math.max(rgbAtMax[0], math.max(rgbAtMax[1], rgbAtMax[2])),
    );
    return <double>[lCusp, lCusp * sCusp];
  }

  static List<double> _getSTMax(double a, double b, [List<double>? cusp]) {
    final actual = cusp ?? _findCusp(a, b);
    return <double>[actual[1] / actual[0], actual[1] / (1.0 - actual[0])];
  }

  static double _cbrt(double value) {
    if (value == 0.0) return value;
    return value.isNegative
        ? -math.pow(-value, 1.0 / 3.0).toDouble()
        : math.pow(value, 1.0 / 3.0).toDouble();
  }

  static double _toDegrees(double radians) => radians * 180.0 / _pi;
  static double _toRadians(double degrees) => degrees * _pi / 180.0;
}
