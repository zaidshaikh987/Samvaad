import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';

class CreatePostScreen extends StatefulWidget {
  static const String routeName = '/create-post';
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String selectedCategory = 'General';
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Anonymous Post'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Category Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: <String>['General', 'Anxiety & Depression', 'Relationship Issues', 'Financial Stress']
                      .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedCategory = val!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Input Field
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "What's on your mind? Post anonymously...",
                  border: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Handle logic to save post
                Navigator.pop(context);
              },
              child: const Text('Post Anonymously'),
            ),
          ],
        ),
      ),
    );
  }
}