import 'package:equatable/equatable.dart';

import '../entities/signal_pulse.dart';

class BuildSignalTimeline {
  const BuildSignalTimeline();

  static Duration unitFor(int wpm) => Duration(microseconds: (1200000 / wpm).round());

  List<SignalPulse> call(TimelineParams params) {
    final unit = unitFor(params.wpm);
    final words = params.morse
        .trim()
        .split(RegExp(r'\s*/\s*'))
        .map((word) => word.trim().split(RegExp(r'\s+')).map(_symbolsOf).where((s) => s.isNotEmpty).toList())
        .where((letters) => letters.isNotEmpty)
        .toList();

    final pulses = <SignalPulse>[];
    for (var w = 0; w < words.length; w++) {
      if (w > 0) pulses.add(SignalPulse.off(unit * 7));
      final letters = words[w];
      for (var l = 0; l < letters.length; l++) {
        if (l > 0) pulses.add(SignalPulse.off(unit * 3));
        final symbols = letters[l];
        for (var s = 0; s < symbols.length; s++) {
          if (s > 0) pulses.add(SignalPulse.off(unit));
          pulses.add(SignalPulse.on(symbols[s] == '.' ? unit : unit * 3));
        }
      }
    }
    return pulses;
  }

  String _symbolsOf(String letter) => letter.replaceAll(RegExp(r'[^.\-]'), '');
}

class TimelineParams extends Equatable {
  const TimelineParams({required this.morse, required this.wpm});

  final String morse;
  final int wpm;

  @override
  List<Object?> get props => [morse, wpm];
}
