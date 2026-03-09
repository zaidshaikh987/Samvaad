import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/utils/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

 // lib/screens/welcome_screen.dart updates
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background, // Soft Pink
    body: SafeArea(
      child: Column(
        children: [
          const Spacer(),
          // Visual Element based on your image
          Container(
            height: 300,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/image.png'), // Replace with your illustration
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Say Hello, to Your\nMental Health',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
              height: 1.2,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: Text(
              'Start meditation to enhance objectivity and achieve the bravest goals',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.greyText, fontSize: 16),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.loginScreen),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Navy
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.createAccountScreen),
                  child: const Text('Create Account', style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}