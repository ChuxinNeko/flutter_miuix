import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MiuixTheme(
  data: MiuixThemeData.light(),
  child: MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('点击占位标签区域能聚焦并唤起输入（标签不得吞掉命中）', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      _wrap(
        MiuixTextField(
          focusNode: focusNode,
          label: '搜索歌曲、歌手或专辑',
          useLabelAsPlaceholder: true,
          singleLine: true,
        ),
      ),
    );

    expect(focusNode.hasFocus, isFalse);
    // 正中即占位文字所在处——修复前 RenderParagraph 吞掉命中，无法聚焦。
    await tester.tap(find.byType(MiuixTextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('点击内边距/背景区域同样聚焦（整块可点击）', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 320,
          child: MiuixTextField(focusNode: focusNode, label: '用户名'),
        ),
      ),
    );

    // 点输入框左上角（insideMargin 留白区域，TextField 文本行之外）。
    final topLeft = tester.getTopLeft(find.byType(MiuixTextField));
    await tester.tapAt(topLeft + const Offset(6, 6));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('autofocus: true 挂载后自动聚焦', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      _wrap(
        MiuixTextField(focusNode: focusNode, label: '歌单名', autofocus: true),
      ),
    );
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('disabled 时点击不聚焦', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      _wrap(
        MiuixTextField(focusNode: focusNode, label: '禁用', enabled: false),
      ),
    );

    await tester.tap(find.byType(MiuixTextField), warnIfMissed: false);
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
  });
}
