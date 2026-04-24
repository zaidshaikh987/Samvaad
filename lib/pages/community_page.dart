// lib/pages/community_page.dart
// Feature 5: Community Safety Moderation AI

import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/screens/post_detail_screen.dart';
import 'package:samvaad/services/ai_mental_health_service.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<Map<String, dynamic>> _posts = [
    {
      'community': 'Anxiety & Depression',
      'time': '2h ago',
      'content':
          'Finally managed to go outside today after weeks of struggling. Small steps matter.',
      'likes': 24,
      'comments': 8,
      'flagged': false,
    },
    {
      'community': 'Relationship Issues',
      'time': '5h ago',
      'content':
          'Had an honest conversation with my friend about boundaries. It was hard but necessary.',
      'likes': 18,
      'comments': 5,
      'flagged': false,
    },
  ];

  // FEATURE 5: Post creation with moderation
  void _showCreatePostSheet() {
    final TextEditingController contentController = TextEditingController();
    String? _selectedCommunity = 'Anxiety & Depression';
    bool _isHarmful = false;
    bool _isAnalyzing = false;
    StateSetter? _sheetSetState;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          _sheetSetState = setSheetState;
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.calm.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined,
                          color: AppColors.calm, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'New Anonymous Post',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '🛡️ Safe Space — AI moderation is active',
                  style: TextStyle(fontSize: 12, color: AppColors.greyText),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCommunity,
                  decoration: InputDecoration(
                    labelText: 'Community',
                    filled: true,
                    fillColor: AppColors.lightGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Anxiety & Depression',
                        child: Text('Anxiety & Depression')),
                    DropdownMenuItem(
                        value: 'Relationship Issues',
                        child: Text('Relationship Issues')),
                    DropdownMenuItem(
                        value: 'Financial Stress',
                        child: Text('Financial Stress')),
                    DropdownMenuItem(
                        value: 'Abuse Support', child: Text('Abuse Support')),
                  ],
                  onChanged: (v) =>
                      setSheetState(() => _selectedCommunity = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  onChanged: (val) {
                    if (_isHarmful) {
                      setSheetState(() => _isHarmful = false);
                    }
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Share your thoughts anonymously...',
                    filled: true,
                    fillColor: AppColors.lightGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                // FEATURE 5: Moderation warning
                if (_isHarmful) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange.shade700, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '⚠️ This post may violate community guidelines. Please revise before posting.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.deepOrange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isHarmful || _isAnalyzing || contentController.text.trim().isEmpty)
                        ? null
                        : () async {
                            final text = contentController.text.trim();
                            
                            setSheetState(() {
                              _isAnalyzing = true;
                              _isHarmful = false;
                            });
                            
                            final harmful = await AIMentalHealthService.detectHarmfulContent(text);
                            
                            if (!mounted) return;
                            
                            if (harmful) {
                              setSheetState(() {
                                _isAnalyzing = false;
                                _isHarmful = true;
                              });
                              return;
                            }

                            Navigator.of(ctx).pop();
                            setState(() {
                              _posts.insert(0, {
                                'community': _selectedCommunity ?? 'General',
                                'time': 'Just now',
                                'content': text,
                                'likes': 0,
                                'comments': 0,
                                'flagged': false,
                              });
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('Post shared anonymously ✓'),
                                  ],
                                ),
                                backgroundColor: AppColors.calm,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isHarmful ? AppColors.greyText : AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isAnalyzing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Share Anonymously',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(top: 10.0, bottom: 90.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 4.0),
                child: Row(
                  children: [
                    const Text(
                      'Find your people and share anonymously',
                      style:
                          TextStyle(fontSize: 14.0, color: AppColors.greyText),
                    ),
                    const SizedBox(width: 8),
                    // FEATURE 5: Safe Space badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.calm.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined,
                              size: 11, color: AppColors.calm),
                          SizedBox(width: 3),
                          Text('Safe Space',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.calm,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              _buildCommunityCategoryList(context),
              const SizedBox(height: 30.0),
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

        // FAB now opens the post creation sheet with moderation
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _showCreatePostSheet,
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
      {
        'title': 'Relationship Issues',
        'members': 42,
        'icon': Icons.favorite_outline
      },
      {
        'title': 'Financial Stress',
        'members': 28,
        'icon': Icons.payments_outlined
      },
      {
        'title': 'Abuse Support',
        'members': 18,
        'icon': Icons.shield_outlined
      },
      {
        'title': 'Anxiety & Depression',
        'members': 38,
        'icon': Icons.psychology_outlined
      },
    ];

    return Column(
      children: [
        ...categories
            .map((category) => _buildCategoryCard(context, category)),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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

  Widget _buildCategoryCard(
      BuildContext context, Map<String, dynamic> category) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child:
              Icon(category['icon'], color: AppColors.primary, size: 20),
        ),
        title: Text(
          category['title'],
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: AppColors.darkText),
        ),
        subtitle: Text(
          '${category['members']} members active',
          style: const TextStyle(color: AppColors.greyText, fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14.0, color: AppColors.greyText),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Entering ${category['title']} community')),
          );
        },
      ),
    );
  }

  Widget _buildPostList(BuildContext context) {
    return Column(
      children: _posts.map((post) => _buildPostCard(context, post)).toList(),
    );
  }

  Widget _buildPostCard(
      BuildContext context, Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      elevation: 0,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(PostDetailScreen.routeName, arguments: post);
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
                        child: Text('?',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.primary)),
                      ),
                      const SizedBox(width: 8.0),
                      Text(post['community'],
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      // FEATURE 5: Moderation badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.calm.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_user_outlined,
                                size: 10, color: AppColors.calm),
                            SizedBox(width: 2),
                            Text('AI Reviewed',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.calm,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(post['time'],
                          style: const TextStyle(
                              color: AppColors.greyText, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(post['content'],
                  style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.darkText,
                      height: 1.4)),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  _buildPostStat(Icons.favorite_border, '${post['likes']}'),
                  const SizedBox(width: 20.0),
                  _buildPostStat(
                      Icons.mode_comment_outlined, '${post['comments']}'),
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
        Text(count,
            style:
                const TextStyle(color: AppColors.greyText, fontSize: 13)),
      ],
    );
  }
}