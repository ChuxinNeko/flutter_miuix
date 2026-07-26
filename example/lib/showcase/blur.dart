import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';

import 'common.dart';

/// 模糊 / 液态玻璃演示（批次 5 阶段 5A）。
///
/// 背景用 [MiuixLayerBackdropCapture] 捕获，前景用 [MiuixTextureBlur] 对捕获的
/// 背景做高斯模糊 + 颜色控制，裁成 squircle 圆角面板。滑块调节模糊半径。
class BlurShowcase extends StatefulWidget {
  const BlurShowcase({super.key});

  @override
  State<BlurShowcase> createState() => _BlurShowcaseState();
}

class _BlurShowcaseState extends State<BlurShowcase> {
  final MiuixLayerBackdrop _backdrop = MiuixLayerBackdrop();
  final MiuixLayerBackdrop _hlBackdrop = MiuixLayerBackdrop();
  double _radius = 20;
  double _saturation = 1.5;

  @override
  void dispose() {
    _backdrop.dispose();
    _hlBackdrop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = MiuixTheme.of(context).colors;
    return ShowcasePage(
      title: '模糊 Blur',
      subtitle: 'MiuixTextureBlur / 液态玻璃',
      sections: [
        ShowcaseSection('基础模糊 TextureBlur', [
          ShowcaseBlock(children: [
            SizedBox(
              height: 280,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // 背景层：被 backdrop 捕获。
                    Positioned.fill(
                      child: MiuixLayerBackdropCapture(
                        backdrop: _backdrop,
                        child: const _ColorfulBackground(),
                      ),
                    ),
                    // 前景模糊面板。
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 140,
                        child: MiuixTextureBlur(
                          backdrop: _backdrop,
                          shape: const MiuixSquircleBorder(
                            cornerRadius: 28,
                          ),
                          blurRadius: _radius,
                          colors: MiuixBlurDefaults.blurColors(
                            saturation: _saturation,
                          ),
                          child: Center(
                            child: MiuixText(
                              '液态玻璃\nR=${_radius.toInt()}',
                              textAlign: TextAlign.center,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ]),
        ShowcaseSection('参数', [
          ShowcaseItem(
            label: '模糊半径',
            child: MiuixSlider(
              value: _radius,
              min: 0,
              max: 60,
              onValueChanged: (v) => setState(() => _radius = v),
            ),
          ),
          ShowcaseItem(
            label: '饱和度',
            child: MiuixSlider(
              value: _saturation,
              min: 0,
              max: 2,
              onValueChanged: (v) => setState(() => _saturation = v),
            ),
          ),
        ]),
        ShowcaseSection('高光边框 Highlight', [
          ShowcaseBlock(children: [
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: MiuixLayerBackdropCapture(
                        backdrop: _hlBackdrop,
                        child: const _ColorfulBackground(),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 120,
                        // 模糊面板 + bloom 高光边框叠加。
                        child: MiuixHighlight(
                          highlight: Highlight.glassStrokeMiddleLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: MiuixTextureBlur(
                            backdrop: _hlBackdrop,
                            shape: const MiuixSquircleBorder(cornerRadius: 28),
                            blurRadius: 24,
                            colors: MiuixBlurDefaults.blurColors(saturation: 1.5),
                            child: Center(
                              child: MiuixText(
                                '玻璃卡片 + 高光',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ]),
      ],
    );
  }
}

/// 彩色背景图，用来凸显模糊效果。用彩色铅笔照片作为丰富的高频细节，
/// 能更直观地展示高斯模糊 / 渐变模糊 / 饱和度调节的差异。
class _ColorfulBackground extends StatelessWidget {
  const _ColorfulBackground();

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage('assets/pencil.jpg'),
      fit: BoxFit.cover,
    );
  }
}
