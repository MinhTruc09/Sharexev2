// lib/data/repositories/auth/auth_repository_impl.dart
// Repository Implementation - Auth Data Access

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharexev2/data/models/auth/entities/auth_result.dart';
import 'package:sharexev2/data/models/auth/mappers/user_mapper.dart';
import 'dart:convert';
import '../../models/auth/app_user.dart';
import '../../models/auth/entities/auth_session.dart';
import '../../models/auth/entities/auth_credentials.dart';
import '../../models/auth/entities/user_role.dart';
import '../../models/auth/dtos/register_passenger_request_dto.dart';
import '../../models/auth/dtos/register_driver_request_dto.dart';
import '../../models/auth/mappers/auth_mapper.dart';
import '../../models/auth/dtos/user_dto.dart';
import '../../services/auth_service.dart' as auth_service;
import '../../services/firebase_auth_service.dart';
import 'auth_repository_interface.dart';
import '../../../core/auth/auth_manager.dart';

/// Implementation của AuthRepositoryInterface
/// Combines API service, Firebase service, và local storage
class AuthRepositoryImpl implements AuthRepositoryInterface {
  final auth_service.AuthServiceInterface _authApiService;
  final FirebaseAuthService _firebaseAuthService;
  final SharedPreferences _prefs;

  // Storage keys
  static const String _keyAuthSession = 'auth_session';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyDeviceToken = 'device_token';

  AuthRepositoryImpl({
    required auth_service.AuthServiceInterface authApiService,
    required FirebaseAuthService firebaseAuthService,
    required SharedPreferences prefs,
  }) : _authApiService = authApiService,
       _firebaseAuthService = firebaseAuthService,
       _prefs = prefs;

  // ===== Authentication Status =====

