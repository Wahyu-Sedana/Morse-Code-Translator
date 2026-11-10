import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/features/playback/domain/entities/signal_pulse.dart';
import 'package:morse_translator/features/playback/domain/usecases/build_signal_timeline.dart';

void main() {
  const build = BuildSignalTimeline();
  const unit = Duration(milliseconds: 60);

  Duration units(int n) => unit * n;

  test('unit duration follows the PARIS standard', () {
    expect(BuildSignalTimeline.unitFor(20), unit);
    expect(BuildSignalTimeline.unitFor(15), const Duration(milliseconds: 80));
  });

  test('a dot is one unit on', () {
    expect(build(const TimelineParams(morse: '.', wpm: 20)), [SignalPulse.on(units(1))]);
  });

  test('a dash is three units on', () {
    expect(build(const TimelineParams(morse: '-', wpm: 20)), [SignalPulse.on(units(3))]);
  });

  test('symbols inside a letter are separated by one unit', () {
    expect(build(const TimelineParams(morse: '.-', wpm: 20)), [
      SignalPulse.on(units(1)),
      SignalPulse.off(units(1)),
      SignalPulse.on(units(3)),
    ]);
  });

  test('letters are separated by three units', () {
    expect(build(const TimelineParams(morse: '. -', wpm: 20)), [
      SignalPulse.on(units(1)),
      SignalPulse.off(units(3)),
      SignalPulse.on(units(3)),
    ]);
  });

  test('words are separated by seven units', () {
    expect(build(const TimelineParams(morse: '. / -', wpm: 20)), [
      SignalPulse.on(units(1)),
      SignalPulse.off(units(7)),
      SignalPulse.on(units(3)),
    ]);
  });

  test('ignores characters that are not dots or dashes', () {
    expect(build(const TimelineParams(morse: '.x', wpm: 20)), [SignalPulse.on(units(1))]);
  });

  test('returns an empty timeline for empty morse', () {
    expect(build(const TimelineParams(morse: '  ', wpm: 20)), isEmpty);
  });

  test('total duration sums every pulse', () {
    final timeline = build(const TimelineParams(morse: '... --- ...', wpm: 20));
    expect(totalDuration(timeline), units(27));
  });
}
