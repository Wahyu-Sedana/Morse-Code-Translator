import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../providers/premium_provider.dart';

/// Offers a rewarded video in exchange for 24 hours of premium features.
class UnlockSheet extends StatelessWidget {
  const UnlockSheet({super.key});

  /// Returns true right away when premium is active; otherwise shows the
  /// sheet and returns whether the user unlocked it.
  static Future<bool> ensureUnlocked(BuildContext context) async {
    final premium = context.read<PremiumProvider>();
    if (premium.isUnlocked) return true;
    await show(context);
    return premium.isUnlocked;
  }

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.ground,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const UnlockSheet(),
    );
  }

  Future<void> _watch(BuildContext context, PremiumProvider premium) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final earned = await premium.watchAdToUnlock();
    if (earned) {
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Premium unlocked for 24 hours')));
    } else {
      messenger.showSnackBar(const SnackBar(content: Text('Watch the full video to unlock')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();
    final unlocked = premium.isUnlocked;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              unlocked ? 'Premium unlocked' : 'Unlock premium features',
              style: AppText.display.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              unlocked
                  ? 'Enjoy every feature. ${formatRemaining(premium.remaining)}.'
                  : 'Watch a short video to use these features free for 24 hours.',
              style: const TextStyle(fontSize: 14, color: AppColors.muted),
            ),
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
              child: const Column(
                children: [
                  _Feature(
                    icon: Icons.flashlight_on_rounded,
                    title: 'Flashlight signal',
                    body: "Blink your phone's flashlight in Morse code.",
                  ),
                  Divider(height: 1, color: AppColors.border, indent: 16, endIndent: 16),
                  _Feature(
                    icon: Icons.ios_share_rounded,
                    title: 'Share as audio',
                    body: 'Save signals as audio files and send them to anyone.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (unlocked)
              FilledButton(onPressed: () => Navigator.of(context).pop(), style: _buttonStyle, child: const Text('Done'))
            else ...[
              FilledButton.icon(
                onPressed: premium.isAdReady && !premium.isShowingAd ? () => _watch(context, premium) : null,
                style: _buttonStyle,
                icon: premium.isShowingAd || premium.isAdLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.muted),
                      )
                    : const Icon(Icons.play_circle_outline_rounded),
                label: Text(premium.isAdLoading && !premium.isAdReady ? 'Loading video...' : 'Watch video'),
              ),
              if (!premium.isAdReady && !premium.isAdLoading && !premium.isShowingAd) ...[
                const SizedBox(height: 10),
                const Text(
                  'No video is available right now. Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                TextButton(onPressed: premium.reloadAd, child: const Text('Try again')),
              ],
            ],
          ],
        ),
      ),
    );
  }

  static final ButtonStyle _buttonStyle = FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    backgroundColor: AppColors.ink,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    textStyle: AppText.button,
  );
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: AppColors.ink),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
      ),
      subtitle: Text(body, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
    );
  }
}
