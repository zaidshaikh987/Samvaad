# Design Document: Samvaad App Refactoring and Enhancement

## Overview

### Purpose

This design document specifies the technical architecture and implementation strategy for refactoring the Samvaad mental health Flutter application from a prototype with API dependencies and in-memory storage to a production-ready, offline-first application with persistent data storage, real authentication, and enhanced user experience.

### Scope

The refactoring encompasses 13 major enhancement areas:

1. **Mood Tracking Analytics** - Persistent storage and visualization of emotional patterns
2. **Offline AI Models** - TensorFlow Lite integration for Emobot and Chatbot
3. **Functional UI Implementation** - Complete navigation and button functionality
4. **Profile Persistence** - SQLite database with encrypted storage
5. **Email OTP Verification** - SMTP-based authentication system
6. **Date Validation** - Birthdate picker with comprehensive validation
7. **UI/UX Redesign** - Professional flash cards and modern components
8. **Enhanced Navigation** - Hamburger menu, breadcrumbs, and FAB implementation
9. **Multi-Language Support** - Offline translation with TensorFlow Lite
10. **Voice Navigation** - Speech recognition for hands-free control
11. **Image Upload** - Profile photo capture and compression
12. **Document Upload** - Secure credential storage for professionals
13. **Comprehensive Profile** - Activity statistics and data export

### Technology Stack

- **Framework**: Flutter 3.7.2+ with Dart SDK
- **Database**: SQLite with sqflite package (^2.3.0)
- **Encryption**: encrypt package (^5.0.3) for AES-256
- **AI Models**: TensorFlow Lite Flutter plugin (^0.10.0)
- **Email Service**: mailer package (^6.0.1) for SMTP
- **Speech Recognition**: speech_to_text package (^6.6.0)
- **Image Processing**: image_picker (^1.0.7), image (^4.1.7)
- **File Handling**: file_picker (^6.1.1), path_provider (^2.1.2)
- **Charts**: fl_chart (^0.66.0) for mood visualization
- **State Management**: Provider (^6.1.1)
- **Localization**: flutter_localizations, intl (^0.18.1)

### Design Principles

1. **Offline-First Architecture** - All core features function without network connectivity
2. **Data Privacy** - AES-256 encryption for sensitive user data
3. **Performance** - Sub-3-second app launch, sub-2-second AI responses
4. **Accessibility** - Voice navigation, multi-language support, WCAG considerations
5. **Scalability** - Modular architecture supporting future feature additions
6. **Testability** - Clear separation of concerns enabling comprehensive testing

## Architecture

### High-Level Architecture

The application follows a layered architecture pattern:

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                       │
│  (Screens, Widgets, UI Components, Voice Interface)         │
└─────────────────────────────────────────────────────────────┘
                            ↓↑
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                      │
│  (Providers, Services, State Management, Navigation)        │
└─────────────────────────────────────────────────────────────┘
                            ↓↑
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  (Repositories, Database, File System, Encryption)          │
└─────────────────────────────────────────────────────────────┘
                            ↓↑
