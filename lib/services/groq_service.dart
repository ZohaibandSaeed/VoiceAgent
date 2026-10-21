import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static const String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  
  // openai/gpt-oss-120b is the primary and exclusive model requested
  static const String _defaultModel = 'openai/gpt-oss-120b';
  String _currentModel = _defaultModel;

  final List<Map<String, String>> _history = [];

  String get currentModel => _currentModel;
  void setModel(String model) {
    _currentModel = model;
  }

  String get _apiKey {
    if (!dotenv.isInitialized) return '';
    return dotenv.env['GROQ_API_KEY']?.trim() ?? '';
  }

  bool get hasApiKey => _apiKey.isNotEmpty && _apiKey != 'your_groq_api_key_here';

  static const String _systemPrompt = '''
You are Zoid, a warm, witty, and intelligent AI voice companion.
Rules for voice responses:
1. Keep answers concise, natural, and direct (1 to 3 sentences maximum), because your response will be read aloud by Text-to-Speech.
2. Match the exact language of the user:
   - If user speaks English, reply in English.
   - If user speaks Urdu (اردو), reply in clean Urdu.
   - If user speaks Roman Urdu (e.g. "kya haal hai"), reply naturally in Roman Urdu.
   - If user speaks any other language, reply in that language.
3. NEVER use markdown symbols (no asterisks, hash signs, bullet points) and avoid emojis, because TTS engines read them awkwardly.
4. Speak conversationally as a human would over the phone.
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
        'Groq API key missing. Please add your GROQ_API_KEY inside the .env file.',
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
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _currentModel,
          'messages': _history,
          'temperature': 0.7,
          'max_tokens': 250,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reply = data['choices'][0]['message']['content'] as String? ?? '';
        final cleanReply = reply.trim();

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