  @override
  Future<bool> isLoggedIn() async {
    try {
      // Check local storage first
      final isLoggedIn = _prefs.getBool(_keyIsLoggedIn) ?? false;
      if (!isLoggedIn) return false;

      // Check if we have valid session
      final session = await getCurrentSession();
      if (session == null || !session.isValid) {
        await clearSession();
        return false;
      }

      // Check if session is expiring soon and try to refresh
      if (session.isExpiringSoon && session.canRefresh) {
        try {
          await refreshToken();
        } catch (e) {
          // If refresh fails, user needs to login again
          await clearSession();
          return false;
        }
      }

      return true;
    } catch (e) {
      await clearSession();
      return false;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userJson = _prefs.getString(_keyCurrentUser);
      if (userJson == null) return null;

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    try {
      final sessionJson = _prefs.getString(_keyAuthSession);
      if (sessionJson == null) return null;

      final sessionMap = json.decode(sessionJson) as Map<String, dynamic>;
      return AuthSession.fromJson(sessionMap);
    } catch (e) {
      return null;
    }
  }

  // ===== Login Operations =====

  @override
  Future<AuthResult> loginWithCredentials(AuthCredentials credentials) async {
    try {
      // Validate credentials
      final errors = credentials.validate();
      if (errors.isNotEmpty) {
        return AuthResult.failure(AuthFailure.validation(errors.first));
      }

      // Call API service
      final loginRequest = AuthMapper.loginRequestFromCredentials(credentials);
      final authResponse = await _authApiService.login(loginRequest);

      // Map response to domain entities
      final session = AuthMapper.sessionFromAuthResponse(authResponse);
      final user = UserMapper.fromUserDto(authResponse.user);

      // Save session and user
      await saveSession(session, user);

      return AuthResult.success(user, session);
    } on auth_service.AuthServiceException catch (e) {
      return AuthResult.failure(AuthFailure.service(e.message, code: e.code));
    } catch (e) {
      return AuthResult.failure(AuthFailure.unknown('Login failed: $e'));
    }
  }

  @override
  Future<AuthResult> loginWithGoogle(String idToken, UserRole role) async {
    try {
      // Call API service with Google ID token
      final googleRequest = AuthMapper.googleSignInRequest(idToken, role);
      final authResponse = await _authApiService.loginWithGoogle(googleRequest);

      // Map response to domain entities
      final session = AuthMapper.sessionFromAuthResponse(authResponse);
      final user = UserMapper.fromUserDto(authResponse.user);

      // Save session and user
      await saveSession(session, user);

      return AuthResult.success(user, session);
    } on auth_service.AuthServiceException catch (e) {
      return AuthResult.failure(AuthFailure.service(e.message, code: e.code));
    } catch (e) {
      return AuthResult.failure(AuthFailure.unknown('Google login failed: $e'));
    }
  }

  @override
  Future<AuthResult> refreshToken() async {
    try {
      final currentSession = await getCurrentSession();
      if (currentSession == null || !currentSession.canRefresh) {
        return AuthResult.failure(
          AuthFailure.session('No valid refresh token available'),
        );
      }

      // Call API service to refresh token
      final refreshRequest = AuthMapper.refreshTokenRequest(
        currentSession.refreshToken,
      );
      final authResponse = await _authApiService.refreshToken(refreshRequest);

      // Map response to domain entities
      final newSession = AuthMapper.sessionFromAuthResponse(authResponse);
      final user = UserMapper.fromUserDto(authResponse.user);

      // Save new session and user
      await saveSession(newSession, user);

      return AuthResult.success(user, newSession);
    } on auth_service.AuthServiceException catch (e) {
      return AuthResult.failure(AuthFailure.service(e.message, code: e.code));
    } catch (e) {
      return AuthResult.failure(
        AuthFailure.unknown('Token refresh failed: $e'),
      );
    }
  }

  // ===== Registration Operations =====

  @override
  Future<AuthResult> registerPassenger(RegisterCredentials credentials) async {
    try {
      // Validate credentials
      final errors = credentials.validate();
      if (errors.isNotEmpty) {
        return AuthResult.failure(AuthFailure.validation(errors.first));
      }

      // Call API service
      final registerRequest = AuthMapper.registerRequestFromCredentials(
        credentials,
        UserRole.passenger,
      );
      // registerRequest may be RegisterPassengerRequestDto or RegisterDriverRequestDto
      final authResponse = await _authApiService.registerPassenger(
        registerRequest as RegisterPassengerRequestDto,
      );

      // Map response to domain entities
      final session = AuthMapper.sessionFromAuthResponse(authResponse);
      final user = UserMapper.fromUserDto(authResponse.user);

      // Save session and user
      await saveSession(session, user);

      return AuthResult.success(user, session);
    } on auth_service.AuthServiceException catch (e) {
      return AuthResult.failure(AuthFailure.service(e.message, code: e.code));
    } catch (e) {
      return AuthResult.failure(
        AuthFailure.unknown('Passenger registration failed: $e'),
      );
    }
  }

  @override
  Future<AuthResult> registerDriver(RegisterCredentials credentials) async {
    try {
      // Validate credentials with license requirement
      final errors = credentials.validate();
      if (errors.isNotEmpty) {
        return AuthResult.failure(AuthFailure.validation(errors.first));
      }

      if (credentials.licenseNumber == null ||
          credentials.licenseNumber!.isEmpty) {
        return AuthResult.failure(
          AuthFailure.validation('License number is required for drivers'),
        );
      }

      // If images provided, use multipart endpoint
      if (credentials.avatarImage != null ||
          credentials.licenseImage != null ||
          credentials.vehicleImage != null) {
        final authResponse = await (_authApiService as auth_service.AuthService)
            .registerDriverMultipart(
              email: credentials.email,
              password: credentials.password,
              fullName: credentials.fullName,
              phoneNumber: credentials.phoneNumber ?? '',
              licensePlate: credentials.licenseNumber ?? '',
              brand: credentials.brand ?? 'Unknown',
              model: credentials.model ?? 'Unknown',
              color: credentials.color ?? 'Unknown',
              numberOfSeats: credentials.numberOfSeats ?? 4,
              avatarImage: credentials.avatarImage,
              licenseImage: credentials.licenseImage,
              vehicleImage: credentials.vehicleImage,
            );

        final session = AuthMapper.sessionFromAuthResponse(authResponse);
        final user = UserMapper.fromUserDto(authResponse.user);
        await saveSession(session, user);
        return AuthResult.success(user, session);
      }

      // Default JSON path
      final registerRequest = AuthMapper.registerRequestFromCredentials(
        credentials,
        UserRole.driver,
      );
      final authResponse = await _authApiService.registerDriver(
        registerRequest as RegisterDriverRequestDto,
      );

      // Map response to domain entities
      final session = AuthMapper.sessionFromAuthResponse(authResponse);
      final user = UserMapper.fromUserDto(authResponse.user);

      // Save session and user
      await saveSession(session, user);

      return AuthResult.success(user, session);
    } on auth_service.AuthServiceException catch (e) {
      return AuthResult.failure(AuthFailure.service(e.message, code: e.code));
    } catch (e) {
      return AuthResult.failure(
        AuthFailure.unknown('Driver registration failed: $e'),
      );
    }
  }

  // ===== Session Management =====

  @override
  Future<void> saveSession(AuthSession session, User user) async {
    try {
      // Save session
      await _prefs.setString(_keyAuthSession, json.encode(session.toJson()));

      // Save user
      await _prefs.setString(_keyCurrentUser, json.encode(user.toJson()));

      // Mark as logged in
      await _prefs.setBool(_keyIsLoggedIn, true);
    } catch (e) {
      throw AuthRepositoryException('Failed to save session: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      // Clear local storage
      await Future.wait([
        _prefs.remove(_keyAuthSession),
        _prefs.remove(_keyCurrentUser),
        _prefs.setBool(_keyIsLoggedIn, false),
      ]);

      // Sign out from Firebase
      await _firebaseAuthService.signOut();
    } catch (e) {
      throw AuthRepositoryException('Failed to clear session: $e');
    }
  }

  @override
  Future<bool> ensureValidSession() async {
    try {
      final session = await getCurrentSession();
      if (session == null) return false;

      if (session.isExpired) {
        await clearSession();
        return false;
      }

      if (session.isExpiringSoon && session.canRefresh) {
        final result = await refreshToken();
        return result.isSuccess;
      }

      return true;
    } catch (e) {
      await clearSession();
      return false;
    }
  }

  // ===== User Profile =====

  @override
  Future<User> updateUserProfile(User user) async {
    try {
      final session = await getCurrentSession();
      if (session == null) {
        throw AuthRepositoryException('No active session');
      }

      // Call API to update profile
      final profileData = UserMapper.toUserDto(user).toJson();
      final updatedProfileData = await _authApiService.updateUserProfile(
        session.accessToken,
        profileData,
      );

      // Map updated data back to User entity
      final updatedUser = UserMapper.fromUserDto(
        UserDto.fromJson(updatedProfileData),
      );

      // Save updated user locally
      await _prefs.setString(
        _keyCurrentUser,
        json.encode(updatedUser.toJson()),
      );

      return updatedUser;
    } on auth_service.AuthServiceException catch (e) {
      throw AuthRepositoryException('Failed to update profile: ${e.message}');
    } catch (e) {
      throw AuthRepositoryException('Failed to update profile: $e');
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final session = await getCurrentSession();
      if (session == null) {
        throw AuthRepositoryException('No active session');
      }

      await _authApiService.changePassword(
        session.accessToken,
        currentPassword,
        newPassword,
      );
    } on auth_service.AuthServiceException catch (e) {
      throw AuthRepositoryException('Failed to change password: ${e.message}');
    } catch (e) {
      throw AuthRepositoryException('Failed to change password: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuthService.sendPasswordResetEmail(email);
    } catch (e) {
      throw AuthRepositoryException('Failed to send password reset email: $e');
    }
  }

  // ===== Device Management =====

  @override
  Future<void> registerDeviceToken(String deviceToken) async {
    try {
      final session = await getCurrentSession();
      if (session == null) return; // Silently fail if no session

      // Get actual user ID from AuthManager
      final currentUser = AuthManager.instance.currentUser;
      final userId =
          currentUser?.id?.toString() ??
          currentUser?.email.value ??
          'unknown_user';

      await _authApiService.registerDevice(deviceToken, userId);
      // Save device token locally for later unregistration
      await _prefs.setString(_keyDeviceToken, deviceToken);
    } catch (e) {
      // Log error but don't throw - device registration is not critical
      print('Failed to register device token: $e');
    }
  }

  @override
  Future<void> unregisterDeviceToken() async {
    try {
      final session = await getCurrentSession();
      if (session == null) return; // Silently fail if no session

      final deviceToken = _prefs.getString(_keyDeviceToken);
      if (deviceToken == null) return;

      await _authApiService.unregisterDevice(deviceToken);
      await _prefs.remove(_keyDeviceToken);
    } catch (e) {
      // Log error but don't throw - device unregistration is not critical
      print('Failed to unregister device token: $e');
    }
  }
}

/// Exception cho Auth Repository operations
class AuthRepositoryException implements Exception {
  final String message;

  const AuthRepositoryException(this.message);

  @override
  String toString() => 'AuthRepositoryException: $message';
}
