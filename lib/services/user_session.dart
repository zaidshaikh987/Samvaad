// lib/services/user_session.dart
// Singleton service that holds the currently logged-in user's state.
// Updated on login/registration and read everywhere via UserSession().currentUser

import 'package:shared_preferences/shared_preferences.dart';
import 'package:samvaad/data/models/user.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  // In-memory current user
  User? _currentUser;

  // Getters
  User? get currentUser => _currentUser;
  String get userId => _currentUser?.id ?? 'demo-user-id';
  String get userName => _currentUser?.name ?? 'User';
  String get userEmail => _currentUser?.email ?? '';
  bool get isLoggedIn => _currentUser != null;

  /// Called after successful login or registration.
  void setUser(User user) {
    _currentUser = user;
    _persistSession(user);
  }

  /// Clear session (logout).
  Future<void> clearSession() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_user_id');
    await prefs.remove('session_user_name');
    await prefs.remove('session_user_email');
  }

  /// Persist minimal session data for app restarts.
  Future<void> _persistSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_user_id', user.id);
    await prefs.setString('session_user_name', user.name);
    await prefs.setString('session_user_email', user.email);
  }

  /// Restore session on app launch (called from main.dart).
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('session_user_id');
    final name = prefs.getString('session_user_name');
    final email = prefs.getString('session_user_email');

    if (id != null && name != null && email != null) {
      // Reconstruct a minimal User from persisted data
      _currentUser = User(
        id: id,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: true,
      );
      return true;
    }
    return false;
  }

  /// Update just the name (after edit profile).
  void updateName(String name) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name, updatedAt: DateTime.now());
      _persistSession(_currentUser!);
    }
  }
}
