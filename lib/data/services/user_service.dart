import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/auth/api/user_dto.dart';
import 'package:sharexev2/data/models/auth/api/driver_dto.dart';
import 'package:sharexev2/config/app_config.dart';

class UserService {
  final ApiClient _api = ApiClient();

  /// Cập nhật profile user
  Future<ApiResponse<dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    final res = await _api.client.put(
      AppConfig.I.user.updateProfile,
      data: profileData,
    );
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) => data);
  }

  /// Đổi mật khẩu
  Future<ApiResponse<dynamic>> changePassword(String oldPassword, String newPassword) async {
    final res = await _api.client.put(
      AppConfig.I.user.changePassword,
      data: {
        'oldPass': oldPassword,
        'newPass': newPassword,
      },
    );
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) => data);
  }

  /// Lấy profile passenger
  Future<ApiResponse<UserDTO>> getPassengerProfile() async {
    final res = await _api.client.get(AppConfig.I.passenger.profile);
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) {
      return UserDTO.fromJson(data);
    });
  }

  /// Lấy profile driver
  Future<ApiResponse<DriverDTO>> getDriverProfile() async {
    final res = await _api.client.get(AppConfig.I.driver.profile);
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) {
      return DriverDTO.fromJson(data);
    });
  }

  /// Lấy danh sách rides của driver
  Future<ApiResponse<List<dynamic>>> getDriverRides() async {
    final res = await _api.client.get(AppConfig.I.driver.myRides);
    return ApiResponse.listFromJson<dynamic>(res.data as Map<String, dynamic>, (e) => e as dynamic);
  }

  /// Lấy tất cả rides
  Future<ApiResponse<List<Map<String, dynamic>>>> getAllRides() async {
    final res = await _api.client.get(AppConfig.I.rides.all);
    return ApiResponse.listFromJson<Map<String, dynamic>>(res.data as Map<String, dynamic>, (e) {
      return e as Map<String, dynamic>;
    });
  }
}
