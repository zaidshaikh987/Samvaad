import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/utils/app_routes.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  
  Widget _buildOtpBox() {
    return Container(
      width: 55,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: TextField(
          onChanged: (value) {
            if (value.length == 1) FocusScope.of(context).nextFocus();
          },
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: const InputDecoration(border: InputBorder.none, counterText: ""),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.mark_email_read_outlined, size: 80, color: AppColors.primary),
            const SizedBox(height: 32),
            const Text(
              'Verification Code',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.darkText),
            ),
            const SizedBox(height: 12),
            const Text(
              'We have sent a 5-digit code to your email. Please enter it below to verify.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.greyText, height: 1.5),
            ),
            const SizedBox(height: 48),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) => _buildOtpBox()),
            ),
            
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {},
              child: const Text('Resend Code', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 60),

            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.completeProfileScreen),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Verify & Continue', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}