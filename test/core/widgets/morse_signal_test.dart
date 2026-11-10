import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/core/theme/app_colors.dart';
import 'package:morse_translator/core/widgets/morse_signal.dart';

void main() {
  test('splits words and letters from raw or prettified input', () {
    final expected = [
      ['...', '---'],
      ['.-'],
    ];
    expect(MorseSignal.wordsOf('... --- / .-'), expected);
    expect(MorseSignal.wordsOf('··· −−− / ·−'), expected);
  });

  test('spoken label names each symbol', () {
    expect(MorseSignal.spokenOf('.- / -'), 'dot dash, space, dash');
  });

  testWidgets('dots are blue circles and dashes are longer amber pills', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: MorseSignal(code: '.-', size: 10)),
      ),
    );

    final shapes = tester
        .widgetList<Container>(find.descendant(of: find.byType(MorseSignal), matching: find.byType(Container)))
        .toList();
    expect(shapes, hasLength(2));

    final dot = tester.getSize(find.byWidget(shapes[0]));
    final dash = tester.getSize(find.byWidget(shapes[1]));
    expect(dot, const Size(10, 10));
    expect(dash, const Size(10 * MorseSignal.dashRatio, 10));
    expect((shapes[0].decoration! as BoxDecoration).color, AppColors.signalDot);
    expect((shapes[1].decoration! as BoxDecoration).color, AppColors.signalDash);
  });

  testWidgets('a letter wider than the space scales down instead of overflowing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 186, child: MorseSignal(code: '-----', size: 14)),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(MorseSignal)).width, lessThanOrEqualTo(186));
  });
}
