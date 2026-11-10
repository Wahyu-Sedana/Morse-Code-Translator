import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SignalLamp extends StatelessWidget {
  const SignalLamp({super.key, required this.isOn, this.size = 14, this.offColor = const Color(0xFF2E3539)});

  final bool isOn;
  final double size;
  final Color offColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 40),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOn ? AppColors.accent : offColor,
        boxShadow: isOn
            ? [
                BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), spreadRadius: size * 0.35),
                BoxShadow(color: AppColors.accent.withValues(alpha: 0.6), blurRadius: size * 1.6),
              ]
            : const [],
      ),
    );
  }
}
