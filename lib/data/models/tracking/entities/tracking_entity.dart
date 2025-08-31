import 'package:equatable/equatable.dart';
import 'dart:math' as math;

/// Business Entity cho Tracking - dùng trong UI và business logic
class TrackingEntity extends Equatable {
  final String rideId;
  final String driverEmail;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const TrackingEntity({
    required this.rideId,
    required this.driverEmail,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        rideId,
        driverEmail,
        latitude,
        longitude,
        timestamp,
      ];

  /// Business methods
  bool get isValidLocation => latitude != 0.0 && longitude != 0.0;
  
  String get coordinatesString => '$latitude, $longitude';
  
  String get timeFormatted {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
  
  /// Calculate distance from another location (in km)
  double distanceFrom(double otherLat, double otherLng) {
    const double earthRadius = 6371; // Earth's radius in km
    
    final dLat = _toRadians(otherLat - latitude);
    final dLng = _toRadians(otherLng - longitude);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) * math.cos(_toRadians(otherLat)) * math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }
  
  double _toRadians(double degrees) => degrees * (3.14159265359 / 180);
  
  /// Check if location is recent (within last 5 minutes)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inMinutes <= 5;
  }

  TrackingEntity copyWith({
    String? rideId,
    String? driverEmail,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) {
    return TrackingEntity(
      rideId: rideId ?? this.rideId,
      driverEmail: driverEmail ?? this.driverEmail,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Business Entity cho Driver Location History
class LocationHistoryEntity extends Equatable {
  final String rideId;
  final List<TrackingEntity> locations;
  final DateTime startTime;
  final DateTime? endTime;

  const LocationHistoryEntity({
    required this.rideId,
    required this.locations,
    required this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [rideId, locations, startTime, endTime];

  /// Business methods
  bool get isActive => endTime == null;
  bool get hasLocations => locations.isNotEmpty;
  
  TrackingEntity? get currentLocation => 
      locations.isNotEmpty ? locations.last : null;
  
  TrackingEntity? get startLocation => 
      locations.isNotEmpty ? locations.first : null;
  
  double get totalDistance {
    if (locations.length < 2) return 0.0;
    
    double total = 0.0;
    for (int i = 1; i < locations.length; i++) {
      total += locations[i].distanceFrom(
        locations[i - 1].latitude,
        locations[i - 1].longitude,
      );
    }
    return total;
  }
  
  Duration get totalDuration {
    if (locations.isEmpty) return Duration.zero;
    
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
  
  double get averageSpeed {
    final duration = totalDuration.inHours;
    if (duration == 0) return 0.0;
    return totalDistance / duration;
  }

  LocationHistoryEntity copyWith({
    String? rideId,
    List<TrackingEntity>? locations,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return LocationHistoryEntity(
      rideId: rideId ?? this.rideId,
      locations: locations ?? this.locations,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
