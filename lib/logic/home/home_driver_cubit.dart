import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart'
    as ride_entity;
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';
import 'package:sharexev2/data/models/auth/entities/user_entity.dart';
import 'package:sharexev2/data/repositories/ride/ride_repository_interface.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/repositories/user/user_repository_interface.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/core/auth/auth_manager.dart';

part 'home_driver_state.dart';

class HomeDriverCubit extends Cubit<HomeDriverState> {
  // Repository Pattern - Clean Architecture
  final RideRepositoryInterface? _rideRepository;
  final BookingRepositoryInterface? _bookingRepository;
  final UserRepositoryInterface? _userRepository;

  HomeDriverCubit({
    required RideRepositoryInterface? rideRepository,
    required BookingRepositoryInterface? bookingRepository,
    required UserRepositoryInterface? userRepository,
  }) : _rideRepository = rideRepository,
       _bookingRepository = bookingRepository,
       _userRepository = userRepository,
       super(const HomeDriverState());

  Future<void> init() async {
    emit(state.copyWith(status: HomeDriverStatus.loading));
    try {
      // Load driver data using Repository Pattern
      ApiResponse<UserEntity> driverProfile;
      ApiResponse<List<ride_entity.RideEntity>> myRides;
      ApiResponse<List<BookingEntity>> bookings;

      if (_userRepository != null) {
        driverProfile = await _userRepository.getProfile();
      } else {
        driverProfile = ApiResponse<UserEntity>(
          message: 'No user repository',
          statusCode: 404,
          data: null,
          success: false,
        );
      }

      if (_rideRepository != null) {
        myRides = await _rideRepository.getAllRides(); // Driver's rides
      } else {
        myRides = ApiResponse<List<ride_entity.RideEntity>>(
          message: 'No ride repository',
          statusCode: 404,
          data: [],
          success: false,
        );
      }

      if (_bookingRepository != null) {
        bookings = await _bookingRepository.getDriverBookings();
      } else {
        bookings = ApiResponse<List<BookingEntity>>(
          message: 'No booking repository',
          statusCode: 404,
          data: [],
          success: false,
        );
      }

      emit(
        state.copyWith(
          status: HomeDriverStatus.ready,
          driverProfile: driverProfile.data,
          myRides: myRides.data ?? [],
          pendingBookings: bookings.data ?? [],
          totalEarnings: _calculateEarnings(myRides.data ?? []),
          completedTrips: _countCompletedTrips(myRides.data ?? []),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: HomeDriverStatus.error, error: e.toString()));
    }
  }

