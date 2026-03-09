import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/main_wrapper.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
            // Notifications
            const _SettingsSectionTitle(title: 'Notifications'),
            _buildToggleSetting(
              'Daily Reminders',
              'Get reminded to journal',
              true,
            ),
            _buildToggleSetting(
              'Mood Check-ins',
              'Track your mood daily',
              false,
            ),
            _buildToggleSetting(
              'Community Updates',
              'New posts and comments',
              true,
            ),
            const SizedBox(height: 20.0),

            // Privacy
            const _SettingsSectionTitle(title: 'Privacy'),
            _buildToggleSetting(
              'Anonymous Mode',
              'Hide your identity in community',
              true,
            ),
            _buildToggleSetting('Data Analytics', 'Help improve Samvaad', true),
            const SizedBox(height: 20.0),

            // Security
            const _SettingsSectionTitle(title: 'Security'),
            _buildButtonSetting('Change Password', () {}),
            _buildButtonSetting('Two-Factor Authentication', () {}),
            const SizedBox(height: 30.0),

            // Log Out Button
            SizedBox(
              width: double.infinity,

              // Simulate log out
              child: OutlinedButton(
                onPressed: () {
                  // Simulate log out
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    MainWrapper
                        .routeName, // This now correctly uses the static getter.
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('Log Out', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSetting(String title, String subtitle, bool initialValue) {
    // Note: In a real app, this should be a StatefulWidget to manage state.
    // Using a StatelessWidget wrapper for simplicity here.
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Switch(
              value: initialValue,
              onChanged: (bool newValue) {
                // Handle switch state change (requires StatefulWidget in a real scenario)
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSetting(String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16.0,
          color: AppColors.greyText,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  final String title;
  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
    );
  }
}
