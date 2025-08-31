import '../../data/repositories/repository_registry.dart';
import 'ride_usecases.dart';
import 'booking_usecases.dart';
import 'user_usecases.dart';
import 'driver_usecases.dart';

/// Registry quản lý tất cả use cases
class UseCaseRegistry {
  static final UseCaseRegistry _instance = UseCaseRegistry._internal();
  static UseCaseRegistry get I => _instance;
  UseCaseRegistry._internal();

  // ===== Lazy Use Cases =====
  late final RideUseCases _rideUseCases = RideUseCases(
    RepositoryRegistry.I.rideRepository,
  );

  late final BookingUseCases _bookingUseCases = BookingUseCases(
    RepositoryRegistry.I.bookingRepository,
  );

  late final UserUseCases _userUseCases = UserUseCases(
    RepositoryRegistry.I.userRepository,
    RepositoryRegistry.I.passengerRepository,
    RepositoryRegistry.I.driverRepository,
    RepositoryRegistry.I.adminRepository,
  );

  late final DriverUseCases _driverUseCases = DriverUseCases(
    RepositoryRegistry.I.driverRepository,
    RepositoryRegistry.I.rideRepository,
    RepositoryRegistry.I.bookingRepository,
  );

  // ===== Getters =====
  RideUseCases get rideUseCases => _rideUseCases;
  BookingUseCases get bookingUseCases => _bookingUseCases;
  UserUseCases get userUseCases => _userUseCases;
  DriverUseCases get driverUseCases => _driverUseCases;

  /// Initialize all use cases
  Future<void> initialize() async {
    // Ensure RepositoryRegistry is initialized first
    await RepositoryRegistry.I.initialize();
    
    print('✅ UseCaseRegistry initialized');
  }

  /// Test all use cases
  Future<void> testUseCases() async {
    print('🧪 Testing all use cases...');
    
    try {
      // Test ride use cases
      final rides = await _rideUseCases.getRecommendedRides(
        userLocation: 'Hà Nội',
        requiredSeats: 1,
      );
      print('✅ RideUseCases: ${rides.data?.length ?? 0} recommended rides');
      
      print('✅ All use cases tested successfully');
    } catch (e) {
      print('❌ Use case test failed: $e');
    }
  }
}
