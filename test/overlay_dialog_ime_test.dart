import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';
import 'package:flutter_test/flutter_test.dart';

/// 回归：键盘（viewInsets.bottom）弹出时，底部锚定的对话框必须整体上移到
/// 键盘上方（对应 Compose 版 imePadding），而不是被键盘遮挡。
void main() {
  testWidgets('对话框随输入法上移', (tester) async {
    const imeHeight = 300.0;
    const contentKey = Key('dialog-content');

    await tester.pumpWidget(
      MiuixTheme(
        data: MiuixThemeData.light(),
        child: MaterialApp(
          // 模拟键盘：向子树注入 viewInsets.bottom。
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              viewInsets: const EdgeInsets.only(bottom: imeHeight),
            ),
            child: child!,
          ),
          home: MiuixScaffold(
            content: (_) => MiuixOverlayDialog(
              show: true,
              title: '编辑 OmniParse',
              content: const SizedBox(key: contentKey, height: 120),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final screenHeight = tester.view.physicalSize.height /
        tester.view.devicePixelRatio;
    final keyboardTop = screenHeight - imeHeight;

    final contentBottom = tester.getBottomLeft(find.byKey(contentKey)).dy;
    expect(
      contentBottom,
      lessThanOrEqualTo(keyboardTop),
      reason: '对话框内容底部 ($contentBottom) 应位于键盘上缘 ($keyboardTop) 之上',
    );

    final titleTop = tester.getTopLeft(find.text('编辑 OmniParse')).dy;
    expect(titleTop, greaterThanOrEqualTo(0), reason: '面板不应被顶出屏幕上缘');
  });
}
