import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../premium/presentation/widgets/unlock_sheet.dart';
import '../../data/services/audio_sharer.dart';
import '../providers/playback_provider.dart';

/// Premium action: export [morse] as a WAV file and open the share sheet.
/// Offers the rewarded video first when premium is locked.
Future<void> shareSignalAudio(BuildContext context, {required String morse, required String label}) async {
  final unlocked = await UnlockSheet.ensureUnlocked(context);
  if (!unlocked || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final wpm = context.read<PlaybackProvider>().options.wpm;
  try {
    await context.read<AudioSharer>().shareWav(morse, wpm: wpm, label: label);
  } catch (_) {
    messenger.showSnackBar(const SnackBar(content: Text('Could not share the audio')));
  }
}
