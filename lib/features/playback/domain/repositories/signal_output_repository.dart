import '../entities/signal_pulse.dart';

abstract class SignalOutputRepository {
  Future<void> play(List<SignalPulse> timeline, {required bool sound, required bool vibration});

  Future<void> stop();
}
