// Miuix Flutter 移植版 - ColorPalette
// 源自 compose-miuix-ui/miuix 的 ColorPalette.kt。
// HSV 网格调色板，支持灰阶列、透明度调节、拖动选色与 RTL 布局。
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/miuix_squircle.dart';

/// [MiuixColorPalette] 的默认尺寸与网格参数。
class MiuixColorPaletteDefaults {
  MiuixColorPaletteDefaults._();

  /// 默认色彩行数。
  static const int rows = 7;

  /// 默认色相列数。
  static const int hueColumns = 12;

  /// 默认显示灰阶列。
  static const bool includeGrayColumn = true;

  /// 默认显示颜色预览。
  static const bool showPreview = true;

  /// 调色板网格的默认圆角半径。
  static const double cornerRadius = 16;

  /// 选中指示器的默认半径。
  static const double indicatorRadius = 10;

  /// 颜色预览和透明度滑块的高度。
  static const double controlHeight = 26;

  /// 调色板网格高度。
  static const double paletteHeight = 180;

  /// 子项之间的垂直间距。
  static const double spacing = 12;
}

/// Miuix 风格的 HSV 网格调色板。对应 Kotlin `ColorPalette`。
///
/// [color] 是外部受控颜色；用户在网格中按下或拖动，以及调节透明度时，
/// 都会通过 [onColorChanged] 返回新颜色。默认网格为 7 行、12 个色相列，
/// 并在末尾附加一个灰阶列。
class MiuixColorPalette extends StatefulWidget {
  const MiuixColorPalette({
    super.key,
    required this.color,
    required this.onColorChanged,
    this.rows = MiuixColorPaletteDefaults.rows,
    this.hueColumns = MiuixColorPaletteDefaults.hueColumns,
    this.includeGrayColumn = MiuixColorPaletteDefaults.includeGrayColumn,
    this.showPreview = MiuixColorPaletteDefaults.showPreview,
    this.cornerRadius = MiuixColorPaletteDefaults.cornerRadius,
    this.indicatorRadius = MiuixColorPaletteDefaults.indicatorRadius,
  })  : assert(rows > 0, 'rows must be greater than zero'),
        assert(hueColumns > 0, 'hueColumns must be greater than zero'),
        assert(cornerRadius >= 0, 'cornerRadius must not be negative'),
        assert(indicatorRadius >= 0, 'indicatorRadius must not be negative');

  /// 当前颜色。
  final Color color;

  /// 用户选色或调节透明度时调用。
  final ValueChanged<Color> onColorChanged;

  /// 色彩网格行数。
  final int rows;

  /// 色相列数。
  final int hueColumns;

  /// 是否在色相列后显示灰阶列。
  final bool includeGrayColumn;

  /// 是否显示顶部颜色预览。
  final bool showPreview;

  /// 网格 squircle 圆角半径。
  final double cornerRadius;

  /// 选中指示器圆环半径。
  final double indicatorRadius;

  @override
  State<MiuixColorPalette> createState() => _MiuixColorPaletteState();
}

class _MiuixColorPaletteState extends State<MiuixColorPalette> {
  late List<(double, double)> _rowSV;
  late List<double> _grayV;
  late List<List<Color>> _colors;

  int _selectedRow = 0;
  int _selectedCol = 0;
  double _alpha = 1;
  Color? _lastEmittedColor;
  (double, double, double)? _lastAcceptedHSV;

  @override
  void initState() {
    super.initState();
    _rebuildPaletteData();
    _syncExternalColor();
  }

  @override
  void didUpdateWidget(MiuixColorPalette oldWidget) {
    super.didUpdateWidget(oldWidget);
    final gridChanged = oldWidget.rows != widget.rows ||
        oldWidget.hueColumns != widget.hueColumns ||
        oldWidget.includeGrayColumn != widget.includeGrayColumn;
    if (gridChanged) _rebuildPaletteData();
    if (gridChanged || oldWidget.color != widget.color) {
      _syncExternalColor();
    }
  }

  int get _totalColumns =>
      widget.hueColumns + (widget.includeGrayColumn ? 1 : 0);

  void _rebuildPaletteData() {
    _rowSV = _buildRowSV(widget.rows);
    _grayV = _buildGrayV(widget.rows);
    final totalColumns = _totalColumns;
    _colors = List.generate(
      widget.rows,
      (row) => List.generate(
        totalColumns,
        (col) => _cellColor(col, row),
        growable: false,
      ),
      growable: false,
    );
  }

