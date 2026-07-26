// Miuix Flutter 移植版 - Bloom 高光边框
// 源自 compose-miuix-ui/miuix 的 miuix-blur/highlight/{Highlight,HighlightStyle,HighlightDrawing}.kt。
// 圆角矩形 SDF + 3D 半球 rim 法线 + 方向光，画出被照亮的玻璃边缘；BlendMode.plus 叠加。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 光源的 3D 位置（归一化 UV）。对应 Kotlin `LightPosition`。
///
/// 着色器把 `(x-0.5, y-0.7, z)` 归一化为方向；[x]/[y] 在 [0,1] 为相对高光边界的
/// UV 位置，`(0.5,0.7)` 为参考原点（放这里无贡献）；[z] 有符号深度，负值置于表面之后。
@immutable
class LightPosition {
  const LightPosition(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;
}

/// 一个方向光源。对应 Kotlin `LightSource`。
@immutable
class LightSource {
  const LightSource({
    required this.position,
    this.color = const Color(0xFFFFFFFF),
    this.intensity = 1.0,
  });
  final LightPosition position;
  final Color color;
  final double intensity;
}

/// 边缘 bloom 描边的着色模型。对应 Kotlin `BloomStroke`。
///
/// [color] 平铺描边色（其 alpha 缩放描边贡献）；[blendMode] 合成模式（默认 plus）；
/// [innerBlurRadius] 内发光深度（dp）；[primaryLight]/[secondaryLight] 两个方向光；
/// [dualPeak] 每光是否产生两个对峰（Apple 风镜面扫光）。
@immutable
class BloomStroke {
  const BloomStroke({
    this.color = const Color(0x0DFFFFFF), // White @ 0.05
    this.blendMode = BlendMode.plus,
    this.innerBlurRadius = 2.8,
    this.primaryLight = const LightSource(
      position: LightPosition(0.5, 0.5, -0.5),
      intensity: 0.4,
    ),
    this.secondaryLight = const LightSource(
      position: LightPosition(0.5, 0.8, -0.5),
      intensity: 0.25,
    ),
    this.dualPeak = false,
  });

  final Color color;
  final BlendMode blendMode;
  final double innerBlurRadius;
  final LightSource primaryLight;
  final LightSource secondaryLight;
  final bool dualPeak;

  // ---- 6 个 GlassStroke 预设（值 1:1 抄 HighlightStyle.kt）----
  static const glassStrokeBigLight = BloomStroke(
    innerBlurRadius: 3.5,
    primaryLight: LightSource(position: LightPosition(0.5, 0.5, -0.5), intensity: 0.3),
    secondaryLight: LightSource(position: LightPosition(0.5, 0.6, -0.5), intensity: 0.2),
  );
  static const glassStrokeMiddleLight = BloomStroke(
    innerBlurRadius: 2.8,
    primaryLight: LightSource(position: LightPosition(0.5, 0.5, -0.5), intensity: 0.4),
    secondaryLight: LightSource(position: LightPosition(0.5, 0.8, -0.5), intensity: 0.25),
  );
  static const glassStrokeSmallLight = BloomStroke(
    innerBlurRadius: 2.6,
    primaryLight: LightSource(position: LightPosition(0.5, 0.5, -0.5), intensity: 0.6),
    secondaryLight: LightSource(position: LightPosition(0.5, 0.95, -0.5), intensity: 0.35),
  );
  static const glassStrokeBigDark = BloomStroke(
    innerBlurRadius: 1.7,
    primaryLight: LightSource(position: LightPosition(0.5, 0.5, -0.5), intensity: 0.4),
    secondaryLight: LightSource(position: LightPosition(0.5, 0.6, -0.5), intensity: 0.25),
  );
  static const glassStrokeMiddleDark = BloomStroke(
    color: Color(0x0FFFFFFF), // White @ 0.06
    innerBlurRadius: 2.0,
    primaryLight: LightSource(position: LightPosition(0.5, 0.5, -0.5), intensity: 0.5),
    secondaryLight: LightSource(position: LightPosition(0.5, 0.8, -0.5), intensity: 0.25),
  );
  static const glassStrokeSmallDark = BloomStroke(
    color: Color(0x14FFFFFF), // White @ 0.08
    innerBlurRadius: 2.3,
    primaryLight: LightSource(position: LightPosition(0.5, 0.5, -0.5), intensity: 0.6),
    secondaryLight: LightSource(position: LightPosition(0.5, 0.95, -0.36), intensity: 0.25),
  );
}

/// 高光配置。对应 Kotlin `Highlight`。
///
/// [width] 描边带宽（dp，默认 0.8）；[alpha] 整体不透明度；[style] 着色模型。
@immutable
class Highlight {
  const Highlight({
    this.width = 0.8,
    this.alpha = 1.0,
    this.style = BloomStroke.glassStrokeMiddleLight,
  });

