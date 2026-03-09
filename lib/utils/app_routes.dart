// Note: This file defines static route names for easy access across the app.

class AppRoutes {
  // Auth Flow
  static const String welcomeScreen = '/welcome';
  static const String loginScreen = '/login';
  static const String createAccountScreen = '/create-account';
  static const String verifyEmailScreen = '/verify-email';
  static const String completeProfileScreen = '/complete-profile';

  // Main Wrapper (Bottom Navigation Host)
  static const String mainWrapper = '/main-wrapper';

  // Main Tabs (Pages hosted by MainWrapper) - Used primarily for internal navigation clarity.
  static const String dashboardPage = '/dashboard';
  static const String aiCompanionPage = '/ai-companion';
  static const String communityPage = '/community';
  static const String helpPage = '/help';

  // Journal Related Routes (Correcting the missing entry)
  static const String dailyJournalEntry = '/daily-journal-entry';
  static const String journalPage = '/journal-entries-tab';
  static const String legacyJournalEntry = '/journal-entry'; // Used to resolve "generator not found" error
static const String professionalRegistration = '/professional-registration';
  // Sub Screens (Corrected name to match MessagesScreen file)
  static const String messagesScreen = '/messages'; 
  static const String aiChatConversationScreen = '/ai-chat-conversation';
  static const String therapistBookingScreen = '/therapist-booking';
  static const String sessionFeedbackScreen = '/session-feedback';
  static const String postDetailScreen = '/post-detail';
  static const String aiReflectionsScreen = '/ai-reflections';
  static const String profileScreen = '/profile';
  static const String editProfileScreen = '/edit-profile';
  static const String settingsScreen = '/settings';
  static const String premiumScreen = '/premium';
  static const String rorschachTestScreen = '/rorschach-test';
  
  // Placeholder for Chat Session screen (seen before feedback)
  static const String chatSessionPlaceholder = '/chat-session-placeholder';
}