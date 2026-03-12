import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nextgen_alarm/providers/alarm_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Auto 5x logic creates exactly 5 alarms separated by 2 minutes', () async {
    final provider = AlarmProvider();
    
    // Wait for prefs init
    await Future.delayed(const Duration(milliseconds: 100));

    final baseTime = DateTime(2026, 1, 1, 15, 0); // 15:00
    
    await provider.addAlarm(
      baseTime, 
      'none', 
      null, 
      auto5x: true
    );

    expect(provider.alarms.length, 5);
    
    // Alarms should be sorted by time
    expect(provider.alarms[0].time, DateTime(2026, 1, 1, 15, 0));
    expect(provider.alarms[1].time, DateTime(2026, 1, 1, 15, 2));
    expect(provider.alarms[2].time, DateTime(2026, 1, 1, 15, 4));
    expect(provider.alarms[3].time, DateTime(2026, 1, 1, 15, 6));
    expect(provider.alarms[4].time, DateTime(2026, 1, 1, 15, 8));

    // Linked IDs should match across the group
    for (var alarm in provider.alarms) {
      expect(alarm.linkedAlarmIds.length, 5);
    }
  });

  test('Toggling one alarm in an Auto 5x group off toggles all others off', () async {
    final provider = AlarmProvider();
    await Future.delayed(const Duration(milliseconds: 100));

    final baseTime = DateTime.now();
    await provider.addAlarm(baseTime, 'simon_says', null, auto5x: true);

    expect(provider.alarms.every((a) => a.isActive == true), true);

    // Toggle one of them off
    final firstId = provider.alarms[0].id;
    await provider.toggleAlarm(firstId, false);

    // All should be off now
    expect(provider.alarms.every((a) => a.isActive == false), true);
  });
}
