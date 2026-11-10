import 'package:flutter/foundation.dart';

import '../../../../core/morse/morse_codec.dart';
import '../../domain/entities/translation.dart';
import '../../domain/entities/translation_direction.dart';
import '../../domain/usecases/translate.dart';

class TranslatorProvider extends ChangeNotifier {
  TranslatorProvider({required Translate translate, MorseCodec codec = const MorseCodec()})
    : _translate = translate,
      _codec = codec;

  final Translate _translate;
  final MorseCodec _codec;

  String _input = '';
  TranslationDirection _direction = TranslationDirection.textToMorse;
  Translation _translation = const Translation.empty(TranslationDirection.textToMorse);

  String get input => _input;
  TranslationDirection get direction => _direction;
  Translation get translation => _translation;

  String get displayOutput => _direction.isTextToMorse ? _codec.prettify(_translation.output) : _translation.output;

  void updateInput(String value) {
    if (value == _input) return;
    _input = value;
    _retranslate();
    notifyListeners();
  }

  void swapDirection() {
    final carried = _translation.output;
    _direction = _direction.flipped;
    _input = carried;
    _retranslate();
    notifyListeners();
  }

  void clear() {
    if (_input.isEmpty) return;
    _input = '';
    _retranslate();
    notifyListeners();
  }

  void _retranslate() {
    _translation = _translate(TranslateParams(input: _input, direction: _direction));
  }
}
