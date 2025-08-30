import 'package:sharexev2/data/models/booking/booking_status.dart';

class PassengerInfo {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final BookingStatus status;
  final int seatsBooked;

  PassengerInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.status,
    required this.seatsBooked,
  });
}
