import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/features/playback/data/services/wav_encoder.dart';
import 'package:morse_translator/features/playback/domain/entities/signal_pulse.dart';

void main() {
  const encoder = WavEncoder(sampleRate: 8000, frequency: 500, ramp: Duration.zero);
  const timeline = [SignalPulse.on(Duration(milliseconds: 100)), SignalPulse.off(Duration(milliseconds: 50))];

  String ascii(Uint8List bytes, int start, int length) => String.fromCharCodes(bytes.sublist(start, start + length));

  test('writes a valid 16 bit mono PCM header', () {
    final bytes = encoder.encode(timeline);
    final data = ByteData.sublistView(bytes);

    expect(ascii(bytes, 0, 4), 'RIFF');
    expect(ascii(bytes, 8, 4), 'WAVE');
    expect(ascii(bytes, 12, 4), 'fmt ');
    expect(data.getUint16(20, Endian.little), 1);
    expect(data.getUint16(22, Endian.little), 1);
    expect(data.getUint32(24, Endian.little), 8000);
    expect(data.getUint16(34, Endian.little), 16);
    expect(ascii(bytes, 36, 4), 'data');
  });

  test('data size matches the timeline length', () {
    final bytes = encoder.encode(timeline);
    final data = ByteData.sublistView(bytes);
    const samples = 800 + 400;

    expect(data.getUint32(40, Endian.little), samples * 2);
    expect(data.getUint32(4, Endian.little), 36 + samples * 2);
    expect(bytes.length, WavEncoder.headerSize + samples * 2);
  });

  test('on pulses carry signal and off pulses are silent', () {
    final bytes = encoder.encode(timeline);
    final data = ByteData.sublistView(bytes);
    int sampleAt(int index) => data.getInt16(WavEncoder.headerSize + index * 2, Endian.little);

    final tone = List.generate(800, sampleAt);
    final silence = List.generate(400, (i) => sampleAt(800 + i));

    expect(tone.any((v) => v.abs() > 1000), isTrue);
    expect(silence.every((v) => v == 0), isTrue);
  });

  test('empty timeline produces only a header', () {
    expect(encoder.encode(const []).length, WavEncoder.headerSize);
  });
}
