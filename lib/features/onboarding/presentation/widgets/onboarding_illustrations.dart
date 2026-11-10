import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/morse_signal.dart';

class IllustrationPanel extends StatelessWidget {
  const IllustrationPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(32)),
        child: Center(
          child: FittedBox(
            child: Padding(padding: const EdgeInsets.all(24), child: child),
          ),
        ),
      ),
    );
  }
}

class TextToSignalIllustration extends StatelessWidget {
  const TextToSignalIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return IllustrationPanel(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Text('SOS', style: AppText.display.copyWith(fontSize: 44, letterSpacing: 4)),
          ),
          const SizedBox(height: 22),
          const Icon(Icons.arrow_downward_rounded, color: AppColors.onPanelFaint, size: 32),
          const SizedBox(height: 22),
          const MorseSignal(code: '... --- ...', size: 14, alignment: WrapAlignment.center),
        ],
      ),
    );
  }
}

class TapIllustration extends StatelessWidget {
  const TapIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return IllustrationPanel(
      child: Column(
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.panelBorder),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 196,
              height: 196,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lampOff),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                  boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.33), blurRadius: 50)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Press', style: AppText.display.copyWith(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(
                      '\u00B7 \u2212',
                      style: AppText.morse.copyWith(fontSize: 16, letterSpacing: 3, color: AppColors.ink),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Short = dot', style: TextStyle(fontSize: 13, color: AppColors.onPanelMuted)),
              SizedBox(width: 18),
              Text('Hold = dash', style: TextStyle(fontSize: 13, color: AppColors.onPanelMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class OutputIllustration extends StatelessWidget {
  const OutputIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return IllustrationPanel(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.graphic_eq_rounded, color: AppColors.muted, size: 40),
              const SizedBox(width: 22),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                  boxShadow: [
                    BoxShadow(color: AppColors.accent.withValues(alpha: 0.19), spreadRadius: 16),
                    BoxShadow(color: AppColors.accent.withValues(alpha: 0.6), blurRadius: 80),
                  ],
                ),
              ),
              const SizedBox(width: 22),
              const Icon(Icons.graphic_eq_rounded, color: AppColors.muted, size: 40),
            ],
          ),
          const SizedBox(height: 36),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Chip(label: 'Sound'),
              SizedBox(width: 10),
              _Chip(label: 'Light'),
              SizedBox(width: 10),
              _Chip(label: 'Vibration'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: AppColors.panelRaised, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}
