import 'package:equatable/equatable.dart';

class OutputOptions extends Equatable {
  const OutputOptions({this.sound = true, this.light = true, this.vibration = false, this.wpm = defaultWpm});

  static const int defaultWpm = 15;
  static const int minWpm = 5;
  static const int maxWpm = 40;

  final bool sound;
  final bool light;
  final bool vibration;
  final int wpm;

  OutputOptions copyWith({bool? sound, bool? light, bool? vibration, int? wpm}) {
    return OutputOptions(
      sound: sound ?? this.sound,
      light: light ?? this.light,
      vibration: vibration ?? this.vibration,
      wpm: (wpm ?? this.wpm).clamp(minWpm, maxWpm),
    );
  }

  @override
  List<Object?> get props => [sound, light, vibration, wpm];
}