  void _syncExternalColor() {
    final hsv = _quantizedHsv(widget.color);
    final current = (hsv.hue, hsv.saturation, hsv.value);
    if (_lastAcceptedHSV case final accepted?
        when _hsvEqualApprox(accepted, current)) {
      _alpha = widget.color.a.clamp(0.0, 1.0);
      _lastAcceptedHSV = current;
      return;
    }

    final isGray = widget.includeGrayColumn && hsv.saturation < 0.05;
    final col = isGray
        ? _totalColumns - 1
        : (((hsv.hue % 360) / 360) * widget.hueColumns)
            .round()
            .clamp(0, widget.hueColumns - 1);
    final row = isGray
        ? _indexOfNearestGrayV(hsv.value, _grayV)
        : _indexOfNearestRowSV(hsv.saturation, hsv.value, _rowSV);

    _selectedCol = col;
    _selectedRow = row;
    _alpha = widget.color.a.clamp(0.0, 1.0);
    _lastAcceptedHSV = current;
  }

  Color _cellColor(int col, int row) {
    final (saturation, value) = _rowSV[row];
    if (widget.includeGrayColumn && col == _totalColumns - 1) {
      return HSVColor.fromAHSV(1, 0, 0, _grayV[row]).toColor();
    }
    final step = 360 / widget.hueColumns;
    final hue = (col * step) % 360;
    return HSVColor.fromAHSV(1, hue, saturation, value).toColor();
  }

  void _selectCell(int row, int col) {
    final baseColor = _colors[row][col];
    final newColor = baseColor.withValues(alpha: _alpha);
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _lastAcceptedHSV = _normalizedHsv(baseColor);
      _lastEmittedColor = newColor;
    });
    widget.onColorChanged(newColor);
  }

  void _changeAlpha(double value) {
    final alpha = value.clamp(0.0, 1.0);
    final baseColor = _colors[_selectedRow][_selectedCol];
    final newColor = baseColor.withValues(alpha: alpha);
    setState(() {
      _alpha = alpha;
      _lastAcceptedHSV = _normalizedHsv(baseColor);
      _lastEmittedColor = newColor;
    });
    widget.onColorChanged(newColor);
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (widget.showPreview) {
      children.add(
        Semantics(
          label: '当前颜色预览',
          image: true,
          child: SizedBox(
            height: MiuixColorPaletteDefaults.controlHeight,
            width: double.infinity,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: _lastEmittedColor ?? widget.color,
                shape: const MiuixSquircleBorder(cornerRadius: 13),
              ),
            ),
          ),
        ),
      );
    }
    children.add(
      _PaletteCanvas(
        rows: widget.rows,
        totalColumns: _totalColumns,
        colors: _colors,
        cornerRadius: widget.cornerRadius,
        indicatorRadius: widget.indicatorRadius,
        selectedRow: _selectedRow,
        selectedCol: _selectedCol,
        onSelect: _selectCell,
      ),
    );
    children.add(
      _AlphaSlider(
        value: _alpha,
        baseColor: _colors[_selectedRow][_selectedCol],
        onChanged: _changeAlpha,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i != 0)
            const SizedBox(height: MiuixColorPaletteDefaults.spacing),
          children[i],
        ],
      ],
    );
  }
}

class _PaletteCanvas extends StatefulWidget {
  const _PaletteCanvas({
    required this.rows,
    required this.totalColumns,
    required this.colors,
    required this.cornerRadius,
    required this.indicatorRadius,
    required this.selectedRow,
    required this.selectedCol,
    required this.onSelect,
  });

  final int rows;
  final int totalColumns;
  final List<List<Color>> colors;
  final double cornerRadius;
  final double indicatorRadius;
  final int selectedRow;
  final int selectedCol;
  final void Function(int row, int col) onSelect;

  @override
  State<_PaletteCanvas> createState() => _PaletteCanvasState();
}

class _PaletteCanvasState extends State<_PaletteCanvas> {
  int? _pointer;

  void _handlePosition(Offset position, Size size, bool isRtl) {
    if (size.width <= 0 || size.height <= 0) return;
    final x = position.dx.clamp(0.0, math.max(0.0, size.width - 1));
    final y = position.dy.clamp(0.0, math.max(0.0, size.height - 1));
    var col = ((x / size.width) * widget.totalColumns)
        .toInt()
        .clamp(0, widget.totalColumns - 1);
    if (isRtl) col = widget.totalColumns - 1 - col;
    final row = ((y / size.height) * widget.rows)
        .toInt()
        .clamp(0, widget.rows - 1);
    widget.onSelect(row, col);
  }

