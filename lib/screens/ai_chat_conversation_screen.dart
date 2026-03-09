import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';

class AIChatConversationScreen extends StatelessWidget {
  static const String routeName = '/ai-chat-conversation';
  const AIChatConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Companion name passed as argument from the selection screen
    final String companionName =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'AI Companion';

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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                // Example AI Message (Brobot)
                _buildChatMessage(
                  companionName,
                  'Hey! I\'m $companionName. How can I help you tackle things today?',
                  isUser: false,
                ),
                // Example User Message
                _buildChatMessage(
                  'User',
                  'I\'m feeling overwhelmed with my schoolwork',
                  isUser: true,
                ),
                // Example AI Message (Brobot)
                _buildChatMessage(
                  companionName,
                  'I understand. Let\'s break this down. What\'s the most urgent task you need to handle?',
                  isUser: false,
                ),
              ],
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildChatMessage(String sender, String text, {required bool isUser}) {
    // Style mimicking the video design
    // Inside _buildChatMessage
final Color bubbleColor = isUser ? AppColors.primary : Colors.white; // Navy for user
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
              style: TextStyle(color: textColor),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            '2:00 PM', // Placeholder timestamp
            style: TextStyle(fontSize: 10.0, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

 Widget _buildMessageInput(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(20.0),
    decoration: BoxDecoration(
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
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.send, color: Colors.white, size: 20),
        )
      ],
    ),
  );
}
}
