// lib/data/models/user.dart
// User data model

class User {
  final String id;
  final String name;
  final String email;
  final DateTime? birthdate;
  final String? gender;
  final String? primaryGoal;
  final String? profilePhotoPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final bool isProfessional;
  final String? professionalType; // 'therapist' or 'psychiatrist'
  final String? verificationStatus; // 'pending', 'verified', 'rejected'
  
  User({
    required this.id,
    required this.name,
    required this.email,
    this.birthdate,
    this.gender,
    this.primaryGoal,
    this.profilePhotoPath,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.isProfessional = false,
    this.professionalType,
    this.verificationStatus,
  });
  
  // Calculate age
  int? get age {
    if (birthdate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthdate!.year;
    if (now.month < birthdate!.month ||
        (now.month == birthdate!.month && now.day < birthdate!.day)) {
      age--;
    }
    return age;
  }
  
  // Days since account creation
  int get daysSinceCreation {
    return DateTime.now().difference(createdAt).inDays;
  }
  
  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birthdate': birthdate?.toIso8601String(),
      'gender': gender,
      'primaryGoal': primaryGoal,
      'profilePhotoPath': profilePhotoPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEmailVerified': isEmailVerified ? 1 : 0,
      'isProfessional': isProfessional ? 1 : 0,
      'professionalType': professionalType,
      'verificationStatus': verificationStatus,
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'] as String)
          : null,
      gender: json['gender'] as String?,
      primaryGoal: json['primary Goal'] as String?,
      profilePhotoPath: json['profilePhotoPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isEmailVerified: (json['isEmailVerified'] as int) == 1,
      isProfessional: (json['isProfessional'] as int) == 1,
      professionalType: json['professionalType'] as String?,
      verificationStatus: json['verificationStatus'] as String?,
    );
  }
  
  // Copy with method for updates
  User copyWith({
    String? name,
    String? email,
    DateTime? birthdate,
    String? gender,
    String? primaryGoal,
    String? profilePhotoPath,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isProfessional,
    String? professionalType,
    String? verificationStatus,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProfessional: isProfessional ?? this.isProfessional,
      professionalType: professionalType ?? this.professionalType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}
