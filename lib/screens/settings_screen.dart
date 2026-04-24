// lib/screens/settings_screen.dart
// Fully stateful settings — all toggles persist via SharedPreferences,
// language switcher, HuggingFace API key config, and working logout.

import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/utils/translations.dart';
import 'package:samvaad/services/user_session.dart';
import 'package:samvaad/utils/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Toggle states
  bool _dailyReminders = true;
  bool _moodCheckins = true;
  bool _communityUpdates = true;
  bool _anonymousMode = false;
  bool _dataAnalytics = true;



  // Language
  String _selectedLocale = 'en';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }



  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyReminders = prefs.getBool('notif_daily') ?? true;
      _moodCheckins = prefs.getBool('notif_mood') ?? true;
      _communityUpdates = prefs.getBool('notif_community') ?? true;
      _anonymousMode = prefs.getBool('priv_anonymous') ?? false;
      _dataAnalytics = prefs.getBool('priv_analytics') ?? true;
      _selectedLocale = prefs.getString('app_locale') ?? 'en';

      _isLoading = false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }



  Future<void> _changeLanguage(String locale) async {
    setState(() => _selectedLocale = locale);
    await AppTranslations().setLocale(locale);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            locale == 'en'
                ? 'Language changed to English'
                : locale == 'hi'
                    ? 'भाषा हिंदी में बदली गई'
                    : 'भाषा मराठीत बदलली',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await UserSession().clearSession();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.welcomeScreen,
          (r) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
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
          children: [
            // ─── NOTIFICATIONS ───
            _buildSectionTitle(
                Icons.notifications_outlined, 'Notifications'),
            _buildToggle(
              'Daily Reminders',
              'Get reminded to journal',
              _dailyReminders,
              (v) {
                setState(() => _dailyReminders = v);
                _saveBool('notif_daily', v);
              },
            ),
            _buildToggle(
              'Mood Check-ins',
              'Track your mood daily',
              _moodCheckins,
              (v) {
                setState(() => _moodCheckins = v);
                _saveBool('notif_mood', v);
              },
            ),
            _buildToggle(
              'Community Updates',
              'New posts and comments',
              _communityUpdates,
              (v) {
                setState(() => _communityUpdates = v);
                _saveBool('notif_community', v);
              },
            ),

            const SizedBox(height: 20),

            // ─── LANGUAGE ───
            _buildSectionTitle(Icons.language_outlined, 'Language'),
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Language',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: AppTranslations.supportedLocales
                          .map((loc) => _buildLanguageChip(
                              loc['code']!,
                              loc['name']!,
                              loc['flag']!))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── PRIVACY ───
            _buildSectionTitle(Icons.privacy_tip_outlined, 'Privacy'),
            _buildToggle(
              'Anonymous Mode',
              'Hide your identity in community',
              _anonymousMode,
              (v) {
                setState(() => _anonymousMode = v);
                _saveBool('priv_anonymous', v);
              },
            ),
            _buildToggle(
              'Data Analytics',
              'Help improve Samvaad',
              _dataAnalytics,
              (v) {
                setState(() => _dataAnalytics = v);
                _saveBool('priv_analytics', v);
              },
            ),



            const SizedBox(height: 20),

            // ─── SECURITY ───
            _buildSectionTitle(Icons.security_outlined, 'Security'),
            _buildButtonTile('Change Password', Icons.lock_outline, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Password change coming soon!')),
              );
            }),
            _buildButtonTile(
                'Two-Factor Authentication', Icons.verified_user_outlined,
                () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('2FA feature coming soon!')),
              );
            }),

            const SizedBox(height: 30),

            // ─── LOG OUT ───
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Log Out',
                    style: TextStyle(fontSize: 16, color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4, left: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value,
      ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.greyText, fontSize: 12)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonTile(
      String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppColors.greyText),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageChip(String code, String name, String flag) {
    final isSelected = _selectedLocale == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeLanguage(code),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.15)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.lightGrey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color:
                      isSelected ? AppColors.primary : AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
