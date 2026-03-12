import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../services/audio_service.dart';

class AddAlarmModal extends StatefulWidget {
  const AddAlarmModal({super.key});

  @override
  State<AddAlarmModal> createState() => _AddAlarmModalState();
}

class _AddAlarmModalState extends State<AddAlarmModal> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedChallenge = 'simon_says'; // 'simon_says', 'gyro_maze', 'none'
  bool _auto5x = false;
  
  final AudioService _audioService = AudioService();
  bool _isRecording = false;
  String? _recordedAudioPath;

  @override
  void initState() {
    super.initState();
    _audioService.init();
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _recordedAudioPath = path;
      });
    } else {
      final started = await _audioService.startRecording();
      if (started) {
        setState(() {
          _isRecording = true;
          _recordedAudioPath = null;
        });
      }
    }
  }

  void _saveAlarm() {
    final now = DateTime.now();
    DateTime alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // If time is in the past, schedule for tomorrow
    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    Provider.of<AlarmProvider>(context, listen: false).addAlarm(
      alarmTime,
      _selectedChallenge,
      _recordedAudioPath,
      auto5x: _auto5x,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Create NextGen Alarm', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          
          // TIME PICKER
          InkWell(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _selectedTime.format(context),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // AUTO 5X TOGGLE
          SwitchListTile(
            title: const Text('Auto 5x (Every 2 mins)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Creates 5 consecutive alarms automatically'),
            value: _auto5x,
            activeThumbColor: Colors.deepPurpleAccent,
            onChanged: (val) => setState(() => _auto5x = val),
          ),
          
          // CHALLENGE SELECTOR
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text('Wakeup Challenge', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'none', label: Text('None')),
              ButtonSegment(value: 'simon_says', label: Text('Color Memory')),
              ButtonSegment(value: 'gyro_maze', label: Text('Gyro Maze')),
            ],
            selected: {_selectedChallenge},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() => _selectedChallenge = newSelection.first);
            },
          ),
          const SizedBox(height: 16),

          // VOICE RECORDING
          ListTile(
            title: const Text('Custom Voice Note', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_recordedAudioPath != null ? 'Audio recorded ✨' : 'Tap mic to record your own alarm sound'),
            trailing: IconButton(
              icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic),
              color: _isRecording ? Colors.redAccent : Colors.white,
              iconSize: 32,
              onPressed: _toggleRecording,
            ),
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveAlarm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('SAVE ALARM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
