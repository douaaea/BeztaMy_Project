import 'package:flutter/material.dart';

class AppConstants {
  // Spring Boot Backend URL - can be overridden with --dart-define=API_BASE_URL=...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8085',
  );

  // Python RAG Backend URL - can be overridden with --dart-define=PYTHON_BACKEND_URL=...
  static const String pythonBackendUrl = String.fromEnvironment(
    'PYTHON_BACKEND_URL',
    defaultValue: 'http://localhost:8000',
  );

  // API paths
  static const String apiBasePath = '/api';
  static const String authPath = '$apiBasePath/auth';
  static const String usersPath = '$apiBasePath/users';
  static const String categoriesPath = '$apiBasePath/categories';
  static const String transactionsPath = '$apiBasePath/transactions';

  static const String appName = 'BeztaMy';

  static const Color appBackgroundColor = Color(0xFFF9F7F1);
}
