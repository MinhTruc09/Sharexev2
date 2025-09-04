import 'package:sharexev2/core/utils/date_time_ext.dart';

enum RideStatus {
  ACTIVE,
  IN_PROGRESS,
  DRIVER_CONFIRMED,
  COMPLETED,
  CANCELLED;

  static RideStatus fromString(String? value) {
    if (value == null) return RideStatus.ACTIVE;
    return RideStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => RideStatus.ACTIVE,
    );
  }

  String toJson() => name;
}

class RideRequestDTO {
  final int id;
  final int availableSeats;
  final String driverName;
  final String driverEmail;
  // final String departure;
  final double startLat;
  final double startLng;
  final String startAddress;
  final String startWard;
  final String startDistrict;
  final String startProvince;

  final double endLat;
  final double endLng;
  final String endAddress;
  final String endWard;
  final String endDistrict;
  final String endProvince;
  final String destination;

  final DateTime startTime;
  final double pricePerSeat;
  final int totalSeat;
  final RideStatus status;

  RideRequestDTO({
    required this.id,
    required this.availableSeats,
    required this.driverName,
    required this.driverEmail,
    required this.startLat,
    required this.startLng,
    required this.startAddress,
    required this.startWard,
    required this.startDistrict,
    required this.startProvince,
    required this.endLat,
    required this.endLng,
    required this.endAddress,
    required this.endWard,
    required this.endDistrict,
    required this.endProvince,
    required this.destination,
    required this.startTime,
    required this.pricePerSeat,
    required this.totalSeat,
    required this.status,
  });

  /// Getter để show UI
  String get startTimePretty => startTime.timeAgo;

  factory RideRequestDTO.fromJson(Map<String, dynamic> json) {
    return RideRequestDTO(
      id: json['id'] ?? 0,
      availableSeats: json['availableSeats'] ?? 0,
      driverName: json['driverName'] ?? '',
      driverEmail: json['driverEmail'] ?? '',
      startLat: (json['startLat'] ?? 0).toDouble(),
      startLng: (json['startLng'] ?? 0).toDouble(),
      startAddress: json['startAddress'] ?? '',
      startWard: json['startWard'] ?? '',
      startDistrict: json['startDistrict'] ?? '',
      startProvince: json['startProvince'] ?? '',
      endLat: (json['endLat'] ?? 0).toDouble(),
      endLng: (json['endLng'] ?? 0).toDouble(),
      endAddress: json['endAddress'] ?? '',
      endWard: json['endWard'] ?? '',
      endDistrict: json['endDistrict'] ?? '',
      endProvince: json['endProvince'] ?? '',
      destination: json['destination'] ?? '',
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      pricePerSeat: (json['pricePerSeat'] ?? 0).toDouble(),
      totalSeat: json['totalSeat'] ?? 0,
      status: RideStatus.fromString(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "availableSeats": availableSeats,
      "driverName": driverName,
      "driverEmail": driverEmail,
      "startLat": startLat,
      "startLng": startLng,
      "startAddress": startAddress,
      "startWard": startWard,
      "startDistrict": startDistrict,
      "startProvince": startProvince,
      "endLat": endLat,
      "endLng": endLng,
      "endAddress": endAddress,
      "endWard": endWard,
      "endDistrict": endDistrict,
      "endProvince": endProvince,
      "destination": destination,
      "startTime": startTime.toIso8601String(),
      "pricePerSeat": pricePerSeat,
      "totalSeat": totalSeat,
      "status": status.toJson(),
    };
  }
}
