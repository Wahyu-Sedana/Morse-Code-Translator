import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../premium/presentation/providers/premium_provider.dart';
import '../../../premium/presentation/widgets/unlock_sheet.dart';
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const OutputSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playback = context.read<PlaybackProvider>();
    final options = context.select<PlaybackProvider, OutputOptions>((p) => p.options);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Signal output', style: AppText.display.copyWith(fontSize: 22)),
            const SizedBox(height: 4),
            const Text('Choose how Morse messages are played.', style: TextStyle(fontSize: 14, color: AppColors.muted)),
            const SizedBox(height: 16),
            // A Material (not a decorated Container) so the list tiles' ink
            // splashes paint on top of the card background.
            Material(
              color: AppColors.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border),
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
                  const Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
                  _FlashlightTile(enabled: options.flashlight, onChanged: playback.setFlashlight),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const SpeedControl(),
            const _PrivacySettingsButton(),
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

/// Premium flashlight toggle. Locked until the user watches a rewarded video.
class _FlashlightTile extends StatelessWidget {
  const _FlashlightTile({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  Future<void> _unlockAndEnable(BuildContext context) async {
    if (await UnlockSheet.ensureUnlocked(context)) onChanged(true);
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = context.select<PremiumProvider, bool>((p) => p.isUnlocked);
    final remaining = context.select<PremiumProvider, Duration>((p) => p.remaining);
    const title = Text(
      'Flashlight',
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
    );
    if (!unlocked) {
      return ListTile(
        onTap: () => _unlockAndEnable(context),
        contentPadding: const EdgeInsets.fromLTRB(16, 2, 12, 2),
        leading: const Icon(Icons.flashlight_on_rounded, color: AppColors.ink),
        title: title,
        subtitle: const Text(
          "Blink your phone's flashlight. Unlock free with a short video.",
          style: TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        trailing: const Icon(Icons.lock_outline_rounded, color: AppColors.muted),
      );
    }
    return SwitchListTile(
      value: enabled,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      secondary: const Icon(Icons.flashlight_on_rounded, color: AppColors.ink),
      title: title,
      subtitle: Text(
        "Blink your phone's flashlight. Premium, ${formatRemaining(remaining)}",
        style: const TextStyle(fontSize: 13, color: AppColors.muted),
      ),
    );
  }
}

/// Lets users in regions that require it (EEA, UK, Switzerland) change their
/// ad consent at any time.
class _PrivacySettingsButton extends StatelessWidget {
  const _PrivacySettingsButton();

  @override
  Widget build(BuildContext context) {
    final required = context.select<PremiumProvider, bool>((p) => p.privacyOptionsRequired);
    if (!required) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: TextButton.icon(
          onPressed: () => context.read<PremiumProvider>().showPrivacyOptions(),
          style: TextButton.styleFrom(foregroundColor: AppColors.muted),
          icon: const Icon(Icons.privacy_tip_outlined, size: 18),
          label: const Text('Privacy settings'),
        ),
      ),
    );
  }
}
