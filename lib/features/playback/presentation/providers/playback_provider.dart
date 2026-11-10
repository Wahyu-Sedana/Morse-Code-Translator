import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/output_options.dart';
import '../../domain/entities/signal_pulse.dart';
import '../../domain/repositories/signal_output_repository.dart';
import '../../domain/usecases/build_signal_timeline.dart';
import '../../domain/usecases/get_output_options.dart';
import '../../domain/usecases/save_output_options.dart';

class PlaybackProvider extends ChangeNotifier {
  PlaybackProvider({
    required BuildSignalTimeline buildTimeline,
    required SignalOutputRepository output,
    required GetOutputOptions getOutputOptions,
    required SaveOutputOptions saveOutputOptions,
  }) : _buildTimeline = buildTimeline,
       _output = output,
       _getOutputOptions = getOutputOptions,
       _saveOutputOptions = saveOutputOptions;

  final BuildSignalTimeline _buildTimeline;
  final SignalOutputRepository _output;
  final GetOutputOptions _getOutputOptions;
  final SaveOutputOptions _saveOutputOptions;

  final List<Timer> _timers = [];
  OutputOptions _options = const OutputOptions();
  bool _isPlaying = false;
  bool _lampOn = false;
  String? _playingKey;
  int _session = 0;
  bool _disposed = false;

  OutputOptions get options => _options;
  bool get isPlaying => _isPlaying;
  bool get lampOn => _lampOn;
  String? get playingKey => _playingKey;

  bool isPlayingKey(String key) => _isPlaying && _playingKey == key;

  Future<void> loadOptions() async {
    final result = await _getOutputOptions(const NoParams());
    result.fold((_) {}, (options) {
      _options = options;
      _notify();
    });
  }

  Future<void> setWpm(int wpm) => _update(_options.copyWith(wpm: wpm));

  Future<void> setSound(bool value) => _update(_options.copyWith(sound: value));

  Future<void> setLight(bool value) => _update(_options.copyWith(light: value));

  Future<void> setVibration(bool value) => _update(_options.copyWith(vibration: value));

  Future<void> _update(OutputOptions options) async {
    if (options == _options) return;
    _options = options;
    _notify();
    await _saveOutputOptions(options);
  }

  Future<void> toggle(String morse, {String key = 'main'}) {
    if (isPlayingKey(key)) return stop();
    return play(morse, key: key);
  }

  Future<void> play(String morse, {String key = 'main'}) async {
    if (_isPlaying) await stop();
    final timeline = _buildTimeline(TimelineParams(morse: morse, wpm: _options.wpm));
    if (timeline.isEmpty) return;

    final session = ++_session;
    _isPlaying = true;
    _playingKey = key;
    _notify();

    try {
      await _output.play(timeline, sound: _options.sound, vibration: _options.vibration);
    } catch (_) {}
    if (session != _session) return;
    _schedule(timeline, session);
  }

  void _schedule(List<SignalPulse> timeline, int session) {
    final useLight = _options.light;
    var offset = Duration.zero;
    for (final pulse in timeline) {
      if (pulse.isOn && useLight) {
        final start = offset;
        final end = offset + pulse.duration;
        _timers.add(Timer(start, () => _setLamp(true, session)));
        _timers.add(Timer(end, () => _setLamp(false, session)));
      }
      offset += pulse.duration;
    }
    _timers.add(Timer(offset, () => _finish(session)));
  }

  void _setLamp(bool value, int session) {
    if (session != _session || _lampOn == value) return;
    _lampOn = value;
    _notify();
  }

  void _finish(int session) {
    if (session != _session) return;
    _cancelTimers();
    _isPlaying = false;
    _lampOn = false;
    _playingKey = null;
    _notify();
  }

  Future<void> stop() async {
    _session++;
    _cancelTimers();
    final wasActive = _isPlaying || _lampOn;
    _isPlaying = false;
    _lampOn = false;
    _playingKey = null;
    if (wasActive) _notify();
    try {
      await _output.stop();
    } catch (_) {}
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _session++;
    _cancelTimers();
    _output.stop().catchError((_) {});
    super.dispose();
  }
}
