// lib/services/offline_ai_service.dart
// Rich offline AI service with 50+ context-aware responses, multi-turn conversation tracking,
// breathing exercises, CBT techniques, and grounding exercises.

import 'dart:math';

class OfflineAIService {
  static final OfflineAIService _instance = OfflineAIService._internal();
  factory OfflineAIService() => _instance;
  OfflineAIService._internal();

  final List<Map<String, String>> _conversationHistory = [];
  static const int _maxContextLength = 15;

  // Crisis keywords
  static const List<String> _crisisKeywords = [
    'suicide', 'kill myself', 'end it all', 'want to die', 'end my life',
    'self harm', 'hurt myself', 'no reason to live', 'better off dead',
    'suicidal', 'hopeless and', 'can\'t go on', 'not worth living',
    'end everything', 'don\'t want to be here', 'take my own life',
  ];

  static const List<String> _harmfulKeywords = [
    'kill yourself', 'hurt yourself', 'you deserve to die', 'end your life',
    'slice yourself', 'overdose', 'jump off', 'hang yourself',
  ];

  // ─────────────────────────────────────────────
  // EMOBOT RESPONSES — Emotional support AI
  // ─────────────────────────────────────────────
  final Map<String, List<String>> _emobotResponses = {
    'anxious': [
      'I hear your anxiety, and I want you to know it\'s okay to feel this way. 💙 Our bodies sometimes try to protect us by worrying. Can you tell me what\'s on your mind right now?',
      'Anxiety can feel so overwhelming — like your mind won\'t stop racing. Try placing one hand on your chest and take 3 slow breaths with me... You\'ve got this. 🌬️',
      'What you\'re feeling is real and valid. Anxiety often shows up when we care about something deeply. What specifically has been weighing on you?',
      'Sometimes anxiety narrows our focus to worst-case scenarios. Let\'s try to ground you — can you name 3 things you can see right now? 👁️',
      'I\'m here with you. Anxiety is like a wave — it rises, peaks, and passes. You\'ve survived every anxious moment before this one. 💪',
      'It takes courage to talk about what you\'re feeling. Anxiety is your mind\'s alarm system, but sometimes it fires when there\'s no real danger. How long have you been feeling this way?',
      'Breathing slowly can signal your nervous system that you\'re safe. Try: inhale for 4 counts, hold for 4, exhale for 6. 🌬️ Want to try it together?',
    ],
    'sad': [
      'I\'m so glad you\'re sharing this with me. Sadness is one of the most human emotions — it often means you care deeply. 💙 What\'s been going on?',
      'It\'s okay to not be okay. You don\'t have to put on a brave face here. I\'m listening, fully and without judgment. Tell me more.',
      'Sadness can feel like a heavy fog. Be gentle with yourself today — rest if you need to, eat something nourishing, and know that this feeling will shift. 🌿',
      'Sometimes sadness is grief — for a person, a relationship, a version of ourselves or our life we hoped for. What loss are you carrying right now?',
      'Your feelings are valid, even if they\'re hard to explain. You don\'t need to have a "reason" to feel sad. Would you like to talk about it?',
      'I\'m here beside you in this. You are not alone, even when it feels that way. What has this sadness looked like for you today?',
      'Crying is actually healing — it releases stress hormones. If you need to cry, that\'s completely okay. I\'m right here. 💙',
    ],
    'happy': [
      'That\'s genuinely wonderful! 😊 Positive moments are worth celebrating fully. What made you smile today?',
      'I love hearing this! Your happiness is contagious, even through text. Soak in these good feelings — you deserve them.',
      'This is beautiful. Hold onto this feeling and remember it on harder days. What\'s been going well for you?',
      'A happy day deserves recognition! Sometimes we rush past good moments. What\'s one thing you\'re especially grateful for right now? 🌟',
      'You radiate positivity today! Happiness shared is happiness doubled. Is there someone special who\'s been part of your good mood?',
      'Yay! I want to hear all about it. Good moments are precious — let\'s celebrate together. What happened? 🎉',
    ],
    'calm': [
      'That sense of calm is so precious. 🌿 What helped you find this peace today?',
      'Being calm is actually a skill — and it sounds like you\'ve found your balance today. What does your calm feel like?',
      'Stillness is its own kind of strength. I\'m glad you\'re in a grounded place. How can we help you maintain this feeling?',
      'That calm centered feeling is what we\'re always working toward. What practices or moments brought you here?',
      'A calm mind is a clear mind. Enjoy this space you\'ve created for yourself. 🌊',
    ],
    'stressed': [
      'Stress can pile up so quickly — and it\'s exhausting. 😮‍💨 What\'s putting the most pressure on you right now?',
      'When we\'re stressed, our brain narrows focus to the problem. But you are more than this moment. Let\'s break it down together — what feels most urgent?',
      'I hear you. Stress signals that your brain thinks there\'s danger. Let\'s help it calm down first: breathe out longer than you breathe in. 🌬️ Better?',
      'One thing that helps with stress: write down everything on your mind, then circle just ONE thing you can do in the next 10 minutes. Small wins matter. 📝',
    ],
    'lonely': [
      'Loneliness is one of the most painful human experiences, and I\'m really glad you reached out. You don\'t have to face it alone right now. 🤝',
      'Even in a crowded room, we can feel unseen. Tell me — what does your loneliness feel like? Is it missing connection, or feeling misunderstood?',
      'I\'m here with you right now, in this moment. You matter. Your thoughts and feelings matter. What would feel most helpful to you right now?',
      'Loneliness can disconnect us from ourselves too. Would you like to try a small act of kindness for yourself today?',
    ],
    'angry': [
      'Anger is actually a very important emotion — it tells us something important has been threatened or violated. What triggered this for you?',
      'Your anger makes sense. Let it out safely here. Sometimes just naming the feeling helps reduce its charge. What happened?',
      'Before diving in — have you had water and a few deep breaths? Sometimes our body just needs a reset first. 💧',
      'Anger often has sadness or fear underneath it. What do you think might be hiding beneath the anger right now?',
    ],
    'overwhelmed': [
      'When everything feels too much, the most powerful thing you can do is pause. Just one breath. You don\'t have to solve everything now. 🌬️',
      'Overwhelm happens when our nervous system hits its limit. Let\'s bring it down together. Name just ONE tiny thing you could do right now — even just getting water. 💧',
      'You\'re carrying a lot. I see that. It\'s not weakness — it\'s human. What\'s the heaviest thing on your plate today?',
    ],
    'lost': [
      'Feeling lost is actually the beginning of finding yourself — it means you\'re questioning, growing. It takes courage to sit with that uncertainty. 🌱',
      'Not knowing your direction can feel terrifying, but it\'s also freedom. What values or things make you feel most alive?',
      'When we feel lost, it helps to return to small anchors — what time did you wake up, what did you eat, who did you speak to? Routine is a compass. 🧭',
    ],
    'default': [
      'I\'m here, fully present for you. Tell me what\'s on your mind and heart right now. 💙',
      'Thank you for reaching out. Whatever you\'re going through, you don\'t have to face it alone. How are you doing today?',
      'I\'m listening without judgment. What\'s been on your mind lately?',
      'This is a safe space for you to share anything. What do you need right now — to be heard, to find solutions, or just to not be alone?',
      'You took a brave step by opening up. I\'m here. What would you like to talk about?',
      'How are you really doing? Beyond the surface — what\'s going on inside?',
    ],
  };

