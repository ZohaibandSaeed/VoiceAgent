import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/groq_service.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';

enum AgentStatus {
  idle,
  listening,
  thinking,
  speaking,
  error,
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class VoiceAgentController extends ChangeNotifier {
  final GroqService _groqService = GroqService();
  final SttService _sttService = SttService();
  final TtsService _ttsService = TtsService();

  AgentStatus _status = AgentStatus.idle;
  String _currentTranscript = '';
  String _currentResponse = '';
  String? _errorMessage;
  double _soundLevel = 0.0;
  bool _isInitialized = false;
  bool _isProcessing = false;
  Timer? _silenceTimer;

  final List<ChatMessage> _messages = [];

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 3), () {
      if (_status == AgentStatus.listening && !_isProcessing) {
        if (_currentTranscript.trim().isNotEmpty) {
          _processRecordedSpeech();
        }
      }
    });
  }

  void _cancelSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = null;
  }

  // Getters
  AgentStatus get status => _status;
  String get currentTranscript => _currentTranscript;
  String get currentResponse => _currentResponse;
  String? get errorMessage => _errorMessage;
  double get soundLevel => _soundLevel;
  bool get isInitialized => _isInitialized;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get hasApiKey => _groqService.hasApiKey;

  // Voice Settings Getters
  String get userLocale => _ttsService.userLocale;
  double get pitch => _ttsService.pitch;
  double get speechRate => _ttsService.speechRate;
  String get currentModel => _groqService.currentModel;

  Future<void> initialize() async {
    try {
      // Initialize TTS
      await _ttsService.initialize();
      _ttsService.onStart = () {
        _status = AgentStatus.speaking;
        notifyListeners();
      };
      _ttsService.onComplete = () {
        _status = AgentStatus.idle;
        _soundLevel = 0.0;
        _isProcessing = false;
        notifyListeners();
      };
      _ttsService.onError = (err) {
        _errorMessage = 'Speech playback error: $err';
        _status = AgentStatus.error;
        _isProcessing = false;
        notifyListeners();
      };

      // Initialize STT
      final sttReady = await _sttService.initialize(
        onStatus: (statusStr) {
          if (statusStr == 'done' || statusStr == 'notListening') {
            if (_status == AgentStatus.listening && !_isProcessing) {
              _processRecordedSpeech();
            }
          }
        },
        onError: (err) {
          if (_status == AgentStatus.listening) {
            _errorMessage = 'Speech error: ${err.errorMsg ?? err.toString()}';
            _status = AgentStatus.error;
            _isProcessing = false;
            notifyListeners();
          }
        },
      );

      _isInitialized = sttReady;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Initialization failed: $e';
      _status = AgentStatus.error;
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Update Voice settings live from frontend
  Future<void> updateVoiceSettings({
    String? locale,
    double? pitch,
    double? speechRate,
    String? model,
  }) async {
    await _ttsService.updateSettings(
      locale: locale,
      pitch: pitch,
      speechRate: speechRate,
    );
    if (model != null) {
      _groqService.setModel(model);
    }
    notifyListeners();
  }

  /// Test sample voice with currently selected settings
  Future<void> testVoiceSettings() async {
    String sample = "Hello! I am Zoid, your AI voice assistant. How can I help you today?";
    if (_ttsService.userLocale.startsWith('ur')) {
      sample = "ہیلو! میں زوئڈ ہوں، آپ کا آواز والا اے آئی ساتھی۔";
    }
    await _ttsService.testVoice(sample);
  }

  /// Toggle listening button action
  Future<void> toggleListening() async {
    if (_status == AgentStatus.speaking) {
      await stopSpeaking();
      return;
    }

    if (_status == AgentStatus.listening) {
      _cancelSilenceTimer();
      await _sttService.stopListening();
      await _processRecordedSpeech();
      return;
    }

    if (_status == AgentStatus.idle || _status == AgentStatus.error) {
      await startListening();
    }
  }

  /// Send prompt directly (e.g. from quick suggestion chips)
  Future<void> sendPrompt(String text) async {
    if (_isProcessing || text.trim().isEmpty) return;
    if (_ttsService.isSpeaking) {
      await _ttsService.stop();
    }
    _currentTranscript = text.trim();
    await _processRecordedSpeech();
  }

  /// Start listening to user speech
  Future<void> startListening() async {
    if (_isProcessing) return;

    _errorMessage = null;
    _currentTranscript = '';
    _soundLevel = 0.0;
    _cancelSilenceTimer();

    // Cleanly stop any ongoing audio/TTS
    if (_ttsService.isSpeaking) {
      await _ttsService.stop();
    }
    // Cleanly reset any STT session
    await _sttService.stopListening();
    await Future.delayed(const Duration(milliseconds: 60));

    try {
      _status = AgentStatus.listening;
      notifyListeners();

      await _sttService.startListening(
        onResult: (words, isFinal) {
          if (_status != AgentStatus.listening || _isProcessing) return;

          if (words.trim().isNotEmpty) {
            _currentTranscript = words;
            notifyListeners();

            // Every new word/phrase resets the 3-second silence timer
            _resetSilenceTimer();
          }
        },
        onSoundLevelChange: (level) {
          if (_status == AgentStatus.listening) {
            final normalized = ((level + 10) / 20).clamp(0.0, 1.0);
            _soundLevel = normalized;
            notifyListeners();
          }
        },
      );
    } catch (e) {
      _errorMessage = 'Mic error: $e';
      _status = AgentStatus.error;
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Send user's recognized words to Groq and speak out response
  Future<void> _processRecordedSpeech() async {
    if (_isProcessing) return;

    _cancelSilenceTimer();
    final textToProcess = _currentTranscript.trim();
    if (textToProcess.isEmpty) {
      _status = AgentStatus.idle;
      _soundLevel = 0.0;
      notifyListeners();
      return;
    }

    _isProcessing = true;
    _currentTranscript = ''; // Reset transcript for next turn
    await _sttService.stopListening(); // Release mic immediately

    _status = AgentStatus.thinking;
    _soundLevel = 0.0;
    _messages.add(ChatMessage(text: textToProcess, isUser: true));
    notifyListeners();

    try {
      final reply = await _groqService.sendMessage(textToProcess);
      _currentResponse = reply;
      _messages.add(ChatMessage(text: reply, isUser: false));

      _status = AgentStatus.speaking;
      notifyListeners();

      await _ttsService.speak(reply);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AgentStatus.error;
    } finally {
      // ALWAYS reset to idle so the user can ask the next question
      _status = AgentStatus.idle;
      _soundLevel = 0.0;
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Stop AI voice immediately
  Future<void> stopSpeaking() async {
    await _ttsService.stop();
    _status = AgentStatus.idle;
    _soundLevel = 0.0;
    _isProcessing = false;
    notifyListeners();
  }

  /// Reset conversation
  void clearConversation() {
    _cancelSilenceTimer();
    _groqService.clearConversation();
    _messages.clear();
    _currentTranscript = '';
    _currentResponse = '';
    _errorMessage = null;
    _status = AgentStatus.idle;
    _soundLevel = 0.0;
    _isProcessing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelSilenceTimer();
    super.dispose();
  }
}
