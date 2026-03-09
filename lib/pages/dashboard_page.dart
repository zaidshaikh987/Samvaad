import 'package:flutter/material.dart';
import 'package:samvaad/screens/message_screen.dart';
import 'package:samvaad/screens/rorschach_test_screen.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/ai_reflections_screen.dart';
import 'package:samvaad/pages/Join_Pro.dart';

class DashboardPage extends StatelessWidget {
  final ValueChanged<int> onNavigateToTab;
  final String userName;

  const DashboardPage({
    super.key,
    required this.onNavigateToTab,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Good Morning, $userName',
            style: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 16.0,
              color: AppColors.greyText,
            ),
          ),
          const SizedBox(height: 20.0),
          _buildMoodSelection(),
          const SizedBox(height: 30.0),
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildQuickAccessGrid(context),
          const SizedBox(height: 30.0),
          const Text(
            'Explore',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildExploreGrid(context),
        ],
      ),
    );
  }

  Widget _buildMoodSelection() {
    final List<Map<String, dynamic>> moods = [
      {'label': 'Happy', 'emoji': '😊', 'color': AppColors.happy},
      {'label': 'Calm', 'emoji': '😌', 'color': AppColors.calm},
      {'label': 'Sad', 'emoji': '😥', 'color': AppColors.sad},
      {'label': 'Anxious', 'emoji': '😟', 'color': AppColors.anxious},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((mood) {
        return _MoodPill(
          emoji: mood['emoji'],
          label: mood['label'],
          color: mood['color'],
          onTap: () {},
        );
      }).toList(),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.2,
      children: [
        _buildQuickAccessCard(
          context,
          icon: Icons.book_outlined,
          title: 'Daily Journaling',
          subtitle: '',
          onTap: () => onNavigateToTab(3),
        ),
        _buildQuickAccessCard(
          context,
          icon: Icons.ssid_chart_outlined,
          title: 'Mood History',
          subtitle: '',
          onTap: () {
            Navigator.of(context).pushNamed(AIReflectionsScreen.routeName);
          },
        ),
        _buildQuickAccessCard(
          context,
          icon: Icons.mail_outline,
          title: 'Messages',
          subtitle: '',
          onTap: () {
            Navigator.of(context).pushNamed(MessagesScreen.routeName);
          },
        ),
        _buildQuickAccessCard(
          context,
          icon: Icons.person_outline,
          title: 'Join as Pro',
          subtitle: '',
          onTap: () {
            Navigator.of(context).pushNamed(ProfessionalRegistrationPage.route);
          },
        ),
      ],
    );
  }

  Widget _buildExploreGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.2,
      children: [
        _buildQuickAccessCard(
          context,
          icon: Icons.chat_bubble_outline,
          title: 'AI Companion',
          subtitle: '',
          onTap: () => onNavigateToTab(1),
        ),
        _buildQuickAccessCard(
          context,
          icon: Icons.people_outline,
          title: 'Community',
          subtitle: '',
          onTap: () => onNavigateToTab(2),
        ),
        _buildQuickAccessCard(
          context,
          icon: Icons.phone_in_talk_outlined,
          title: 'Professional Help',
          subtitle: '',
          onTap: () => onNavigateToTab(4),
        ),
        _buildQuickAccessCard(
          context,
          icon: Icons.visibility_outlined,
          title: 'Rorschach Test',
          subtitle: '',
          onTap: () {
            Navigator.of(context).pushNamed(RorschachTestScreen.routeName);
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: AppColors.darkText),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.greyText,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodPill extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MoodPill({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28.0),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}