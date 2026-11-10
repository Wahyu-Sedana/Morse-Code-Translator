import '../../../../core/morse/morse_alphabet.dart';
import '../../domain/entities/morse_entry.dart';
import '../../domain/repositories/reference_repository.dart';

class ReferenceRepositoryImpl implements ReferenceRepository {
  const ReferenceRepositoryImpl();

  @override
  List<MorseEntry> getEntries(MorseCategory category) {
    final source = switch (category) {
      MorseCategory.letters => kMorseLetters,
      MorseCategory.digits => kMorseDigits,
      MorseCategory.symbols => kMorseSymbols,
    };
    return source.entries
        .map((e) => MorseEntry(character: e.key, code: e.value, category: category))
        .toList(growable: false);
  }
}
