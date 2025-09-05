import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/tracking/entities/location_entity.dart';
import '../../data/repositories/tracking/tracking_repository_interface.dart';

/// Cubit for managing real-time tracking state
class TrackingCubit extends Cubit<TrackingState> {
  final TrackingRepositoryInterface? _trackingRepository;

  TrackingCubit(this._trackingRepository) : super(const TrackingState());

  /// Start tracking for a specific ride
  Future<void> startTracking(String rideId) async {
    if (_trackingRepository == null) {
      emit(state.copyWith(
        status: TrackingStatus.inactive,
        error: 'Tracking repository not available',
      ));
      return;
    }

    emit(state.copyWith(status: TrackingStatus.active, error: null));

    try {
      await _trackingRepository!.startTracking(rideId);
      emit(state.copyWith(status: TrackingStatus.active));
    } catch (e) {
      emit(state.copyWith(
        status: TrackingStatus.inactive,
        error: 'Failed to start tracking: $e',
      ));
    }
  }

  /// Stop tracking for a specific ride
  Future<void> stopTracking(String rideId) async {
    if (_trackingRepository == null) {
      emit(state.copyWith(
        status: TrackingStatus.inactive,
        error: 'Tracking repository not available',
      ));
      return;
    }

    try {
      await _trackingRepository!.stopTracking(rideId);
      emit(state.copyWith(
        status: TrackingStatus.inactive,
        currentLocation: null,
        route: [],
        progress: null,
        eta: null,
        remainingDistance: null,
        remainingTime: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to stop tracking: $e',
      ));
    }
  }

  /// Update driver location
  void updateLocation(LocationEntity location) {
    emit(state.copyWith(
      currentLocation: location,
      lastUpdate: DateTime.now(),
    ));
  }

  /// Update route information
  void updateRoute(List<LatLng> routePoints, {
    double? progress,
    DateTime? eta,
    double? remainingDistance,
    int? remainingTime,
  }) {
    emit(state.copyWith(
      route: routePoints,
      progress: progress,
      eta: eta,
      remainingDistance: remainingDistance,
      remainingTime: remainingTime,
      lastUpdate: DateTime.now(),
    ));
  }

  /// Refresh tracking data
  Future<void> refreshTracking(String rideId) async {
    if (_trackingRepository == null) {
      emit(state.copyWith(
        error: 'Tracking repository not available',
      ));
      return;
    }

    try {
      final location = await _trackingRepository!.getCurrentLocation(rideId);
      if (location != null) {
        updateLocation(location);
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to refresh tracking: $e',
      ));
    }
  }

  /// Set tracking status
  void setStatus(TrackingStatus status) {
    emit(state.copyWith(status: status));
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(error: null));
  }
}

/// State for tracking
class TrackingState {
  final TrackingStatus status;
  final LocationEntity? currentLocation;
  final List<LatLng> route;
  final double? progress; // 0.0 to 1.0
  final DateTime? eta;
  final double? remainingDistance; // in km
  final int? remainingTime; // in minutes
  final DateTime? lastUpdate;
  final String? error;

  const TrackingState({
    this.status = TrackingStatus.inactive,
    this.currentLocation,
    this.route = const [],
    this.progress,
    this.eta,
    this.remainingDistance,
    this.remainingTime,
    this.lastUpdate,
    this.error,
  });

  TrackingState copyWith({
    TrackingStatus? status,
    LocationEntity? currentLocation,
    List<LatLng>? route,
    double? progress,
    DateTime? eta,
    double? remainingDistance,
    int? remainingTime,
    DateTime? lastUpdate,
    String? error,
  }) {
    return TrackingState(
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      route: route ?? this.route,
      progress: progress ?? this.progress,
      eta: eta ?? this.eta,
      remainingDistance: remainingDistance ?? this.remainingDistance,
      remainingTime: remainingTime ?? this.remainingTime,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      error: error,
    );
  }
}

/// Enum for tracking status
enum TrackingStatus {
  inactive,
  active,
  paused,
  completed,
  cancelled,
}