import 'package:flutter/material.dart';

class AppColors {
  // Deep luxury obsidian & onyx black backgrounds
  static const Color background = Color(0xFF090A0C);
  static const Color surface = Color(0xFF121417);
  static const Color surfaceCard = Color(0xFF1A1D22);
  static const Color surfaceCardLight = Color(0xFF24282F);

  // Luxury Light Brown / Warm Champagne / Caramel Bronze
  static const Color primaryCyan = Color(0xFFD4B996); // Warm champagne light brown (primary)
  static const Color warmBrown = Color(0xFFC5A880);
  static const Color lightBrown = Color(0xFFE5D5C3);
  static const Color deepBronze = Color(0xFFA8845B);
  static const Color glowBrown = Color(0xFFF0E2D0);

  // Pure & Pearl White highlights
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pearlWhite = Color(0xFFF5F5F7);
  static const Color offWhite = Color(0xFFE5E7EB);

  // Functional status colors (harmonized with warm luxury tone)
  static const Color accentViolet = Color(0xFFC5A880); // maps to warm brown
  static const Color glowBlue = Color(0xFFE5D5C3);
  static const Color activeGreen = Color(0xFFE2C9A5); // warm champagne for active
  static const Color warningOrange = Color(0xFFE5A96A);
  static const Color errorRed = Color(0xFFE56A6A);

  // High contrast text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFC0C4CC);
  static const Color textMuted = Color(0xFF7E8490);

  // Luxury gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lightBrown, deepBronze],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient listeningGradient = LinearGradient(
    colors: [pureWhite, warmBrown],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient thinkingGradient = LinearGradient(
    colors: [warmBrown, deepBronze],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient speakingGradient = LinearGradient(
    colors: [lightBrown, pureWhite],
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
        secondary: AppColors.lightBrown,
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

