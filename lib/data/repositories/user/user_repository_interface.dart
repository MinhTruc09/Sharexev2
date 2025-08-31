import '../../models/auth/entities/user_entity.dart';
import '../../models/auth/entities/driver_entity.dart';
import '../../../core/network/api_response.dart';

/// Interface cho User Repository
abstract class UserRepositoryInterface {
  /// Cập nhật thông tin cá nhân
  Future<ApiResponse<void>> updateProfile({
    required String phone,
    required String fullName,
    required String licensePlate,
    required String brand,
    required String model,
    required String color,
    required int numberOfSeats,
    String? vehicleImageUrl,
    String? licenseImageUrl,
    String? avatarImageUrl,
  });

  /// Thay đổi mật khẩu
  Future<ApiResponse<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

/// Interface cho Passenger Repository
abstract class PassengerRepositoryInterface {
  /// Lấy thông tin cá nhân hành khách
  Future<ApiResponse<UserEntity>> getProfile();
}

/// Interface cho Driver Repository
abstract class DriverRepositoryInterface {
  /// Lấy thông tin cá nhân tài xế
  Future<ApiResponse<DriverEntity>> getProfile();
}

/// Interface cho Admin Repository
abstract class AdminRepositoryInterface {
  /// Lấy danh sách người dùng theo vai trò
  Future<ApiResponse<List<dynamic>>> getUsersByRole({String? role});

  /// Lấy thông tin chi tiết của người dùng
  Future<ApiResponse<DriverEntity>> getUserDetail(int userId);

  /// Chấp nhận đăng ký tài xế
  Future<ApiResponse<void>> approveDriver(int userId);

  /// Từ chối đăng ký tài xế
  Future<ApiResponse<bool>> rejectDriver(int userId, String rejectionReason);

  /// Xóa người dùng
  Future<ApiResponse<void>> deleteUser(int userId);
}
