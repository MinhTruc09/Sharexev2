import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/tracking/tracking_repository_interface.dart';

part 'tracking_state.dart';

enum TrackingStatus { initial, loading, tracking, stopped, error }

class LocationData {
  final double lat;
  final double lng;

  const LocationData({required this.lat, required this.lng});
}

class TrackingCubit extends Cubit<TrackingState> {
  final TrackingRepositoryInterface _trackingRepository;

  TrackingCubit({
    required TrackingRepositoryInterface trackingRepository,
  })  : _trackingRepository = trackingRepository,
        super(const TrackingState());

  Future<void> startTracking(int rideId) async {
    emit(state.copyWith(status: TrackingStatus.loading));

    try {
      // Start real-time tracking
      await _trackingRepository.startTracking(rideId);
      
      // Get initial trip data
      final tripData = await _trackingRepository.getTripData(rideId);
      
      emit(state.copyWith(
        status: TrackingStatus.tracking,
        rideId: rideId,
        tripStatus: 'in_progress',
        driverName: 'Nguyễn Văn B',
        vehiclePlate: '29A-12345',
        vehicleType: 'Toyota Vios',
        estimatedTime: 15,
        remainingDistance: 5.2,
        tripProgress: 0.3,
        currentLocation: const LocationData(lat: 10.762622, lng: 106.660172),
      ));

      // Start listening to location updates
      _listenToLocationUpdates();
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.error,
        error: e.toString(),
      ));
    }
  }

  void _listenToLocationUpdates() {
    // TODO: Implement real-time location updates
    // This would typically use WebSocket or Firebase Realtime Database
    
    // Mock periodic updates
    Future.delayed(const Duration(seconds: 5), () {
      if (state.status == TrackingStatus.tracking) {
        emit(state.copyWith(
          currentLocation: LocationData(
            lat: state.currentLocation!.lat + 0.001,
            lng: state.currentLocation!.lng + 0.001,
          ),
          tripProgress: (state.tripProgress ?? 0.3) + 0.1,
          estimatedTime: (state.estimatedTime ?? 15) - 1,
          remainingDistance: (state.remainingDistance ?? 5.2) - 0.2,
        ));
        
        if ((state.tripProgress ?? 0) < 1.0) {
          _listenToLocationUpdates();
        } else {
          emit(state.copyWith(tripStatus: 'completed'));
        }
      }
    });
  }

  Future<void> refreshLocation() async {
    if (state.rideId != null) {
      try {
        final location = await _trackingRepository.getCurrentLocation(state.rideId!);
        emit(state.copyWith(currentLocation: location));
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
    if (state.rideId != null) {
      await _trackingRepository.stopTracking(state.rideId!);
    }
    emit(state.copyWith(status: TrackingStatus.stopped));
  }

  @override
  Future<void> close() {
    stopTracking();
    return super.close();
  }
}
