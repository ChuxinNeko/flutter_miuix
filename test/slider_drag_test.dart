// 验证：MiuixSlider / MiuixVerticalSlider / MiuixRangeSlider 拖动跟手。
// 回归此前的 bug——拖动时错用 details.delta（每帧增量）叠加到固定起点，
// 导致 thumb 几乎不动、拖不动只能点击。改用绝对本地坐标后，拖动应能
// 让值跨越大幅区间。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_miuix/miuix.dart';

void main() {
  testWidgets('MiuixSlider 水平拖动应大幅改变值（跟手）', (tester) async {
    double value = 0.0;
    await tester.pumpWidget(
      MiuixSystemTheme(
        child: Builder(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  child: StatefulBuilder(
                    builder: (context, setState) => MiuixSlider(
                      value: value,
                      onValueChanged: (v) => setState(() => value = v),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(MiuixSlider);
    final start = tester.getCenter(finder);
    // 从中心向右拖到接近右端。
    final gesture = await tester.startGesture(start);
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(12, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    // 拖到右侧后值应显著大于中点 0.5；bug 版会几乎停在 0.5 附近。
    expect(value, greaterThan(0.8),
        reason: '向右拖动后值应接近上限，说明拖动跟手');
  });

  testWidgets('MiuixVerticalSlider 垂直拖动应大幅改变值', (tester) async {
    double value = 0.5;
    await tester.pumpWidget(
      MiuixSystemTheme(
        child: Builder(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  height: 300,
                  child: StatefulBuilder(
                    builder: (context, setState) => MiuixVerticalSlider(
                      value: value,
                      onValueChanged: (v) => setState(() => value = v),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(MiuixVerticalSlider);
    final start = tester.getCenter(finder);
    // 向下拖：垂直默认下小上大，故值应下降。
    final gesture = await tester.startGesture(start);
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, 12));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(value, lessThan(0.2),
        reason: '向下拖动后值应接近下限，说明拖动跟手');
  });

  testWidgets('MiuixRangeSlider 拖动 end thumb 应大幅改变上界', (tester) async {
    double startV = 0.2;
    double endV = 0.5;
    await tester.pumpWidget(
      MiuixSystemTheme(
        child: Builder(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  child: StatefulBuilder(
                    builder: (context, setState) => MiuixRangeSlider(
                      startValue: startV,
                      endValue: endV,
                      onValueChanged: (r) => setState(() {
                        startV = r.$1;
                        endV = r.$2;
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final finder = find.byType(MiuixRangeSlider);
    final box = tester.getRect(finder);
    // end thumb 大约在 50% 处，从那里向右拖。
    final startPoint = Offset(box.left + box.width * 0.5, box.center.dy);
    final gesture = await tester.startGesture(startPoint);
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(12, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(endV, greaterThan(0.8),
        reason: '向右拖 end thumb 后上界应接近 1，说明拖动跟手');
    expect(startV, closeTo(0.2, 0.05), reason: 'start thumb 不应被带动');
  });
}
