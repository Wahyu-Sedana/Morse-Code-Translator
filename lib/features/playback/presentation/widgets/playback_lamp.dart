import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/signal_lamp.dart';
import '../providers/playback_provider.dart';

/// Signal lamp bound to one playback key. Only this widget rebuilds while the
/// lamp blinks, so the surrounding page stays still during playback.
class PlaybackLamp extends StatelessWidget {
  const PlaybackLamp({super.key, required this.playbackKey, this.size = 14});

  final String playbackKey;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isOn = context.select<PlaybackProvider, bool>((p) => p.isPlayingKey(playbackKey) && p.lampOn);
    return SignalLamp(isOn: isOn, size: size);
  }
}
