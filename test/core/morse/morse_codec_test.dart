import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/core/morse/morse_codec.dart';

void main() {
  late MorseCodec codec;

  setUp(() {
    codec = const MorseCodec();
  });

  group('encode', () {
    test('encodes a single word with spaces between letters', () {
      expect(codec.encode('SOS'), '... --- ...');
    });

    test('is case insensitive', () {
      expect(codec.encode('sos'), '... --- ...');
    });

    test('separates words with a slash', () {
      expect(codec.encode('Halo dunia'), '.... .- .-.. --- / -.. ..- -. .. .-');
    });

    test('collapses repeated whitespace and trims', () {
      expect(codec.encode('  a   b  '), '.- / -...');
    });

    test('encodes digits and punctuation', () {
      expect(codec.encode('1?'), '.---- ..--..');
    });

    test('skips unsupported characters', () {
      expect(codec.encode('a#b'), '.- -...');
    });

    test('returns empty string for blank input', () {
      expect(codec.encode('   '), '');
    });

    test('drops words made only of unsupported characters', () {
      expect(codec.encode('a ### b'), '.- / -...');
    });
  });

  group('decode', () {
    test('decodes letters separated by spaces', () {
      expect(codec.decode('... --- ...'), 'SOS');
    });

    test('decodes words separated by a slash', () {
      expect(codec.decode('.... .. / .- .-..'), 'HI AL');
    });

    test('accepts pretty symbols', () {
      expect(codec.decode('··· −−− ···'), 'SOS');
    });

    test('marks unknown codes with a question mark', () {
      expect(codec.decode('........'), '?');
    });

    test('treats three or more spaces as a word gap', () {
      expect(codec.decode('.-   -...'), 'A B');
    });

    test('returns empty string for blank input', () {
      expect(codec.decode('  '), '');
    });

    test('ignores a trailing word separator', () {
      expect(codec.decode('.- / '), 'A');
    });
  });

  group('prettify', () {
    test('replaces dots and dashes with display glyphs', () {
      expect(codec.prettify('.- /'), '·− /');
    });
  });

  test('encode then decode round trips supported text', () {
    expect(codec.decode(codec.encode('Terima kasih 2026')), 'TERIMA KASIH 2026');
  });
}
