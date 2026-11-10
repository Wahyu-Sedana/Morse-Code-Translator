import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/morse_signal.dart';
import '../../../../core/widgets/square_icon_button.dart';
import '../../domain/entities/history_entry.dart';
import '../utils/history_time_format.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({
    super.key,
    required this.entry,
    required this.isPlaying,
    required this.onPlay,
    required this.onToggleFavorite,
  });

  final HistoryEntry entry;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.text.isEmpty ? '(no text)' : entry.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.display.copyWith(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.ground, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        entry.source.label,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 14,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: MorseSignal(code: entry.morse, size: 8, onDark: false, singleLine: true),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatHistoryTime(entry.createdAt, DateTime.now()),
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SquareIconButton(
            icon: entry.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            tooltip: entry.isFavorite ? 'Remove from favorites' : 'Add to favorites',
            background: AppColors.ground,
            foreground: entry.isFavorite ? const Color(0xFFB7791F) : AppColors.muted,
            onPressed: onToggleFavorite,
          ),
          const SizedBox(width: 8),
          SquareIconButton(
            icon: isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
            tooltip: isPlaying ? 'Stop' : 'Play ${entry.text}',
            background: AppColors.ink,
            foreground: AppColors.accent,
            onPressed: onPlay,
          ),
        ],
      ),
    );
  }
}
