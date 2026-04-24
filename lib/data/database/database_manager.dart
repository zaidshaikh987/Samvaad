// lib/data/database/database_manager.dart
// SQLite database manager with encryption support

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  static Database? _database;
  
  factory DatabaseManager() => _instance;
  
  DatabaseManager._internal();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    // Initialize web database factory if on web
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    
    String path;
    
    if (kIsWeb) {
      // For web, use a real string path so sqflite uses IndexedDB and data persists across reloads!
      path = 'samvaad_web_persistent.db';
    } else {
      // For mobile/desktop, use app documents directory
      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'samvaad.db');
    }
    
    try {
      return await openDatabase(
        path,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      // Final fallback if the web worker fundamentally fails to instantiate
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase('samvaad_web_persistent_fallback.db', options: OpenDatabaseOptions(
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ));
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        emailHash TEXT,
        password TEXT,
        birthdate TEXT,
        gender TEXT,
        primaryGoal TEXT,
        profilePhotoPath TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isEmailVerified INTEGER DEFAULT 0,
        isProfessional INTEGER DEFAULT 0,
        professionalType TEXT,
        verificationStatus TEXT
      )
    ''');
    
    // Mood entries table
    await db.execute('''
      CREATE TABLE mood_entries (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        mood TEXT NOT NULL,
        reflectionNotes TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    // Journal entries table
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT,
        content TEXT NOT NULL,
        mood TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    // Chat messages table
    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        botType TEXT NOT NULL,
        sender TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    // Documents table
    await db.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        documentType TEXT NOT NULL,
        filePath TEXT NOT NULL,
        fileName TEXT NOT NULL,
        fileSize INTEGER NOT NULL,
        uploadedAt TEXT NOT NULL,
        isEncrypted INTEGER DEFAULT 1,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(userId, key)
      )
    ''');
    
    // OTP records table
    await db.execute('''
      CREATE TABLE otp_records (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        otpHash TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        isUsed INTEGER DEFAULT 0,
        resendCount INTEGER DEFAULT 0
      )
    ''');
    
    // Activity statistics table
    await db.execute('''
      CREATE TABLE activity_statistics (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        journalEntriesCount INTEGER DEFAULT 0,
        aiChatSessionsCount INTEGER DEFAULT 0,
        moodCheckInsCount INTEGER DEFAULT 0,
        communityPostsCount INTEGER DEFAULT 0,
        lastUpdated TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_mood_entries_userId ON mood_entries(userId)');
    await db.execute('CREATE INDEX idx_mood_entries_timestamp ON mood_entries(timestamp)');
    await db.execute('CREATE INDEX idx_journal_entries_userId ON journal_entries(userId)');
    await db.execute('CREATE INDEX idx_chat_messages_userId ON chat_messages(userId)');
    await db.execute('CREATE INDEX idx_otp_records_email ON otp_records(email)');
    await db.execute('CREATE INDEX idx_users_emailHash ON users(emailHash)');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN password TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE users ADD COLUMN emailHash TEXT');
      await db.execute('CREATE INDEX idx_users_emailHash ON users(emailHash)');
    }
  }
  
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
  
  // Transaction support
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }
  
  // Clear all data (for testing or logout)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('mood_entries');
    await db.delete('journal_entries');
    await db.delete('chat_messages');
    await db.delete('documents');
    await db.delete('settings');
    await db.delete('otp_records');
    await db.delete('activity_statistics');
  }
}
