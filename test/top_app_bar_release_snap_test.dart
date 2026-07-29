import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';
import 'package:flutter_test/flutter_test.dart';

/// 回归：松手吸附与双层标题过渡（对齐 Kotlin 原版 `settleAppBar` / `TopAppBarLayout`）。
///
/// - 松手时停在折叠过渡区中段 → 列表吸附到全展开/全折叠的近端，标题绝不
///   停驻在半淡出状态。吸附动画的对象是列表位置而非 heightOffset，折叠量
///   始终是滚动位置的纯函数，不会重新引入"吸附后 offset 与 pixels 解耦"
///   的历史回归（见 top_app_bar_scroll_gate_test.dart）。
/// - 折叠 1/3 前大标题淡出中、小标题尚未出现；折叠过半后小标题淡入。
void main() {
  Widget app(MiuixExitUntilCollapsedScrollBehavior behavior) {
    return MiuixTheme(
      data: MiuixThemeData.light(),
      child: MaterialApp(
        home: MiuixScaffold(
          topBar: MiuixTopAppBar(
            title: '学期设置',
            scrollBehavior: behavior,
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
    );
  }

  testWidgets('松手停在过渡区中段时吸附到近端端点', (tester) async {
    final behavior = MiuixExitUntilCollapsedScrollBehavior();
    await tester.pumpWidget(app(behavior));
    await tester.pumpAndSettle();

    final limit = behavior.state.heightOffsetLimit;
    expect(limit, lessThan(-1), reason: '展开量应已测出');
    final expansion = -limit;

    // 慢速上滑到过渡区前段（fraction < 0.5）后松手 → 应吸回全展开。
    await tester.timedDrag(
      find.byType(ListView),
      Offset(0, -expansion * 0.3),
      const Duration(milliseconds: 300),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(
      behavior.state.collapsedFraction,
      closeTo(0, 0.02),
      reason: '折叠比例未过半，松手应吸回全展开',
    );

    // 慢速上滑到过渡区后段（fraction > 0.5）后松手 → 应吸到全折叠。
    await tester.timedDrag(
      find.byType(ListView),
      Offset(0, -expansion * 0.7),
      const Duration(milliseconds: 300),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(
      behavior.state.collapsedFraction,
      closeTo(1, 0.02),
      reason: '折叠比例已过半，松手应吸到全折叠',
    );

    // 吸附后折叠量必须仍与滚动位置一致（不解耦）。
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(
      behavior.state.heightOffset,
      closeTo(-(scrollable.position.pixels), 0.51),
      reason: '吸附动画的对象是列表位置，offset ≡ f(pixels)',
    );
  });

  testWidgets('小标题在 1/3 折叠阈值后才淡入', (tester) async {
    final behavior = MiuixExitUntilCollapsedScrollBehavior(
      snapOnRelease: false, // 关闭吸附以便停在过渡区中段观察。
    );
    await tester.pumpWidget(app(behavior));
    await tester.pumpAndSettle();

    final expansion = -behavior.state.heightOffsetLimit;

    // 小标题仅在其透明度 > 0 时才会被加入组件树，所以树中标题副本数直接
    // 反映小标题是否出现（展开态：显示层大标题 + 测量层副本）。
    int titleCopies() => find.text('学期设置').evaluate().length;

    // 折叠 20%（< 1/3 阈值）：大标题淡出中，小标题不应出现。
    behavior.state.heightOffset = -expansion * 0.2;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final copiesBeforeThreshold = titleCopies();

    // 折叠 60%（> 1/3 阈值）：小标题淡入，副本数增加。
    behavior.state.heightOffset = -expansion * 0.6;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final copiesAfterThreshold = titleCopies();

    expect(
      copiesAfterThreshold,
      greaterThan(copiesBeforeThreshold),
      reason: '越过 1/3 阈值后小标题淡入',
    );
    expect(behavior.state.collapsedFraction, closeTo(0.6, 0.01));
  });

  testWidgets('lockSmallTitleUntilTop 开启时惯性回顶不重新展开', (tester) async {
    final behavior = MiuixExitUntilCollapsedScrollBehavior(
      lockSmallTitleUntilTop: true,
    );
    await tester.pumpWidget(app(behavior));
    await tester.pumpAndSettle();

    // 大幅上滑越过折叠区并停稳：完全折叠。
    await tester.drag(
      find.byType(ListView),
      const Offset(0, -400),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(behavior.state.collapsedFraction, closeTo(1, 0.05));

    // 猛甩回顶部（fling，不是慢速拖拽）：惯性期间标题保持折叠冻结。
    await tester.fling(
      find.byType(ListView),
      const Offset(0, 600),
      3000,
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(
      behavior.state.collapsedFraction,
      closeTo(1, 0.05),
      reason: '锁开启时惯性滚动碰巧到顶不解锁，标题保持小标题',
    );
  });
}
