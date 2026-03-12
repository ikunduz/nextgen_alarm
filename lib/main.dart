import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/alarm_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/features_screen.dart';
import 'services/audio_service.dart';
import 'services/alarm_service.dart';

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

Future<bool> _checkAndRequestNotificationPermission() async {
  // This will be handled by the flutter_local_notifications plugin
  return true;
}

class NextGenAlarmApp extends StatelessWidget {
  const NextGenAlarmApp({super.key});

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
