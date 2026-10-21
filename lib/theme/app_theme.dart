import 'package:flutter/material.dart';

class AppColors {
  // Deep space dark backgrounds
  static const Color background = Color(0xFF0A0E17);
  static const Color surface = Color(0xFF131B2E);
  static const Color surfaceCard = Color(0xFF1B243B);

  // Futuristic vibrant accents
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color glowBlue = Color(0xFF3B82F6);
  static const Color activeGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryCyan, accentViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient listeningGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient thinkingGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient speakingGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF00E5FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryCyan,
      fontFamily: 'sans-serif',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryCyan,
        secondary: AppColors.accentViolet,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
