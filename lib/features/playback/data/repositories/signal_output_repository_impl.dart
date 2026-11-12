import '../../domain/entities/signal_pulse.dart';
import '../../domain/repositories/signal_output_repository.dart';
import '../datasources/haptic_device.dart';
import '../datasources/tone_player.dart';
import '../datasources/torch_device.dart';
import '../services/wav_encoder.dart';

class SignalOutputRepositoryImpl implements SignalOutputRepository {
  const SignalOutputRepositoryImpl({
    required TonePlayer tonePlayer,
    required HapticDevice hapticDevice,
    required TorchDevice torchDevice,
    WavEncoder encoder = const WavEncoder(),
  }) : _tonePlayer = tonePlayer,
       _hapticDevice = hapticDevice,
       _torchDevice = torchDevice,
       _encoder = encoder;

  final TonePlayer _tonePlayer;
  final HapticDevice _hapticDevice;
  final TorchDevice _torchDevice;
  final WavEncoder _encoder;

  /// Alternating wait/on durations in milliseconds, starting with a wait.
  /// Shared by the vibration motor and the flashlight.
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

  @override
  Future<void> play(
    List<SignalPulse> timeline, {
    required bool sound,
    required bool vibration,
    required bool flashlight,
  }) async {
    if (timeline.isEmpty) return;

    // Start the tone first (encoding and file I/O take a moment), then
    // vibration and flashlight, so all outputs begin together.
    if (sound) await _tonePlayer.playWav(await _encoder.encodeAsync(timeline));

    final pattern = vibrationPatternOf(timeline);
    final tasks = <Future<void>>[];
    if (vibration && await _hapticDevice.hasVibrator()) tasks.add(_hapticDevice.vibratePattern(pattern));
    if (flashlight && await _torchDevice.isAvailable()) tasks.add(_torchDevice.playPattern(pattern));
    await Future.wait(tasks);
  }

  @override
  Future<void> stop() async {
    await Future.wait([_tonePlayer.stop(), _hapticDevice.cancel(), _torchDevice.stop()]);
  }
}
