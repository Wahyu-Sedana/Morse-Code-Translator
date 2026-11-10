import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/features/tap_keyer/domain/usecases/classify_press.dart';

void main() {
  const classify = ClassifyPress();

  test('threshold is two units at slow speeds', () {
    expect(classify.thresholdFor(10), const Duration(milliseconds: 240));
  });

  test('threshold never drops below the minimum at fast speeds', () {
    expect(classify.thresholdFor(40), const Duration(milliseconds: 150));
  });

  test('short presses are dots', () {
    expect(classify(const PressParams(duration: Duration(milliseconds: 90), wpm: 15)), '.');
  });

  test('presses at or above the threshold are dashes', () {
    expect(classify(const PressParams(duration: Duration(milliseconds: 160), wpm: 15)), '-');
    expect(classify(const PressParams(duration: Duration(milliseconds: 400), wpm: 15)), '-');
  });
}
