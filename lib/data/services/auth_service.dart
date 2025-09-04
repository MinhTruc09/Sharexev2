// lib/data/services/auth_service.dart
// Service Implementation - Auth API Operations

import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../config/app_config.dart';
import '../models/auth/dtos/auth_response_dto.dart';
import '../models/auth/dtos/login_request_dto.dart';
import '../models/auth/dtos/google_login_request_dto.dart';
import '../models/auth/dtos/register_passenger_request_dto.dart';
import '../models/auth/dtos/register_driver_request_dto.dart';
import '../models/auth/dtos/refresh_token_request_dto.dart';

/// Auth Service Interface
abstract class AuthServiceInterface {
  Future<AuthResponseDto> login(LoginRequestDto request);
  // Note: register method removed - use registerPassenger or registerDriver instead
  Future<AuthResponseDto> refreshToken(RefreshTokenRequestDto request);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  // Additional methods needed by repository
  Future<AuthResponseDto> loginWithGoogle(GoogleLoginRequestDto googleRequest);
  Future<AuthResponseDto> registerPassenger(
    RegisterPassengerRequestDto registerRequest,
  );
  Future<AuthResponseDto> registerDriver(
    RegisterDriverRequestDto registerRequest,
  );
  Future<AuthResponseDto> registerDriverMultipart({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String licensePlate,
    required String brand,
    required String model,
    required String color,
    required int numberOfSeats,
    File? avatarImage,
    File? licenseImage,
    File? vehicleImage,
  });
  Future<Map<String, dynamic>> updateUserProfile(
    String token,
    Map<String, dynamic> profileData,
  );
  Future<void> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  );
  Future<void> resetPassword(String email);
  Future<void> verifyEmail(String token);
  Future<void> resendVerificationEmail(String email);
  Future<void> registerDevice(String deviceToken, String userId);
  Future<void> unregisterDevice(String deviceToken);
}

