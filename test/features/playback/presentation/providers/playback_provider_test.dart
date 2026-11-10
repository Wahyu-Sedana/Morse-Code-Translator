import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_translator/core/error/failures.dart';
import 'package:morse_translator/core/usecase/usecase.dart';
import 'package:morse_translator/features/playback/domain/entities/output_options.dart';
import 'package:morse_translator/features/playback/domain/repositories/signal_output_repository.dart';
import 'package:morse_translator/features/playback/domain/usecases/build_signal_timeline.dart';
import 'package:morse_translator/features/playback/domain/usecases/get_output_options.dart';
import 'package:morse_translator/features/playback/domain/usecases/save_output_options.dart';
import 'package:morse_translator/features/playback/presentation/providers/playback_provider.dart';

class MockOutput extends Mock implements SignalOutputRepository {}

class MockGetOptions extends Mock implements GetOutputOptions {}

class MockSaveOptions extends Mock implements SaveOutputOptions {}

void main() {
  late MockOutput output;
  late MockGetOptions getOptions;
  late MockSaveOptions saveOptions;
  late PlaybackProvider provider;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const OutputOptions());
    registerFallbackValue(<Never>[]);
  });

  setUp(() {
    output = MockOutput();
    getOptions = MockGetOptions();
    saveOptions = MockSaveOptions();
    when(
      () => output.play(
        any(),
        sound: any(named: 'sound'),
        vibration: any(named: 'vibration'),
      ),
    ).thenAnswer((_) async {});
    when(() => output.stop()).thenAnswer((_) async {});
    when(() => saveOptions(any())).thenAnswer((_) async => const Right(unit));
    provider = PlaybackProvider(
      buildTimeline: const BuildSignalTimeline(),
      output: output,
      getOutputOptions: getOptions,
      saveOutputOptions: saveOptions,
    );
  });

  test('loadOptions applies stored options', () async {
    when(() => getOptions(any())).thenAnswer((_) async => const Right(OutputOptions(wpm: 25, sound: false)));

    await provider.loadOptions();

    expect(provider.options, const OutputOptions(wpm: 25, sound: false));
  });

  test('loadOptions keeps defaults on failure', () async {
    when(() => getOptions(any())).thenAnswer((_) async => const Left(CacheFailure()));

    await provider.loadOptions();

    expect(provider.options, const OutputOptions());
  });

  test('changing speed clamps and persists', () async {
    await provider.setWpm(100);

    expect(provider.options.wpm, OutputOptions.maxWpm);
    verify(() => saveOptions(const OutputOptions(wpm: OutputOptions.maxWpm))).called(1);
  });

  test('toggles persist each output channel', () async {
    await provider.setSound(false);
    await provider.setLight(false);
    await provider.setVibration(true);

    expect(provider.options, const OutputOptions(sound: false, light: false, vibration: true));
  });

  test('play drives the lamp through the timeline and then finishes', () {
    fakeAsync((async) {
      provider.setWpm(20);
      async.flushMicrotasks();

      provider.play('.-', key: 'main');
      async.flushMicrotasks();
      async.elapse(Duration.zero);

      expect(provider.isPlaying, isTrue);
      expect(provider.isPlayingKey('main'), isTrue);
      expect(provider.lampOn, isTrue);

      async.elapse(const Duration(milliseconds: 61));
      expect(provider.lampOn, isFalse);

      async.elapse(const Duration(milliseconds: 60));
      expect(provider.lampOn, isTrue);

      async.elapse(const Duration(milliseconds: 180));
      expect(provider.lampOn, isFalse);
      expect(provider.isPlaying, isFalse);
      expect(provider.isPlayingKey('main'), isFalse);
    });
  });

  test('play sends the timeline to the output with the current channels', () {
    fakeAsync((async) {
      provider.setVibration(true);
      async.flushMicrotasks();

      provider.play('.');
      async.flushMicrotasks();

      verify(() => output.play(any(that: hasLength(1)), sound: true, vibration: true)).called(1);
    });
  });

  test('lamp stays off when the light channel is disabled', () {
    fakeAsync((async) {
      provider.setLight(false);
      async.flushMicrotasks();

      provider.play('.');
      async.flushMicrotasks();

      expect(provider.isPlaying, isTrue);
      expect(provider.lampOn, isFalse);
      async.elapse(const Duration(seconds: 1));
    });
  });

  test('stop cancels the timeline and the output', () {
    fakeAsync((async) {
      provider.play('---');
      async.flushMicrotasks();

      provider.stop();
      async.flushMicrotasks();

      expect(provider.isPlaying, isFalse);
      expect(provider.lampOn, isFalse);
      verify(() => output.stop()).called(1);

      async.elapse(const Duration(seconds: 2));
      expect(provider.lampOn, isFalse);
    });
  });

  test('play ignores morse without signals', () {
    fakeAsync((async) {
      provider.play('  ');
      async.flushMicrotasks();

      expect(provider.isPlaying, isFalse);
      verifyNever(
        () => output.play(
          any(),
          sound: any(named: 'sound'),
          vibration: any(named: 'vibration'),
        ),
      );
    });
  });
}
