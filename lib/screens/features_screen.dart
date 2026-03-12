import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Features'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFeatureCard(
            context,
            Icons.timer,
            'Stopwatch',
            'Measure elapsed time with lap functionality',
            const StopwatchScreen(),
          ),
          _buildFeatureCard(
            context,
            Icons.hourglass_empty,
            'Countdown Timer',
            'Set timers for various activities',
            const CountdownTimerScreen(),
          ),
          _buildFeatureCard(
            context,
            Icons.access_time,
            'Focus Time',
            'Pomodoro technique for productivity',
            const FocusTimeScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      IconData icon,
      String title,
      String description,
      Widget screen,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Icon(
          icon,
          size: 36,
          color: Colors.deepPurpleAccent,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }
}

// Stopwatch Screen
class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  bool _isRunning = false;
  int _elapsedMilliseconds = 0;
  List<String> _laps = [];
  late final Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
  }

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        _stopwatch.stop();
      } else {
        _stopwatch.start();
      }
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    setState(() {
      _stopwatch.reset();
      _elapsedMilliseconds = 0;
      _laps.clear();
      if (_isRunning) {
        _stopwatch.start();
      }
    });
  }

  void _recordLap() {
    setState(() {
      final lapTime = _stopwatch.elapsedMilliseconds;
      final lapString = _formatTime(lapTime);
      _laps.add('Lap ${_laps.length + 1}: $lapString');
    });
  }

  String _formatTime(int milliseconds) {
    int hours = (milliseconds / 3600000).floor();
    int minutes = ((milliseconds % 3600000) / 60000).floor();
    int seconds = ((milliseconds % 60000) / 1000).floor();
    int ms = milliseconds % 1000;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${ms.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isRunning) {
      _elapsedMilliseconds = _stopwatch.elapsedMilliseconds;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          // Time display
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                _formatTime(_elapsedMilliseconds),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
          
          // Laps list
          Expanded(
            flex: 3,
            child: _laps.isEmpty
                ? const Center(
                    child: Text(
                      'No laps recorded',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _laps.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_laps[index]),
                        trailing: Text(
                          '${_laps.length - index}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Controls
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? _recordLap : _resetTimer,
                  icon: Icon(_isRunning ? Icons.flag : Icons.replay),
                  label: Text(_isRunning ? 'Lap' : 'Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Pause' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? Colors.orange : Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Countdown Timer Screen
class CountdownTimerScreen extends StatefulWidget {
  const CountdownTimerScreen({super.key});

  @override
  State<CountdownTimerScreen> createState() => _CountdownTimerScreenState();
}

class _CountdownTimerScreenState extends State<CountdownTimerScreen> {
  bool _isRunning = false;
  int _remainingSeconds = 0;
  int _initialSeconds = 0;
  late final Timer _timer;
  bool _isTimerSet = false;

  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _stopTimer();
          // TODO: Add notification when timer ends
        }
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _timer.cancel();
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _remainingSeconds = _initialSeconds;
      _timer.cancel();
    });
  }

  void _setTimer() {
    final int hours = int.tryParse(_hoursController.text) ?? 0;
    final int minutes = int.tryParse(_minutesController.text) ?? 0;
    final int seconds = int.tryParse(_secondsController.text) ?? 0;
    
    setState(() {
      _initialSeconds = (hours * 3600) + (minutes * 60) + seconds;
      _remainingSeconds = _initialSeconds;
      _isTimerSet = true;
    });
  }

  String _formatTime(int totalSeconds) {
    int hours = (totalSeconds / 3600).floor();
    int minutes = ((totalSeconds % 3600) / 60).floor();
    int seconds = totalSeconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdown Timer'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Timer display
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: -2,
              ),
            ),
          ),
          
          // Timer input
          if (!_isTimerSet || !_isRunning) ...[
            const Text(
              'Set Timer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hours',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minutes',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _secondsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Seconds',
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _setTimer,
              icon: const Icon(Icons.access_time),
              label: const Text('Set Timer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
          
          // Timer controls
          if (_isTimerSet) ...[
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? _stopTimer : _startTimer,
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_isRunning ? 'Pause' : 'Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRunning ? Colors.orange : Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.replay),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Focus Time (Pomodoro) Screen
class FocusTimeScreen extends StatefulWidget {
  const FocusTimeScreen({super.key});

  @override
  State<FocusTimeScreen> createState() => _FocusTimeScreenState();
}

class _FocusTimeScreenState extends State<FocusTimeScreen> {
  bool _isRunning = false;
  bool _isBreakTime = false;
  int _remainingSeconds = 0;
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _completedSessions = 0;
  late final Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _remainingSeconds = (_isBreakTime ? _breakMinutes : _focusMinutes) * 60;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _timer.cancel();
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _isBreakTime = false;
      _remainingSeconds = _focusMinutes * 60;
      _timer.cancel();
    });
  }

  void _onTimerComplete() {
    setState(() {
      _isRunning = false;
      _timer.cancel();
      
      if (_isBreakTime) {
        // Break ended, start focus session
        _isBreakTime = false;
        _completedSessions++;
      } else {
        // Focus session ended, start break
        _isBreakTime = true;
      }
      
      // Start next session automatically
      _startTimer();
    });
  }

  String _formatTime(int totalSeconds) {
    int minutes = (totalSeconds / 60).floor();
    int seconds = totalSeconds % 60;
    
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Time (Pomodoro)'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Timer display
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Text(
                  _isBreakTime ? 'Break Time' : 'Focus Time',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isBreakTime ? Colors.green : Colors.deepPurpleAccent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -2,
                  ),
                ),
              ],
            ),
          ),
          
          // Sessions counter
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Completed Sessions: $_completedSessions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Settings
          const SizedBox(height: 32),
          const Text(
            'Session Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text('Focus (min)', style: TextStyle(fontSize: 16)),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: TextEditingController(text: _focusMinutes.toString()),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        setState(() {
                          _focusMinutes = int.tryParse(value) ?? 25;
                          if (!_isRunning) {
                            _remainingSeconds = _focusMinutes * 60;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Break (min)', style: TextStyle(fontSize: 16)),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: TextEditingController(text: _breakMinutes.toString()),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        setState(() {
                          _breakMinutes = int.tryParse(value) ?? 5;
                          if (!_isRunning && _isBreakTime) {
                            _remainingSeconds = _breakMinutes * 60;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Controls
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Pause' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? Colors.orange : Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.replay),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}