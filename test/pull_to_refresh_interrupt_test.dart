// 验证：下拉触发刷新后的回弹（弹簧回收）未完成时再次下拉，不应卡在拉长状态。
// 回归此前的 bug——回弹中被新的下拉取消后，_startRefreshing 内部锁
// （_isRefreshingInternally）泄漏为 true，此后所有松手都被提前拦截，
// 指示器永远停留在拉长状态、不再回弹也不再刷新。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_miuix/miuix.dart';

void main() {
  testWidgets('回弹未完成时再次下拉不应卡在拉长状态', (tester) async {
    bool refreshing = false;
    await tester.pumpWidget(
      MiuixSystemTheme(
        child: Builder(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => MiuixPullToRefresh(
                  isRefreshing: refreshing,
                  onRefresh: () {
                    setState(() => refreshing = true);
                    Future<void>.delayed(
                      const Duration(milliseconds: 400),
                      () => setState(() => refreshing = false),
                    );
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [SizedBox(height: 1200)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final listFinder = find.byType(ListView);

    // 第一次下拉远超触发阈值并松手：刷新弹簧开始向静止位回弹。
    await tester.drag(listFinder, const Offset(0, 300));
    await tester.pump(const Duration(milliseconds: 100)); // 回弹未完成

    // 回弹未完成时再次下拉，然后松手。
    await tester.drag(listFinder, const Offset(0, 200));
    await tester.pumpAndSettle();

    // 不应卡在拉长状态：刷新流程应正常走完，头部收起，列表回到顶部。
    expect(tester.getTopLeft(listFinder).dy, 0,
        reason: '二次下拉后应正常回弹并完成刷新，而非卡在拉长状态');
  });
}
