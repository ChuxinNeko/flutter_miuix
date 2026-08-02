import 'package:flutter/material.dart';
import 'package:flutter_miuix/miuix.dart';
import 'package:flutter_test/flutter_test.dart';

/// 受控用法：与 App 一致，每次 onQueryChange 都 setState 重建 MiuixInputField，
/// 正是触发 IME 合成错乱（输 "ji" 变 "jjijiji"）的场景。
class _ControlledInput extends StatefulWidget {
  const _ControlledInput();

  @override
  State<_ControlledInput> createState() => _ControlledInputState();
}

class _ControlledInputState extends State<_ControlledInput> {
  String _query = '';
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => MiuixTheme(
    data: MiuixThemeData.light(),
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: MiuixInputField(
            query: _query,
            onQueryChange: (v) => setState(() => _query = v),
            onSearch: (_) {},
            expanded: _expanded,
            onExpandedChange: (v) => setState(() => _expanded = v),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('IME 合成期间父级重建不打断 composing（中文输入不重复）', (
    tester,
  ) async {
    await tester.pumpWidget(const _ControlledInput());
    // 建立输入连接并聚焦。
    await tester.showKeyboard(find.byType(MiuixInputField));
    await tester.pump();

    // 模拟输入法合成态：拼音 "ji" 带 composing 区。updateEditingValue 会先更新
    // EditableText 的值（含 composing），再触发 onChanged → 父级 setState 重建。
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'ji',
        selection: TextSelection.collapsed(offset: 2),
        composing: TextRange(start: 0, end: 2),
      ),
    );
    await tester.pump();

    final state = tester.state<EditableTextState>(find.byType(EditableText));
    // 修复前：重建每帧新建 controller（composing 被清空），合成态丢失、增量重插；
    // 修复后：持久 controller + didUpdateWidget 跳过等值覆盖，composing 完整保留。
    expect(state.textEditingValue.text, 'ji');
    expect(
      state.textEditingValue.composing,
      const TextRange(start: 0, end: 2),
    );
  });
}
