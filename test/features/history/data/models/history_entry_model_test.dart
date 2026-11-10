import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/features/history/data/models/history_entry_model.dart';
import 'package:morse_translator/features/history/domain/entities/history_entry.dart';

import '../../../../fixtures/history_fixtures.dart';

void main() {
  test('is a HistoryEntry', () {
    expect(entry('1'), isA<HistoryEntry>());
  });

  test('round trips through json', () {
    final model = entry('1', favorite: true, source: HistorySource.tap);

    expect(HistoryEntryModel.fromJson(model.toJson()), model);
  });

  test('falls back to defaults for missing optional fields', () {
    final model = HistoryEntryModel.fromJson({
      'id': '1',
      'text': 'A',
      'morse': '.-',
      'source': 'unknown',
      'createdAt': fixedNow.toIso8601String(),
    });

    expect(model.source, HistorySource.textToMorse);
    expect(model.isFavorite, isFalse);
  });
}
