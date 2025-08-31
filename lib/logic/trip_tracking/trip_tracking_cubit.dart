import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/repositories/location/location_repository_interface.dart';
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';

part 'trip_tracking_state.dart';

class TripTrackingCubit extends Cubit<TripTrackingState> {
  final dynamic _bookingRepository; // TODO: Type as BookingRepositoryInterface when DI is ready
  final dynamic _locationRepository; // TODO: Type as LocationRepositoryInterface when DI is ready
  
  StreamSubscription<LocationData>? _driverLocationSubscription;
  Timer? _etaUpdateTimer;

  TripTrackingCubit({
    required dynamic bookingRepository,
    required dynamic locationRepository,
  }) : _bookingRepository = bookingRepository,
       _locationRepository = locationRepository,
       super(const TripTrackingState());

  // ===== Trip Lifecycle Management =====

  /// Start tracking a trip
  Future<void> startTripTracking(int bookingId) async {
    emit(state.copyWith(status: TripTrackingStatus.loading));

    try {
      if (_bookingRepository != null) {
        final response = await _bookingRepository.getBookingDetail(bookingId);
        
        if (response.success && response.data != null) {
          final booking = response.data!;
          
          emit(state.copyWith(
            status: TripTrackingStatus.tracking,
            currentBooking: booking,
            tripPhase: _getTripPhaseFromBooking(booking),
            error: null,
          ));

          // Start real-time tracking
          _startDriverLocationTracking();
          _startETAUpdates();
        } else {
          emit(state.copyWith(
            status: TripTrackingStatus.error,
            error: response.message ?? 'Failed to load booking',
          ));
        }
      } else {
        // Mock trip tracking
        _startMockTripTracking(bookingId);
      }
    } catch (e) {
      emit(state.copyWith(
        status: TripTrackingStatus.error,
        error: 'Trip tracking error: $e',
      ));
    }
  }

  /// Driver confirms pickup
  Future<void> confirmPickup() async {
    if (state.currentBooking == null) return;

    emit(state.copyWith(status: TripTrackingStatus.loading));

    try {
      if (_bookingRepository != null) {
        final response = await _bookingRepository.passengerConfirmRide(
          state.currentBooking!.rideId,
        );
        
        if (response.success) {
          emit(state.copyWith(
            status: TripTrackingStatus.tracking,
            tripPhase: TripPhase.inProgress,
            pickupTime: DateTime.now(),
          ));
        } else {
          emit(state.copyWith(
            status: TripTrackingStatus.error,
            error: response.message ?? 'Failed to confirm pickup',
          ));
        }
      } else {
        // Mock confirm pickup
        emit(state.copyWith(
          status: TripTrackingStatus.tracking,
          tripPhase: TripPhase.inProgress,
          pickupTime: DateTime.now(),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TripTrackingStatus.error,
        error: 'Pickup confirmation error: $e',
      ));
    }
  }

  /// Complete trip
  Future<void> completeTrip() async {
    if (state.currentBooking == null) return;

    emit(state.copyWith(status: TripTrackingStatus.loading));

    try {
      if (_bookingRepository != null) {
        final response = await _bookingRepository.completeRide(
          state.currentBooking!.rideId,
        );
        
        if (response.success) {
          emit(state.copyWith(
            status: TripTrackingStatus.completed,
            tripPhase: TripPhase.completed,
            completionTime: DateTime.now(),
          ));
          
          _stopAllTracking();
        } else {
          emit(state.copyWith(
            status: TripTrackingStatus.error,
            error: response.message ?? 'Failed to complete trip',
          ));
        }
      } else {
        // Mock complete trip
        emit(state.copyWith(
          status: TripTrackingStatus.completed,
          tripPhase: TripPhase.completed,
          completionTime: DateTime.now(),
        ));
        
        _stopAllTracking();
      }
    } catch (e) {
      emit(state.copyWith(
        status: TripTrackingStatus.error,
        error: 'Trip completion error: $e',
      ));
    }
  }

  /// Cancel trip
  Future<void> cancelTrip(String reason) async {
    if (state.currentBooking == null) return;

    emit(state.copyWith(status: TripTrackingStatus.loading));

    try {
      if (_bookingRepository != null) {
        final response = await _bookingRepository.cancelBooking(
          state.currentBooking!.rideId,
        );
        
        if (response.success) {
          emit(state.copyWith(
            status: TripTrackingStatus.cancelled,
            tripPhase: TripPhase.cancelled,
            cancellationReason: reason,
          ));
          
          _stopAllTracking();
        } else {
          emit(state.copyWith(
            status: TripTrackingStatus.error,
            error: response.message ?? 'Failed to cancel trip',
          ));
        }
      } else {
        // Mock cancel trip
        emit(state.copyWith(
          status: TripTrackingStatus.cancelled,
          tripPhase: TripPhase.cancelled,
          cancellationReason: reason,
        ));
        
        _stopAllTracking();
      }
    } catch (e) {
      emit(state.copyWith(
        status: TripTrackingStatus.error,
        error: 'Trip cancellation error: $e',
      ));
    }
  }

  // ===== Real-time Tracking =====

  void _startDriverLocationTracking() {
    if (_locationRepository != null) {
      _driverLocationSubscription = _locationRepository
          .startLocationTracking()
          .listen(
        (location) {
          emit(state.copyWith(
            driverLocation: location,
            lastLocationUpdate: DateTime.now(),
          ));
          
          _updateETA();
        },
        onError: (error) {
          emit(state.copyWith(
            error: 'Driver tracking error: $error',
          ));
        },
      );
    }
  }

  void _startETAUpdates() {
    _etaUpdateTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateETA(),
    );
  }

