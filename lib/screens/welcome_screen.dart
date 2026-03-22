import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/utils/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Now Pure White
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            
// --- ATTRACTIVE & ALIGNED LOGO/ILLUSTRATION ---
            Center(
              child: Container(
                height: 320,
                width: double.infinity,
                // Ensures it doesn't touch the very edges of the screen
                margin: const EdgeInsets.symmetric(horizontal: 24), 
                decoration: BoxDecoration(
                  // Creates a soft, modern glow behind your logo
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.15), // Soft cyan center
                      AppColors.primary.withOpacity(0.05),   // Fades to soft blue
                      AppColors.background.withOpacity(0.0), // Fades out completely to white
                    ],
                    radius: 0.6,
                    center: Alignment.center,
                  ),
                ),
                child: Padding(
                  // Adds breathing room inside the glow
                  padding: const EdgeInsets.all(20.0), 
                  child: Image.asset(
                    'assets/images/image.png', // Replace with your logo/illustration
                    fit: BoxFit.contain,
                    alignment: Alignment.center, // Strictly aligns the image to the center
                  ),
                ),
              ),
            ),
            // ----------------------------------------------
            const Spacer(flex: 1),
            
            // Improved Title using RichText for a colorful pop
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                    height: 1.2,
                    // fontFamily: 'YourCustomFont', // Add your font family here if needed
                  ),
                  children: [
                    TextSpan(text: 'Say Hello, to Your\n'),
                    TextSpan(
                      text: 'Mental Health',
                      style: TextStyle(
                        color: AppColors.primary, // Uses the vibrant Royal Blue
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Improved Subtitle with better line height
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Start meditation to enhance objectivity and achieve the bravest goals.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.greyText, 
                  fontSize: 16,
                  height: 1.5, // Better readability
                ),
              ),
            ),
            
            const Spacer(flex: 2),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Column(
                children: [
                  // Primary Action Button
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.loginScreen),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Vibrant Blue
                      foregroundColor: AppColors.white,
                      elevation: 6, // Adds a nice drop shadow
                      shadowColor: AppColors.primary.withOpacity(0.5), // Colored shadow
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // Modern slightly rounded corners
                      ),
                    ),
                    child: const Text(
                      'Get Started', 
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16), // Space between buttons
                  
                  // Secondary Action Button
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.createAccountScreen),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Create Account', 
                      style: TextStyle(
                        color: AppColors.darkText, 
                        fontSize: 16, 
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10), // Bottom padding safeguard
          ],
        ),
      ),
    );
  }
}