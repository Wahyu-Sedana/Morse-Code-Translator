import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppFonts {
  static const String body = 'Inter';
  static const String display = 'SpaceGrotesk';
  static const String mono = 'JetBrainsMono';
}

abstract final class AppText {
  static const TextStyle screenTitle = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.ink,
  );

  static const TextStyle eyebrow = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 3,
    color: AppColors.muted,
  );

  static const TextStyle label = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    height: 1.55,
    color: AppColors.inkSoft,
  );

  static const TextStyle button = TextStyle(fontFamily: AppFonts.body, fontSize: 16, fontWeight: FontWeight.w700);

  static const TextStyle morse = TextStyle(fontFamily: AppFonts.mono, fontWeight: FontWeight.w700, letterSpacing: 2);

  static const TextStyle display = TextStyle(
    fontFamily: AppFonts.display,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
}
