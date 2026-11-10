import 'package:equatable/equatable.dart';

enum HistorySource {
  textToMorse('Text to Morse'),
  morseToText('Morse to Text'),
  tap('Tap');

  const HistorySource(this.label);

  final String label;
}

class HistoryEntry extends Equatable {
  const HistoryEntry({
    required this.id,
    required this.text,
    required this.morse,
    required this.source,
    required this.createdAt,
    this.isFavorite = false,
  });

  final String id;
  final String text;
  final String morse;
  final HistorySource source;
  final DateTime createdAt;
  final bool isFavorite;

  HistoryEntry copyWith({bool? isFavorite}) {
    return HistoryEntry(
      id: id,
      text: text,
      morse: morse,
      source: source,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, text, morse, source, createdAt, isFavorite];
}
