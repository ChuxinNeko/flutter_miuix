// flutter_miuix 基础冒烟测试：验证主题 + 基础组件可正常构建与交互。
//
// 组件级细化测试建议按组件拆分到独立文件（如 bottom_sheet_dismiss_test.dart）。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_miuix/miuix.dart';

void main() {
  testWidgets('MiuixButton 在 MiuixSystemTheme 下可构建并响应点击', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MiuixSystemTheme(
        child: Builder(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MiuixScaffold(
              content: (padding) => Center(
                child: MiuixButton(
                  onPressed: () => taps++,
                  child: const Text('点击'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('点击'), findsOneWidget);

    await tester.tap(find.text('点击'));
    await tester.pump();

    expect(taps, 1);
  });
}
