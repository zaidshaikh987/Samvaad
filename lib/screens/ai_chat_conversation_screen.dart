// lib/screens/ai_chat_conversation_screen.dart
// Feature 4: Crisis Detection System with Hugging Face AI Integration

import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/services/ai_mental_health_service.dart';
import 'package:samvaad/services/offline_ai_service.dart';
import 'package:samvaad/utils/app_routes.dart';

class AIChatConversationScreen extends StatefulWidget {
  static const String routeName = '/ai-chat-conversation';
  const AIChatConversationScreen({super.key});

  @override
  State<AIChatConversationScreen> createState() =>
      _AIChatConversationScreenState();
}

class _AIChatConversationScreenState extends State<AIChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OfflineAIService _aiService = OfflineAIService();

  bool _crisisDetected = false;
  bool _crisisBannerDismissed = false;

  final List<Map<String, dynamic>> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String companionName) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'User', 'text': text, 'isUser': true});
      _messageController.clear();
      // Add typing indicator
      _messages.add({
        'sender': companionName,
        'text': '...',
        'isUser': false,
        'isTyping': true,
      });
    });
    _scrollToBottom();

    // Detect crisis
    final isCrisis = await AIMentalHealthService.detectCrisis(text);

    // Generate AI response based on companion type
    String aiResponse;
    try {
      if (companionName.toLowerCase().contains('emobot')) {
        aiResponse = await _aiService.generateEmobotResponse(text);
      } else {
        aiResponse = await _aiService.generateChatbotResponse(text);
      }
    } catch (e) {
      aiResponse = 'I\'m having trouble connecting right now. Please try again in a moment.';
      print('AI response error: $e');
    }

    if (!mounted) return;

    setState(() {
      // Remove typing indicator
      _messages.removeLast();

      if (isCrisis) {
        _crisisDetected = true;
        _crisisBannerDismissed = false;
      }
      
      // Add AI response
      _messages.add({
        'sender': companionName,
        'text': aiResponse,
        'isUser': false,
      });
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String companionName =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'AI Companion';

    // Pre-populate initial message if empty
    if (_messages.isEmpty) {
      _messages.add({
        'sender': companionName,
        'text': 'Hey! I\'m $companionName. How can I help you today?',
        'isUser': false,
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(companionName),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.videocam_outlined),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // FEATURE 4: Crisis Banner
          if (_crisisDetected && !_crisisBannerDismissed)
            _buildCrisisBanner(context),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg['isTyping'] == true) {
                  return _buildTypingIndicator();
                }
                return _buildChatMessage(
                  msg['sender'],
                  msg['text'],
                  isUser: msg['isUser'],
                );
              },
            ),
          ),
          _buildMessageInput(context, companionName),
        ],
      ),
    );
  }

  // FEATURE 4: Crisis Detection Banner
  Widget _buildCrisisBanner(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'We noticed you may be struggling 💙',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF8B0000),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _crisisBannerDismissed = true),
                child: const Icon(Icons.close, size: 18, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'re not alone. iCall Helpline: 9152987821 (Mon–Sat, 8am–10pm)',
            style: TextStyle(fontSize: 13, color: Color(0xFF5C0000), height: 1.4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(AppRoutes.therapistBookingScreen);
                  },
                  icon: const Icon(Icons.medical_services_outlined, size: 16),
                  label: const Text('Talk to Therapist',
                      style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0).copyWith(bottomLeft: Radius.zero),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text(
              'Analyzing...',
              style: TextStyle(color: AppColors.darkText, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(String sender, String text, {required bool isUser}) {
    final Color bubbleColor = isUser ? AppColors.primary : Colors.white;
    final Color textColor = isUser ? Colors.white : AppColors.darkText;
    final Alignment alignment =
        isUser ? Alignment.centerRight : Alignment.centerLeft;
    final BorderRadius borderRadius = BorderRadius.circular(16.0);

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: isUser
                  ? borderRadius.copyWith(bottomRight: Radius.zero)
                  : borderRadius.copyWith(bottomLeft: Radius.zero),
              boxShadow: isUser
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
            ),
            child: Text(
              text,
              style: TextStyle(color: textColor, height: 1.4),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Just now',
            style: TextStyle(fontSize: 10.0, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, String companionName) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Share your thoughts...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                ),
                onSubmitted: (_) => _sendMessage(companionName),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(companionName),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