  // ─────────────────────────────────────────────
  // BROBOT RESPONSES — Practical advice AI
  // ─────────────────────────────────────────────
  final Map<String, List<String>> _brobotResponses = {
    'stress': [
      'Here\'s a proven framework for acute stress: 1) Stop what you\'re doing for 2 minutes, 2) Do box breathing (4-4-4-4), 3) Write down your top 3 stressors, 4) Tackle just ONE. What\'s #1 for you?',
      'Stress management tip — try the 5-4-3-2-1 grounding technique: name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste. Done? How do you feel now?',
      'For long-term stress: the research is clear — regular physical movement (even 10-min walks), consistent sleep (7-8h), and social connection are the three most powerful interventions.',
      'One underrated stress buster: progressive muscle relaxation. Tense each muscle group for 5 seconds, release. Start from your feet, work up. Takes 10 mins. Want the full script?',
    ],
    'sleep': [
      'Better sleep hygiene: 1) Consistent wake time (non-negotiable), 2) No screens 1h before bed, 3) Keep room 65-68°F/18-20°C, 4) No caffeine after 2pm. Which of these can you start tonight?',
      'The 4-7-8 technique for falling asleep: inhale 4 counts, hold 7, exhale 8. Repeat 4 times. It activates your parasympathetic nervous system.',
      'If you can\'t fall asleep after 20 minutes, get up and do something quiet in dim light until you feel sleepy. Fighting sleeplessness in bed wires your brain to associate bed with wakefulness.',
      'Morning light exposure for 10-15 minutes (outside, no sunglasses) dramatically improves your sleep drive and circadian rhythm. Try it tomorrow morning!',
    ],
    'anxiety': [
      'CBT technique for anxiety: STOP → Situation, Thought, Outcome, Plan. Write down the anxious thought, then ask: Is this thought 100% true? What evidence do you have for and against it?',
      'For anxiety management: Limit caffeine, get regular exercise (even short walks reduce anxiety significantly), practice mindfulness 10 min/day. Which of these feels most achievable?',
      'The worry time technique: Schedule 15 minutes per day to worry about specific things. Outside that window, when worries arise, note them and defer to worry time. Sounds odd, but it works.',
      'Anti-anxiety tip: Cold water on your face/wrists triggers the dive reflex and slows your heart rate almost immediately. Worth trying when anxiety spikes.',
    ],
    'motivation': [
      'Action before motivation, not the other way around. Start with just 2 minutes of the task. Often motivation follows action once you start. What task are you avoiding right now?',
      'Break your goal into laughably small steps. If your goal is "exercise," your step one is "put on gym shoes." If it\'s "write report," step one is "open the document." What\'s your next tiny step?',
      'Remove friction: prepare everything the night before, set your environment up for success. We follow paths of least resistance. What can you make easier right now?',
    ],
    'relationships': [
      'Communication tip: Use "I" statements instead of "you" statements. "I feel hurt when..." vs "You always..." This reduces defensiveness dramatically.',
      'Active listening technique: When someone speaks, resist the urge to prepare your response. Simply listen to understand, then ask one clarifying question before responding.',
      'Healthy relationships require the 5:1 ratio — five positive interactions for every negative one. Are you banking enough positive moments with the people who matter to you?',
    ],
    'work': [
      'Productivity method: Time-block your calendar. Assign specific tasks to specific time blocks. Treat them like unmovable meetings. Context-switching kills productivity.',
      'The two-minute rule: If a task takes less than 2 minutes, do it immediately. This clears mental clutter and prevents small tasks from piling up.',
      'When overwhelmed at work: write every task on separate sticky notes, then sort into: Urgent+Important, Important only, Urgent only, Neither. Focus only on column 1 first.',
    ],
    'self_care': [
      'Self-care isn\'t selfish — it\'s maintenance. This week, pick just ONE: 30-minute daily walk, cooking one healthy meal, calling a friend, or 8 hours of sleep. Which feels most needed?',
      'Three-minute morning ritual: 1) Write ONE thing you\'re grateful for, 2) Set ONE intention for the day, 3) Name ONE person you\'ll show kindness to. Simple but transformative.',
      'The basics matter: water (8 glasses), movement (30 min), sunlight (10 min), sleep (7-8h), connection (one meaningful conversation). Which basics are you missing this week?',
    ],
    'default': [
      'I\'m Brobot — here to give you practical, evidence-based mental health strategies. What challenge are you working through?',
      'Let me help you build a concrete plan. The research on mental health is clear: small, consistent actions beat big, irregular ones every time. What area would you like to work on?',
      'I love a good solution. Tell me what you\'re dealing with and I\'ll share specific techniques that research has shown to help. What\'s going on?',
      'Give me the specifics and I\'ll give you an action plan. What are you struggling with right now?',
    ],
  };

