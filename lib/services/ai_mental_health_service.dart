// lib/services/ai_mental_health_service.dart
// Mental health AI service using offline models

import 'package:samvaad/services/offline_ai_service.dart';

class AIMentalHealthService {
  static final OfflineAIService _offlineAI = OfflineAIService();

  // ─────────────────────────────────────────────
  // Feature 4: Crisis Detection (Offline)
  // ─────────────────────────────────────────────
  static Future<bool> detectCrisis(String text) async {
    return await _offlineAI.detectCrisis(text);
  }

  // ─────────────────────────────────────────────
  // Feature 5: Community Content Moderation (Offline)
  // ─────────────────────────────────────────────
  static Future<bool> detectHarmfulContent(String text) async {
    return await _offlineAI.detectHarmfulContent(text);
  }

  // ─────────────────────────────────────────────
  // Feature 3: Emotional Risk Scoring (Offline)
  // ─────────────────────────────────────────────
  static Future<double> computeRiskScore({
    required String mood,
    String journalText = '',
  }) async {
    double baseScore = 0.2; // baseline low risk
    switch (mood.toLowerCase()) {
      case 'anxious': baseScore += 0.35; break;
      case 'sad': baseScore += 0.25; break;
      case 'calm': baseScore += 0.0; break;
      case 'happy': baseScore -= 0.05; break;
    }

    if (journalText.isEmpty) return baseScore.clamp(0.0, 1.0);

    // Analyze journal text sentiment using offline AI
    final sentiment = await _offlineAI.analyzeSentiment(journalText);
    
    // Adjust score based on sentiment (0.0 = negative, 1.0 = positive)
    final sentimentAdjustment = (0.5 - sentiment) * 0.4; // -0.2 to +0.2
    
    return (baseScore + sentimentAdjustment).clamp(0.0, 1.0);
  }

  static String getRiskLevel(double score) {
    if (score < 0.35) return 'Low';
    if (score < 0.65) return 'Moderate';
    return 'High';
  }

  static String getRiskDescription(double score) {
    if (score < 0.35) {
      return 'Your emotional patterns look stable. Keep up the great self-care!';
    } else if (score < 0.65) {
      return 'Some stress signals detected (measured by AI). Consider expressing your thoughts.';
    } else {
      return 'AI detects significant distress. Reaching out for support is a brave step.';
    }
  }

  // ─────────────────────────────────────────────
  // Feature 6: Smart Therapist Matching (Synchronous)
  // ─────────────────────────────────────────────
  static List<Map<String, dynamic>> getMatchedTherapists(String mood) {
    final all = [
      {
        'name': 'Dr. Priya Sharma',
        'specialty': 'Anxiety & Panic Disorders',
        'matchMoods': ['Anxious', 'Sad'],
        'years': 10,
        'rating': 4.9,
        'fee': 70,
        'lang': 'Hindi, English',
        'reason': 'Specializes in anxiety — matches your recent patterns',
      },
      {
        'name': 'Dr. Arjun Mehta',
        'specialty': 'Depression & Low Mood',
        'matchMoods': ['Sad', 'Anxious'],
        'years': 9,
        'rating': 4.8,
        'fee': 65,
        'lang': 'English, Marathi',
        'reason': 'Expert in mood-lifting CBT techniques',
      },
      {
        'name': 'Dr. Ananya Roy',
        'specialty': 'Stress & Life Transitions',
        'matchMoods': ['Anxious', 'Calm'],
        'years': 7,
        'rating': 4.7,
        'fee': 60,
        'lang': 'English, Bengali',
        'reason': 'Focuses on work-life balance and stress management',
      },
      {
        'name': 'Dr. Kabir Nair',
        'specialty': 'Positive Psychology',
        'matchMoods': ['Happy', 'Calm'],
        'years': 6,
        'rating': 4.6,
        'fee': 55,
        'lang': 'English, Malayalam',
        'reason': 'Helps build on your positive momentum',
      },
    ];

    // Sort by match score
    final matched = all.where((t) => (t['matchMoods'] as List<String>).contains(mood)).toList();
    final unmatched = all.where((t) => !(t['matchMoods'] as List<String>).contains(mood)).toList();

    return [...matched, ...unmatched];
  }

  static int getMatchScore(Map<String, dynamic> therapist, String mood) {
    final moods = therapist['matchMoods'] as List<String>;
    if (moods.contains(mood)) {
      return 85 + ((therapist['rating'] as double) * 2).toInt();
    }
    return 60 + ((therapist['rating'] as double) * 2).toInt();
  }

