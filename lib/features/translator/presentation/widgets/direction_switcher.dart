import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/square_icon_button.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../domain/entities/translation_direction.dart';

class DirectionSwitcher extends StatelessWidget {
  const DirectionSwitcher({super.key, required this.direction, required this.onSwap});

  final TranslationDirection direction;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final from = direction.isTextToMorse ? 'Text' : 'Morse';
    final to = direction.isTextToMorse ? 'Morse' : 'Text';
    return SurfaceCard(
      radius: 18,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(child: _Pill(label: from)),
          const SizedBox(width: 8),
          SquareIconButton(
            icon: Icons.swap_horiz_rounded,
            tooltip: 'Swap translation direction',
            background: AppColors.ink,
            foreground: Colors.white,
            onPressed: onSwap,
          ),
          const SizedBox(width: 8),
          Expanded(child: _Pill(label: to)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.ground, borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
      ),
    );
  }
}
