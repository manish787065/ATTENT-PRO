import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  static const LinearGradient primaryButton = LinearGradient(
    colors: AppColors.primaryGradient,
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient background = LinearGradient(
    colors: [Color(0xFF0A0E27), Color(0xFF141836), Color(0xFF0D1117)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glass = LinearGradient(
    colors: [AppColors.glassWhite, AppColors.glassDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successCard = LinearGradient(
    colors: AppColors.successGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerCard = LinearGradient(
    colors: AppColors.dangerGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const SweepGradient attendanceRing = SweepGradient(
    colors: [AppColors.secondary, AppColors.primary, AppColors.cyan],
    startAngle: 0,
    endAngle: 6.28,
  );
}
