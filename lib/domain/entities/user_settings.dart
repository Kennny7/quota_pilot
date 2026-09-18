// lib/domain/entities/user_settings.dart

import '../../core/constants/app_colors.dart';

enum AppThemeMode {
  system,
  light,
  dark,
  oled;

  String get label => switch (this) {
        AppThemeMode.system => 'System Default',
        AppThemeMode.light => 'Light Modern',
        AppThemeMode.dark => 'Dark Nebula',
        AppThemeMode.oled => 'OLED Black (AMOLED)',
      };
}

class UserSettings {
  final AppThemeMode themeMode;
  final AppAccentPalette accentPalette;
  final bool quotaAlertsEnabled;
  final int quotaAlertThreshold; // percent, 1..100
  final bool autoRefresh;
  final int refreshIntervalMinutes;
  final String locale;
  final bool isSupporter;

  const UserSettings({
    this.themeMode = AppThemeMode.system,
    this.accentPalette = AppAccentPalette.indigo,
    this.quotaAlertsEnabled = true,
    this.quotaAlertThreshold = 20,
    this.autoRefresh = true,
    this.refreshIntervalMinutes = 30,
    this.locale = 'en',
    this.isSupporter = false,
  });

  bool get darkMode =>
      themeMode == AppThemeMode.dark || themeMode == AppThemeMode.oled;

  UserSettings copyWith({
    AppThemeMode? themeMode,
    AppAccentPalette? accentPalette,
    bool? quotaAlertsEnabled,
    int? quotaAlertThreshold,
    bool? autoRefresh,
    int? refreshIntervalMinutes,
    String? locale,
    bool? isSupporter,
    bool? darkMode,
  }) =>
      UserSettings(
        themeMode: themeMode ??
            (darkMode != null
                ? (darkMode ? AppThemeMode.dark : AppThemeMode.light)
                : this.themeMode),
        accentPalette: accentPalette ?? this.accentPalette,
        quotaAlertsEnabled: quotaAlertsEnabled ?? this.quotaAlertsEnabled,
        quotaAlertThreshold: quotaAlertThreshold ?? this.quotaAlertThreshold,
        autoRefresh: autoRefresh ?? this.autoRefresh,
        refreshIntervalMinutes:
            refreshIntervalMinutes ?? this.refreshIntervalMinutes,
        locale: locale ?? this.locale,
        isSupporter: isSupporter ?? this.isSupporter,
      );
}