┌─────────────────────────────────────────────────────────────┐
│                   Infrastructure Layer                       │
│  (SQLite, TFLite Models, SMTP, Device APIs)                 │
└─────────────────────────────────────────────────────────────┘
```

### Architectural Patterns

**1. Repository Pattern**
- Abstracts data sources (database, file system, models)
- Provides clean API for business logic layer
- Enables easy testing with mock repositories

**2. Provider Pattern (State Management)**
- Centralized state management using Provider package
- Reactive UI updates on state changes
- Scoped providers for feature-specific state

**3. Service Layer Pattern**
- Encapsulates business logic in service classes
- AI services, authentication services, translation services
- Reusable across multiple screens

**4. Factory Pattern**
- Model factories for TensorFlow Lite initialization
- Database connection factory with connection pooling
- Email service factory for SMTP configuration

### Offline-First Strategy

The application implements a comprehensive offline-first architecture:

**Data Synchronization**
- All user data stored locally in SQLite
- Background sync queue for operations requiring network
- Conflict resolution using last-write-wins strategy
- Sync status indicators in UI

**AI Model Management**
- Models bundled with app installation (initial ~50MB)
- Incremental model updates via WiFi-only downloads
- Model versioning and rollback capability
- Fallback to rule-based responses if model fails

**Asset Caching**
- All static assets (images, icons, fonts) bundled
- Dynamic content cached with expiration policies
- Cache invalidation on app updates

### Security Architecture

**Data Encryption**
- AES-256-GCM for sensitive user data at rest
- Encryption keys derived from device-specific identifiers
- Secure key storage using flutter_secure_storage
- Encrypted database fields: email, journal entries, documents

**Authentication Security**
- OTP codes hashed with SHA-256 before storage
- Rate limiting on OTP generation (3 per 15 minutes)
- Session tokens with 30-day expiration
- Secure session storage with automatic cleanup

**File Security**
- Uploaded documents encrypted before storage
- File access restricted to app sandbox
- Secure deletion with overwrite on file removal

## Components and Interfaces

### Core Components

#### 1. Database Manager

**Responsibility**: Manages SQLite database lifecycle, migrations, and queries

**Interface**:
```dart
abstract class DatabaseManager {
  Future<Database> get database;
  Future<void> initialize();
  Future<void> close();
  Future<void> migrate(int fromVersion, int toVersion);
}
```

**Implementation Details**:
- Singleton pattern for single database instance
- Connection pooling for concurrent access
- Automatic migration on version changes
- Transaction support for atomic operations

#### 2. Encryption Service

**Responsibility**: Handles encryption/decryption of sensitive data

**Interface**:
```dart
abstract class EncryptionService {
  Future<String> encrypt(String plaintext);
  Future<String> decrypt(String ciphertext);
  Future<Uint8List> encryptBytes(Uint8List data);
  Future<Uint8List> decryptBytes(Uint8List data);
  Future<void> rotateKeys();
}
```

**Implementation Details**:
- AES-256-GCM encryption algorithm
- PBKDF2 key derivation with 100,000 iterations
- Random IV generation for each encryption
- Key rotation support for enhanced security

#### 3. AI Model Service

**Responsibility**: Manages TensorFlow Lite models for offline AI functionality

**Interface**:
```dart
abstract class AIModelService {
  Future<void> loadModels();
  Future<String> generateResponse(String input, ConversationContext context);
  Future<bool> detectCrisis(String text);
  Future<double> analyzeSentiment(String text);
  Future<void> updateModels();
  bool get isLoaded;
}
```

**Implementation Details**:
- Lazy loading of models on first use
- Model caching in memory for performance
- Context window of 10 messages for conversation
- Crisis keyword detection with ML-based scoring

**Models**:
- **Emobot Model**: Fine-tuned DistilBERT for emotional support (~40MB)
- **Chatbot Model**: MobileBERT for general conversation (~25MB)
- **Sentiment Analyzer**: TFLite sentiment model (~5MB)
- **Crisis Detector**: Binary classifier for crisis detection (~8MB)

#### 4. Translation Service

**Responsibility**: Provides offline multi-language translation

**Interface**:
```dart
abstract class TranslationService {
  Future<void> loadLanguage(String languageCode);
  Future<String> translate(String text, String targetLanguage);
  Future<void> downloadLanguageModel(String languageCode);
  List<String> get supportedLanguages;
  String get currentLanguage;
}
```

**Implementation Details**:
- On-device translation using TFLite models
- Language models: Hindi, Tamil, Telugu, Bengali, Marathi
- Model size: ~15MB per language pair
- Fallback to English if translation fails

#### 5. OTP Service

**Responsibility**: Generates and validates one-time passwords

**Interface**:
```dart
abstract class OTPService {
  Future<String> generateOTP(String email);
  Future<bool> validateOTP(String email, String otp);
  Future<void> sendOTPEmail(String email, String otp);
  Future<void> invalidateOTP(String email);
  Future<bool> canResendOTP(String email);
}
```

**Implementation Details**:
- 6-digit numeric OTP generation
- 10-minute expiration window
- SHA-256 hashing before storage
- Rate limiting: 3 attempts per 15 minutes
- SMTP integration for email delivery

#### 6. Voice Navigation Service

**Responsibility**: Handles speech recognition and command routing

**Interface**:
```dart
abstract class VoiceNavigationService {
  Future<void> startListening();
  Future<void> stopListening();
  Stream<String> get recognizedText;
  Future<NavigationCommand?> parseCommand(String text);
  List<VoiceCommand> get availableCommands;
}
```

**Implementation Details**:
- On-device speech recognition
- Command pattern matching with fuzzy logic
- Multi-language command support
- Audio feedback for command confirmation

#### 7. File Upload Service

**Responsibility**: Manages image and document uploads

**Interface**:
```dart
abstract class FileUploadService {
  Future<String> uploadProfilePhoto(File image);
  Future<String> uploadDocument(File document, DocumentType type);
  Future<void> deleteFile(String filePath);
  Future<File> compressImage(File image, int maxSizeKB);
  Future<bool> validateFile(File file, FileType type);
}
```

**Implementation Details**:
- Image compression to max 500KB
- Document encryption before storage
- File validation (format, size, content)
- Progress tracking for large uploads

### Data Repositories

#### User Repository

**Responsibility**: CRUD operations for user profiles

**Interface**:
```dart
abstract class UserRepository {
  Future<User?> getUserById(String userId);
  Future<void> createUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String userId);
  Future<Map<String, dynamic>> exportUserData(String userId);
}
```

#### Mood Repository

**Responsibility**: Manages mood tracking data

**Interface**:
```dart
abstract class MoodRepository {
  Future<void> saveMoodCheckIn(MoodCheckIn checkIn);
  Future<List<MoodCheckIn>> getMoodHistory(String userId, DateRange range);
  Future<MoodStatistics> getMoodStatistics(String userId, DateRange range);
  Future<List<MoodPattern>> detectPatterns(String userId);
}
```

#### Journal Repository

**Responsibility**: Manages journal entries

**Interface**:
```dart
abstract class JournalRepository {
  Future<void> saveEntry(JournalEntry entry);
  Future<JournalEntry?> getEntry(String entryId);
  Future<List<JournalEntry>> getEntries(String userId, DateRange range);
  Future<void> deleteEntry(String entryId);
  Future<List<JournalEntry>> searchEntries(String userId, String query);
}
```

#### Conversation Repository

**Responsibility**: Stores AI conversation history

**Interface**:
```dart
abstract class ConversationRepository {
  Future<void> saveMessage(Message message);
  Future<List<Message>> getConversation(String userId, String botType);
  Future<ConversationContext> getContext(String userId, String botType);
  Future<void> clearConversation(String userId, String botType);
}
```

### State Management

**Provider Architecture**:

```dart
// User state
class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<void> updateProfile(User user);
}

// Mood tracking state
class MoodProvider extends ChangeNotifier {
  List<MoodCheckIn> _moodHistory = [];
  MoodStatistics? _statistics;
  
  Future<void> addMoodCheckIn(MoodCheckIn checkIn);
  Future<void> loadMoodHistory(DateRange range);
  Future<void> refreshStatistics();
}

// AI conversation state
class AIConversationProvider extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isTyping = false;
  
  Future<void> sendMessage(String text);
  Future<void> loadConversation();
  void clearConversation();
}

// Language state
class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';
  
  Future<void> changeLanguage(String languageCode);
  String translate(String key);
}
```

