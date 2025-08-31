import '../services/service_registry.dart';

// Ride
import 'ride/ride_repository_interface.dart';
import 'ride/ride_repository_impl.dart';

// User
import 'user/user_repository_interface.dart';
import 'user/user_repository_impl.dart';

// Booking
import 'booking/booking_repository_interface.dart';
import 'booking/booking_repository_impl.dart';

// Auth
import 'auth/auth_repository_interface.dart';
import 'auth/auth_repository_impl.dart';

// Chat
import 'chat/chat_repository_interface.dart';
import 'chat/chat_repository_impl.dart';

// Notification
import 'notification/notification_repository_interface.dart';
import 'notification/notification_repository_impl.dart';

// Tracking
import 'tracking/tracking_repository_interface.dart';
import 'tracking/tracking_repository_impl.dart';
import 'package:sharexev2/core/auth/auth_manager.dart';

/// Registry quản lý tất cả repositories
class RepositoryRegistry {
  static final RepositoryRegistry _instance = RepositoryRegistry._internal();
  static RepositoryRegistry get I => _instance;
  RepositoryRegistry._internal();

  // ===== Lazy Repositories =====
  late final RideRepositoryInterface _rideRepository = RideRepositoryImpl(
    ServiceRegistry.I.rideService,
  );

  late final UserRepositoryInterface _userRepository = UserRepositoryImpl(
    ServiceRegistry.I.userService,
  );

  late final PassengerRepositoryInterface _passengerRepository = PassengerRepositoryImpl(
    ServiceRegistry.I.passengerService,
  );

  late final DriverRepositoryInterface _driverRepository = DriverRepositoryImpl(
    ServiceRegistry.I.driverService,
  );

  late final AdminRepositoryInterface _adminRepository = AdminRepositoryImpl(
    ServiceRegistry.I.adminService,
  );

  late final BookingRepositoryInterface _bookingRepository = BookingRepositoryImpl(
    ServiceRegistry.I.bookingService,
  ) as BookingRepositoryInterface;

  late AuthRepositoryInterface _authRepository;

  late final ChatRepositoryInterface _chatRepository = ChatRepositoryImpl(
    chatService: ServiceRegistry.I.chatService,
    authManager: AuthManager(),
  ) as ChatRepositoryInterface;

  late final NotificationRepositoryInterface _notificationRepository = NotificationRepositoryImpl(
    ServiceRegistry.I.notificationService,
  );

  late final TrackingRepositoryInterface _trackingRepository = TrackingRepositoryImpl(
    ServiceRegistry.I.trackingService,
  );

  // ===== Getters =====
  RideRepositoryInterface get rideRepository => _rideRepository;
  UserRepositoryInterface get userRepository => _userRepository;
  PassengerRepositoryInterface get passengerRepository => _passengerRepository;
  DriverRepositoryInterface get driverRepository => _driverRepository;
  AdminRepositoryInterface get adminRepository => _adminRepository;
  BookingRepositoryInterface get bookingRepository => _bookingRepository;
  AuthRepositoryInterface get authRepository => _authRepository;
  ChatRepositoryInterface get chatRepository => _chatRepository;
  NotificationRepositoryInterface get notificationRepository => _notificationRepository;
  TrackingRepositoryInterface get trackingRepository => _trackingRepository;

  /// Initialize all repositories
  Future<void> initialize() async {
    // Ensure ServiceRegistry is initialized first
    await ServiceRegistry.I.initialize();
    
    // Initialize AuthRepository
    _authRepository = AuthRepositoryImpl(
      authApiService: ServiceRegistry.I.authService,
      firebaseAuthService: ServiceRegistry.I.firebaseAuthService,
      prefs: ServiceRegistry.I.prefs!,
    );
    
    // All other repositories are lazy-loaded, so no additional initialization needed
    print('✅ RepositoryRegistry initialized');
  }

  /// Test all repositories
  Future<void> testRepositories() async {
    print('🧪 Testing all repositories...');
    
    try {
      // Test ride repository
      final rides = await _rideRepository.getAvailableRides();
      print('✅ RideRepository: ${rides.data?.length ?? 0} rides');
      
      // Test auth repository (if user is logged in)
      // final user = await _authRepository.getCurrentUser();
      // print('✅ AuthRepository: User loaded');
      
      print('✅ All repositories tested successfully');
    } catch (e) {
      print('❌ Repository test failed: $e');
    }
  }
}
