// lib/pages/journal_page.dart
// Feature: Full journal with SQLite persistence + past entries list

import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';
import 'package:samvaad/data/repositories/journal_repository.dart';
import 'package:samvaad/services/user_session.dart';

class JournalPage extends StatefulWidget {
  static const String routeName = '/journal-entry';
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _contentController = TextEditingController();
  final JournalRepository _repo = JournalRepository();

  String? _selectedMood;
  bool _isSaving = false;
  List<JournalEntry> _entries = [];
  bool _isLoadingEntries = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEntries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoadingEntries = true);
    try {
      final userId = UserSession().userId;
      final entries = await _repo.getEntries(userId);
      if (mounted) setState(() => _entries = entries);
    } catch (e) {
      debugPrint('Error loading journal entries: $e');
    } finally {
      if (mounted) setState(() => _isLoadingEntries = false);
    }
  }

  Future<void> _saveEntry() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before saving')),
      );
      return;
    }
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood first')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final userId = UserSession().userId;
      final entry = JournalEntry(
        id: 'journal_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        content: content,
        mood: _selectedMood,
        createdAt: DateTime.now(),
      );
      await _repo.saveEntry(entry);

      _contentController.clear();
      setState(() => _selectedMood = null);
      await _loadEntries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Journal entry saved!'),
              ],
            ),
            backgroundColor: AppColors.calm,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        // Switch to Past Entries tab
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving entry: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteEntry(String entryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this journal entry?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _repo.deleteEntry(entryId);
      await _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: AppColors.primary.withOpacity(0.15),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.greyText,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                const Tab(text: 'New Entry'),
                Tab(
                    text:
                        'Past Entries${_entries.isNotEmpty ? ' (${_entries.length})' : ''}'),
              ],
            ),
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNewEntryTab(),
              _buildPastEntriesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewEntryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6.0),
          // Date header
          Text(
            _formatDate(DateTime.now()),
            style: const TextStyle(
                color: AppColors.greyText,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'How was your day?',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16.0),

          // Journal text area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: _contentController,
              maxLines: 8,
              minLines: 5,
              decoration: const InputDecoration(
                hintText:
                    'Write about your thoughts, feelings, or anything on your mind...',
                hintStyle: TextStyle(color: AppColors.greyText, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 28.0),
          const Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildMoodSelection(),
          const SizedBox(height: 32.0),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Save Entry',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMoodSelection() {
    final List<Map<String, dynamic>> moods = [
      {
        'label': 'Happy',
        'image': 'assets/images/smile.jpeg',
        'color': AppColors.happy
      },
      {
        'label': 'Calm',
        'image': 'assets/images/cry.jpeg',
        'color': AppColors.calm
      },
      {
        'label': 'Sad',
        'image': 'assets/images/sad.jpeg',
        'color': AppColors.sad
      },
      {
        'label': 'Anxious',
        'image': 'assets/images/angry.jpeg',
        'color': AppColors.anxious
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((mood) {
        bool isSelected = _selectedMood == mood['label'];
        return GestureDetector(
          onTap: () => setState(() => _selectedMood = mood['label'] as String),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 70,
                height: 70,
                padding: EdgeInsets.all(isSelected ? 3 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? mood['color'] as Color
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage(mood['image'] as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                mood['label'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      isSelected ? AppColors.darkText : AppColors.greyText,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPastEntriesTab() {
    if (_isLoadingEntries) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 60, color: AppColors.greyText.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'No journal entries yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start writing your first entry!',
              style: TextStyle(color: AppColors.greyText, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Write First Entry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length,
      itemBuilder: (ctx, i) => _buildEntryCard(_entries[i]),
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    final moodColor = _getMoodColor(entry.mood);
    final moodEmoji = _getMoodEmoji(entry.mood);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Entry'),
            content: const Text('Delete this journal entry?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _repo.deleteEntry(entry.id).then((_) => _loadEntries()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                      Text(moodEmoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: moodColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.mood ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: moodColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(entry.createdAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.greyText),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry.content,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkText,
                    height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry.content.length > 120) ...[
                const SizedBox(height: 6),
                Text(
                  'Tap to read more',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary.withOpacity(0.7)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getMoodColor(String? mood) {
    switch (mood) {
      case 'Happy':
        return AppColors.happy;
      case 'Calm':
        return AppColors.calm;
      case 'Sad':
        return AppColors.sad;
      case 'Anxious':
        return AppColors.anxious;
      default:
        return AppColors.greyText;
    }
  }

  String _getMoodEmoji(String? mood) {
    switch (mood) {
      case 'Happy':
        return '😊';
      case 'Calm':
        return '😌';
      case 'Sad':
        return '😢';
      case 'Anxious':
        return '😰';
      default:
        return '🙂';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}