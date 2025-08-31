// DTO for passenger information returned by booking APIs.

import 'package:sharexev2/data/models/booking/booking_status.dart';

class PassengerInfoDto {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final BookingStatus status;
  final int seatsBooked;
  PassengerInfoDto({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.status,
    required this.seatsBooked,
  });
  factory PassengerInfoDto.fromJson(Map<String, dynamic> json) {
    return PassengerInfoDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'],
      status: BookingStatus.fromValue(json['status'] ?? ''),
      seatsBooked: json['seatsBooked'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "avatarUrl": avatarUrl,
      "status": status.value,
      "seatsBooked": seatsBooked,
    };
  }
}
