import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/morse/morse_codec.dart';
import '../../domain/usecases/classify_press.dart';

class TapProvider extends ChangeNotifier {
  TapProvider({
    required MorseCodec codec,
    required ClassifyPress classifyPress,
    required int Function() wpm,
    DateTime Function()? clock,
    this.letterTimeout = const Duration(milliseconds: 900),
  }) : _codec = codec,
       _classifyPress = classifyPress,
       _wpm = wpm,
       _clock = clock ?? DateTime.now;

  static const String _wordGap = ' / ';

  final MorseCodec _codec;
  final ClassifyPress _classifyPress;
  final int Function() _wpm;
  final DateTime Function() _clock;
  final Duration letterTimeout;

  String _sequence = '';
  String _buffer = '';
  bool _isPressed = false;
  DateTime? _pressStartedAt;
  Timer? _idleTimer;

  String get sequence => _sequence;
  String get buffer => _buffer;
  bool get isPressed => _isPressed;
  bool get isEmpty => _sequence.isEmpty && _buffer.isEmpty;

  String get morse => _join(_sequence, _buffer).trim();

  String get decoded => _codec.decode(morse);

  void pressDown() {
    _idleTimer?.cancel();
    _isPressed = true;
    _pressStartedAt = _clock();
    notifyListeners();
  }

  void pressUp() {
    final startedAt = _pressStartedAt;
    if (!_isPressed || startedAt == null) return;
    _isPressed = false;
    _pressStartedAt = null;
    final symbol = _classifyPress(PressParams(duration: _clock().difference(startedAt), wpm: _wpm()));
    addSymbol(symbol);
  }

  void addSymbol(String symbol) {
    if (symbol != MorseCodec.dot && symbol != MorseCodec.dash) return;
    _idleTimer?.cancel();
    _buffer += symbol;
    _idleTimer = Timer(letterTimeout, commitLetter);
    notifyListeners();
  }

  void commitLetter() {
    _idleTimer?.cancel();
    if (_buffer.isEmpty) return;
    _sequence = _join(_sequence, _buffer);
    _buffer = '';
    notifyListeners();
  }

  void addWordSpace() {
    _idleTimer?.cancel();
    var next = _join(_sequence, _buffer);
    _buffer = '';
    if (next.isNotEmpty && !next.endsWith(_wordGap)) next += _wordGap;
    if (next == _sequence) {
      notifyListeners();
      return;
    }
    _sequence = next;
    notifyListeners();
  }

  void backspace() {
    _idleTimer?.cancel();
    if (_buffer.isNotEmpty) {
      _buffer = _buffer.substring(0, _buffer.length - 1);
    } else if (_sequence.endsWith(_wordGap)) {
      _sequence = _sequence.substring(0, _sequence.length - _wordGap.length);
    } else if (_sequence.isNotEmpty) {
      final cut = _sequence.lastIndexOf(' ');
      _sequence = cut < 0 ? '' : _sequence.substring(0, cut + 1);
      if (!_sequence.endsWith(_wordGap)) _sequence = _sequence.trimRight();
    } else {
      return;
    }
    notifyListeners();
  }

  void clear() {
    _idleTimer?.cancel();
    if (isEmpty && !_isPressed) return;
    _sequence = '';
    _buffer = '';
    _isPressed = false;
    _pressStartedAt = null;
    notifyListeners();
  }

  String _join(String sequence, String letter) {
    if (letter.isEmpty) return sequence;
    if (sequence.isEmpty || sequence.endsWith(_wordGap)) return sequence + letter;
    return '$sequence $letter';
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }
}
