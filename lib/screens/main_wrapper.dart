// lib/screens/main_wrapper.dart (CORRECTED)

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../pages/dashboard_page.dart';
// Updated imports for the 5 main pages
import '../pages/ai_companion_page.dart';
import '../pages/community_page.dart';
import '../pages/journal_page.dart';
import '../pages/help_page.dart';
import 'profile_screen.dart';

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

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.greyText,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.android), // AI Companion/Chat Icon
            label: "AI Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: "Community",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined), // Journal Icon
            label: "Journal",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.phone_in_talk_outlined,
            ), // Help/Professional Help Icon
            label: "Help",
          ),
        ],
      ),
    );
  }
}
