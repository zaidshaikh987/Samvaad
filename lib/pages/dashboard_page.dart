import 'package:flutter/material.dart';
import 'package:samvaad/screens/message_screen.dart';
import 'package:samvaad/screens/rorschach_test_screen.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/ai_reflections_screen.dart';
import 'package:samvaad/pages/Join_Pro.dart';

class DashboardPage extends StatefulWidget {
  final ValueChanged<int> onNavigateToTab;
  final String userName;

  const DashboardPage({
    super.key,
    required this.onNavigateToTab,
    required this.userName,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
   
         // I added your Bottom Navigation Bar back!
     
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/images/avatr.jpeg'), 
                  ),
                  
                  // FIX 1: Wrapped in a SizedBox to prevent infinite width crashes
                  SizedBox(
                    width: 125,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {
                         Navigator.of(context).pushNamed(ProfessionalRegistrationPage.route);
                      },
                      icon: const Icon(Icons.workspace_premium, size: 18),
                      label: const Text('Upgrade'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero, // Overrides global infinite width theme
                        backgroundColor: AppColors.happy, 
                        foregroundColor: AppColors.darkText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24.0),
              
              Text(
                'Good Morning, ${widget.userName}',
                style: const TextStyle(
                  fontSize: 24.0,
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
        ),
      ),
    );
  }

  Widget _buildMoodSelection() {
    final List<Map<String, dynamic>> moods = [
      {'label': 'Happy', 'image': 'assets/images/smile.jpeg', 'color': AppColors.happy},
      {'label': 'Calm', 'image': 'assets/images/cry.jpeg', 'color': AppColors.calm},
      {'label': 'Sad', 'image': 'assets/images/sad.jpeg', 'color': AppColors.sad},
      {'label': 'Anxious', 'image': 'assets/images/angry.jpeg', 'color': AppColors.anxious},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((mood) {
        return _MoodPill(
          imagePath: mood['image'],
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
      childAspectRatio: 1.1, 
      children: [
        _buildImageCard(
          context,
          imagePath: 'assets/images/sky.jpeg', 
          title: 'Daily Journaling',
          subtitle: 'Log your thoughts',
          onTap: () => widget.onNavigateToTab(2), 
        ),
        _buildImageCard(
          context,
          imagePath: 'assets/images/dark.jpeg', 
          title: 'Journal Insights',
          subtitle: 'View your patterns',
          onTap: () {
            Navigator.of(context).pushNamed(AIReflectionsScreen.routeName);
          },
        ),
        _buildImageCard(
          context,
          imagePath: 'assets/images/ds.jpeg', 
          title: 'Messages',
          subtitle: 'Talk to someone',
          onTap: () {
            Navigator.of(context).pushNamed(MessagesScreen.routeName);
          },
        ),
        _buildImageCard(
          context,
          imagePath: 'assets/images/daew.jpeg', 
          title: 'Join as Pro',
          subtitle: 'Therapist access',
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
      childAspectRatio: 1.1,
      children: [
        _buildImageCard(
          context,
          imagePath: 'assets/images/natue.jpeg', 
          title: 'AI Companion',
          subtitle: '24/7 Support',
          onTap: () => widget.onNavigateToTab(3), 
        ),
        _buildImageCard(
          context,
          imagePath: 'assets/images/asw.jpeg', 
          title: 'Community',
          subtitle: 'Share & Connect',
          onTap: () => widget.onNavigateToTab(1), 
        ),
      ],
    );
  }

  // Updated Card Builder to make the WHOLE card an image
  Widget _buildImageCard(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.greyText.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            fit: StackFit.expand, // Forces the stack to fill the whole card
            children: [
              // 1. The Background Image filling the entire card
              Image.asset(
                imagePath,
                fit: BoxFit.cover, // Ensures the image stretches/crops perfectly to the card shape
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.lightGrey,
                  child: const Icon(Icons.image, size: 45, color: Colors.grey),
                ),
              ),
              
              // 2. The Text Overlay
              if (title.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7), // Dark at the bottom
                          Colors.transparent, // Fades to clear
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15, 
                            fontWeight: FontWeight.w700, 
                            color: Colors.white, // Changed to white for contrast
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12, 
                              color: Colors.white70, // Slightly faded white
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} // <--- FIXED: Added this closing brace for the _DashboardPageState class

class _MoodPill extends StatelessWidget {
  final String imagePath;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MoodPill({
    required this.imagePath,
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
            padding: const EdgeInsets.all(4.0), 
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.face, size: 50, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.darkText, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}