class Ride {
  final String id;
  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double price;
  final int duration; // minutes
  final double distance; // km
  final RideStatus status;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleInfo;
  final DateTime createdAt;

  const Ride({
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
    this.driverName,
    this.driverPhone,
    this.vehicleInfo,
    required this.createdAt,
  });

  Ride copyWith({
    String? id,
    String? pickupAddress,
    String? dropoffAddress,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    double? price,
    int? duration,
    double? distance,
    RideStatus? status,
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? vehicleInfo,
    DateTime? createdAt,
  }) {
    return Ride(
      id: id ?? this.id,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum RideStatus {
  searching,
  driverFound,
  driverArriving,
  inProgress,
  completed,
  cancelled,
}

extension RideStatusExtension on RideStatus {
  String get displayName {
    switch (this) {
      case RideStatus.searching:
        return 'Đang tìm tài xế';
      case RideStatus.driverFound:
        return 'Đã tìm thấy tài xế';
      case RideStatus.driverArriving:
        return 'Tài xế đang đến';
      case RideStatus.inProgress:
        return 'Đang di chuyển';
      case RideStatus.completed:
        return 'Hoàn thành';
      case RideStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String get description {
    switch (this) {
      case RideStatus.searching:
        return 'Đang tìm tài xế gần bạn...';
      case RideStatus.driverFound:
        return 'Tài xế đã nhận chuyến';
      case RideStatus.driverArriving:
        return 'Tài xế đang đến điểm đón';
      case RideStatus.inProgress:
        return 'Đang trên đường đến đích';
      case RideStatus.completed:
        return 'Chuyến đi đã hoàn thành';
      case RideStatus.cancelled:
        return 'Chuyến đi đã bị hủy';
    }
  }
}
