// lib/utils/constants.dart
// Application-wide constants

class AppConstants {
  // Database
  static const String databaseName = 'samvaad.db';
  static const int databaseVersion = 1;
  
  // OTP
  static const int otpLength = 6;
  static const int otpExpirationMinutes = 10;
  static const int otpMaxResendAttempts = 3;
  static const int otpResendCooldownMinutes = 15;
  
  // File Upload
  static const int maxImageSizeKB = 500;
  static const int maxDocumentSizeMB = 5;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocumentFormats = ['pdf', 'jpg', 'jpeg', 'png'];
  
  // AI Models
  static const int conversationContextWindow = 10;
  static const int aiResponseTimeoutSeconds = 5;
  
  // Performance
  static const int appLaunchTimeoutSeconds = 3;
  static const int databaseQueryTimeoutMs = 500;
  static const int uiInteractionTimeoutMs = 100;
  
  // Mood Tracking
  static const int moodHistoryDays = 30;
  static const List<String> moodTypes = ['Happy', 'Calm', 'Sad', 'Anxious'];
  
  // Languages
  static const List<String> supportedLanguages = [
    'en', // English
    'hi', // Hindi
    'ta', // Tamil
    'te', // Telugu
    'bn', // Bengali
    'mr', // Marathi
  ];
  
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'bn': 'বাংলা',
    'mr': 'मराठी',
  };
  
  // Session
  static const int sessionExpirationDays = 30;
  
  // Encryption
  static const int pbkdf2Iterations = 100000;
  static const int encryptionKeyLength = 32; // 256 bits
  
  // Voice Navigation Commands
  static const Map<String, List<String>> voiceCommands = {
    'journal': ['open journal', 'journal', 'write', 'diary'],
    'emobot': ['talk to emobot', 'emobot', 'chat', 'talk'],
    'profile': ['show profile', 'profile', 'my profile'],
    'community': ['go to community', 'community', 'forum'],
    'mood': ['check mood', 'mood', 'track mood', 'mood tracker'],
    'settings': ['show settings', 'settings', 'preferences'],
    'home': ['go home', 'home', 'dashboard'],
  };
  
  // Hugging Face AI Configuration
  static const String huggingFaceApiUrl = 'https://api-inference.huggingface.co/models';
  static const String huggingFaceConversationalModel = 'facebook/blenderbot-400M-distill';
  static const String huggingFaceEmotionalModel = 'microsoft/DialoGPT-medium';
  static const String huggingFaceSentimentModel = 'distilbert-base-uncased-finetuned-sst-2-english';
  static const int huggingFaceTimeoutSeconds = 30;
  static const int huggingFaceMaxRetries = 2;
}
