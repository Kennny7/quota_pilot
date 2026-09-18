// lib/domain/repositories/i_settings_repository.dart

import '../entities/user_settings.dart';

abstract class ISettingsRepository {
  Future<UserSettings> getSettings();
  Future<void> updateSettings(UserSettings settings);
  Future<void> setQuotaAlertsEnabled(bool enabled);
  Future<void> setQuotaAlertThreshold(int percent);
}