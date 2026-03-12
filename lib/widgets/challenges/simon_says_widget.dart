import 'dart:async';
import 'package:flutter/material.dart';

class SimonSaysWidget extends StatefulWidget {
  final VoidCallback onChallengeCompleted;
  
  const SimonSaysWidget({super.key, required this.onChallengeCompleted});

  @override
  State<SimonSaysWidget> createState() => _SimonSaysWidgetState();
}

class _SimonSaysWidgetState extends State<SimonSaysWidget> {
  // Logic placeholder
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Color Memory Challenge',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
        ),
        const SizedBox(height: 16),
        const Text(
          'Repeat the sequence of colors to turn off the alarm!',
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _colorButton(Colors.red),
            _colorButton(Colors.green),
            _colorButton(Colors.blue),
            _colorButton(Colors.yellow),
          ],
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

  Widget _colorButton(Color color) {
    return GestureDetector(
      onTap: () {
        // Handle logic
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
      ),
    );
  }
}
