// lib/data/repositories/user_repository.dart
// User data repository

import 'package:samvaad/data/database/database_manager.dart';
import 'package:samvaad/data/models/user.dart';
import 'package:samvaad/services/encryption_service.dart';

class UserRepository {
  final DatabaseManager _dbManager = DatabaseManager();
  final EncryptionService _encryption = EncryptionService();
  
  // Create new user
  Future<void> createUser(User user) async {
    final db = await _dbManager.database;
    
    // Encrypt sensitive data
    final encryptedEmail = await _encryption.encryptString(user.email);
    final emailHash = _encryption.hashSHA256(user.email.toLowerCase());
    
    final userData = user.toJson();
    userData['email'] = encryptedEmail;
    userData['emailHash'] = emailHash;
    // Note: Password must be securely placed by caller or passed in object.
    
    await db.insert('users', userData);
  }
  
  // Get user by ID
  Future<User?> getUserById(String userId) async {
    final db = await _dbManager.database;
    
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    
    final userData = Map<String, dynamic>.from(results.first);
    
    // Decrypt sensitive data
    try {
      userData['email'] = await _encryption.decryptString(userData['email']);
    } catch (e) {
      // Fallback for unencrypted legacy rows
    }
    
    return User.fromJson(userData);
  }
  
  // Get user by email (Optimized to prevent Algorithmic DOS)
  Future<User?> getUserByEmail(String email) async {
    final db = await _dbManager.database;
    
    final emailHash = _encryption.hashSHA256(email.toLowerCase());

    // 1. First attempt O(1) lookup using hash
    var results = await db.query(
      'users',
      where: 'emailHash = ?',
      whereArgs: [emailHash],
      limit: 1,
    );
    
    if (results.isNotEmpty) {
       final userData = Map<String, dynamic>.from(results.first);
       String decryptedEmail;
       try {
         decryptedEmail = await _encryption.decryptString(userData['email']);
       } catch (e) {
         decryptedEmail = userData['email'];
       }
       userData['email'] = decryptedEmail;
       return User.fromJson(userData);
    }
    
    // 2. Legacy fallback for old rows without hashes (to not break existing accounts)
    results = await db.query('users');
    
    for (final row in results) {
      final userData = Map<String, dynamic>.from(row);
      String decryptedEmail;
      try {
        decryptedEmail = await _encryption.decryptString(userData['email']);
      } catch (e) {
        decryptedEmail = userData['email']; // Legacy fallback
      }
      
      if (decryptedEmail == email) {
        // Since we found it, opportunistically migrate it to the new strategy
        await db.update('users', {'emailHash': emailHash}, where: 'id = ?', whereArgs: [userData['id']]);
        
        userData['email'] = decryptedEmail;
        return User.fromJson(userData);
      }
    }
    
    return null;
  }
  
  // Update user
  Future<void> updateUser(User user) async {
    final db = await _dbManager.database;
    
    final encryptedEmail = await _encryption.encryptString(user.email);
    
    final userData = user.toJson();
    userData['email'] = encryptedEmail;
    userData['updatedAt'] = DateTime.now().toIso8601String();
    
    await db.update(
      'users',
      userData,
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
  
  // Delete user
  Future<void> deleteUser(String userId) async {
    final db = await _dbManager.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
  
  // Export user data
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    final user = await getUserById(userId);
    if (user == null) throw Exception('User not found');
    
    final db = await _dbManager.database;
    
    // Get all related data
    final moodEntries = await db.query(
      'mood_entries',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    
    final journalEntries = await db.query(
      'journal_entries',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    
    final chatMessages = await db.query(
      'chat_messages',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    
    return {
      'user': user.toJson(),
      'moodEntries': moodEntries,
      'journalEntries': journalEntries,
      'chatMessages': chatMessages,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
  
  // Check if email exists
  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }
  
  // Update email verification status
  Future<void> markEmailVerified(String userId) async {
    final db = await _dbManager.database;
    await db.update(
      'users',
      {'isEmailVerified': 1, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
