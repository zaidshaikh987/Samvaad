# 🤗 Hugging Face AI Integration Setup Guide

## Overview

Your Samvaad app now uses **Hugging Face AI models** for intelligent mental health conversations! The app uses a **hybrid approach**:

- **Primary**: Hugging Face API (real AI models)
- **Fallback**: Offline rule-based responses (when API is unavailable)

## 🎯 AI Models Used

### 1. **Emobot** (Emotional Support)
- **Model**: `facebook/blenderbot-400M-distill`
- **Purpose**: Empathetic, emotional conversations
- **Best for**: Listening, validation, emotional support

### 2. **Brobot** (Practical Advice)
- **Model**: `facebook/blenderbot-400M-distill`
- **Purpose**: Actionable mental health strategies
- **Best for**: Coping techniques, practical advice

### 3. **Sentiment Analysis**
- **Model**: `distilbert-base-uncased-finetuned-sst-2-english`
- **Purpose**: Analyze emotional tone of messages
- **Best for**: Risk scoring, mood detection

---

## 🚀 Quick Setup (3 Steps)

### Step 1: Get Your FREE Hugging Face API Key

1. Go to: https://huggingface.co/join
2. Create a free account (takes 30 seconds)
3. Go to: https://huggingface.co/settings/tokens
4. Click **"New token"**
5. Name it: `samvaad-app`
6. Select **"Read"** access (free tier)
7. Click **"Generate token"**
8. **Copy the token** (starts with `hf_...`)

### Step 2: Add API Key to Your App

Open `lib/services/huggingface_ai_service.dart` and replace:

```dart
static const String _apiKey = 'YOUR_HUGGINGFACE_API_KEY';
```

With your actual key:

```dart
static const String _apiKey = 'hf_YourActualTokenHere';
```

### Step 3: Test the Integration

Run the app and test:

```bash
flutter run -d chrome
```

1. Navigate to **AI Chat** tab
2. Talk to **Emobot** or **Brobot**
3. Send a message like: "I'm feeling anxious today"
4. You should see a **real AI response** (not a pre-written one)

---

## ✅ How to Verify It's Working

### Test 1: Check Console Logs

When you send a message, you should see:
- ✅ No errors about "API key"
- ✅ No "Hugging Face API failed" messages
- ✅ Responses that are contextual and unique

### Test 2: Compare Responses

**Offline mode** (without API key):
- User: "I'm feeling anxious"
- Bot: "I hear you, and I want you to know that anxiety is a natural response..."

**Hugging Face mode** (with API key):
- User: "I'm feeling anxious"
- Bot: "I understand how you're feeling. Anxiety can be overwhelming, but there are ways to manage it. Have you tried deep breathing exercises? They can help calm your nervous system..."

The Hugging Face responses are:
- More contextual
- More varied
- More conversational
- Better at understanding nuance

---

## 🔧 Configuration Options

### Enable/Disable Hugging Face API

In your code, you can toggle between Hugging Face and offline mode:

```dart
final aiService = OfflineAIService();

// Enable Hugging Face (default)
aiService.setUseHuggingFace(true);

// Disable Hugging Face (use offline only)
aiService.setUseHuggingFace(false);

// Check if configured
if (aiService.isHuggingFaceEnabled()) {
  print('Using Hugging Face AI');
} else {
  print('Using offline AI');
}
```

### Test API Connection

```dart
final aiService = OfflineAIService();
final isConnected = await aiService.testHuggingFaceConnection();

if (isConnected) {
  print('✅ Hugging Face API is working!');
} else {
  print('❌ Hugging Face API is not configured or unavailable');
}
```

---

## 📊 API Usage & Limits

### Free Tier (Hugging Face)
- **Rate Limit**: ~30 requests/minute
- **Cost**: FREE forever
- **Models**: All inference API models
- **Timeout**: 30 seconds per request

### What Happens When Limit is Reached?
The app automatically falls back to offline responses. Users won't see any errors.

### Upgrade Options
If you need more requests:
1. Go to: https://huggingface.co/pricing
2. Upgrade to **Pro** ($9/month) for unlimited requests
3. Or use **Inference Endpoints** for dedicated resources

---

## 🛠️ Troubleshooting

### Issue 1: "Model is loading" Error

**Cause**: Hugging Face models "sleep" after inactivity

**Solution**: Wait 10-20 seconds and try again. The model will wake up.

**Code handles this automatically** with fallback responses.

### Issue 2: API Key Not Working

**Check**:
1. API key starts with `hf_`
2. No extra spaces in the key
3. Token has "Read" access enabled
4. Account is verified (check email)

### Issue 3: Slow Responses

**Causes**:
- Model is loading (first request)
- Network latency
- High API traffic

**Solutions**:
- Wait for model to warm up
- Use offline mode for instant responses
- Upgrade to Inference Endpoints for faster responses

### Issue 4: Generic Responses

**Cause**: API key not configured, using offline fallback

