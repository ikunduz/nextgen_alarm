import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';

class AlarmNotificationService {
  static final AlarmNotificationService _instance = AlarmNotificationService._internal();
  factory AlarmNotificationService() => _instance;
  AlarmNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const String _triggeredAlarmsKey = 'triggered_alarms';

  Future<void> init() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    debugPrint('AlarmNotificationService initialized');
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Alarm notification tapped: ${response.payload}');
    // Alarm ID'yi kaydet, app açıldığında RingingScreen gösterilecek
    if (response.payload != null) {
      _saveTriggeredAlarm(int.parse(response.payload!));
    }
  }

  Future<void> showAlarmNotification({
    required int alarmId,
    required String alarmTime,
    required String challengeType,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'alarm_channel_v1',
      'Alarm Notifications',
      channelDescription: 'Alarm clock notifications',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      autoCancel: false,
      ongoing: true,
      sound: const RawResourceAndroidNotificationSound('system_alarm'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
      additionalFlags: Int32List.fromList([4]),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
      when: 0,
      usesChronometer: false,
      channelShowBadge: true,
      onlyAlertOnce: false,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: alarmId,
      title: '⏰ ALARM!',
      body: 'Wake up! Challenge: $challengeType',
      notificationDetails: notificationDetails,
      payload: alarmId.toString(),
    );

    debugPrint('Alarm notification shown for alarm ID: $alarmId');
    _saveTriggeredAlarm(alarmId);
  }

  void _saveTriggeredAlarm(int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> triggeredAlarms = prefs.getStringList(_triggeredAlarmsKey) ?? [];
    triggeredAlarms.add(alarmId.toString());
    await prefs.setStringList(_triggeredAlarmsKey, triggeredAlarms);
    debugPrint('Saved triggered alarm ID: $alarmId');
  }

  Future<List<int>> getTriggeredAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> triggeredAlarms = prefs.getStringList(_triggeredAlarmsKey) ?? [];
    return triggeredAlarms.map((id) => int.parse(id)).toList();
  }

  Future<void> clearTriggeredAlarm(int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> triggeredAlarms = prefs.getStringList(_triggeredAlarmsKey) ?? [];
    triggeredAlarms.remove(alarmId.toString());
    await prefs.setStringList(_triggeredAlarmsKey, triggeredAlarms);
    debugPrint('Cleared triggered alarm ID: $alarmId');
  }

  Future<void> cancelNotification(int alarmId) async {
    await flutterLocalNotificationsPlugin.cancel(id: alarmId);
  }
}
