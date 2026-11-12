import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import '../../domain/entities/signal_pulse.dart';

class WavEncoder {
  const WavEncoder({
    this.sampleRate = 22050,
    this.frequency = 620,
    this.amplitude = 0.45,
    this.ramp = const Duration(milliseconds: 4),
  });

  static const int headerSize = 44;

  final int sampleRate;
  final double frequency;
  final double amplitude;
  final Duration ramp;

  /// Audio longer than this is encoded on a background isolate so the UI
  /// thread never stalls. Shorter clips stay inline because spawning an
  /// isolate would only add latency.
  static const Duration backgroundThreshold = Duration(seconds: 10);

  /// Encodes on a background isolate when the clip is long.
  Future<Uint8List> encodeAsync(List<SignalPulse> timeline) async {
    final total = timeline.fold<Duration>(Duration.zero, (sum, pulse) => sum + pulse.duration);
    if (total <= backgroundThreshold) return encode(timeline);
    final encoder = this;
    return Isolate.run(() => encoder.encode(timeline));
  }

  int samplesFor(Duration duration) => (duration.inMicroseconds * sampleRate / 1000000).round();

  Uint8List encode(List<SignalPulse> timeline) {
    final totalSamples = timeline.fold<int>(0, (sum, pulse) => sum + samplesFor(pulse.duration));
    final dataSize = totalSamples * 2;
    final bytes = ByteData(headerSize + dataSize);
    _writeHeader(bytes, dataSize);

    final rampSamples = samplesFor(ramp);
    final peak = (amplitude * 32767).round();
    var offset = headerSize;
    var phaseIndex = 0;
    for (final pulse in timeline) {
      final count = samplesFor(pulse.duration);
      for (var i = 0; i < count; i++) {
        var value = 0;
        if (pulse.isOn) {
          final edge = math.min(i, count - 1 - i);
          final gain = rampSamples > 0 && edge < rampSamples ? edge / rampSamples : 1.0;
          value = (math.sin(2 * math.pi * frequency * phaseIndex / sampleRate) * peak * gain).round();
        }
        bytes.setInt16(offset, value, Endian.little);
        offset += 2;
        phaseIndex++;
      }
    }
    return bytes.buffer.asUint8List();
  }

  void _writeHeader(ByteData bytes, int dataSize) {
    void ascii(int at, String text) {
      for (var i = 0; i < text.length; i++) {
        bytes.setUint8(at + i, text.codeUnitAt(i));
      }
    }

    ascii(0, 'RIFF');
    bytes.setUint32(4, 36 + dataSize, Endian.little);
    ascii(8, 'WAVE');
    ascii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    ascii(36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);
  }
}
