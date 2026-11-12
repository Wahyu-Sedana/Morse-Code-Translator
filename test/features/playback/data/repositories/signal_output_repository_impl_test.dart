import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_translator/features/playback/data/datasources/haptic_device.dart';
import 'package:morse_translator/features/playback/data/datasources/tone_player.dart';
import 'package:morse_translator/features/playback/data/datasources/torch_device.dart';
import 'package:morse_translator/features/playback/data/repositories/signal_output_repository_impl.dart';
import 'package:morse_translator/features/playback/data/services/wav_encoder.dart';
import 'package:morse_translator/features/playback/domain/entities/signal_pulse.dart';

class MockTonePlayer extends Mock implements TonePlayer {}

class MockHapticDevice extends Mock implements HapticDevice {}

class MockTorchDevice extends Mock implements TorchDevice {}

void main() {
  late MockTonePlayer tonePlayer;
  late MockHapticDevice haptic;
  late MockTorchDevice torch;
  late SignalOutputRepositoryImpl repository;

  const timeline = [
    SignalPulse.on(Duration(milliseconds: 60)),
    SignalPulse.off(Duration(milliseconds: 60)),
    SignalPulse.on(Duration(milliseconds: 180)),
  ];

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    tonePlayer = MockTonePlayer();
    haptic = MockHapticDevice();
    torch = MockTorchDevice();
    repository = SignalOutputRepositoryImpl(tonePlayer: tonePlayer, hapticDevice: haptic, torchDevice: torch);
    when(() => tonePlayer.playWav(any())).thenAnswer((_) async {});
    when(() => tonePlayer.stop()).thenAnswer((_) async {});
    when(() => haptic.hasVibrator()).thenAnswer((_) async => true);
    when(() => haptic.vibratePattern(any())).thenAnswer((_) async {});
    when(() => haptic.cancel()).thenAnswer((_) async {});
    when(() => torch.isAvailable()).thenAnswer((_) async => true);
    when(() => torch.playPattern(any())).thenAnswer((_) async {});
    when(() => torch.stop()).thenAnswer((_) async {});
  });

  test('vibration pattern starts with a zero wait and alternates', () {
    expect(SignalOutputRepositoryImpl.vibrationPatternOf(timeline), [0, 60, 60, 180]);
  });

  test('plays a wav when sound is enabled', () async {
    await repository.play(timeline, sound: true, vibration: false, flashlight: false);

    final bytes = verify(() => tonePlayer.playWav(captureAny())).captured.single as Uint8List;
    expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
    verifyNever(() => haptic.vibratePattern(any()));
  });

  test('encodes long audio off the UI thread and still plays a valid wav', () async {
    final long = [
      for (var i = 0; i < 40; i++) ...[
        const SignalPulse.on(Duration(milliseconds: 180)),
        const SignalPulse.off(Duration(milliseconds: 180)),
      ],
    ];

    await repository.play(long, sound: true, vibration: false, flashlight: false);

    final bytes = verify(() => tonePlayer.playWav(captureAny())).captured.single as Uint8List;
    expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
    expect(bytes.length, const WavEncoder().encode(long).length);
  });

  test('vibrates when vibration is enabled and supported', () async {
    await repository.play(timeline, sound: false, vibration: true, flashlight: false);

    verify(() => haptic.vibratePattern([0, 60, 60, 180])).called(1);
    verifyNever(() => tonePlayer.playWav(any()));
  });

  test('skips vibration when the device has no vibrator', () async {
    when(() => haptic.hasVibrator()).thenAnswer((_) async => false);

    await repository.play(timeline, sound: false, vibration: true, flashlight: false);

    verifyNever(() => haptic.vibratePattern(any()));
  });

  test('does nothing for an empty timeline', () async {
    await repository.play(const [], sound: true, vibration: true, flashlight: false);

    verifyNever(() => tonePlayer.playWav(any()));
    verifyNever(() => haptic.hasVibrator());
  });

  test('stop halts sound and vibration', () async {
    await repository.stop();

    verify(() => tonePlayer.stop()).called(1);
    verify(() => haptic.cancel()).called(1);
    verify(() => torch.stop()).called(1);
  });

  test('blinks the flashlight with the signal pattern when enabled', () async {
    await repository.play(timeline, sound: false, vibration: false, flashlight: true);

    verify(() => torch.playPattern([0, 60, 60, 180])).called(1);
  });

  test('skips the flashlight when the device has none', () async {
    when(() => torch.isAvailable()).thenAnswer((_) async => false);

    await repository.play(timeline, sound: false, vibration: false, flashlight: true);

    verifyNever(() => torch.playPattern(any()));
  });

  test('starts the tone before vibration and flashlight so they stay in sync', () async {
    final order = <String>[];
    when(() => tonePlayer.playWav(any())).thenAnswer((_) async => order.add('sound'));
    when(() => haptic.vibratePattern(any())).thenAnswer((_) async => order.add('vibration'));
    when(() => torch.playPattern(any())).thenAnswer((_) async => order.add('flashlight'));

    await repository.play(timeline, sound: true, vibration: true, flashlight: true);

    expect(order.first, 'sound');
    expect(order, containsAll(['vibration', 'flashlight']));
  });
}
