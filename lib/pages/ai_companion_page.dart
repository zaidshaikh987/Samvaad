import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/ai_chat_conversation_screen.dart';

class AICompanionPage extends StatelessWidget {
  const AICompanionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Select who you\'d like to talk to',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 24.0),

          // Brobot Card
          _buildCompanionCard(
            context,
            icon: Icons.android,
            name: 'Brobot',
            type: 'Practical Support',
            description:
            'Get actionable advice, problem-solving strategies, and practical guidance for daily challenges.',
            onTap: () {
              Navigator.of(context).pushNamed(
                AIChatConversationScreen.routeName,
                arguments: 'Brobot',
              );
            },
          ),
          const SizedBox(height: 20.0),

          // Emobot Card
          _buildCompanionCard(
            context,
            icon: Icons.sentiment_satisfied_alt_outlined,
            name: 'Emobot',
            type: 'Emotional Support',
            description:
            'Find empathy, validation, and emotional understanding in a safe, non-judgmental space.',
            onTap: () {
              Navigator.of(context).pushNamed(
                AIChatConversationScreen.routeName,
                arguments: 'Emobot',
              );
            },
          ),
          const SizedBox(height: 40.0),

          // Free Chat Remaining Notice
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.happy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.darkText),
                SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    'You have 8 minutes of free chat remaining today',
                    style: TextStyle(color: AppColors.darkText, fontSize: 14.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanionCard(
      BuildContext context, {
        required IconData icon,
        required String name,
        required String type,
        required String description,
        required VoidCallback onTap,
      }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon, color: AppColors.darkText, size: 30),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
