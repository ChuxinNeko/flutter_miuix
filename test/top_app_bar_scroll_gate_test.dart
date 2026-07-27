import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';
import 'package:flutter_test/flutter_test.dart';

/// 回归：ExitUntilCollapsed 的展开必须按内容位置门控。
///
/// 曾出现的 bug：上滑/下滑对称累加 heightOffset，导致在列表任意位置轻微
/// 下滑都会让已折叠的小标题立即回到大标题样式（松手后还被 snap 完整弹开），
/// 而此时列表离顶部还有数千像素。正确语义（对齐 Kotlin
/// ExitUntilCollapsedScrollBehavior）：下滑只有在内容滚回顶部过渡区间
/// [minScrollExtent, minScrollExtent + 展开量] 内才逐像素展开。
void main() {
  const expansion = 40.0; // 大标题展开量，heightOffsetLimit = -40。

  FixedScrollMetrics metrics(
    double pixels, {
    AxisDirection axisDirection = AxisDirection.down,
  }) => FixedScrollMetrics(
    minScrollExtent: 0,
    maxScrollExtent: 2000,
    pixels: pixels,
    viewportDimension: 800,
    axisDirection: axisDirection,
    devicePixelRatio: 3,
  );

  MiuixExitUntilCollapsedScrollBehavior behavior({double offset = 0}) {
    final b = MiuixExitUntilCollapsedScrollBehavior();
    b.state.heightOffsetLimit = -expansion;
    b.state.heightOffset = offset;
    return b;
  }

  // ScrollNotification.context 非空，pump 一个最小 widget 拿真实 context。
  Future<BuildContext> pumpContext(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    return tester.element(find.byType(SizedBox));
  }

  /// pixelsAfter 为本次滚动后的位置，delta 为本次增量（>0 上滑）。
  void update(
    MiuixExitUntilCollapsedScrollBehavior b,
    BuildContext context,
    double pixelsAfter,
    double delta, {
    AxisDirection axisDirection = AxisDirection.down,
  }) {
    b.handleScroll(ScrollUpdateNotification(
      metrics: metrics(pixelsAfter, axisDirection: axisDirection),
      context: context,
      scrollDelta: delta,
    ));
  }

  testWidgets('顶部上滑逐像素折叠到 heightOffsetLimit', (tester) async {
    final ctx = await pumpContext(tester);
    final b = behavior();
    update(b, ctx, 15, 15);
    expect(b.state.heightOffset, -15);
    update(b, ctx, 60, 45); // 越过过渡区上界，超出部分不再累加（setter 钳制）。
    expect(b.state.heightOffset, -expansion);
  });

  testWidgets('列表中部下滑不展开（回归：中部微下滑标题弹回大标题）', (tester) async {
    final ctx = await pumpContext(tester);
    final b = behavior(offset: -expansion);
    update(b, ctx, 990, -10);
    update(b, ctx, 900, -90);
    expect(b.state.heightOffset, -expansion, reason: '离顶部尚远，必须保持折叠');
  });

  testWidgets('滚回顶部过渡区间内才逐像素展开', (tester) async {
    final ctx = await pumpContext(tester);
    final b = behavior(offset: -expansion);
    update(b, ctx, 60, -940); // 1000 → 60，仍在过渡区上界(40)之外。
    expect(b.state.heightOffset, -expansion);
    update(b, ctx, 35, -25); // 60 → 35：区间内行程 40→35 = 5px。
    expect(b.state.heightOffset, -35);
    update(b, ctx, 0, -35); // 回到顶部，完全展开。
    expect(b.state.heightOffset, 0);
  });

  testWidgets('iOS 弹性下拉越过顶部的行程也计入展开', (tester) async {
    final ctx = await pumpContext(tester);
    final b = behavior(offset: -expansion);
    update(b, ctx, -12, -52); // 40 → -12：区间内行程 40px + 过顶 12px。
    expect(b.state.heightOffset, 0);
  });

  testWidgets('回弹归位（min 以下的上滑行程）不折叠', (tester) async {
    final ctx = await pumpContext(tester);
    final b = behavior();
    update(b, ctx, 0, 12); // -12 → 0：全程在 min 以下。
    expect(b.state.heightOffset, 0);
  });

  testWidgets('Clamping 物理顶部下拉的 OverscrollNotification 驱动展开', (tester) async {
    final ctx = await pumpContext(tester);
    final b = behavior(offset: -expansion);
    b.handleScroll(OverscrollNotification(
      metrics: metrics(0),
      context: ctx,
      overscroll: -15,
    ));
    expect(b.state.heightOffset, -25);
    b.handleScroll(OverscrollNotification(
      metrics: metrics(0),
      context: ctx,
      overscroll: -400, // 大幅过冲：钳制在完全展开。
    ));
    expect(b.state.heightOffset, 0);
  });

  testWidgets('横向滚动通知不驱动折叠', (tester) async {
    final ctx = await pumpContext(tester);
    final b = behavior();
    update(b, ctx, 100, 100, axisDirection: AxisDirection.right);
    expect(b.state.heightOffset, 0);
  });
}
