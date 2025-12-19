import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SttService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;

  /// Initialize speech recognition - should be called once on app/screen load
  /// This follows the official speech_to_text documentation pattern
  Future<void> init() async {
    if (_speechEnabled) return; // Only initialize once

    // Speech recognition on web has limitations
    if (kIsWeb) {
      print('Warning: Speech recognition on web may have limited support');
    }

    try {
      _speechEnabled = await _speech.initialize(
        onError: (error) => print('STT Error: $error'),
        onStatus: (status) => print('STT Status: $status'),
      );

      if (_speechEnabled) {
        print('Speech recognition initialized successfully');
      } else {
        print('Speech recognition not available on this device');
      }
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      _speechEnabled = false;
    }
  }

  /// Start listening for speech input
  /// Follows documentation pattern with simpler API
  Future<void> startListening(Function(String) onResult) async {
    // Auto-initialize if not done yet (defensive programming)
    if (!_speechEnabled) {
      await init();
    }

    // Check again after initialization attempt
    if (!_speechEnabled) {
      throw Exception('Speech recognition not available on this platform');
    }

    // Start listening (matches documentation example)
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 30), // Max duration
      pauseFor: const Duration(seconds: 3), // Auto-stop after 3s silence
      partialResults: true, // Real-time updates
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  /// Stop the active speech recognition session
  Future<void> stopListening() => _speech.stop();

  /// Check if speech recognition is currently listening
  bool get isListening => _speech.isListening;

  /// Check if speech recognition is NOT listening (matches doc example)
  bool get isNotListening => _speech.isNotListening;

  /// Check if speech recognition is available on this device
  bool get isEnabled => _speechEnabled;

  /// Clean up resources
  void dispose() {
    if (isListening) {
      _speech.cancel();
    }
  }
}
