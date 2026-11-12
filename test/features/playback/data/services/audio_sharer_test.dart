import 'package:flutter_test/flutter_test.dart';
import 'package:morse_translator/features/playback/data/services/audio_sharer.dart';

void main() {
  test('builds a safe, short file name from the message', () {
    expect(WavFileSharer.slugOf('HELLO WORLD'), 'hello-world');
    expect(WavFileSharer.slugOf('  SOS!!  '), 'sos');
    expect(WavFileSharer.slugOf('???'), 'signal');
    expect(WavFileSharer.slugOf(''), 'signal');
    expect(WavFileSharer.slugOf('A' * 40).length, 32);
  });
}
