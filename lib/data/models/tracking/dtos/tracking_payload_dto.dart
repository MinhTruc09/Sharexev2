import 'package:sharexev2/core/utils/date_time_ext.dart';

class TrackingPayloadDto {
  final String rideId;
  final String driverEmail;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  TrackingPayloadDto({
    required this.rideId,
    required this.driverEmail,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory TrackingPayloadDto.fromJson(Map<String, dynamic> json) {
    return TrackingPayloadDto(
      rideId: json['rideId']?.toString() ?? '',
      driverEmail: json['driverEmail'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "rideId": rideId,
      "driverEmail": driverEmail,
      "latitude": latitude,
      "longitude": longitude,
      "timestamp": timestamp.toIso8601String(),
    };
  }

  /// Getter hiển thị thời gian đẹp (dùng extension)
  String get formattedTime => timestamp.timeAgo;
}
