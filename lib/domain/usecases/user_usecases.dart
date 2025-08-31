import '../../data/models/auth/entities/user_entity.dart';
import '../../data/models/auth/entities/driver_entity.dart';
import '../../data/repositories/user/user_repository_interface.dart';
import '../../core/network/api_response.dart';

/// Use Cases cho User Management - Business Logic Layer
class UserUseCases {
  final UserRepositoryInterface _userRepository;
  final PassengerRepositoryInterface _passengerRepository;
  final DriverRepositoryInterface _driverRepository;
  final AdminRepositoryInterface _adminRepository;

  UserUseCases(
    this._userRepository,
    this._passengerRepository,
    this._driverRepository,
    this._adminRepository,
  );

  /// Cập nhật thông tin cá nhân với validation
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
    // Business validation
    final validationErrors = _validateProfileUpdate(
      phone: phone,
      fullName: fullName,
      licensePlate: licensePlate,
      brand: brand,
      model: model,
      color: color,
      numberOfSeats: numberOfSeats,
    );

    if (validationErrors.isNotEmpty) {
      return ApiResponse<void>(
        message: validationErrors.first,
        statusCode: 400,
        data: null,
        success: false,
      );
    }

    return await _userRepository.updateProfile(
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
  }

  /// Thay đổi mật khẩu với validation
  Future<ApiResponse<void>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Business validation
    final validationErrors = _validatePasswordChange(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (validationErrors.isNotEmpty) {
      return ApiResponse<void>(
        message: validationErrors.first,
        statusCode: 400,
        data: null,
        success: false,
      );
    }

    return await _userRepository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  /// Lấy thông tin hành khách
  Future<ApiResponse<UserEntity>> getPassengerProfile() async {
    return await _passengerRepository.getProfile();
  }

  /// Lấy thông tin tài xế
  Future<ApiResponse<DriverEntity>> getDriverProfile() async {
    return await _driverRepository.getProfile();
  }

  /// Admin: Lấy danh sách người dùng theo vai trò
  Future<ApiResponse<List<dynamic>>> getUsersByRole({
    String? role,
  }) async {
    return await _adminRepository.getUsersByRole(role: role);
  }

  /// Admin: Duyệt tài xế
  Future<ApiResponse<void>> approveDriver(int userId) async {
    // Business rule: Only admin can approve drivers
    return await _adminRepository.approveDriver(userId);
  }

  /// Admin: Từ chối tài xế với lý do
  Future<ApiResponse<bool>> rejectDriver({
    required int userId,
    required String rejectionReason,
  }) async {
    // Business validation
    if (rejectionReason.trim().isEmpty) {
      return ApiResponse<bool>(
        message: 'Lý do từ chối không được để trống',
        statusCode: 400,
        data: false,
        success: false,
      );
    }

    if (rejectionReason.length < 10) {
      return ApiResponse<bool>(
        message: 'Lý do từ chối phải có ít nhất 10 ký tự',
        statusCode: 400,
        data: false,
        success: false,
      );
    }

    return await _adminRepository.rejectDriver(userId, rejectionReason);
  }

  /// Admin: Xóa người dùng
  Future<ApiResponse<void>> deleteUser(int userId) async {
    // Business rule: Cannot delete admin users
    // This would typically check user role first
    return await _adminRepository.deleteUser(userId);
  }

  /// Validation cho việc cập nhật profile
  List<String> _validateProfileUpdate({
    required String phone,
    required String fullName,
    required String licensePlate,
    required String brand,
    required String model,
    required String color,
    required int numberOfSeats,
  }) {
    final errors = <String>[];

    // Phone validation
    final phoneRegex = RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$');
    if (!phoneRegex.hasMatch(phone)) {
      errors.add('Số điện thoại không hợp lệ (phải có 10 số và bắt đầu bằng 03, 05, 07, 08, 09)');
    }

    // Full name validation
    if (fullName.trim().isEmpty) {
      errors.add('Họ tên không được để trống');
    }

    if (fullName.trim().length < 2) {
      errors.add('Họ tên phải có ít nhất 2 ký tự');
    }

    // License plate validation
    final licensePlateRegex = RegExp(r'^[0-9]{2}[A-Z]{1,2}-[0-9]{4,6}$');
    if (!licensePlateRegex.hasMatch(licensePlate)) {
      errors.add('Biển số xe không hợp lệ (VD: 30A-12345)');
    }

    // Vehicle info validation
    if (brand.trim().isEmpty) {
      errors.add('Hãng xe không được để trống');
    }

    if (model.trim().isEmpty) {
      errors.add('Mẫu xe không được để trống');
    }

    if (color.trim().isEmpty) {
      errors.add('Màu xe không được để trống');
    }

    // Number of seats validation
    if (numberOfSeats < 1 || numberOfSeats > 16) {
      errors.add('Số ghế phải từ 1 đến 16');
    }

    return errors;
  }

  /// Validation cho việc thay đổi mật khẩu
  List<String> _validatePasswordChange({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    final errors = <String>[];

    if (oldPassword.trim().isEmpty) {
      errors.add('Mật khẩu cũ không được để trống');
    }

    if (newPassword.trim().isEmpty) {
      errors.add('Mật khẩu mới không được để trống');
    }

    if (newPassword.length < 6) {
      errors.add('Mật khẩu mới phải có ít nhất 6 ký tự');
    }

    if (newPassword == oldPassword) {
      errors.add('Mật khẩu mới phải khác mật khẩu cũ');
    }

    if (newPassword != confirmPassword) {
      errors.add('Xác nhận mật khẩu không khớp');
    }

    // Password strength validation
    if (!_isStrongPassword(newPassword)) {
      errors.add('Mật khẩu phải chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 số');
    }

    return errors;
  }

  /// Kiểm tra độ mạnh của mật khẩu
  bool _isStrongPassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    
    return hasUppercase && hasLowercase && hasDigits;
  }
}
