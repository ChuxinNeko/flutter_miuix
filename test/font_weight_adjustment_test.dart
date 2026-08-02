// Miuix Flutter 移植版 - 字重跟随系统测试
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_miuix/miuix.dart';

void main() {
  group('adjustFontWeight', () {
    test('adjustment 0 原样返回（含 null），零回归', () {
      expect(adjustFontWeight(null, 0), isNull);
      expect(adjustFontWeight(FontWeight.w400, 0), FontWeight.w400);
      expect(adjustFontWeight(FontWeight.bold, 0), FontWeight.bold);
    });

    test('+100 时按 issue 例子逐档偏移', () {
      // null 视为 w400。
      expect(adjustFontWeight(null, 100), FontWeight.w500);
      expect(adjustFontWeight(FontWeight.w400, 100), FontWeight.w500);
      expect(adjustFontWeight(FontWeight.w600, 100), FontWeight.w700);
      expect(adjustFontWeight(FontWeight.w700, 100), FontWeight.w800);
    });

    test('+200 两档', () {
      expect(adjustFontWeight(FontWeight.w400, 200), FontWeight.w600);
      expect(adjustFontWeight(FontWeight.w700, 200), FontWeight.w900);
    });

    test('上下越界 clamp 到 w100..w900', () {
      expect(adjustFontWeight(FontWeight.w900, 100), FontWeight.w900);
      expect(adjustFontWeight(FontWeight.w800, 300), FontWeight.w900);
      expect(adjustFontWeight(FontWeight.w200, -300), FontWeight.w100);
    });

    test('负偏移变细', () {
      expect(adjustFontWeight(FontWeight.w400, -100), FontWeight.w300);
    });
  });

  group('MiuixText 跟随主题 fontWeightAdjustment', () {
    Future<FontWeight?> weightOf(
      WidgetTester tester,
      int adjustment, {
      FontWeight? explicit,
    }) async {
      await tester.pumpWidget(
        MiuixTheme(
          data: MiuixThemeData.light(fontWeightAdjustment: adjustment),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MiuixText('测试', fontWeight: explicit),
          ),
        ),
      );
      final text = tester.widget<Text>(find.byType(Text));
      return text.style?.fontWeight;
    }

    testWidgets('adjustment 0 时未指定字重保持默认（null）', (tester) async {
      expect(await weightOf(tester, 0), isNull);
    });

    testWidgets('+100 时未指定字重 → w500', (tester) async {
      expect(await weightOf(tester, 100), FontWeight.w500);
    });

    testWidgets('+100 时显式 w600 → w700', (tester) async {
      expect(await weightOf(tester, 100, explicit: FontWeight.w600), FontWeight.w700);
    });
  });

  group('MiuixSystemTheme 依据 boldText 自动跟随', () {
    testWidgets('boldText 开启 → 默认 +100', (tester) async {
      late int adjustment;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(boldText: true),
          child: MiuixSystemTheme(
            child: Builder(
              builder: (context) {
                adjustment = MiuixTheme.of(context).fontWeightAdjustment;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(adjustment, 100);
    });

    testWidgets('boldText 关闭 → 0', (tester) async {
      late int adjustment;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(boldText: false),
          child: MiuixSystemTheme(
            child: Builder(
              builder: (context) {
                adjustment = MiuixTheme.of(context).fontWeightAdjustment;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(adjustment, 0);
    });

    testWidgets('显式 fontWeightAdjustment 覆盖自动跟随', (tester) async {
      late int adjustment;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(boldText: true),
          child: MiuixSystemTheme(
            fontWeightAdjustment: 0,
            child: Builder(
              builder: (context) {
                adjustment = MiuixTheme.of(context).fontWeightAdjustment;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(adjustment, 0);
    });
  });
}
