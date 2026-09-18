// lib/domain/entities/user_settings.dart

class UserSettings {
  final bool darkMode;
  final bool autoRefresh;
  final int refreshIntervalMinutes;
  final String locale;

  const UserSettings({
    this.darkMode = false,
    this.autoRefresh = true,
    this.refreshIntervalMinutes = 30,
    this.locale = 'en',
  });

  UserSettings copyWith({
    bool? darkMode,
    bool? autoRefresh,
    int? refreshIntervalMinutes,
    String? locale,
  }) => UserSettings(
        darkMode: darkMode ?? this.darkMode,
        autoRefresh: autoRefresh ?? this.autoRefresh,
        refreshIntervalMinutes: refreshIntervalMinutes ?? this.refreshIntervalMinutes,
        locale: locale ?? this.locale,
      );
}