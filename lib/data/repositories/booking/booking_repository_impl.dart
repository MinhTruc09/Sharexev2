import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';
import 'package:sharexev2/data/services/booking_service.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/models/booking/mappers/booking_mapper.dart';

/// Implementation của BookingRepository sử dụng API thật
class BookingRepositoryImpl implements BookingRepositoryInterface {
  final BookingService _bookingService;

  BookingRepositoryImpl({required BookingService bookingService})
    : _bookingService = bookingService;

  @override
  Future<ApiResponse<List<BookingEntity>>> getPassengerBookings() async {
    final response = await _bookingService.getPassengerBookings();
    if (response.success && response.data != null) {
      final entities = BookingMapper.fromDtoList(response.data!);
      return ApiResponse.success(data: entities, message: response.message);
    }
    return ApiResponse.error(message: response.message);
  }

  @override
  Future<ApiResponse<BookingEntity>> getBookingDetail(int bookingId) async {
    final response = await _bookingService.getBookingDetail(
      bookingId.toString(),
    );
    if (response.success && response.data != null) {
      final entity = BookingMapper.fromDto(response.data!);
      return ApiResponse.success(data: entity, message: response.message);
    }
    return ApiResponse.error(message: response.message);
  }

  @override
  Future<ApiResponse<BookingEntity>> createBooking(
    int rideId,
    int seats,
  ) async {
    final response = await _bookingService.createBooking(
      rideId.toString(),
      seats,
    );
    if (response.success && response.data != null) {
      final entity = BookingMapper.fromDto(response.data!);
      return ApiResponse.success(data: entity, message: response.message);
    }
    return ApiResponse.error(message: response.message);
  }

  @override
  Future<ApiResponse<BookingEntity>> passengerConfirmRide(int rideId) async {
    final response = await _bookingService.passengerConfirmRide(
      rideId.toString(),
    );
    if (response.success && response.data != null) {
      final entity = BookingMapper.fromDto(response.data!);
      return ApiResponse.success(data: entity, message: response.message);
    }
    return ApiResponse.error(message: response.message);
  }

  @override
  Future<ApiResponse<BookingEntity>> cancelBooking(int rideId) async {
    final response = await _bookingService.cancelBooking(rideId.toString());
    if (response.success && response.data != null) {
      final entity = BookingMapper.fromDto(response.data!);
      return ApiResponse.success(data: entity, message: response.message);
    }
    return ApiResponse.error(message: response.message);
  }

  @override
  Future<ApiResponse<List<BookingEntity>>> getDriverBookings() async {
    final response = await _bookingService.getDriverBookings();
    if (response.success && response.data != null) {
      final entities = BookingMapper.fromDtoList(response.data!);
      return ApiResponse.success(data: entities, message: response.message);
    }
    return ApiResponse.error(message: response.message);
  }

  @override
  Future<ApiResponse<BookingEntity>> acceptBooking(int bookingId) async {
    final response = await _bookingService.acceptBooking(bookingId.toString());
    if (response.success && response.data != null) {
      final entity = BookingMapper.fromDto(response.data!);
      return ApiResponse.success(data: entity, message: response.message);
    }
    return ApiResponse.error(message: response.message);
  }

  @override
  Future<ApiResponse<BookingEntity>> rejectBooking(int bookingId) async {
    final response = await _bookingService.rejectBooking(bookingId.toString());
    if (response.success && response.data != null) {
      final entity = BookingMapper.fromDto(response.data!);
      return ApiResponse.success(data: entity, message: response.message);
    }
    return ApiResponse.error(message: response.message);
  }

  @override
  Future<ApiResponse<BookingEntity>> completeRide(int rideId) async {
    final response = await _bookingService.completeRide(rideId.toString());
    if (response.success && response.data != null) {
      final entity = BookingMapper.fromDto(response.data!);
      return ApiResponse.success(data: entity, message: response.message);
    }
    return ApiResponse.error(message: response.message);
  }

  @override
  Future<ApiResponse<List<BookingEntity>>> getBookings({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _bookingService.getBookings(page: page, limit: limit);
    if (response.success && response.data != null) {
      final entities = BookingMapper.fromDtoList(response.data!);
      return ApiResponse.success(data: entities, message: response.message);
    }
    return ApiResponse.error(message: response.message);
  }
}
