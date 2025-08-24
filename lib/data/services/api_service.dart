import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sharexev2/data/models/auth_models.dart';
import 'package:sharexev2/config/env.dart';

class ApiService {
  static const String baseUrl = Env.apiBaseUrl;
  static const String apiVersion = Env.apiVersion;
  
  // Headers cho API calls
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _authHeaders(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };

  // Đăng nhập bằng email/password
  Future<AuthResponse> login(
    LoginRequest request, 
    String role, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$apiVersion/auth/login'),
        headers: _headers,
        body: jsonEncode({
          ...request.toJson(),
          'role': role,
          if (additionalData != null) ...additionalData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Đăng nhập bằng Google
  Future<AuthResponse> loginWithGoogle(LoginRequest request, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$apiVersion/auth/google'),
        headers: _headers,
        body: jsonEncode({
          ...request.toJson(),
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đăng nhập Google thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Đăng ký
  Future<AuthResponse> register(
    String email, 
    String password, 
    String name, 
    String role, 
    String? firebaseToken, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$apiVersion/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          if (firebaseToken != null) 'firebase_token': firebaseToken,
          if (additionalData != null) ...additionalData,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Refresh token
  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$apiVersion/auth/refresh'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Refresh token thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Lấy thông tin user (cần token)
  Future<User> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$apiVersion/user/profile'),
        headers: _authHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Lấy thông tin thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Cập nhật thông tin user
  Future<User> updateProfile(String token, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$apiVersion/user/profile'),
        headers: _authHeaders(token),
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return User.fromJson(responseData);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Cập nhật thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Đăng xuất (revoke token)
  Future<void> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$apiVersion/auth/logout'),
        headers: _authHeaders(token),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đăng xuất thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}
