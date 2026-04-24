import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../utils/constants.dart';

/// Service for voice-based navigation and commands
class VoiceNavigationService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastRecognizedText = '';
  Function(String)? _onCommandRecognized;
  Function(String)? _onTextRecognized;

  bool get isListening => _isListening;
  String get lastRecognizedText => _lastRecognizedText;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      debugPrint('Microphone permission denied');
      return false;
    }

    // Initialize speech recognition
    _isInitialized = await _speech.initialize(
      onError: (error) => debugPrint('Speech recognition error: $error'),
      onStatus: (status) => debugPrint('Speech recognition status: $status'),
    );

    return _isInitialized;
  }

  /// Start listening for voice commands
  Future<void> startListening({
    Function(String)? onCommandRecognized,
    Function(String)? onTextRecognized,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }

    if (_isListening) return;

    _onCommandRecognized = onCommandRecognized;
    _onTextRecognized = onTextRecognized;

    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        _lastRecognizedText = result.recognizedWords.toLowerCase();
        _onTextRecognized?.call(_lastRecognizedText);

        if (result.finalResult) {
          _processCommand(_lastRecognizedText);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speech.stop();
    _isListening = false;
  }

  /// Process recognized command
  void _processCommand(String text) {
    final command = _matchCommand(text);
    if (command != null) {
      _onCommandRecognized?.call(command);
    }
  }

  /// Match recognized text to a command using fuzzy matching
  String? _matchCommand(String text) {
    for (final entry in AppConstants.voiceCommands.entries) {
      for (final phrase in entry.value) {
        if (text.contains(phrase.toLowerCase())) {
          return entry.key;
        }
      }
    }
    return null;
  }

  /// Get available commands
  Map<String, List<String>> getAvailableCommands() {
    return AppConstants.voiceCommands;
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Dispose resources
  void dispose() {
    _speech.stop();
    _speech.cancel();
  }
}
