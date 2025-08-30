import 'package:sharexev2/data/models/booking/booking_dto.dart';
import 'package:sharexev2/data/models/booking/booking.dart';
import 'package:sharexev2/data/models/booking/mappers/vehicle_mapper.dart';
import 'package:sharexev2/data/models/booking/mappers/passenger_info_mapper.dart';

class BookingMapper {
  static Booking fromDto(BookingDTO dto) {
    return Booking(
      id: dto.id,
      rideId: dto.rideId,
      seatsBooked: dto.seatsBooked,
      status: dto.status,
      createdAt: dto.createdAt,
      totalPrice: dto.totalPrice,
      departure: dto.departure,
      destination: dto.destination,
      startTime: dto.startTime,
      pricePerSeat: dto.pricePerSeat,
      rideStatus: dto.rideStatus,
      totalSeats: dto.totalSeats,
      availableSeats: dto.availableSeats,
      driverId: dto.driverId,
      driverName: dto.driverName,
      driverPhone: dto.driverPhone,
      driverEmail: dto.driverEmail,
      driverAvatarUrl: dto.driverAvatarUrl,
      driverStatus: dto.driverStatus,
      passengerId: dto.passengerId,
      passengerName: dto.passengerName,
      passengerPhone: dto.passengerPhone,
      passengerEmail: dto.passengerEmail,
      passengerAvatarUrl: dto.passengerAvatarUrl,
      vehicle: dto.vehicle != null ? VehicleMapper.fromDto(dto.vehicle!) : null,
      fellowPassengers:
          dto.fellowPassengers
              .map((p) => PassengerInfoMapper.fromDto(p))
              .toList(),
    );
  }
}