/// Implementation của AuthServiceInterface
/// Handles tất cả auth API calls với proper error handling
class AuthService implements AuthServiceInterface {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  // ===== Authentication Operations =====

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    try {
      final response = await _apiClient.client.post(
        AppConfig.I.auth.login,
        data: request.toJson(),
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e, 'login');
    } catch (e) {
      throw AuthServiceException('Unexpected error during login: $e');
    }
  }

  // register method removed - use registerPassenger or registerDriver instead

  @override
  Future<AuthResponseDto> refreshToken(RefreshTokenRequestDto request) async {
    try {
      final response = await _apiClient.client.post(
        AppConfig.I.auth.refresh,
        data: request.toJson(),
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e, 'refresh token');
    } catch (e) {
      throw AuthServiceException('Unexpected error during token refresh: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.client.post(AppConfig.I.auth.logout);
    } on DioException catch (e) {
      _handleDioException(e, 'logout');
    } catch (e) {
      throw AuthServiceException('Unexpected error during logout: $e');
    }
  }

  // ===== Additional Authentication Methods =====

  @override
  Future<AuthResponseDto> loginWithGoogle(GoogleLoginRequestDto request) async {
    try {
      final response = await _apiClient.client.post(
        AppConfig.I.auth.googleSignIn,
        data: request.toJson(),
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e, 'loginWithGoogle');
    } catch (e) {
      throw AuthServiceException('Unexpected error during Google login: $e');
    }
  }

  @override
  Future<AuthResponseDto> registerPassenger(
    RegisterPassengerRequestDto request,
  ) async {
    try {
      // API docs show query parameters, not body
      final queryParams = {
        'email': request.email,
        'password': request.password,
        'fullName': request.fullName,
        'phone': request.phoneNumber,
      };

      final response = await _apiClient.client.post(
        AppConfig.I.auth.registerPassenger,
        queryParameters: queryParams,
        // No data needed since all required fields are in query params
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e, 'registerPassenger');
    } catch (e) {
      throw AuthServiceException(
        'Unexpected error during passenger registration: $e',
      );
    }
  }

  @override
  Future<AuthResponseDto> registerDriver(
    RegisterDriverRequestDto request,
  ) async {
    try {
      // Check if we have image URLs to use multipart endpoint
      if (request.avatarUrl != null ||
          request.licenseImageUrl != null ||
          request.vehicleImageUrl != null) {
        // Use multipart endpoint for images
        return await registerDriverMultipart(
          email: request.email,
          password: request.password,
          fullName: request.fullName,
          phoneNumber: request.phoneNumber,
          licensePlate: request.licensePlate,
          brand: request.brand,
          model: request.model,
          color: request.color,
          numberOfSeats: request.numberOfSeats,
          // File uploads should be handled separately in multipart request
          // For now, these are URL strings that will be handled by the API
          avatarImage: null, // request.avatarUrl will be included in API call
          licenseImage:
              null, // request.licenseImageUrl will be included in API call
          vehicleImage:
              null, // request.vehicleImageUrl will be included in API call
        );
      }

      // Build query parameters as required by API docs
      final queryParams = {
        'email': request.email,
        'phone': request.phoneNumber,
        'password': request.password,
        'fullName': request.fullName,
        'licensePlate': request.licensePlate,
        'brand': request.brand,
        'model': request.model,
        'color': request.color,
        'numberOfSeats': request.numberOfSeats.toString(),
      };

      // API docs show parameters in query string, not in body
      // Request body is multipart/form-data but only for optional images
      final response = await _apiClient.client.post(
        AppConfig.I.auth.registerDriver,
        queryParameters: queryParams,
        // No data needed since all required fields are in query params
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e, 'registerDriver');
    } catch (e) {
      throw AuthServiceException(
        'Unexpected error during driver registration: $e',
      );
    }
  }

  @override
  Future<AuthResponseDto> registerDriverMultipart({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String licensePlate,
    required String brand,
    required String model,
    required String color,
    required int numberOfSeats,
    File? avatarImage,
    File? licenseImage,
    File? vehicleImage,
  }) async {
    try {
      final formData = FormData();
      formData.fields
        ..add(MapEntry('email', email))
        ..add(MapEntry('password', password))
        ..add(MapEntry('fullName', fullName))
        ..add(MapEntry('phone', phoneNumber))
        ..add(MapEntry('licensePlate', licensePlate))
        ..add(MapEntry('brand', brand))
        ..add(MapEntry('model', model))
        ..add(MapEntry('color', color))
        ..add(MapEntry('numberOfSeats', numberOfSeats.toString()));

      if (avatarImage != null) {
        formData.files.add(
          MapEntry(
            'avatarImage',
            await MultipartFile.fromFile(
              avatarImage.path,
              filename: avatarImage.uri.pathSegments.last,
            ),
          ),
        );
      }
      if (licenseImage != null) {
        formData.files.add(
          MapEntry(
            'licenseImage',
            await MultipartFile.fromFile(
              licenseImage.path,
              filename: licenseImage.uri.pathSegments.last,
            ),
          ),
        );
      }
      if (vehicleImage != null) {
        formData.files.add(
          MapEntry(
            'vehicleImage',
            await MultipartFile.fromFile(
              vehicleImage.path,
              filename: vehicleImage.uri.pathSegments.last,
            ),
          ),
        );
      }

      final response = await _apiClient.client.post(
        AppConfig.I.auth.registerDriver,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioException(e, 'registerDriverMultipart');
    } catch (e) {
      throw AuthServiceException(
        'Unexpected error during driver registration (multipart): $e',
      );
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      // Implementation depends on storage mechanism
      // This is a placeholder
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      // Implementation depends on storage mechanism
      // This is a placeholder
      return null;
    } catch (e) {
      return null;
    }
  }

  // ===== Profile Management =====

  @override
  Future<Map<String, dynamic>> updateUserProfile(
    String token,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await _apiClient.client.put(
        AppConfig.I.auth.profile,
        data: profileData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioException(e, 'updateUserProfile');
    } catch (e) {
      throw AuthServiceException('Unexpected error during profile update: $e');
    }
  }

  @override
  Future<void> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _apiClient.client.post(
        AppConfig.I.auth.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      _handleDioException(e, 'changePassword');
    } catch (e) {
      throw AuthServiceException('Unexpected error during password change: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _apiClient.client.post(
        '/auth/reset-password', // Add this endpoint to config if needed
        data: {'email': email},
      );
    } on DioException catch (e) {
      _handleDioException(e, 'resetPassword');
    } catch (e) {
      throw AuthServiceException('Unexpected error during password reset: $e');
    }
  }

  @override
  Future<void> verifyEmail(String token) async {
    try {
      await _apiClient.client.post(
        AppConfig.I.auth.verify,
        data: {'token': token},
      );
    } on DioException catch (e) {
      _handleDioException(e, 'verifyEmail');
    } catch (e) {
      throw AuthServiceException(
        'Unexpected error during email verification: $e',
      );
    }
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _apiClient.client.post(
        '/auth/resend-verification', // Add this endpoint to config if needed
        data: {'email': email},
      );
    } on DioException catch (e) {
      _handleDioException(e, 'resendVerificationEmail');
    } catch (e) {
      throw AuthServiceException(
        'Unexpected error during resend verification: $e',
      );
    }
  }

  // ===== Device Management =====

  @override
  Future<void> registerDevice(String deviceToken, String userId) async {
    try {
      await _apiClient.client.post(
        AppConfig.I.auth.registerDevice,
        data: {
          'deviceToken': deviceToken,
          'userId': userId,
          'platform': 'mobile',
        },
      );
    } on DioException catch (e) {
      _handleDioException(e, 'registerDevice');
    } catch (e) {
      throw AuthServiceException(
        'Unexpected error during device registration: $e',
      );
    }
  }

  @override
  Future<void> unregisterDevice(String deviceToken) async {
    try {
      await _apiClient.client.post(
        AppConfig.I.auth.unregisterDevice,
        data: {'deviceToken': deviceToken},
      );
    } on DioException catch (e) {
      _handleDioException(e, 'unregisterDevice');
    } catch (e) {
      throw AuthServiceException(
        'Unexpected error during device unregistration: $e',
      );
    }
  }

  // ===== Error Handling =====

  Never _handleDioException(DioException e, String operation) {
    String message;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout during $operation';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout during $operation';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout during $operation';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        if (statusCode == 401) {
          message = 'Authentication failed during $operation';
        } else if (statusCode == 403) {
          message = 'Access forbidden during $operation';
        } else if (statusCode == 422) {
          message =
              'Validation error during $operation: ${responseData?['message'] ?? 'Invalid data'}';
        } else {
          message = 'Server error during $operation: $statusCode';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled during $operation';
        break;
      default:
        message = 'Network error during $operation: $e';
    }
    throw AuthServiceException(message);
  }
}

/// Auth Service Exception
class AuthServiceException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  const AuthServiceException(this.message, {this.code, this.details});

  @override
  String toString() => 'AuthServiceException: $message';
}

/// Firebase Auth Service for social login
class FirebaseAuthService {
  static bool get isAvailable => true; // Placeholder

  String? get currentUser => null; // Placeholder

  Future<String?> getIdToken() async {
    // Placeholder implementation
    return null;
  }

  Future<void> signOut() async {
    // Placeholder implementation
  }
}
