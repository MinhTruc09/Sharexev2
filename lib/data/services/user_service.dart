import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/auth/dtos/user_update_request_dto.dart';
import 'package:sharexev2/data/models/auth/dtos/change_pass_dto.dart';
import 'package:sharexev2/config/app_config.dart';

class UserService {
  final ApiClient _api;

  UserService(this._api);

  /// Cập nhật thông tin cá nhân
  /// PUT /api/user/update-profile
  Future<ApiResponse<dynamic>> updateProfile(
    UserUpdateRequestDTO request,
  ) async {
    final res = await _api.client.put(
      AppConfig.I.user.updateProfile,
      data: {
        'userUpdateRequestDTO': request.toJson(),
      },
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => json,
    );
  }

  /// Thay đổi mật khẩu
  /// PUT /api/user/change-pass
  Future<ApiResponse<dynamic>> changePassword(ChangePassDTO request) async {
    final res = await _api.client.put(
      AppConfig.I.user.changePassword,
      data: request.toJson(),
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => json,
    );
  }
}