  final double width;
  final double alpha;
  final BloomStroke style;

  static const glassStrokeBigLight = Highlight(style: BloomStroke.glassStrokeBigLight);
  static const glassStrokeMiddleLight = Highlight(style: BloomStroke.glassStrokeMiddleLight);
  static const glassStrokeSmallLight = Highlight(style: BloomStroke.glassStrokeSmallLight);
  static const glassStrokeBigDark = Highlight(style: BloomStroke.glassStrokeBigDark);
  static const glassStrokeMiddleDark = Highlight(style: BloomStroke.glassStrokeMiddleDark);
  static const glassStrokeSmallDark = Highlight(style: BloomStroke.glassStrokeSmallDark);

  /// 默认高光 = 标准浅色卡片。
  static const defaultHighlight = glassStrokeMiddleLight;
}

/// 光方向参考原点（对应 LIGHT_REF_X/Y）。
const double _lightRefX = 0.5;
const double _lightRefY = 0.7;

/// bloom stroke 着色器程序单例。
class _BloomShaderProgram {
  _BloomShaderProgram._();
  static ui.FragmentProgram? _program;
  static bool _loading = false;
  static ui.FragmentProgram? get programOrNull => _program;
  static void ensureLoaded(VoidCallback onLoaded) {
    if (_program != null || _loading) return;
    _loading = true;
    ui.FragmentProgram.fromAsset('packages/flutter_miuix/shaders/miuix_bloom_stroke.frag').then((p) {
      _program = p;
      _loading = false;
      onLoaded();
    });
  }
}

/// 在子内容之上绘制 bloom 高光边框。对应 Kotlin `Modifier.highlight` / `drawHighlight`。
///
/// [highlight] 高光配置；[shape] 圆角形状（读取四角半径，null=胶囊/全圆角）。
/// 目前实现 single-peak 变体（默认 [BloomStroke.dualPeak]=false，覆盖全部内置预设）。
class MiuixHighlight extends StatefulWidget {
  const MiuixHighlight({
    super.key,
    this.highlight = Highlight.defaultHighlight,
    this.shape,
    this.child,
  });

  final Highlight highlight;
  final ShapeBorder? shape;
  final Widget? child;

  @override
  State<MiuixHighlight> createState() => _MiuixHighlightState();
}

class _MiuixHighlightState extends State<MiuixHighlight> {
  @override
  void initState() {
    super.initState();
    _BloomShaderProgram.ensureLoaded(_onLoaded);
  }

  void _onLoaded() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child ?? const SizedBox.expand();
    final program = _BloomShaderProgram.programOrNull;
    if (program == null ||
        widget.highlight.width <= 0 ||
        widget.highlight.alpha <= 0) {
      return child;
    }
    return _HighlightRenderWidget(
      highlight: widget.highlight,
      shape: widget.shape,
      program: program,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      child: child,
    );
  }
}

class _HighlightRenderWidget extends SingleChildRenderObjectWidget {
  const _HighlightRenderWidget({
    required this.highlight,
    required this.shape,
    required this.program,
    required this.devicePixelRatio,
    required Widget super.child,
  });

  final Highlight highlight;
  final ShapeBorder? shape;
  final ui.FragmentProgram program;
  final double devicePixelRatio;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderHighlight(
        highlight: highlight,
        shape: shape,
        shader: program.fragmentShader(),
        devicePixelRatio: devicePixelRatio,
      );

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderHighlight)
      ..highlight = highlight
      ..shape = shape
      ..devicePixelRatio = devicePixelRatio;
  }
}
class _RenderHighlight extends RenderProxyBox {
  _RenderHighlight({
    required this._highlight,
    required this._shape,
    required this._shader,
    required this._devicePixelRatio,
  });

  final ui.FragmentShader _shader;

  Highlight _highlight;
  set highlight(Highlight v) {
    if (_highlight == v) return;
    _highlight = v;
    markNeedsPaint();
  }

  ShapeBorder? _shape;
  set shape(ShapeBorder? v) {
    if (_shape == v) return;
    _shape = v;
    markNeedsPaint();
  }

  double _devicePixelRatio;
  set devicePixelRatio(double v) {
    if (_devicePixelRatio == v) return;
    _devicePixelRatio = v;
    markNeedsPaint();
  }

  @override
  void dispose() {
    _shader.dispose();
    super.dispose();
  }