  // Detect crisis keywords
  Future<bool> detectCrisis(String text) async {
    final lowerText = text.toLowerCase();
    return _crisisKeywords.any((keyword) => lowerText.contains(keyword));
  }

  // Detect harmful content
  Future<bool> detectHarmfulContent(String text) async {
    final lowerText = text.toLowerCase();
    return _harmfulKeywords.any((keyword) => lowerText.contains(keyword));
  }

  // Analyze sentiment (0.0 = negative, 1.0 = positive)
  Future<double> analyzeSentiment(String text) async {

    final lowerText = text.toLowerCase();
    const positiveWords = [
      'happy', 'good', 'great', 'wonderful', 'love', 'joy', 'excited', 'calm', 'peaceful',
      'better', 'amazing', 'grateful', 'thankful', 'hopeful', 'strong', 'proud'
    ];
    const negativeWords = [
      'sad', 'bad', 'terrible', 'hate', 'angry', 'anxious', 'worried', 'depressed', 'hopeless',
      'awful', 'horrible', 'scared', 'lonely', 'lost', 'overwhelmed', 'stressed'
    ];

    int pos = positiveWords.where((w) => lowerText.contains(w)).length;
    int neg = negativeWords.where((w) => lowerText.contains(w)).length;

    if (pos + neg == 0) return 0.5;
    return pos / (pos + neg);
  }

