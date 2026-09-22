import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'time_capsule_channel',
          'Time Capsule',
          channelDescription: 'Notifications for Time Capsule events',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showCapsuleUnlocked({
    required String capsuleTitle,
    required int notifId,
  }) async {
    await showNotification(
      id: notifId,
      title: '🔓 Time Capsule Unlocked!',
      body: '"$capsuleTitle" is now open. Your memory has arrived from the past.',
    );
  }

  Future<void> showCapsuleReminder({
    required String capsuleTitle,
    required String countdown,
    required int notifId,
  }) async {
    await showNotification(
      id: notifId,
      title: '⏰ Capsule Opening Soon',
      body: '"$capsuleTitle" opens $countdown',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
