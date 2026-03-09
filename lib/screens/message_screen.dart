import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';

class MessagesScreen extends StatefulWidget {
  static const String routeName = '/messages';
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _selectedTab = 'Primary'; // Primary, General, Professional

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: _buildSearchBar(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
            child: _buildTabBar(),
          ),
          Expanded(
            child: _buildMessageList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Search messages...',
        prefixIcon: const Icon(Icons.search, color: AppColors.greyText),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final List<String> tabs = ['Primary', 'General', 'Professional'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tabs.map((tab) {
        bool isSelected = _selectedTab == tab;
        return Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedTab = tab;
              });
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent.withOpacity(0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.greyText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageList() {
    // Mock data changes based on the selected tab
    final List<Map<String, dynamic>> primaryMessages = [
      {'initials': 'SW', 'name': 'Sarah Williams', 'message': 'Hope you are doing well!', 'time': '2h ago', 'unread': 1, 'color': AppColors.primary},
      {'initials': 'MC', 'name': 'Mike Chen', 'message': 'See you tomorrow!', 'time': '5h ago', 'unread': 0, 'color': AppColors.happy},
    ];

    final List<Map<String, dynamic>> generalMessages = [
      {'initials': 'AU', 'name': 'Anonymous User', 'message': 'Thank you for your support', 'time': '1d ago', 'unread': 2, 'color': AppColors.calm},
      {'initials': 'CM', 'name': 'Community Member', 'message': 'How are you feeling today?', 'time': '2d ago', 'unread': 0, 'color': AppColors.sad},
    ];

    final List<Map<String, dynamic>> professionalMessages = [
      {'initials': 'DJ', 'name': 'Dr. Sarah Johnson', 'message': 'See you at our session tomorrow!', 'time': '3h ago', 'unread': 0, 'color': AppColors.primary},
      {'initials': 'DM', 'name': 'Dr. James Miller', 'message': 'Your progress has been great', 'time': '1d ago', 'unread': 1, 'color': AppColors.happy},
    ];

    List<Map<String, dynamic>> currentMessages;
    if (_selectedTab == 'General') {
      currentMessages = generalMessages;
    } else if (_selectedTab == 'Professional') {
      currentMessages = professionalMessages;
    } else {
      currentMessages = primaryMessages;
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: currentMessages.length,
      itemBuilder: (context, index) {
        final msg = currentMessages[index];
        return _buildMessageTile(msg);
      },
    );
  }

  Widget _buildMessageTile(Map<String, dynamic> msg) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          // Navigate to individual chat screen
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar with Initials
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: msg['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: Text(
                    msg['initials'],
                    style: TextStyle(
                      color: msg['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              // Message Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      msg['message'],
                      style: TextStyle(
                        color: msg['unread'] > 0 ? AppColors.darkText : AppColors.greyText,
                        fontWeight: msg['unread'] > 0 ? FontWeight.w600 : FontWeight.normal,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Time and Unread Count
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg['time'],
                    style: TextStyle(
                      color: msg['unread'] > 0 ? AppColors.primary : AppColors.greyText,
                      fontSize: 13,
                    ),
                  ),
                  if (msg['unread'] > 0) ...[
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${msg['unread']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
