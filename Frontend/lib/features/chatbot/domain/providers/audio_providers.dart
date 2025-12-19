import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/tts_service.dart';
import '../../data/services/stt_service.dart';

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});

final sttServiceProvider = Provider<SttService>((ref) {
  return SttService();
});
