import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/auth/dtos/driver_dto.dart';
import 'package:sharexev2/config/app_config.dart';

class AdminService {
  final ApiClient _api;

  AdminService(this._api);

  /// Lấy danh sách người dùng theo vai trò
  /// GET /api/admin/user/role
  Future<ApiResponse<List<dynamic>>> getUsersByRole({String? role}) async {
    final queryParams = <String, dynamic>{};
    if (role != null) queryParams['role'] = role;

    final res = await _api.client.get(
      AppConfig.I.admin.usersByRole,
      queryParameters: queryParams,
    );
    return ApiResponse.listFromJson<dynamic>(
      res.data as Map<String, dynamic>,
      (json) => json,
    );
  }

  /// Lấy thông tin chi tiết của người dùng
  /// GET /api/admin/user/{id}
  Future<ApiResponse<DriverDto>> getUserDetail(int userId) async {
    final res = await _api.client.get(
      "${AppConfig.I.admin.userDetail}$userId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => DriverDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Chấp nhận đăng ký tài xế
  /// POST /api/admin/user/approved/{id}
  Future<ApiResponse<dynamic>> approveDriver(int userId) async {
    final res = await _api.client.post(
      "${AppConfig.I.admin.approveUser}$userId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => json,
    );
  }

  /// Từ chối đăng ký tài xế
  /// POST /api/admin/user/reject/{id}
  Future<ApiResponse<bool>> rejectDriver(
    int userId,
    String rejectionReason,
  ) async {
    final res = await _api.client.post(
      "${AppConfig.I.admin.rejectUser}$userId",
      queryParameters: {'rejectionReason': rejectionReason},
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => json as bool,
    );
  }

  /// Xóa người dùng
  /// DELETE /api/admin/user/delete/{id}
  Future<ApiResponse<dynamic>> deleteUser(int userId) async {
    final res = await _api.client.delete(
      "${AppConfig.I.admin.deleteUser}$userId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => json,
    );
  }
}
