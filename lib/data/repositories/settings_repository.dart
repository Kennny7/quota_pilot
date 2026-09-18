// lib/data/repositories/settings_repository.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/i_settings_repository.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  static const _kDark = 'settings.dark_mode';
  static const _kAuto = 'settings.auto_refresh';
  static const _kInterval = 'settings.refresh_interval';
  static const _kLocale = 'settings.locale';
  static const _kQuotaAlertsEnabled = 'settings.quota_alerts_enabled';
  static const _kQuotaAlertThreshold = 'settings.quota_alert_threshold';

  final SharedPreferences _prefs;
  SettingsRepositoryImpl(this._prefs);

  @override
  Future<UserSettings> getSettings() async => UserSettings(
        darkMode: _prefs.getBool(_kDark) ?? false,
        autoRefresh: _prefs.getBool(_kAuto) ?? true,
        refreshIntervalMinutes: _prefs.getInt(_kInterval) ?? 30,
        locale: _prefs.getString(_kLocale) ?? 'en',
        quotaAlertsEnabled: _prefs.getBool(_kQuotaAlertsEnabled) ?? true,
        quotaAlertThreshold: _prefs.getInt(_kQuotaAlertThreshold) ?? 20,
      );

  @override
  Future<void> updateSettings(UserSettings s) async {
    await _prefs.setBool(_kDark, s.darkMode);
    await _prefs.setBool(_kAuto, s.autoRefresh);
    await _prefs.setInt(_kInterval, s.refreshIntervalMinutes);
    await _prefs.setString(_kLocale, s.locale);
    await _prefs.setBool(_kQuotaAlertsEnabled, s.quotaAlertsEnabled);
    await _prefs.setInt(
      _kQuotaAlertThreshold,
      s.quotaAlertThreshold.clamp(1, 100),
    );
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