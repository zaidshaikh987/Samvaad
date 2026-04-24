// lib/services/encryption_service.dart
// AES-256-GCM encryption service for sensitive data

import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();
  
  final _secureStorage = const FlutterSecureStorage();
  static const String _keyStorageKey = 'encryption_master_key';
  
  encrypt.Key? _encryptionKey;
  
  // Initialize encryption key
  Future<void> initialize() async {
    String? storedKey = await _secureStorage.read(key: _keyStorageKey);
    
    if (storedKey == null) {
      // Generate new key
      final key = encrypt.Key.fromSecureRandom(32); // 256 bits
      await _secureStorage.write(
        key: _keyStorageKey,
        value: base64.encode(key.bytes),
      );
      _encryptionKey = key;
    } else {
      // Load existing key
      _encryptionKey = encrypt.Key(base64.decode(storedKey));
    }
  }
  
  // Encrypt string data
  Future<String> encryptString(String plaintext) async {
    if (_encryptionKey == null) await initialize();
    
    final iv = encrypt.IV.fromSecureRandom(16); // 128 bits
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.gcm),
    );
    
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    
    // Combine IV and encrypted data
    final combined = '${iv.base64}:${encrypted.base64}';
    return combined;
  }
  
  // Decrypt string data
  Future<String> decryptString(String ciphertext) async {
    if (_encryptionKey == null) await initialize();
    
    try {
      // Split IV and encrypted data
      final parts = ciphertext.split(':');
      if (parts.length != 2) throw Exception('Invalid ciphertext format');
      
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      
      final encrypter = encrypt.Encrypter(
        encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.gcm),
      );
      
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
  
  // Encrypt byte array (for files)
  Future<Uint8List> encryptBytes(Uint8List data) async {
    if (_encryptionKey == null) await initialize();
    
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.gcm),
    );
    
    final encrypted = encrypter.encryptBytes(data, iv: iv);
    
    // Prepend IV to encrypted data
    final result = Uint8List(iv.bytes.length + encrypted.bytes.length);
    result.setRange(0, iv.bytes.length, iv.bytes);
    result.setRange(iv.bytes.length, result.length, encrypted.bytes);
    
    return result;
  }
  
  // Decrypt byte array (for files)
  Future<Uint8List> decryptBytes(Uint8List data) async {
    if (_encryptionKey == null) await initialize();
    
    try {
      // Extract IV and encrypted data
      final iv = encrypt.IV(data.sublist(0, 16));
      final encryptedData = data.sublist(16);
      
      final encrypter = encrypt.Encrypter(
        encrypt.AES(_encryptionKey!, mode: encrypt.AESMode.gcm),
      );
      
      final encrypted = encrypt.Encrypted(encryptedData);
      return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
  
  // Hash data (for OTP storage)
  String hashSHA256(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Rotate encryption key
  Future<void> rotateKey() async {
    final newKey = encrypt.Key.fromSecureRandom(32);
    await _secureStorage.write(
      key: _keyStorageKey,
      value: base64.encode(newKey.bytes),
    );
    _encryptionKey = newKey;
  }
  
  // Clear encryption key (for logout)
  Future<void> clearKey() async {
    await _secureStorage.delete(key: _keyStorageKey);
    _encryptionKey = null;
  }
}
