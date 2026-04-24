// lib/data/models/mood_check_in.dart
// Mood check-in data model

class MoodCheckIn {
  final String id;
  final String userId;
  final String mood; // 'Happy', 'Calm', 'Sad', 'Anxious'
  final String? reflectionNotes;
  final DateTime timestamp;
  
  MoodCheckIn({
    required this.id,
    required this.userId,
    required this.mood,
    this.reflectionNotes,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mood': mood,
      'reflectionNotes': reflectionNotes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory MoodCheckIn.fromJson(Map<String, dynamic> json) {
    return MoodCheckIn(
      id: json['id'] as String,
      userId: json['userId'] as String,
      mood: json['mood'] as String,
      reflectionNotes: json['reflectionNotes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
