import 'package:sharexev2/core/network/api_response.dart';
import '../../models/booking/entities/booking_entity.dart';
// ...existing imports...
import 'package:sharexev2/data/models/booking/mappers/booking_mapper.dart';
import 'booking_repository_interface.dart';
import 'package:sharexev2/data/services/booking_service.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingService _bookingService;

  BookingRepositoryImpl(this._bookingService);

  @override
  Future<ApiResponse<List<BookingEntity>>> getPassengerBookings() async {
    final res = await _bookingService.getPassengerBookings();
    if (res.data == null)
      return ApiResponse<List<BookingEntity>>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    final mapped = res.data!.map((dto) => BookingMapper.fromDto(dto)).toList();
    return ApiResponse<List<BookingEntity>>(
      message: res.message,
      statusCode: res.statusCode,
      data: mapped,
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<BookingEntity>> getBookingDetail(String bookingId) async {
    final res = await _bookingService.getBookingDetail(bookingId);
    if (res.data == null)
      return ApiResponse<BookingEntity>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<BookingEntity>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<BookingEntity>> createBooking(String rideId, int seats) async {
    final res = await _bookingService.createBooking(rideId, seats);
    if (res.data == null)
      return ApiResponse<BookingEntity>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<BookingEntity>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<BookingEntity>> passengerConfirmRide(String rideId) async {
    final res = await _bookingService.passengerConfirmRide(rideId);
    if (res.data == null)
      return ApiResponse<BookingEntity>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<BookingEntity>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<BookingEntity>> cancelBooking(String rideId) async {
    final res = await _bookingService.cancelBooking(rideId);
    if (res.data == null)
      return ApiResponse<BookingEntity>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<BookingEntity>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<List<BookingEntity>>> getDriverBookings() async {
    final res = await _bookingService.getDriverBookings();
    if (res.data == null)
      return ApiResponse<List<BookingEntity>>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    final mapped = res.data!.map((dto) => BookingMapper.fromDto(dto)).toList();
    return ApiResponse<List<BookingEntity>>(
      message: res.message,
      statusCode: res.statusCode,
      data: mapped,
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<BookingEntity>> acceptBooking(String bookingId) async {
    final res = await _bookingService.acceptBooking(bookingId);
    if (res.data == null)
      return ApiResponse<BookingEntity>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<BookingEntity>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<BookingEntity>> rejectBooking(String bookingId) async {
    final res = await _bookingService.rejectBooking(bookingId);
    if (res.data == null)
      return ApiResponse<BookingEntity>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<BookingEntity>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<BookingEntity>> completeRide(String rideId) async {
    final res = await _bookingService.completeRide(rideId);
    if (res.data == null)
      return ApiResponse<BookingEntity>(
        message: res.message,
        statusCode: res.statusCode,
        data: null,
        success: res.success,
      );

    return ApiResponse<BookingEntity>(
      message: res.message,
      statusCode: res.statusCode,
      data: BookingMapper.fromDto(res.data!),
      success: res.success,
    );
  }
}
