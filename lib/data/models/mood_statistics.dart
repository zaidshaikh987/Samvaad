// lib/data/models/mood_statistics.dart
// Mood statistics data model

class MoodStatistics {
  final String userId;
  final int totalCheckIns;
  final Map<String, int> moodCounts; // {'Happy': 10, 'Calm': 8, ...}
  final String? mostFrequentMood;
  final int positiveDays;
  final int negativeDays;
  final double volatilityScore; // 0.0 to 1.0
  final DateTime startDate;
  final DateTime endDate;
  
  MoodStatistics({
    required this.userId,
    required this.totalCheckIns,
    required this.moodCounts,
    this.mostFrequentMood,
    required this.positiveDays,
    required this.negativeDays,
    required this.volatilityScore,
    required this.startDate,
    required this.endDate,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalCheckIns': totalCheckIns,
      'moodCounts': moodCounts,
      'mostFrequentMood': mostFrequentMood,
      'positiveDays': positiveDays,
      'negativeDays': negativeDays,
      'volatilityScore': volatilityScore,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
  
  factory MoodStatistics.fromJson(Map<String, dynamic> json) {
    return MoodStatistics(
      userId: json['userId'] as String,
      totalCheckIns: json['totalCheckIns'] as int,
      moodCounts: Map<String, int>.from(json['moodCounts'] as Map),
      mostFrequentMood: json['mostFrequentMood'] as String?,
      positiveDays: json['positiveDays'] as int,
      negativeDays: json['negativeDays'] as int,
      volatilityScore: (json['volatilityScore'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }
}
