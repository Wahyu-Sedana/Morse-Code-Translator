import 'package:equatable/equatable.dart';

import 'translation_direction.dart';

class Translation extends Equatable {
  const Translation({
    required this.input,
    required this.output,
    required this.morse,
    required this.plainText,
    required this.direction,
  });

  const Translation.empty(this.direction) : input = '', output = '', morse = '', plainText = '';

  final String input;
  final String output;
  final String morse;
  final String plainText;
  final TranslationDirection direction;

  bool get isEmpty => output.trim().isEmpty;

  @override
  List<Object?> get props => [input, output, morse, plainText, direction];
}
