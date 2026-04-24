// lib/pages/Join_Pro.dart
// Professional registration with:
// - Profile photo upload (image_picker)
// - License document upload (file_picker)
// - Additional certificates upload
// - Full form validation and DB save

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/utils/app_routes.dart';
import 'package:samvaad/data/database/database_manager.dart';
import 'package:samvaad/services/user_session.dart';

class ProfessionalRegistrationPage extends StatefulWidget {
  static const String route = '/professional-registration';

  const ProfessionalRegistrationPage({super.key});

  @override
  State<ProfessionalRegistrationPage> createState() =>
      _ProfessionalRegistrationPageState();
}

class _ProfessionalRegistrationPageState
    extends State<ProfessionalRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  String _selectedProfType = 'Therapist';
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _yearsExpController = TextEditingController();
  final _licenseNoController = TextEditingController();
  final _bioController = TextEditingController();
  final _feeController = TextEditingController();

  String? _profilePhotoPath;
  String? _licenseDocPath;
  String? _licenseDocName;
  final List<Map<String, String>> _additionalDocs = [];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _yearsExpController.dispose();
    _licenseNoController.dispose();
    _bioController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  // ─── Photo upload ───────────────────────────────────────
  Future<void> _pickProfilePhoto() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _profilePhotoPath = picked.path);
    }
  }

  Future<void> _takeProfilePhoto() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _profilePhotoPath = picked.path);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickProfilePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _takeProfilePhoto();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── License document upload ──────────────────────────
  Future<void> _pickLicenseDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _licenseDocPath = result.files.first.path;
        _licenseDocName = result.files.first.name;
      });
    }
  }

  // ─── Additional documents upload ─────────────────────
  Future<void> _pickAdditionalDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _additionalDocs.add({
          'path': result.files.first.path ?? '',
          'name': result.files.first.name,
        });
      });
    }
  }

  // ─── Submit ───────────────────────────────────────────
  Future<void> _submitForReview() async {
    if (!_formKey.currentState!.validate()) return;

    if (_profilePhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your profile photo.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_licenseDocPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your license document.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final db = await DatabaseManager().database;
      final userId = UserSession().userId;
      final now = DateTime.now();

      // Save professional registration to DB
      await db.insert('documents', {
        'id': 'pro_${now.millisecondsSinceEpoch}',
        'userId': userId,
        'type': 'professional_registration',
        'name': 'Professional Registration - ${_nameController.text}',
        'filePath': _licenseDocPath,
        'description': _selectedProfType,
        'createdAt': now.toIso8601String(),
        'metadata': '{"name":"${_nameController.text}","type":"$_selectedProfType","specialty":"${_specialtyController.text}","licenseNo":"${_licenseNoController.text}","yearsExp":"${_yearsExpController.text}","fee":"${_feeController.text}","photo":"${_profilePhotoPath ?? ''}","status":"pending"}',
      });

      // Update user to professional status (pending)
      await db.update(
        'users',
        {
          'isProfessional': 0, // Will become 1 when approved
          'professionalType': _selectedProfType.toLowerCase(),
          'verificationStatus': 'pending',
          'updatedAt': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.calm.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline,
                      color: AppColors.calm, size: 64),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Application Submitted!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your professional registration is under review. We\'ll notify you within 2-3 business days.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.greyText, height: 1.4),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.mainWrapper,
                        (r) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error submitting: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Join as Professional'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium_outlined,
                        color: AppColors.primary, size: 32),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Professional Registration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Join 200+ mental health professionals',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.greyText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Profile Photo ───
              _buildSectionTitle('Profile Photo *'),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: _showPhotoOptions,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.lightGrey,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.4),
                            width: 2,
                          ),
                          image: _profilePhotoPath != null
                              ? DecorationImage(
                                  image: FileImage(File(_profilePhotoPath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _profilePhotoPath == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined,
                                      color: AppColors.greyText, size: 32),
                                  SizedBox(height: 4),
                                  Text(
                                    'Add Photo',
                                    style: TextStyle(
                                        color: AppColors.greyText,
                                        fontSize: 12),
                                  ),
                                ],
                              )
                            : null,
                      ),
                      if (_profilePhotoPath != null)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: _showPhotoOptions,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Professional Type ───
              _buildSectionTitle('Professional Type *'),
              const SizedBox(height: 12),
              Row(
                children: ['Therapist', 'Psychiatrist'].map((type) {
                  final isSelected = _selectedProfType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedProfType = type),
                      child: Container(
                        margin: EdgeInsets.only(
                            right: type == 'Therapist' ? 8 : 0),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.lightGrey,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              type == 'Therapist'
                                  ? Icons.psychology_outlined
                                  : Icons.local_hospital_outlined,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.greyText,
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              type,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ─── Form Fields ───
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Dr. Full Name',
                icon: Icons.person_outline,
                validator: (v) =>
                    v!.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _specialtyController,
                label: 'Specialty / Area of Expertise',
                hint: 'e.g. Anxiety, Depression, CBT',
                icon: Icons.star_outline,
                validator: (v) =>
                    v!.trim().isEmpty ? 'Specialty is required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _yearsExpController,
                      label: 'Years Experience',
                      hint: '5',
                      icon: Icons.work_history_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField(
                      controller: _feeController,
                      label: 'Session Fee (₹/hour)',
                      hint: '1500',
                      icon: Icons.currency_rupee_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _licenseNoController,
                label: 'License / Registration Number',
                hint: 'e.g. MCI-2024-XXXX',
                icon: Icons.badge_outlined,
                validator: (v) =>
                    v!.trim().isEmpty ? 'License number is required' : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _bioController,
                label: 'Professional Bio',
                hint:
                    'Tell clients about your background, approach, and specialties...',
                icon: Icons.article_outlined,
                maxLines: 4,
              ),

              const SizedBox(height: 24),

              // ─── License Document ───
              _buildSectionTitle('License Document *'),
              const SizedBox(height: 8),
              const Text(
                'Upload a clear scan/photo of your professional license or registration certificate.',
                style: TextStyle(color: AppColors.greyText, fontSize: 12),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickLicenseDocument,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _licenseDocPath != null
                          ? AppColors.calm
                          : AppColors.primary.withOpacity(0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _licenseDocPath != null
                      ? Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.calm.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.check_circle_outline,
                                  color: AppColors.calm),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Document Uploaded ✓',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.calm,
                                    ),
                                  ),
                                  Text(
                                    _licenseDocName ?? 'Document',
                                    style: const TextStyle(
                                        color: AppColors.greyText,
                                        fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh,
                                  color: AppColors.primary, size: 18),
                              onPressed: _pickLicenseDocument,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.upload_file_outlined,
                                  color: AppColors.primary, size: 32),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tap to Upload License',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'PDF, JPG, PNG, DOC up to 10MB',
                              style: TextStyle(
                                  color: AppColors.greyText, fontSize: 12),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // ─── Additional Documents ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Additional Certificates'),
                  TextButton.icon(
                    onPressed: _pickAdditionalDocument,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
                ],
              ),
              if (_additionalDocs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_circle_outline,
                          color: AppColors.greyText),
                      SizedBox(width: 12),
                      Text(
                        'Add degrees, certificates, etc.',
                        style: TextStyle(
                            color: AppColors.greyText, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ...(_additionalDocs.asMap().entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file_outlined,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value['name'] ?? 'Document',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 18),
                          onPressed: () => setState(
                              () => _additionalDocs.removeAt(entry.key)),
                        ),
                      ],
                    ),
                  );
                })),

              const SizedBox(height: 32),

              // ─── Submit Button ───
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForReview,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit for Review',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'By submitting, you agree to our professional verification terms.\n'
                  'We review all applications within 2-3 business days.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.greyText),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: AppColors.greyText, fontSize: 13),
              prefixIcon:
                  maxLines == 1 ? Icon(icon, color: AppColors.primary, size: 20) : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: maxLines > 1 ? 16 : 0,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}