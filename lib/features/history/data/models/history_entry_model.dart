import '../../domain/entities/history_entry.dart';

class HistoryEntryModel extends HistoryEntry {
  const HistoryEntryModel({
    required super.id,
    required super.text,
    required super.morse,
    required super.source,
    required super.createdAt,
    super.isFavorite,
  });

  factory HistoryEntryModel.fromEntity(HistoryEntry entry) {
    return HistoryEntryModel(
      id: entry.id,
      text: entry.text,
      morse: entry.morse,
      source: entry.source,
      createdAt: entry.createdAt,
      isFavorite: entry.isFavorite,
    );
  }

  factory HistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return HistoryEntryModel(
      id: json['id'] as String,
      text: json['text'] as String,
      morse: json['morse'] as String,
      source: HistorySource.values.firstWhere(
        (source) => source.name == json['source'],
        orElse: () => HistorySource.textToMorse,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'morse': morse,
      'source': source.name,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }
}