  // ─────────────────────────────────────────────
  // Feature 7: AI Weekly Insights (Synchronous)
  // ─────────────────────────────────────────────
  static Map<String, dynamic> getWeeklyInsights(List<String> weekMoods) {
    final moodCounts = <String, int>{};
    for (final m in weekMoods) {
      moodCounts[m] = (moodCounts[m] ?? 0) + 1;
    }

    final dominant = moodCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final positiveDays = weekMoods.where((m) => m == 'Happy' || m == 'Calm').length;
    final anxiousDays = weekMoods.where((m) => m == 'Anxious').length;
    final sadDays = weekMoods.where((m) => m == 'Sad').length;

    String trigger = 'No strong pattern';
    if (anxiousDays >= 3) trigger = 'Recurring anxiety — possible work stress';
    if (sadDays >= 3) trigger = 'Prolonged low mood detected';
    if (positiveDays >= 5) trigger = 'Consistent positive emotional state';

    String observation = 'Your week had a balanced emotional spread.';
    if (dominant == 'Anxious') observation = 'Anxiety dominated this week. Consider relaxation techniques.';
    else if (dominant == 'Happy') observation = 'Great week! Positive moods were predominant.';
    else if (dominant == 'Sad') observation = 'This was a tough week emotionally. You showed resilience.';
    else if (dominant == 'Calm') observation = 'A calm, balanced week. Your coping skills are working.';

    return {
      'dominantMood': dominant,
      'positiveDays': positiveDays,
      'anxiousDays': anxiousDays,
      'sadDays': sadDays,
      'trigger': trigger,
      'observation': observation,
      'positivityScore': (positiveDays / 7.0).clamp(0.0, 1.0),
      'selfCareScore': 0.65,
      'recommendedAction': _getActionForMood(dominant),
    };
  }

  static String _getActionForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'anxious': return 'Try a 10-min breathing exercise in AI Chat';
      case 'sad': return 'Write in your journal — it helps process emotions';
      case 'happy': return 'Share positivity in the Community!';
      case 'calm': return 'Book a therapist session to maintain your progress';
      default: return 'Check in with your mood daily for better insights';
    }
  }

  // ─────────────────────────────────────────────
  // Feature 2: Mood Pattern Detection (Synchronous)
  // ─────────────────────────────────────────────
  static List<Map<String, dynamic>> getMoodPatterns(List<String> weekMoods) {
    final patterns = <Map<String, dynamic>>[];
    final anxiousDays = <String>[];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    for (int i = 0; i < weekMoods.length && i < 7; i++) {
      if (weekMoods[i] == 'Anxious') anxiousDays.add(days[i]);
    }

    if (anxiousDays.isNotEmpty) {
      patterns.add({
        'icon': 'warning', 'title': 'Anxiety Trigger Days',
        'description': 'Higher anxiety detected on ${anxiousDays.join(', ')}', 'color': 'anxious',
      });
    }

    final positiveDays = weekMoods.where((m) => m == 'Happy' || m == 'Calm').length;
    if (positiveDays >= 3) {
      patterns.add({
        'icon': 'sunny', 'title': 'Positive Momentum',
        'description': '$positiveDays days of positive mood this week', 'color': 'happy',
      });
    }

    patterns.add({
      'icon': 'cycle', 'title': 'Emotional Cycle',
      'description': 'Mood tends to improve mid-week (Wed–Thu)', 'color': 'calm',
    });

    return patterns;
  }

  // ─────────────────────────────────────────────
  // Feature 8: Personalized Feature Recommendations
  // ─────────────────────────────────────────────
  static List<Map<String, dynamic>> getRecommendations(String mood) {
    final all = [
      {'title': 'Write in Journal', 'subtitle': 'Process what you\'re feeling', 'icon': 'journal', 'tab': 3, 'moods': ['Sad', 'Anxious']},
      {'title': 'Talk to Emobot', 'subtitle': 'Get emotional support right now', 'icon': 'chat', 'tab': 1, 'moods': ['Sad', 'Anxious']},
      {'title': 'Anxiety & Depression Community', 'subtitle': 'You\'re not alone — share your story', 'icon': 'community', 'tab': 2, 'moods': ['Sad', 'Anxious', 'Calm']},
      {'title': 'Book a Therapy Session', 'subtitle': 'Talk to a licensed therapist', 'icon': 'therapy', 'tab': 4, 'moods': ['Anxious', 'Sad']},
      {'title': 'Talk to Brobot', 'subtitle': 'Get actionable strategies', 'icon': 'chat', 'tab': 1, 'moods': ['Happy', 'Calm']},
      {'title': 'Share in Community', 'subtitle': 'Inspire others with your positivity', 'icon': 'community', 'tab': 2, 'moods': ['Happy']},
    ];

    final matched = all.where((r) => (r['moods'] as List<String>).contains(mood)).toList();
    final unmatched = all.where((r) => !(r['moods'] as List<String>).contains(mood)).toList();
    return [...matched, ...unmatched].take(4).toList();
  }

  // ─────────────────────────────────────────────
  // Feature 1: Daily Check-In Reflection Prompts
  // ─────────────────────────────────────────────
  static String getReflectionPrompt(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return 'What made you smile today? 😊';
      case 'calm': return 'What helped you feel at peace today? 🌿';
      case 'sad': return 'What\'s been weighing on you? You can share here. 💙';
      case 'anxious': return 'What\'s been causing you worry? Let\'s talk through it. 🌬️';
      default: return 'How has your day been going?';
    }
  }
}
