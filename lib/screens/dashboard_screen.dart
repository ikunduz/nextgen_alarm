import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm_model.dart';
import 'add_alarm_modal.dart';
import 'features_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showAddAlarmModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAlarmModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Enhanced gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced App Bar
              _buildAppBar(context),
              
              // Enhanced body
              Expanded(
                child: Consumer<AlarmProvider>(
                  builder: (context, provider, child) {
                    if (provider.alarms.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: provider.alarms.length,
                      itemBuilder: (context, index) {
                        final alarm = provider.alarms[index];
                        return _buildAlarmCard(context, alarm, index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Enhanced FAB
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'NextGen Alarm',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.deepPurpleAccent.withOpacity(0.5),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.list_alt, color: Colors.white70),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeaturesScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white70),
                onPressed: () {
                  // TODO: Navigate to settings
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_add,
            size: 80,
            color: Colors.deepPurpleAccent.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'No alarms set',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap + to create your first challenge alarm!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Quick add buttons for common alarms
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickAlarmButton(context, 'Morning', 7, 0),
              _buildQuickAlarmButton(context, 'Workout', 18, 0),
              _buildQuickAlarmButton(context, 'Study', 20, 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAlarmButton(BuildContext context, String label, int hour, int minute) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implement quick alarm creation
      },
      icon: Icon(Icons.access_time, size: 18),
      label: Text('$label\n${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.2),
        foregroundColor: Colors.deepPurpleAccent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAlarmCard(BuildContext context, AlarmModel alarm, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key('alarm_${alarm.id}'),
        background: Container(
          color: Colors.redAccent,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 28),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          context.read<AlarmProvider>().deleteAlarm(alarm.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alarm deleted')),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: alarm.isActive
                  ? [
                      Colors.deepPurpleAccent.withOpacity(0.2),
                      Colors.deepPurpleAccent.withOpacity(0.1),
                    ]
                  : [
                      Colors.grey[800]!,
                      Colors.grey[900]!,
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: alarm.isActive
                  ? Colors.deepPurpleAccent.withOpacity(0.4)
                  : Colors.grey[700]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurpleAccent.withOpacity(alarm.isActive ? 0.3 : 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('HH:mm').format(alarm.time),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: alarm.isActive ? Colors.white : Colors.grey[400],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Toggle Switch as requested "kapatma tuşu"
                Switch(
                  value: alarm.isActive,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  thumbColor: MaterialStateProperty.all(Colors.white),
                  onChanged: (val) {
                    context.read<AlarmProvider>().toggleAlarm(alarm.id, val);
                  },
                ),
                const SizedBox(width: 8),
                // Explicit Delete Button as requested "silme tuşu"
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    // Show confirmation dialog or just delete
                    _showDeleteConfirmation(context, alarm.id);
                  },
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    _getChallengeIcon(alarm.challengeType),
                    size: 18,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Challenge: ${alarm.challengeType.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  if (alarm.linkedAlarmIds.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Auto 5x',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int alarmId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Alarm?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this alarm?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AlarmProvider>().deleteAlarm(alarmId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alarm deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  IconData _getChallengeIcon(String challengeType) {
    switch (challengeType) {
      case 'simon_says':
        return Icons.memory;
      case 'gyro_maze':
        return Icons.analytics;
      default:
        return Icons.alarm;
    }
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddAlarmModal(context),
      icon: const Icon(Icons.add_circle_outline, size: 28),
      label: const Text(
        'Create Alarm',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.deepPurpleAccent,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
