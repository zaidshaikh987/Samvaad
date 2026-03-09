import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _selectedGender;
  String? _selectedGoal;
  TextEditingController _dateController = TextEditingController(text: '15-05-1998');

  final List<String> genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  final List<String> goals = ['Managing Anxiety', 'Improving Sleep', 'Building Resilience', 'Stress Reduction'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1998, 5, 15),
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

  @override
  Widget build(BuildContext context) {
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
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.accent,
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 12.0),
                  TextButton(
                    onPressed: () {
                      // Handle change photo action
                    },
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
            _buildInputField('Display Name', 'Alex Chen'),
            const SizedBox(height: 20.0),

            // Email (read-only)
            _buildInputField('Email', 'alex@email.com', isReadOnly: true),
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
              onPressed: () {
                // Handle saving changes
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile Updated!')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8.0),
        TextFormField(
          initialValue: hint,
          readOnly: isReadOnly,
          style: TextStyle(color: isReadOnly ? AppColors.greyText : AppColors.darkText),
          decoration: InputDecoration(
            hintText: hint,
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
