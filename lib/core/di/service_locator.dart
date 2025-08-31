import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core services
import '../../core/network/api_client.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/booking_service.dart';
import '../../data/services/ride_service.dart';
import '../../data/services/user_service.dart';

// Repository interfaces
import '../../data/repositories/auth/auth_repository_interface.dart';
import '../../data/repositories/booking/booking_repository_interface.dart';
import '../../data/repositories/ride/ride_repository_interface.dart';
import '../../data/repositories/user/user_repository_interface.dart';
import '../../data/repositories/chat/chat_repository_interface.dart';
import '../../data/repositories/location/location_repository_interface.dart';

// Real implementations
import '../../data/repositories/auth/auth_repository_impl.dart';
import '../../data/repositories/booking/booking_repository_impl.dart';
import '../../data/repositories/ride/ride_repository_impl.dart';
import '../../data/repositories/user/user_repository_impl.dart';

// Mock implementations (for services not yet implemented)
import 'mock_implementations.dart';

// Auth manager
import '../auth/auth_manager.dart';

/// Service Locator using GetIt for Dependency Injection
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  /// Get instance of any registered service
  static T get<T extends Object>() => _getIt.get<T>();
  
  /// Check if a service is registered
  static bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();
  
  /// Setup all dependencies
  static Future<void> setup() async {
    // Register external dependencies first
    await _registerExternalDependencies();
    
    // Register core services
    _registerCoreServices();
    
    // Register repositories
    _registerRepositories();
    
    print('✅ Service Locator setup completed');
  }
  
  /// Register external dependencies (SharedPreferences, etc.)
  static Future<void> _registerExternalDependencies() async {
    // SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    _getIt.registerSingleton<SharedPreferences>(sharedPreferences);
    
    print('✅ External dependencies registered');
  }
  
  /// Register core services
  static void _registerCoreServices() {
    // API Client
    _getIt.registerLazySingleton<ApiClient>(() => ApiClient());

    // Auth Manager (singleton)
    _getIt.registerLazySingleton<AuthManager>(() => AuthManager());

    // Services
    _getIt.registerLazySingleton<AuthService>(
      () => AuthService(get<ApiClient>()),
    );

    _getIt.registerLazySingleton<BookingService>(
      () => BookingService(get<ApiClient>()),
    );

    _getIt.registerLazySingleton<RideService>(
      () => RideService(get<ApiClient>()),
    );

    _getIt.registerLazySingleton<UserService>(
      () => UserService(get<ApiClient>()),
    );

    print('✅ Core services registered');
  }
  
  /// Register repositories
  static void _registerRepositories() {
    // ✅ Using REAL implementations now

    // Auth Repository (Mock for now)
    _getIt.registerLazySingleton<AuthRepositoryInterface>(
      () => MockAuthRepository(),
    );

    // Booking Repository (Mock for now)
    _getIt.registerLazySingleton<BookingRepositoryInterface>(
      () => MockBookingRepository(),
    );

    // Ride Repository (Mock for now)
    _getIt.registerLazySingleton<RideRepositoryInterface>(
      () => MockRideRepository(),
    );

    // User Repository (Mock for now)
    _getIt.registerLazySingleton<UserRepositoryInterface>(
      () => MockUserRepository(),
    );

    // Chat Repository (Mock for now)
    _getIt.registerLazySingleton<ChatRepositoryInterface>(
      () => MockChatRepository(),
    );

    // Location Repository (Mock implementation)
    _getIt.registerLazySingleton<LocationRepositoryInterface>(
      () => MockLocationRepository(),
    );

    print('✅ Mock repositories registered');
  }
  
  /// Reset all dependencies (useful for testing)
  static Future<void> reset() async {
    await _getIt.reset();
    print('🔄 Service Locator reset');
  }
}
