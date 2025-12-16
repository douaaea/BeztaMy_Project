import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/services/chatbot_service.dart';

/// Provider for ChatbotService
final chatbotServiceProvider = Provider<ChatbotService>((ref) {
  final authToken = ref.watch(authTokenProvider);

  if (authToken == null) {
    throw Exception('Not authenticated');
  }

  return ChatbotService(
    dio: Dio(),
    authToken: authToken,
    pythonBackendUrl: AppConstants.pythonBackendUrl,
  );
});

/// Provider for checking backend health
final chatbotHealthProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(chatbotServiceProvider);
  return await service.checkHealth();
});
