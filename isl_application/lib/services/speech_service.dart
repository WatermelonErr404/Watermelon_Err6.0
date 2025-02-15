// services/speech_service.dart
import 'package:isl_application/utils/language_utils.dart';
import 'package:speech_to_text/speech_to_text.dart';
// services/speech_service.dart
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => print('Speech initialization error: $error'),
        onStatus: (status) => print('Speech status: $status'),
      );
      return _isInitialized;
    } catch (e) {
      print('Error initializing speech service: $e');
      return false;
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    required AppLanguage language,
  }) async {
    if (!_isInitialized) {
      onError('Speech recognition not initialized');
      return;
    }

    final localeId = language == AppLanguage.english ? 'en_US' : 'hi_IN';

    try {
      await _speech.listen(
        onResult: (result) => onResult(result.recognizedWords),
        listenFor: Duration(seconds: 30),
        localeId: localeId,
        cancelOnError: true,
        partialResults: true,
      );
    } catch (e) {
      onError('Error starting speech recognition: $e');
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}