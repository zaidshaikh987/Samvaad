import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';

class JournalPage extends StatefulWidget {
  static const String routeName = '/journal-entry';
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  String? _selectedMood;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 10.0),
          const Text(
            'How was your day?',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            maxLines: 8,
            minLines: 5,
            decoration: InputDecoration(
              hintText: 'Write about your thoughts, feelings, or anything on your mind...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 40.0),
          const Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 20.0),
          _buildMoodSelection(),
          const SizedBox(height: 40.0),
          ElevatedButton(
            onPressed: () {
              if (_selectedMood == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a mood first')),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Journal Entry Saved!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Save Entry', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

 Widget _buildMoodSelection() {
  final List<Map<String, dynamic>> moods = [
    {'label': 'Happy', 'image': 'assets/images/smile.jpeg', 'color': AppColors.happy},
    {'label': 'Calm', 'image': 'assets/images/cry.jpeg', 'color': AppColors.calm},
    {'label': 'Sad', 'image': 'assets/images/sad.jpeg', 'color': AppColors.sad},
    {'label': 'Anxious', 'image': 'assets/images/angry.jpeg', 'color': AppColors.anxious},
  ];

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: moods.map((mood) {
      bool isSelected = _selectedMood == mood['label'];
      return GestureDetector(
        onTap: () => setState(() => _selectedMood = mood['label'] as String),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              height: 70,
              padding: EdgeInsets.all(isSelected ? 3 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? mood['color'] as Color : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // REMOVED 'const' from here because withValues is dynamic
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(mood['image'] as String),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              mood['label'] as String,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? AppColors.darkText : AppColors.greyText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}
}