// Miuix Flutter 移植版 - ColorPicker
// 源自 compose-miuix-ui/miuix 的 ColorPicker.kt。
// 四种色彩空间（HSV/OkHSV/OkLab/OkLch）的滑块取色器；颜色数学复用 color/ 模块，
// 渐变轨道用 ui.Gradient.linear（像素级内缩 + Clamp），指示器用 ui.Gradient.radial 发光环。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../color/extensions.dart';
import '../color/hsv.dart';
import '../color/ok_hsv.dart';
import '../color/ok_lab.dart';
import '../color/ok_lch.dart';
import '../color/transforms.dart';
import 'miuix_slider.dart';

/// 取色器使用的色彩空间。对应 Kotlin `ColorSpace`。
enum MiuixColorSpace {
  /// 传统 HSV。
  hsv,

  /// 基于 OkLab 的 OkHSV，感知均匀性更好。
  okhsv,

  /// OkLab（明度 + 绿红轴 + 蓝黄轴）。
  oklab,

  /// OkLCH（明度 + 色度 + 色相）。
  oklch,
}

/// Miuix 风格、支持多色彩空间的取色器。对应 Kotlin `ColorPicker`。
///
/// 根据 [colorSpace] 分派到对应的子取色器。
class MiuixColorPicker extends StatelessWidget {
  const MiuixColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
    this.showPreview = true,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
    this.colorSpace = MiuixColorSpace.hsv,
  });

  /// 当前颜色。
  final Color color;

  /// 颜色变化回调。
  final ValueChanged<Color> onColorChanged;

  /// 是否显示所选颜色的预览条。
  final bool showPreview;

  /// 滑块的触感反馈类型，默认与 Slider 一致（边缘反馈）。
  final MiuixSliderHapticEffect hapticEffect;

  /// 使用的色彩空间，默认 [MiuixColorSpace.hsv]。
  final MiuixColorSpace colorSpace;

  @override
  Widget build(BuildContext context) {
    switch (colorSpace) {
      case MiuixColorSpace.okhsv:
        return MiuixOkHsvColorPicker(
          color: color,
          onColorChanged: onColorChanged,
          showPreview: showPreview,
          hapticEffect: hapticEffect,
        );
      case MiuixColorSpace.oklab:
        return MiuixOkLabColorPicker(
          color: color,
          onColorChanged: onColorChanged,
          showPreview: showPreview,
          hapticEffect: hapticEffect,
        );
      case MiuixColorSpace.oklch:
        return MiuixOkLchColorPicker(
          color: color,
          onColorChanged: onColorChanged,
          showPreview: showPreview,
          hapticEffect: hapticEffect,
        );
      case MiuixColorSpace.hsv:
        return MiuixHsvColorPicker(
          color: color,
          onColorChanged: onColorChanged,
          showPreview: showPreview,
          hapticEffect: hapticEffect,
        );
    }
  }
}

/// HSV 色彩空间的 Miuix 取色器。对应 Kotlin `HsvColorPicker`。
class MiuixHsvColorPicker extends StatelessWidget {
  const MiuixHsvColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
    this.showPreview = true,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool showPreview;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixColorPickerBody(
    color: color,
    onColorChanged: onColorChanged,
    showPreview: showPreview,
    hapticEffect: hapticEffect,
    colorSpace: MiuixColorSpace.hsv,
  );
}

/// OkHSV 色彩空间的 Miuix 取色器。对应 Kotlin `OkHsvColorPicker`。
class MiuixOkHsvColorPicker extends StatelessWidget {
  const MiuixOkHsvColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
    this.showPreview = true,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool showPreview;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixColorPickerBody(
    color: color,
    onColorChanged: onColorChanged,
    showPreview: showPreview,
    hapticEffect: hapticEffect,
    colorSpace: MiuixColorSpace.okhsv,
  );
}

/// OkLab 色彩空间的 Miuix 取色器。对应 Kotlin `OkLabColorPicker`。
class MiuixOkLabColorPicker extends StatelessWidget {
  const MiuixOkLabColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
    this.showPreview = true,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool showPreview;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixColorPickerBody(
    color: color,
    onColorChanged: onColorChanged,
    showPreview: showPreview,
    hapticEffect: hapticEffect,
    colorSpace: MiuixColorSpace.oklab,
  );
}

/// OkLCH 色彩空间的 Miuix 取色器。对应 Kotlin `OkLchColorPicker`。
class MiuixOkLchColorPicker extends StatelessWidget {
  const MiuixOkLchColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
    this.showPreview = true,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool showPreview;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) => _MiuixColorPickerBody(
    color: color,
    onColorChanged: onColorChanged,
    showPreview: showPreview,
    hapticEffect: hapticEffect,
    colorSpace: MiuixColorSpace.oklch,
  );
}

