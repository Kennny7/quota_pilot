// lib/presentation/providers/notification_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/notification_service.dart';
import '../../core/notifications/quota_alert_scheduler.dart';
import '../../core/notifications/quota_alert_service.dart';
import 'account_providers.dart';
import 'quota_providers.dart';
import 'settings_providers.dart';

export '../../core/notifications/notification_service.dart';
export '../../core/notifications/quota_alert_scheduler.dart';
export '../../core/notifications/quota_alert_service.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

final quotaAlertServiceProvider = Provider<QuotaAlertService>((ref) {
  return QuotaAlertService(
    accountRepository: ref.watch(accountRepositoryProvider),
    quotaRepository: ref.watch(quotaRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    notifications: ref.watch(notificationServiceProvider),
  );
});

/// Watch this once (e.g. in the root widget) to start the start/resume checks.
final quotaAlertSchedulerProvider = Provider<QuotaAlertScheduler>((ref) {
  final scheduler = QuotaAlertScheduler(ref.watch(quotaAlertServiceProvider));
  scheduler.start();
  ref.onDispose(scheduler.stop);
  return scheduler;
});
