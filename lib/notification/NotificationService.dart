import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'reminder_channel',
    'Reminder Notifications',
    description: 'This channel is used for reminder notifications.',
    importance: Importance.max,
  );

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> scheduleNotification(
      DateTime scheduledTime, String id, String title, String body) async {
    final tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> cancelNotification(String id) async {
    await _flutterLocalNotificationsPlugin.cancel(_generateUniqueId(id));
  }

  static int _generateUniqueId(String id) {
    return id.hashCode;
  }
}

Future<void> checkAndScheduleNotifications(DocumentSnapshot document) async {
  final reviewTime = (document['reviewTime'] as Timestamp).toDate();
  final now = DateTime.now();
  final remainingTime = reviewTime.difference(now);

  try {
    if (remainingTime.isNegative) {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(document.id)
          .update({
        'memorized': false,
      });
    } else {
      await NotificationService.scheduleNotification(
        reviewTime,
        document.id,
        '復習の時間です',
        '${document['name']}の復習を行ってください',
      );
    }
  } catch (e) {
    print('Error scheduling notification: $e');
  }
}