  // Create new ride
  Future<void> createRide({
    required String departure,
    required String destination,
    required DateTime startTime,
    required double pricePerSeat,
    required int totalSeats,
  }) async {
    emit(state.copyWith(status: HomeDriverStatus.loading));
    try {
      if (_rideRepository != null) {
        // Create proper RideEntity and use repository
        final rideEntity = ride_entity.RideEntity(
          id: DateTime.now().millisecondsSinceEpoch,
          departure: departure,
          destination: destination,
          startLat: 0.0, // Should be provided by caller
          startLng: 0.0, // Should be provided by caller
          endLat: 0.0, // Should be provided by caller
          endLng: 0.0, // Should be provided by caller
          startAddress: departure,
          endAddress: destination,
          startTime: startTime,
          pricePerSeat: pricePerSeat,
          totalSeat: totalSeats,
          availableSeats: totalSeats,
          driverName:
              AuthManager.instance.currentUser?.fullName ?? 'Current Driver',
          driverEmail:
              AuthManager.instance.currentUser?.email.value ??
              'driver@sharexe.com',
          status: ride_entity.RideStatus.active,
          startWard: '',
          startDistrict: '',
          startProvince: '',
          endWard: '',
          endDistrict: '',
          endProvince: '',
        );

        final response = await _rideRepository.createRide(rideEntity);

        if (response.success && response.data != null) {
          emit(
            state.copyWith(
              status: HomeDriverStatus.ready,
              activeTrips: [...state.activeTrips, response.data!],
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: HomeDriverStatus.error,
              error: response.message ?? 'Tạo chuyến đi thất bại',
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            status: HomeDriverStatus.error,
            error: 'Ride repository không khả dụng',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(status: HomeDriverStatus.error, error: e.toString()));
    }
  }

  // Accept booking
  Future<void> acceptBooking(int bookingId) async {
    try {
      if (_bookingRepository != null) {
        final response = await _bookingRepository.acceptBooking(bookingId);
        if (response.success) {
          // Refresh data after accepting booking
          await init();
        } else {
          emit(
            state.copyWith(
              status: HomeDriverStatus.error,
              error: response.message ?? 'Không thể chấp nhận booking',
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            status: HomeDriverStatus.error,
            error: 'Booking repository không khả dụng',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(status: HomeDriverStatus.error, error: e.toString()));
    }
  }

  // Load earnings data
  Future<void> loadEarnings() async {
    try {
      // Implement actual earnings calculation from rides
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final monthStart = DateTime(now.year, now.month, 1);

      // Calculate earnings for different periods
      double todayEarnings = 0.0;
      double weeklyEarnings = 0.0;
      double monthlyEarnings = 0.0;
      int todayRides = 0;
      int weeklyRides = 0;
      int monthlyRides = 0;
      int todayPassengers = 0;
      int weeklyPassengers = 0;
      int monthlyPassengers = 0;
      int todayDriveTime = 0;
      int weeklyDriveTime = 0;
      int monthlyDriveTime = 0;

      for (final ride in state.myRides) {
        if (ride.startTime.isAfter(today)) {
          todayEarnings += ride.pricePerSeat * ride.totalSeat;
          todayRides++;
          todayPassengers += (ride.totalSeat - (ride.availableSeats ?? 0));
          todayDriveTime += 60; // Assume 1 hour per ride
        }
        if (ride.startTime.isAfter(weekStart)) {
          weeklyEarnings += ride.pricePerSeat * ride.totalSeat;
          weeklyRides++;
          weeklyPassengers += (ride.totalSeat - (ride.availableSeats ?? 0));
          weeklyDriveTime += 60;
        }
        if (ride.startTime.isAfter(monthStart)) {
          monthlyEarnings += ride.pricePerSeat * ride.totalSeat;
          monthlyRides++;
          monthlyPassengers += (ride.totalSeat - (ride.availableSeats ?? 0));
          monthlyDriveTime += 60;
        }
      }

      emit(
        state.copyWith(
          todayEarnings: todayEarnings,
          weeklyEarnings: weeklyEarnings,
          monthlyEarnings: monthlyEarnings,
          todayRides: todayRides,
          weeklyRides: weeklyRides,
          monthlyRides: monthlyRides,
          todayPassengers: todayPassengers,
          weeklyPassengers: weeklyPassengers,
          monthlyPassengers: monthlyPassengers,
          todayDriveTime: todayDriveTime,
          weeklyDriveTime: weeklyDriveTime,
          monthlyDriveTime: monthlyDriveTime,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: HomeDriverStatus.error, error: e.toString()));
    }
  }

  // Load trips data
  Future<void> loadTrips() async {
    try {
      final allTrips = state.myRides;
      final activeTrips =
          allTrips
              .where((ride) => ride.status == ride_entity.RideStatus.active)
              .toList();
      final completedTrips =
          allTrips
              .where((ride) => ride.status == ride_entity.RideStatus.completed)
              .toList();
      final cancelledTrips =
          allTrips
              .where((ride) => ride.status == ride_entity.RideStatus.cancelled)
              .toList();
      final recentRides = allTrips.take(5).toList(); // Last 5 rides

      emit(
        state.copyWith(
          allTrips: allTrips,
          activeTrips: activeTrips,
          completedTripsList: completedTrips,
          cancelledTrips: cancelledTrips,
          recentRides: recentRides,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: HomeDriverStatus.error, error: e.toString()));
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await init();
    await loadEarnings();
    await loadTrips();
  }

  // Refresh earnings
  Future<void> refreshEarnings() async {
    await loadEarnings();
  }

  // Refresh trips
  Future<void> refreshTrips() async {
    await loadTrips();
  }

  // Reject booking
  Future<void> rejectBooking(int bookingId) async {
    try {
      if (_bookingRepository != null) {
        final response = await _bookingRepository.rejectBooking(bookingId);
        if (response.success) {
          // Reload bookings after successful reject
          await init();
        } else {
          emit(
            state.copyWith(
              error: response.message ?? 'Không thể từ chối booking',
            ),
          );
        }
      } else {
        emit(state.copyWith(error: 'Booking repository không khả dụng'));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Complete ride
  Future<void> completeRide(String rideId) async {
    try {
      if (_rideRepository != null) {
        // Implement complete ride through repository
        if (_bookingRepository != null) {
          final response = await _bookingRepository.completeRide(
            int.parse(rideId),
          );
          if (response.success) {
            // Refresh rides after completion
            await init();
            emit(state.copyWith(status: HomeDriverStatus.ready));
          } else {
            emit(
              state.copyWith(
                error: response.message ?? 'Hoàn thành chuyến đi thất bại',
              ),
            );
          }
        } else {
          emit(state.copyWith(error: 'Booking repository không khả dụng'));
        }
      } else {
        emit(state.copyWith(error: 'Ride repository không khả dụng'));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Helper methods
  double _calculateEarnings(List<ride_entity.RideEntity> rides) {
    return rides
        .where((ride) => ride.status == ride_entity.RideStatus.completed)
        .fold(
          0.0,
          (sum, ride) =>
              sum +
              (ride.pricePerSeat *
                  (ride.totalSeat - (ride.availableSeats ?? 0))),
        );
  }

  int _countCompletedTrips(List<ride_entity.RideEntity> rides) {
    return rides
        .where((ride) => ride.status == ride_entity.RideStatus.completed)
        .length;
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
