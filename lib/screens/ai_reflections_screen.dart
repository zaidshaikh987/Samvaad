// lib/screens/ai_reflections_screen.dart
// Feature 2: AI Mood Pattern Detection
// Feature 3: Emotional Risk Scoring System
// Feature 7: AI-Generated Mental Health Insights

import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/services/ai_mental_health_service.dart';

class AIReflectionsScreen extends StatefulWidget {
  static const String routeName = '/ai-reflections';
  const AIReflectionsScreen({super.key});

  @override
  State<AIReflectionsScreen> createState() => _AIReflectionsScreenState();
}

class _AIReflectionsScreenState extends State<AIReflectionsScreen> {
  // Feature 7: Tab selection — "This Week" vs "Last Week"
  String _selectedTab = 'This Week';

  // Simulated weekly mood data (7 days)
  final List<String> _thisWeekMoods = [
    'Anxious', 'Sad', 'Calm', 'Happy', 'Anxious', 'Calm', 'Happy'
  ];
  final List<String> _lastWeekMoods = [
    'Sad', 'Sad', 'Anxious', 'Calm', 'Happy', 'Anxious', 'Sad'
  ];

  double? _riskScore;

  @override
  void initState() {
    super.initState();
    _loadRiskScore();
  }

  Future<void> _loadRiskScore() async {
    final insights = AIMentalHealthService.getWeeklyInsights(_thisWeekMoods);
    final score = await AIMentalHealthService.computeRiskScore(
      mood: insights['dominantMood'],
      journalText: 'feeling a bit overwhelmed with work',
    );
    if (mounted) {
      setState(() => _riskScore = score);
    }
  }

