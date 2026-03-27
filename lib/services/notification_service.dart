import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/event_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
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
  }

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  Future<void> scheduleEventNotification(EventModel event) async {
    if (!event.notificationEnabled) return;

    // Cancel existing notifications first
    await cancelEventNotification(event.id);

    final baseId = event.id.hashCode;

    // Event day notification (always active - reminderEventDay is always true)
    final eventDayDate = tz.TZDateTime(
      tz.local,
      event.targetDate.year,
      event.targetDate.month,
      event.targetDate.day,
      9,
      0,
    );
    if (eventDayDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await _scheduleNotification(
        id: baseId,
        title: 'Bugün Günü Geldi! 🎉',
        body: '"${event.title}" bugün!',
        scheduledDate: eventDayDate,
      );
    }

    // 1 day before
    if (event.reminder1Day) {
      await _scheduleReminderBefore(
        baseId: baseId + 1,
        event: event,
        daysBefore: 1,
        message: '"${event.title}" etkinliğine 1 gün kaldı!',
      );
    }

    // 3 days before
    if (event.reminder3Days) {
      await _scheduleReminderBefore(
        baseId: baseId + 2,
        event: event,
        daysBefore: 3,
        message: '"${event.title}" etkinliğine 3 gün kaldı!',
      );
    }

    // 1 week before
    if (event.reminder1Week) {
      await _scheduleReminderBefore(
        baseId: baseId + 3,
        event: event,
        daysBefore: 7,
        message: '"${event.title}" etkinliğine 1 hafta kaldı!',
      );
    }

    // 1 month before
    if (event.reminder1Month) {
      await _scheduleReminderBefore(
        baseId: baseId + 4,
        event: event,
        daysBefore: 30,
        message: '"${event.title}" etkinliğine 1 ay kaldı!',
      );
    }
  }

  Future<void> _scheduleReminderBefore({
    required int baseId,
    required EventModel event,
    required int daysBefore,
    required String message,
  }) async {
    final scheduledDate = tz.TZDateTime(
      tz.local,
      event.targetDate.year,
      event.targetDate.month,
      event.targetDate.day - daysBefore,
      9,
      0,
    );
    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      await _scheduleNotification(
        id: baseId,
        title: 'Gün Sayacı ⏰',
        body: message,
        scheduledDate: scheduledDate,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'countdown_channel',
          'Geri Sayım Bildirimleri',
          channelDescription: 'Etkinlik geri sayım bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelEventNotification(String eventId) async {
    final baseId = eventId.hashCode;
    for (int i = 0; i < 5; i++) {
      await _plugin.cancel(baseId + i);
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
