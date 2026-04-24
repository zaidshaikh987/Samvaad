// lib/services/otp_service.dart
// OTP generation and validation service

import 'dart:math';
import 'package:samvaad/data/database/database_manager.dart';
import 'package:samvaad/data/models/otp_record.dart';
import 'package:samvaad/services/encryption_service.dart';
import 'package:samvaad/services/email_service.dart';
import 'package:samvaad/utils/constants.dart';

class OTPService {
  final DatabaseManager _dbManager = DatabaseManager();
  final EncryptionService _encryption = EncryptionService();
  final EmailService _emailService = EmailService();
  
  // Generate 6-digit OTP
  String _generateOTP() {
    final random = Random.secure();
    final otp = random.nextInt(900000) + 100000; // 100000 to 999999
    return otp.toString();
  }
  
  // Generate and send OTP
  Future<bool> generateAndSendOTP(String email) async {
    // Check rate limiting
    if (!await canResendOTP(email)) {
      throw Exception('Too many OTP requests. Please wait before trying again.');
    }
    
    // Generate OTP
    final otp = _generateOTP();
    final otpHash = _encryption.hashSHA256(otp);
    
    // Create OTP record
    final record = OTPRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      otpHash: otpHash,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(
        Duration(minutes: AppConstants.otpExpirationMinutes),
      ),
    );
    
    // Save to database
    final db = await _dbManager.database;
    await db.insert('otp_records', record.toJson());
    
    // Send email
    try {
      await _emailService.sendOTPEmail(email, otp);
      return true;
    } catch (e) {
      print('Failed to send OTP email: $e');
      return false;
    }
  }
  
  // Validate OTP
  Future<bool> validateOTP(String email, String otp) async {
    final db = await _dbManager.database;
    
    // Get latest OTP record for email
    final results = await db.query(
      'otp_records',
      where: 'email = ? AND isUsed = 0',
      whereArgs: [email],
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    
    if (results.isEmpty) return false;
    
    final record = OTPRecord.fromJson(results.first);
    
    // Check if expired
    if (record.isExpired) {
      return false;
    }
    
    // Validate OTP
    final otpHash = _encryption.hashSHA256(otp);
    if (otpHash != record.otpHash) {
      return false;
    }
    
    // Mark as used
    await db.update(
      'otp_records',
      {'isUsed': 1},
      where: 'id = ?',
      whereArgs: [record.id],
    );
    
    return true;
  }
  
  // Check if can resend OTP (rate limiting)
  Future<bool> canResendOTP(String email) async {
    final db = await _dbManager.database;
    
    final cutoffTime = DateTime.now().subtract(
      Duration(minutes: AppConstants.otpResendCooldownMinutes),
    );
    
    final results = await db.query(
      'otp_records',
      where: 'email = ? AND createdAt >= ?',
      whereArgs: [email, cutoffTime.toIso8601String()],
    );
    
    return results.length < AppConstants.otpMaxResendAttempts;
  }
  
  // Get remaining cooldown time
  Future<Duration?> getRemainingCooldown(String email) async {
    final db = await _dbManager.database;
    
    final cutoffTime = DateTime.now().subtract(
      Duration(minutes: AppConstants.otpResendCooldownMinutes),
    );
    
    final results = await db.query(
      'otp_records',
      where: 'email = ? AND createdAt >= ?',
      whereArgs: [email, cutoffTime.toIso8601String()],
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    
    final record = OTPRecord.fromJson(results.first);
    final cooldownEnd = record.createdAt.add(
      Duration(minutes: AppConstants.otpResendCooldownMinutes),
    );
    
    final remaining = cooldownEnd.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
  
  // Invalidate all OTPs for email
  Future<void> invalidateOTPs(String email) async {
    final db = await _dbManager.database;
    await db.update(
      'otp_records',
      {'isUsed': 1},
      where: 'email = ?',
      whereArgs: [email],
    );
  }
  
  // Clean up expired OTPs
  Future<void> cleanupExpiredOTPs() async {
    final db = await _dbManager.database;
    await db.delete(
      'otp_records',
      where: 'expiresAt < ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
  }
}
