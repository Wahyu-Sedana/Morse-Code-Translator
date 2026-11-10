import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_illustrations.dart';

class _Slide {
  const _Slide({required this.title, required this.body, required this.illustration});

  final String title;
  final String body;
  final Widget illustration;
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const List<_Slide> _slides = [
    _Slide(
      title: 'Text to signal in an instant',
      body: 'Type any message and see its Morse code right away. It works the other way too, from Morse code to text.',
      illustration: TextToSignalIllustration(),
    ),
    _Slide(
      title: 'Tap the signal yourself',
      body: 'Feel how a telegraph works. Press briefly for a dot, hold for a dash, and the app reads it as letters.',
      illustration: TapIllustration(),
    ),
    _Slide(
      title: 'Hear it, see it, feel it',
      body: 'Play your message as sound, a flashing light, or vibration. Everything works offline, no internet needed.',
      illustration: OutputIllustration(),
    ),
  ];

  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<OnboardingProvider>().complete();
    if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _next(OnboardingProvider onboarding) {
    if (onboarding.isLastPage) {
      _finish();
      return;
    }
    _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();
    final isLast = onboarding.isLastPage;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 44,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    opacity: isLast ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: isLast ? null : _finish,
                      style: TextButton.styleFrom(foregroundColor: AppColors.muted, minimumSize: const Size(64, 44)),
                      child: const Text('Skip', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: onboarding.setPage,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 11, child: slide.illustration),
                        const SizedBox(height: 28),
                        Expanded(
                          flex: 7,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Dots(count: _slides.length, active: index),
                                const SizedBox(height: 12),
                                Semantics(
                                  header: true,
                                  child: Text(
                                    slide.title,
                                    style: AppText.display.copyWith(fontSize: 30, letterSpacing: -0.5, height: 1.15),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(slide.body, style: AppText.body),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: () => _next(onboarding),
                  style: FilledButton.styleFrom(
                    backgroundColor: isLast ? AppColors.accent : AppColors.ink,
                    foregroundColor: isLast ? AppColors.ink : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    textStyle: AppText.button,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isLast ? 'Get started' : 'Next'),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
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

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step ${active + 1} of $count',
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Container(
              width: i == active ? 28 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == active ? AppColors.ink : AppColors.dotInactive,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
