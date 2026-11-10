import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/core/morse/morse_codec.dart';
import 'package:morse_translator/features/translator/domain/entities/translation.dart';
import 'package:morse_translator/features/translator/domain/entities/translation_direction.dart';
import 'package:morse_translator/features/translator/domain/usecases/translate.dart';

void main() {
  late Translate translate;

  setUp(() {
    translate = const Translate(MorseCodec());
  });

  test('translates text to morse', () {
    final result = translate(const TranslateParams(input: 'SOS', direction: TranslationDirection.textToMorse));

    expect(
      result,
      const Translation(
        input: 'SOS',
        output: '... --- ...',
        morse: '... --- ...',
        plainText: 'SOS',
        direction: TranslationDirection.textToMorse,
      ),
    );
  });

  test('translates morse to text and normalizes the morse', () {
    final result = translate(const TranslateParams(input: '··· −−− ···', direction: TranslationDirection.morseToText));

    expect(result.output, 'SOS');
    expect(result.morse, '... --- ...');
    expect(result.plainText, 'SOS');
  });

  test('reports empty output for blank input', () {
    final result = translate(const TranslateParams(input: '', direction: TranslationDirection.textToMorse));

    expect(result.isEmpty, isTrue);
  });

  test('direction toggles to its opposite', () {
    expect(TranslationDirection.textToMorse.flipped, TranslationDirection.morseToText);
    expect(TranslationDirection.morseToText.flipped, TranslationDirection.textToMorse);
  });
}