  void _updateETA() {
    if (state.driverLocation != null && state.currentBooking != null) {
      // Calculate ETA based on current location and destination
      final estimatedMinutes = _calculateETA(
        state.driverLocation!,
        state.currentBooking!,
      );
      
      emit(state.copyWith(estimatedArrivalMinutes: estimatedMinutes));
    }
  }

  int _calculateETA(LocationData driverLocation, BookingEntity booking) {
    // Mock ETA calculation - in real app, use routing service
    final distance = _calculateDistance(
      driverLocation.latitude,
      driverLocation.longitude,
      21.0285, // Mock destination lat
      105.8542, // Mock destination lng
    );
    
    // Assume average speed of 30 km/h in city
    return (distance / 30 * 60).round();
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    // Simple distance calculation - in real app, use proper geo library
    final deltaLat = lat2 - lat1;
    final deltaLng = lng2 - lng1;
    return (deltaLat * deltaLat + deltaLng * deltaLng) * 111; // Rough km conversion
  }

  void _startMockTripTracking(int bookingId) {
    // Mock booking for testing
    final mockBooking = BookingEntity(
      id: bookingId,
      rideId: 1,
      seatsBooked: 1,
      status: BookingStatus.accepted,
      createdAt: DateTime.now(),
      totalPrice: 85000,
      departure: 'Hà Nội',
      destination: 'Sân bay Nội Bài',
      startTime: DateTime.now().add(const Duration(minutes: 10)),
      pricePerSeat: 85000,
      rideStatus: 'active',
      totalSeats: 4,
      availableSeats: 3,
      driverId: 1,
      driverName: 'Nguyễn Văn A',
      driverPhone: '0901234567',
      driverEmail: 'driver@example.com',
      driverAvatarUrl: null,
      driverStatus: 'active',
      vehicle: null,
      passengerId: 1,
      passengerName: 'Nguyễn Văn B',
      passengerPhone: '0987654321',
      passengerEmail: 'passenger@example.com',
      passengerAvatarUrl: null,
      fellowPassengers: [],
    );

    emit(state.copyWith(
      status: TripTrackingStatus.tracking,
      currentBooking: mockBooking,
      tripPhase: TripPhase.driverEnRoute,
      estimatedArrivalMinutes: 8,
    ));
  }

  TripPhase _getTripPhaseFromBooking(BookingEntity booking) {
    switch (booking.status) {
      case BookingStatus.accepted:
        return TripPhase.driverEnRoute;
      case BookingStatus.inProgress:
        return TripPhase.inProgress;
      case BookingStatus.completed:
        return TripPhase.completed;
      case BookingStatus.cancelled:
        return TripPhase.cancelled;
      default:
        return TripPhase.driverEnRoute;
    }
  }

  void _stopAllTracking() {
    _driverLocationSubscription?.cancel();
    _etaUpdateTimer?.cancel();
  }

  @override
  Future<void> close() {
    _stopAllTracking();
    return super.close();
  }
}
