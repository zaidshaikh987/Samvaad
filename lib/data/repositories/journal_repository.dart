// lib/data/repositories/journal_repository.dart
// Handles all CRUD operations for journal_entries table

import 'package:samvaad/data/database/database_manager.dart';

class JournalEntry {
  final String id;
  final String userId;
  final String content;
  final String? mood;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.content,
    this.mood,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': null,
        'content': content,
        'mood': mood,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': createdAt.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        userId: json['userId'] as String,
        content: json['content'] as String,
        mood: json['mood'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class JournalRepository {
  final DatabaseManager _db = DatabaseManager();

  Future<void> saveEntry(JournalEntry entry) async {
    final db = await _db.database;
    await db.insert('journal_entries', entry.toJson());
  }

  Future<List<JournalEntry>> getEntries(String userId) async {
    final db = await _db.database;
    final results = await db.query(
      'journal_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return results.map((r) => JournalEntry.fromJson(r)).toList();
  }

  Future<int> getEntryCount(String userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM journal_entries WHERE userId = ?',
      [userId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<void> deleteEntry(String entryId) async {
    final db = await _db.database;
    await db.delete('journal_entries', where: 'id = ?', whereArgs: [entryId]);
  }
}
