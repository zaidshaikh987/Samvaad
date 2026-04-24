// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/main_wrapper.dart';
import 'package:samvaad/utils/app_routes.dart';
import 'package:samvaad/data/database/database_manager.dart';
import 'package:samvaad/services/user_session.dart';
import 'package:samvaad/data/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samvaad/services/encryption_service.dart';
import 'package:samvaad/data/repositories/user_repository.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    const secureStorage = FlutterSecureStorage();
    final savedEmail = await secureStorage.read(key: 'saved_email');
    final savedPassword = await secureStorage.read(key: 'saved_password');
    if (savedEmail != null) _emailController.text = savedEmail;
    if (savedPassword != null) _passwordController.text = savedPassword;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use repository to find the user via new O(1) hashed lookup
      final userRepository = UserRepository();
      final user = await userRepository.getUserByEmail(email);

      if (user != null) {
        // Look up the database record explicitly to check the actual stored password
        final db = await DatabaseManager().database;
        final results = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [user.id]
        );
        
        if (results.isNotEmpty) {
           final storedPassword = results.first['password'] as String?;
           final encryptionService = EncryptionService();
           
           // Verify password hashes! Let's allow legacy plaintext match for backwards compatibility until they reset.
           final hashedInput = encryptionService.hashSHA256(password);
           
           if (storedPassword == hashedInput || storedPassword == password) {
               // IF we matched plaintext legacy, let's gracefully upgrade their password hash
               if (storedPassword == password) {
                   await db.update('users', {'password': hashedInput}, where: 'id = ?', whereArgs: [user.id]);
               }
               
               UserSession().setUser(user);
               
               const secureStorage = FlutterSecureStorage();
               await secureStorage.write(key: 'saved_email', value: email);
               await secureStorage.write(key: 'saved_password', value: password);
           
               if (mounted) {
                 Navigator.of(context).pushReplacementNamed(
                   MainWrapper.routeName,
                   arguments: user.name,
                 );
               }
               return;
           }
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              controller: _emailController,
              label: 'Email',
              hint: 'your@email.com',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 20.0),
            
            _buildRefreshingInput(
              controller: _passwordController,
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
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Log In', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
    required TextEditingController controller,
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
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: TextFormField(
            controller: controller,
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