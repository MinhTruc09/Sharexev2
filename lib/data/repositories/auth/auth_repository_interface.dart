// Repository Interface: Auth Repository
// Định nghĩa contract cho auth data access

import '../../models/auth/app_user.dart';
import '../../models/auth/entities/auth_session.dart';
import '../../models/auth/entities/auth_credentials.dart';
import '../../models/auth/entities/auth_result.dart';
import '../../models/auth/entities/user_role.dart';

/// Abstract repository interface cho Auth operations
/// Định nghĩa contract mà tất cả auth repositories phải implement
abstract class AuthRepositoryInterface {
  // ===== Authentication Status =====

  /// Kiểm tra user có đang đăng nhập không
  Future<bool> isLoggedIn();

  /// Lấy current user nếu đã đăng nhập
  Future<User?> getCurrentUser();

  /// Lấy current auth session
  Future<AuthSession?> getCurrentSession();

  // ===== Login Operations =====

  /// Đăng nhập bằng email/password
  Future<AuthResult> loginWithCredentials(AuthCredentials credentials);

  /// Đăng nhập bằng Google
  Future<AuthResult> loginWithGoogle(String idToken, UserRole role);

  /// Refresh access token
  Future<AuthResult> refreshToken();

  // ===== Registration Operations =====

  /// Đăng ký passenger
  Future<AuthResult> registerPassenger(RegisterCredentials credentials);

  /// Đăng ký driver
  Future<AuthResult> registerDriver(RegisterCredentials credentials);

  // ===== Session Management =====

  /// Lưu auth session
  Future<void> saveSession(AuthSession session, User user);

  /// Xóa auth session (logout)
  Future<void> clearSession();

  /// Kiểm tra và refresh token nếu cần
  Future<bool> ensureValidSession();

  // ===== User Profile =====

  /// Cập nhật thông tin user
  Future<User> updateUserProfile(User user);

  /// Thay đổi mật khẩu
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Gửi email đặt lại mật khẩu (quên mật khẩu)
  Future<void> sendPasswordResetEmail(String email);

  // ===== Device Management =====

  /// Đăng ký device token cho push notifications
  Future<void> registerDeviceToken(String deviceToken);

  /// Hủy đăng ký device token
  Future<void> unregisterDeviceToken();
}
