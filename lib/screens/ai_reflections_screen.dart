import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';

class AIReflectionsScreen extends StatefulWidget {
  static const String routeName = '/ai-reflections';
  const AIReflectionsScreen({super.key});

  @override
  State<AIReflectionsScreen> createState() => _AIReflectionsScreenState();
}

class _AIReflectionsScreenState extends State<AIReflectionsScreen> {
  String _selectedTab = 'Growth Mindset';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // New Soft Pink Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AI Reflections', 
          style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Tab Selector
            _buildTabSelector(),
            const SizedBox(height: 24.0),

            // Weekly Insights Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                          child: const Icon(Icons.auto_fix_high, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12.0),
                        const Text(
                          'Your Week\'s Insights', 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkText)
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'You\'ve shown remarkable resilience this week. Your journal entries reveal a pattern of positive coping strategies, especially when dealing with work stress.',
                      style: TextStyle(fontSize: 15.0, height: 1.5, color: AppColors.darkText),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),

            // Patterns Detected Section
            const Text(
              'Patterns Detected',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 20.0),
            _buildStatCard('Positive Mood Days', 0.65, AppColors.happy),
            _buildStatCard('Self-Care Activities', 0.80, AppColors.calm),
            const SizedBox(height: 32.0),

            // Recommended Topics Section
            const Text(
              'Recommended Topics',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildTopicTile('Stress Management Techniques', Icons.trending_up),
            _buildTopicTile('Building Healthy Habits', Icons.psychology_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Row(
      children: [
        _buildTabPill('Growth Mindset'),
        const SizedBox(width: 12.0),
        _buildTabPill('Self-Care'),
      ],
    );
  }

  Widget _buildTabPill(String title) {
    bool isSelected = _selectedTab == title;
    return InkWell(
      onTap: () => setState(() => _selectedTab = title),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  // UPDATED: Modern Progress Bar Stat Card
  Widget _buildStatCard(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label, 
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.darkText)
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildTopicTile(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkText)
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16.0, color: AppColors.greyText),
        onTap: () {
          // Navigate to topic detail
        },
      ),
    );
  }
}