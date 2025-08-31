import '../data/services/service_registry.dart';
import '../data/repositories/repository_registry.dart';
import '../domain/usecases/usecase_registry.dart';

/// Main App Registry - Quản lý toàn bộ dependency injection
class AppRegistry {
  static final AppRegistry _instance = AppRegistry._internal();
  static AppRegistry get I => _instance;
  AppRegistry._internal();

  bool _isInitialized = false;

  // ===== Registries =====
  ServiceRegistry get services => ServiceRegistry.I;
  RepositoryRegistry get repositories => RepositoryRegistry.I;
  UseCaseRegistry get useCases => UseCaseRegistry.I;

  /// Initialize toàn bộ ứng dụng
  Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ AppRegistry already initialized');
      return;
    }

    print('🚀 Initializing AppRegistry...');

    try {
      // 1. Initialize Services (API, Network, etc.)
      await services.initialize();
      
      // 2. Initialize Repositories (Data layer)
      await repositories.initialize();
      
      // 3. Initialize Use Cases (Business logic)
      await useCases.initialize();

      _isInitialized = true;
      print('✅ AppRegistry initialized successfully');
      
    } catch (e) {
      print('❌ AppRegistry initialization failed: $e');
      rethrow;
    }
  }

  /// Test toàn bộ hệ thống
  Future<void> runSystemTests() async {
    if (!_isInitialized) {
      throw Exception('AppRegistry not initialized. Call initialize() first.');
    }

    print('🧪 Running system tests...');

    try {
      // Test repositories
      await repositories.testRepositories();

      // Test use cases
      await useCases.testUseCases();

      print('✅ All system tests passed');

    } catch (e) {
      print('❌ System tests failed: $e');
      rethrow;
    }
  }

  /// Get system status
  Map<String, dynamic> getSystemStatus() {
    return {
      'initialized': _isInitialized,
      'services': {
        'apiClient': 'available',
        'authService': 'available',
        'rideService': 'available',
        'driverService': 'available',
        'passengerService': 'available',
        'userService': 'available',
        'adminService': 'available',
        'bookingService': 'available',
        'chatService': 'available',
        'notificationService': 'available',
        'trackingService': 'available',
      },
      'repositories': {
        'rideRepository': 'available',
        'userRepository': 'available',
        'bookingRepository': 'available',
        'authRepository': 'available',
        'chatRepository': 'available',
        'notificationRepository': 'available',
        'trackingRepository': 'available',
      },
      'useCases': {
        'rideUseCases': 'available',
        'bookingUseCases': 'available',
        'userUseCases': 'available',
      },
    };
  }

  /// Reset toàn bộ hệ thống (for testing)
  void reset() {
    _isInitialized = false;
    print('🔄 AppRegistry reset');
  }
}

/// Extension để dễ dàng access từ UI
extension AppRegistryExtension on AppRegistry {
  // Quick access to commonly used use cases
  get rideUseCases => useCases.rideUseCases;
  get bookingUseCases => useCases.bookingUseCases;
  get userUseCases => useCases.userUseCases;
  get driverUseCases => useCases.driverUseCases;

  // Quick access to commonly used repositories
  get rideRepository => repositories.rideRepository;
  get userRepository => repositories.userRepository;
  get bookingRepository => repositories.bookingRepository;
  get authRepository => repositories.authRepository;
  get driverRepository => repositories.driverRepository;
}
