import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/tracking/tracking_repository_interface.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/repositories/location/location_repository_interface.dart';
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';

part 'tracking_state.dart';

enum TrackingStatus { initial, loading, tracking, stopped, error }

enum TripPhase {
  driverEnRoute,    // Driver is coming to pickup
  arrived,          // Driver has arrived at pickup
  inProgress,       // Trip is in progress
  completed,        // Trip completed
  cancelled,        // Trip cancelled
}

class LocationData {
  final double lat;
  final double lng;

  const LocationData({required this.lat, required this.lng});
}

class TrackingCubit extends Cubit<TrackingState> {
  final TrackingRepositoryInterface _trackingRepository;
  final dynamic _bookingRepository; // TODO: Type as BookingRepositoryInterface when DI is ready
  final dynamic _locationRepository; // TODO: Type as LocationRepositoryInterface when DI is ready
  
  StreamSubscription<LocationData>? _driverLocationSubscription;
  Timer? _etaUpdateTimer;

  TrackingCubit({
    required TrackingRepositoryInterface trackingRepository,
    required dynamic bookingRepository,
    required dynamic locationRepository,
  })  : _trackingRepository = trackingRepository,
        _bookingRepository = bookingRepository,
        _locationRepository = locationRepository,
        super(const TrackingState());

  // ===== Basic Tracking Functions =====

  Future<void> startTracking(int rideId) async {
    emit(state.copyWith(status: TrackingStatus.loading));

    try {
      // Start real-time tracking using location repository
      if (_locationRepository != null) {
        _startDriverLocationTracking();
        _startETAUpdates();
        
        emit(state.copyWith(
          status: TrackingStatus.tracking,
          rideId: rideId,
          tripStatus: 'in_progress',
        ));
      } else {
        emit(state.copyWith(
          status: TrackingStatus.error,
          error: 'Location tracking service không khả dụng',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.error,
        error: e.toString(),
      ));
    }
  }

  void _listenToLocationUpdates() {
    // TODO: Implement real-time location updates via WebSocket or Firebase
    // For now, emit error instead of mock data
    emit(state.copyWith(
      status: TrackingStatus.error,
      error: 'Real-time tracking service chưa được triển khai',
    ));
  }

  Future<void> refreshLocation() async {
    if (state.rideId != null && _locationRepository != null) {
      try {
        final response = await _locationRepository.getCurrentLocation();
        if (response.success && response.data != null) {
          emit(state.copyWith(currentLocation: response.data!));
        }
      } catch (e) {
        // Handle error silently for refresh
      }
    }
  }

  void centerOnVehicle() {
    // TODO: Implement map centering
    // This would typically call a map controller method
  }

  Future<void> stopTracking() async {
    if (state.rideId != null && _locationRepository != null) {
      await _locationRepository.stopLocationTracking();
    }
    _stopAllTracking();
    emit(state.copyWith(status: TrackingStatus.stopped));
  }

  // ===== Trip Lifecycle Management =====

  /// Start tracking a trip with booking
  Future<void> startTripTracking(int bookingId) async {
    emit(state.copyWith(status: TrackingStatus.loading));

    try {
      if (_bookingRepository != null) {
        final response = await _bookingRepository.getBookingDetail(bookingId);
        
        if (response.success && response.data != null) {
          final booking = response.data!;
          
          emit(state.copyWith(
            status: TrackingStatus.tracking,
            rideId: booking.rideId,
            tripStatus: _getTripPhaseFromBooking(booking).name,
            driverName: booking.driverName ?? 'Tài xế',
            vehiclePlate: booking.vehicle?.licensePlate ?? 'N/A',
            vehicleType: '${booking.vehicle?.brand ?? ''} ${booking.vehicle?.model ?? ''}',
            error: null,
          ));

          // Start real-time tracking
          _startDriverLocationTracking();
          _startETAUpdates();
        } else {
          emit(state.copyWith(
            status: TrackingStatus.error,
            error: response.message ?? 'Failed to load booking',
          ));
        }
      } else {
        emit(state.copyWith(
          status: TrackingStatus.error,
          error: 'Booking tracking service không khả dụng',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.error,
        error: 'Trip tracking error: $e',
      ));
    }
  }

  /// Driver confirms pickup
  Future<void> confirmPickup() async {
    if (state.rideId == null) return;

    emit(state.copyWith(status: TrackingStatus.loading));

    try {
      if (_bookingRepository != null) {
        final response = await _bookingRepository.passengerConfirmRide(state.rideId!);
        
        if (response.success) {
          emit(state.copyWith(
            status: TrackingStatus.tracking,
            tripStatus: TripPhase.inProgress.name,
          ));
        } else {
          emit(state.copyWith(
            status: TrackingStatus.error,
            error: response.message ?? 'Failed to confirm pickup',
          ));
        }
      } else {
        emit(state.copyWith(
          status: TrackingStatus.error,
          error: 'Booking repository không khả dụng',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.error,
        error: 'Pickup confirmation error: $e',
      ));
    }
  }

  /// Complete trip
  Future<void> completeTrip() async {
    if (state.rideId == null) return;

    emit(state.copyWith(status: TrackingStatus.loading));

    try {
      if (_bookingRepository != null) {
        final response = await _bookingRepository.completeRide(state.rideId!);
        
        if (response.success) {
          emit(state.copyWith(
            status: TrackingStatus.tracking,
            tripStatus: TripPhase.completed.name,
          ));
          
          _stopAllTracking();
        } else {
          emit(state.copyWith(
            status: TrackingStatus.error,
            error: response.message ?? 'Failed to complete trip',
          ));
        }
      } else {
        emit(state.copyWith(
          status: TrackingStatus.error,
          error: 'Booking repository không khả dụng',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.error,
        error: 'Trip completion error: $e',
      ));
    }
  }

  /// Cancel trip
  Future<void> cancelTrip(String reason) async {
    if (state.rideId == null) return;

    emit(state.copyWith(status: TrackingStatus.loading));

    try {
      if (_bookingRepository != null) {
        final response = await _bookingRepository.cancelBooking(state.rideId!);
        
        if (response.success) {
          emit(state.copyWith(
            status: TrackingStatus.tracking,
            tripStatus: TripPhase.cancelled.name,
          ));
          
          _stopAllTracking();
        } else {
          emit(state.copyWith(
            status: TrackingStatus.error,
            error: response.message ?? 'Failed to cancel trip',
          ));
        }
      } else {
        emit(state.copyWith(
          status: TrackingStatus.error,
          error: 'Booking repository không khả dụng',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.error,
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
            currentLocation: location,
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
    if (state.currentLocation != null) {
      // Calculate ETA based on current location and destination
      final estimatedMinutes = _calculateETA(state.currentLocation!);
      
      emit(state.copyWith(estimatedTime: estimatedMinutes));
    }
  }

  int _calculateETA(LocationData driverLocation) {
    // Use real ETA calculation with fallback coordinates
    // TODO: Get destination coordinates from ride data
    final distance = _calculateDistance(
      driverLocation.lat,
      driverLocation.lng,
      21.0285, // TODO: Get from ride destination coordinates
      105.8542, // TODO: Get from ride destination coordinates
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
