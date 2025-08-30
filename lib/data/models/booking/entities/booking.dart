import 'package:sharexev2/data/models/booking/booking_status.dart';
import 'package:sharexev2/data/models/booking/vehicle.dart';
import 'package:sharexev2/data/models/booking/passenger_info.dart';

class Booking {
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

  final Vehicle? vehicle;

  final int passengerId;
  final String passengerName;
  final String passengerPhone;
  final String passengerEmail;
  final String passengerAvatarUrl;

  final List<PassengerInfo> fellowPassengers;

  Booking({
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
}
