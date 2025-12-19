import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

class TtsService {
  final Map<String, String> _audioCache = {}; // text -> file path
  final AudioPlayer _player = AudioPlayer();
  final Dio _dio = Dio();
  String? _apiKey;
  String? _voiceId;
  String? _modelId;

  static const int MAX_CACHE_SIZE = 20;
  static const int MAX_TEXT_LENGTH = 5000;
  // Defaults - used if not set in .env
  static const String DEFAULT_VOICE_ID = "21m00Tcm4TlvDq8ikWAM"; // Rachel
  static const String DEFAULT_MODEL_ID = "eleven_monolingual_v1";

  TtsService() {
    _init();
  }

  void _init() {
    _apiKey = dotenv.env['ELEVENLABS_API_KEY'];
    _voiceId = dotenv.env['ELEVENLABS_VOICE_ID'] ?? DEFAULT_VOICE_ID;
    _modelId = dotenv.env['ELEVENLABS_MODEL_ID'] ?? DEFAULT_MODEL_ID;

    if (_apiKey == null || _apiKey!.isEmpty) {
      print('Warning: ELEVENLABS_API_KEY is missing in .env');
    }
    print('ElevenLabs Config:');
    print('  Voice ID: $_voiceId');
    print('  Model ID: $_modelId');
  }

  Future<void> play(String text) async {
    if (text.length > MAX_TEXT_LENGTH) {
      throw Exception('Text too long for synthesis');
    }

    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('ElevenLabs API Key not found');
    }

    // On web, use BytesSource instead of file
    if (kIsWeb) {
      return _playOnWeb(text);
    }

    // Mobile: Use file-based approach
    return _playOnMobile(text);
  }

  Future<void> _playOnWeb(String text) async {
    // Synthesize and play directly from bytes
    try {
      final response = await _dio.post(
        'https://api.elevenlabs.io/v1/text-to-speech/$_voiceId',
        options: Options(
          headers: {'xi-api-key': _apiKey, 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
        data: {
          "text": text,
          "model_id": _modelId,
          "voice_settings": {"stability": 0.5, "similarity_boost": 0.5},
        },
      );

      if (response.statusCode == 200) {
        final bytes = Uint8List.fromList(response.data);
        await _player.play(BytesSource(bytes));
      } else {
        throw Exception(
          'ElevenLabs API failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('TTS failed: $e');
    }
  }

  Future<void> _playOnMobile(String text) async {
    // Check cache first
    if (_audioCache.containsKey(text)) {
      final path = _audioCache[text]!;
      if (await File(path).exists()) {
        await _player.play(DeviceFileSource(path));
        return;
      } else {
        _audioCache.remove(text);
      }
    }

    // Synthesize API Call
    try {
      final tempDir = await getTemporaryDirectory();
      final String fileName =
          'tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final String filePath = '${tempDir.path}/$fileName';

      final response = await _dio.post(
        'https://api.elevenlabs.io/v1/text-to-speech/$_voiceId',
        options: Options(
          headers: {'xi-api-key': _apiKey, 'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
        data: {
          "text": text,
          "model_id": _modelId,
          "voice_settings": {"stability": 0.5, "similarity_boost": 0.5},
        },
      );

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.data);

        // Update cache (with eviction)
        if (_audioCache.length >= MAX_CACHE_SIZE) {
          final oldestKey = _audioCache.keys.first;
          // Optionally delete old file
          final oldPath = _audioCache[oldestKey];
          if (oldPath != null && await File(oldPath).exists()) {
            await File(oldPath).delete();
          }
          _audioCache.remove(oldestKey);
        }
        _audioCache[text] = filePath;

        await _player.play(DeviceFileSource(filePath));
      } else {
        throw Exception(
          'ElevenLabs API failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('TTS failed: $e');
    }
  }

  Future<void> stop() => _player.stop();

  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  void dispose() {
    _player.dispose();
  }
}
