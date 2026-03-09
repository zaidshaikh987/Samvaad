import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/pages/dashboard_page.dart'; // Reusing MoodPill from dashboard

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

          // Journal Prompt
          const Text(
            'How was your day?',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16.0),

          // Text Area for Journaling
          TextFormField(
            maxLines: 10,
            minLines: 5,
            decoration: const InputDecoration(
              hintText:
                  'Write about your thoughts, feelings, or anything on your mind...',
              filled: true,
              fillColor: AppColors.white,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 40.0),

          // Mood Tracker Section
          const Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16.0),

          // Mood Selection
          _buildMoodSelectionRow(),
          const SizedBox(height: 40.0),

          // Save Entry Button
          ElevatedButton(
            onPressed: () {
              // Handle saving the journal entry
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Journal Entry Saved!')),
              );
            },
            child: const Text('Save Entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelectionRow() {
    final List<Map<String, dynamic>> moods = [
      {'label': 'Happy', 'emoji': '😊', 'color': AppColors.happy},
      {'label': 'Calm', 'emoji': '😌', 'color': AppColors.calm},
      {'label': 'Sad', 'emoji': '😥', 'color': AppColors.sad},
      {'label': 'Anxious', 'emoji': '😟', 'color': AppColors.anxious},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          moods.map((mood) {
            bool isSelected = _selectedMood == mood['label'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedMood = mood['label'];
                });
              },
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                // Update _buildMoodSelectionRow decoration
                decoration: BoxDecoration(
                  color: isSelected ? mood['color'] : AppColors.white,
                  borderRadius: BorderRadius.circular(
                    20.0,
                  ), // More rounded like the image
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(mood['emoji'], style: const TextStyle(fontSize: 32.0)),
                    const SizedBox(height: 4.0),
                    Text(
                      mood['label'],
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isSelected ? AppColors.primary : AppColors.darkText,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
