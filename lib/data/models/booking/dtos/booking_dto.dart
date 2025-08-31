import '../booking_status.dart';
import 'passenger_info_dto.dart';
import 'vehicle_dto.dart';

class BookingDto {
  final int id;
  final int rideId;
  final int seatsBooked;
  final BookingStatus status;
  final String createdAt;
  final double totalPrice;
  final String departure;
  final String destination;
  final String startTime;
  final double pricePerSeat;
  final String rideStatus;
  final int totalSeats;
  final int availableSeats;

  final int driverId;
  final String driverName;
  final String driverPhone;
  final String driverEmail;
  final String driverAvatarUrl;
  final String driverStatus;

  final VehicleDto? vehicle;

  final int passengerId;
  final String passengerName;
  final String passengerPhone;
  final String passengerEmail;
  final String passengerAvatarUrl;

  final List<PassengerInfoDto> fellowPassengers;

  BookingDto({
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
    required this.driverAvatarUrl,
    required this.driverStatus,
    this.vehicle,
    required this.passengerId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerEmail,
    required this.passengerAvatarUrl,
    required this.fellowPassengers,
  });

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    return BookingDto(
      id: json['id'] ?? 0,
      rideId: json['rideId'] ?? 0,
      seatsBooked: json['seatsBooked'] ?? 0,
      status: BookingStatus.fromValue(json['status'] ?? ''),
      createdAt: json['createdAt'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      departure: json['departure'] ?? '',
      destination: json['destination'] ?? '',
      startTime: json['startTime'] ?? '',
      pricePerSeat: (json['pricePerSeat'] ?? 0).toDouble(),
      rideStatus: json['rideStatus'] ?? '',
      totalSeats: json['totalSeats'] ?? 0,
      availableSeats: json['availableSeats'] ?? 0,
      driverId: json['driverId'] ?? 0,
      driverName: json['driverName'] ?? '',
      driverPhone: json['driverPhone'] ?? '',
      driverEmail: json['driverEmail'] ?? '',
      driverAvatarUrl: json['driverAvatarUrl'] ?? '',
      driverStatus: json['driverStatus'] ?? '',
      vehicle:
          json['vehicle'] != null ? VehicleDto.fromJson(json['vehicle']) : null,
      passengerId: json['passengerId'] ?? 0,
      passengerName: json['passengerName'] ?? '',
      passengerPhone: json['passengerPhone'] ?? '',
      passengerEmail: json['passengerEmail'] ?? '',
      passengerAvatarUrl: json['passengerAvatarUrl'] ?? '',
      fellowPassengers:
          (json['fellowPassengers'] as List<dynamic>? ?? [])
              .map((e) => PassengerInfoDto.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "rideId": rideId,
    "seatsBooked": seatsBooked,
    "status": status.value,
    "createdAt": createdAt,
    "totalPrice": totalPrice,
    "departure": departure,
    "destination": destination,
    "startTime": startTime,
    "pricePerSeat": pricePerSeat,
    "rideStatus": rideStatus,
    "totalSeats": totalSeats,
    "availableSeats": availableSeats,
    "driverId": driverId,
    "driverName": driverName,
    "driverPhone": driverPhone,
    "driverEmail": driverEmail,
    "driverAvatarUrl": driverAvatarUrl,
    "driverStatus": driverStatus,
    "vehicle": vehicle?.toJson(),
    "passengerId": passengerId,
    "passengerName": passengerName,
    "passengerPhone": passengerPhone,
    "passengerEmail": passengerEmail,
    "passengerAvatarUrl": passengerAvatarUrl,
    "fellowPassengers": fellowPassengers.map((e) => e.toJson()).toList(),
  };
}
