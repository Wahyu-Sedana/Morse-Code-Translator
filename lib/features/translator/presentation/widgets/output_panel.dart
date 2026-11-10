import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/morse_signal.dart';
import '../../../../core/widgets/square_icon_button.dart';

class OutputPanel extends StatelessWidget {
  const OutputPanel({
    super.key,
    required this.label,
    required this.output,
    required this.isMorse,
    required this.lamp,
    required this.isPlaying,
    required this.onPlay,
    required this.onCopy,
    required this.onSave,
  });

  final String label;
  final String output;
  final bool isMorse;
  final Widget lamp;
  final bool isPlaying;
  final VoidCallback? onPlay;
  final VoidCallback? onCopy;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final hasOutput = output.isNotEmpty;
    final textStyle = isMorse
        ? AppText.morse.copyWith(fontSize: 24, height: 1.5)
        : AppText.display.copyWith(fontSize: 26, letterSpacing: 1, height: 1.35);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: AppText.label.copyWith(color: AppColors.onPanelMuted)),
              ),
              const Text('Signal lamp', style: TextStyle(fontSize: 12, color: AppColors.onPanelMuted)),
              const SizedBox(width: 8),
              lamp,
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              child: Semantics(
                liveRegion: true,
                child: hasOutput && isMorse
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: MorseSignal(code: output, size: 14),
                      )
                    : SelectableText(
                        hasOutput ? output : 'Your translation appears here',
                        style: textStyle.copyWith(color: hasOutput ? AppColors.accent : AppColors.onPanelFaint),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: onPlay,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.ink,
                      disabledBackgroundColor: AppColors.panelRaised,
                      disabledForegroundColor: AppColors.onPanelFaint,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: AppText.button,
                    ),
                    icon: Icon(isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded),
                    label: Text(isPlaying ? 'Stop' : 'Play'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SquareIconButton(
                icon: Icons.copy_rounded,
                tooltip: 'Copy result',
                size: 52,
                radius: 16,
                background: AppColors.panelRaised,
                foreground: Colors.white,
                onPressed: onCopy,
              ),
              const SizedBox(width: 10),
              SquareIconButton(
                icon: Icons.bookmark_add_outlined,
                tooltip: 'Save to history',
                size: 52,
                radius: 16,
                background: AppColors.panelRaised,
                foreground: Colors.white,
                onPressed: onSave,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
