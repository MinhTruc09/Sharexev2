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
      final newRide = RideEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        driverName: state.driverProfile?.fullName ?? 'Tài xế',
        driverEmail: state.driverProfile?.email ?? 'driver@example.com',
        departure: departure,
        startLat: 21.0285, // Default Hanoi coordinates
        startLng: 105.8542,
        startAddress: departure,
        startWard: 'Phường',
        startDistrict: 'Quận',
        startProvince: 'Hà Nội',
        endLat: 21.0285,
        endLng: 105.8542,
        endAddress: destination,
        endWard: 'Phường đích',
        endDistrict: 'Quận đích',
        endProvince: 'Hà Nội',
        destination: destination,
        startTime: startTime,
        pricePerSeat: pricePerSeat,
        totalSeat: totalSeats,
        availableSeats: totalSeats,
        status: RideStatus.active,
      );

      // TODO: Use _rideUseCases.createRide(newRide) when implemented
      final updatedRides = [...state.myRides, newRide];

      emit(state.copyWith(
        status: HomeDriverStatus.ready,
        myRides: updatedRides,
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeDriverStatus.error, error: e.toString()));
    }
  }

  // Accept booking
  Future<void> acceptBooking(String bookingId) async {
    try {
      // TODO: Use _bookingUseCases.acceptBooking(bookingId) when implemented
      final updatedBookings = state.pendingBookings
          .where((booking) => booking.id.toString() != bookingId)
          .toList();

      emit(state.copyWith(pendingBookings: updatedBookings));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Reject booking
  Future<void> rejectBooking(String bookingId) async {
    try {
      // TODO: Use _bookingUseCases.rejectBooking(bookingId) when implemented
      final updatedBookings = state.pendingBookings
          .where((booking) => booking.id.toString() != bookingId)
          .toList();

      emit(state.copyWith(pendingBookings: updatedBookings));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // Complete ride
  Future<void> completeRide(String rideId) async {
    try {
      final updatedRides = state.myRides.map((ride) {
        if (ride.id.toString() == rideId) {
          return ride.copyWith(status: RideStatus.completed);
        }
        return ride;
      }).toList();

      emit(state.copyWith(
        myRides: updatedRides,
        totalEarnings: _calculateEarnings(updatedRides),
        completedTrips: _countCompletedTrips(updatedRides),
      ));
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

