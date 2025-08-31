part of 'tracking_cubit.dart';

class TrackingState {
  final TrackingStatus status;
  final String? error;
  final int? rideId;
  final String? tripStatus;
  final LocationData? currentLocation;
  final String? driverName;
  final String? vehiclePlate;
  final String? vehicleType;
  final int? estimatedTime;
  final double? remainingDistance;
  final double? tripProgress;

  const TrackingState({
    this.status = TrackingStatus.initial,
    this.error,
    this.rideId,
    this.tripStatus,
    this.currentLocation,
    this.driverName,
    this.vehiclePlate,
    this.vehicleType,
    this.estimatedTime,
    this.remainingDistance,
    this.tripProgress,
  });

  TrackingState copyWith({
    TrackingStatus? status,
    String? error,
    int? rideId,
    String? tripStatus,
    LocationData? currentLocation,
    String? driverName,
    String? vehiclePlate,
    String? vehicleType,
    int? estimatedTime,
    double? remainingDistance,
    double? tripProgress,
  }) {
    return TrackingState(
      status: status ?? this.status,
      error: error ?? this.error,
      rideId: rideId ?? this.rideId,
      tripStatus: tripStatus ?? this.tripStatus,
      currentLocation: currentLocation ?? this.currentLocation,
      driverName: driverName ?? this.driverName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      remainingDistance: remainingDistance ?? this.remainingDistance,
      tripProgress: tripProgress ?? this.tripProgress,
    );
  }
}
