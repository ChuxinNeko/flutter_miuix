# 移植分析：ColorPalette

- 复杂度: high
- 预估行数: 430
- 未移植依赖(unportedDeps): ColorPicker
- 已移植依赖(portedDeps): MiuixSquircleBorder, addSquircleRect, SquircleDefaults
- 计划公开 API(publicApi): MiuixColorPalette, MiuixColorPaletteDefaults
- 新增颜色 token: 无
- 新增文本样式: 无

## 平台/原生差异处理(platformConcerns)
Squircle clip/fill: source uses AGSL runtime-shader squircleClip/squircleBackground (Android API33+, else RoundedCornerShape fallback). Port with the already-ported MiuixSquircleBorder — squircleClip(16dp) on the grid Box -> ClipPath(clipper: squircle) or MiuixSquircleBorder as ShapeBorder; the 13dp preview squircleBackground -> ShapeDecoration(color, shape: MiuixSquircleBorder(cornerRadius:13)). Gestures: Compose pointerInput/awaitEachGesture (down + drag-while-pressed) -> Flutter Listener (onPointerDown/onPointerMove) or GestureDetector(onPanDown/onPanStart/onPanUpdate); must map local pointer position to cell every move and re-emit. Glow ring indicator uses Brush.radialGradient -> replicate with a CustomPainter using ui.Gradient.radial (4 color stops) then a white Stroke circle. Alpha slider (HsvAlphaSlider, comes from ColorPicker) uses SliderDefaults.SliderHapticEffect + SliderHapticState + LocalHapticFeedback -> Flutter HapticFeedback.selectionClick() or omit haptics. HSV<->Color: Hsv.toColor uses Compose Color.hsv and Color.toHsv quantizes RGB to 8-bit before conversion -> use Flutter's built-in HSVColor.fromAHSV/fromColor; to match exactly, quantize red/green/blue to (c*255).toInt()/255 before HSVColor.fromColor. No blur/sensors needed.

## 实现要点(keyNotes) — 严格按此复刻
DEFAULTS: rows=7, hueColumns=12, includeGrayColumn=true, showPreview=true, cornerRadius=16dp, indicatorRadius=10dp. totalColumns = hueColumns + (includeGrayColumn?1:0) = 13 default.

LAYOUT: outer Column, verticalArrangement spacedBy 12dp (use Column with SizedBox(height:12) between the up-to-3 children, or spacing).
- Preview (only if showPreview): Box fillMaxWidth, height 26dp, squircleBackground(color = lastEmittedColor ?? color, cornerRadius 13dp).
- PaletteCanvas Box: squircleClip(cornerRadius=16dp default), fillMaxWidth, height 180dp. Contains PaletteGrid (Canvas fillMaxSize) + selection indicator overlay.
- HsvAlphaSlider at bottom (from ColorPicker port).

STATE (StatefulWidget): selectedRow=0, selectedCol=0, alpha=color.alpha.clamp(0,1), lastEmittedColor (Color?), lastAcceptedHSV (Triple<h,s,v>? -> a small record/class). rowSV and grayV are memoized on rows.

EXTERNAL-COLOR SYNC (Compose LaunchedEffect(color,rows,hueColumns,includeGrayColumn) -> Flutter didUpdateWidget + initState): compute hsv=color.toHsv, h=hsv.h, s=hsv.s/100, v=hsv.v/100 (Hsv stores s,v in 0..100). currentHSV=(h,s,v). If lastAcceptedHSV != null && hsvEqualApprox(lastAcceptedHSV,currentHSV): just set alpha=color.alpha, lastAcceptedHSV=currentHSV, return. Else: isGray = includeGrayColumn && s<0.05; col = isGray? totalColumns-1 : ((h%360)/360*hueColumns).roundToInt().clamp(0,hueColumns-1); row = isGray? indexOfNearestGrayV(v,grayV) : indexOfNearestRowSV(s,v,rowSV); set selectedCol/selectedRow, alpha=color.alpha, lastAcceptedHSV=currentHSV.

hsvEqualApprox(a,b,epsH=1.5,eps=0.02): dhRaw=abs(a.h-b.h); dh=min(dhRaw,360-dhRaw); return dh<=epsH && abs(a.s-b.s)<=eps && abs(a.v-b.v)<=eps.
indexOfNearestGrayV(targetV,grayV): argmin over (targetV-grayV[i])^2.
indexOfNearestRowSV(targetS,targetV,rowSV): argmin over ds^2+dv^2 where ds=targetS-s[i], dv=targetV-v[i].

