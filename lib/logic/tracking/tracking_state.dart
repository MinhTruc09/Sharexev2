part of 'tracking_cubit.dart';

enum TrackingStatus {
  initial,
  active,
  inactive,
  error,
}

class LocationData {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
  });
}

class TrackingState {
  final TrackingStatus status;
  final String? error;
  final int? rideId;
  final String? tripStatus;
  final LocationData? currentLocation;
  final LocationData? driverLocation;
  final String? driverName;
  final String? vehiclePlate;
  final String? vehicleType;
  final int? estimatedTime;
  final double? remainingDistance;
  final double? tripProgress;

  // Map properties
  final double? mapCenterLat;
  final double? mapCenterLng;
  final double? mapZoom;

  // Destination properties
  final double? destinationLat;
  final double? destinationLng;

  const TrackingState({
    this.status = TrackingStatus.initial,
    this.error,
    this.rideId,
    this.tripStatus,
    this.currentLocation,
    this.driverLocation,
    this.driverName,
    this.vehiclePlate,
    this.vehicleType,
    this.estimatedTime,
    this.remainingDistance,
    this.tripProgress,
    this.mapCenterLat,
    this.mapCenterLng,
    this.mapZoom,
    this.destinationLat,
    this.destinationLng,
  });

  TrackingState copyWith({
    TrackingStatus? status,
    String? error,
    int? rideId,
    String? tripStatus,
    LocationData? currentLocation,
    LocationData? driverLocation,
    String? driverName,
    String? vehiclePlate,
    String? vehicleType,
    int? estimatedTime,
    double? remainingDistance,
    double? tripProgress,
    double? mapCenterLat,
    double? mapCenterLng,
    double? mapZoom,
    double? destinationLat,
    double? destinationLng,
  }) {
    return TrackingState(
      status: status ?? this.status,
      error: error ?? this.error,
      rideId: rideId ?? this.rideId,
      tripStatus: tripStatus ?? this.tripStatus,
      currentLocation: currentLocation ?? this.currentLocation,
      driverLocation: driverLocation ?? this.driverLocation,
      driverName: driverName ?? this.driverName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      remainingDistance: remainingDistance ?? this.remainingDistance,
      tripProgress: tripProgress ?? this.tripProgress,
      mapCenterLat: mapCenterLat ?? this.mapCenterLat,
      mapCenterLng: mapCenterLng ?? this.mapCenterLng,
      mapZoom: mapZoom ?? this.mapZoom,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
    );
  }
}
