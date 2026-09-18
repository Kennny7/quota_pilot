// lib/core/notifications/quota_alert_scheduler.dart

import 'package:flutter/widgets.dart';

import 'quota_alert_service.dart';

/// Runs [QuotaAlertService.checkAndNotify] on app start and every time the app
/// returns to the foreground. Deliberately cheap: the service reads cached
/// data only.
///
/// If you need checks while the app is *fully closed*, wrap
/// [QuotaAlertService.checkAndNotify] in a WorkManager periodic task — see
/// the README note at the bottom of this file.
class QuotaAlertScheduler with WidgetsBindingObserver {
  QuotaAlertScheduler(this._service);

  final QuotaAlertService _service;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;

    WidgetsBinding.instance.addObserver(this);
    // Defer to after the first frame so we never block app startup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service.checkAndNotify();
    });
  }

  void stop() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _service.checkAndNotify();
    }
  }
}