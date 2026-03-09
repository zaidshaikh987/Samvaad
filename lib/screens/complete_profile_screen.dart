// lib/screens/complete_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart'; //
import 'package:samvaad/utils/app_routes.dart'; //

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  String? _selectedGender;
  String? _selectedGoal;
  // ADDED: Controller to capture the Display Name
  final TextEditingController _displayNameController = TextEditingController();

  final List<String> _genders = ['Male', 'Female', 'Non-binary', 'Other', 'Prefer not to say'];
  final List<String> _goals = [
    'Managing Anxiety', 
    'Improving Sleep', 
    'Reducing Stress', 
    'Building Healthy Habits'
  ];
  
  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText), //
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Samvaad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Complete Your Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText, //
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Help us personalize your experience',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyText, //
              ),
            ),
            const SizedBox(height: 40),

            // Display Name Field
            const Text('Display Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField( // MODIFIED: Added controller
              controller: _displayNameController,
              decoration: const InputDecoration(
                hintText: 'How should we call you?',
              ),
            ),
            const SizedBox(height: 24),

            // Date of Birth Field
            const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'dd-mm-yyyy',
                suffixIcon: Icon(Icons.calendar_today, color: AppColors.greyText), //
              ),
            ),
            const SizedBox(height: 24),

            // Gender Dropdown
            const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                hintText: 'Select gender',
              ),
              items: _genders.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            ),
            const SizedBox(height: 24),

            // Primary Goal Dropdown
            const Text('What brings you here?', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGoal,
              decoration: const InputDecoration(
                hintText: 'Select your goal',
              ),
              items: _goals.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGoal = newValue;
                });
              },
            ),
            const SizedBox(height: 40),

            // Complete Setup Button
            ElevatedButton(
              onPressed: () {
                // MODIFIED: Pass the entered name to the main wrapper
                final userName = _displayNameController.text.trim();
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.mainWrapper,
                  arguments: userName.isNotEmpty ? userName : 'User', // Pass the captured name
                );
              },
              child: const Text('Complete Setup'),
            ),
          ],
        ),
      ),
    );
  }
}