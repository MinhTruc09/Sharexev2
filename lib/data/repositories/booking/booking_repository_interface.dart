import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';

/// Interface cho BookingRepository - Clean Architecture
abstract class BookingRepositoryInterface {
  /// Lấy danh sách bookings của passenger
  Future<ApiResponse<List<BookingEntity>>> getPassengerBookings();

  /// Lấy chi tiết booking theo ID
  Future<ApiResponse<BookingEntity>> getBookingDetail(int bookingId);

  /// Tạo booking mới
  Future<ApiResponse<BookingEntity>> createBooking(int rideId, int seats);

  /// Passenger xác nhận ride
  Future<ApiResponse<BookingEntity>> passengerConfirmRide(int rideId);

  /// Passenger hủy booking
  Future<ApiResponse<BookingEntity>> cancelBooking(int rideId);

  /// Driver lấy danh sách bookings
  Future<ApiResponse<List<BookingEntity>>> getDriverBookings();

  /// Driver chấp nhận booking
  Future<ApiResponse<BookingEntity>> acceptBooking(int bookingId);

  /// Driver từ chối booking
  Future<ApiResponse<BookingEntity>> rejectBooking(int bookingId);

  /// Driver hoàn thành ride
  Future<ApiResponse<BookingEntity>> completeRide(int rideId);

  /// Get bookings with pagination
  Future<ApiResponse<List<BookingEntity>>> getBookings({
    int page = 1,
    int limit = 10,
  });
}

/// Legacy interface for backward compatibility
abstract class BookingRepository {
  /// Lấy danh sách bookings của passenger
  Future<ApiResponse<List<BookingEntity>>> getPassengerBookings();

  /// Lấy chi tiết booking theo ID
  Future<ApiResponse<BookingEntity>> getBookingDetail(String bookingId);

  /// Tạo booking mới
  Future<ApiResponse<BookingEntity>> createBooking(String rideId, int seats);

  /// Passenger xác nhận ride
  Future<ApiResponse<BookingEntity>> passengerConfirmRide(String rideId);

  /// Passenger hủy booking
  Future<ApiResponse<BookingEntity>> cancelBooking(String rideId);

  /// Driver lấy danh sách bookings
  Future<ApiResponse<List<BookingEntity>>> getDriverBookings();

  /// Driver chấp nhận booking
  Future<ApiResponse<BookingEntity>> acceptBooking(String bookingId);

  /// Driver từ chối booking
  Future<ApiResponse<BookingEntity>> rejectBooking(String bookingId);

  /// Driver hoàn thành ride
  Future<ApiResponse<BookingEntity>> completeRide(String rideId);
}
