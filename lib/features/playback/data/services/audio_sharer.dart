import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/usecases/build_signal_timeline.dart';
import 'wav_encoder.dart';

/// Exports a Morse signal as a WAV file and opens the system share sheet.
abstract class AudioSharer {
  Future<void> shareWav(String morse, {required int wpm, required String label});
}

class WavFileSharer implements AudioSharer {
  const WavFileSharer({
    WavEncoder encoder = const WavEncoder(),
    BuildSignalTimeline buildTimeline = const BuildSignalTimeline(),
  }) : _encoder = encoder,
       _buildTimeline = buildTimeline;

  final WavEncoder _encoder;
  final BuildSignalTimeline _buildTimeline;

  /// File-name friendly version of the message, e.g. "HELLO WORLD" -> "hello-world".
  static String slugOf(String label) {
    final slug = label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.isEmpty) return 'signal';
    return slug.length > 32 ? slug.substring(0, 32).replaceAll(RegExp(r'-+$'), '') : slug;
  }

  @override
  Future<void> shareWav(String morse, {required int wpm, required String label}) async {
    final timeline = _buildTimeline(TimelineParams(morse: morse, wpm: wpm));
    if (timeline.isEmpty) return;
    final bytes = await _encoder.encodeAsync(timeline);
    final dir = await getTemporaryDirectory();
    final name = 'morse-${slugOf(label)}.wav';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'audio/wav', name: name)],
        title: 'Morse code audio',
        subject: label.isEmpty ? 'Morse code' : label,
      ),
    );
  }
}
