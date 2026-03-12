class AlarmModel {
  final int id;
  final DateTime time;
  final bool isActive;
  final String challengeType; // 'simon_says', 'gyro_maze', 'none'
  final String? customAudioPath;
  final List<int> linkedAlarmIds; // For the Auto-5x feature, to turn them all off

  AlarmModel({
    required this.id,
    required this.time,
    this.isActive = true,
    this.challengeType = 'none',
    this.customAudioPath,
    this.linkedAlarmIds = const [],
  });

  AlarmModel copyWith({
    int? id,
    DateTime? time,
    bool? isActive,
    String? challengeType,
    String? customAudioPath,
    List<int>? linkedAlarmIds,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      challengeType: challengeType ?? this.challengeType,
      customAudioPath: customAudioPath ?? this.customAudioPath,
      linkedAlarmIds: linkedAlarmIds ?? this.linkedAlarmIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'isActive': isActive,
      'challengeType': challengeType,
      'customAudioPath': customAudioPath,
      'linkedAlarmIds': linkedAlarmIds,
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id']?.toInt() ?? 0,
      time: DateTime.parse(map['time']),
      isActive: map['isActive'] ?? false,
      challengeType: map['challengeType'] ?? 'none',
      customAudioPath: map['customAudioPath'],
      linkedAlarmIds: List<int>.from(map['linkedAlarmIds'] ?? []),
    );
  }
}
