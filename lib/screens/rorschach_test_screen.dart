// lib/screens/rorschach_test_screen.dart
// Feature: Multi-question Rorschach-inspired psychological self-assessment
// with personality result analysis

import 'package:flutter/material.dart';
import 'package:samvaad/utils/app_colors.dart';

class RorschachTestScreen extends StatefulWidget {
  static const String routeName = '/rorschach-test';
  const RorschachTestScreen({super.key});

  @override
  State<RorschachTestScreen> createState() => _RorschachTestScreenState();
}

class _RorschachTestScreenState extends State<RorschachTestScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestion = 0;
  final List<String?> _selectedAnswers = List.filled(6, null);
  bool _showResult = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Self-assessment questions with abstract inkblot-inspired descriptions
  final List<Map<String, dynamic>> _questions = [
    {
      'prompt': 'Look at this abstract shape. What does it most remind you of?',
      'icon': Icons.water_drop,
      'color': const Color(0xFF6C5CE7),
      'options': [
        {'text': 'Two people reaching out to each other', 'trait': 'social'},
        {'text': 'A butterfly spreading its wings', 'trait': 'creative'},
        {'text': 'Storm clouds forming', 'trait': 'anxious'},
        {'text': 'A peaceful mountain range', 'trait': 'calm'},
      ],
    },
    {
      'prompt': 'What feeling does this pattern evoke in you?',
      'icon': Icons.blur_on,
      'color': const Color(0xFF00B894),
      'options': [
        {'text': 'Excitement and energy', 'trait': 'energetic'},
        {'text': 'Quiet reflection', 'trait': 'introspective'},
        {'text': 'A sense of wonder', 'trait': 'creative'},
        {'text': 'Slight unease', 'trait': 'anxious'},
      ],
    },
    {
      'prompt': 'In this image, your eye is first drawn to...',
      'icon': Icons.remove_red_eye_outlined,
      'color': const Color(0xFFE17055),
      'options': [
        {'text': 'The dark center — there\'s something hidden', 'trait': 'introspective'},
        {'text': 'The outer edges — full of movement', 'trait': 'energetic'},
        {'text': 'The overall harmony and balance', 'trait': 'calm'},
        {'text': 'The contrast between light and shadow', 'trait': 'creative'},
      ],
    },
    {
      'prompt': 'If this shape were a living creature, it would be...',
      'icon': Icons.pets,
      'color': const Color(0xFFFDAB00),
      'options': [
        {'text': 'A soaring eagle — free and independent', 'trait': 'energetic'},
        {'text': 'A wise owl — quiet and observant', 'trait': 'introspective'},
        {'text': 'A playful dolphin — social and joyful', 'trait': 'social'},
        {'text': 'A tortoise — patient and grounded', 'trait': 'calm'},
      ],
    },
    {
      'prompt': 'The first word that comes to mind when you see this is...',
      'icon': Icons.psychology_outlined,
      'color': const Color(0xFF0984E3),
      'options': [
        {'text': 'Connection', 'trait': 'social'},
        {'text': 'Transformation', 'trait': 'creative'},
        {'text': 'Stillness', 'trait': 'calm'},
        {'text': 'Tension', 'trait': 'anxious'},
      ],
    },
    {
      'prompt': 'If you could step into this image, you would...',
      'icon': Icons.open_in_full,
      'color': const Color(0xFFA29BFE),
      'options': [
        {'text': 'Explore every corner with curiosity', 'trait': 'creative'},
        {'text': 'Find someone to share it with', 'trait': 'social'},
        {'text': 'Sit quietly and absorb the atmosphere', 'trait': 'introspective'},
        {'text': 'Find the safest, most comfortable spot', 'trait': 'calm'},
      ],
    },
  ];

  // Personality profiles keyed by dominant trait
  final Map<String, Map<String, dynamic>> _personalities = {
    'social': {
      'title': 'The Connector',
      'emoji': '🤝',
      'color': const Color(0xFF00B894),
      'description':
          'You are deeply attuned to your relationships and the world of people around you. You draw energy from connection, communication, and shared experiences. Your emotional intelligence is one of your greatest strengths — you notice when others are struggling before they even say a word.',
      'strengths': ['Empathetic', 'Communicative', 'Supportive', 'Socially aware'],
      'tip': 'Remember to invest the same compassionate energy in yourself that you give to others. Alone time for reflection can recharge your empathetic gifts.',
    },
    'creative': {
      'title': 'The Visionary',
      'emoji': '🎨',
      'color': const Color(0xFF6C5CE7),
      'description':
          'Your mind works in patterns, symbols, and meanings that others might overlook. You approach life with curiosity and see possibilities where others see walls. Creative expression — whether through art, writing, problem-solving, or imagination — is central to your emotional wellbeing.',
      'strengths': ['Imaginative', 'Innovative', 'Open-minded', 'Pattern-seeking'],
      'tip': 'When feeling emotionally overwhelmed, channel your feelings into creative output. Journaling, art, or even doodling can unlock emotional clarity for your type.',
    },
    'introspective': {
      'title': 'The Deep Thinker',
      'emoji': '🌌',
      'color': const Color(0xFF0984E3),
      'description':
          'You process the world through deep inner reflection before expressing outward. You value authenticity, meaning, and self-understanding above surface-level experience. Solitude doesn\'t frighten you — it energises you. You likely keep a rich inner world that few are privileged to see.',
      'strengths': ['Self-aware', 'Thoughtful', 'Authentic', 'Philosophical'],
      'tip': 'Your strength is reflection, but be mindful of over-analysis. Sometimes, sharing your inner world with a trusted person — or a journal — can prevent emotional build-up.',
    },
    'calm': {
      'title': 'The Steady Anchor',
      'emoji': '⚓',
      'color': AppColors.calm,
      'description':
          'You possess a remarkable inner stability that others gravitate towards during turbulent times. You process emotions methodically rather than reactively, which gives you resilience and perspective most people admire. Your presence is inherently calming to those around you.',
      'strengths': ['Resilient', 'Patient', 'Grounded', 'Reliable'],
      'tip': 'Your calm exterior can sometimes mask deeper emotions you haven\'t fully processed. Regular check-ins with your inner state — through breathing exercises or journaling — can help sustain your equilibrium.',
    },
    'energetic': {
      'title': 'The Dynamo',
      'emoji': '⚡',
      'color': const Color(0xFFFDAB00),
      'description':
          'You bring energy, spontaneity, and enthusiasm to everything you take on. You are action-oriented, motivated by momentum, and thrive in dynamic environments. Routine can feel constraining to your spirited nature — you actively seek growth and new experiences.',
      'strengths': ['Enthusiastic', 'Motivated', 'Adaptable', 'Inspiring'],
      'tip': 'High energy, if unchecked, can turn to anxiety or restlessness. Incorporating brief mindfulness or breathing exercises into your day helps channel your vitality constructively.',
    },
    'anxious': {
      'title': 'The Sensitive Sensor',
      'emoji': '🌡️',
      'color': const Color(0xFFE17055),
      'description':
          'You are highly attuned to threats, subtleties, and changes in your environment — a trait that, when channelled well, makes you perceptive, careful, and deeply thoughtful. Your anxiety is often a signal of how much you care. Learning to work with it rather than against it is key to your emotional flourishing.',
      'strengths': ['Perceptive', 'Detail-oriented', 'Careful', 'Deeply caring'],
      'tip': 'Anxiety is information, not identity. The Samvaad breathing exercise (📚 Dashboard → Breathing Exercise) and talking to Emobot can be transformative for your emotional pattern.',
    },
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectAnswer(String trait) {
    setState(() => _selectedAnswers[_currentQuestion] = trait);
  }

  void _nextQuestion() {
    if (_selectedAnswers[_currentQuestion] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select an answer before continuing')),
      );
      return;
    }

    _animController.reverse().then((_) {
      setState(() {
        if (_currentQuestion < _questions.length - 1) {
          _currentQuestion++;
        } else {
          _showResult = true;
        }
        _animController.forward();
      });
    });
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      _animController.reverse().then((_) {
        setState(() => _currentQuestion--);
        _animController.forward();
      });
    }
  }

  String _getDominantTrait() {
    final counts = <String, int>{};
    for (final t in _selectedAnswers) {
      if (t != null) counts[t] = (counts[t] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Self Assessment',
              style: TextStyle(
                  color: AppColors.darkText, fontWeight: FontWeight.bold),
            ),
            if (!_showResult) ...[
              const Spacer(),
              Text(
                '${_currentQuestion + 1} / ${_questions.length}',
                style: const TextStyle(
                    color: AppColors.greyText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _showResult ? _buildResultView() : _buildQuestionView(),
    );
  }

  Widget _buildQuestionView() {
    final q = _questions[_currentQuestion];
    final color = q['color'] as Color;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentQuestion + 1) / _questions.length,
                minHeight: 6,
                backgroundColor: AppColors.lightGrey,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 24),

            // Abstract Shape Visualization
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                ),
                child: Center(
                  child: Icon(
                    q['icon'] as IconData,
                    size: 90,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Question
            Text(
              q['prompt'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Answer Options
            ...(q['options'] as List<Map<String, dynamic>>).map((opt) {
              final isSelected = _selectedAnswers[_currentQuestion] == opt['trait'];
              return GestureDetector(
                onTap: () => _selectAnswer(opt['trait'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? color.withOpacity(0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? color : AppColors.lightGrey,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? color : AppColors.greyText,
                            width: 2,
                          ),
                          color: isSelected ? color : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          opt['text'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: isSelected
                                ? AppColors.darkText
                                : AppColors.darkText.withOpacity(0.8),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Navigation Buttons
            Row(
              children: [
                if (_currentQuestion > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                            color: AppColors.primary.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentQuestion > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 3,
                      shadowColor: color.withOpacity(0.3),
                    ),
                    child: Text(
                      _currentQuestion < _questions.length - 1
                          ? 'Next Question'
                          : 'See My Result',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final trait = _getDominantTrait();
    final profile = _personalities[trait]!;
    final color = profile['color'] as Color;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Result Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  profile['emoji'] as String,
                  style: const TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your Personality Type',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  profile['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Description
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology_outlined, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Your Profile',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  profile['description'] as String,
                  style: const TextStyle(
                      color: AppColors.darkText, fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Strengths
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.star_outline, color: AppColors.happy, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Your Core Strengths',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.darkText),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      (profile['strengths'] as List<String>).map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Wellness Tip
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Samvaad Wellness Tip for You',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  profile['tip'] as String,
                  style: const TextStyle(
                      color: AppColors.darkText, fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // CTA Buttons
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentQuestion = 0;
                _showResult = false;
                for (int i = 0; i < _selectedAnswers.length; i++) {
                  _selectedAnswers[i] = null;
                }
                _animController.forward();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 3,
              shadowColor: color.withOpacity(0.3),
            ),
            child: const Text('Retake Assessment',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Back to Dashboard',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