**Check**:
```dart
final hfService = HuggingFaceAIService();
print(hfService.isConfigured()); // Should print: true
```

---

## 🎨 Customization

### Change AI Models

Edit `lib/services/huggingface_ai_service.dart`:

```dart
// Current models
static const String _conversationalModel = 'facebook/blenderbot-400M-distill';
static const String _emotionalModel = 'microsoft/DialoGPT-medium';

// Alternative models (you can try these)
// static const String _conversationalModel = 'facebook/blenderbot-1B-distill'; // Larger, better
// static const String _emotionalModel = 'microsoft/DialoGPT-large'; // More empathetic
```

### Adjust Response Parameters

```dart
parameters: {
  'max_length': 150,        // Longer = more detailed responses
  'temperature': 0.9,       // Higher = more creative (0.0-1.0)
  'top_p': 0.95,           // Higher = more diverse vocabulary
  'do_sample': true,       // Enable randomness
}
```

### Add Conversation History

The service already tracks last 10 messages for context:

```dart
final history = _huggingFace.getHistory();
print(history); // [{'role': 'user', 'content': '...'}, ...]

// Clear history
_huggingFace.clearHistory();
```

---

## 🔐 Security Best Practices

### ⚠️ IMPORTANT: Never Commit API Keys

**Bad** ❌:
```dart
static const String _apiKey = 'hf_abc123...'; // Hardcoded
```

**Good** ✅:
```dart
// Use environment variables or secure storage
static String get _apiKey => Platform.environment['HUGGINGFACE_API_KEY'] ?? '';
```

### For Production Apps

1. **Use Flutter Secure Storage**:
```dart
final storage = FlutterSecureStorage();
await storage.write(key: 'hf_api_key', value: 'hf_...');
final apiKey = await storage.read(key: 'hf_api_key');
```

2. **Use Backend Proxy**:
   - Store API key on your server
   - App calls your server
   - Server calls Hugging Face
   - Prevents key exposure

3. **Use Environment Variables**:
```bash
# .env file (add to .gitignore)
HUGGINGFACE_API_KEY=hf_your_key_here
```

---

## 📈 Monitoring & Analytics

### Track API Usage

Add logging to `huggingface_ai_service.dart`:

```dart
Future<String> _callHuggingFaceAPI(...) async {
  final startTime = DateTime.now();
  
  try {
    final response = await http.post(...);
    final duration = DateTime.now().difference(startTime);
    
    print('✅ HF API Success: ${duration.inMilliseconds}ms');
    return result;
  } catch (e) {
    print('❌ HF API Error: $e');
    throw e;
  }
}
```

### Monitor Fallback Rate

```dart
int _hfSuccessCount = 0;
int _hfFailureCount = 0;

double get fallbackRate => _hfFailureCount / (_hfSuccessCount + _hfFailureCount);
```

---

## 🚀 Next Steps

### 1. **Test with Real Users**
- Get feedback on AI quality
- Monitor response times
- Track fallback rate

### 2. **Fine-tune Models** (Advanced)
- Train custom models on mental health data
- Use Hugging Face AutoTrain
- Deploy custom endpoints

### 3. **Add More Features**
- **Emotion detection**: Detect 7 emotions (joy, sadness, anger, etc.)
- **Language translation**: Support Hindi, Tamil, etc.
- **Voice input**: Transcribe speech to text
- **Summarization**: Summarize long journal entries

### 4. **Optimize Performance**
- Cache common responses
- Preload models on app start
- Use streaming responses for real-time chat

---

## 📚 Resources

- **Hugging Face Docs**: https://huggingface.co/docs/api-inference
- **Model Hub**: https://huggingface.co/models
- **Pricing**: https://huggingface.co/pricing
- **Community**: https://discuss.huggingface.co

---

## ✨ What's Different Now?

### Before (Rule-Based)
```
User: "I'm feeling really anxious about my job interview tomorrow"
Bot: "I hear you. Anxiety can be overwhelming. Remember to breathe deeply..."
```

### After (Hugging Face AI)
```
User: "I'm feeling really anxious about my job interview tomorrow"
Bot: "Job interviews can definitely trigger anxiety. It's completely normal to feel nervous about something important. Have you prepared your answers to common questions? Sometimes practicing out loud can help build confidence. Also, remember that the interviewer wants you to succeed - they're looking for the right fit, not trying to catch you out. Would you like to talk through some preparation strategies?"
```

**The AI now**:
- Understands context (job interview)
- Provides specific advice (practice answers)
- Asks follow-up questions
- Maintains conversation flow
- Adapts to user's emotional state

---

## 🎉 You're All Set!

Your app now has **real AI-powered mental health support**. Users will experience:

✅ More empathetic conversations  
✅ Context-aware responses  
✅ Personalized advice  
✅ Natural conversation flow  
✅ Automatic fallback (no errors)  

**Need help?** Check the troubleshooting section or open an issue.

---

**Made with 💙 for mental health support**
