import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.ink,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppFonts.body,
      scaffoldBackgroundColor: AppColors.ground,
      splashFactory: InkSparkle.splashFactory,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(fontFamily: AppFonts.body, color: Colors.white, fontSize: 14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.ink : AppColors.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.accent : AppColors.border,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.ink,
        selectionColor: Color(0x55F2B347),
        selectionHandleColor: AppColors.ink,
      ),
    );
  }
}
