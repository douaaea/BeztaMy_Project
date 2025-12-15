import '../../../../core/network/api_client.dart';
import '../models/user_profile_response.dart';
import '../models/update_profile_request.dart';
import '../models/change_password_request.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  /// Get user profile
  Future<UserProfileResponse> getProfile() async {
    final response = await _apiClient.get('/users/profile');
    return UserProfileResponse.fromJson(response.data);
  }

  /// Update user profile
  Future<void> updateProfile(UpdateProfileRequest request) async {
    await _apiClient.put(
      '/users/profile',
      data: request.toJson(),
    );
  }

  /// Change password
  Future<void> changePassword(ChangePasswordRequest request) async {
    await _apiClient.put(
      '/users/change-password',
      data: request.toJson(),
    );
  }

  /// Delete user profile
  Future<void> deleteProfile() async {
    await _apiClient.delete('/users/profile');
  }
}
