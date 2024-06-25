import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'main.dart';

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
        builder: (context) => MyApp(),
      ));
    }
  }

  void startRepeatingNotifications() {
    _scheduleNextNotification();
    _setupDailyNotificationTimer();
  }

  void _setupDailyNotificationTimer() {
    // Calculate delay until the next 7:00 AM
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = _nextInstanceOfSevenAM();
    Duration durationUntilNextNotification = scheduledDate.difference(now);

    // Setup timer to repeat every day at 7:00 AM
    timer = Timer(durationUntilNextNotification, () {
      _scheduleNextNotification();
      timer = Timer.periodic(Duration(days: 1), (Timer t) {
        _scheduleNextNotification();
      });
    });
  }

  void _scheduleNextNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Grace Devotion',
      'It\'s time for today\'s devotion!',
      _nextInstanceOfSevenAM(),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'devotion',
          'Devotion Notifications',
          channelDescription: 'Notification channel for devotion notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'drawable/logo', // Assuming your notification icon is here
          color: Colors.black,
          playSound: true,
          largeIcon: DrawableResourceAndroidBitmap(
              'drawable/logo'), // Update path to your image
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
  }

  tz.TZDateTime _nextInstanceOfSevenAM() {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 7);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }
}
