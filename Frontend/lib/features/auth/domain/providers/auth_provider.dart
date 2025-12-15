import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/auth_response.dart';
import '../../data/services/auth_service.dart';

/// Secure storage for tokens
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Auth token provider - stores JWT token
final authTokenProvider = StateNotifierProvider<AuthTokenNotifier, String?>((ref) {
  return AuthTokenNotifier(ref.watch(secureStorageProvider));
});

class AuthTokenNotifier extends StateNotifier<String?> {
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';

  AuthTokenNotifier(this._storage) : super(null) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    state = await _storage.read(key: _tokenKey);
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    state = token;
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    state = null;
  }
}

/// API client provider with auth token
final apiClientProvider = Provider<ApiClient>((ref) {
  final token = ref.watch(authTokenProvider);
  return ApiClient(authToken: token);
});

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});

/// Current user provider - stores user info from auth response
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AuthResponse?>((ref) {
  return CurrentUserNotifier(ref.watch(secureStorageProvider));
});

class CurrentUserNotifier extends StateNotifier<AuthResponse?> {
  final FlutterSecureStorage _storage;
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';
  static const String _firstNameKey = 'user_first_name';
  static const String _lastNameKey = 'user_last_name';
  static const String _profilePictureKey = 'user_profile_picture';
  static const String _tokenKey = 'auth_token';

  CurrentUserNotifier(this._storage) : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final token = await _storage.read(key: _tokenKey);
    final userIdStr = await _storage.read(key: _userIdKey);
    final email = await _storage.read(key: _emailKey);
    final firstName = await _storage.read(key: _firstNameKey);
    final lastName = await _storage.read(key: _lastNameKey);
    final profilePicture = await _storage.read(key: _profilePictureKey);

    if (token != null && userIdStr != null && email != null && firstName != null && lastName != null) {
      state = AuthResponse(
        token: token,
        userId: int.parse(userIdStr),
        email: email,
        firstName: firstName,
        lastName: lastName,
        profilePicture: profilePicture,
      );
    }
  }

  Future<void> setUser(AuthResponse user) async {
    try {
      await _storage.write(key: _tokenKey, value: user.token);
      await _storage.write(key: _userIdKey, value: user.userId.toString());
      await _storage.write(key: _emailKey, value: user.email);
      await _storage.write(key: _firstNameKey, value: user.firstName);
      await _storage.write(key: _lastNameKey, value: user.lastName);
      if (user.profilePicture != null) {
        await _storage.write(key: _profilePictureKey, value: user.profilePicture);
      } else {
        await _storage.delete(key: _profilePictureKey);
      }
    } catch (e) {
      print('Error saving user to storage: $e');
      // Continue to update state even if storage fails
    }
    state = user;
  }

  Future<void> clearUser() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _firstNameKey);
    await _storage.delete(key: _lastNameKey);
    await _storage.delete(key: _profilePictureKey);
    state = null;
  }
}

/// Auth state provider - checks if user is authenticated
final authStateProvider = Provider<bool>((ref) {
  final token = ref.watch(authTokenProvider);
  return token != null && token.isNotEmpty;
});

/// User ID provider - extracts userId from current user
final userIdProvider = Provider<int?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.userId;
});
