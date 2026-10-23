import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';
import 'tts_service.dart';

/// Service providing Microsoft Azure Neural Text-to-Speech (500,000 free chars/month)
/// with high-realism authentic Pakistani & international voices and seamless local TTS fallback.
class AzureTtsService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TtsService _fallbackTts = TtsService();

  bool _isSpeaking = false;
  Function()? onStart;
  Function()? onComplete;
  Function(String error)? onError;

  // Voice configurations
  String _userLocale = 'ur-PK'; // Default to authentic Pakistani Urdu
  String _voiceGender = 'Female'; // Female or Male
  double _pitch = 1.0;
  double _speechRate = 1.0;

  bool get isSpeaking => _isSpeaking || _fallbackTts.isSpeaking;
  String get userLocale => _userLocale;
  String get voiceGender => _voiceGender;
  double get pitch => _pitch;
  double get speechRate => _speechRate;

  // Optional compile-time fallback key passed via --dart-define=AZURE_SPEECH_KEY=...
  static const String _fallbackAzureKey = String.fromEnvironment(
    'AZURE_SPEECH_KEY',
    defaultValue: '',
  );

  static const String _fallbackAzureRegion = String.fromEnvironment(
    'AZURE_SPEECH_REGION',
    defaultValue: 'eastus',
  );

  String get _azureKey {
    final fromEnv = dotenv.isInitialized
        ? (dotenv.env['AZURE_SPEECH_KEY']?.trim() ?? '')
        : '';
    if (fromEnv.isNotEmpty &&
        fromEnv != 'your_azure_speech_key_here' &&
        fromEnv != 'your_key_here') {
      return fromEnv;
    }
    return _fallbackAzureKey.trim();
  }

  String get _azureRegion {
    final fromEnv = dotenv.isInitialized
        ? (dotenv.env['AZURE_SPEECH_REGION']?.trim() ?? '')
        : '';
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return _fallbackAzureRegion.trim();
  }

  bool get hasAzureKey =>
      _azureKey.isNotEmpty &&
      _azureKey != 'your_azure_speech_key_here' &&
      _azureKey != 'your_key_here';

  /// Voice mapping for top Azure Neural human voices
  static const Map<String, Map<String, String>> _azureVoiceMap = {
    'ur-PK': {
      'Female': 'ur-PK-UzmaNeural',
      'Male': 'ur-PK-AsadNeural',
    },
    'en-US': {
      'Female': 'en-US-JennyNeural',
      'Male': 'en-US-GuyNeural',
    },
    'en-GB': {
      'Female': 'en-GB-SoniaNeural',
      'Male': 'en-GB-RyanNeural',
    },
    'en-IN': {
      'Female': 'en-IN-NeerjaNeural',
      'Male': 'en-IN-PrabhatNeural',
    },
    'en-AU': {
      'Female': 'en-AU-NatashaNeural',
      'Male': 'en-AU-WilliamNeural',
    },
    'en-CA': {
      'Female': 'en-CA-ClaraNeural',
      'Male': 'en-CA-LiamNeural',
    },
    'en-IE': {
      'Female': 'en-IE-EmilyNeural',
      'Male': 'en-IE-ConnorNeural',
    },
  };

  String _selectedVoiceId = 'ur-PK-UzmaNeural';

  /// Returns active Azure voice name
  String get selectedVoiceId => _selectedVoiceId;
  String get selectedVoiceName => _selectedVoiceId;

  Future<void> initialize() async {
    // Initialize fallback device TTS in case Azure key is missing/offline
    await _fallbackTts.initialize();
    _fallbackTts.onStart = () {
      _isSpeaking = true;
      onStart?.call();
    };
    _fallbackTts.onComplete = () {
      _isSpeaking = false;
      onComplete?.call();
    };
    _fallbackTts.onError = (err) {
      _isSpeaking = false;
      onError?.call(err);
    };

    // Configure AudioPlayer callbacks for Azure MP3 playback
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _isSpeaking = true;
        onStart?.call();
      } else if (state == PlayerState.completed || state == PlayerState.stopped) {
        if (_isSpeaking) {
          _isSpeaking = false;
          onComplete?.call();
        }
      }
    });

    _audioPlayer.onLog.listen((msg) {
      // Internal logging for player diagnostics
    });
  }

  Future<void> updateSettings({
    String? voiceId,
    String? locale,
    String? gender,
    double? pitch,
    double? speechRate,
  }) async {
    if (voiceId != null) {
      _selectedVoiceId = voiceId;
      if (voiceId.startsWith('ur-PK')) {
        _userLocale = 'ur-PK';
      } else if (voiceId.startsWith('en-US')) {
        _userLocale = 'en-US';
      } else if (voiceId.startsWith('en-GB')) {
        _userLocale = 'en-GB';
      } else if (voiceId.startsWith('en-AU')) {
        _userLocale = 'en-AU';
      } else if (voiceId.startsWith('en-CA')) {
        _userLocale = 'en-CA';
      } else if (voiceId.startsWith('en-IN')) {
        _userLocale = 'en-IN';
      } else if (voiceId.startsWith('en-IE')) {
        _userLocale = 'en-IE';
      }

      if (voiceId.contains('Asad') ||
          voiceId.contains('Guy') ||
          voiceId.contains('Ryan') ||
          voiceId.contains('Prabhat') ||
          voiceId.contains('William') ||
          voiceId.contains('Liam') ||
          voiceId.contains('Connor')) {
        _voiceGender = 'Male';
      } else {
        _voiceGender = 'Female';
      }
    } else {
      if (locale != null) _userLocale = locale;
      if (gender != null) _voiceGender = gender;
      final voices = _azureVoiceMap[_userLocale] ?? _azureVoiceMap['ur-PK']!;
      _selectedVoiceId = voices[_voiceGender] ?? voices['Female']!;
    }

    if (pitch != null) _pitch = pitch;
    if (speechRate != null) _speechRate = speechRate;

    // Sync settings with fallback TTS as well
    await _fallbackTts.updateSettings(
      locale: _userLocale,
      pitch: pitch,
      speechRate: speechRate != null ? (speechRate * 0.5) : null,
    );
  }


  /// Escape XML special characters for Azure SSML payload
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Format SSML body for Azure Speech REST API
  String _buildSsml(String text, String voiceName, String lang) {
    // Pitch range in SSML: e.g. "+10%", "-5%", default "0%"
    final pitchPct = ((_pitch - 1.0) * 50).round();
    final pitchStr = pitchPct >= 0 ? '+$pitchPct%' : '$pitchPct%';

    // Rate range in SSML: e.g. "+0%", "+15%", "-10%"
    final ratePct = ((_speechRate - 1.0) * 50).round();
    final rateStr = ratePct >= 0 ? '+$ratePct%' : '$ratePct%';

    final safeText = _escapeXml(text);

    return '''<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xmlns:mstts='https://www.w3.org/2001/mstts' xml:lang='$lang'>
  <voice name='$voiceName'>
    <prosody pitch='$pitchStr' rate='$rateStr'>
      $safeText
    </prosody>
  </voice>
</speak>''';
  }

  /// Synthesize speech from Azure Neural TTS REST API
  Future<Uint8List?> _fetchAzureSpeech(String text, String voiceName, String lang) async {
    final endpoint = Uri.parse(
      'https://$_azureRegion.tts.speech.microsoft.com/cognitiveservices/v1',
    );

    final ssml = _buildSsml(text, voiceName, lang);

    final response = await http.post(
      endpoint,
      headers: {
        'Ocp-Apim-Subscription-Key': _azureKey,
        'Content-Type': 'application/ssml+xml',
        'X-Microsoft-OutputFormat': 'audio-24khz-160kbitrate-mono-mp3',
        'User-Agent': 'ZoidVoiceAgent',
      },
      body: utf8.encode(ssml),
    ).timeout(const Duration(seconds: 12));

    if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
      debugPrint('🔊 [Azure TTS] Successfully received ${response.bodyBytes.length} bytes for $voiceName');
      return response.bodyBytes;
    } else {
      debugPrint('❌ [Azure TTS] API Error (${response.statusCode}): ${response.body}');
      return null;
    }
  }

  /// Speak text out loud using Azure Neural voice (with automatic fallback to device TTS)
  Future<void> speak(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    await stop();

    String activeVoice = _selectedVoiceId;
    String activeLang = _userLocale;

    final hasUrduChars = RegExp(r'[\u0600-\u06FF]').hasMatch(cleanText);
    if (hasUrduChars && !activeVoice.startsWith('ur-PK')) {
      activeVoice = _voiceGender == 'Male' ? 'ur-PK-AsadNeural' : 'ur-PK-UzmaNeural';
      activeLang = 'ur-PK';
    }

    if (hasAzureKey) {
      try {
        debugPrint('🎙️ [Azure TTS] Synthesizing speech with voice: $activeVoice ($activeLang)');
        final audioBytes = await _fetchAzureSpeech(cleanText, activeVoice, activeLang);

        if (audioBytes != null && audioBytes.isNotEmpty) {
          _isSpeaking = true;
          onStart?.call();

          Source source;
          if (kIsWeb) {
            // Flutter Web browsers require a data URI URL for in-memory audio
            final base64Audio = base64Encode(audioBytes);
            source = UrlSource('data:audio/mp3;base64,$base64Audio');
          } else {
            source = BytesSource(audioBytes);
          }

          await _audioPlayer.play(source);
          debugPrint('▶️ [Azure TTS] Playing Azure Neural audio stream');
          return;
        }
      } catch (e) {
        debugPrint('⚠️ [Azure TTS] Playback failed: $e. Falling back to device TTS');
      }
    }

    // Fallback: If Azure key missing or request failed, use device TTS gracefully
    debugPrint('ℹ️ [Azure TTS] Using fallback device TTS');
    await _fallbackTts.speak(cleanText);
  }

  /// Test sample voice with currently selected settings
  Future<void> testVoice(String sampleText) async {
    await stop();
    await speak(sampleText);
  }

  /// Stop any ongoing speech immediately
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}

    await _fallbackTts.stop();

    _isSpeaking = false;
    onComplete?.call();
  }

  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
  }
}
