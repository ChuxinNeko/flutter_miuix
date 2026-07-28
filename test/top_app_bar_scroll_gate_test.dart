import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';
import 'package:flutter_test/flutter_test.dart';

/// 回归：ExitUntilCollapsed 的折叠量必须按内容位置直接映射。
///
/// 曾出现的 bug：heightOffset 靠累加 delta + 松手 snap 维护，snap 把它吸到
/// 端点后与真实滚动位置 pixels 解耦——折叠到居中小标题后轻微下滑，标题立即
/// 弹回大标题，而列表离顶部还有数千像素。正确语义（对齐 iOS/Kotlin
/// ExitUntilCollapsedScrollBehavior）：heightOffset = -(pixels - minScrollExtent)，
/// 由 setter 钳到 [heightOffsetLimit, 0]，只有内容滚回顶部过渡区间
/// [minScrollExtent, minScrollExtent + 展开量] 内才逐像素展开，中途上/下滑不跳变。
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

  testWidgets('折叠后在顶部区间中段轻微下滑只逐像素展开，不跳回大标题', (tester) async {
    // 用户报告的场景：折叠到居中小标题（pixels≈40）后往下拨一点点。
    final ctx = await pumpContext(tester);
    final b = behavior(offset: -expansion);
    update(b, ctx, 38, -2); // 40 → 38：仅展开 2px，绝不整段弹回。
    expect(b.state.heightOffset, -38);
    update(b, ctx, 40, 2); // 再上滑回 40：重新完全折叠。
    expect(b.state.heightOffset, -expansion);
  });

  testWidgets('顶部下拉的 OverscrollNotification 保持完全展开', (tester) async {
    // 顶部（pixels=0）标题恒为完全展开；过顶下拉不改变折叠量（只出现回弹辉光）。
    final ctx = await pumpContext(tester);
    final b = behavior(offset: -expansion);
    b.handleScroll(OverscrollNotification(
      metrics: metrics(0),
      context: ctx,
      overscroll: -15,
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
