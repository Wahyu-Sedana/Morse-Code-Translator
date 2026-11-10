import 'package:equatable/equatable.dart';

import '../../../playback/domain/usecases/build_signal_timeline.dart';

class ClassifyPress {
  const ClassifyPress({this.minimumThreshold = const Duration(milliseconds: 150)});

  final Duration minimumThreshold;

  Duration thresholdFor(int wpm) {
    final twoUnits = BuildSignalTimeline.unitFor(wpm) * 2;
    return twoUnits > minimumThreshold ? twoUnits : minimumThreshold;
  }

  String call(PressParams params) => params.duration < thresholdFor(params.wpm) ? '.' : '-';
}

class PressParams extends Equatable {
  const PressParams({required this.duration, required this.wpm});

  final Duration duration;
  final int wpm;

  @override
  List<Object?> get props => [duration, wpm];
}
