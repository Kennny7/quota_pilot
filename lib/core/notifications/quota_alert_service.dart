// lib/core/notifications/quota_alert_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/i_account_repository.dart';
import '../../domain/repositories/i_quota_repository.dart';
import '../../domain/repositories/i_settings_repository.dart';
import 'notification_service.dart';

/// Checks every account's cached quota and fires a local notification for any
/// account that has dropped at or below the user's configured threshold.
class QuotaAlertService {
  QuotaAlertService({
    required IAccountRepository accountRepository,
    required IQuotaRepository quotaRepository,
    required ISettingsRepository settingsRepository,
    NotificationService? notifications,
  })  : _accounts = accountRepository,
        _quotas = quotaRepository,
        _settings = settingsRepository,
        _notifications = notifications ?? NotificationService.instance;

  final IAccountRepository _accounts;
  final IQuotaRepository _quotas;
  final ISettingsRepository _settings;
  final NotificationService _notifications;

  static const String _prefsPrefix = 'quota_alert_last_sent_';
  static const Duration _minIntervalBetweenAlerts = Duration(hours: 12);

  bool _isRunning = false;

  /// Entry point. Safe to call repeatedly (concurrent calls are ignored).
  Future<void> checkAndNotify() async {
    if (_isRunning) return;
    _isRunning = true;
    try {
      await _run();
    } catch (e, st) {
      debugPrint('QuotaAlertService failed: $e\n$st');
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _run() async {
    // 1. Is the feature even on?
    final settings = await _settings.getSettings();
    if (!settings.quotaAlertsEnabled) return;

    // 2. Can we actually post notifications?
    if (!await _notifications.areNotificationsEnabled()) return;

    final threshold = settings.quotaAlertThreshold;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    // 3. Iterate accounts and check their latest cached quota.
    final accounts = await _accounts.getAllAccounts();

    for (final account in accounts) {
      final accountId = account.id;
      if (accountId == null) continue;

      final quota = await _quotas.getLatestQuota(accountId);
      final remaining = quota?.remainingPercent;
      if (remaining == null) continue; // no data yet
      if (remaining > threshold) continue; // still healthy

      // 4. Throttle per-account.
      final key = '$_prefsPrefix$accountId';
      final lastSent = prefs.getInt(key) ?? 0;
      if (now - lastSent < _minIntervalBetweenAlerts.inMilliseconds) continue;

      // 5. Fire alert.
      await _notifications.showQuotaAlert(
        id: notificationIdFor(accountId),
        title: '${account.email} quota is low',
        body:
            '${remaining.round()}% remaining ($threshold% threshold). Tap to inspect or update.',
        payload: accountId.toString(),
      );

      await prefs.setInt(key, now);
    }
  }

  /// Sends a sample notification to verify permissions and notifications.
  Future<void> sendTestAlert() async {
    final settings = await _settings.getSettings();
    await _notifications.showQuotaAlert(
      id: 99999,
      title: 'QuotaPilot Alert Test',
      body:
          'Quota alerts are active! Threshold is set to ${settings.quotaAlertThreshold}%.',
    );
  }

  /// Clears the throttle for one account (e.g. after the user refreshes it).
  Future<void> resetThrottle(int accountId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefsPrefix$accountId');
    await _notifications.cancel(notificationIdFor(accountId));
  }

  /// Stable notification id derived from the account id.
  static int notificationIdFor(int accountId) => accountId & 0x7fffffff;
}