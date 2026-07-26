// 验证：MiuixFloatingToolbar 内部按钮能正常收到点击（外层 opaque onTap 不吞子按钮）。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_miuix/miuix.dart';

void main() {
  testWidgets('FloatingToolbar 内部按钮可点击', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MiuixSystemTheme(
        child: Builder(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: MiuixFloatingToolbar(
                  child: MiuixIconButton(
                    onPressed: () => taps++,
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(taps, 1, reason: '子按钮 onPressed 应被触发');
  });
}
