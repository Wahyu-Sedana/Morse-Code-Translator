import 'package:morse_translator/features/history/data/models/history_entry_model.dart';
import 'package:morse_translator/features/history/domain/entities/history_entry.dart';

final DateTime fixedNow = DateTime.utc(2026, 11, 10, 9, 12);

HistoryEntryModel entry(
  String id, {
  bool favorite = false,
  HistorySource source = HistorySource.textToMorse,
  String text = 'SOS',
}) {
  return HistoryEntryModel(
    id: id,
    text: text,
    morse: '... --- ...',
    source: source,
    createdAt: fixedNow,
    isFavorite: favorite,
  );
}
