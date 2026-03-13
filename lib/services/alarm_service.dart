import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/alarm_model.dart';
import 'alarm_notification_service.dart';

/// Background callback for alarms - this is called when alarm fires
@pragma('vm:entry-point')
void backgroundAlarmCallback(int alarmId) async {
  debugPrint('🔔 ALARM IS RINGING! Background callback fired for ID: $alarmId');

  // Load alarms from shared preferences to get details for this ID
  final prefs = await SharedPreferences.getInstance();
  final String? alarmsJson = prefs.getString('nextgen_alarms');
  
  String challengeType = 'none';
  String? audioPath;
  String alarmTime = DateTime.now().toString();

  if (alarmsJson != null) {
    try {
      final List<dynamic> decoded = jsonDecode(alarmsJson);
      final alarmData = decoded.firstWhere((e) => e['id'] == alarmId, orElse: () => null);
      
      if (alarmData != null) {
        challengeType = alarmData['challengeType'] ?? 'none';
        audioPath = alarmData['customAudioPath'];
        alarmTime = alarmData['time'] ?? alarmTime;
        debugPrint('Fetched alarm details: Challenge=$challengeType, audio=$audioPath');
      } else {
        debugPrint('No alarm data found for ID: $alarmId');
      }
    } catch (e) {
      debugPrint('Error parsing alarms for background callback: $e');
    }
  }

  // Save triggered info for the main app
  await prefs.setInt('triggered_alarm_id', alarmId);
  await prefs.setBool('alarm_triggered', true);

  // Show full-screen notification
  final notificationService = AlarmNotificationService();
  await notificationService.init();
  await notificationService.showAlarmNotification(
    alarmId: alarmId,
    alarmTime: alarmTime,
    challengeType: challengeType,
  );
}

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await AndroidAlarmManager.initialize();
    _isInitialized = true;
    debugPrint('AlarmService initialized');
  }

  /// Schedule an alarm for a specific time
  Future<bool> scheduleAlarm(AlarmModel alarm) async {
    if (!_isInitialized) {
      await init();
    }

    final int alarmId = alarm.id;
    final DateTime scheduledTime = alarm.time;

    // Get current time from the device
    final DateTime now = DateTime.now();
    final int delay = scheduledTime.difference(now).inSeconds;

    if (delay <= 0) {
      debugPrint('Cannot schedule alarm in the past: $delay seconds');
      return false;
    }

    try {
      // Schedule exact alarm using oneShotAt with absolute time
      // This uses the device's real time clock
      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        alarmId,
        backgroundAlarmCallback,
        exact: true,
        wakeup: true,
        alarmClock: true,
        rescheduleOnReboot: true,
      );

      debugPrint('✅ Alarm scheduled: ID=$alarmId, time=$scheduledTime, delay=${delay}s');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to schedule alarm: $e');
      return false;
    }
  }

  /// Cancel a scheduled alarm
  Future<bool> cancelAlarm(int alarmId) async {
    try {
      await AndroidAlarmManager.cancel(alarmId);
      debugPrint('Alarm cancelled: ID=$alarmId');
      return true;
    } catch (e) {
      debugPrint('Failed to cancel alarm: $e');
      return false;
    }
  }

  /// Schedule multiple alarms (for Auto-5x feature)
  Future<void> scheduleMultipleAlarms(List<AlarmModel> alarms) async {
    for (final alarm in alarms) {
      await scheduleAlarm(alarm);
    }
  }

  /// Check if exact alarms can be scheduled
  Future<bool> canScheduleExactAlarms() async {
    return true;
  }
}
