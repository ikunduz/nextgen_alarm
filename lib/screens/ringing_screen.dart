import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/audio_service.dart';
import '../services/alarm_notification_service.dart';
import '../widgets/challenges/simon_says_widget.dart';
import '../widgets/challenges/gyro_maze_widget.dart';

class RingingScreen extends StatefulWidget {
  final AlarmModel alarm;

  const RingingScreen({super.key, required this.alarm});

  @override
  State<RingingScreen> createState() => _RingingScreenState();
}

class _RingingScreenState extends State<RingingScreen> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _startRinging();
  }

  Future<void> _startRinging() async {
    // If there's a custom audio path, play it. Otherwise play default system alarm
    if (widget.alarm.customAudioPath != null && widget.alarm.customAudioPath!.isNotEmpty) {
      await _audioService.playAudio(widget.alarm.customAudioPath!);
    } else {
      await _audioService.playAssetAudio('alarms/system_alarm.mp3');
    }
    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _stopRingingAndDismiss() async {
    if (_isPlaying) {
      await _audioService.stopAudio();
    }
    
    // Clear the notification
    final notificationService = AlarmNotificationService();
    await notificationService.cancelNotification(widget.alarm.id);
    await notificationService.clearTriggeredAlarm(widget.alarm.id);
    
    if (mounted) {
      Navigator.pop(context); // Go back to dashboard
    }
  }

  Widget _buildChallengeWidget() {
    if (widget.alarm.challengeType == 'simon_says') {
      return SimonSaysWidget(onChallengeCompleted: _stopRingingAndDismiss);
    } else if (widget.alarm.challengeType == 'gyro_maze') {
      return GyroMazeWidget(onChallengeCompleted: _stopRingingAndDismiss);
    } else {
      // No challenge, just a big button
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.alarm_on, size: 100, color: Colors.greenAccent),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _stopRingingAndDismiss,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            ),
            child: const Text('WAKE UP!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Extra dark for sleepy eyes
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: _buildChallengeWidget(),
          ),
        ),
      ),
    );
  }
}
