import 'package:equatable/equatable.dart';

class SignalPulse extends Equatable {
  const SignalPulse({required this.isOn, required this.duration});

  const SignalPulse.on(this.duration) : isOn = true;

  const SignalPulse.off(this.duration) : isOn = false;

  final bool isOn;
  final Duration duration;

  @override
  List<Object?> get props => [isOn, duration];
}

Duration totalDuration(List<SignalPulse> timeline) =>
    timeline.fold(Duration.zero, (sum, pulse) => sum + pulse.duration);
