import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../../auth/data/models/auth_response.dart';
import '../../data/models/user_profile_response.dart';
import '../../data/models/update_profile_request.dart';
import '../../data/models/change_password_request.dart';
import '../../data/services/user_service.dart';

/// User service provider
final userServiceProvider = Provider<UserService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserService(apiClient);
});

/// Profile provider - loads user profile
final profileProvider = FutureProvider<UserProfileResponse>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getProfile();
});

/// Profile notifier for managing profile state
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfileResponse>> {
  final UserService _userService;
  final Ref _ref;

  ProfileNotifier(this._userService, this._ref) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _userService.getProfile();
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProfile(UpdateProfileRequest request) async {
    try {
      await _userService.updateProfile(request);
      // Reload profile after update
      await loadProfile();
      
      // Update Auth Provider using the FRESH source of truth from the backend
      // This is more robust than using the request object
      final freshProfile = state.value;
      
      if (freshProfile != null) {
          print('DEBUG: Syncing fresh backend profile to local auth state...');
          
          final currentUser = _ref.read(currentUserProvider);
          if (currentUser != null) {
             final updatedUser = AuthResponse(
                token: currentUser.token,
                userId: currentUser.userId,
                email: freshProfile.email, // Use fresh email
                firstName: freshProfile.firstName, // Use fresh name
                lastName: freshProfile.lastName, // Use fresh name
                profilePicture: freshProfile.profilePicture, // Use fresh picture
              );
              
              await _ref.read(currentUserProvider.notifier).setUser(updatedUser);
              print('DEBUG: Local auth state synced with backend data.');
          }
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      await _userService.changePassword(request);
    } catch (error, stackTrace) {
      // Don't set error state on main profile, just rethrow for UI to handle
      rethrow;
    }
  }

  Future<void> deleteProfile() async {
    try {
      await _userService.deleteProfile();
      // Clear auth state after deletion
      await _ref.read(authTokenProvider.notifier).clearToken();
      await _ref.read(currentUserProvider.notifier).clearUser();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfileResponse>>((ref) {
  final userService = ref.watch(userServiceProvider);
  return ProfileNotifier(userService, ref);
});