  @override
  Widget build(BuildContext context) {
    final insights = AIMentalHealthService.getWeeklyInsights(_thisWeekMoods);
    final lastWeekInsights =
        AIMentalHealthService.getWeeklyInsights(_lastWeekMoods);
    final patterns = AIMentalHealthService.getMoodPatterns(_thisWeekMoods);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AI Reflections',
          style: TextStyle(
              color: AppColors.darkText, fontWeight: FontWeight.bold),
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
            // FEATURE 3: Emotional Risk Score Card
            _riskScore == null 
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                : _buildRiskScoreCard(_riskScore!),
            const SizedBox(height: 28),

            // FEATURE 7: This Week / Last Week Tab Selector
            _buildTabSelector(),
            const SizedBox(height: 24),

            if (_selectedTab == 'This Week') ...[
              // FEATURE 7: Weekly Insights Card
              _buildWeeklyInsightCard(insights),
              const SizedBox(height: 28),

              // FEATURE 2: 7-Day Mood Bar Chart
              _buildMoodChartSection(_thisWeekMoods),
              const SizedBox(height: 28),

              // FEATURE 2: Patterns Detected
              _buildPatternsSection(patterns),
              const SizedBox(height: 28),

              // Day-of-week heatmap
              _buildDayHeatmap(_thisWeekMoods),
            ] else ...[
              // FEATURE 7: Last Week Comparison
              _buildLastWeekComparison(insights, lastWeekInsights),
              const SizedBox(height: 28),

              // Last week chart
              _buildMoodChartSection(_lastWeekMoods, title: 'Last Week Mood'),
            ],

            const SizedBox(height: 28),
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
            _buildTopicTile(
                'Building Healthy Habits', Icons.psychology_outlined),
            _buildTopicTile('Mindfulness Exercises', Icons.self_improvement),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FEATURE 3: Emotional Risk Scoring Card
  // ─────────────────────────────────────────────
  Widget _buildRiskScoreCard(double riskScore) {
    final level = AIMentalHealthService.getRiskLevel(riskScore);
    final description = AIMentalHealthService.getRiskDescription(riskScore);
    final percentage = (riskScore * 100).toInt();

    Color riskColor;
    Color bgColor;
    IconData riskIcon;

    switch (level) {
      case 'High':
        riskColor = Colors.red.shade600;
        bgColor = Colors.red.shade50;
        riskIcon = Icons.warning_rounded;
        break;
      case 'Moderate':
        riskColor = Colors.orange.shade600;
        bgColor = Colors.orange.shade50;
        riskIcon = Icons.info_rounded;
        break;
      default:
        riskColor = AppColors.calm;
        bgColor = const Color(0xFFEAFFF7);
        riskIcon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: riskColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: riskColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Score Indicator
          SizedBox(
            width: 75,
            height: 75,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: riskScore,
                  strokeWidth: 7,
                  backgroundColor: riskColor.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                ),
                Text(
                  '$percentage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(riskIcon, color: riskColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Emotional Risk: $level',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.greyText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FEATURE 7: Tab Selector
  // ─────────────────────────────────────────────
  Widget _buildTabSelector() {
    return Row(
      children: [
        _buildTabPill('This Week'),
        const SizedBox(width: 12.0),
        _buildTabPill('Last Week'),
      ],
    );
  }

  Widget _buildTabPill(String title) {
    bool isSelected = _selectedTab == title;
    return InkWell(
      onTap: () => setState(() => _selectedTab = title),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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

  // ─────────────────────────────────────────────
  // FEATURE 7: Weekly Insight Card
  // ─────────────────────────────────────────────
  Widget _buildWeeklyInsightCard(Map<String, dynamic> insights) {
    return Container(
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
                  child: const Icon(Icons.auto_fix_high,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12.0),
                const Text(
                  'Your Week\'s Insights',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.darkText),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              insights['observation'],
              style: const TextStyle(
                  fontSize: 15.0, height: 1.5, color: AppColors.darkText),
            ),
            const SizedBox(height: 12),
            _buildInsightRow(
                Icons.flag_outlined, 'Key Trigger', insights['trigger']),
            const SizedBox(height: 8),
            _buildInsightRow(Icons.lightbulb_outline, 'Suggested Action',
                insights['recommendedAction']),
            const SizedBox(height: 16),
            // Progress bars
            _buildStatRow('Positive Days',
                insights['positivityScore'], AppColors.happy),
            const SizedBox(height: 8),
            _buildStatRow(
                'Self-Care Score', insights['selfCareScore'], AppColors.calm),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText)),
            Text('${(progress * 100).toInt()}%',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // FEATURE 2: 7-Day Mood Bar Chart
  // ─────────────────────────────────────────────
  Widget _buildMoodChartSection(List<String> moods, {String title = 'This Week\'s Mood'}) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final moodHeights = {
      'Happy': 1.0,
      'Calm': 0.75,
      'Anxious': 0.55,
      'Sad': 0.35,
    };
    final moodColors = {
      'Happy': AppColors.happy,
      'Calm': AppColors.calm,
      'Anxious': AppColors.anxious,
      'Sad': AppColors.sad,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mood intensity by day',
            style: TextStyle(fontSize: 12, color: AppColors.greyText),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 125,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(moods.length, (i) {
                final mood = i < moods.length ? moods[i] : 'Calm';
                final height = (moodHeights[mood] ?? 0.5) * 80;
                final color = moodColors[mood] ?? AppColors.calm;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: height,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      i < days.length ? days[i] : '',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.greyText),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 12,
            children: [
              _buildLegendItem('Happy', AppColors.happy),
              _buildLegendItem('Calm', AppColors.calm),
              _buildLegendItem('Anxious', AppColors.anxious),
              _buildLegendItem('Sad', AppColors.sad),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.greyText)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // FEATURE 2: Patterns Detected Section
  // ─────────────────────────────────────────────
  Widget _buildPatternsSection(List<Map<String, dynamic>> patterns) {
    final colorMap = {
      'anxious': AppColors.anxious,
      'happy': AppColors.happy,
      'calm': AppColors.calm,
      'sad': AppColors.sad,
    };
    final iconMap = {
      'warning': Icons.warning_amber_rounded,
      'sunny': Icons.wb_sunny_outlined,
      'cycle': Icons.loop,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patterns Detected',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 14),
        ...patterns.map((p) {
          final color = colorMap[p['color']] ?? AppColors.primary;
          final icon = iconMap[p['icon']] ?? Icons.info_outline;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['title'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        p['description'],
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.greyText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // FEATURE 2: Day-of-Week Heatmap
  // ─────────────────────────────────────────────
  Widget _buildDayHeatmap(List<String> moods) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final moodColors = {
      'Happy': AppColors.happy,
      'Calm': AppColors.calm,
      'Anxious': AppColors.anxious,
      'Sad': AppColors.sad,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emotional Heatmap',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final mood = i < moods.length ? moods[i] : 'Calm';
              final color = moodColors[mood] ?? AppColors.calm;
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(days[i],
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.greyText)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FEATURE 7: Last Week Comparison
  // ─────────────────────────────────────────────
  Widget _buildLastWeekComparison(
    Map<String, dynamic> thisWeek,
    Map<String, dynamic> lastWeek,
  ) {
    final thisPos = thisWeek['positiveDays'] as int;
    final lastPos = lastWeek['positiveDays'] as int;
    final diff = thisPos - lastPos;
    final improved = diff >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Week-over-Week Comparison',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 14),
        _buildComparisonCard(
          title: 'Positive Mood Days',
          thisWeekValue: '$thisPos days',
          lastWeekValue: '$lastPos days',
          improved: improved,
          changeText: improved
              ? '+$diff more positive days this week!'
              : '${diff.abs()} fewer positive days than last week',
        ),
        const SizedBox(height: 12),
        _buildComparisonCard(
          title: 'Self-Care Score',
          thisWeekValue: '${(thisWeek['selfCareScore'] * 100).toInt()}%',
          lastWeekValue: '${(lastWeek['selfCareScore'] * 100).toInt()}%',
          improved: true,
          changeText: 'Consistent self-care habits observed',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  improved
                      ? 'Great trend! Your emotional health is improving week over week.'
                      : 'This week was challenging. Remember: progress isn\'t always linear.',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.darkText, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonCard({
    required String title,
    required String thisWeekValue,
    required String lastWeekValue,
    required bool improved,
    required String changeText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildWeekBadge('This Week', thisWeekValue, AppColors.primary),
              const SizedBox(width: 12),
              _buildWeekBadge('Last Week', lastWeekValue, AppColors.greyText),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                improved ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: improved ? AppColors.calm : AppColors.anxious,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  changeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: improved ? AppColors.calm : AppColors.anxious,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildTopicTile(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
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
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.darkText)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16.0, color: AppColors.greyText),
        onTap: () {},
      ),
    );
  }
}