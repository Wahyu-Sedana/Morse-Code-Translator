import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';

class TapPad extends StatelessWidget {
  const TapPad({super.key, required this.isPressed, required this.onDown, required this.onUp, this.size = 220});

  final bool isPressed;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tap key. Press briefly for a dot, hold for a dash',
      child: Listener(
        onPointerDown: (_) {
          HapticFeedback.selectionClick();
          onDown();
        },
        onPointerUp: (_) => onUp(),
        onPointerCancel: (_) => onUp(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPressed ? AppColors.accent : AppColors.ink,
            border: Border.all(color: isPressed ? AppColors.ink : AppColors.border, width: 10),
            boxShadow: isPressed
                ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.45), blurRadius: 40)]
                : const [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPressed ? 'Signal...' : 'Press',
                    style: AppText.display.copyWith(fontSize: 22, color: isPressed ? AppColors.ink : Colors.white),
                  ),
                  if (size >= 160) ...[
                    const SizedBox(height: 6),
                    Text(
                      'hold for a dash',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: (isPressed ? AppColors.ink : Colors.white).withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
