import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  Function()? onStart;
  Function()? onComplete;
  Function(String error)? onError;

  static bool get _isIOS => !kIsWeb && Platform.isIOS;

  // Customizable voice properties
  String _userLocale = 'en-US';
  double _pitch = 1.0;
  double _speechRate = _isIOS ? 0.5 : 0.48;

  bool get isSpeaking => _isSpeaking;
  String get userLocale => _userLocale;
  double get pitch => _pitch;
  double get speechRate => _speechRate;

  Future<void> initialize() async {
    await _applySettings();

    // Await speak completion so future questions are never blocked
    await _flutterTts.awaitSpeakCompletion(true);

    if (_isIOS) {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );
    }

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      onStart?.call();
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      onComplete?.call();
    });

    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
      onComplete?.call();
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      onError?.call(msg.toString());
    });
  }

  Future<void> _applySettings() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setSpeechRate(_speechRate);
  }

  Future<void> updateSettings({
    String? locale,
    double? pitch,
    double? speechRate,
  }) async {
    if (locale != null) _userLocale = locale;
    if (pitch != null) _pitch = pitch;
    if (speechRate != null) _speechRate = speechRate;
    await _applySettings();
  }

  /// Detects whether text contains Urdu/Arabic characters or English/Latin
  String _detectLanguage(String text) {
    final urduRegex = RegExp(r'[\u0600-\u06FF]');
    if (urduRegex.hasMatch(text)) {
      return 'ur-PK';
    }
    // Respect the user's selected accent/locale
    return _userLocale;
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    final lang = _detectLanguage(text);
    try {
      final isLanguageAvailable = await _flutterTts.isLanguageAvailable(lang);
      if (isLanguageAvailable == true) {
        await _flutterTts.setLanguage(lang);
      } else {
        await _flutterTts.setLanguage(_userLocale);
      }
    } catch (_) {
      await _flutterTts.setLanguage('en-US');
    }

    _isSpeaking = true;
    onStart?.call();

    try {
      await _flutterTts.speak(text);
    } finally {
      _isSpeaking = false;
      onComplete?.call();
    }
  }

  Future<void> testVoice(String sampleText) async {
    if (_isSpeaking) {
      await stop();
    }
    await speak(sampleText);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    onComplete?.call();
  }
}
