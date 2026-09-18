// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF2563EB); // Modern Royal Blue
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary Accents
  static const Color emerald = Color(0xFF10B981); // Vibrant Safe Green
  static const Color amber = Color(0xFFF59E0B); // Caution / Warning
  static const Color rose = Color(0xFFEF4444); // Low Quota / Critical
  static const Color purple = Color(0xFF8B5CF6); // Antigravity / Special Tier
  static const Color cyan = Color(0xFF06B6D4);

  // Light Mode Neutrals
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Mode Neutrals (Deep Nebula)
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF151C2C);
  static const Color darkSurfaceVariant = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // OLED Black Neutrals (Pure Black AMOLED)
  static const Color oledBackground = Color(0xFF000000);
  static const Color oledSurface = Color(0xFF0A0A0A);
  static const Color oledSurfaceVariant = Color(0xFF141414);
  static const Color oledBorder = Color(0xFF262626);

  // Status & Health
  static const Color quotaGood = Color(0xFF10B981); // >= 40%
  static const Color quotaWarning = Color(0xFFF59E0B); // 20% - 39%
  static const Color quotaCritical = Color(0xFFEF4444); // < 20%

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardDarkGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color divider = Color(0x1F94A3B8);
}

enum AppAccentPalette {
  indigo,
  emerald,
  sunset,
  violet;

  String get label => switch (this) {
        AppAccentPalette.indigo => 'Cyber Indigo',
        AppAccentPalette.emerald => 'Neon Emerald',
        AppAccentPalette.sunset => 'Sunset Amber',
        AppAccentPalette.violet => 'Cosmic Violet',
      };

  Color get primaryColor => switch (this) {
        AppAccentPalette.indigo => const Color(0xFF2563EB),
        AppAccentPalette.emerald => const Color(0xFF10B981),
        AppAccentPalette.sunset => const Color(0xFFF59E0B),
        AppAccentPalette.violet => const Color(0xFF8B5CF6),
      };

  Color get secondaryColor => switch (this) {
        AppAccentPalette.indigo => const Color(0xFF06B6D4),
        AppAccentPalette.emerald => const Color(0xFF34D399),
        AppAccentPalette.sunset => const Color(0xFFFB923C),
        AppAccentPalette.violet => const Color(0xFFA78BFA),
      };
}
