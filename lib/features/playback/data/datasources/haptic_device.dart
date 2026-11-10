import 'package:vibration/vibration.dart';

abstract class HapticDevice {
  Future<bool> hasVibrator();

  Future<void> vibratePattern(List<int> pattern);

  Future<void> cancel();
}

class VibrationHapticDevice implements HapticDevice {
  const VibrationHapticDevice();

  @override
  Future<bool> hasVibrator() async => await Vibration.hasVibrator();

  @override
  Future<void> vibratePattern(List<int> pattern) => Vibration.vibrate(pattern: pattern);

  @override
  Future<void> cancel() => Vibration.cancel();
}
