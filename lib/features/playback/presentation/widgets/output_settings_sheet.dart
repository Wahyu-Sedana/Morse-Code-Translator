import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../domain/entities/output_options.dart';
import '../providers/playback_provider.dart';
import 'speed_control.dart';

class OutputSettingsSheet extends StatelessWidget {
  const OutputSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.ground,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const OutputSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playback = context.read<PlaybackProvider>();
    final options = context.select<PlaybackProvider, OutputOptions>((p) => p.options);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Signal output', style: AppText.display.copyWith(fontSize: 22)),
            const SizedBox(height: 4),
            const Text('Choose how Morse messages are played.', style: TextStyle(fontSize: 14, color: AppColors.muted)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _OptionTile(
                    icon: Icons.volume_up_rounded,
                    title: 'Sound',
                    subtitle: '620 Hz beep tone',
                    value: options.sound,
                    onChanged: playback.setSound,
                  ),
                  const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
                  _OptionTile(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Light',
                    subtitle: 'On-screen signal lamp',
                    value: options.light,
                    onChanged: playback.setLight,
                  ),
                  const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
                  _OptionTile(
                    icon: Icons.vibration_rounded,
                    title: 'Vibration',
                    subtitle: 'Vibration pattern follows the signal',
                    value: options.vibration,
                    onChanged: playback.setVibration,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const SpeedControl(),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      secondary: Icon(icon, color: AppColors.ink),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
    );
  }
}
