import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:sharexev2/config/env.dart';

import '../auth/auth_manager.dart';
// <-- dùng Env

class ApiDebugHelper {
  static final ApiDebugHelper _instance = ApiDebugHelper._internal();
  factory ApiDebugHelper() => _instance;
  ApiDebugHelper._internal();

  final Env _env = Env();
  final AuthManager _authManager = AuthManager();

  // Endpoints theo nhóm
  final List<Map<String, dynamic>> debugEndpoints = [
    {
      'name': 'Driver Rides',
      'endpoint': '/driver/my-rides',
      'description': 'Lấy danh sách chuyến đi của tài xế',
      'requireAuth': true,
    },
    {
      'name': 'Driver Bookings',
      'endpoint': '/driver/bookings',
      'description': 'Lấy danh sách booking của tài xế',
      'requireAuth': true,
    },
    {
      'name': 'Driver Profile',
      'endpoint': '/driver/profile',
      'description': 'Lấy thông tin hồ sơ tài xế',
      'requireAuth': true,
    },
    {
      'name': 'Available Rides',
      'endpoint': '/ride/available',
      'description': 'Lấy danh sách chuyến đi sẵn có',
      'requireAuth': false,
    },
    {
      'name': 'Health Check',
      'endpoint': '/health',
      'description': 'Kiểm tra kết nối API',
      'requireAuth': false,
    },
  ];

  /// Test kết nối đến API
  Future<bool> testApiConnection() async {
    developer.log(
      'Kiểm tra kết nối đến API: ${_env.fullApiUrl}',
      name: 'api_debug',
    );

    try {
      final response = await http
          .get(Uri.parse('${_env.fullApiUrl}/health'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) return true;
      return !(response.statusCode == 502 || response.statusCode == 504);
    } catch (e) {
      developer.log(
        'Lỗi khi kiểm tra kết nối: $e',
        name: 'api_debug',
        error: e,
      );
      return false;
    }
  }

  /// Test một endpoint cụ thể
  Future<Map<String, dynamic>> testEndpoint(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    final url = Uri.parse('${_env.fullApiUrl}$endpoint');
    developer.log('Kiểm tra endpoint: $url', name: 'api_debug');

    try {
      final headers = {'Content-Type': 'application/json'};
      if (requireAuth) {
        final token = _authManager.getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'body': response.body,
        'endpoint': endpoint,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 0,
        'body': e.toString(),
        'endpoint': endpoint,
      };
    }
  }

  /// Cập nhật URL API runtime
  void updateApiUrl(String url) {
    _env.updateBaseUrl(url);
  }

  /// Reset về mặc định
  void resetApiUrl() {
    _env.resetToDefault();
  }
}
