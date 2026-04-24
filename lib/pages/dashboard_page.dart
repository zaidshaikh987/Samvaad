// lib/pages/dashboard_page.dart
// Enhanced dashboard — tappable avatar, more flash cards, quick shortcuts, wellness status

import 'package:flutter/material.dart';
import 'package:samvaad/screens/message_screen.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/ai_reflections_screen.dart';
import 'package:samvaad/pages/Join_Pro.dart';
import 'package:samvaad/services/ai_mental_health_service.dart';
import 'package:samvaad/widgets/flash_card.dart';
import 'package:samvaad/services/user_session.dart';
import 'package:samvaad/utils/app_routes.dart';
import 'package:samvaad/utils/translations.dart';
import 'package:samvaad/data/repositories/mood_repository.dart';
import 'package:samvaad/data/models/mood_check_in.dart';
import 'package:samvaad/screens/premium_screen.dart';
import 'dart:io';

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
  String? _selectedMood;
  int _checkInStreak = 3;
  bool _checkedInToday = false;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _displayName {
    final sessionName = UserSession().userName;
    if (sessionName != 'User' && sessionName.isNotEmpty) return sessionName;
    return widget.userName.isNotEmpty ? widget.userName : 'User';
  }

  void _onMoodSelected(String mood) {
    setState(() => _selectedMood = mood);
    _showCheckInSheet(mood);
  }

  void _showCheckInSheet(String mood) {
    final prompt = AIMentalHealthService.getReflectionPrompt(mood);
    final TextEditingController reflectionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_note_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You\'re feeling $mood',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              prompt,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.greyText, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reflectionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your reflection here...',
                filled: true,
                fillColor: AppColors.lightGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final note = reflectionController.text.trim();
                  final String userId = UserSession().userId;
                  
                  if (userId.isNotEmpty) {
                    final moodCheckIn = MoodCheckIn(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: userId,
                      mood: mood,
                      reflectionNotes: note.isNotEmpty ? note : null,
                      timestamp: DateTime.now(),
                    );
                    
                    try {
                      await MoodRepository().saveMoodCheckIn(moodCheckIn);
                    } catch (e) {
                      debugPrint('Error saving mood: $e');
                    }
                  }

                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _checkedInToday = true;
                      _checkInStreak++;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(
                                'Check-in saved! 🔥 $_checkInStreak-day streak!'),
                          ],
                        ),
                        backgroundColor: AppColors.calm,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Check-In',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emergency_outlined, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('SOS Helplines', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSOSLine('iCall (TISS)', '9152987821', '8am–10pm Mon–Sat'),
            const Divider(),
            _buildSOSLine('Vandrevala Foundation', '1860-2662-345', '24/7'),
            const Divider(),
            _buildSOSLine('NIMHANS', '080-46110007', '8am–8pm'),
            const Divider(),
            _buildSOSLine('Fortis 24/7', '8376804102', '24/7'),
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
  }

  Widget _buildSOSLine(String name, String number, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(hours,
                    style: const TextStyle(
                        color: AppColors.greyText, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoPath = UserSession().currentUser?.profilePhotoPath;

    return Scaffold(
      backgroundColor: AppColors.background,
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
                  // Tappable avatar → Profile
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.profileScreen),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          backgroundImage: photoPath != null &&
                                  File(photoPath).existsSync()
                              ? FileImage(File(photoPath))
                              : const AssetImage('assets/images/avatr.jpeg')
                                  as ImageProvider,
                          child: (photoPath == null)
                              ? Text(
                                  _displayName.isNotEmpty
                                      ? _displayName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.calm,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Top Right Actions
                  Row(
                    children: [
                      // Language Switcher
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: AppTranslations().locale,
                            icon: const Icon(Icons.language, size: 16, color: AppColors.primary),
                            style: const TextStyle(fontSize: 13, color: AppColors.darkText, fontWeight: FontWeight.bold),
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text('EN')),
                              DropdownMenuItem(value: 'hi', child: Text('HI')),
                              DropdownMenuItem(value: 'mr', child: Text('MR')),
                            ],
                            onChanged: (String? val) {
                              if (val != null) {
                                AppTranslations().setLocale(val).then((_) {
                                  if (mounted) setState(() {});
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Upgrade button
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed(PremiumScreen.routeName);
                          },
                          icon: const Icon(Icons.workspace_premium, size: 16),
                          label: const Text('Upgrade',
                              style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: Size.zero,
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
                ],
              ),

              const SizedBox(height: 20),

              // Streak banner
              if (_checkedInToday || _checkInStreak > 0)
                _buildStreakBanner(),

              const SizedBox(height: 16),

              Text(
                '${_getGreeting()}, $_displayName!',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 16.0, color: AppColors.greyText),
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
                'Explore & Discover',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildExploreGrid(context),

              // Personalized Recommendations
              if (_selectedMood != null) ...[
                const SizedBox(height: 30.0),
                _buildRecommendationsSection(context),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.12),
            AppColors.secondary.withOpacity(0.12)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_checkInStreak-Day Check-In Streak!',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const Text(
                  'Keep going — consistency builds emotional resilience',
                  style: TextStyle(fontSize: 12, color: AppColors.greyText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelection() {
    final List<Map<String, dynamic>> moods = [
      {
        'label': 'Happy',
        'image': 'assets/images/smile.jpeg',
        'color': AppColors.happy
      },
      {
        'label': 'Calm',
        'image': 'assets/images/cry.jpeg',
        'color': AppColors.calm
      },
      {
        'label': 'Sad',
        'image': 'assets/images/sad.jpeg',
        'color': AppColors.sad
      },
      {
        'label': 'Anxious',
        'image': 'assets/images/angry.jpeg',
        'color': AppColors.anxious
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((mood) {
        final isSelected = _selectedMood == mood['label'];
        return _MoodPill(
          imagePath: mood['image'],
          label: mood['label'],
          color: mood['color'],
          isSelected: isSelected,
          onTap: () => _onMoodSelected(mood['label']),
        );
      }).toList(),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14.0,
      mainAxisSpacing: 14.0,
      childAspectRatio: 1.0,
      children: [
        FlashCard(
          title: 'Daily Journal',
          subtitle: 'Log your thoughts',
          icon: Icons.book_outlined,
          primaryColor: const Color(0xFF6B4CE6),
          secondaryColor: const Color(0xFF9B7EF5),
          onTap: () => widget.onNavigateToTab(3),
        ),
        FlashCard(
          title: 'AI Companion',
          subtitle: '24/7 emotional support',
          icon: Icons.psychology_outlined,
          primaryColor: const Color(0xFFE91E63),
          secondaryColor: const Color(0xFFF06292),
          onTap: () => widget.onNavigateToTab(1),
        ),
        FlashCard(
          title: 'Find Therapist',
          subtitle: 'Licensed professionals',
          icon: Icons.medical_services_outlined,
          primaryColor: const Color(0xFF2E7D9A),
          secondaryColor: const Color(0xFF4A9BB8),
          onTap: () => widget.onNavigateToTab(4),
        ),
        FlashCard(
          title: 'Community',
          subtitle: 'Share & connect',
          icon: Icons.people_outline,
          primaryColor: const Color(0xFF00BCD4),
          secondaryColor: const Color(0xFF4DD0E1),
          onTap: () => widget.onNavigateToTab(2),
        ),
      ],
    );
  }

  Widget _buildExploreGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14.0,
      mainAxisSpacing: 14.0,
      childAspectRatio: 1.0,
      children: [
        FlashCard(
          title: 'Journal Insights',
          subtitle: 'View your patterns',
          icon: Icons.insights_outlined,
          primaryColor: const Color(0xFF4CAF50),
          secondaryColor: const Color(0xFF66BB6A),
          onTap: () =>
              Navigator.of(context).pushNamed(AIReflectionsScreen.routeName),
        ),
        FlashCard(
          title: 'Breathing Exercise',
          subtitle: 'Calm your mind now',
          icon: Icons.air_outlined,
          primaryColor: const Color(0xFF26C6DA),
          secondaryColor: const Color(0xFF4DD0E1),
          onTap: () => _showBreathingExercise(context),
        ),
        FlashCard(
          title: 'SOS Helpline',
          subtitle: 'Immediate support',
          icon: Icons.emergency_outlined,
          primaryColor: const Color(0xFFF44336),
          secondaryColor: const Color(0xFFEF9A9A),
          onTap: _showSOSDialog,
        ),
        FlashCard(
          title: 'Self Assessment',
          subtitle: 'Rorschach test',
          icon: Icons.psychology_alt_outlined,
          primaryColor: const Color(0xFF9C27B0),
          secondaryColor: const Color(0xFFCE93D8),
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.rorschachTestScreen),
        ),
        FlashCard(
          title: 'Messages',
          subtitle: 'Talk to someone',
          icon: Icons.chat_bubble_outline,
          primaryColor: const Color(0xFFFF9800),
          secondaryColor: const Color(0xFFFFB74D),
          onTap: () =>
              Navigator.of(context).pushNamed(MessagesScreen.routeName),
        ),
        FlashCard(
          title: 'Join as Pro',
          subtitle: 'Therapist access',
          icon: Icons.workspace_premium_outlined,
          primaryColor: const Color(0xFF795548),
          secondaryColor: const Color(0xFFA1887F),
          onTap: () => Navigator.of(context)
              .pushNamed(ProfessionalRegistrationPage.route),
        ),
      ],
    );
  }

  void _showBreathingExercise(BuildContext context) {
    int _phase = 0; // 0=inhale, 1=hold, 2=exhale
    int _seconds = 4;
    bool _running = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        final phases = ['Inhale', 'Hold', 'Exhale'];
        final counts = [4, 4, 6];
        final colors = [AppColors.primary, AppColors.calm, AppColors.secondary];

        void nextPhase() async {
          for (int p = 0; p < 3; p++) {
            setSheetState(() {
              _phase = p;
              _seconds = counts[p];
              _running = true;
            });
            for (int i = counts[p]; i >= 0; i--) {
              await Future.delayed(const Duration(seconds: 1));
              if (ctx.mounted) setSheetState(() => _seconds = i);
            }
          }
          if (ctx.mounted) setSheetState(() => _running = false);
        }

        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Box Breathing',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '4-4-6 breathing to calm anxiety',
                style: TextStyle(color: AppColors.greyText),
              ),
              const SizedBox(height: 32),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors[_phase].withOpacity(0.3),
                      colors[_phase].withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(color: colors[_phase], width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      phases[_phase],
                      style: TextStyle(
                        color: colors[_phase],
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_seconds',
                      style: TextStyle(
                        color: colors[_phase],
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _running ? null : nextPhase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _running ? 'Breathing...' : 'Start Exercise',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRecommendationsSection(BuildContext context) {
    final recommendations = AIMentalHealthService.getRecommendations(_selectedMood!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_fix_high,
                  color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'Recommended for You',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Based on your $_selectedMood mood',
          style: const TextStyle(fontSize: 13, color: AppColors.greyText),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              return _buildRecommendationCard(context, rec);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, Map<String, dynamic> rec) {
    final iconMap = {
      'journal': Icons.book_outlined,
      'chat': Icons.chat_bubble_outline,
      'community': Icons.people_outline,
      'therapy': Icons.medical_services_outlined,
    };
    final colorMap = {
      'journal': AppColors.happy,
      'chat': AppColors.primary,
      'community': AppColors.calm,
      'therapy': AppColors.anxious,
    };

    final icon = iconMap[rec['icon']] ?? Icons.star_outline;
    final color = colorMap[rec['icon']] ?? AppColors.primary;
    final tabIndex = rec['tab'] as int;

    return GestureDetector(
      onTap: () => widget.onNavigateToTab(tabIndex),
      child: Container(
        width: 145,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              rec['title'],
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              rec['subtitle'],
              style: const TextStyle(fontSize: 11, color: AppColors.greyText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodPill extends StatelessWidget {
  final String imagePath;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodPill({
    required this.imagePath,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.35)
                  : color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.face, size: 50, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? AppColors.darkText : AppColors.greyText,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}