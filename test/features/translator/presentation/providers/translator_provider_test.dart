import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/core/morse/morse_codec.dart';
import 'package:morse_translator/features/translator/domain/entities/translation_direction.dart';
import 'package:morse_translator/features/translator/domain/usecases/translate.dart';
import 'package:morse_translator/features/translator/presentation/providers/translator_provider.dart';

void main() {
  late TranslatorProvider provider;
  late int notifications;

  setUp(() {
    provider = TranslatorProvider(translate: const Translate(MorseCodec()));
    notifications = 0;
    provider.addListener(() => notifications++);
  });

  test('starts empty in text to morse mode', () {
    expect(provider.direction, TranslationDirection.textToMorse);
    expect(provider.input, isEmpty);
    expect(provider.translation.isEmpty, isTrue);
  });

  test('updating input translates immediately', () {
    provider.updateInput('SOS');

    expect(provider.translation.output, '... --- ...');
    expect(notifications, 1);
  });

  test('same input does not notify again', () {
    provider.updateInput('A');
    provider.updateInput('A');

    expect(notifications, 1);
  });

  test('swap flips direction and carries the output over as new input', () {
    provider.updateInput('SOS');
    provider.swapDirection();

    expect(provider.direction, TranslationDirection.morseToText);
    expect(provider.input, '... --- ...');
    expect(provider.translation.output, 'SOS');
  });

  test('swap back returns readable text', () {
    provider.updateInput('sos');
    provider.swapDirection();
    provider.swapDirection();

    expect(provider.direction, TranslationDirection.textToMorse);
    expect(provider.input, 'SOS');
    expect(provider.translation.output, '... --- ...');
  });

  test('clear empties the input', () {
    provider.updateInput('SOS');
    provider.clear();

    expect(provider.input, isEmpty);
    expect(provider.translation.isEmpty, isTrue);
  });

  test('display output is prettified only for morse', () {
    provider.updateInput('A');
    expect(provider.displayOutput, '\u00B7\u2212');

    provider.swapDirection();
    expect(provider.displayOutput, 'A');
  });
}
