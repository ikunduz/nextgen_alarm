import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/alarm_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/ringing_screen.dart';
import 'screens/features_screen.dart';
import 'services/audio_service.dart';
import 'services/alarm_service.dart';
import 'models/alarm_model.dart';

import 'services/alarm_notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request permissions for Android 12+ (exact alarms)
  await _requestPermissions();
  
  // Initialize audio service
  final audioService = AudioService();
  await audioService.init();
  
  // Initialize alarm service
  final alarmService = AlarmService();
  await alarmService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        Provider<AudioService>(create: (_) => audioService),
        Provider<AlarmService>(create: (_) => alarmService),
      ],
      child: const NextGenAlarmApp(),
    ),
  );
}

// Request necessary permissions for Android 12+
Future<void> _requestPermissions() async {
  // Initialize alarm service first to check permissions
  final alarmService = AlarmService();
  await alarmService.init();
  
  // Check if exact alarms can be scheduled
  final canSchedule = await alarmService.canScheduleExactAlarms();
  if (!canSchedule) {
    debugPrint('Cannot schedule exact alarms - user needs to grant permission in settings');
  }

  // Request notification permissions
  final notificationService = AlarmNotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();
}

class NextGenAlarmApp extends StatefulWidget {
  const NextGenAlarmApp({super.key});

  @override
  State<NextGenAlarmApp> createState() => _NextGenAlarmAppState();
}

class _NextGenAlarmAppState extends State<NextGenAlarmApp> with WidgetsBindingObserver {
  AlarmModel? _activeAlarm;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForAlarmTrigger();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check if app was resumed from an alarm
      _checkForAlarmTrigger();
    }
  }
  
  void _checkForAlarmTrigger() async {
    final prefs = await SharedPreferences.getInstance();
    final bool triggered = prefs.getBool('alarm_triggered') ?? false;
    
    if (triggered) {
      final int? alarmId = prefs.getInt('triggered_alarm_id');
      if (alarmId != null) {
        // Clear the trigger flags immediately so we don't loop
        await prefs.setBool('alarm_triggered', false);
        
        // Find the alarm in the provider
        if (mounted) {
          final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
          final alarm = alarmProvider.alarms.cast<AlarmModel?>().firstWhere((a) => a?.id == alarmId, orElse: () => null);
          
          if (alarm != null) {
            _showRingingScreen(alarm);
          }
        }
      }
    }
  }

  void _showRingingScreen(AlarmModel alarm) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => RingingScreen(alarm: alarm),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'NextGen Alarm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.cyanAccent,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
