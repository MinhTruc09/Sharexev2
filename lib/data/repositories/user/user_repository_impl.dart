import 'user_repository_interface.dart';
import '../../models/auth/entities/user_entity.dart';
import '../../models/auth/entities/driver_entity.dart';
import '../../models/auth/entities/user_role.dart';
import '../../models/auth/mappers/entity_mapper.dart';
import '../../models/auth/dtos/user_update_request_dto.dart';
import '../../models/auth/dtos/change_pass_dto.dart';
import '../../services/user_service.dart';
import '../../services/passenger_service.dart';
import '../../services/driver_service.dart';
// import '../../services/admin_service.dart'; // Removed - service doesn't exist
import '../../../core/network/api_response.dart';

/// Implementation của User Repository
class UserRepositoryImpl implements UserRepositoryInterface {
  final UserService _userService;

  UserRepositoryImpl(this._userService);

  @override
  Future<ApiResponse<UserEntity>> getProfile() async {
    try {
      final response = await _userService.getProfile();
      
      if (response.success && response.data != null) {
        final userEntity = UserEntity(
          id: response.data!['id'],
          fullName: response.data!['fullName'] ?? response.data!['name'] ?? '',
          email: response.data!['email'] ?? '',
          phoneNumber: response.data!['phoneNumber'] ?? response.data!['phone'] ?? '',
          avatarUrl: response.data!['avatarUrl'],
          role: UserRole.values.firstWhere(
            (r) => r.name.toLowerCase() == (response.data!['role'] ?? 'passenger').toString().toLowerCase(),
            orElse: () => UserRole.passenger,
          ),
        );
        return ApiResponse.success(
          data: userEntity,
          message: response.message,
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error getting profile: $e',
      );
    }
  }

  @override
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
  }) async {
    try {
      final request = UserUpdateRequestDTO(
        phone: phone,
        fullName: fullName,
        licensePlate: licensePlate,
        brand: brand,
        model: model,
        color: color,
        numberOfSeats: numberOfSeats,
        vehicleImageUrl: vehicleImageUrl,
        licenseImageUrl: licenseImageUrl,
        avatarImageUrl: avatarImageUrl,
      );

      final response = await _userService.updateProfile(request);
      
      return ApiResponse<void>(
        message: response.message,
        statusCode: response.statusCode,
        data: null,
        success: response.success,
      );
    } catch (e) {
      return ApiResponse<void>(
        message: 'Lỗi cập nhật thông tin: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  @override
  Future<ApiResponse<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final request = ChangePassDTO(
        oldPass: oldPassword,
        newPass: newPassword,
      );

      final response = await _userService.changePassword(request);
      
      return ApiResponse<void>(
        message: response.message,
        statusCode: response.statusCode,
        data: null,
        success: response.success,
      );
    } catch (e) {
      return ApiResponse<void>(
        message: 'Lỗi thay đổi mật khẩu: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }
}

/// Implementation của Passenger Repository
class PassengerRepositoryImpl implements PassengerRepositoryInterface {
  final PassengerService _passengerService;

  PassengerRepositoryImpl(this._passengerService);

  @override
  Future<ApiResponse<UserEntity>> getProfile() async {
    try {
      final response = await _passengerService.getProfile();
      
      final entity = response.data != null 
          ? UserEntityMapper.fromDto(response.data!)
          : null;
      
      return ApiResponse<UserEntity>(
        message: response.message,
        statusCode: response.statusCode,
        data: entity,
        success: response.success,
      );
    } catch (e) {
      return ApiResponse<UserEntity>(
        message: 'Lỗi lấy thông tin hành khách: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }
}

/// Implementation của Driver Repository
class DriverRepositoryImpl implements DriverRepositoryInterface {
  final DriverService _driverService;

  DriverRepositoryImpl(this._driverService);

  @override
  Future<ApiResponse<DriverEntity>> getProfile() async {
    try {
      final response = await _driverService.getProfile();
      
      final entity = response.data != null 
          ? DriverEntityMapper.fromDto(response.data!)
          : null;
      
      return ApiResponse<DriverEntity>(
        message: response.message,
        statusCode: response.statusCode,
        data: entity,
        success: response.success,
      );
    } catch (e) {
      return ApiResponse<DriverEntity>(
        message: 'Lỗi lấy thông tin tài xế: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }
}

// Admin Repository implementation removed - AdminService doesn't exist
// This would need to be implemented when AdminService is created
