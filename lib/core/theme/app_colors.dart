import 'package:flutter/material.dart';

/// Design tokens for the dark premium theme.
abstract final class AppColors {
  static const background = Color(0xFF0B0B12);
  static const surface = Color(0xFF14141F);
  static const surfaceHigh = Color(0xFF1D1D2E);
  static const outline = Color(0xFF2A2A3D);

  static const primary = Color(0xFF8B5CF6); // electric purple
  static const secondary = Color(0xFF3B82F6); // electric blue

  static const textPrimary = Color(0xFFF2F2F8);
  static const textSecondary = Color(0xFF9A9AB0);

  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);

  static const accentGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Spacing and radius scale.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const double radiusCard = 16;
  static const double radiusChip = 12;
}
