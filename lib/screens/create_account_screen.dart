import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/utils/app_routes.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Samvaad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join Samvaad today',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 40),

            // Full Name Field
            const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 24),

            // Email Field
            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'your@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            // Password Field
            const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Create a password',
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Password Field
            const Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Confirm your password',
              ),
            ),
            const SizedBox(height: 40),

            // Create Account Button
            ElevatedButton(
              onPressed: () {
                // Navigate to email verification screen
                Navigator.of(context).pushNamed(AppRoutes.verifyEmailScreen);
              },
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 24),

            // Log In Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?", style: TextStyle(color: AppColors.darkText)),
                TextButton(
                  onPressed: () {
                    // Navigate back to the login screen
                    Navigator.of(context).pushNamed(AppRoutes.loginScreen);
                  },
                  child: const Text(
                    'Log In',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
