import 'package:equatable/equatable.dart';

enum MorseCategory {
  letters('Letters'),
  digits('Numbers'),
  symbols('Symbols');

  const MorseCategory(this.label);

  final String label;
}

class MorseEntry extends Equatable {
  const MorseEntry({required this.character, required this.code, required this.category});

  final String character;
  final String code;
  final MorseCategory category;

  int get signalCount => code.length;

  @override
  List<Object?> get props => [character, code, category];
}
