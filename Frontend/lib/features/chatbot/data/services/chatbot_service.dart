import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';

/// Service for chatbot API communication with Python RAG backend
class ChatbotService {
  final Dio _dio;
  final String _pythonBackendUrl;

  ChatbotService({
    required Dio dio,
    required String authToken,
    String pythonBackendUrl = 'http://localhost:8000',
  })  : _dio = dio,
        _pythonBackendUrl = pythonBackendUrl {
    // Configure Dio for Python backend
    _dio.options = BaseOptions(
      baseUrl: pythonBackendUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );
  }

  /// Send a message to the chatbot
  ///
  /// Returns the bot's response
  Future<String> sendMessage({
    required String question,
    required String sessionId,
  }) async {
    try {
      final response = await _dio.post(
        '/chat',
        data: {
          'question': question,
          'session_id': sessionId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['answer'] as String;
      } else {
        throw ApiException('Unexpected response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get chat history for a session
  Future<Map<String, dynamic>> getChatHistory(String sessionId) async {
    try {
      final response = await _dio.get('/chat/history/$sessionId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Clear chat history for a session
  Future<void> clearChatHistory(String sessionId) async {
    try {
      await _dio.delete('/chat/history/$sessionId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Check backend health
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      final data = response.data as Map<String, dynamic>;
      return data['status'] == 'healthy';
    } on DioException catch (e) {
      print('Health check failed: ${e.message}');
      return false;
    }
  }

  /// Handle Dio errors
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data is Map
            ? (error.response?.data['detail'] ?? 'Unknown error')
            : error.response?.data?.toString() ?? 'Unknown error';

        if (statusCode == 401) {
          return UnauthorizedException(
            'Authentication failed. Please log in again.',
          );
        } else if (statusCode == 403) {
          return UnauthorizedException('Access denied.');
        } else if (statusCode == 500) {
          return ServerException(
            'Server error. Please try again later.',
            statusCode: statusCode,
          );
        }
        return ApiException(message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return ApiException('Request cancelled');

      default:
        return NetworkException(
          'Network error. Please check your connection.',
        );
    }
  }
}
