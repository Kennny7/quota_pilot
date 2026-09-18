// lib/data/repositories/settings_repository.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/i_settings_repository.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  static const _kThemeMode = 'settings.theme_mode';
  static const _kAccentPalette = 'settings.accent_palette';
  static const _kDark = 'settings.dark_mode';
  static const _kAuto = 'settings.auto_refresh';
  static const _kInterval = 'settings.refresh_interval';
  static const _kLocale = 'settings.locale';
  static const _kQuotaAlertsEnabled = 'settings.quota_alerts_enabled';
  static const _kQuotaAlertThreshold = 'settings.quota_alert_threshold';
  static const _kIsSupporter = 'settings.is_supporter';

  final SharedPreferences _prefs;
  SettingsRepositoryImpl(this._prefs);

  @override
  Future<UserSettings> getSettings() async {
    final themeStr = _prefs.getString(_kThemeMode);
    final themeMode = AppThemeMode.values.firstWhere(
      (m) => m.name == themeStr,
      orElse: () {
        final legacyDark = _prefs.getBool(_kDark);
        if (legacyDark == true) return AppThemeMode.dark;
        return AppThemeMode.system;
      },
    );

    final accentStr = _prefs.getString(_kAccentPalette);
    final accent = AppAccentPalette.values.firstWhere(
      (a) => a.name == accentStr,
      orElse: () => AppAccentPalette.indigo,
    );

    return UserSettings(
      themeMode: themeMode,
      accentPalette: accent,
      autoRefresh: _prefs.getBool(_kAuto) ?? true,
      refreshIntervalMinutes: _prefs.getInt(_kInterval) ?? 30,
      locale: _prefs.getString(_kLocale) ?? 'en',
      quotaAlertsEnabled: _prefs.getBool(_kQuotaAlertsEnabled) ?? true,
      quotaAlertThreshold: _prefs.getInt(_kQuotaAlertThreshold) ?? 20,
      isSupporter: _prefs.getBool(_kIsSupporter) ?? false,
    );
  }

  @override
  Future<void> updateSettings(UserSettings s) async {
    await _prefs.setString(_kThemeMode, s.themeMode.name);
    await _prefs.setString(_kAccentPalette, s.accentPalette.name);
    await _prefs.setBool(_kDark, s.darkMode);
    await _prefs.setBool(_kAuto, s.autoRefresh);
    await _prefs.setInt(_kInterval, s.refreshIntervalMinutes);
    await _prefs.setString(_kLocale, s.locale);
    await _prefs.setBool(_kQuotaAlertsEnabled, s.quotaAlertsEnabled);
    await _prefs.setInt(
      _kQuotaAlertThreshold,
      s.quotaAlertThreshold.clamp(1, 100),
    );
    await _prefs.setBool(_kIsSupporter, s.isSupporter);
  }

  @override
  Future<void> setQuotaAlertsEnabled(bool enabled) async {
    await _prefs.setBool(_kQuotaAlertsEnabled, enabled);
  }

  @override
  Future<void> setQuotaAlertThreshold(int percent) async {
    final clamped = percent.clamp(1, 100);
    await _prefs.setInt(_kQuotaAlertThreshold, clamped);
  }
}