  void _moveSelection(int rowDelta, int colDelta) {
    final row = (widget.selectedRow + rowDelta).clamp(0, widget.rows - 1);
    final col = (widget.selectedCol + colDelta)
        .clamp(0, widget.totalColumns - 1);
    widget.onSelect(row, col);
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final value =
        '第 ${widget.selectedRow + 1} 行，第 ${widget.selectedCol + 1} 列';

    return Semantics(
      label: '颜色调色板',
      value: value,
      hint: '拖动选择颜色',
      onIncrease: () => _moveSelection(0, 1),
      onDecrease: () => _moveSelection(0, -1),
      child: SizedBox(
        height: MiuixColorPaletteDefaults.paletteHeight,
        child: ClipPath(
          clipper: _SquircleClipper(widget.cornerRadius),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(
                constraints.maxWidth,
                MiuixColorPaletteDefaults.paletteHeight,
              );
              return Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  if (_pointer != null) return;
                  _pointer = event.pointer;
                  _handlePosition(event.localPosition, size, isRtl);
                },
                onPointerMove: (event) {
                  if (_pointer == event.pointer) {
                    _handlePosition(event.localPosition, size, isRtl);
                  }
                },
                onPointerUp: (event) {
                  if (_pointer == event.pointer) _pointer = null;
                },
                onPointerCancel: (event) {
                  if (_pointer == event.pointer) _pointer = null;
                },
                child: CustomPaint(
                  painter: _PalettePainter(
                    rows: widget.rows,
                    totalColumns: widget.totalColumns,
                    colors: widget.colors,
                    selectedRow: widget.selectedRow,
                    selectedCol: widget.selectedCol,
                    indicatorRadius: widget.indicatorRadius,
                    isRtl: isRtl,
                  ),
                  size: Size.infinite,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SquircleClipper extends CustomClipper<Path> {
  const _SquircleClipper(this.cornerRadius);

  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    addSquircleRect(path, size.width, size.height, cornerRadius);
    return path;
  }

  @override
  bool shouldReclip(_SquircleClipper oldClipper) =>
      cornerRadius != oldClipper.cornerRadius;
}

class _PalettePainter extends CustomPainter {
  const _PalettePainter({
    required this.rows,
    required this.totalColumns,
    required this.colors,
    required this.selectedRow,
    required this.selectedCol,
    required this.indicatorRadius,
    required this.isRtl,
  });

  final int rows;
  final int totalColumns;
  final List<List<Color>> colors;
  final int selectedRow;
  final int selectedCol;
  final double indicatorRadius;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width.toInt();
    final height = size.height.toInt();
    final colEdges = List.generate(
      totalColumns + 1,
      (i) => (i * width) ~/ totalColumns,
      growable: false,
    );
    final rowEdges = List.generate(
      rows + 1,
      (i) => (i * height) ~/ rows,
      growable: false,
    );

    for (var row = 0; row < rows; row++) {
      final top = rowEdges[row].toDouble();
      final bottom = rowEdges[row + 1].toDouble();
      for (var col = 0; col < totalColumns; col++) {
        final start = colEdges[col].toDouble();
        final end = colEdges[col + 1].toDouble();
        final left = isRtl ? width - end : start;
        canvas.drawRect(
          Rect.fromLTWH(left, top, end - start, bottom - top),
          Paint()..color = colors[row][col],
        );
      }
    }

    final physicalCol = isRtl ? totalColumns - 1 - selectedCol : selectedCol;
    final start = colEdges[physicalCol];
    final end = colEdges[physicalCol + 1];
    final top = rowEdges[selectedRow];
    final bottom = rowEdges[selectedRow + 1];
    final center = Offset((start + end) / 2, (top + bottom) / 2);
    _paintGlowRing(canvas, center, indicatorRadius * 2);
  }

  @override
  bool shouldRepaint(_PalettePainter oldDelegate) =>
      rows != oldDelegate.rows ||
      totalColumns != oldDelegate.totalColumns ||
      !identical(colors, oldDelegate.colors) ||
      selectedRow != oldDelegate.selectedRow ||
      selectedCol != oldDelegate.selectedCol ||
      indicatorRadius != oldDelegate.indicatorRadius ||
      isRtl != oldDelegate.isRtl;
}

class _AlphaSlider extends StatefulWidget {
  const _AlphaSlider({
    required this.value,
    required this.baseColor,
    required this.onChanged,
  });

  final double value;
  final Color baseColor;
  final ValueChanged<double> onChanged;

  @override
  State<_AlphaSlider> createState() => _AlphaSliderState();
}

class _AlphaSliderState extends State<_AlphaSlider> {
  int? _pointer;
  bool _edgeFeedbackTriggered = false;

  void _begin(double x, double width, bool isRtl) {
    final value = _valueAt(x, width, isRtl);
    widget.onChanged(value);
    _edgeFeedbackTriggered =
        (value == 0 || value == 1) && value == widget.value;
  }

  void _update(double x, double width, bool isRtl) {
    final value = _valueAt(x, width, isRtl);
    widget.onChanged(value);
    final atEdge = value == 0 || value == 1;
    if (atEdge && !_edgeFeedbackTriggered) {
      HapticFeedback.selectionClick();
      _edgeFeedbackTriggered = true;
    } else if (!atEdge) {
      _edgeFeedbackTriggered = false;
    }
  }

  double _valueAt(double x, double width, bool isRtl) {
    final logicalX = isRtl ? width - x : x;
    const half = MiuixColorPaletteDefaults.controlHeight / 2;
    final effectiveWidth = width - MiuixColorPaletteDefaults.controlHeight;
    if (effectiveWidth <= 0) return 0;
    final constrained = logicalX.clamp(half, width - half);
    return ((constrained - half) / effectiveWidth).clamp(0.0, 1.0);
  }

  void _semanticChange(double delta) {
    widget.onChanged((widget.value + delta).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final percent = (widget.value * 100).round();
    return Semantics(
      label: '透明度',
      value: '$percent%',
      increasedValue: '${math.min(100, percent + 5)}%',
      decreasedValue: '${math.max(0, percent - 5)}%',
      onIncrease: () => _semanticChange(0.05),
      onDecrease: () => _semanticChange(-0.05),
      child: SizedBox(
        height: MiuixColorPaletteDefaults.controlHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            MiuixColorPaletteDefaults.controlHeight / 2,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  if (_pointer != null) return;
                  _pointer = event.pointer;
                  _begin(event.localPosition.dx, width, isRtl);
                },
                onPointerMove: (event) {
                  if (_pointer == event.pointer) {
                    _update(event.localPosition.dx, width, isRtl);
                  }
                },
                onPointerUp: (event) {
                  if (_pointer == event.pointer) _pointer = null;
                },
                onPointerCancel: (event) {
                  if (_pointer == event.pointer) _pointer = null;
                },
                child: CustomPaint(
                  painter: _AlphaSliderPainter(
                    value: widget.value,
                    baseColor: widget.baseColor,
                    isRtl: isRtl,
                  ),
                  size: Size.infinite,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AlphaSliderPainter extends CustomPainter {
  const _AlphaSliderPainter({
    required this.value,
    required this.baseColor,
    required this.isRtl,
  });

  final double value;
  final Color baseColor;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 3.0;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xffcccccc),
    );
    final darkPaint = Paint()..color = const Color(0xffaaaaaa);
    final rows = (size.height / cell).ceil().clamp(1, 1 << 20);
    for (var row = 0; row < rows; row++) {
      var x = row.isEven ? cell : 0.0;
      final y = row * cell;
      while (x < size.width) {
        canvas.drawRect(
          Rect.fromLTRB(
            x,
            y,
            math.min(x + cell, size.width),
            math.min(y + cell, size.height),
          ),
          darkPaint,
        );
        x += cell * 2;
      }
    }

    final transparent = baseColor.withValues(alpha: 0);
    final opaque = baseColor.withValues(alpha: 1);
    final colors = isRtl ? <Color>[opaque, transparent] : <Color>[transparent, opaque];
    final half = size.height / 2;
    final shaderRect = Rect.fromLTRB(half, 0, size.width - half, size.height);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          shaderRect.centerLeft,
          shaderRect.centerRight,
          colors,
          const [0, 1],
          TileMode.clamp,
        ),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    final visualValue = isRtl ? 1 - value : value;
    final center = Offset(
      half + visualValue * (size.width - size.height),
      size.height / 2,
    );
    _paintGlowRing(canvas, center, 20);
  }

  @override
  bool shouldRepaint(_AlphaSliderPainter oldDelegate) =>
      value != oldDelegate.value ||
      baseColor != oldDelegate.baseColor ||
      isRtl != oldDelegate.isRtl;
}

void _paintGlowRing(Canvas canvas, Offset center, double size) {
  const strokeWidth = 6.0;
  const glowSpread = 2.0;
  const glowColor = Color.fromRGBO(0, 0, 0, 0.25);
  final halfStroke = strokeWidth / 2;
  final ringCenterRadius = size / 2 - halfStroke;
  final gradientRadius = ringCenterRadius + halfStroke + glowSpread;
  if (gradientRadius <= 0) return;

  double stop(double value) => value.clamp(0.0, 1.0);
  final stops = <double>[
    stop(math.max(0, ringCenterRadius - halfStroke - glowSpread) /
        gradientRadius),
    stop((ringCenterRadius - halfStroke) / gradientRadius),
    stop((ringCenterRadius + halfStroke) / gradientRadius),
    stop((ringCenterRadius + halfStroke + glowSpread) / gradientRadius),
  ];
  canvas.drawCircle(
    center,
    gradientRadius,
    Paint()
      ..shader = ui.Gradient.radial(
        center,
        gradientRadius,
        const [Colors.transparent, glowColor, glowColor, Colors.transparent],
        stops,
      ),
  );
  canvas.drawCircle(
    center,
    ringCenterRadius,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth,
  );
}

List<(double, double)> _buildRowSV(int rows) {
  if (rows <= 1) return const [(1, 1)];
  if (rows == 7) {
    const saturation = [0.10, 0.35, 0.70, 1.00, 1.00, 1.00, 1.00];
    const value = [1.00, 1.00, 1.00, 0.85, 0.65, 0.45, 0.20];
    return List.generate(7, (i) => (saturation[i], value[i]));
  }

  final topBrightCut = math.min(0.34, 2 / (rows - 1));
  return List.generate(rows, (i) {
    final t = i / (rows - 1);
    final saturationRamp = (t / 0.35).clamp(0.0, 1.0);
    final saturation = (0.10 + 0.90 * saturationRamp).clamp(0.0, 1.0);
    final value = t <= topBrightCut
        ? 1.0
        : 1 + (0.20 - 1) *
            ((t - topBrightCut) / (1 - topBrightCut)).clamp(0.0, 1.0);
    return (saturation, value);
  });
}

List<double> _buildGrayV(int rows) {
  if (rows <= 1) return const [1];
  return List.generate(rows, (i) => 1 - i / (rows - 1));
}

HSVColor _quantizedHsv(Color color) {
  final red = (color.r * 255).toInt().clamp(0, 255);
  final green = (color.g * 255).toInt().clamp(0, 255);
  final blue = (color.b * 255).toInt().clamp(0, 255);
  return HSVColor.fromColor(Color.fromARGB(255, red, green, blue));
}

(double, double, double) _normalizedHsv(Color color) {
  final hsv = _quantizedHsv(color);
  return (hsv.hue, hsv.saturation, hsv.value);
}

bool _hsvEqualApprox(
  (double, double, double) a,
  (double, double, double) b, {
  double hueEpsilon = 1.5,
  double epsilon = 0.02,
}) {
  final rawHueDifference = (a.$1 - b.$1).abs();
  final hueDifference = math.min(rawHueDifference, 360 - rawHueDifference);
  return hueDifference <= hueEpsilon &&
      (a.$2 - b.$2).abs() <= epsilon &&
      (a.$3 - b.$3).abs() <= epsilon;
}

int _indexOfNearestGrayV(double target, List<double> values) {
  var index = 0;
  var minimum = double.infinity;
  for (var i = 0; i < values.length; i++) {
    final difference = target - values[i];
    final distance = difference * difference;
    if (distance < minimum) {
      minimum = distance;
      index = i;
    }
  }
  return index;
}

int _indexOfNearestRowSV(
  double targetSaturation,
  double targetValue,
  List<(double, double)> values,
) {
  var index = 0;
  var minimum = double.infinity;
  for (var i = 0; i < values.length; i++) {
    final saturationDifference = targetSaturation - values[i].$1;
    final valueDifference = targetValue - values[i].$2;
    final distance = saturationDifference * saturationDifference +
        valueDifference * valueDifference;
    if (distance < minimum) {
      minimum = distance;
      index = i;
    }
  }
  return index;
}
