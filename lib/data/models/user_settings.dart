// lib/data/models/user_settings.dart

import '../../core/constants/app_colors.dart';
import '../../domain/entities/user_settings.dart';

class UserSettingsModel extends UserSettings {
  const UserSettingsModel({
    super.themeMode = AppThemeMode.system,
    super.accentPalette = AppAccentPalette.indigo,
    super.quotaAlertsEnabled = true,
    super.quotaAlertThreshold = 20,
    super.autoRefresh = true,
    super.refreshIntervalMinutes = 30,
    super.locale = 'en',
    super.isSupporter = false,
  });

  factory UserSettingsModel.fromEntity(UserSettings s) {
    if (s is UserSettingsModel) return s;
    return UserSettingsModel(
      themeMode: s.themeMode,
      accentPalette: s.accentPalette,
      quotaAlertsEnabled: s.quotaAlertsEnabled,
      quotaAlertThreshold: s.quotaAlertThreshold,
      autoRefresh: s.autoRefresh,
      refreshIntervalMinutes: s.refreshIntervalMinutes,
      locale: s.locale,
      isSupporter: s.isSupporter,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'accentPalette': accentPalette.name,
        'darkMode': darkMode,
        'autoRefresh': autoRefresh,
        'refreshIntervalMinutes': refreshIntervalMinutes,
        'locale': locale,
        'quotaAlertsEnabled': quotaAlertsEnabled,
        'quotaAlertThreshold': quotaAlertThreshold,
        'isSupporter': isSupporter,
      };

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    AppThemeMode parseTheme(dynamic val) {
      if (val is String) {
        return AppThemeMode.values.firstWhere(
          (m) => m.name == val,
          orElse: () => AppThemeMode.system,
        );
      }
      if (json['darkMode'] == true) return AppThemeMode.dark;
      return AppThemeMode.system;
    }

    AppAccentPalette parseAccent(dynamic val) {
      if (val is String) {
        return AppAccentPalette.values.firstWhere(
          (a) => a.name == val,
          orElse: () => AppAccentPalette.indigo,
        );
      }
      return AppAccentPalette.indigo;
    }

    return UserSettingsModel(
      themeMode: parseTheme(json['themeMode']),
      accentPalette: parseAccent(json['accentPalette']),
      quotaAlertsEnabled: json['quotaAlertsEnabled'] as bool? ?? true,
      quotaAlertThreshold: json['quotaAlertThreshold'] as int? ?? 20,
      autoRefresh: json['autoRefresh'] as bool? ?? true,
      refreshIntervalMinutes: json['refreshIntervalMinutes'] as int? ?? 30,
      locale: json['locale'] as String? ?? 'en',
      isSupporter: json['isSupporter'] as bool? ?? false,
    );
  }
}