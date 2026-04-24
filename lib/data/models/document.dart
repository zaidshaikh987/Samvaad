/// Model representing a professional verification document
class Document {
  final String id;
  final String userId;
  final String documentType; // 'license', 'degree', 'id_proof'
  final String filePath;
  final String fileName;
  final int fileSizeBytes;
  final String verificationStatus; // 'pending', 'approved', 'rejected'
  final DateTime uploadedAt;
  final String? rejectionReason;

  Document({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    this.verificationStatus = 'pending',
    required this.uploadedAt,
    this.rejectionReason,
  });

  /// Convert Document to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'documentType': documentType,
      'filePath': filePath,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'verificationStatus': verificationStatus,
      'uploadedAt': uploadedAt.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  /// Create Document from JSON
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      userId: json['userId'] as String,
      documentType: json['documentType'] as String,
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      verificationStatus: json['verificationStatus'] as String? ?? 'pending',
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  /// Create a copy with updated fields
  Document copyWith({
    String? id,
    String? userId,
    String? documentType,
    String? filePath,
    String? fileName,
    int? fileSizeBytes,
    String? verificationStatus,
    DateTime? uploadedAt,
    String? rejectionReason,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      documentType: documentType ?? this.documentType,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
