// lib/presentation/providers/settings_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/notifications/notification_service.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/i_settings_repository.dart';

export '../../core/constants/app_colors.dart';
export '../../domain/entities/user_settings.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  ),
);

final settingsRepositoryProvider = Provider<ISettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(sharedPreferencesProvider)),
);

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, UserSettings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    return ref.read(settingsRepositoryProvider).getSettings();
  }

  Future<void> _persist(UserSettings next) async {
    final previous = state.valueOrNull;
    state = AsyncValue.data(next); // optimistic
    try {
      await ref.read(settingsRepositoryProvider).updateSettings(next);
    } catch (_) {
      if (previous != null) state = AsyncValue.data(previous);
      rethrow;
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _persist(current.copyWith(themeMode: mode));
  }

  Future<void> setAccentPalette(AppAccentPalette palette) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _persist(current.copyWith(accentPalette: palette));
  }

  Future<void> setQuotaAlertsEnabled(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (enabled) {
      final granted =
          await NotificationService.instance.requestPermissions();
      if (!granted) return;
    }
    await _persist(current.copyWith(quotaAlertsEnabled: enabled));
  }

  Future<void> setQuotaAlertThreshold(int percent) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _persist(
      current.copyWith(quotaAlertThreshold: percent.clamp(1, 100)),
    );
  }

  Future<void> setIsSupporter(bool isSupporter) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _persist(current.copyWith(isSupporter: isSupporter));
  }

  /// Re-reads settings from the repository.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).getSettings(),
    );
  }
}

final themeModeProvider = Provider<ThemeMode>((ref) {
  final mode =
      ref.watch(settingsProvider).valueOrNull?.themeMode ?? AppThemeMode.system;
  return switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.oled => ThemeMode.dark,
  };
});