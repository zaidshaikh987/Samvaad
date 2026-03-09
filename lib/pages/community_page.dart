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
          padding: const EdgeInsets.only(top: 10.0, bottom: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Community Categories
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Communities',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Find your people',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.greyText,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              _buildCommunityCategoryList(),
              const SizedBox(height: 30.0),

              // Recent Posts
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
        // Floating Action Button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              // Handle creating a new post
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityCategoryList() {
    final List<Map<String, dynamic>> categories = [
      {'title': 'Relationship Issues', 'members': 42},
      {'title': 'Financial Stress', 'members': 28},
      {'title': 'Abuse Support', 'members': 18},
      {'title': 'Anxiety & Depression', 'members': 38},
    ];

    return Column(
      children: [
        ...categories.map((category) => _buildCategoryCard(category)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                // Navigate to all communities view
              },
              child: const Text('View All Communities', style: TextStyle(color: AppColors.primary)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      child: ListTile(
        title: Text(
          category['title'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${category['members']} members',
          style: const TextStyle(color: AppColors.greyText),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16.0, color: AppColors.greyText),
        onTap: () {
          // Navigate to community detail page
        },
      ),
    );
  }

  Widget _buildPostList(BuildContext context) {
    final List<Map<String, dynamic>> posts = [
      {
        'community': 'Anxiety & Depression',
        'time': '2h ago',
        'content':
        'Finally managed to go outside today after weeks of struggling. Small steps matter. I\'ve been dealing with agoraphobia and today was a breakthrough.',
        'likes': 24,
        'comments': 8,
      },
      {
        'community': 'Relationship Issues',
        'time': '5h ago',
        'content':
        'Had an honest conversation with my friend about boundaries. It was hard but necessary.',
        'likes': 18,
        'comments': 5,
      },
      {
        'community': 'Work & Career',
        'time': '1d ago',
        'content':
        'Work has been overwhelming, but I\'m learning to take breaks without feeling guilty.',
        'likes': 32,
        'comments': 12,
      },
    ];

    return Column(
      children: posts.map((post) => _buildPostCard(context, post)).toList(),
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(PostDetailScreen.routeName, arguments: post);
        },
        borderRadius: BorderRadius.circular(16.0),
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
                      const Text('AN', style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold)), // Anonymous Avatar
                      const SizedBox(width: 8.0),
                      Text(post['community'], style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                    ],
                  ),
                  Text(post['time'], style: const TextStyle(color: AppColors.greyText, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(post['content'], style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  const Icon(Icons.favorite_border, size: 18, color: AppColors.greyText),
                  const SizedBox(width: 4.0),
                  Text('${post['likes']}', style: const TextStyle(color: AppColors.greyText)),
                  const SizedBox(width: 20.0),
                  const Icon(Icons.comment_outlined, size: 18, color: AppColors.greyText),
                  const SizedBox(width: 4.0),
                  Text('${post['comments']}', style: const TextStyle(color: AppColors.greyText)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