  // 解析四角半径（像素），对应 setCornerRadiiUniform：[TL,TR,BL,BR]，各 clamp 到 minDim/2。
  List<double> _cornerRadiiPx(double wPx, double hPx) {
    final maxR = math.min(wPx, hPx) / 2.0;
    double all = maxR;
    if (_shape is RoundedRectangleBorder) {
      final br = (_shape as RoundedRectangleBorder).borderRadius
          .resolve(TextDirection.ltr);
      return [
        math.min(br.topLeft.x * _devicePixelRatio, maxR),
        math.min(br.topRight.x * _devicePixelRatio, maxR),
        math.min(br.bottomLeft.x * _devicePixelRatio, maxR),
        math.min(br.bottomRight.x * _devicePixelRatio, maxR),
      ];
    }
    return [all, all, all, all];
  }
  // 计算方向光的 dir/axis/intensity uniform，对应 applyLightUniforms。
  // 返回 (dirX,dirY,dirZ, colorR,G,B, intensity, axisX,axisY)。
  List<double> _lightUniforms(LightSource light, {required bool isPrimary}) {
    final dx = light.position.x - _lightRefX;
    final dy = light.position.y - _lightRefY;
    final dz = light.position.z;
    final len = math.max(math.sqrt(dx * dx + dy * dy + dz * dz), 1e-6);
    final nx = dx / len, ny = dy / len, nz = dz / len;
    final c = light.color;
    final intensity = c.a * light.intensity;
    // axis：法线 xy 归一化；退化时按上/下 fallback。
    final xyLen = math.sqrt(nx * nx + ny * ny);
    double axX, axY;
    if (xyLen > 1e-3) {
      axX = nx / xyLen;
      axY = ny / xyLen;
    } else {
      axX = 0.0;
      axY = isPrimary ? -1.0 : 1.0;
    }
    return [nx, ny, nz, c.r, c.g, c.b, intensity, axX, axY];
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset); // 先画子内容
    if (size.isEmpty) return;

    final dpr = _devicePixelRatio;
    final wPx = size.width * dpr;
    final hPx = size.height * dpr;
    final strokeWidthPx =
        math.min(_highlight.width * dpr, math.min(wPx, hPx) / 2.0);
    final innerPx = _highlight.style.innerBlurRadius * dpr;
    final radii = _cornerRadiiPx(wPx, hPx);
    final l1 = _lightUniforms(_highlight.style.primaryLight, isPrimary: true);
    final l2 = _lightUniforms(_highlight.style.secondaryLight, isPrimary: false);
    final sc = _highlight.style.color;

    // uniform 下标顺序须与 .frag 声明一致。
    _shader
      ..setFloat(0, wPx * 0.5)
      ..setFloat(1, hPx * 0.5)
      ..setFloat(2, (wPx * 0.5).floorToDouble())
      ..setFloat(3, (hPx * 0.5).floorToDouble())
      ..setFloat(4, radii[0])
      ..setFloat(5, radii[1])
      ..setFloat(6, radii[2])
      ..setFloat(7, radii[3])
      ..setFloat(8, strokeWidthPx)
      ..setFloat(9, innerPx)
      ..setFloat(10, innerPx * innerPx)
      ..setFloat(11, _highlight.alpha)
      // strokeColor（rgb，a=1）+ strokeAlphaMul
      ..setFloat(12, sc.r)
      ..setFloat(13, sc.g)
      ..setFloat(14, sc.b)
      ..setFloat(15, 1.0)
      ..setFloat(16, sc.a)
      // light1: dir(3) color(3) intensity(1)
      ..setFloat(17, l1[0])
      ..setFloat(18, l1[1])
      ..setFloat(19, l1[2])
      ..setFloat(20, l1[3])
      ..setFloat(21, l1[4])
      ..setFloat(22, l1[5])
      ..setFloat(23, l1[6])
      // light2
      ..setFloat(24, l2[0])
      ..setFloat(25, l2[1])
      ..setFloat(26, l2[2])
      ..setFloat(27, l2[3])
      ..setFloat(28, l2[4])
      ..setFloat(29, l2[5])
      ..setFloat(30, l2[6])
      // axis1, axis2
      ..setFloat(31, l1[7])
      ..setFloat(32, l1[8])
      ..setFloat(33, l2[7])
      ..setFloat(34, l2[8]);

    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(1.0 / dpr, 1.0 / dpr);
    final paint = Paint()
      ..shader = _shader
      ..blendMode = _highlight.style.blendMode;
    canvas.drawRect(Offset.zero & Size(wPx, hPx), paint);
    canvas.restore();
  }
}


