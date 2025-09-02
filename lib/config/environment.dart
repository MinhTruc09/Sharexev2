/// Environment configuration for different build environments
class Environment {
  static const String _currentEnvironment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Current environment
  static String get current => _currentEnvironment;

  /// Check if current environment is development
  static bool get isDevelopment => _currentEnvironment == 'development';

  /// Check if current environment is staging
  static bool get isStaging => _currentEnvironment == 'staging';

  /// Check if current environment is production
  static bool get isProduction => _currentEnvironment == 'production';

  /// API Base URL based on environment
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case 'production':
        return 'https://carpooling-j5xn.onrender.com';
      case 'staging':
        return 'https://carpooling-staging.onrender.com'; // TODO: Update when available
      case 'development':
      default:
        return 'https://carpooling-j5xn.onrender.com'; // Using production for now
    }
  }

  /// WebSocket URL based on environment
  static String get websocketUrl {
    switch (_currentEnvironment) {
      case 'production':
        return 'wss://carpooling-j5xn.onrender.com/ws';
      case 'staging':
        return 'wss://carpooling-staging.onrender.com/ws';
      case 'development':
      default:
        return 'wss://carpooling-j5xn.onrender.com/ws';
    }
  }

  /// App name based on environment
  static String get appName {
    switch (_currentEnvironment) {
      case 'production':
        return 'ShareXe';
      case 'staging':
        return 'ShareXe Staging';
      case 'development':
      default:
        return 'ShareXe Dev';
    }
  }

  /// Enable debug features
  static bool get enableDebugFeatures {
    return isDevelopment || isStaging;
  }

  /// Enable logging
  static bool get enableLogging {
    return isDevelopment || isStaging;
  }

  /// API timeout in seconds
  static int get apiTimeoutSeconds {
    switch (_currentEnvironment) {
      case 'production':
        return 30;
      case 'staging':
        return 45;
      case 'development':
      default:
        return 60;
    }
  }
}

/// Firebase configuration based on environment
class FirebaseEnvironment {
  /// Firebase project ID
  static String get projectId {
    switch (Environment.current) {
      case 'production':
        return 'sharexe-prod'; // TODO: Update with actual project ID
      case 'staging':
        return 'sharexe-staging'; // TODO: Update with actual project ID
      case 'development':
      default:
        return 'sharexe-dev'; // TODO: Update with actual project ID
    }
  }

  /// Firebase API key
  static String get apiKey {
    switch (Environment.current) {
      case 'production':
        return const String.fromEnvironment('FIREBASE_API_KEY_PROD');
      case 'staging':
        return const String.fromEnvironment('FIREBASE_API_KEY_STAGING');
      case 'development':
      default:
        return const String.fromEnvironment('FIREBASE_API_KEY_DEV');
    }
  }
}

