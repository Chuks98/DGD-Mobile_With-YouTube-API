import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'main.dart';
import './screens/display.dart';

class NotificationService {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Timer? timer;

  NotificationService() {
    _initialize();
  }

  void _initialize() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
    tz.initializeTimeZones();
  }

  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => Display(),
      ));
    }
  }

  void startRepeatingNotifications() {
    timer = Timer.periodic(
        Duration(minutes: 5), (Timer t) => _scheduleNotification());
  }

  void _scheduleNotification() async {
    await flutterLocalNotificationsPlugin.show(
      0,
      'Daily Grace Devotion',
      'Remember to read today\'s devotion!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_devotion_channel',
          'Daily Devotion Notifications',
          channelDescription:
              'Notification channel for daily devotion reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: 'daily_devotion',
    );
  }
}
