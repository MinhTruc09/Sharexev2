import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/auth/api/login_request_dto.dart';
import 'package:sharexev2/data/models/auth/auth_response_dto.dart';
import 'package:sharexev2/config/app_config.dart';

class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  /// Đăng nhập → AuthResponseDto
  Future<AuthResponseDto> login(LoginRequestDTO request) async {
    final res = await _api.client.post(
      AppConfig.I.auth.login,
      data: request.toJson(),
    );

    final apiRes = ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (data) => AuthResponseDto.fromJson(data),
    );

    return apiRes.data as AuthResponseDto;
  }

  /// Đăng ký hành khách → AuthResponseDto
  Future<AuthResponseDto> registerPassenger(
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.client.post(
      AppConfig.I.auth.registerPassenger,
      data: payload,
    );

    final apiRes = ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (data) => AuthResponseDto.fromJson(data),
    );

    return apiRes.data as AuthResponseDto;
  }

  /// Đăng ký tài xế → AuthResponseDto
  Future<AuthResponseDto> registerDriver(Map<String, dynamic> payload) async {
    final res = await _api.client.post(
      AppConfig.I.auth.registerDriver,
      data: payload,
    );

    final apiRes = ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (data) => AuthResponseDto.fromJson(data),
    );

    return apiRes.data as AuthResponseDto;
  }

  /// TODO: Refresh token (backend cần cung cấp API này)
  Future<AuthResponseDto?> refreshToken(String refreshToken) async {
    // final res = await _api.client.post(
    //   AppConfig.I.auth.refresh,
    //   data: {"refreshToken": refreshToken},
    // );
    // final apiRes = ApiResponse.fromJson(
    //   res.data as Map<String, dynamic>,
    //   (data) => AuthResponseDto.fromJson(data),
    // );
    // return apiRes.data as AuthResponseDto;
    return null;
  }
}