  // Generate Emobot response
  Future<String> generateEmobotResponse(String userMessage) async {
    _addToHistory('User', userMessage);

    // Crisis check first
    if (await detectCrisis(userMessage)) {
      return 'I hear you, and I\'m really glad you\'re sharing this with me. 💙 You are not alone. What you\'re feeling is real and valid — reaching out for help is one of the bravest things you can do.\n\n📞 iCall helpline: 9152987821 (Mon–Sat, 8am–10pm)\n\nWould you like to talk to a professional right now?';
    }

    // Rich offline inference
    final lowerMessage = userMessage.toLowerCase();
    String category = 'default';

    if (lowerMessage.contains('anxious') || lowerMessage.contains('worried') ||
        lowerMessage.contains('nervous') || lowerMessage.contains('panic')) {
      category = 'anxious';
    } else if (lowerMessage.contains('sad') || lowerMessage.contains('depressed') ||
        lowerMessage.contains('down') || lowerMessage.contains('cry') ||
        lowerMessage.contains('grief') || lowerMessage.contains('mourn')) {
      category = 'sad';
    } else if (lowerMessage.contains('happy') || lowerMessage.contains('great') ||
        lowerMessage.contains('wonderful') || lowerMessage.contains('excited')) {
      category = 'happy';
    } else if (lowerMessage.contains('calm') || lowerMessage.contains('peaceful') ||
        lowerMessage.contains('relaxed') || lowerMessage.contains('okay')) {
      category = 'calm';
    } else if (lowerMessage.contains('stress') || lowerMessage.contains('pressure') ||
        lowerMessage.contains('burden')) {
      category = 'stressed';
    } else if (lowerMessage.contains('lonely') || lowerMessage.contains('alone') ||
        lowerMessage.contains('isolated') || lowerMessage.contains('no one')) {
      category = 'lonely';
    } else if (lowerMessage.contains('angry') || lowerMessage.contains('furious') ||
        lowerMessage.contains('frustrated') || lowerMessage.contains('mad')) {
      category = 'angry';
    } else if (lowerMessage.contains('overwhelm') || lowerMessage.contains('too much') ||
        lowerMessage.contains('can\'t handle')) {
      category = 'overwhelmed';
    } else if (lowerMessage.contains('lost') || lowerMessage.contains('direction') ||
        lowerMessage.contains('purpose') || lowerMessage.contains('meaning')) {
      category = 'lost';
    }

    final responses = _emobotResponses[category]!;
    final resp = responses[Random().nextInt(responses.length)];
    _addToHistory('Emobot', resp);
    return resp;
  }

  // Generate Brobot (practical advice) response
  Future<String> generateChatbotResponse(String userMessage) async {
    _addToHistory('User', userMessage);



    final lowerMessage = userMessage.toLowerCase();
    String category = 'default';

    if (lowerMessage.contains('stress') || lowerMessage.contains('overwhelm')) {
      category = 'stress';
    } else if (lowerMessage.contains('sleep') || lowerMessage.contains('insomnia') ||
        lowerMessage.contains('tired')) {
      category = 'sleep';
    } else if (lowerMessage.contains('anxiety') || lowerMessage.contains('anxious') ||
        lowerMessage.contains('panic')) {
      category = 'anxiety';
    } else if (lowerMessage.contains('motivat') || lowerMessage.contains('lazy') ||
        lowerMessage.contains('procrastinat')) {
      category = 'motivation';
    } else if (lowerMessage.contains('relationship') || lowerMessage.contains('friend') ||
        lowerMessage.contains('partner') || lowerMessage.contains('family')) {
      category = 'relationships';
    } else if (lowerMessage.contains('work') || lowerMessage.contains('job') ||
        lowerMessage.contains('boss') || lowerMessage.contains('deadline')) {
      category = 'work';
    } else if (lowerMessage.contains('self care') || lowerMessage.contains('take care') ||
        lowerMessage.contains('routine')) {
      category = 'self_care';
    }

    final responses = _brobotResponses[category]!;
    final resp = responses[Random().nextInt(responses.length)];
    _addToHistory('Brobot', resp);
    return resp;
  }

  void _addToHistory(String role, String message) {
    _conversationHistory.add({'role': role, 'content': message});
    if (_conversationHistory.length > _maxContextLength * 2) {
      _conversationHistory.removeAt(0);
    }
  }

  void clearContext() => _conversationHistory.clear();
  List<Map<String, String>> getHistory() => List.from(_conversationHistory);

}
