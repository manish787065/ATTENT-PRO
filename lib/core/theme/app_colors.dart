import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0A0E27);
  static const Color surface = Color(0xFF141836);
  static const Color surfaceLight = Color(0xFF1E2449);
  static const Color cardBg = Color(0xFF161B3A);

  // Primary Palette
  static const Color primary = Color(0xFF4361EE);
  static const Color secondary = Color(0xFF7209B7);
  static const Color cyan = Color(0xFF00F5FF);

  // Status Colors
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFB703);
  static const Color danger = Color(0xFFEF233C);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8892B0);
  static const Color textHint = Color(0xFF4A5568);

  // Glass
  static const Color glassWhite = Color(0x22FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x05FFFFFF);

  // Gradients helpers
  static const List<Color> primaryGradient = [primary, secondary];
  static const List<Color> cyanGradient = [primary, cyan];
  static const List<Color> dangerGradient = [Color(0xFFEF233C), Color(0xFFB5179E)];
  static const List<Color> successGradient = [Color(0xFF06D6A0), Color(0xFF4361EE)];
}
