import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart';
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';
import 'package:sharexev2/data/models/auth/entities/user_entity.dart';
import 'package:sharexev2/data/repositories/ride/ride_repository_interface.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/repositories/user/user_repository_interface.dart';
import 'package:sharexev2/core/network/api_response.dart';

part 'home_driver_state.dart';

class HomeDriverCubit extends Cubit<HomeDriverState> {
  // Repository Pattern - Clean Architecture
  final dynamic _rideRepository; // TODO: Type as RideRepositoryInterface when DI is ready
  final dynamic _bookingRepository; // TODO: Type as BookingRepositoryInterface when DI is ready
  final dynamic _userRepository; // TODO: Type as UserRepositoryInterface when DI is ready

  HomeDriverCubit({
    required dynamic rideRepository,
    required dynamic bookingRepository,
    required dynamic userRepository,
  }) : _rideRepository = rideRepository,
       _bookingRepository = bookingRepository,
       _userRepository = userRepository,
       super(const HomeDriverState());

  Future<void> init() async {
    emit(state.copyWith(status: HomeDriverStatus.loading));
    try {
      // Load driver data using Repository Pattern
      ApiResponse<UserEntity> driverProfile;
      ApiResponse<List<RideEntity>> myRides;
      ApiResponse<List<BookingEntity>> bookings;

      if (_userRepository != null) {
        driverProfile = await _userRepository.getProfile();
      } else {
        driverProfile = ApiResponse<UserEntity>(message: 'No user repository', statusCode: 404, data: null, success: false);
      }

      if (_rideRepository != null) {
        myRides = await _rideRepository.getAllRides(); // Driver's rides
      } else {
        myRides = ApiResponse<List<RideEntity>>(message: 'No ride repository', statusCode: 404, data: [], success: false);
      }

      if (_bookingRepository != null) {
        bookings = await _bookingRepository.getDriverBookings();
      } else {
        bookings = ApiResponse<List<BookingEntity>>(message: 'No booking repository', statusCode: 404, data: [], success: false);
      }

      emit(state.copyWith(
        status: HomeDriverStatus.ready,
        driverProfile: driverProfile.data,
        myRides: myRides.data ?? [],
        pendingBookings: bookings.data ?? [],
        totalEarnings: _calculateEarnings(myRides.data ?? []),
        completedTrips: _countCompletedTrips(myRides.data ?? []),
      ));
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
        // TODO: Create proper RideRequestDTO and use repository
        // final rideRequest = RideRequestDTO(...);
        // final response = await _rideRepository.createRide(rideRequest);
        
        emit(state.copyWith(
          status: HomeDriverStatus.error,
          error: 'Create ride API chưa được triển khai',
        ));
      } else {
        emit(state.copyWith(
          status: HomeDriverStatus.error,
          error: 'Ride repository không khả dụng',
        ));
      }
    } catch (e) {
      emit(state.copyWith(status: HomeDriverStatus.error, error: e.toString()));
    }
  }

  // Accept booking
  Future<void> acceptBooking(String bookingId) async {
    try {
      if (_bookingRepository != null) {
        final response = await _bookingRepository.acceptBooking(bookingId);
        if (response.success) {
          // Reload bookings after successful accept
          await init();
        } else {
          emit(state.copyWith(error: response.message ?? 'Không thể chấp nhận booking'));
        }
      } else {
        emit(state.copyWith(error: 'Booking repository không khả dụng'));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Reject booking
  Future<void> rejectBooking(String bookingId) async {
    try {
      if (_bookingRepository != null) {
        final response = await _bookingRepository.rejectBooking(bookingId);
        if (response.success) {
          // Reload bookings after successful reject
          await init();
        } else {
          emit(state.copyWith(error: response.message ?? 'Không thể từ chối booking'));
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
        // TODO: Implement complete ride through repository
        // final response = await _rideRepository.completeRide(rideId);
        emit(state.copyWith(error: 'Complete ride API chưa được triển khai'));
      } else {
        emit(state.copyWith(error: 'Ride repository không khả dụng'));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Helper methods
  double _calculateEarnings(List<RideEntity> rides) {
    return rides
        .where((ride) => ride.status == RideStatus.completed)
        .fold(0.0, (sum, ride) => sum + (ride.pricePerSeat * (ride.totalSeat - (ride.availableSeats ?? 0))));
  }

  int _countCompletedTrips(List<RideEntity> rides) {
    return rides.where((ride) => ride.status == RideStatus.completed).length;
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}

