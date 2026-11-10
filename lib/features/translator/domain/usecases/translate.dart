import 'package:equatable/equatable.dart';

import '../../../../core/morse/morse_codec.dart';
import '../entities/translation.dart';
import '../entities/translation_direction.dart';

class Translate {
  const Translate(this._codec);

  final MorseCodec _codec;

  Translation call(TranslateParams params) {
    if (params.direction.isTextToMorse) {
      final morse = _codec.encode(params.input);
      return Translation(
        input: params.input,
        output: morse,
        morse: morse,
        plainText: params.input.trim().toUpperCase(),
        direction: params.direction,
      );
    }
    final normalized = _codec.normalize(params.input).trim().replaceAll(RegExp(r'\s*/\s*'), ' / ');
    final text = _codec.decode(normalized);
    return Translation(
      input: params.input,
      output: text,
      morse: normalized,
      plainText: text,
      direction: params.direction,
    );
  }
}

class TranslateParams extends Equatable {
  const TranslateParams({required this.input, required this.direction});

  final String input;
  final TranslationDirection direction;

  @override
  List<Object?> get props => [input, direction];
}
