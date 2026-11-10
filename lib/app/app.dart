import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/onboarding/presentation/pages/splash_page.dart';
import 'home_shell.dart';
import 'routes.dart';

class MorseApp extends StatelessWidget {
  const MorseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.onboarding: (_) => const OnboardingPage(),
        AppRoutes.home: (_) => const HomeShell(),
      },
    );
  }
}
