import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/core/morse/morse_codec.dart';
import 'package:morse_translator/features/tap_keyer/domain/usecases/classify_press.dart';
import 'package:morse_translator/features/tap_keyer/presentation/providers/tap_provider.dart';

void main() {
  late DateTime now;
  late TapProvider provider;

  TapProvider build() => TapProvider(
    codec: const MorseCodec(),
    classifyPress: const ClassifyPress(),
    wpm: () => 15,
    clock: () => now,
    letterTimeout: const Duration(milliseconds: 900),
  );

  setUp(() {
    now = DateTime(2026, 11, 10);
    provider = build();
  });

  tearDown(() => provider.dispose());

  void press(Duration length) {
    provider.pressDown();
    now = now.add(length);
    provider.pressUp();
  }

  test('starts empty', () {
    expect(provider.isEmpty, isTrue);
    expect(provider.decoded, isEmpty);
  });

  test('short and long presses become dot and dash in the buffer', () {
    press(const Duration(milliseconds: 80));
    press(const Duration(milliseconds: 300));

    expect(provider.buffer, '.-');
    expect(provider.isPressed, isFalse);
  });

  test('buffer commits to a letter after the idle timeout', () {
    fakeAsync((async) {
      provider = build();
      provider.addSymbol('.');
      provider.addSymbol('-');
      async.elapse(const Duration(milliseconds: 899));
      expect(provider.buffer, '.-');

      async.elapse(const Duration(milliseconds: 1));
      expect(provider.buffer, isEmpty);
      expect(provider.sequence, '.-');
      expect(provider.decoded, 'A');
    });
  });

  test('pressing again cancels the pending commit', () {
    fakeAsync((async) {
      provider = build();
      provider.addSymbol('.');
      async.elapse(const Duration(milliseconds: 800));
      provider.pressDown();
      async.elapse(const Duration(milliseconds: 500));
      now = now.add(const Duration(milliseconds: 80));
      provider.pressUp();

      expect(provider.buffer, '..');
    });
  });

  test('letters are separated by spaces and words by slashes', () {
    provider.addSymbol('.');
    provider.commitLetter();
    provider.addSymbol('-');
    provider.addWordSpace();
    provider.addSymbol('.');
    provider.commitLetter();

    expect(provider.sequence, '. - / .');
    expect(provider.decoded, 'ET E');
  });

  test('word space commits the pending buffer first and is not repeated', () {
    provider.addSymbol('.');
    provider.addWordSpace();
    provider.addWordSpace();

    expect(provider.sequence, '. / ');
    expect(provider.buffer, isEmpty);
  });

  test('word space is ignored at the start', () {
    provider.addWordSpace();

    expect(provider.sequence, isEmpty);
  });

  test('morse includes the pending buffer', () {
    provider.addSymbol('.');
    provider.commitLetter();
    provider.addSymbol('-');

    expect(provider.morse, '. -');
    expect(provider.decoded, 'ET');
  });

  group('backspace', () {
    test('removes the last symbol from the buffer first', () {
      provider.addSymbol('.');
      provider.addSymbol('-');
      provider.backspace();

      expect(provider.buffer, '.');
    });

    test('then removes the last committed letter', () {
      provider.addSymbol('.');
      provider.commitLetter();
      provider.addSymbol('-');
      provider.commitLetter();
      provider.backspace();

      expect(provider.sequence, '.');
    });

    test('removes a trailing word separator', () {
      provider.addSymbol('.');
      provider.addWordSpace();
      provider.backspace();

      expect(provider.sequence, '.');
    });

    test('removing the first letter of a word keeps the separator', () {
      provider.addSymbol('.');
      provider.addWordSpace();
      provider.addSymbol('-');
      provider.commitLetter();
      provider.backspace();

      expect(provider.sequence, '. / ');
    });
  });

  test('clear resets everything', () {
    provider.addSymbol('.');
    provider.commitLetter();
    provider.addSymbol('-');
    provider.clear();

    expect(provider.isEmpty, isTrue);
  });
}
