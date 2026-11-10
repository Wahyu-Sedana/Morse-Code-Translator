import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/features/reference/data/repositories/reference_repository_impl.dart';
import 'package:morse_translator/features/reference/domain/entities/morse_entry.dart';
import 'package:morse_translator/features/reference/domain/usecases/get_morse_entries.dart';
import 'package:morse_translator/features/reference/presentation/providers/reference_provider.dart';

void main() {
  const getEntries = GetMorseEntries(ReferenceRepositoryImpl());

  group('repository', () {
    test('letters contain the full A to Z alphabet', () {
      final letters = getEntries(MorseCategory.letters);

      expect(letters.length, 26);
      expect(letters.first, const MorseEntry(character: 'A', code: '.-', category: MorseCategory.letters));
    });

    test('digits contain ten entries with five signals each', () {
      final digits = getEntries(MorseCategory.digits);

      expect(digits.length, 10);
      expect(digits.every((e) => e.signalCount == 5), isTrue);
    });

    test('symbols are tagged with their category', () {
      expect(getEntries(MorseCategory.symbols).every((e) => e.category == MorseCategory.symbols), isTrue);
    });
  });

  group('provider', () {
    late ReferenceProvider provider;

    setUp(() => provider = ReferenceProvider(getMorseEntries: getEntries));

    test('starts on letters with S selected', () {
      expect(provider.category, MorseCategory.letters);
      expect(provider.selected.character, 'S');
    });

    test('switching category loads its entries and keeps the selection', () {
      provider.selectCategory(MorseCategory.digits);

      expect(provider.entries.length, 10);
      expect(provider.selected.character, 'S');
    });

    test('selecting an entry notifies listeners', () {
      var notified = 0;
      provider.addListener(() => notified++);

      provider.select(provider.entries.first);

      expect(provider.selected.character, 'A');
      expect(notified, 1);
    });
  });
}
