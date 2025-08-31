import 'package:equatable/equatable.dart';

/// Business Entity cho Ride - dùng trong UI và business logic
class RideEntity extends Equatable {
  final int id;
  final int? availableSeats;
  final String driverName;
  final String driverEmail;
  final String departure;
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

  const RideEntity({
    required this.id,
    this.availableSeats,
    required this.driverName,
    required this.driverEmail,
    required this.departure,
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

  @override
  List<Object?> get props => [
        id,
        availableSeats,
        driverName,
        driverEmail,
        departure,
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
        destination,
        startTime,
        pricePerSeat,
        totalSeat,
        status,
      ];

  /// Business methods
  bool get isActive => status == RideStatus.active;
  bool get isCompleted => status == RideStatus.completed;
  bool get isCancelled => status == RideStatus.cancelled;
  bool get hasAvailableSeats => (availableSeats ?? 0) > 0;
  
  String get formattedPrice => '${pricePerSeat.toStringAsFixed(0)}đ';
  String get formattedStartTime => '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
  String get routeDescription => '$departure → $destination';
  
  double get estimatedDuration {
    // Simple estimation based on distance
    final distance = _calculateDistance(startLat, startLng, endLat, endLng);
    return distance / 50; // Assume 50km/h average speed
  }
  
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simplified distance calculation
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    return (dLat * dLat + dLon * dLon) * 111; // Rough km conversion
  }

  RideEntity copyWith({
    int? id,
    int? availableSeats,
    String? driverName,
    String? driverEmail,
    String? departure,
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
    String? destination,
    DateTime? startTime,
    double? pricePerSeat,
    int? totalSeat,
    RideStatus? status,
  }) {
    return RideEntity(
      id: id ?? this.id,
      availableSeats: availableSeats ?? this.availableSeats,
      driverName: driverName ?? this.driverName,
      driverEmail: driverEmail ?? this.driverEmail,
      departure: departure ?? this.departure,
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
      destination: destination ?? this.destination,
      startTime: startTime ?? this.startTime,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      totalSeat: totalSeat ?? this.totalSeat,
      status: status ?? this.status,
    );
  }
}

enum RideStatus {
  active,
  inProgress,
  driverConfirmed,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case RideStatus.active:
        return 'Đang hoạt động';
      case RideStatus.inProgress:
        return 'Đang di chuyển';
      case RideStatus.driverConfirmed:
        return 'Tài xế đã xác nhận';
      case RideStatus.completed:
        return 'Hoàn thành';
      case RideStatus.cancelled:
        return 'Đã hủy';
    }
  }
}
