import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/post_detail_screen.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(top: 10.0, bottom: 90.0), // Extra bottom padding for FAB
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Communities',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Find your people and share anonymously',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.greyText,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Community Categories
              _buildCommunityCategoryList(context),
              const SizedBox(height: 30.0),

              // Recent Posts Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Recent Posts',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              _buildPostList(context),
            ],
          ),
        ),

        // Floating Action Button for New Posts
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              // This should navigate to your CreatePostScreen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Anonymous Post Editor...')),
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityCategoryList(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'title': 'Relationship Issues', 'members': 42, 'icon': Icons.favorite_outline},
      {'title': 'Financial Stress', 'members': 28, 'icon': Icons.payments_outlined},
      {'title': 'Abuse Support', 'members': 18, 'icon': Icons.shield_outlined},
      {'title': 'Anxiety & Depression', 'members': 38, 'icon': Icons.psychology_outlined},
    ];

    return Column(
      children: [
        // Map categories to clickable cards
        ...categories.map((category) => _buildCategoryCard(context, category)),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text('View All Communities'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(category['icon'], color: AppColors.primary, size: 20),
        ),
        title: Text(
          category['title'],
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkText),
        ),
        subtitle: Text(
          '${category['members']} members active',
          style: const TextStyle(color: AppColors.greyText, fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14.0, color: AppColors.greyText),
        onTap: () {
          // Navigate to specific community thread
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Entering ${category['title']} community')),
          );
        },
      ),
    );
  }

  Widget _buildPostList(BuildContext context) {
    final List<Map<String, dynamic>> posts = [
      {
        'community': 'Anxiety & Depression',
        'time': '2h ago',
        'content': 'Finally managed to go outside today after weeks of struggling. Small steps matter.',
        'likes': 24,
        'comments': 8,
      },
      {
        'community': 'Relationship Issues',
        'time': '5h ago',
        'content': 'Had an honest conversation with my friend about boundaries. It was hard but necessary.',
        'likes': 18,
        'comments': 5,
      },
    ];

    return Column(
      children: posts.map((post) => _buildPostCard(context, post)).toList(),
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(PostDetailScreen.routeName, arguments: post);
        },
        borderRadius: BorderRadius.circular(20.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.secondary,
                        child: Text('?', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                      ),
                      const SizedBox(width: 8.0),
                      Text(post['community'], 
                        style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(post['time'], style: const TextStyle(color: AppColors.greyText, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(post['content'], 
                style: const TextStyle(fontSize: 15, color: AppColors.darkText, height: 1.4)),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  _buildPostStat(Icons.favorite_border, '${post['likes']}'),
                  const SizedBox(width: 20.0),
                  _buildPostStat(Icons.mode_comment_outlined, '${post['comments']}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostStat(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.greyText),
        const SizedBox(width: 4.0),
        Text(count, style: const TextStyle(color: AppColors.greyText, fontSize: 13)),
      ],
    );
  }
}