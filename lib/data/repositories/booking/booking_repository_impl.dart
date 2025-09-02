import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';

import 'package:sharexev2/data/models/booking/mappers/booking_mapper.dart';
import 'package:sharexev2/data/services/booking_service.dart';
import 'booking_repository_interface.dart';

/// Implementation của BookingRepository sử dụng real API
class BookingRepositoryImpl implements BookingRepositoryInterface {
  final BookingService _bookingService;
  final BookingMapper _bookingMapper = BookingMapper();

  BookingRepositoryImpl({
    required BookingService bookingService,
  }) : _bookingService = bookingService;

  @override
  Future<ApiResponse<List<BookingEntity>>> getPassengerBookings() async {
    try {
      final response = await _bookingService.getPassengerBookings();
      
      if (response.success && response.data != null) {
        final bookingEntities = response.data!
            .map((dto) => BookingMapper.dtoToEntity(dto))
            .toList();
            
        return ApiResponse.success(
          data: bookingEntities,
          message: response.message,
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to get passenger bookings',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error getting passenger bookings: $e',
      );
    }
  }

  @override
  Future<ApiResponse<BookingEntity>> getBookingDetail(int bookingId) async {
    try {
      final response = await _bookingService.getBookingDetail(bookingId.toString());
      
      if (response.success && response.data != null) {
        final bookingEntity = BookingMapper.dtoToEntity(response.data!);
        
        return ApiResponse.success(
          data: bookingEntity,
          message: response.message,
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to get booking detail',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error getting booking detail: $e',
      );
    }
  }

  @override
  Future<ApiResponse<BookingEntity>> createBooking(int rideId, int seats) async {
    try {
      final response = await _bookingService.createBooking(rideId.toString(), seats);
      
      if (response.success && response.data != null) {
        final bookingEntity = BookingMapper.dtoToEntity(response.data!);
        
        return ApiResponse.success(
          data: bookingEntity,
          message: response.message,
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to create booking',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error creating booking: $e',
      );
    }
  }

  @override
  Future<ApiResponse<BookingEntity>> passengerConfirmRide(int rideId) async {
    try {
      final response = await _bookingService.passengerConfirmRide(rideId.toString());
      
      if (response.success && response.data != null) {
        final bookingEntity = BookingMapper.dtoToEntity(response.data!);
        
        return ApiResponse.success(
          data: bookingEntity,
          message: response.message,
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to confirm ride',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error confirming ride: $e',
      );
    }
  }

  @override
  Future<ApiResponse<BookingEntity>> cancelBooking(int rideId) async {
    try {
      final response = await _bookingService.cancelBooking(rideId.toString());
      
      if (response.success && response.data != null) {
        final bookingEntity = BookingMapper.dtoToEntity(response.data!);
        
        return ApiResponse.success(
          data: bookingEntity,
          message: response.message,
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to cancel booking',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error canceling booking: $e',
      );
    }
  }

  @override
  Future<ApiResponse<List<BookingEntity>>> getDriverBookings() async {
    try {
      final response = await _bookingService.getDriverBookings();
      
      if (response.success && response.data != null) {
        final bookingEntities = response.data!
            .map((dto) => BookingMapper.dtoToEntity(dto))
            .toList();
            
        return ApiResponse.success(
          data: bookingEntities,
          message: response.message,
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to get driver bookings',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error getting driver bookings: $e',
      );
    }
  }

  @override
  Future<ApiResponse<BookingEntity>> acceptBooking(int bookingId) async {
    try {
      final response = await _bookingService.acceptBooking(bookingId.toString());
      
      if (response.success && response.data != null) {
        final bookingEntity = BookingMapper.dtoToEntity(response.data!);
        
        return ApiResponse.success(
          data: bookingEntity,
          message: response.message,
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to accept booking',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error accepting booking: $e',
      );
    }
  }

  @override
  Future<ApiResponse<BookingEntity>> rejectBooking(int bookingId) async {
    try {
      final response = await _bookingService.rejectBooking(bookingId.toString());
      
      if (response.success && response.data != null) {
        final bookingEntity = BookingMapper.dtoToEntity(response.data!);
        
        return ApiResponse.success(
          data: bookingEntity,
          message: response.message,
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to reject booking',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error rejecting booking: $e',
      );
    }
  }

  @override
  Future<ApiResponse<BookingEntity>> completeRide(int rideId) async {
    try {
      final response = await _bookingService.completeRide(rideId.toString());
      
      if (response.success && response.data != null) {
        final bookingEntity = BookingMapper.dtoToEntity(response.data!);
        
        return ApiResponse.success(
          data: bookingEntity,
          message: response.message,
        );
      } else {
        return ApiResponse.error(
          message: response.message ?? 'Failed to complete ride',
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Error completing ride: $e',
      );
    }
  }
}