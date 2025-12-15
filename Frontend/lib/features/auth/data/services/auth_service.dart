import '../../../../core/network/api_client.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Login with email and password
  Future<AuthResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    
    final response = await _apiClient.post(
      '/auth/login',
      data: request.toJson(),
    );

    return AuthResponse.fromJson(response.data);
  }

  /// Register a new user
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: request.toJson(),
    );

    return AuthResponse.fromJson(response.data);
  }

  /// Logout (clear token handled by provider)
  Future<void> logout() async {
    // Token clearing is handled by the auth provider
    // This method exists for future server-side logout if needed
  }
}
