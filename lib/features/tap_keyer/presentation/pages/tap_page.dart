import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/morse_signal.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/square_icon_button.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../playback/presentation/providers/playback_provider.dart';
import '../../../playback/presentation/widgets/share_audio.dart';
import '../providers/tap_provider.dart';
import '../widgets/tap_pad.dart';

class TapPage extends StatelessWidget {
  const TapPage({super.key});

  static const String playbackKey = 'tap';

  Future<void> _save(BuildContext context, TapProvider tap) async {
    tap.commitLetter();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<HistoryProvider>().add(
      text: tap.decoded,
      morse: tap.morse,
      source: HistorySource.tap,
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(ok ? 'Saved to history' : 'No signal to save yet')));
  }

  @override
  Widget build(BuildContext context) {
    final tap = context.watch<TapProvider>();
    final playback = context.read<PlaybackProvider>();
    final decoded = tap.decoded;
    final isPlaying = context.select<PlaybackProvider, bool>((p) => p.isPlayingKey(playbackKey));

    return Column(
      children: [
        const ScreenHeader(eyebrow: '\u2212 \u00B7\u2212 \u00B7\u2212\u2212\u00B7', title: 'Tap a Signal'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SurfaceCard(
                  padding: const EdgeInsets.fromLTRB(18, 14, 10, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(child: Text('Result', style: AppText.label)),
                          SquareIconButton(
                            icon: isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                            tooltip: isPlaying ? 'Stop' : 'Play signal',
                            background: AppColors.ground,
                            radius: 12,
                            onPressed: tap.isEmpty ? null : () => playback.toggle(tap.morse, key: playbackKey),
                          ),
                          const SizedBox(width: 6),
                          SquareIconButton(
                            icon: Icons.bookmark_add_outlined,
                            tooltip: 'Save to history',
                            background: AppColors.ground,
                            radius: 12,
                            onPressed: tap.isEmpty ? null : () => _save(context, tap),
                          ),
                          const SizedBox(width: 6),
                          SquareIconButton(
                            icon: Icons.ios_share_rounded,
                            tooltip: 'Share as audio',
                            background: AppColors.ground,
                            radius: 12,
                            onPressed: tap.isEmpty
                                ? null
                                : () {
                                    tap.commitLetter();
                                    shareSignalAudio(context, morse: tap.morse, label: tap.decoded);
                                  },
                          ),
                          const SizedBox(width: 6),
                          SquareIconButton(
                            icon: Icons.delete_outline_rounded,
                            tooltip: 'Clear',
                            background: AppColors.ground,
                            radius: 12,
                            onPressed: tap.isEmpty ? null : tap.clear,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          decoded.isEmpty ? 'Start tapping' : decoded,
                          style: AppText.display.copyWith(
                            fontSize: 32,
                            letterSpacing: 1,
                            color: decoded.isEmpty ? AppColors.placeholder : AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (tap.sequence.isNotEmpty) MorseSignal(code: tap.sequence, size: 10, onDark: false),
                          Container(
                            constraints: const BoxConstraints(minHeight: 28),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(8)),
                            child: tap.buffer.isEmpty
                                ? Text(
                                    '_',
                                    style: AppText.morse.copyWith(fontSize: 16, height: 1, color: AppColors.accent),
                                  )
                                : MorseSignal(code: tap.buffer, size: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final padSize = (constraints.maxHeight - 64).clamp(96.0, 220.0);
                      final showHint = constraints.maxHeight >= padSize + 64;
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TapPad(size: padSize, isPressed: tap.isPressed, onDown: tap.pressDown, onUp: tap.pressUp),
                            if (showHint) ...[
                              const SizedBox(height: 14),
                              const Text(
                                'Letters are added after a short pause',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: TextStyle(fontSize: 13, color: AppColors.muted),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _KeyButton(glyph: '\u00B7', label: 'Dot', onPressed: () => tap.addSymbol('.')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _KeyButton(glyph: '\u2212', label: 'Dash', onPressed: () => tap.addSymbol('-')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _KeyButton(glyph: '/', label: 'Space', onPressed: tap.addWordSpace),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _KeyButton(
                        icon: Icons.backspace_outlined,
                        label: 'Delete',
                        dark: true,
                        onPressed: tap.isEmpty ? null : tap.backspace,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onPressed, this.glyph, this.icon, this.dark = false});

  final String label;
  final String? glyph;
  final IconData? icon;
  final bool dark;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : AppColors.ink;
    return Material(
      color: dark ? AppColors.ink : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: dark ? BorderSide.none : const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon, size: 20, color: foreground)
              else
                Text(
                  glyph ?? '',
                  style: TextStyle(fontSize: 20, height: 1, fontWeight: FontWeight.w700, color: foreground),
                ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: foreground),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
