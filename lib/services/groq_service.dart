import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroqService {
  static const String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _prefApiKey = 'custom_groq_api_key';
  
  // llama-3.3-70b-versatile is the primary and exclusive model requested
  static const String _defaultModel = 'llama-3.3-70b-versatile';
  String _currentModel = _defaultModel;

  String? _customApiKey;
  final List<Map<String, String>> _history = [];

  String get currentModel => _currentModel;
  void setModel(String model) {
    _currentModel = model;
  }

  Future<void> loadSavedApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customApiKey = prefs.getString(_prefApiKey);
    } catch (_) {}
  }

  Future<void> saveApiKey(String newKey) async {
    _customApiKey = newKey.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_customApiKey!.isEmpty) {
        await prefs.remove(_prefApiKey);
      } else {
        await prefs.setString(_prefApiKey, _customApiKey!);
      }
    } catch (_) {}
  }

  Future<bool> validateKey(String testKey) async {
    final cleanKey = testKey.trim();
    if (cleanKey.isEmpty) return false;
    try {
      final response = await http.get(
        Uri.parse('https://api.groq.com/openai/v1/models'),
        headers: {
          'Authorization': 'Bearer $cleanKey',
        },
      ).timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  String get apiKey {
    if (_customApiKey != null && _customApiKey!.isNotEmpty) {
      return _customApiKey!;
    }
    if (dotenv.isInitialized) {
      final envKey = dotenv.env['GROQ_API_KEY']?.trim() ?? '';
      if (envKey.isNotEmpty && envKey != 'your_groq_api_key_here') {
        return envKey;
      }
    }
    return '';
  }

  bool get hasApiKey => apiKey.isNotEmpty;

  static const String _systemPrompt = '''
You are Zoid, a warm, witty, and intelligent AI voice companion.
Rules for voice responses:
1. Language matching:
   - If the user speaks in English, reply strictly in fluent, natural English.
   - If the user speaks in Roman Urdu / Roman English (e.g. "kya haal hai", "aap kaise hain", "mujhe ek baat batao"), reply strictly in natural Roman Urdu / Roman English using simple Latin letters.
   - STRICT RULE: Hindi is strictly forbidden. NEVER use Hindi words, Hindi greetings, or Hindi vocabulary (do NOT use Namaste, Namaskar, Dhanyawad, Kripya, Sahayata, Mitra, etc.). Use natural Urdu/Pakistani phrasing (e.g. "Salam", "Theek hoon", "Shukriya", "Bataiye", "Aap kaise hain").
2. Brevity & Voice friendliness:
   - Keep answers concise, natural, and direct (1 to 2 short sentences maximum), because your response will be read aloud by Text-to-Speech.
3. Clean text:
   - NEVER use markdown formatting (no asterisks *, no hash symbols #, no bullet points -).
   - NEVER use emojis, because TTS engines pronounce them awkwardly.
4. Speak conversationally like a real human over a phone call.
''';

  GroqService() {
    _resetHistory();
  }

  void _resetHistory() {
    _history.clear();
    _history.add({
      'role': 'system',
      'content': _systemPrompt,
    });
  }

  void clearConversation() {
    _resetHistory();
  }

  void _trimHistoryIfNeeded() {
    // Keep system prompt + last 10 messages (5 user questions, 5 assistant answers)
    if (_history.length > 11) {
      final system = _history.first;
      final recent = _history.sublist(_history.length - 10);
      _history.clear();
      _history.add(system);
      _history.addAll(recent);
    }
  }

  Future<String> sendMessage(String userMessage) async {
    if (!hasApiKey) {
      throw Exception(
        'Groq API key missing. Please configure your GROQ_API_KEY in app settings.',
      );
    }

    _history.add({
      'role': 'user',
      'content': userMessage,
    });

    _trimHistoryIfNeeded();

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _currentModel,
          'messages': _history,
          'temperature': 0.7,
          'reasoning_effort': 'low',
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reply = data['choices'][0]['message']['content'] as String? ?? '';
        var cleanReply = reply.trim();

        if (cleanReply.isEmpty) {
          cleanReply = 'Mujhe samajh nahi aaya, barah e karam dobara bolejiye.';
        }

        _history.add({
          'role': 'assistant',
          'content': cleanReply,
        });

        return cleanReply;
      } else {
        final errorBody = response.body;
        throw Exception('Groq API Error (${response.statusCode}): $errorBody');
      }
    } catch (e) {
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
      rethrow;
    }
  }
}
