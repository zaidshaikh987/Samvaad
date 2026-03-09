import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/main_wrapper.dart';
import 'package:samvaad/utils/app_routes.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Soft Pink Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20.0),
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.w900,
                color: AppColors.darkText,
              ),
            ),
            const Text(
              'Log in to your safe space',
              style: TextStyle(fontSize: 16.0, color: AppColors.greyText),
            ),
            const SizedBox(height: 48.0),
            
            _buildRefreshingInput(
              label: 'Email',
              hint: 'your@email.com',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 20.0),
            
            _buildRefreshingInput(
              label: 'Password',
              hint: '••••••••',
              icon: Icons.lock_outline,
              isPassword: true,
              suffix: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.greyText,
                  size: 20,
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 40.0),

            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed(MainWrapper.routeName),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
              child: const Text('Log In', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? ", style: TextStyle(color: AppColors.darkText)),
                InkWell(
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.createAccountScreen),
                  child: const Text('Sign Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshingInput({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkText)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: TextFormField(
            obscureText: isPassword && !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }
}