buildRowSV(rows) -> List<(s,v)>: rows<=1 -> [(1,1)]. rows==7 -> s=[0.10,0.35,0.70,1.00,1.00,1.00,1.00], v=[1.00,1.00,1.00,0.85,0.65,0.45,0.20]. else: topBrightCut=min(0.34, 2/(rows-1)); for i in 0..rows-1: t=i/(rows-1); sRamp=(t/0.35).clamp(0,1); s=(0.10+0.90*sRamp).clamp(0,1); v = t<=topBrightCut ? 1 : lerp(1,0.20, ((t-topBrightCut)/(1-topBrightCut)).clamp(0,1)).
buildGrayV(rows): rows<=1 -> [1]; else List(rows){ i -> 1 - i/(rows-1) }.
cellColor(col,row,rowSV,grayV,hueColumns,includeGrayColumn): (s,v)=rowSV[row]; if includeGrayColumn && col==totalColumns-1 -> HSVColor.fromAHSV(1,0,0, grayV[row]) i.e. Hsv(0,0,grayV[row]*100); else step=360/hueColumns; h=(col*step)%360; HSVColor.fromAHSV(1, h, s, v) i.e. Hsv(h, s*100, v*100).

GRID DRAWING (CustomPainter, fillMaxSize): w=size.width.toInt(), h=size.height.toInt() (INTEGER pixel edges to avoid seams). colEdges[i] = (i*w)~/totalColumns for i in 0..totalColumns; rowEdges[i]=(i*h)~/rows. For r in 0..rows-1: top=rowEdges[r], bottom=rowEdges[r+1], cellH=bottom-top; for c in 0..totalColumns-1: start=colEdges[c], end=colEdges[c+1], cellW=end-start; color=precomputed[r][c]; left = isRtl ? width-end : start; drawRect(Rect.fromLTWH(left, top, cellW, cellH), Paint()..color). Precompute the rows x totalColumns color array once (memoize on rows/hueColumns/includeGrayColumn).

pointToCell(pos,size,rows,totalColumns,isRtl): x=pos.x.clamp(0, width-1); y=pos.y.clamp(0, height-1); col=((x/width)*totalColumns).toInt().clamp(0,totalColumns-1); if isRtl col=totalColumns-1-col; row=((y/height)*rows).toInt().clamp(0,rows-1); return (row,col). On down and every move while pressed: set selectedRow/Col, newColor=cellColor(c,r,...).withOpacity(alpha), lastAcceptedHSV = newColor.toHsv normalized, lastEmittedColor=newColor, onColorChanged(newColor).

SELECTION INDICATOR (positioned Box, size = indicatorRadius*2 = 20dp default; must live INSIDE the squircle-clipped Box so it clips). Center at cell: using integer edges start=colEdges[selectedCol], end=colEdges[selectedCol+1], top=rowEdges[selectedRow], bottom=rowEdges[selectedRow+1]; cx=(start+end)/2, cy=(top+bottom)/2; place top-left at (cx - indicatorSize/2, cy - indicatorSize/2) (Compose rounds to int). Draw via CustomPainter: strokeWidth=6dp, halfStroke=3dp, glowSpread=2dp, glowColor=Black@0.25. ringCenterRadius = minDimension/2 - halfStroke; gradientRadius = ringCenterRadius + halfStroke + glowSpread. RadialGradient centered, radius=gradientRadius, 4 stops: [ (ringCenterRadius-halfStroke-glowSpread).clampAtLeast(0)/gradientRadius -> transparent, (ringCenterRadius-halfStroke)/gradientRadius -> glowColor, (ringCenterRadius+halfStroke)/gradientRadius -> glowColor, (ringCenterRadius+halfStroke+glowSpread)/gradientRadius -> transparent ]. drawCircle(center, gradientRadius, fill=glow gradient); then drawCircle(center, ringCenterRadius, white, Stroke width=strokeWidth). NOTE: identical glow-ring geometry is reused by ColorPicker's SliderIndicator (20dp) — share one painter helper.

HsvAlphaSlider (from ColorPicker port): pass currentHue=h, currentSaturation=s, currentValue=v, currentAlpha=alpha, onAlphaChanged. baseColor for the slider = cellColor(selectedCol,selectedRow,...); hsvBase=baseColor.toHsv; h=hsvBase.h, s=hsvBase.s/100, v=hsvBase.v/100. onAlphaChanged(a): alpha=a; newColor=baseColor.withOpacity(a); lastAcceptedHSV from baseColor.toHsv; lastEmittedColor=newColor; onColorChanged(newColor). Its internals (ColorSlider): height 26dp, indicator 20dp, pill clip (CircleShape -> BorderRadius 13 / StadiumBorder), horizontalGradient startX=13 endX=width-13 Clamp of [baseColor@0, baseColor@1], 0.5dp Gray@0.1 border stroke, checkerboard behind (cell 3dp, light 0xFFCCCCCC, dark 0xFFAAAAAA drawn as offset squares per row). handleSliderInteraction: effectiveWidth=totalWidth-sliderSize(26); constrainedX=posX.clamp(13, totalWidth-13); value=((constrainedX-13)/effectiveWidth).clamp(0,1).

COLORS: no MiuixTheme/colorScheme/textStyles tokens used at all — all colors are literal (Black@0.25, White, Gray@0.1, transparent, 0xFFCCCCCC, 0xFFAAAAAA) or HSV-computed. No MiuixText/MiuixContentColor. lerp is Compose util lerp(start,stop,frac) -> start+(stop-start)*frac.
