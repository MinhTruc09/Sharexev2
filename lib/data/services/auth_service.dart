import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/auth/api/login_request_dto.dart';
import 'package:sharexev2/data/models/auth/auth_reponse_dto.dart';
import 'package:sharexev2/data/models/auth/mappers/app_user_mapper.dart';
import 'package:sharexev2/data/models/auth/app_user.dart';
import 'package:sharexev2/config/app_config.dart';

class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  /// Đăng nhập → AppUser
  Future<AppUser> login(LoginRequestDTO request) async {
    final res = await _api.client.post(
      AppConfig.I.auth.login,
      data: request.toJson(),
    );

    final apiRes = ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (data) => AuthResponseDto.fromJson(data),
    );

    final dto = apiRes.data as AuthResponseDto;
    return AppUserMapper.fromUserDto(dto.user);
  }

  /// Đăng ký hành khách → AppUser
  Future<AppUser> registerPassenger(Map<String, dynamic> payload) async {
    final res = await _api.client.post(
      AppConfig.I.auth.registerPassenger,
      data: payload,
    );

    final apiRes = ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (data) => AuthResponseDto.fromJson(data),
    );

    final dto = apiRes.data as AuthResponseDto;
    return AppUserMapper.fromUserDto(dto.user);
  }

  /// Đăng ký tài xế → AppUser
  Future<AppUser> registerDriver(Map<String, dynamic> payload) async {
    final res = await _api.client.post(
      AppConfig.I.auth.registerDriver,
      data: payload,
    );

    final apiRes = ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (data) => AuthResponseDto.fromJson(data),
    );

    final dto = apiRes.data as AuthResponseDto;
    return AppUserMapper.fromDriverDto(dto.user.toDriverDTO());
  }

  /// TODO: Refresh token (backend cần cung cấp API này)
  Future<bool> refreshToken(String refreshToken) async {
    // final res = await _api.client.post(
    //   AppConfig.I.auth.refresh,
    //   data: {"refreshToken": refreshToken},
    // );
    // parse response -> save new tokens
    return false;
  }
}
