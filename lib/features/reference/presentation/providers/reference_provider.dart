import 'package:flutter/foundation.dart';

import '../../domain/entities/morse_entry.dart';
import '../../domain/usecases/get_morse_entries.dart';

class ReferenceProvider extends ChangeNotifier {
  ReferenceProvider({required GetMorseEntries getMorseEntries}) : _getMorseEntries = getMorseEntries {
    _entries = _getMorseEntries(_category);
    _selected = _entries.firstWhere((e) => e.character == 'S', orElse: () => _entries.first);
  }

  final GetMorseEntries _getMorseEntries;

  MorseCategory _category = MorseCategory.letters;
  late List<MorseEntry> _entries;
  late MorseEntry _selected;

  MorseCategory get category => _category;
  List<MorseEntry> get entries => _entries;
  MorseEntry get selected => _selected;

  void selectCategory(MorseCategory category) {
    if (category == _category) return;
    _category = category;
    _entries = _getMorseEntries(category);
    notifyListeners();
  }

  void select(MorseEntry entry) {
    if (entry == _selected) return;
    _selected = entry;
    notifyListeners();
  }
}
