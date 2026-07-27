import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';
import 'package:flutter_test/flutter_test.dart';

/// 回归：折叠过程中大标题必须始终留在屏幕内，且折叠终点为居中小标题。
///
/// 曾出现的 bug：MiuixIconButton 的 Center 未设 widthFactor，在顶栏测量层的
/// 有界宽松约束下被撑满整屏宽（navWidth=屏宽），标题避让逻辑随之把折叠目标
/// 推到屏幕外——滚动时标题"向右飞出屏幕"。
void main() {
  testWidgets('带返回键时折叠标题始终在屏幕内并收敛到居中', (tester) async {
    final behavior = MiuixExitUntilCollapsedScrollBehavior();
    await tester.pumpWidget(
      MiuixTheme(
        data: MiuixThemeData.light(),
        child: MaterialApp(
          home: MiuixScaffold(
            topBar: MiuixTopAppBar(
              title: '音源配置',
              scrollBehavior: behavior,
              navigationIcon: MiuixIconButton(
                onPressed: () {},
                child: MiuixIcon(
                  vector: MiuixIcons.extended.byName('back')!,
                  size: 24,
                ),
              ),
            ),
            content: (padding) => MiuixScrollBehaviorListener(
              behavior: behavior,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: padding,
                children: [
                  for (var i = 0; i < 40; i++)
                    SizedBox(height: 56, child: Text('item $i')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final screenWidth = tester.view.physicalSize.width /
        tester.view.devicePixelRatio;
    // 顶栏渲染层里的标题（排除 Offstage 测量层副本）。
    Iterable<RenderBox> titleBoxes() => find
        .text('音源配置')
        .evaluate()
        .map((e) => e.renderObject)
        .whereType<RenderBox>()
        .where((box) => box.hasSize && box.localToGlobal(Offset.zero).dy >= 0);

    // 逐步上滑折叠，标题任何时刻都不得越出屏幕。
    for (var step = 0; step < 12; step++) {
      await tester.drag(
        find.byType(ListView),
        const Offset(0, -12),
        warnIfMissed: false,
      );
      await tester.pump();
      for (final box in titleBoxes()) {
        final left = box.localToGlobal(Offset.zero).dx;
        expect(left, greaterThanOrEqualTo(0));
        expect(
          left + box.size.width,
          lessThanOrEqualTo(screenWidth + 0.5),
          reason: 'collapse step $step 标题越出屏幕右侧',
        );
      }
    }

    // 完全折叠：一次大幅上滑越过折叠区并等吸附动画结束（不能直接改
    // heightOffset——残留的吸附动画会在下一帧覆盖它）。
    await tester.drag(
      find.byType(ListView),
      const Offset(0, -400),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(behavior.state.collapsedFraction, closeTo(1, 0.05));
    final centers = titleBoxes()
        .map((box) =>
            box.localToGlobal(Offset.zero).dx + box.size.width / 2)
        .toList();
    expect(
      centers.any((center) => (center - screenWidth / 2).abs() < 40),
      isTrue,
      reason: '折叠后标题未居中，副本中心点=$centers',
    );
  });
}
