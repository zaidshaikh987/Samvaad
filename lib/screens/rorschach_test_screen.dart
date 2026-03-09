import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';

class RorschachTestScreen extends StatelessWidget {
  static const String routeName = '/rorschach-test';
  const RorschachTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rorschach Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'What do you see in this image?',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 24.0),

            // Image Placeholder (The Star in the video)
            Center(
              child: Container(
                width: 250,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: AppColors.lightGrey, width: 1),
                ),
                child: const Center(
                  child: Icon(Icons.star, size: 150, color: AppColors.darkText),
                ),
              ),
            ),
            const SizedBox(height: 40.0),

            const Text(
              'Describe what you see in the image...',
              style: TextStyle(
                fontSize: 16.0,
                color: AppColors.darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              maxLines: 5,
              minLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your response...',
                filled: true,
                fillColor: AppColors.white,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40.0),

            ElevatedButton(
              onPressed: () {
                // Handle submission
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Response Submitted!')),
                );
              },
              child: const Text('Submit Response'),
            ),
          ],
        ),
      ),
    );
  }
}
