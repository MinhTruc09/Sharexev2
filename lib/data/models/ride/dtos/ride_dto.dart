import 'package:equatable/equatable.dart';

/// Ride DTO for API communication
class RideDto extends Equatable {
  final int id;
  final String departure;
  final String destination;
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
  final String startTime;
  final double pricePerSeat;
  final int totalSeat;
  final int availableSeats;
  final String status;
  final String driverName;
  final String driverEmail;
  final String? driverPhone;
  final String? driverAvatar;
  final String? vehicleInfo;
  final String createdAt;
  final String? updatedAt;

  const RideDto({
    required this.id,
    required this.departure,
    required this.destination,
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
    required this.startTime,
    required this.pricePerSeat,
    required this.totalSeat,
    required this.availableSeats,
    required this.status,
    required this.driverName,
    required this.driverEmail,
    this.driverPhone,
    this.driverAvatar,
    this.vehicleInfo,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory RideDto.fromJson(Map<String, dynamic> json) {
    return RideDto(
      id: json['id'] ?? 0,
      departure: json['departure'] ?? '',
      destination: json['destination'] ?? '',
      startLat: (json['startLat'] ?? 0.0).toDouble(),
      startLng: (json['startLng'] ?? 0.0).toDouble(),
      startAddress: json['startAddress'] ?? '',
      startWard: json['startWard'] ?? '',
      startDistrict: json['startDistrict'] ?? '',
      startProvince: json['startProvince'] ?? '',
      endLat: (json['endLat'] ?? 0.0).toDouble(),
      endLng: (json['endLng'] ?? 0.0).toDouble(),
      endAddress: json['endAddress'] ?? '',
      endWard: json['endWard'] ?? '',
      endDistrict: json['endDistrict'] ?? '',
      endProvince: json['endProvince'] ?? '',
      startTime: json['startTime'] ?? '',
      pricePerSeat: (json['pricePerSeat'] ?? 0.0).toDouble(),
      totalSeat: json['totalSeat'] ?? 0,
      availableSeats: json['availableSeats'] ?? 0,
      status: json['status'] ?? 'ACTIVE',
      driverName: json['driverName'] ?? '',
      driverEmail: json['driverEmail'] ?? '',
      driverPhone: json['driverPhone'],
      driverAvatar: json['driverAvatar'],
      vehicleInfo: json['vehicleInfo'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departure': departure,
      'destination': destination,
      'startLat': startLat,
      'startLng': startLng,
      'startAddress': startAddress,
      'startWard': startWard,
      'startDistrict': startDistrict,
      'startProvince': startProvince,
      'endLat': endLat,
      'endLng': endLng,
      'endAddress': endAddress,
      'endWard': endWard,
      'endDistrict': endDistrict,
      'endProvince': endProvince,
      'startTime': startTime,
      'pricePerSeat': pricePerSeat,
      'totalSeat': totalSeat,
      'availableSeats': availableSeats,
      'status': status,
      'driverName': driverName,
      'driverEmail': driverEmail,
      'driverPhone': driverPhone,
      'driverAvatar': driverAvatar,
      'vehicleInfo': vehicleInfo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Copy with
  RideDto copyWith({
    int? id,
    String? departure,
    String? destination,
    double? startLat,
    double? startLng,
    String? startAddress,
    String? startWard,
    String? startDistrict,
    String? startProvince,
    double? endLat,
    double? endLng,
    String? endAddress,
    String? endWard,
    String? endDistrict,
    String? endProvince,
    String? startTime,
    double? pricePerSeat,
    int? totalSeat,
    int? availableSeats,
    String? status,
    String? driverName,
    String? driverEmail,
    String? driverPhone,
    String? driverAvatar,
    String? vehicleInfo,
    String? createdAt,
    String? updatedAt,
  }) {
    return RideDto(
      id: id ?? this.id,
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      startAddress: startAddress ?? this.startAddress,
      startWard: startWard ?? this.startWard,
      startDistrict: startDistrict ?? this.startDistrict,
      startProvince: startProvince ?? this.startProvince,
      endLat: endLat ?? this.endLat,
      endLng: endLng ?? this.endLng,
      endAddress: endAddress ?? this.endAddress,
      endWard: endWard ?? this.endWard,
      endDistrict: endDistrict ?? this.endDistrict,
      endProvince: endProvince ?? this.endProvince,
      startTime: startTime ?? this.startTime,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      totalSeat: totalSeat ?? this.totalSeat,
      availableSeats: availableSeats ?? this.availableSeats,
      status: status ?? this.status,
      driverName: driverName ?? this.driverName,
      driverEmail: driverEmail ?? this.driverEmail,
      driverPhone: driverPhone ?? this.driverPhone,
      driverAvatar: driverAvatar ?? this.driverAvatar,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        departure,
        destination,
        startLat,
        startLng,
        startAddress,
        startWard,
        startDistrict,
        startProvince,
        endLat,
        endLng,
        endAddress,
        endWard,
        endDistrict,
        endProvince,
        startTime,
        pricePerSeat,
        totalSeat,
        availableSeats,
        status,
        driverName,
        driverEmail,
        driverPhone,
        driverAvatar,
        vehicleInfo,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() => 'RideDto(id: $id, departure: $departure, destination: $destination)';
}
