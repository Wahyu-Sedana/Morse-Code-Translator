import 'morse_alphabet.dart';

class MorseCodec {
  const MorseCodec();

  static const String dot = '.';
  static const String dash = '-';
  static const String letterSeparator = ' ';
  static const String wordSeparator = ' / ';

  static final Map<String, String> _reverse = {for (final entry in kMorseAlphabet.entries) entry.value: entry.key};

  String encode(String text) {
    final words = text.toUpperCase().trim().split(RegExp(r'\s+'));
    final encodedWords = <String>[];
    for (final word in words) {
      final codes = <String>[];
      for (final char in word.split('')) {
        final code = kMorseAlphabet[char];
        if (code != null) codes.add(code);
      }
      if (codes.isNotEmpty) encodedWords.add(codes.join(letterSeparator));
    }
    return encodedWords.join(wordSeparator);
  }

  String decode(String morse) {
    final normalized = normalize(morse).trim();
    if (normalized.isEmpty) return '';
    final words = normalized
        .split(RegExp(r'\s*/\s*|\s{3,}'))
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty);
    return words.map((word) => word.split(RegExp(r'\s+')).map((code) => _reverse[code] ?? '?').join()).join(' ');
  }

  String normalize(String morse) {
    return morse.replaceAll(RegExp('[\u00B7\u2022\u2219]'), dot).replaceAll(RegExp('[\u2212\u2013\u2014_]'), dash);
  }

  String prettify(String morse) {
    return morse.replaceAll(dot, '\u00B7').replaceAll(dash, '\u2212');
  }

  String? codeFor(String character) => kMorseAlphabet[character.toUpperCase()];

  String? characterFor(String code) => _reverse[code];
}
