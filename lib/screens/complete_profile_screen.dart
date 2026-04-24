// lib/screens/complete_profile_screen.dart
// Saves full profile to DB and registers user session on completion.

import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/utils/app_routes.dart';
import 'package:samvaad/data/database/database_manager.dart';
import 'package:samvaad/services/user_session.dart';
import 'package:samvaad/data/models/user.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  String? _selectedGender;
  String? _selectedGoal;
  DateTime? _selectedDate;
  bool _isLoading = false;

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final List<String> _genders = [
    'Male', 'Female', 'Non-binary', 'Other', 'Prefer not to say'
  ];
  final List<String> _goals = [
    'Managing Anxiety',
    'Improving Sleep',
    'Reducing Stress',
    'Building Healthy Habits',
    'Processing Grief',
    'Building Resilience',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill name from session if available
    _displayNameController.text = UserSession().userName == 'User'
        ? ''
        : UserSession().userName;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  Future<void> _completeSetup() async {
    final name = _displayNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your display name'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final session = UserSession();
      final userId = session.userId;

      // Update user in DB
      final db = await DatabaseManager().database;
      final now = DateTime.now();
      await db.update(
        'users',
        {
          'name': name,
          'birthdate': _selectedDate?.toIso8601String(),
          'gender': _selectedGender,
          'primaryGoal': _selectedGoal,
          'isEmailVerified': 1,
          'updatedAt': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      // Update session with full user object
      final updatedUser = User(
        id: userId,
        name: name,
        email: session.userEmail,
        birthdate: _selectedDate,
        gender: _selectedGender,
        primaryGoal: _selectedGoal,
        createdAt: now,
        updatedAt: now,
        isEmailVerified: true,
      );
      session.setUser(updatedUser);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.mainWrapper,
          arguments: name,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Samvaad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Complete Your Profile',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText),
            ),
            const SizedBox(height: 8),
            const Text(
              'Help us personalize your experience',
              style: TextStyle(fontSize: 16, color: AppColors.greyText),
            ),
            const SizedBox(height: 36),

            // Display Name
            _buildLabel('Display Name *'),
            const SizedBox(height: 8),
            _buildInputBox(
              child: TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  hintText: 'How should we call you?',
                  prefixIcon:
                      Icon(Icons.person_outline, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date of Birth
            _buildLabel('Date of Birth'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: _buildInputBox(
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'dd-mm-yyyy',
                    hintStyle: const TextStyle(color: AppColors.greyText),
                    prefixIcon: const Icon(Icons.cake_outlined,
                        color: AppColors.primary),
                    suffixIcon: const Icon(Icons.calendar_today_outlined,
                        color: AppColors.greyText, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Gender Dropdown
            _buildLabel('Gender'),
            const SizedBox(height: 8),
            _buildInputBox(
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                hint: const Text('Select gender',
                    style: TextStyle(color: AppColors.greyText)),
                isExpanded: true,
                items: _genders.map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
            ),
            const SizedBox(height: 20),

            // Primary Goal Dropdown
            _buildLabel('What brings you here?'),
            const SizedBox(height: 8),
            _buildInputBox(
              child: DropdownButtonFormField<String>(
                value: _selectedGoal,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                hint: const Text('Select your primary goal',
                    style: TextStyle(color: AppColors.greyText)),
                isExpanded: true,
                items: _goals.map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (v) => setState(() => _selectedGoal = v),
              ),
            ),
            const SizedBox(height: 40),

            // Complete Setup Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _completeSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Complete Setup',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText));
  }

  Widget _buildInputBox({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}