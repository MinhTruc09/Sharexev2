import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/booking/booking_dto.dart';
import 'package:sharexev2/data/repositories/booking_repository.dart';
import 'package:sharexev2/data/services/booking_service.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingService _bookingService;

  BookingRepositoryImpl(this._bookingService);

  @override
  Future<ApiResponse<List<BookingDTO>>> getPassengerBookings() async {
    return await _bookingService.getPassengerBookings();
  }

  @override
  Future<ApiResponse<BookingDTO>> getBookingDetail(String bookingId) async {
    return await _bookingService.getBookingDetail(bookingId);
  }

  @override
  Future<ApiResponse<BookingDTO>> createBooking(String rideId, int seats) async {
    return await _bookingService.createBooking(rideId, seats);
  }

  @override
  Future<ApiResponse<BookingDTO>> passengerConfirmRide(String rideId) async {
    return await _bookingService.passengerConfirmRide(rideId);
  }

  @override
  Future<ApiResponse<BookingDTO>> cancelBooking(String rideId) async {
    return await _bookingService.cancelBooking(rideId);
  }

  @override
  Future<ApiResponse<List<BookingDTO>>> getDriverBookings() async {
    return await _bookingService.getDriverBookings();
  }

  @override
  Future<ApiResponse<String>> acceptBooking(String bookingId) async {
    return await _bookingService.acceptBooking(bookingId);
  }

  @override
  Future<ApiResponse<String>> rejectBooking(String bookingId) async {
    return await _bookingService.rejectBooking(bookingId);
  }

  @override
  Future<ApiResponse<String>> completeRide(String rideId) async {
    return await _bookingService.completeRide(rideId);
  }
}
