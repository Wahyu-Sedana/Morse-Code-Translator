import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../providers/onboarding_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.minimumDuration = const Duration(milliseconds: 2200)});

  final Duration minimumDuration;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const int _steps = 8;
  static const List<String> _shape = ['.', '-', '.'];

  Timer? _ticker;
  int _step = 0;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 320), (_) {
      if (mounted) setState(() => _step = (_step + 1) % _steps);
    });
    _start();
  }

  Future<void> _start() async {
    final results = await Future.wait([
      context.read<OnboardingProvider>().resolveLaunch(),
      Future<void>.delayed(widget.minimumDuration),
    ]);
    _go(results.first as LaunchDestination);
  }

  void _go(LaunchDestination destination) {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(
      context,
    ).pushReplacementNamed(destination == LaunchDestination.home ? AppRoutes.home : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowing = _step >= 4;
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: AppColors.panelBorder),
                        boxShadow: glowing
                            ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.25), blurRadius: 60)]
                            : const [],
                      ),
                      child: ExcludeSemantics(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < _shape.length; i++) ...[
                              if (i > 0) const SizedBox(width: 10),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 90),
                                width: _shape[i] == '.' ? 18 : 46,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: _step == i || glowing
                                      ? (_shape[i] == '.' ? AppColors.signalDot : AppColors.signalDash)
                                      : AppColors.lampOff,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Morse',
                      style: AppText.display.copyWith(fontSize: 44, letterSpacing: -1, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Translate signals, send messages',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.onPanelMuted),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      width: 120,
                      height: 4,
                      child: LinearProgressIndicator(
                        value: (_step + 1) / _steps,
                        backgroundColor: AppColors.panelBorder,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('v1.0', style: AppText.morse.copyWith(fontSize: 12, color: AppColors.onPanelFaint)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
