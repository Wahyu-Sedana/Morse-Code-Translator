import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color ground = Color(0xFFF4F5F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF14181A);
  static const Color inkSoft = Color(0xFF3F454A);
  static const Color muted = Color(0xFF5B6166);
  static const Color placeholder = Color(0xFF7A8086);
  static const Color border = Color(0xFFDDDFDA);
  static const Color dotInactive = Color(0xFFC4C8C2);
  static const Color panel = Color(0xFF1F2528);
  static const Color panelRaised = Color(0xFF262C30);
  static const Color panelBorder = Color(0xFF2E3539);
  static const Color lampOff = Color(0xFF3A4246);
  static const Color onPanelMuted = Color(0xFFB5BCC1);
  static const Color onPanelFaint = Color(0xFF8A9298);
  static const Color accent = Color(0xFFF2B347);
  static const Color focus = Color(0xFF2A6FDB);

  // Morse signal shapes: dots are blue, dashes are amber, so the two read
  // apart by color as well as by length. Each has a variant for dark panels
  // and one with enough contrast on light surfaces.
  static const Color signalDot = Color(0xFF5BB4FF);
  static const Color signalDash = accent;
  static const Color signalDotOnLight = Color(0xFF2A6FDB);
  static const Color signalDashOnLight = Color(0xFFC27D12);
}
