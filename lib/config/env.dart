
/// 🌍 Environment Config
///
/// - Quản lý API baseUrl (default, fallback, runtime)
/// - Config Firebase, Cloudinary, FCM
/// - WebSocket URL
class Env {
  static final Env _instance = Env._internal();
  factory Env() => _instance;
  Env._internal();

  // ===== Runtime config =====
  String? _runtimeBaseUrl;
  bool isUsingFallback = false;

  // ===== API base URL =====
  static const String _defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://carpooling-j5xn.onrender.com',
  );

  static const String fallbackApiUrl = 'https://sharexe-api.onrender.com';

  /// Lấy base URL (ưu tiên runtime -> default -> fallback)
  String get apiBaseUrl {
    if (_runtimeBaseUrl != null) return _runtimeBaseUrl!;
    return isUsingFallback ? fallbackApiUrl : _defaultApiBaseUrl;
  }

  /// Base path
  String apiBasePath = '/api';

  /// Full API URL (baseUrl + /api)
  String get fullApiUrl => '$apiBaseUrl$apiBasePath';

  /// WebSocket URL
  String get webSocketUrl {
    String baseUrl = apiBaseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    String wsUrl;
    if (baseUrl.startsWith('https://')) {
      wsUrl = baseUrl.replaceFirst('https://', 'wss://');
    } else if (baseUrl.startsWith('http://')) {
      wsUrl = baseUrl.replaceFirst('http://', 'ws://');
    } else {
      wsUrl = 'wss://$baseUrl';
    }

    return baseUrl.contains('onrender') ? '$wsUrl/ws/websocket' : '$wsUrl/ws';
  }

  /// API Version
  static const String apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  // ===== Firebase config =====
  static const bool enableFirebase = bool.fromEnvironment(
    'ENABLE_FIREBASE',
    defaultValue: true,
  );

  // ===== Cloudinary config =====
  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '',
  );

  static const String cloudinaryApiKey = String.fromEnvironment(
    'CLOUDINARY_API_KEY',
    defaultValue: '',
  );

  static const String cloudinaryApiSecret = String.fromEnvironment(
    'CLOUDINARY_API_SECRET',
    defaultValue: '',
  );

  // ===== FCM config =====
  static const String fcmServerKey = String.fromEnvironment(
    'FCM_SERVER_KEY',
    defaultValue: '',
  );

  // ===== Update baseUrl runtime =====
  void updateBaseUrl(String url) {
    _runtimeBaseUrl = url;
    isUsingFallback = false;
  }

  void resetToDefault() {
    _runtimeBaseUrl = null;
    isUsingFallback = false;
  }
}
