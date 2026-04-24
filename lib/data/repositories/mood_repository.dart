// lib/data/repositories/mood_repository.dart
// Mood tracking data repository

import 'package:samvaad/data/database/database_manager.dart';
import 'package:samvaad/data/models/mood_check_in.dart';
import 'package:samvaad/data/models/mood_statistics.dart';

class MoodRepository {
  final DatabaseManager _dbManager = DatabaseManager();
  
  // Save mood check-in
  Future<void> saveMoodCheckIn(MoodCheckIn checkIn) async {
    final db = await _dbManager.database;
    await db.insert('mood_entries', checkIn.toJson());
    
    // Update activity statistics
    await _updateActivityStats(checkIn.userId);
  }
  
  // Get mood history for date range
  Future<List<MoodCheckIn>> getMoodHistory(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbManager.database;
    
    final results = await db.query(
      'mood_entries',
      where: 'userId = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'timestamp DESC',
    );
    
    return results.map((row) => MoodCheckIn.fromJson(row)).toList();
  }
  
  // Get mood statistics
  Future<MoodStatistics> getMoodStatistics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final moodHistory = await getMoodHistory(userId, startDate, endDate);
    
    if (moodHistory.isEmpty) {
      return MoodStatistics(
        userId: userId,
        totalCheckIns: 0,
        moodCounts: {},
        positiveDays: 0,
        negativeDays: 0,
        volatilityScore: 0.0,
        startDate: startDate,
        endDate: endDate,
      );
    }
    
    // Calculate mood counts
    final moodCounts = <String, int>{};
    int positiveDays = 0;
    int negativeDays = 0;
    
    for (final checkIn in moodHistory) {
      moodCounts[checkIn.mood] = (moodCounts[checkIn.mood] ?? 0) + 1;
      
      if (checkIn.mood == 'Happy' || checkIn.mood == 'Calm') {
        positiveDays++;
      } else {
        negativeDays++;
      }
    }
    
    // Find most frequent mood
    String? mostFrequentMood;
    int maxCount = 0;
    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentMood = mood;
      }
    });
    
    // Calculate volatility score (how often mood changes)
    double volatilityScore = 0.0;
    if (moodHistory.length > 1) {
      int changes = 0;
      for (int i = 1; i < moodHistory.length; i++) {
        if (moodHistory[i].mood != moodHistory[i - 1].mood) {
          changes++;
        }
      }
      volatilityScore = changes / (moodHistory.length - 1);
    }
    
    return MoodStatistics(
      userId: userId,
      totalCheckIns: moodHistory.length,
      moodCounts: moodCounts,
      mostFrequentMood: mostFrequentMood,
      positiveDays: positiveDays,
      negativeDays: negativeDays,
      volatilityScore: volatilityScore,
      startDate: startDate,
      endDate: endDate,
    );
  }
  
  // Get today's mood check-in
  Future<MoodCheckIn?> getTodayMoodCheckIn(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final history = await getMoodHistory(userId, startOfDay, endOfDay);
    return history.isNotEmpty ? history.first : null;
  }
  
  // Get check-in streak
  Future<int> getCheckInStreak(String userId) async {
    final db = await _dbManager.database;
    
    final results = await db.query(
      'mood_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
    
    if (results.isEmpty) return 0;
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final row in results) {
      final checkIn = MoodCheckIn.fromJson(row);
      final checkInDate = DateTime(
        checkIn.timestamp.year,
        checkIn.timestamp.month,
        checkIn.timestamp.day,
      );
      
      if (lastDate == null) {
        // First entry
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        
        if (checkInDate.isAtSameMomentAs(todayDate) ||
            checkInDate.isAtSameMomentAs(todayDate.subtract(const Duration(days: 1)))) {
          streak = 1;
          lastDate = checkInDate;
        } else {
          break;
        }
      } else {
        // Check if consecutive day
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (checkInDate.isAtSameMomentAs(expectedDate)) {
          streak++;
          lastDate = checkInDate;
        } else {
          break;
        }
      }
    }
    
    return streak;
  }
  
  // Update activity statistics
  Future<void> _updateActivityStats(String userId) async {
    final db = await _dbManager.database;
    
    final count = await db.rawQuery(
      'SELECT COUNT(*) as count FROM mood_entries WHERE userId = ?',
      [userId],
    );
    
    final moodCount = count.first['count'] as int;
    
    await db.rawInsert('''
      INSERT OR REPLACE INTO activity_statistics (id, userId, moodCheckInsCount, lastUpdated)
      VALUES (?, ?, ?, ?)
    ''', [userId, userId, moodCount, DateTime.now().toIso8601String()]);
  }
}
