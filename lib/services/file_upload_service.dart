// lib/services/file_upload_service.dart
// File upload service for images and documents

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:samvaad/services/encryption_service.dart';
import 'package:samvaad/utils/constants.dart';
import 'package:samvaad/utils/validators.dart';

enum DocumentType { license, degree, idProof, other }

class FileUploadService {
  final ImagePicker _imagePicker = ImagePicker();
  final EncryptionService _encryption = EncryptionService();
  
  // Upload profile photo
  Future<String?> uploadProfilePhoto({bool fromCamera = false}) async {
    try {
      // Pick image
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image == null) return null;
      
      // Crop image to 1:1 aspect ratio (skip on web due to compatibility issues)
      File imageFile;
      if (!kIsWeb) {
        final croppedFile = await _cropImage(image.path);
        if (croppedFile == null) return null;
        imageFile = File(croppedFile.path);
      } else {
        imageFile = File(image.path);
      }
      
      // Compress image
      final compressedFile = await compressImage(
        imageFile,
        AppConstants.maxImageSizeKB,
      );
      
      // Save to app directory
      final savedPath = await _saveFile(compressedFile, 'profile_photos');
      
      return savedPath;
    } catch (e) {
      print('Error uploading profile photo: $e');
      return null;
    }
  }
  
  // Crop image to 1:1 aspect ratio
  Future<CroppedFile?> _cropImage(String imagePath) async {
    return await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: Color(0xFF4361EE),
          toolbarWidgetColor: Color(0xFFFFFFFF),
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
  }
  
  // Compress image to target size
  Future<File> compressImage(File imageFile, int maxSizeKB) async {
    final fileSizeKB = await imageFile.length() ~/ 1024;
    
    if (fileSizeKB <= maxSizeKB) {
      return imageFile;
    }
    
    // Calculate quality to achieve target size
    int quality = 85;
    File compressedFile = imageFile;
    
    while (quality > 10) {
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        '${imageFile.path}_compressed.jpg',
        quality: quality,
      );
      
      if (result == null) break;
      
      compressedFile = File(result.path);
      final newSizeKB = await compressedFile.length() ~/ 1024;
      
      if (newSizeKB <= maxSizeKB) {
        break;
      }
      
      quality -= 10;
    }
    
    return compressedFile;
  }
  
  // Upload document
  Future<String?> uploadDocument(DocumentType type) async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.allowedDocumentFormats,
      );
      
      if (result == null || result.files.isEmpty) return null;
      
      final file = File(result.files.single.path!);
      
      // Validate file
      if (!await validateFile(file, FileType.custom)) {
        throw Exception('Invalid file format or size');
      }
      
      // Encrypt document
      final encryptedFile = await _encryptFile(file);
      
      // Save to app directory
      final savedPath = await _saveFile(
        encryptedFile,
        'documents/${type.name}',
      );
      
      return savedPath;
    } catch (e) {
      print('Error uploading document: $e');
      return null;
    }
  }
  
  // Encrypt file
  Future<File> _encryptFile(File file) async {
    final bytes = await file.readAsBytes();
    final encryptedBytes = await _encryption.encryptBytes(bytes);
    
    final tempDir = await getTemporaryDirectory();
    final encryptedFile = File('${tempDir.path}/${path.basename(file.path)}.enc');
    await encryptedFile.writeAsBytes(encryptedBytes);
    
    return encryptedFile;
  }
  
  // Decrypt file
  Future<Uint8List> decryptFile(String filePath) async {
    final file = File(filePath);
    final encryptedBytes = await file.readAsBytes();
    return await _encryption.decryptBytes(encryptedBytes);
  }
  
  // Save file to app directory
  Future<String> _saveFile(File file, String subdirectory) async {
    final appDir = await getApplicationDocumentsDirectory();
    final saveDir = Directory('${appDir.path}/$subdirectory');
    
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(file.path);
    final fileName = '$timestamp$extension';
    final savePath = '${saveDir.path}/$fileName';
    
    await file.copy(savePath);
    
    return savePath;
  }
  
  // Delete file
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
  
  // Validate file
  Future<bool> validateFile(File file, FileType type) async {
    // Check file size
    final fileSizeBytes = await file.length();
    final maxSizeBytes = type == FileType.image
        ? AppConstants.maxImageSizeKB * 1024
        : AppConstants.maxDocumentSizeMB * 1024 * 1024;
    
    if (!Validators.isValidFileSize(fileSizeBytes, maxSizeBytes)) {
      return false;
    }
    
    // Check file extension
    final fileName = path.basename(file.path);
    final allowedExtensions = type == FileType.image
        ? AppConstants.allowedImageFormats
        : AppConstants.allowedDocumentFormats;
    
    return Validators.isValidFileExtension(fileName, allowedExtensions);
  }
  
  // Get file size in KB
  Future<int> getFileSizeKB(String filePath) async {
    final file = File(filePath);
    final bytes = await file.length();
    return bytes ~/ 1024;
  }
  
  // Get file size in MB
  Future<double> getFileSizeMB(String filePath) async {
    final kb = await getFileSizeKB(filePath);
    return kb / 1024;
  }
}
