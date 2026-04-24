// lib/screens/main_wrapper.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../pages/dashboard_page.dart';
import '../pages/ai_companion_page.dart';
import '../pages/community_page.dart';
import '../pages/journal_page.dart';
import '../pages/help_page.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../services/voice_navigation_service.dart';
import '../services/user_session.dart';
import '../utils/app_routes.dart';

class MainWrapper extends StatefulWidget {
  // FIX: ADDED the missing routeName getter.
  static const String routeName = '/main-wrapper';

  final String userName;
  const MainWrapper({super.key, required this.userName});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  final VoiceNavigationService _voiceService = VoiceNavigationService();
  bool _isListening = false;
  String _recognizedText = '';

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // UPDATED: Define 5 main pages matching the video's bottom navigation
    _pages = [
      DashboardPage(onNavigateToTab: _onItemTapped, userName: widget.userName),
      // Index 1: AI Chat Companion
      const AICompanionPage(),
      // Index 2: Community
      const CommunityPage(),
      // Index 3: Journal
      const JournalPage(),
      // Index 4: Help / Professional Help (We use HelpPage as the tab destination)
      const HelpPage(),
    ];
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _toggleVoiceNavigation() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() {
        _isListening = false;
        _recognizedText = '';
      });
    } else {
      final hasPermission = await _voiceService.hasPermission();
      if (!hasPermission) {
        final granted = await _voiceService.requestPermission();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Microphone permission required')),
            );
          }
          return;
        }
      }

      await _voiceService.startListening(
        onTextRecognized: (text) {
          setState(() => _recognizedText = text);
        },
        onCommandRecognized: (command) {
          _handleVoiceCommand(command);
        },
      );
      setState(() => _isListening = true);
    }
  }

  void _handleVoiceCommand(String command) {
    switch (command) {
      case 'home':
        _onItemTapped(0);
        break;
      case 'chatbot':
      case 'ai':
        _onItemTapped(1);
        break;
      case 'community':
        _onItemTapped(2);
        break;
      case 'journal':
        _onItemTapped(3);
        break;
      case 'help':
        _onItemTapped(4);
        break;
      case 'profile':
        Navigator.of(context).pushNamed(ProfileScreen.routeName);
        break;
      default:
        break;
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigating to $command'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0 ? null : AppBar(
        title: Text(_getPageTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).pushNamed(ProfileScreen.routeName);
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          // Voice navigation overlay
          if (_isListening)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Listening...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (_recognizedText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _recognizedText,
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleVoiceNavigation,
        backgroundColor: _isListening ? Colors.red : AppColors.primary,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.greyText,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Daily Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'Help'),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'AI Companion';
      case 2:
        return 'Community';
      case 3:
        return 'Journal';
      case 4:
        return 'Help';
      default:
        return 'Samvaad';
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    UserSession().userName.isNotEmpty
                        ? UserSession().userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  UserSession().userName.isNotEmpty
                      ? UserSession().userName
                      : widget.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  UserSession().userEmail.isNotEmpty
                      ? UserSession().userEmail
                      : 'Mental Health Companion',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.home_outlined, 'Home', () => _onItemTapped(0)),
          _buildDrawerItem(Icons.person_outline, 'Profile', () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed(ProfileScreen.routeName);
          }),
          _buildDrawerItem(Icons.chat_bubble_outline, 'AI Companion', () => _onItemTapped(1)),
          _buildDrawerItem(Icons.people_outline, 'Community', () => _onItemTapped(2)),
          _buildDrawerItem(Icons.auto_awesome, 'Journal', () => _onItemTapped(3)),
          _buildDrawerItem(Icons.help_outline, 'Help', () => _onItemTapped(4)),
          const Divider(),
          _buildDrawerItem(Icons.settings_outlined, 'Settings', () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed(SettingsScreen.routeName);
          }),
          _buildDrawerItem(Icons.info_outline, 'About', () {
            Navigator.pop(context);
            showAboutDialog(
              context: context,
              applicationName: 'Samvaad',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.psychology_outlined,
                  color: AppColors.primary, size: 36),
              children: const [
                Text(
                  'Samvaad is your safe mental health companion — offering AI support, journaling, community connection, and professional help.',
                ),
              ],
            );
          }),
          _buildDrawerItem(Icons.logout, 'Logout', () async {
            Navigator.pop(context);
            await UserSession().clearSession();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.welcomeScreen,
                (route) => false,
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
