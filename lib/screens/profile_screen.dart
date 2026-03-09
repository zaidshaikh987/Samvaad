import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/edit_profile_screen.dart';
import 'package:samvaad/screens/settings_screen.dart';
import 'package:samvaad/screens/premium_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const String routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.accent,
                      child: Text('AC', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12.0),
                    const Text('Alex Chen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4.0),
                    const Text('alex@email.com', style: TextStyle(color: AppColors.greyText)),
                    const SizedBox(height: 8.0),
                    const Text('Level 5 • 520 XP', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30.0),

            // This Week's Activity
            const Text(
              'This Week\'s Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActivityStat('7', 'Journal\nEntries'),
                _buildActivityStat('5', 'AI\nChats'),
                _buildActivityStat('12', 'Mood\nChecks'),
              ],
            ),
            const SizedBox(height: 30.0),

            // Navigation Links
            _buildProfileTile(
              context,
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () => Navigator.of(context).pushNamed(EditProfileScreen.routeName),
            ),
            _buildProfileTile(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => Navigator.of(context).pushNamed(SettingsScreen.routeName),
            ),
            _buildProfileTile(
              context,
              icon: Icons.workspace_premium_outlined,
              title: 'Upgrade to Premium',
              onTap: () => Navigator.of(context).pushNamed(PremiumScreen.routeName),
            ),
            _buildProfileTile(
              context,
              icon: Icons.help_outline,
              title: 'Help & Feedback',
              onTap: () {
                // Navigate to Help & Feedback (reusing HelpPage logic for a new screen)
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.darkText),
        ),
      ],
    );
  }

  Widget _buildProfileTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkText),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.greyText),
          ],
        ),
      ),
    );
  }
}
