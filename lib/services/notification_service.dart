import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Store active notifications
  final List<NotificationItem> _activeNotifications = [];

  // Getter for active notifications
  List<NotificationItem> get activeNotifications => _activeNotifications;

  Future<void> init() async {
    try {
      // Initialize timezone
      tz_init.initializeTimeZones();

      // Android initialization with icon and channel details
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher',
          );

      // iOS initialization
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(

            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      // Initialize the plugin and set up notification click handling
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
          // You can add navigation logic here if needed
        },
      );

      // Create notification channel for Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }

      // Request permissions for iOS
      if (Platform.isIOS) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }

      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'water_tracker_channel',
      'Water Tracker Notifications',
      description: 'Notifications for water tracking reminders',
      sound:  RawResourceAndroidNotificationSound('water_drop'),
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // Request notification permissions - removed Android permission request
  Future<void> requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >();

        final bool? granted = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS notification permission granted: $granted');
      }
      // For Android, permissions are handled in the AndroidManifest.xml
      // and through system settings
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'water_tracker_channel',
            'Water Tracker Notifications',
            channelDescription: 'Notifications for water tracking reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.reminder,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      // Add to active notifications
      _activeNotifications.add(
        NotificationItem(
          id: id,
          title: title,
          body: body,
          timestamp: DateTime.now(),
        ),
      );

      debugPrint('Notification shown successfully');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'water_tracker_channel',
            'Water Tracker Notifications',
            channelDescription: 'Notifications for water tracking reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.reminder,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        interruptionLevel: InterruptionLevel.active,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // Removed uiLocalNotificationDateInterpretation parameter
        payload: payload,
      );

      // Add to active notifications
      _activeNotifications.add(
        NotificationItem(
          id: id,
          title: title,
          body: body,
          timestamp: scheduledDate,
          isScheduled: true,
        ),
      );

      debugPrint('Notification scheduled for ${scheduledDate.toString()}');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Schedule daily reminders
  Future<void> scheduleReminders() async {
    try {
      // Schedule reminders throughout the day
      final now = DateTime.now();
      final random = Random();

      // Morning reminder (8-10 AM)
      final morningHour = 8 + random.nextInt(2);
      final morningTime = DateTime(
        now.year,
        now.month,
        now.day,
        morningHour,
        random.nextInt(60),
      );

      if (morningTime.isAfter(now)) {
        await scheduleNotification(
          id: 1,
          title: 'Morning Hydration',
          body: 'Start your day right with a glass of water!',
          scheduledDate: morningTime,
        );
      }

      // Midday reminder (12-2 PM)
      final middayHour = 12 + random.nextInt(2);
      final middayTime = DateTime(
        now.year,
        now.month,
        now.day,
        middayHour,
        random.nextInt(60),
      );

      if (middayTime.isAfter(now)) {
        await scheduleNotification(
          id: 2,
          title: 'Midday Hydration Check',
          body: 'Have you had enough water today? Time for a refill!',
          scheduledDate: middayTime,
        );
      }

      // Afternoon reminder (3-5 PM)
      final afternoonHour = 15 + random.nextInt(2);
      final afternoonTime = DateTime(
        now.year,
        now.month,
        now.day,
        afternoonHour,
        random.nextInt(60),
      );

      if (afternoonTime.isAfter(now)) {
        await scheduleNotification(
          id: 3,
          title: 'Afternoon Reminder',
          body:
              'Feeling the afternoon slump? Hydration can help boost your energy!',
          scheduledDate: afternoonTime,
        );
      }

      // Evening reminder (7-9 PM)
      final eveningHour = 19 + random.nextInt(2);
      final eveningTime = DateTime(
        now.year,
        now.month,
        now.day,
        eveningHour,
        random.nextInt(60),
      );

      if (eveningTime.isAfter(now)) {
        await scheduleNotification(
          id: 4,
          title: 'Evening Hydration',
          body: 'Don\'t forget to reach your daily water goal!',
          scheduledDate: eveningTime,
        );
      }

      debugPrint('Daily reminders scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling reminders: $e');
    }
  }

  // Schedule a single reminder
  Future<void> scheduleReminderIn(int minutes) async {
    try {
      final scheduledTime = DateTime.now().add(Duration(minutes: minutes));

      await scheduleNotification(
        id: 100 + minutes, // Use minutes as part of ID to avoid conflicts
        title: 'Hydration Reminder',
        body: 'Time to drink some water!',
        scheduledDate: scheduledTime,
      );

      debugPrint('Reminder scheduled for $minutes minutes from now');
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
      _activeNotifications.removeWhere((notification) => notification.id == id);
      debugPrint('Notification with ID $id canceled');
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      _activeNotifications.clear();
      debugPrint('All notifications canceled');
    } catch (e) {
      debugPrint('Error canceling notifications: $e');
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        final areEnabled =
            await androidImplementation.areNotificationsEnabled();
        return areEnabled ?? false;
      }

      return true; // Default to true for iOS or if we can't check
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }
}

// Class to store notification information
class NotificationItem {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isScheduled;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isScheduled = false,
  });
}
