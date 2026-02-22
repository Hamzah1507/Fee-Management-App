import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Initialize ───────────────────────────────────────────
  Future<void> init() async {
    const android = AndroidInitializationSettings(
        '@mipmap/ic_launcher');

    const settings =
        InitializationSettings(android: android);

    await _plugin.initialize(settings);

    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── Fee Collected Notification ───────────────────────────
  Future<void> showFeeCollected({
    required String studentName,
    required int amount,
    required int semester,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'fee_collected',
        'Fee Collected',
        channelDescription:
            'Notifications when fees are collected',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF00C48C),
        playSound: true,
        enableVibration: true,
      ),
    );

    await _plugin.show(
      1,
      '✅ Fee Collected!',
      '₹$amount received from $studentName (Sem $semester)',
      details,
    );
  }

  // ── Overdue Alert Notification ───────────────────────────
  Future<void> showOverdueAlert({
    required String studentName,
    required int pendingAmount,
    required int daysOverdue,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'overdue_alert',
        'Overdue Alerts',
        channelDescription:
            'Alerts for overdue fee payments',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFFFF5B5B),
        playSound: true,
        enableVibration: true,
      ),
    );

    await _plugin.show(
      2,
      '⚠️ Overdue Fee Alert!',
      '$studentName is $daysOverdue day(s) overdue — ₹$pendingAmount pending',
      details,
    );
  }

  // ── Student Added Notification ───────────────────────────
  Future<void> showStudentAdded({
    required String studentName,
    required String course,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'student_added',
        'Student Added',
        channelDescription:
            'Notifications when a student is added',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF4F6EF7),
        playSound: true,
      ),
    );

    await _plugin.show(
      3,
      '👤 Student Added!',
      '$studentName enrolled in $course',
      details,
    );
  }
}