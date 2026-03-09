import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';

class PostDetailScreen extends StatelessWidget {
  static const String routeName = '/post-detail';
  const PostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data based on the community post structure
    final Map<String, dynamic> post =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {
              'community': 'Anxiety & Depression',
              'time': '2h ago',
              'content':
              'Finally managed to go outside today after weeks of struggling. Small steps matter. I\'ve been dealing with agoraphobia and today was a breakthrough.',
              'likes': 24,
              'comments': 8,
            };

    final List<Map<String, dynamic>> comments = [
      {'time': '1h ago', 'content': 'I\'m so proud of you! Every step counts. 💙'},
      {'time': '2h ago', 'content': 'This resonates with me. You\'re doing amazing!'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original Post Content
                  _buildPostContent(post),
                  const SizedBox(height: 30.0),

                  const Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Comments List
                  ...comments.map((comment) => _buildCommentTile(comment)),
                ],
              ),
            ),
          ),
          // Comment Input Section
          _buildCommentInput(context),
        ],
      ),
    );
  }

  Widget _buildPostContent(Map<String, dynamic> post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('AN', style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold)), // Anonymous Avatar
                const SizedBox(width: 8.0),
                Text(post['community'], style: const TextStyle(color: AppColors.primary, fontSize: 13)),
              ],
            ),
            const Icon(Icons.bookmark_border, color: AppColors.greyText),
          ],
        ),
        const SizedBox(height: 8.0),
        Text(post['content'], style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12.0),
        Row(
          children: [
            const Icon(Icons.favorite_border, size: 20, color: AppColors.greyText),
            const SizedBox(width: 4.0),
            Text('${post['likes']}', style: const TextStyle(color: AppColors.greyText)),
            const SizedBox(width: 20.0),
            const Icon(Icons.comment_outlined, size: 20, color: AppColors.greyText),
            const SizedBox(width: 4.0),
            Text('${post['comments']}', style: const TextStyle(color: AppColors.greyText)),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentTile(Map<String, dynamic> comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Anonymous Avatar Placeholder
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.lightGrey,
            child: Text('AN', style: TextStyle(color: AppColors.darkText, fontSize: 14)),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Anonymous',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      comment['time'],
                      style: const TextStyle(color: AppColors.greyText, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(comment['content']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGrey,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Add a supportive comment...',
                filled: true,
                fillColor: AppColors.lightGrey.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle posting the comment
                },
                child: const Text('Post Comment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
