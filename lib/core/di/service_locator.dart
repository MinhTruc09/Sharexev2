import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

// Core services
import '../../core/network/api_client.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/booking_service.dart';
import '../../data/services/ride_service.dart';
import '../../data/services/user_service.dart';
import '../../data/services/firebase_auth_service.dart' as firebase;
import '../../data/services/tracking_service.dart';
import '../../data/services/chat/chat_api_service.dart';

// Repository interfaces
import '../../data/repositories/auth/auth_repository_interface.dart';
import '../../data/repositories/booking/booking_repository_interface.dart';
import '../../data/repositories/ride/ride_repository_interface.dart';
import '../../data/repositories/user/user_repository_interface.dart';
import '../../data/repositories/chat/chat_repository_interface.dart';
import '../../data/repositories/location/location_repository_interface.dart';
import '../../data/repositories/tracking/tracking_repository_interface.dart';

// Real implementations
import '../../data/repositories/auth/auth_repository_impl.dart';
import '../../data/repositories/booking/booking_repository_impl.dart';
import '../../data/repositories/ride/ride_repository_impl.dart';
import '../../data/repositories/user/user_repository_impl.dart';
import '../../data/repositories/chat/chat_repository_impl.dart';
import '../../data/repositories/location/location_repository_impl.dart';
import '../../data/repositories/tracking/tracking_repository_impl.dart';

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

    // ignore: avoid_print
    print('✅ Service Locator setup completed');
  }

  /// Register external dependencies (SharedPreferences, etc.)
  static Future<void> _registerExternalDependencies() async {
    // SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    _getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    // ignore: avoid_print
    print('✅ External dependencies registered');
  }

  /// Register core services
  static void _registerCoreServices() {
    // Dio instance
    _getIt.registerLazySingleton<Dio>(() => Dio());

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

    // Firebase Auth Service
    _getIt.registerLazySingleton<firebase.FirebaseAuthService>(
      () => firebase.FirebaseAuthService(),
    );

    // Tracking Service
    _getIt.registerLazySingleton<TrackingService>(
      () => TrackingService(get<ApiClient>()),
    );

    // Chat API Service uses same Dio instance configured via ApiClient (baseUrl from Env)
    _getIt.registerLazySingleton<ChatApiService>(() {
      final apiClient = get<ApiClient>();
      // Reuse ApiClient's Dio to leverage interceptors and baseUrl
      return ChatApiService(apiClient.client);
    });

    // ignore: avoid_print
    print('✅ Core services registered');
  }

  /// Register repositories
  static void _registerRepositories() {
    // ✅ Using REAL implementations based on API documentation

    // Auth Repository - Real implementation
    _getIt.registerLazySingleton<AuthRepositoryInterface>(
      () => AuthRepositoryImpl(
        authApiService: get<AuthService>(),
        firebaseAuthService: get<firebase.FirebaseAuthService>(),
        prefs: get<SharedPreferences>(),
      ),
    );

    // Booking Repository - Real implementation
    _getIt.registerLazySingleton<BookingRepositoryInterface>(
      () => BookingRepositoryImpl(bookingService: get<BookingService>()),
    );

    // Ride Repository - Real implementation
    _getIt.registerLazySingleton<RideRepositoryInterface>(
      () => RideRepositoryImpl(get<RideService>()),
    );

    // User Repository - Real implementation
    _getIt.registerLazySingleton<UserRepositoryInterface>(
      () => UserRepositoryImpl(get<UserService>()),
    );

    // Chat Repository - Real implementation
    _getIt.registerLazySingleton<ChatRepositoryInterface>(
      () => ChatRepositoryImpl(chatApiService: get<ChatApiService>()),
    );

    // Location Repository - Real implementation
    _getIt.registerLazySingleton<LocationRepositoryInterface>(
      () => LocationRepositoryImpl(trackingService: get<TrackingService>()),
    );

    // Tracking Repository - Real implementation
    _getIt.registerLazySingleton<TrackingRepositoryInterface>(
      () => TrackingRepositoryImpl(get<TrackingService>()),
    );

    // ignore: avoid_print
    print('✅ Real repositories registered');
  }

  /// Reset all dependencies (useful for testing)
  static Future<void> reset() async {
    await _getIt.reset();
    // ignore: avoid_print
    print('🔄 Service Locator reset');
  }
}
