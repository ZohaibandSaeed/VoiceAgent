import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isAvailable = false;
  String _currentLocaleId = '';

  bool get isAvailable => _isAvailable;
  bool get isListening => _speechToText.isListening;

  Future<bool> initialize({
    Function(String status)? onStatus,
    Function(dynamic error)? onError,
  }) async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      return false;
    }

    _isAvailable = await _speechToText.initialize(
      onStatus: (status) => onStatus?.call(status),
      onError: (errorNotification) => onError?.call(errorNotification),
      debugLogging: false,
    );

    if (_isAvailable) {
      final systemLocale = await _speechToText.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    return _isAvailable;
  }

  Future<void> startListening({
    required Function(String words, bool isFinal) onResult,
    Function(double soundLevel)? onSoundLevelChange,
    String? localeId,
  }) async {
    // Reset any hanging previous session
    if (_speechToText.isListening) {
      await _speechToText.stop();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!_isAvailable) {
      final reInit = await initialize();
      if (!reInit) {
        throw Exception('Microphone permission or speech recognition not available.');
      }
    }

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      onSoundLevelChange: onSoundLevelChange,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
        localeId: localeId ?? (_currentLocaleId.isNotEmpty ? _currentLocaleId : null),
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  Future<void> cancelListening() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
  }
}
