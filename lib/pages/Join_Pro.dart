import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';

class ProfessionalRegistrationPage extends StatefulWidget {
  // Added the route getter so it can be accessed from DashboardPage
  static const String route = '/professional-registration';

  const ProfessionalRegistrationPage({super.key});

  @override
  State<ProfessionalRegistrationPage> createState() =>
      _ProfessionalRegistrationPageState();
}

class _ProfessionalRegistrationPageState
    extends State<ProfessionalRegistrationPage> {
  String selectedType = 'Therapist';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: AppColors.darkText),
        title: const Text(
          'Samvaad',
          style: TextStyle(color: AppColors.darkText),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Professional Registration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Professional Type",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTypeButton("Therapist"),
                      const SizedBox(width: 12),
                      _buildTypeButton("Psychiatrist"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildLabelledField("Full Name", "Dr. Jane Smith"),
                  _buildLabelledField(
                    "Specialty",
                    "e.g., Anxiety & Depression",
                  ),
                  _buildLabelledField("Years of Experience", "10"),
                  _buildLabelledField("License Number", "PSY12345"),

                  const Text(
                    "License Document",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildUploadBox(),

                  _buildLabelledField(
                    "Professional Bio",
                    "Tell us about your experience...",
                    maxLines: 3,
                  ),
                  _buildLabelledField("Session Fee (per hour)", "80"),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.darkText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Submit for Review",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label) {
    bool isSelected = selectedType == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.secondary : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.darkText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelledField(String label, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.greyText,
                fontSize: 14,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.none,
        ),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          const Text(
            "Click to upload license",
            style: TextStyle(
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "PDF, JPG, PNG (Max 5MB)",
            style: TextStyle(
              color: AppColors.greyText.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}