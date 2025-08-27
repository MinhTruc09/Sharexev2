// lib/data/repositories/auth/auth_api_repository.dart
import 'package:dio/dio.dart';
import 'package:sharexev2/core/auth/auth_manager.dart';
import 'package:sharexev2/config/app_config.dart';
import 'package:sharexev2/data/models/auth/auth_reponse_dto.dart';
import 'package:sharexev2/data/models/auth/mappers/app_user_mapper.dart';
import 'package:sharexev2/data/repositories/auth/auth_repository.dart';
import 'package:sharexev2/data/models/auth/app_user.dart';
import 'package:sharexev2/core/network/api_response.dart';

class AuthApiRepository implements AuthRepository {
  final Dio _dio;
  final AuthManager _authManager = AuthManager();

  AuthApiRepository(this._dio);

  @override
  Future<bool> isLoggedIn() async {
    return _authManager.getToken() != null;
  }

  @override
  Future<String?> getAuthToken() async {
    return _authManager.getToken();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    return _authManager.currentUser;
  }

  @override
  Future<AppUser> loginWithEmail(String email, String password) async {
    final res = await _dio.post(
      AppConfig.I.auth.login,
      data: {"email": email, "password": password},
    );

    final apiResponse = ApiResponse.fromJson(
      res.data,
      (json) => AuthResponseDto.fromJson(json),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception("Login failed: ${apiResponse.message}");
    }

    final dto = apiResponse.data!;
    final user = AppUserMapper.fromUserDto(dto.user);

    await _authManager.saveSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      user: user,
    );

    return user;
  }

  @override
  Future<AppUser> registerPassenger(
    String email,
    String password,
    String fullName,
  ) async {
    final res = await _dio.post(
      AppConfig.I.auth.registerPassenger,
      data: {"email": email, "password": password, "fullName": fullName},
    );

    final apiResponse = ApiResponse.fromJson(
      res.data,
      (json) => AuthResponseDto.fromJson(json),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception("Register failed: ${apiResponse.message}");
    }

    final dto = apiResponse.data!;
    final user = AppUserMapper.fromUserDto(dto.user);

    await _authManager.saveSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      user: user,
    );

    return user;
  }

  @override
  Future<AppUser> registerDriver(
    String email,
    String password,
    String fullName,
    String licenseNumber,
  ) async {
    final res = await _dio.post(
      AppConfig.I.auth.registerDriver,
      data: {
        "email": email,
        "password": password,
        "fullName": fullName,
        "licenseNumber": licenseNumber,
      },
    );

    final apiResponse = ApiResponse.fromJson(
      res.data,
      (json) => AuthResponseDto.fromJson(json),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception("Register driver failed: ${apiResponse.message}");
    }

    final dto = apiResponse.data!;
    final user = AppUserMapper.fromUserDto(dto.user);

    await _authManager.saveSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      user: user,
    );

    return user;
  }

  @override
  Future<void> refreshToken() async {
    throw UnimplementedError("Refresh token chưa được implement");
  }

  @override
  Future<void> logout() async {
    await _authManager.clearSession();
  }
}
