// example 项目的最小 smoke test：验证主入口可构建。
//
// 由于 example 是组件 showcase（不是业务 app），这里仅做"能跑起来"的冒烟验证。
// 真正的组件测试应在主包 `flutter_miuix` 的 test/ 目录中编写。

import 'package:flutter_test/flutter_test.dart';

import 'package:miuix_example/main.dart';

void main() {
  testWidgets('Showcase app boots without throwing', (tester) async {
    await tester.pumpWidget(const MiuixShowcaseApp());
    await tester.pump(const Duration(milliseconds: 100));

    // 主页大标题应该出现。
    expect(find.text('miuix 组件库'), findsOneWidget);
    // 至少一个分类入口可见。
    expect(find.text('按钮 Button'), findsOneWidget);
  });
}
