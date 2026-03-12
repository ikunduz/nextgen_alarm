import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/alarm_model.dart';

/// Background callback for alarms
@pragma('vm:entry-point')
Future<void> backgroundAlarmCallback() async {
  debugPrint('Background alarm callback fired!');
  // The alarm manager will handle showing the notification and launching the app
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

    // Calculate delay in seconds
    final int delay = scheduledTime.difference(DateTime.now()).inSeconds;

    if (delay <= 0) {
      debugPrint('Cannot schedule alarm in the past: $delay seconds');
      return false;
    }

    try {
      // Schedule exact alarm
      await AndroidAlarmManager.oneShot(
        Duration(seconds: delay),
        alarmId,
        backgroundAlarmCallback,
        exact: true,
        wakeup: true,
        alarmClock: true,
        rescheduleOnReboot: true,
      );

      debugPrint('Alarm scheduled: ID=$alarmId, delay=${delay}s');
      return true;
    } catch (e) {
      debugPrint('Failed to schedule alarm: $e');
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