class _MiuixColorPickerBody extends StatefulWidget {
  const _MiuixColorPickerBody({
    required this.color,
    required this.onColorChanged,
    required this.showPreview,
    required this.hapticEffect,
    required this.colorSpace,
  });

  final Color color;
  final ValueChanged<Color> onColorChanged;
  final bool showPreview;
  final MiuixSliderHapticEffect hapticEffect;
  final MiuixColorSpace colorSpace;

  @override
  State<_MiuixColorPickerBody> createState() => _MiuixColorPickerBodyState();
}

class _MiuixColorPickerBodyState extends State<_MiuixColorPickerBody> {
  late double _first;
  late double _second;
  late double _third;
  late double _alpha;
  late int _lastAppliedExternalArgb;

  @override
  void initState() {
    super.initState();
    _syncFrom(widget.color);
  }

  @override
  void didUpdateWidget(_MiuixColorPickerBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.colorSpace != widget.colorSpace) {
      _syncFrom(widget.color);
      return;
    }
    final int externalArgb = widget.color.toARGB32();
    final int internalArgb = _selectedColor.toARGB32();
    if (externalArgb != _lastAppliedExternalArgb &&
        externalArgb != internalArgb) {
      _syncFrom(widget.color);
    }
  }

  void _syncFrom(Color color) {
    switch (widget.colorSpace) {
      case MiuixColorSpace.hsv:
        final Hsv hsv = color.toHsv();
        _first = hsv.h;
        _second = hsv.s / 100;
        _third = hsv.v / 100;
      case MiuixColorSpace.okhsv:
        final List<double> okhsv = Transforms.colorToOkhsv(color);
        _first = okhsv[0];
        _second = okhsv[1];
        _third = okhsv[2];
      case MiuixColorSpace.oklab:
        final OkLab lab = color.toOkLab();
        _first = lab.l / 100;
        _second = lab.a / 100 * 0.4;
        _third = lab.b / 100 * 0.4;
      case MiuixColorSpace.oklch:
        final OkLch lch = color.toOkLch();
        _first = lch.l / 100;
        _second = lch.c / 100;
        _third = lch.h / 360;
    }
    _alpha = color.a;
    _lastAppliedExternalArgb = color.toARGB32();
  }

  Color get _selectedColor {
    switch (widget.colorSpace) {
      case MiuixColorSpace.hsv:
        return Hsv(_first, _second * 100, _third * 100).toColor(_alpha);
      case MiuixColorSpace.okhsv:
        return OkHsv(_first, _second, _third).toColor(_alpha);
      case MiuixColorSpace.oklab:
        return OkLab(
          _first * 100,
          _second / 0.4 * 100,
          _third / 0.4 * 100,
        ).toColor(_alpha);
      case MiuixColorSpace.oklch:
        return OkLch(_first * 100, _second * 100, _third * 360).toColor(_alpha);
    }
  }

  void _setChannel(int channel, double value) {
    setState(() {
      switch (channel) {
        case 0:
          _first = value;
        case 1:
          _second = value;
        case 2:
          _third = value;
        case 3:
          _alpha = value;
      }
    });
    final Color selected = _selectedColor;
    if (selected.toARGB32() != widget.color.toARGB32()) {
      widget.onColorChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color selected = _selectedColor;
    final List<Widget> children = <Widget>[
      if (widget.showPreview)
        ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: SizedBox(
            width: double.infinity,
            height: 26,
            child: ColoredBox(color: selected),
          ),
        ),
      ..._buildSliders(),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i != 0) const SizedBox(height: 12),
          children[i],
        ],
      ],
    );
  }

  List<Widget> _buildSliders() {
    switch (widget.colorSpace) {
      case MiuixColorSpace.hsv:
        return <Widget>[
          _slider(
            value: _first / 360,
            channel: 0,
            mapValue: (value) => value * 360,
            colors: Transforms.generateHsvHueColors(),
          ),
          _slider(
            value: _second,
            channel: 1,
            colors: <Color>[
              Hsv(_first, 0, 100).toColor(),
              Hsv(_first, 100, 100).toColor(),
            ],
          ),
          _slider(
            value: _third,
            channel: 2,
            colors: <Color>[
              const Color(0xFF000000),
              Hsv(_first, _second * 100, 100).toColor(),
            ],
          ),
          _slider(
            value: _alpha,
            channel: 3,
            checkerboard: true,
            colors: _alphaColors(
              Hsv(_first, _second * 100, _third * 100).toColor(),
            ),
          ),
        ];
      case MiuixColorSpace.okhsv:
        return <Widget>[
          _slider(
            value: _first,
            channel: 0,
            colors: Transforms.generateOkHsvHueColors(),
          ),
          _slider(
            value: _second,
            channel: 1,
            colors: <Color>[
              Transforms.okhsvToColor(_first, 0, 1),
              Transforms.okhsvToColor(_first, 1, 1),
            ],
          ),
          _slider(
            value: _third,
            channel: 2,
            colors: <Color>[
              Transforms.okhsvToColor(_first, _second, 0),
              Transforms.okhsvToColor(_first, _second, 1),
            ],
          ),
          _slider(
            value: _alpha,
            channel: 3,
            checkerboard: true,
            colors: _alphaColors(
              Transforms.okhsvToColor(_first, _second, _third),
            ),
          ),
        ];
      case MiuixColorSpace.oklab:
        return _buildOkLabSliders();
      case MiuixColorSpace.oklch:
        return _buildOkLchSliders();
    }
  }

  List<Widget> _buildOkLabSliders() {
    final List<Color> lightness = List<Color>.generate(8, (int i) {
      final double l = i / 7;
      return OkLab(l * 100, _second / 0.4 * 100, _third / 0.4 * 100).toColor();
    });
    final List<Color> aColors = List<Color>.generate(9, (int i) {
      final double a = -0.3 + 0.6 * i / 8;
      return OkLab(_first * 100, a / 0.4 * 100, _third / 0.4 * 100).toColor();
    });
    final List<Color> bColors = List<Color>.generate(9, (int i) {
      final double b = -0.3 + 0.6 * i / 8;
      return OkLab(_first * 100, _second / 0.4 * 100, b / 0.4 * 100).toColor();
    });
    final Color base = OkLab(
      _first * 100,
      _second / 0.4 * 100,
      _third / 0.4 * 100,
    ).toColor();
    return <Widget>[
      _slider(value: _first, channel: 0, colors: lightness),
      _slider(
        value: (_second + 0.3) / 0.6,
        channel: 1,
        mapValue: (value) => value * 0.6 - 0.3,
        colors: aColors,
      ),
      _slider(
        value: (_third + 0.3) / 0.6,
        channel: 2,
        mapValue: (value) => value * 0.6 - 0.3,
        colors: bColors,
      ),
      _slider(
        value: _alpha,
        channel: 3,
        checkerboard: true,
        colors: _alphaColors(base),
      ),
    ];
  }

  List<Widget> _buildOkLchSliders() {
    final double hue = _third * 360;
    final double chroma = _second * 0.4;
    final Color base = Transforms.oklchToColor(_first, chroma, hue);
    return <Widget>[
      _slider(
        value: _third,
        channel: 2,
        colors: Transforms.generateOkLchHueColors(_first, _second),
      ),
      _slider(
        value: _first,
        channel: 0,
        colors: <Color>[
          Transforms.oklchToColor(0, chroma, hue),
          Transforms.oklchToColor(1, chroma, hue),
        ],
      ),
      _slider(
        value: _second,
        channel: 1,
        colors: <Color>[
          Transforms.oklchToColor(_first, 0, hue),
          Transforms.oklchToColor(_first, 0.4, hue),
        ],
      ),
      _slider(
        value: _alpha,
        channel: 3,
        checkerboard: true,
        colors: _alphaColors(base),
      ),
    ];
  }

  List<Color> _alphaColors(Color color) => <Color>[
    color.withValues(alpha: 0),
    color.withValues(alpha: 1),
  ];

  Widget _slider({
    required double value,
    required int channel,
    required List<Color> colors,
    double Function(double)? mapValue,
    bool checkerboard = false,
  }) {
    return _ColorSlider(
      value: value,
      colors: colors,
      checkerboard: checkerboard,
      hapticEffect: widget.hapticEffect,
      onChanged: (value) =>
          _setChannel(channel, mapValue?.call(value) ?? value),
    );
  }
}

