// 回归测试：MiuixOverlayBottomSheet 关闭后必须真正移除遮罩层。
//
// 历史 bug：退出动画用 AnimationController.animateWith(SpringSimulation)，
// 弹簧收敛到 0 时状态是 completed 而非 dismissed，导致监听 dismissed 的收尾
// 逻辑永不触发，_popupController.dismiss() 不被调用，全屏 opaque 遮罩层残留
// 并吞掉所有点击 —— 表现为"点开底部弹窗后整页卡死、无法返回"。
//
// 本测试验证：show 置 false 并动画结束后，弹窗内容被移除，且底层内容可再次点击。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_miuix/miuix.dart';

void main() {
  testWidgets('OverlayBottomSheet 关闭后移除遮罩，底层重新可点击', (tester) async {
    var showSheet = false;
    var backgroundTaps = 0;

    await tester.pumpWidget(
      MiuixSystemTheme(
        child: Builder(
          builder: (context) {
            final theme = MiuixTheme.of(context);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(brightness: theme.brightness),
              home: StatefulBuilder(
                builder: (context, setState) {
                  return MiuixScaffold(
                    content: (padding) => Stack(
                      children: [
                        // 底层的可点击区域：遮罩残留时它会被吞掉点击。
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => backgroundTaps++,
                            child: const SizedBox.expand(),
                          ),
                        ),
                        Center(
                          child: MiuixButton(
                            onPressed: () => setState(() => showSheet = true),
                            child: const Text('打开'),
                          ),
                        ),
                        MiuixOverlayBottomSheet(
                          show: showSheet,
                          title: '操作',
                          onDismissRequest: () =>
                              setState(() => showSheet = false),
                          content: MiuixButton(
                            onPressed: () => setState(() => showSheet = false),
                            child: const Text('确定'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    // 打开弹窗。
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    expect(find.text('确定'), findsOneWidget, reason: '弹窗应已显示');

    // 点击弹窗内按钮触发关闭（对应用户"点击操作列表"的场景）。
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    // 关键断言 1：弹窗内容被移除（说明 dismiss() 确实被调用）。
    expect(find.text('确定'), findsNothing, reason: '关闭后弹窗内容应被移除');

    // 关键断言 2：底层区域重新可点击（说明残留遮罩已消失，页面未卡死）。
    await tester.tap(find.text('打开')); // 落在背景 GestureDetector 之上的按钮
    await tester.pumpAndSettle();
    // 再次能打开弹窗，进一步证明交互恢复正常。
    expect(find.text('确定'), findsOneWidget, reason: '关闭后应能再次打开，页面未卡死');
  });
}
