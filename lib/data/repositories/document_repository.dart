import 'package:sqflite/sqflite.dart';
import '../database/database_manager.dart';
import '../models/document.dart';

/// Repository for managing professional verification documents
class DocumentRepository {
  final DatabaseManager _dbManager = DatabaseManager();

  /// Save a new document
  Future<int> saveDocument(Document document) async {
    final db = await _dbManager.database;
    return await db.insert(
      'documents',
      document.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all documents for a user
  Future<List<Document>> getDocumentsByUserId(String userId) async {
    final db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'uploadedAt DESC',
    );

    return List.generate(maps.length, (i) => Document.fromJson(maps[i]));
  }

  /// Get documents by type for a user
  Future<List<Document>> getDocumentsByType(
      String userId, String documentType) async {
    final db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      where: 'userId = ? AND documentType = ?',
      whereArgs: [userId, documentType],
      orderBy: 'uploadedAt DESC',
    );

    return List.generate(maps.length, (i) => Document.fromJson(maps[i]));
  }

  /// Get a document by ID
  Future<Document?> getDocumentById(String documentId) async {
    final db = await _dbManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [documentId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Document.fromJson(maps.first);
  }

  /// Update document verification status
  Future<int> updateVerificationStatus(
      String documentId, String status) async {
    final db = await _dbManager.database;
    return await db.update(
      'documents',
      {'verificationStatus': status},
      where: 'id = ?',
      whereArgs: [documentId],
    );
  }

  /// Delete a document
  Future<int> deleteDocument(String documentId) async {
    final db = await _dbManager.database;
    return await db.delete(
      'documents',
      where: 'id = ?',
      whereArgs: [documentId],
    );
  }

  /// Check if user has uploaded all required documents
  Future<bool> hasAllRequiredDocuments(String userId) async {
    final requiredTypes = ['license', 'degree', 'id_proof'];
    for (final type in requiredTypes) {
      final docs = await getDocumentsByType(userId, type);
      if (docs.isEmpty) return false;
    }
    return true;
  }

  /// Get verification status summary for a user
  Future<Map<String, dynamic>> getVerificationSummary(String userId) async {
    final docs = await getDocumentsByUserId(userId);
    final pending = docs.where((d) => d.verificationStatus == 'pending').length;
    final approved =
        docs.where((d) => d.verificationStatus == 'approved').length;
    final rejected =
        docs.where((d) => d.verificationStatus == 'rejected').length;

    return {
      'total': docs.length,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'hasAllRequired': await hasAllRequiredDocuments(userId),
    };
  }
}
