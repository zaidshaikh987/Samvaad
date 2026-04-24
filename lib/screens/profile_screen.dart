// lib/screens/profile_screen.dart
// Enhanced — uses real UserSession, clickable avatar, mood graph, proper navigation

import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/edit_profile_screen.dart';
import 'package:samvaad/screens/settings_screen.dart';
import 'package:samvaad/screens/premium_screen.dart';
import 'package:samvaad/data/repositories/user_repository.dart';
import 'package:samvaad/data/repositories/mood_repository.dart';
import 'package:samvaad/data/repositories/journal_repository.dart';
import 'package:samvaad/data/models/user.dart';
import 'package:samvaad/data/models/mood_check_in.dart';
import 'package:samvaad/widgets/mood_graph_widget.dart';
import 'package:samvaad/services/user_session.dart';
import 'package:samvaad/data/database/database_manager.dart';
import 'package:samvaad/utils/app_routes.dart';
import 'dart:io';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  static const String routeName = '/profile';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepo = UserRepository();
  final MoodRepository _moodRepo = MoodRepository();
  final JournalRepository _journalRepo = JournalRepository();

  User? _currentUser;
  List<MoodCheckIn> _moodHistory = [];
  bool _isLoading = true;
  int _journalCount = 0;
  int _chatCount = 0;
  int _moodCheckCount = 0;
  int _checkInStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final userId = UserSession().userId;

      _currentUser = await _userRepo.getUserById(userId);

      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      _moodHistory = await _moodRepo.getMoodHistory(userId, startDate, endDate);

      _checkInStreak = await _moodRepo.getCheckInStreak(userId);
      _moodCheckCount = _moodHistory.length;

      // Real counts from database
      _journalCount = await _journalRepo.getEntryCount(userId);

      // Count AI chat messages from DB
      final db = await DatabaseManager().database;
      final chatResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM chat_messages WHERE userId = ?',
        [userId],
      );
      _chatCount = (chatResult.first['count'] as int?) ?? 0;
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of Samvaad?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.greyText)),
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
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = _currentUser ?? UserSession().currentUser;
    final displayName = user?.name ?? UserSession().userName;
    final displayEmail = user?.email ?? UserSession().userEmail;
    final age = user?.age;
    final gender = user?.gender;
    final goal = user?.primaryGoal;
    final photoPath = user?.profilePhotoPath;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Gradient AppBar with avatar
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () async {
                  await Navigator.of(context).pushNamed(EditProfileScreen.routeName);
                  _loadProfileData();
                },
                tooltip: 'Edit Profile',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Modern blurred mesh background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                  
                  // Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                    // Tappable avatar
                    GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).pushNamed(EditProfileScreen.routeName);
                        _loadProfileData();
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            backgroundImage: photoPath != null && File(photoPath).existsSync()
                                ? FileImage(File(photoPath))
                                : null,
                            child: photoPath == null
                                ? Text(
                                    displayName.isNotEmpty
                                        ? displayName.substring(0, 2).toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 14, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayEmail,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // User details card
                  _buildDetailsCard(age, gender, goal, user),

                  const SizedBox(height: 20),

                  // Streak banner
                  if (_checkInStreak > 0) _buildStreakBanner(),

                  if (_checkInStreak > 0) const SizedBox(height: 20),

                  // Activity stats
                  const Text(
                    'Activity Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActivityStat('$_journalCount', 'Journal\nEntries',
                          Icons.book_outlined),
                      _buildActivityStat(
                          '$_chatCount', 'AI\nChats', Icons.chat_bubble_outline),
                      _buildActivityStat('$_moodCheckCount', 'Mood\nChecks',
                          Icons.mood_outlined),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Mood history graph
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.show_chart, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Mood Tracking History',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _moodHistory.isEmpty
                            ? _buildEmptyMoodState()
                            : MoodGraphWidget(
                                moodHistory: _moodHistory,
                                onDateTap: (date) {},
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Divider
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // Navigation tiles
                  _buildProfileTile(
                    context,
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    color: AppColors.primary,
                    onTap: () async {
                      await Navigator.of(context).pushNamed(EditProfileScreen.routeName);
                      _loadProfileData();
                    },
                  ),
                  _buildProfileTile(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    color: AppColors.primary,
                    onTap: () => Navigator.of(context).pushNamed(SettingsScreen.routeName),
                  ),
                  _buildProfileTile(
                    context,
                    icon: Icons.workspace_premium_outlined,
                    title: 'Upgrade to Premium',
                    color: const Color(0xFFFF9800),
                    onTap: () => Navigator.of(context).pushNamed(PremiumScreen.routeName),
                  ),
                  _buildProfileTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Feedback',
                    color: AppColors.calm,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Help & Feedback'),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📧 Email: support@samvaad.app'),
                              SizedBox(height: 8),
                              Text('📞 Helpline: 9152987821 (iCall)'),
                              SizedBox(height: 8),
                              Text('🌐 Website: samvaad.app'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  _buildProfileTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Settings',
                    color: AppColors.secondary,
                    onTap: () => Navigator.of(context).pushNamed(SettingsScreen.routeName),
                  ),
                  _buildProfileTile(
                    context,
                    icon: Icons.logout,
                    title: 'Log Out',
                    color: Colors.red,
                    onTap: _logout,
                  ),

                  const SizedBox(height: 40),

                  // App version
                  Center(
                    child: Text(
                      'Samvaad v1.0.0 • Your wellness, your journey',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.greyText.withOpacity(0.7)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(int? age, String? gender, String? goal, User? user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDetailRow(Icons.cake_outlined, 'Age',
              age != null ? '$age years' : 'Not set'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.lightGrey, height: 1),
          ),
          _buildDetailRow(Icons.person_outline, 'Gender', gender ?? 'Not set'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.lightGrey, height: 1),
          ),
          _buildDetailRow(Icons.flag_outlined, 'Goal', goal ?? 'Not set'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.lightGrey, height: 1),
          ),
          _buildDetailRow(
            Icons.verified_outlined,
            'Member since',
            user != null
                ? '${user.daysSinceCreation} days ago'
                : 'New member',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Text(label,
            style: const TextStyle(color: AppColors.greyText, fontSize: 14)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.darkText)),
      ],
    );
  }

  Widget _buildStreakBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_checkInStreak-Day Streak!',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const Text(
                  'Keep up the great work!',
                  style: TextStyle(fontSize: 13, color: AppColors.greyText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMoodState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        children: [
          const Icon(Icons.mood_outlined, size: 48, color: AppColors.greyText),
          const SizedBox(height: 12),
          const Text(
            'No mood history yet',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          const SizedBox(height: 4),
          const Text(
            'Start tracking your mood from the Home screen',
            style: TextStyle(color: AppColors.greyText, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStat(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.darkText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.darkText,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: title == 'Log Out' ? Colors.red : AppColors.darkText,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: AppColors.greyText),
      onTap: onTap,
    );
  }
}
