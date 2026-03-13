import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'providers/alarm_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/ringing_screen.dart';
import 'screens/features_screen.dart';
import 'services/audio_service.dart';
import 'services/alarm_service.dart';
import 'models/alarm_model.dart';

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
  
  void _checkForAlarmTrigger() {
    // In a real app, we would check a flag or shared preferences
    // to see if the alarm was triggered while the app was in background
    // For now, we'll handle it through the ringing screen
  }

  void _showRingingScreen(AlarmModel alarm) {
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RingingScreen(alarm: alarm),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
