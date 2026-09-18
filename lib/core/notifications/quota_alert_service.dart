// lib/core/notifications/quota_alert_service.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/account_repository.dart';
import '../../data/repositories/quota_repository.dart';
import '../../data/repositories/settings_repository.dart';
import 'notification_service.dart';

/// Checks every account's cached quota and fires a local notification for any
/// account that has dropped at or below the user's configured threshold.
///
/// Design notes:
///  * Reads the *cached* quota from the local DB — no network calls, so this
///    is safe to run on every app start / resume.
///  * Throttles per-account so we don't re-notify on every resume. The
///    throttle window is [_minIntervalBetweenAlerts].
class QuotaAlertService {
  QuotaAlertService({
    required AccountRepository accountRepository,
    required QuotaRepository quotaRepository,
    required SettingsRepository settingsRepository,
    NotificationService? notifications,
  })  : _accounts = accountRepository,
        _quotas = quotaRepository,
        _settings = settingsRepository,
        _notifications = notifications ?? NotificationService.instance;

  final AccountRepository _accounts;
  final QuotaRepository _quotas;
  final SettingsRepository _settings;
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
      final quota = await _quotas.getLatestQuota(account.id);
      final remaining = quota?.remainingPercent;
      if (remaining == null) continue;          // no data yet — skip
      if (remaining > threshold) continue;       // still healthy

      // 4. Throttle per-account.
      final key = '$_prefsPrefix${account.id}';
      final lastSent = prefs.getInt(key) ?? 0;
      if (now - lastSent < _minIntervalBetweenAlerts.inMilliseconds) continue;

      // 5. Fire it.
      await _notifications.showQuotaAlert(
        id: notificationIdFor(account.id),
        title: '${account.label} quota is low',
        body:
            '${remaining.round()}% remaining — below your ${threshold}% threshold.',
        payload: account.id,
      );

      await prefs.setInt(key, now);
    }
  }

  /// Clears the throttle for one account (e.g. after the user refreshes it)
  /// and dismisses any outstanding notification.
  Future<void> resetThrottle(String accountId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefsPrefix$accountId');
    await _notifications.cancel(notificationIdFor(accountId));
  }

  /// Stable notification id derived from the account id.
  static int notificationIdFor(String accountId) =>
      accountId.hashCode & 0x7fffffff;
}