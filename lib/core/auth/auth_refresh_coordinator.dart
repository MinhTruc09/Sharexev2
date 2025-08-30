// Coordinator to attempt token refresh using backend refresh token first,
// and fallback to exchanging Firebase ID token when available.

import 'package:sharexev2/data/repositories/auth/auth_api_repository.dart';
import 'package:sharexev2/data/services/auth_service.dart';
import 'package:sharexev2/data/services/service_registry.dart';
import 'package:sharexev2/core/auth/auth_manager.dart';
import 'package:sharexev2/data/services/firebase_service.dart';
import 'package:sharexev2/config/app_config.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/auth/dtos/auth_response_dto.dart';
import 'package:sharexev2/data/models/auth/mappers/user_mapper.dart';

/// Attempts to refresh tokens. Strategy:
/// 1) Try backend refresh via AuthApiRepository.refreshToken()
/// 2) If that fails and Firebase signed-in user exists, get Firebase ID token
///    and POST it to the backend exchange endpoint (AppConfig.I.auth.googleSignIn)
///    to obtain new app tokens.
class AuthRefreshCoordinator {
  static final _registry = ServiceRegistry.I;

  /// Try refresh and return true when new tokens are stored, false otherwise.
  static Future<bool> tryRefresh() async {
    final authManager = AuthManager();

    // 1) Try backend refresh via repository
    try {
      final repo = AuthApiRepository(
        AuthService(_registry.apiClient),
        authManager,
      );
      await repo.refreshToken();
      return true;
    } catch (_) {
      // ignore and fall back to Firebase exchange
    }

    // 2) Fallback: use Firebase ID token if available
    try {
      if (!FirebaseService.isAvailable) return false;

      final fbUser = FirebaseService.currentUser;
      if (fbUser == null) return false;

      final idToken = await fbUser.getIdToken(true);
      if (idToken == null || idToken.isEmpty) return false;

      // Exchange ID token with backend via API client
      final client = _registry.apiClient.client;
      final response = await client.post(
        AppConfig.I.auth.googleSignIn,
        data: {'idToken': idToken},
      );

      final apiRes = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (d) => AuthResponseDto.fromJson(d),
      );

      final dto = apiRes.data as AuthResponseDto;

      // Persist new session via AuthManager
      final user = UserMapper.userFromDto(dto.user);
      await authManager.saveSession(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
        user: user,
      );

      return true;
    } catch (e) {
      // any failure -> cannot refresh
      try {
        await authManager.clearSession();
      } catch (_) {}
      return false;
    }
  }
}
