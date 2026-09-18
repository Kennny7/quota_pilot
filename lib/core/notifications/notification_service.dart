// lib/core/notifications/notification_service.dart


import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Singleton wrapper around [FlutterLocalNotificationsPlugin].
///
/// Only handles the plumbing: init, permissions, and showing a notification.
/// The decision of *when* to notify lives in [QuotaAlertService].
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialised = false;
  bool get isInitialised => _initialised;

  static const String quotaChannelId = 'quota_alerts';
  static const String quotaChannelName = 'Quota alerts';
  static const String quotaChannelDescription =
      'Reminds you when a service quota drops below your threshold.';

  Future<void> init() async {
    if (_initialised) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      // Ask for permissions explicitly later, when the user toggles the setting on.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createAndroidChannel();
    _initialised = true;
  }

  Future<void> _createAndroidChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        quotaChannelId,
        quotaChannelName,
        description: quotaChannelDescription,
        importance: Importance.defaultImportance,
      ),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Optional: hook into a global navigator key to open AccountDetailScreen
    // using `response.payload` (we pass the account id as payload).
    debugPrint('Quota notification tapped: ${response.payload}');
  }

  // ---------------------------------------------------------------------------
  // Permissions
  // ---------------------------------------------------------------------------

  /// Requests OS-level notification permission.
  /// Call this when the user flips the Settings toggle ON.
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted =
          await ios?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    return true;
  }

  /// Best-effort check whether notifications can currently be shown.
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await android?.areNotificationsEnabled() ?? false;
      }
      // iOS / macOS: assume enabled — the OS silently drops otherwise and
      // re-checking is expensive. We only ask once when the toggle flips on.
      return true;
    } catch (e) {
      debugPrint('areNotificationsEnabled failed: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Showing / cancelling
  // ---------------------------------------------------------------------------

  Future<void> showQuotaAlert({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialised) await init();

    const androidDetails = AndroidNotificationDetails(
      quotaChannelId,
      quotaChannelName,
      channelDescription: quotaChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(''),
    );
    const darwinDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  Future<void> cancel(int id) async {
    if (!_initialised) return;
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!_initialised) return;
    await _plugin.cancelAll();
  }
}