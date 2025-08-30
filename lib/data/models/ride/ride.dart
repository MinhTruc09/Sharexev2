// lib/data/models/ride.dart

enum RideStatus {
  searching,
  driverFound,
  driverArriving,
  inProgress,
  completed,
  cancelled,
}

class Ride {
  final String id;
  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double price;
  final int duration; // seconds
  final int distance; // meters
  final RideStatus status;
  final String? driverId;
  final String driverName;
  final String driverPhone;
  final String vehicleInfo;
  final DateTime createdAt;

  Ride({
    required this.id,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.price,
    required this.duration,
    required this.distance,
    required this.status,
    this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleInfo,
    required this.createdAt,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id']?.toString() ?? '',
      pickupAddress: json['startAddress'] ?? '',
      dropoffAddress: json['endAddress'] ?? '',
      pickupLat: (json['startLat'] ?? 0).toDouble(),
      pickupLng: (json['startLng'] ?? 0).toDouble(),
      dropoffLat: (json['endLat'] ?? 0).toDouble(),
      dropoffLng: (json['endLng'] ?? 0).toDouble(),
      price: (json['pricePerSeat'] ?? 0).toDouble(),
      duration: 0,
      distance: 0,
      status: _statusFromApi(json['status'] as String?),
      driverId: json['driverId']?.toString(),
      driverName: json['driverName'] ?? '',
      driverPhone: json['driverPhone'] ?? '',
      vehicleInfo: '${json['brand'] ?? ''} ${json['model'] ?? ''} - ${json['licensePlate'] ?? ''}',
      createdAt: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startAddress': pickupAddress,
        'endAddress': dropoffAddress,
        'startLat': pickupLat,
        'startLng': pickupLng,
        'endLat': dropoffLat,
        'endLng': dropoffLng,
        'pricePerSeat': price,
        'status': _statusToApi(status),
        'driverId': driverId,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'brand': vehicleInfo,
        'startTime': createdAt.toIso8601String(),
      };

  static RideStatus _statusFromApi(String? status) {
    switch (status) {
      case 'ACTIVE':
        return RideStatus.searching;
      case 'IN_PROGRESS':
        return RideStatus.inProgress;
      case 'DRIVER_CONFIRMED':
        return RideStatus.driverFound;
      case 'DRIVER_ARRIVING':
        return RideStatus.driverArriving;
      case 'COMPLETED':
        return RideStatus.completed;
      case 'CANCELLED':
        return RideStatus.cancelled;
      default:
        return RideStatus.searching;
    }
  }

  static String _statusToApi(RideStatus status) {
    switch (status) {
      case RideStatus.searching:
        return 'ACTIVE';
      case RideStatus.driverFound:
        return 'DRIVER_CONFIRMED';
      case RideStatus.driverArriving:
        return 'DRIVER_ARRIVING';
      case RideStatus.inProgress:
        return 'IN_PROGRESS';
      case RideStatus.completed:
        return 'COMPLETED';
      case RideStatus.cancelled:
        return 'CANCELLED';
    }
  }
}
