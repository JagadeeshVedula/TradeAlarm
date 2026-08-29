import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/alarms/domain/models/alarm.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      'gmx_oi_alarm_channel_v3',
      'GMX OI Threshold Alarms',
      description: 'Notifications for GMX Long Open Interest threshold crossings',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _isInitialized = true;
  }

  static Future<void> requestPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  static Future<void> showAlarmNotification({
    required Alarm alarm,
    required double currentPct,
  }) async {
    await initialize();

    final directionText = alarm.direction == CrossDirection.up ? 'crossed UP' : 'crossed DOWN';
    final currentPctFormatted = currentPct.round().toString();
    final thresholdFormatted = alarm.threshold.toStringAsFixed(1);

    String title = '🚨 GMX ALARM: ${alarm.label}';
    String body = '${alarm.tokenSymbol} Long OI $directionText $thresholdFormatted% (Current: $currentPctFormatted%)';
    if (alarm.note != null && alarm.note!.isNotEmpty) {
      body += '\nNote: "${alarm.note}"';
    }

    final androidDetails = AndroidNotificationDetails(
      'gmx_oi_alarm_channel_v3',
      'GMX OI Threshold Alarms',
      channelDescription: 'Notifications for GMX Long Open Interest threshold crossings',
      importance: Importance.max,
      priority: Priority.max,
      ticker: '🚨 GMX ALARM TRIGGERED',
      colorized: true,
      color: const Color(0xFF00F5A0),
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 250, 500, 250, 500]),
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      alarm.id.hashCode,
      title,
      body,
      details,
    );
  }
}
