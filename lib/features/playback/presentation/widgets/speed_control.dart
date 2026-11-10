import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/square_icon_button.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/output_options.dart';
import '../providers/playback_provider.dart';

class SpeedControl extends StatelessWidget {
  const SpeedControl({super.key});

  @override
  Widget build(BuildContext context) {
    final wpm = context.select<PlaybackProvider, int>((p) => p.options.wpm);
    final playback = context.read<PlaybackProvider>();
    return SurfaceCard(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Speed',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
          ),
          SquareIconButton(
            icon: Icons.remove_rounded,
            tooltip: 'Slower',
            background: AppColors.ground,
            radius: 12,
            onPressed: wpm > OutputOptions.minWpm ? () => playback.setWpm(wpm - 1) : null,
          ),
          SizedBox(
            width: 84,
            child: Text(
              '$wpm WPM',
              textAlign: TextAlign.center,
              style: AppText.morse.copyWith(fontSize: 15, letterSpacing: 0, color: AppColors.ink),
            ),
          ),
          SquareIconButton(
            icon: Icons.add_rounded,
            tooltip: 'Faster',
            background: AppColors.ground,
            radius: 12,
            onPressed: wpm < OutputOptions.maxWpm ? () => playback.setWpm(wpm + 1) : null,
          ),
        ],
      ),
    );
  }
}
