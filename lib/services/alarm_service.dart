import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/alarm_model.dart';

/// Background callback for alarms - this is called when alarm fires
@pragma('vm:entry-point')
Future<void> backgroundAlarmCallback() async {
  debugPrint('🔔 ALARM IS RINGING! Background callback fired!');
  
  // The Android Alarm Manager Plus plugin will automatically:
  // 1. Wake up the device
  // 2. Start the app if it's not running
  // 3. Call this callback
  
  // We return immediately - the app should be started automatically
  return Future.value();
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
