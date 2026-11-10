import 'dart:isolate';
import 'dart:typed_data';

import '../../domain/entities/signal_pulse.dart';
import '../../domain/repositories/signal_output_repository.dart';
import '../datasources/haptic_device.dart';
import '../datasources/tone_player.dart';
import '../services/wav_encoder.dart';

class SignalOutputRepositoryImpl implements SignalOutputRepository {
  const SignalOutputRepositoryImpl({
    required TonePlayer tonePlayer,
    required HapticDevice hapticDevice,
    WavEncoder encoder = const WavEncoder(),
  }) : _tonePlayer = tonePlayer,
       _hapticDevice = hapticDevice,
       _encoder = encoder;

  final TonePlayer _tonePlayer;
  final HapticDevice _hapticDevice;
  final WavEncoder _encoder;

  static List<int> vibrationPatternOf(List<SignalPulse> timeline) {
    final pattern = <int>[];
    var expectOn = false;
    for (final pulse in timeline) {
      if (pulse.isOn != expectOn) pattern.add(0);
      pattern.add(pulse.duration.inMilliseconds);
      expectOn = !pulse.isOn;
    }
    return pattern;
  }

  /// Audio longer than this is encoded on a background isolate so the UI
  /// thread never stalls. Shorter clips (single letters, short words) stay
  /// inline because spawning an isolate would only add latency.
  static const Duration backgroundEncodeThreshold = Duration(seconds: 10);

  Future<Uint8List> _encode(List<SignalPulse> timeline) async {
    final total = timeline.fold<Duration>(Duration.zero, (sum, pulse) => sum + pulse.duration);
    if (total <= backgroundEncodeThreshold) return _encoder.encode(timeline);
    final encoder = _encoder;
    return Isolate.run(() => encoder.encode(timeline));
  }

  @override
  Future<void> play(List<SignalPulse> timeline, {required bool sound, required bool vibration}) async {
    if (timeline.isEmpty) return;
    final tasks = <Future<void>>[];
    if (sound) tasks.add(_encode(timeline).then(_tonePlayer.playWav));
    if (vibration && await _hapticDevice.hasVibrator()) {
      tasks.add(_hapticDevice.vibratePattern(vibrationPatternOf(timeline)));
    }
    await Future.wait(tasks);
  }

  @override
  Future<void> stop() async {
    await Future.wait([_tonePlayer.stop(), _hapticDevice.cancel()]);
  }
}
