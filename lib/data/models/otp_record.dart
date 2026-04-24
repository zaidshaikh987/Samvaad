// lib/data/models/otp_record.dart
// OTP record data model

class OTPRecord {
  final String id;
  final String email;
  final String otpHash; // SHA-256 hashed OTP
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;
  final int resendCount;
  
  OTPRecord({
    required this.id,
    required this.email,
    required this.otpHash,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
    this.resendCount = 0,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isUsed && !isExpired;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'otpHash': otpHash,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isUsed': isUsed ? 1 : 0,
      'resendCount': resendCount,
    };
  }
  
  factory OTPRecord.fromJson(Map<String, dynamic> json) {
    return OTPRecord(
      id: json['id'] as String,
      email: json['email'] as String,
      otpHash: json['otpHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      isUsed: (json['isUsed'] as int) == 1,
      resendCount: json['resendCount'] as int,
    );
  }
}
