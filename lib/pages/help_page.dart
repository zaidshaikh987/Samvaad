import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/therapist_booking_screen.dart';
import 'package:samvaad/utils/app_routes.dart';
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        // Tab Bar for Therapists/Psychiatrists
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

        // Tab View Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTherapistList(context),
              _buildTherapistList(
                context,
                isPsychiatrist: true,
              ), // Reusing the list layout
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTherapistList(
    BuildContext context, {
    bool isPsychiatrist = false,
  }) {
    // Mock Data
    final List<Map<String, dynamic>> providers = [
      {
        'name': 'Dr. Sarah Johnson',
        'specialty': 'Anxiety & Stress',
        'years': 12,
        'rating': 4.9,
        'fee': 80,
        'status': 'Available this week',
      },
      {
        'name': 'Dr. Michael Chen',
        'specialty': 'Teen Counseling',
        'years': 8,
        'rating': 4.7,
        'fee': 75,
        'status': 'Booked out',
      },
    ];

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
          ...providers
              .map((provider) => _buildProviderCard(context, provider))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildProviderCard(
    BuildContext context,
    Map<String, dynamic> provider,
  ) {
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
                // Avatar Placeholder
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
                      Text(
                        provider['specialty'],
                        style: const TextStyle(
                          color: AppColors.darkText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(Icons.star, color: AppColors.happy, size: 16),
                          Text(
                            '${provider['rating']} · ${provider['years']} Years',
                            style: TextStyle(
                              color: AppColors.greyText,
                              fontSize: 13,
                            ),
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
                      const Text(
                        'Session Fee',
                        style: TextStyle(
                          color: AppColors.greyText,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$${provider['fee']}/session',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          color: AppColors.greyText,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        provider['status'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              isAvailable
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
                onPressed:
                    isAvailable
                        ? () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.therapistBookingScreen, // Fixed
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
