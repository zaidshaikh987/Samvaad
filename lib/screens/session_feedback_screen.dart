import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/main_wrapper.dart';

class SessionFeedbackScreen extends StatefulWidget {
  static const String routeName = '/session-feedback';
  const SessionFeedbackScreen({super.key});

  @override
  State<SessionFeedbackScreen> createState() => _SessionFeedbackScreenState();
}

class _SessionFeedbackScreenState extends State<SessionFeedbackScreen> {
  int _rating = 0;
  bool _sessionHelpful = false;
  bool _recommendProfessional = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Feedback'),
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
            const Text(
              'Help us improve your experience',
              style: TextStyle(
                fontSize: 16.0,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 30.0),

            const Text(
              'Rate Your Session',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildStarRating(),
            const SizedBox(height: 40.0),

            const Text(
              'Additional Feedback',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              maxLines: 5,
              minLines: 3,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts about the session...',
                filled: true,
                fillColor: AppColors.white,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 30.0),

            // Checkbox 1
            _buildCheckboxTile(
              label: 'The session was helpful',
              value: _sessionHelpful,
              onChanged: (bool? newValue) {
                setState(() => _sessionHelpful = newValue ?? false);
              },
            ),
            // Checkbox 2
            _buildCheckboxTile(
              label: 'Would recommend this professional',
              value: _recommendProfessional,
              onChanged: (bool? newValue) {
                setState(() => _recommendProfessional = newValue ?? false);
              },
            ),

            const SizedBox(height: 40.0),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Handle submission
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feedback Submitted!')),
                );
                Navigator.of(context).popUntil(ModalRoute.withName(MainWrapper.routeName));
              },
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: AppColors.happy,
            size: 40,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
        );
      }),
    );
  }

  Widget _buildCheckboxTile({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
