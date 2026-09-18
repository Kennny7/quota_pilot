// lib/domain/entities/user_settings.dart

class UserSettings {
  const UserSettings({
    this.darkMode = false,
    this.autoRefresh = true,
    this.refreshIntervalMinutes = 30,
    this.locale = 'en',
    this.quotaAlertsEnabled = true,
    this.quotaAlertThreshold = 20, // percent, 1..100
  });

  final bool darkMode;
  final bool autoRefresh;
  final int refreshIntervalMinutes;
  final String locale;

  /// Whether local notifications are enabled for low quota.
  final bool quotaAlertsEnabled;

  /// Percentage (1–100) below which we notify.
  final int quotaAlertThreshold;

  UserSettings copyWith({
    bool? darkMode,
    bool? autoRefresh,
    int? refreshIntervalMinutes,
    String? locale,
    bool? quotaAlertsEnabled,
    int? quotaAlertThreshold,
  }) {
    return UserSettings(
      darkMode: darkMode ?? this.darkMode,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshIntervalMinutes:
          refreshIntervalMinutes ?? this.refreshIntervalMinutes,
      locale: locale ?? this.locale,
      quotaAlertsEnabled: quotaAlertsEnabled ?? this.quotaAlertsEnabled,
      quotaAlertThreshold: quotaAlertThreshold ?? this.quotaAlertThreshold,
    );
  }

  Map<String, dynamic> toJson() => {
        'darkMode': darkMode,
        'autoRefresh': autoRefresh,
        'refreshIntervalMinutes': refreshIntervalMinutes,
        'locale': locale,
        'quotaAlertsEnabled': quotaAlertsEnabled,
        'quotaAlertThreshold': quotaAlertThreshold,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        darkMode: json['darkMode'] as bool? ?? false,
        autoRefresh: json['autoRefresh'] as bool? ?? true,
        refreshIntervalMinutes:
            json['refreshIntervalMinutes'] as int? ?? 30,
        locale: json['locale'] as String? ?? 'en',
        quotaAlertsEnabled: json['quotaAlertsEnabled'] as bool? ?? true,
        quotaAlertThreshold: json['quotaAlertThreshold'] as int? ?? 20,
      );
}