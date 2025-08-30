import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/booking/booking.dart';
// ...existing imports...
import 'package:sharexev2/data/models/booking/mappers/booking_mapper.dart';
import 'package:sharexev2/data/repositories/booking_repository.dart';
import 'package:sharexev2/data/services/booking_service.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingService _bookingService;

  BookingRepositoryImpl(this._bookingService);

  @override
  Future<ApiResponse<List<Booking>>> getPassengerBookings() async {
    final res = await _bookingService.getPassengerBookings();
    if (res.data == null)
      return ApiResponse<List<Booking>>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    final mapped = res.data!.map((dto) => BookingMapper.fromDto(dto)).toList();
    return ApiResponse<List<Booking>>(
      message: res.message,
      statusCode: res.statusCode,
      data: mapped,
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<Booking>> getBookingDetail(String bookingId) async {
    final res = await _bookingService.getBookingDetail(bookingId);
    if (res.data == null)
      return ApiResponse<Booking>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<Booking>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<Booking>> createBooking(String rideId, int seats) async {
    final res = await _bookingService.createBooking(rideId, seats);
    if (res.data == null)
      return ApiResponse<Booking>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<Booking>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<Booking>> passengerConfirmRide(String rideId) async {
    final res = await _bookingService.passengerConfirmRide(rideId);
    if (res.data == null)
      return ApiResponse<Booking>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<Booking>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<Booking>> cancelBooking(String rideId) async {
    final res = await _bookingService.cancelBooking(rideId);
    if (res.data == null)
      return ApiResponse<Booking>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<Booking>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<List<Booking>>> getDriverBookings() async {
    final res = await _bookingService.getDriverBookings();
    if (res.data == null)
      return ApiResponse<List<Booking>>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    final mapped = res.data!.map((dto) => BookingMapper.fromDto(dto)).toList();
    return ApiResponse<List<Booking>>(
      message: res.message,
      statusCode: res.statusCode,
      data: mapped,
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<Booking>> acceptBooking(String bookingId) async {
    final res = await _bookingService.acceptBooking(bookingId);
    if (res.data == null)
      return ApiResponse<Booking>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<Booking>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<Booking>> rejectBooking(String bookingId) async {
    final res = await _bookingService.rejectBooking(bookingId);
    if (res.data == null)
      return ApiResponse<Booking>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<Booking>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<Booking>> completeRide(String rideId) async {
    final res = await _bookingService.completeRide(rideId);
    if (res.data == null)
      return ApiResponse<Booking>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<Booking>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }
}
