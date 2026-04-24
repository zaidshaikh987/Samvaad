import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';

class PremiumScreen extends StatefulWidget {
  static const String routeName = '/premium';
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'Annual';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium_outlined, color: AppColors.happy, size: 60),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Samvaad Premium',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Unlock the full potential of your mental wellness journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.greyText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40.0),

            // Premium Benefits
            const Text(
              'Premium Benefits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildBenefit('Unlimited AI chat conversations'),
            _buildBenefit('Advanced mood analytics'),
            _buildBenefit('Premium meditation library'),
            _buildBenefit('Priority therapist booking'),
            _buildBenefit('Ad-free experience'),
            _buildBenefit('Export journal entries'),
            const SizedBox(height: 40.0),

            // Subscription Plans
            _buildSubscriptionPlan('Monthly Plan', 'Billed monthly', '\$9.99/month', 'Monthly', isPopular: false),
            const SizedBox(height: 20.0),
            _buildSubscriptionPlan('Annual Plan', 'Save 40%', '\$5.99/month', 'Annual', isPopular: true),
            const SizedBox(height: 40.0),

            // Free Trial Info
            const Center(
              child: Text(
                'Cancel anytime. 7-day free trial for new subscribers.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.greyText, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12.0),

            // Start Free Trial Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: Row(
                        children: [
                          const Icon(Icons.workspace_premium_outlined,
                              color: AppColors.happy),
                          const SizedBox(width: 8),
                          const Text('Start Free Trial',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You\'re starting a 7-day free trial of the '
                            '${_selectedPlan == 'Annual' ? 'Annual Plan (\$5.99/month)' : 'Monthly Plan (\$9.99/month)'}.',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No charge until your trial ends. Cancel anytime.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.greyText),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Not Now',
                              style: TextStyle(color: AppColors.greyText)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('Free trial activated! Enjoy Samvaad Premium 🎉'),
                                  ],
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 3),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary),
                          child: const Text('Start Trial',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Start 7-Day Free Trial',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary),
          const SizedBox(width: 12.0),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlan(String title, String subtitle, String price, String planId, {required bool isPopular}) {
    bool isSelected = _selectedPlan == planId;
    return InkWell(
      onTap: () {
        setState(() => _selectedPlan = planId);
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4.0),
                    Text(subtitle, style: const TextStyle(color: AppColors.greyText)),
                  ],
                ),
                Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            if (isPopular) ...[
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.happy.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text('Most Popular', style: TextStyle(color: AppColors.darkText, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
