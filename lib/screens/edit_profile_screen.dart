import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/data/repositories/user_repository.dart';
import 'package:samvaad/data/models/user.dart';
import 'package:samvaad/services/file_upload_service.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit-profile';
  final String? userId;
  
  const EditProfileScreen({super.key, this.userId});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  final FileUploadService _fileUploadService = FileUploadService();
  
  User? _currentUser;
  bool _isLoading = true;
  String? _profilePhotoPath;
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _dateController;
  
  String? _selectedGender;
  String? _selectedGoal;

  final List<String> genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final List<String> goals = ['Managing Anxiety', 'Improving Sleep', 'Building Resilience', 'Stress Reduction'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _dateController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // In a real app, get userId from auth service
      final userId = widget.userId ?? 'demo-user-id';
      final user = await _userRepository.getUserById(userId);
      
      if (user != null) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.name;
          _emailController.text = user.email;
          _dateController.text = user.birthdate != null 
              ? '${user.birthdate!.day.toString().padLeft(2, '0')}-${user.birthdate!.month.toString().padLeft(2, '0')}-${user.birthdate!.year}'
              : '';
          _selectedGender = user.gender;
          _profilePhotoPath = user.profilePhotoPath;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentUser?.birthdate ?? DateTime(1998, 5, 15),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  Future<void> _changePhoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                await _uploadPhoto(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _uploadPhoto(fromCamera: false);
              },
            ),
            if (_profilePhotoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _profilePhotoPath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadPhoto({required bool fromCamera}) async {
    try {
      final photoPath = await _fileUploadService.uploadProfilePhoto(
        fromCamera: fromCamera,
      );
      
      if (photoPath != null) {
        setState(() => _profilePhotoPath = photoPath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo uploaded successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading photo: $e')),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_currentUser == null) return;

    try {
      // Parse birthdate from DD-MM-YYYY format
      DateTime? birthdate;
      if (_dateController.text.isNotEmpty) {
        final parts = _dateController.text.split('-');
        if (parts.length == 3) {
          birthdate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }

      final updatedUser = _currentUser!.copyWith(
        name: _nameController.text,
        birthdate: birthdate,
        gender: _selectedGender,
        profilePhotoPath: _profilePhotoPath,
      );

      await _userRepository.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Profile Updated Successfully!'),
              ],
            ),
            backgroundColor: AppColors.calm,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Profile Picture and Change Photo Link
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _changePhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.accent,
                          backgroundImage: _profilePhotoPath != null
                              ? FileImage(File(_profilePhotoPath!))
                              : null,
                          child: _profilePhotoPath == null
                              ? const Icon(Icons.person, color: Colors.white, size: 50)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  TextButton(
                    onPressed: _changePhoto,
                    child: const Text(
                      'Change Photo',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),

            // Display Name
            _buildInputField('Display Name', _nameController),
            const SizedBox(height: 20.0),

            // Email (read-only)
            _buildInputField('Email', _emailController, isReadOnly: true),
            const SizedBox(height: 20.0),

            // Date of Birth
            _buildDateField(context),
            const SizedBox(height: 20.0),

            // Gender Dropdown
            _buildDropdownField('Gender', _selectedGender, genders, (String? newValue) {
              setState(() => _selectedGender = newValue);
            }),
            const SizedBox(height: 20.0),

            // Primary Goal Dropdown
            _buildDropdownField('Primary Goal', _selectedGoal, goals, (String? newValue) {
              setState(() => _selectedGoal = newValue);
            }),
            const SizedBox(height: 40.0),

            // Save Changes Button
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          style: TextStyle(color: isReadOnly ? AppColors.greyText : AppColors.darkText),
          decoration: InputDecoration(
            fillColor: isReadOnly ? AppColors.lightGrey : AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: () => _selectDate(context),
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.greyText),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? selectedValue, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8.0),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: const InputDecoration(),
          hint: Text(items.first),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.greyText),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}
