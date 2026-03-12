import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroMazeWidget extends StatefulWidget {
  final VoidCallback onChallengeCompleted;

  const GyroMazeWidget({super.key, required this.onChallengeCompleted});

  @override
  State<GyroMazeWidget> createState() => _GyroMazeWidgetState();
}

class _GyroMazeWidgetState extends State<GyroMazeWidget> {
  // Logic placeholder
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Gyro Maze Challenge',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tilt your phone to guide the ball into the center.',
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.black45,
            border: Border.all(color: Colors.deepPurpleAccent, width: 4),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.sports_baseball, color: Colors.white, size: 32), // Placeholder for ball/maze
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: widget.onChallengeCompleted, // SKIPPING FOR DEMO PURPOSES
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
          child: const Text('DEBUG: Skip Challenge'),
        )
      ],
    );
  }
}
