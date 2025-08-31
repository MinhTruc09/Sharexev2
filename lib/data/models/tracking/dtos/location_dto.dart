import 'package:equatable/equatable.dart';

/// Location DTO for API communication
class LocationDto extends Equatable {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? bearing;
  final double? speed;
  final String timestamp;
  final String? address;
  final String? city;
  final String? country;
  final Map<String, dynamic>? metadata;

  const LocationDto({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.bearing,
    this.speed,
    required this.timestamp,
    this.address,
    this.city,
    this.country,
    this.metadata,
  });

  /// Create from JSON
  factory LocationDto.fromJson(Map<String, dynamic> json) {
    return LocationDto(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      altitude: json['altitude']?.toDouble(),
      bearing: json['bearing']?.toDouble(),
      speed: json['speed']?.toDouble(),
      timestamp: json['timestamp'] ?? '',
      address: json['address'],
      city: json['city'],
      country: json['country'],
      metadata: json['metadata'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'bearing': bearing,
      'speed': speed,
      'timestamp': timestamp,
      'address': address,
      'city': city,
      'country': country,
      'metadata': metadata,
    };
  }

  /// Copy with
  LocationDto copyWith({
    String? id,
    String? userId,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? bearing,
    double? speed,
    String? timestamp,
    String? address,
    String? city,
    String? country,
    Map<String, dynamic>? metadata,
  }) {
    return LocationDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      bearing: bearing ?? this.bearing,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        latitude,
        longitude,
        accuracy,
        altitude,
        bearing,
        speed,
        timestamp,
        address,
        city,
        country,
        metadata,
      ];

  @override
  String toString() => 'LocationDto(id: $id, lat: $latitude, lng: $longitude)';
}
