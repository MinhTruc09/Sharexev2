import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class MockAuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';
  static const String _expiresAtKey = 'expires_at';
  static const String _roleKey = 'role';

  // Mock users database
  static final Map<String, Map<String, dynamic>> _mockUsers = {
    'passenger@test.com': {
      'password': '2540#CN22',
      'user': {
        'id': 'user_passenger_1',
        'email': 'passenger@test.com',
        'name': 'Nguyễn Văn A',
        'role': 'PASSENGER',
        'photo_url': null,
        'created_at':
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'last_login_at': null,
      },
    },
    'driver@test.com': {
      'password': '2540#CN22',
      'user': {
        'id': 'user_driver_1',
        'email': 'driver@test.com',
        'name': 'Trần Văn B',
        'role': 'DRIVER',
        'photo_url': null,
        'created_at':
            DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'last_login_at': null,
        'approval_status': 'approved', // approved, pending, rejected
      },
    },
    'driver.pending@test.com': {
      'password': '2540#CN22',
      'user': {
        'id': 'user_driver_2',
        'email': 'driver.pending@test.com',
        'name': 'Lê Văn C',
        'role': 'DRIVER',
        'photo_url': null,
        'created_at':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'last_login_at': null,
        'approval_status': 'pending',
      },
    },
    'driver.rejected@test.com': {
      'password': '2540#CN22',
      'user': {
        'id': 'user_driver_3',
        'email': 'driver.rejected@test.com',
        'name': 'Phạm Văn D',
        'role': 'DRIVER',
        'photo_url': null,
        'created_at':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'last_login_at': null,
        'approval_status': 'rejected',
      },
    },
  };

  // Kiểm tra đăng nhập
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    return accessToken != null;
  }

  // Lấy role hiện tại
  Future<String?> getCurrentUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // Lưu role
  Future<void> setCurrentUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  // Lấy access token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Đăng nhập bằng email/password
  Future<AuthResponse> loginWithEmail(
    String email,
    String password,
    String role, {
    Map<String, dynamic>? additionalData,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final mockUser = _mockUsers[email.toLowerCase()];

    if (mockUser == null) {
      throw Exception('Email không tồn tại');
    }

    if (mockUser['password'] != password) {
      throw Exception('Mật khẩu không đúng');
    }

    final userData = mockUser['user'] as Map<String, dynamic>;
    if (userData['role'] != role) {
      throw Exception('Role không khớp với tài khoản');
    }

    // Check driver approval status
    if (role == 'DRIVER') {
      final approvalStatus = userData['approval_status'] as String?;
      if (approvalStatus == 'pending') {
        throw Exception(
          'Tài khoản đang chờ admin xét duyệt. Vui lòng chờ thông báo qua email.',
        );
      } else if (approvalStatus == 'rejected') {
        throw Exception(
          'Tài khoản đã bị từ chối. Vui lòng liên hệ admin để biết thêm chi tiết.',
        );
      }
    }

    final user = User.fromJson(userData);
    final authResponse = AuthResponse(
      accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      user: user,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );

    // Lưu thông tin vào local storage
    await _saveAuthData(authResponse);

    return authResponse;
  }

  // Đăng nhập bằng Google (mock)
  Future<AuthResponse> loginWithGoogle(String role) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 2000));

    // Mock Google user
    final user = User(
      id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'google.user@gmail.com',
      name: 'Google User',
      role: role,
      photoUrl: 'https://via.placeholder.com/150',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    final authResponse = AuthResponse(
      accessToken:
          'mock_google_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_google_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      user: user,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );

    await _saveAuthData(authResponse);

    return authResponse;
  }

  // Refresh token (mock)
  Future<void> refreshToken() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null) throw Exception('Không có user data');

    // Generate new tokens
    await prefs.setString(
      _accessTokenKey,
      'mock_refreshed_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    await prefs.setString(
      _expiresAtKey,
      DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    );
  }

  // Đăng ký (mock)
  Future<AuthResponse> register(
    String email,
    String password,
    String name,
    String role, {
    Map<String, dynamic>? additionalData,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 2000));

    if (_mockUsers.containsKey(email.toLowerCase())) {
      throw Exception('Email đã tồn tại');
    }

    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: role,
      photoUrl: null,
      createdAt: DateTime.now(),
      lastLoginAt: null,
    );

    // Add to mock database
    _mockUsers[email.toLowerCase()] = {
      'password': password,
      'user': user.toJson(),
    };

    final authResponse = AuthResponse(
      accessToken:
          'mock_register_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock_register_refresh_${DateTime.now().millisecondsSinceEpoch}',
      user: user,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );

    await _saveAuthData(authResponse);

    return authResponse;
  }

  // Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_expiresAtKey);
    await prefs.remove(_roleKey);
  }

  // Lưu auth data vào local storage
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, authResponse.accessToken);
    await prefs.setString(_refreshTokenKey, authResponse.refreshToken);
    await prefs.setString(_userKey, authResponse.user.toJson().toString());
    await prefs.setString(
      _expiresAtKey,
      authResponse.expiresAt.toIso8601String(),
    );
    await prefs.setString(_roleKey, authResponse.user.role);
  }

  // Lấy thông tin user hiện tại
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson == null) return null;

      // Parse JSON string thành Map
      final userMap = Map<String, dynamic>.from(
        userJson as Map<String, dynamic>,
      );
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }
}
