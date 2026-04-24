// lib/pages/help_page.dart
// Feature 6: Smart Therapist Matching

import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';

import 'package:samvaad/utils/app_routes.dart';
import 'package:samvaad/services/ai_mental_health_service.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Simulated current mood (in real app, passed from shared state)
  final String _currentMood = 'Anxious';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: AppColors.accent.withOpacity(0.3),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
              ),
              labelColor: AppColors.darkText,
              unselectedLabelColor: AppColors.greyText,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [Tab(text: 'Therapists'), Tab(text: 'Psychiatrists')],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTherapistList(context),
              _buildTherapistList(context, isPsychiatrist: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTherapistList(BuildContext context,
      {bool isPsychiatrist = false}) {
    final allTherapists =
        AIMentalHealthService.getMatchedTherapists(_currentMood);
    final topMatches = allTherapists.take(2).toList();
    final rest = allTherapists.skip(2).toList();

    // Static fallback list for psychiatrists
    final List<Map<String, dynamic>> providers = isPsychiatrist
        ? [
            {
              'name': 'Dr. Ramesh Iyer',
              'specialty': 'Mood Disorders',
              'years': 15,
              'rating': 4.8,
              'fee': 100,
              'status': 'Available this week',
            },
            {
              'name': 'Dr. Fatima Khan',
              'specialty': 'Anxiety & OCD',
              'years': 11,
              'rating': 4.7,
              'fee': 95,
              'status': 'Booked out',
            },
          ]
        : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPsychiatrist ? 'Medical Professionals' : 'Licensed Therapists',
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            isPsychiatrist
                ? 'Prescribe and manage medication'
                : 'Talk therapy and counseling support',
            style: const TextStyle(color: AppColors.greyText, fontSize: 14),
          ),
          const SizedBox(height: 16.0),

          if (!isPsychiatrist) ...[
            // FEATURE 6: AI-Recommended Section
            _buildAIMatchSection(topMatches),
            const SizedBox(height: 24),
            const Text(
              'All Therapists',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 12),
            ...rest.map((t) => _buildProviderCard(context, {
                  'name': t['name'],
                  'specialty': t['specialty'],
                  'years': t['years'],
                  'rating': t['rating'],
                  'fee': t['fee'],
                  'status': 'Available this week',
                })),
          ] else
            ...providers
                .map((provider) => _buildProviderCard(context, provider)),
        ],
      ),
    );
  }

  // FEATURE 6: AI-Recommended section with match scores
  Widget _buildAIMatchSection(List<Map<String, dynamic>> matches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.08),
                AppColors.secondary.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_fix_high,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI-Recommended for You',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Based on your $_currentMood mood patterns',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...matches.map((t) => _buildMatchedTherapistCard(t)),
      ],
    );
  }

  Widget _buildMatchedTherapistCard(Map<String, dynamic> therapist) {
    final matchScore =
        AIMentalHealthService.getMatchScore(therapist, _currentMood);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: const Icon(Icons.person,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        therapist['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        therapist['specialty'],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: AppColors.happy, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            '${therapist['rating']} · ${therapist['years']} yrs · ${therapist['lang']}',
                            style: const TextStyle(
                                color: AppColors.greyText, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // FEATURE 6: Match Score Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.calm.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$matchScore%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.calm,
                        ),
                      ),
                      const Text(
                        'match',
                        style: TextStyle(
                            fontSize: 9, color: AppColors.greyText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Match reason
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      therapist['reason'],
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.darkText),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Session Fee',
                          style: TextStyle(
                              color: AppColors.greyText, fontSize: 12)),
                      Text('\$${therapist['fee']}/session',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.therapistBookingScreen,
                        arguments: {
                          'name': therapist['name'],
                          'specialty': therapist['specialty'],
                          'fee': therapist['fee'],
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Book Session',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(
      BuildContext context, Map<String, dynamic> provider) {
    bool isAvailable = provider['status'] == 'Available this week';
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.accent.withOpacity(0.5),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(provider['specialty'],
                          style: const TextStyle(
                              color: AppColors.darkText, fontSize: 14)),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: AppColors.happy, size: 16),
                          Text(
                            '${provider['rating']} · ${provider['years']} Years',
                            style: const TextStyle(
                                color: AppColors.greyText, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Session Fee',
                          style: TextStyle(
                              color: AppColors.greyText, fontSize: 12)),
                      Text('\$${provider['fee']}/session',
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status',
                          style: TextStyle(
                              color: AppColors.greyText, fontSize: 12)),
                      Text(
                        provider['status'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isAvailable
                              ? AppColors.primary
                              : AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isAvailable
                    ? () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.therapistBookingScreen,
                          arguments: provider,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isAvailable ? AppColors.primary : AppColors.lightGrey,
                  foregroundColor:
                      isAvailable ? Colors.white : AppColors.greyText,
                ),
                child: Text(isAvailable ? 'Book Session' : 'Unavailable'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
