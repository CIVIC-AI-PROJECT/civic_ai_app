import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  String _recognizedText = '';

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;

  Future<void> initializeSpeech() async {
    try {
      bool available = await _speechToText.initialize(
        onError: (error) => print('Error: $error'),
        onStatus: (status) => print('Status: $status'),
      );
      if (!available) {
        print('Speech to text not available');
      }
    } catch (e) {
      print('Error initializing speech to text: $e');
    }
  }

  Future<void> initializeTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
    } catch (e) {
      // TTS initialization may fail on some devices, non-critical
      debugPrint('TTS initialization failed: $e');
    }
  }

  Future<String> startListening({
    required String languageCode,
    Function(String)? onResult,
  }) async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        _isListening = true;
        _recognizedText = '';
        await _speechToText.listen(
          onResult: (result) {
            _recognizedText = result.recognizedWords;
            if (result.finalResult) {
              _isListening = false;
              onResult?.call(_recognizedText);
            }
          },
          localeId: languageCode,
        );
      }
    }
    return _recognizedText;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      _isListening = false;
      await _speechToText.stop();
    }
  }

  Future<void> speak(String text, {required String languageCode}) async {
    try {
      await _flutterTts.setLanguage(languageCode);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
  }
}
