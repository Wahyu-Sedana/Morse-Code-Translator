import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

abstract class TonePlayer {
  Future<void> playWav(Uint8List bytes);

  Future<void> stop();
}

class AudioplayersTonePlayer implements TonePlayer {
  AudioplayersTonePlayer({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  File? _lastFile;

  @override
  Future<void> playWav(Uint8List bytes) async {
    await _player.stop();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/morse_${DateTime.now().microsecondsSinceEpoch}.wav');
    await file.writeAsBytes(bytes, flush: true);
    final previous = _lastFile;
    _lastFile = file;
    await _player.play(DeviceFileSource(file.path));
    if (previous != null && await previous.exists()) {
      await previous.delete();
    }
  }

  @override
  Future<void> stop() => _player.stop();
}