class _ColorSlider extends StatefulWidget {
  const _ColorSlider({
    required this.value,
    required this.onChanged,
    required this.colors,
    required this.checkerboard,
    required this.hapticEffect,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final List<Color> colors;
  final bool checkerboard;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  State<_ColorSlider> createState() => _ColorSliderState();
}

class _ColorSliderState extends State<_ColorSlider> {
  final _ColorSliderHapticState _haptic = _ColorSliderHapticState();
  double _dragOffset = 0;
  double _width = 0;

  double _valueAt(double x) {
    if (_width <= 26) return 0;
    final double constrained = x.clamp(13.0, _width - 13);
    return ((constrained - 13) / (_width - 26)).clamp(0.0, 1.0);
  }

  bool get _isRtl => Directionality.of(context) == TextDirection.rtl;

  void _dragStart(DragStartDetails details) {
    final double x = _isRtl
        ? _width - details.localPosition.dx
        : details.localPosition.dx;
    _dragOffset = x;
    final double value = _valueAt(x);
    widget.onChanged(value);
    _haptic.reset(value, widget.value);
  }

  void _dragUpdate(DragUpdateDetails details) {
    _dragOffset += _isRtl ? -details.delta.dx : details.delta.dx;
    final double value = _valueAt(_dragOffset);
    widget.onChanged(value);
    _haptic.handle(value, widget.hapticEffect);
  }

  @override
  Widget build(BuildContext context) {
    final bool rtl = _isRtl;
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        return ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _dragStart,
            onHorizontalDragUpdate: _dragUpdate,
            child: SizedBox(
              width: double.infinity,
              height: 26,
              child: CustomPaint(
                painter: _ColorSliderPainter(
                  value: widget.value,
                  colors: widget.colors,
                  checkerboard: widget.checkerboard,
                  isRtl: rtl,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ColorSliderPainter extends CustomPainter {
  const _ColorSliderPainter({
    required this.value,
    required this.colors,
    required this.checkerboard,
    required this.isRtl,
  });

  final double value;
  final List<Color> colors;
  final bool checkerboard;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    if (checkerboard) _paintCheckerboard(canvas, size);

    final List<Color> gradientColors = isRtl
        ? colors.reversed.toList(growable: false)
        : colors;
    // dart:ui 的 Gradient.linear 在 colorStops 为 null 时要求 colors.length == 2，
    // 故此处为多色渐变显式生成均匀分布的 stops，等价于 Compose
    // Brush.horizontalGradient 默认行为。
    final List<double> stops = gradientColors.length == 1
        ? const <double>[0.0]
        : List<double>.generate(
            gradientColors.length,
            (int i) => i / (gradientColors.length - 1),
            growable: false,
          );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(13, 0),
          Offset(size.width - 13, 0),
          gradientColors,
          stops,
          TileMode.clamp,
        ),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = const Color(0xFF888888).withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    final double visualValue = isRtl ? 1 - value : value;
    final Offset center = Offset(
      13 + visualValue.clamp(0.0, 1.0) * (size.width - 26),
      size.height / 2,
    );
    _paintIndicator(canvas, center);
  }

  void _paintCheckerboard(Canvas canvas, Size size) {
    const double cell = 3;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFCCCCCC),
    );
    final Paint dark = Paint()..color = const Color(0xFFAAAAAA);
    final int rows = math.max(1, (size.height / cell).ceil());
    for (int row = 0; row < rows; row++) {
      final double y = row * cell;
      double x = row.isEven ? cell : 0;
      while (x < size.width) {
        canvas.drawRect(
          Rect.fromLTRB(
            x,
            y,
            math.min(x + cell, size.width),
            math.min(y + cell, size.height),
          ),
          dark,
        );
        x += cell * 2;
      }
    }
  }

  void _paintIndicator(Canvas canvas, Offset center) {
    const double strokeWidth = 6;
    const double halfStroke = 3;
    const double glowSpread = 2;
    const double ringCenterRadius = 7;
    const double gradientRadius = 12;
    const Color glow = Color.fromRGBO(0, 0, 0, 0.25);
    canvas.drawCircle(
      center,
      gradientRadius,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          gradientRadius,
          const <Color>[Color(0x00000000), glow, glow, Color(0x00000000)],
          const <double>[
            (ringCenterRadius - halfStroke - glowSpread) / gradientRadius,
            (ringCenterRadius - halfStroke) / gradientRadius,
            (ringCenterRadius + halfStroke) / gradientRadius,
            (ringCenterRadius + halfStroke + glowSpread) / gradientRadius,
          ],
        ),
    );
    canvas.drawCircle(
      center,
      ringCenterRadius,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_ColorSliderPainter oldDelegate) =>
      value != oldDelegate.value ||
      colors != oldDelegate.colors ||
      checkerboard != oldDelegate.checkerboard ||
      isRtl != oldDelegate.isRtl;
}

class _ColorSliderHapticState {
  bool _edgeTriggered = false;
  double _lastStep = 0;

  void reset(double current, double previous) {
    final bool atEdge = current == 0 || current == 1;
    _edgeTriggered = atEdge && previous == current;
    _lastStep = current;
  }

  void handle(double current, MiuixSliderHapticEffect effect) {
    if (effect == MiuixSliderHapticEffect.none) return;
    final bool atEdge = current == 0 || current == 1;
    if (atEdge && !_edgeTriggered) {
      HapticFeedback.selectionClick();
      _edgeTriggered = true;
    } else if (!atEdge) {
      _edgeTriggered = false;
    }
    if (effect == MiuixSliderHapticEffect.step &&
        !atEdge &&
        current != _lastStep) {
      HapticFeedback.selectionClick();
      _lastStep = current;
    } else if (atEdge) {
      _lastStep = current;
    }
  }
}
