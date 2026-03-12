import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';

class AlarmProvider with ChangeNotifier {
  List<AlarmModel> _alarms = [];
  SharedPreferences? _prefs;
  static const String _prefsKey = 'nextgen_alarms';

  List<AlarmModel> get alarms => _alarms;

  AlarmProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadAlarms();
  }

  void _loadAlarms() {
    if (_prefs == null) return;
    final String? alarmsJson = _prefs!.getString(_prefsKey);
    if (alarmsJson != null) {
      final List<dynamic> decoded = jsonDecode(alarmsJson);
      _alarms = decoded.map((e) => AlarmModel.fromJson(e)).toList();
      _alarms.sort((a, b) => a.time.compareTo(b.time));
      notifyListeners();
    }
  }

  Future<void> _saveAlarms() async {
    if (_prefs == null) return;
    final List<Map<String, dynamic>> alarmsList = _alarms.map((e) => e.toJson()).toList();
    await _prefs!.setString(_prefsKey, jsonEncode(alarmsList));
  }

  int _generateId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000) + Random().nextInt(1000);
  }

  Future<void> addAlarm(DateTime time, String challengeType, String? audioPath, {bool auto5x = false}) async {
    List<AlarmModel> newAlarms = [];
    List<int> groupIds = [];

    if (auto5x) {
      for (int i = 0; i < 5; i++) {
        groupIds.add(_generateId() + i); 
      }
      
      for (int i = 0; i < 5; i++) {
        DateTime alarmTime = time.add(Duration(minutes: i * 2)); // 2 min interval
        newAlarms.add(AlarmModel(
          id: groupIds[i],
          time: alarmTime,
          challengeType: challengeType,
          customAudioPath: audioPath,
          linkedAlarmIds: groupIds,
        ));
      }
    } else {
      newAlarms.add(AlarmModel(
        id: _generateId(),
        time: time,
        challengeType: challengeType,
        customAudioPath: audioPath,
      ));
    }

    _alarms.addAll(newAlarms);
    _alarms.sort((a, b) => a.time.compareTo(b.time));
    
    await _saveAlarms();
    notifyListeners();

    // Schedule alarms via AlarmService
    final alarmService = AlarmService();
    for (final alarm in newAlarms) {
      if (alarm.isActive) {
        await alarmService.scheduleAlarm(alarm);
      }
    }
  }

  Future<void> toggleAlarm(int id, bool isActive) async {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alarms[index] = _alarms[index].copyWith(isActive: isActive);
      
      final alarmService = AlarmService();

      if (!isActive && _alarms[index].linkedAlarmIds.isNotEmpty) {
          for(int linkedId in _alarms[index].linkedAlarmIds) {
             final lIndex = _alarms.indexWhere((a) => a.id == linkedId);
             if (lIndex != -1) {
                 _alarms[lIndex] = _alarms[lIndex].copyWith(isActive: false);
                 // Cancel linked alarm
                 await alarmService.cancelAlarm(linkedId);
             }
          }
          // Cancel the main alarm too
          await alarmService.cancelAlarm(id);
      } else if (isActive) {
        // Schedule the alarm
        await alarmService.scheduleAlarm(_alarms[index]);
      } else {
        // Cancel this alarm
        await alarmService.cancelAlarm(id);
      }

      await _saveAlarms();
      notifyListeners();
      // TODO: Update scheduling
    }
  }

  Future<void> deleteAlarm(int id) async {
     final index = _alarms.indexWhere((a) => a.id == id);
     if (index != -1) {
         final alarm = _alarms[index];
         
         // Cancel alarms in the system
         final alarmService = AlarmService();
         await alarmService.cancelAlarm(id);
         
         if (alarm.linkedAlarmIds.isNotEmpty) {
             for (final linkedId in alarm.linkedAlarmIds) {
               await alarmService.cancelAlarm(linkedId);
               _alarms.removeWhere((a) => a.id == linkedId);
             }
         } else {
             _alarms.removeAt(index);
         }
         await _saveAlarms();
         notifyListeners();
     }
  }
}
