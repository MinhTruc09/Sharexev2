import 'package:equatable/equatable.dart';
import '../../auth/entities/user_entity.dart';
import '../../auth/entities/driver_entity.dart';
import '../booking_status.dart';

/// Business Entity cho Booking - dùng trong UI và business logic
class BookingEntity extends Equatable {
  final int id;
  final int rideId;
  final int seatsBooked;
  final BookingStatus status;
  final DateTime createdAt;
  final double totalPrice;
  final String departure;
  final String destination;
  final DateTime startTime;
  final double pricePerSeat;
  final String rideStatus;
  final int totalSeats;
  final int availableSeats;
  
  // Driver info
  final int driverId;
  final String driverName;
  final String driverPhone;
  final String driverEmail;
  final String? driverAvatarUrl;
  final String driverStatus;
  final VehicleEntity? vehicle;
  
  // Passenger info
  final int passengerId;
  final String passengerName;
  final String passengerPhone;
  final String passengerEmail;
  final String? passengerAvatarUrl;
  
  // Fellow passengers
  final List<PassengerInfoEntity> fellowPassengers;

  const BookingEntity({
    required this.id,
    required this.rideId,
    required this.seatsBooked,
    required this.status,
    required this.createdAt,
    required this.totalPrice,
    required this.departure,
    required this.destination,
    required this.startTime,
    required this.pricePerSeat,
    required this.rideStatus,
    required this.totalSeats,
    required this.availableSeats,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.driverEmail,
    this.driverAvatarUrl,
    required this.driverStatus,
    this.vehicle,
    required this.passengerId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerEmail,
    this.passengerAvatarUrl,
    required this.fellowPassengers,
  });

  @override
  List<Object?> get props => [
        id,
        rideId,
        seatsBooked,
        status,
        createdAt,
        totalPrice,
        departure,
        destination,
        startTime,
        pricePerSeat,
        rideStatus,
        totalSeats,
        availableSeats,
        driverId,
        driverName,
        driverPhone,
        driverEmail,
        driverAvatarUrl,
        driverStatus,
        vehicle,
        passengerId,
        passengerName,
        passengerPhone,
        passengerEmail,
        passengerAvatarUrl,
        fellowPassengers,
      ];

  /// Business methods
  bool get isPending => status == BookingStatus.pending;
  bool get isAccepted => status == BookingStatus.accepted;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isRejected => status == BookingStatus.rejected;
  
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(0)}đ';
  String get formattedPricePerSeat => '${pricePerSeat.toStringAsFixed(0)}đ/ghế';
  String get formattedStartTime => '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
  String get routeDescription => '$departure → $destination';
  String get seatsInfo => '$seatsBooked/${totalSeats} ghế';
  
  int get totalPassengers => fellowPassengers.length + 1; // +1 for current passenger
  
  bool get canCancel => isPending || isAccepted;
  bool get canConfirm => isAccepted;

  BookingEntity copyWith({
    int? id,
    int? rideId,
    int? seatsBooked,
    BookingStatus? status,
    DateTime? createdAt,
    double? totalPrice,
    String? departure,
    String? destination,
    DateTime? startTime,
    double? pricePerSeat,
    String? rideStatus,
    int? totalSeats,
    int? availableSeats,
    int? driverId,
    String? driverName,
    String? driverPhone,
    String? driverEmail,
    String? driverAvatarUrl,
    String? driverStatus,
    VehicleEntity? vehicle,
    int? passengerId,
    String? passengerName,
    String? passengerPhone,
    String? passengerEmail,
    String? passengerAvatarUrl,
    List<PassengerInfoEntity>? fellowPassengers,
  }) {
    return BookingEntity(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      seatsBooked: seatsBooked ?? this.seatsBooked,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      totalPrice: totalPrice ?? this.totalPrice,
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      startTime: startTime ?? this.startTime,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      rideStatus: rideStatus ?? this.rideStatus,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverEmail: driverEmail ?? this.driverEmail,
      driverAvatarUrl: driverAvatarUrl ?? this.driverAvatarUrl,
      driverStatus: driverStatus ?? this.driverStatus,
      vehicle: vehicle ?? this.vehicle,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerEmail: passengerEmail ?? this.passengerEmail,
      passengerAvatarUrl: passengerAvatarUrl ?? this.passengerAvatarUrl,
      fellowPassengers: fellowPassengers ?? this.fellowPassengers,
    );
  }
}

class VehicleEntity extends Equatable {
  final String licensePlate;
  final String brand;
  final String model;
  final String color;
  final int numberOfSeats;
  final String? vehicleImageUrl;
  final String? licenseImageUrl;

  const VehicleEntity({
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.color,
    required this.numberOfSeats,
    this.vehicleImageUrl,
    this.licenseImageUrl,
  });

  @override
  List<Object?> get props => [
        licensePlate,
        brand,
        model,
        color,
        numberOfSeats,
        vehicleImageUrl,
        licenseImageUrl,
      ];

  String get fullInfo => '$brand $model - $color - $licensePlate';
}

class PassengerInfoEntity extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String? avatarUrl;
  final BookingStatus status;
  final int seatsBooked;

  const PassengerInfoEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.avatarUrl,
    required this.status,
    required this.seatsBooked,
  });

  @override
  List<Object?> get props => [id, name, phone, email, avatarUrl, status, seatsBooked];
}

enum BookingStatus {
  pending,
  accepted,
  inProgress,
  passengerConfirmed,
  driverConfirmed,
  completed,
  cancelled,
  rejected;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Chờ xác nhận';
      case BookingStatus.accepted:
        return 'Đã chấp nhận';
      case BookingStatus.inProgress:
        return 'Đang di chuyển';
      case BookingStatus.passengerConfirmed:
        return 'Hành khách đã xác nhận';
      case BookingStatus.driverConfirmed:
        return 'Tài xế đã xác nhận';
      case BookingStatus.completed:
        return 'Hoàn thành';
      case BookingStatus.cancelled:
        return 'Đã hủy';
      case BookingStatus.rejected:
        return 'Bị từ chối';
    }
  }

  static BookingStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return BookingStatus.pending;
      case 'ACCEPTED':
        return BookingStatus.accepted;
      case 'IN_PROGRESS':
        return BookingStatus.inProgress;
      case 'PASSENGER_CONFIRMED':
        return BookingStatus.passengerConfirmed;
      case 'DRIVER_CONFIRMED':
        return BookingStatus.driverConfirmed;
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      case 'REJECTED':
        return BookingStatus.rejected;
      default:
        return BookingStatus.pending;
    }
  }
}
