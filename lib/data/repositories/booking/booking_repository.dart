import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/booking/entities/booking.dart';

/// Interface cho BookingRepository
abstract class BookingRepository {
  /// Lấy danh sách bookings của passenger
  Future<ApiResponse<List<Booking>>> getPassengerBookings();

  /// Lấy chi tiết booking theo ID
  Future<ApiResponse<Booking>> getBookingDetail(String bookingId);

  /// Tạo booking mới
  Future<ApiResponse<Booking>> createBooking(String rideId, int seats);

  /// Passenger xác nhận ride
  Future<ApiResponse<Booking>> passengerConfirmRide(String rideId);

  /// Passenger hủy booking
  Future<ApiResponse<Booking>> cancelBooking(String rideId);

  /// Driver lấy danh sách bookings
  Future<ApiResponse<List<Booking>>> getDriverBookings();

  /// Driver chấp nhận booking
  Future<ApiResponse<Booking>> acceptBooking(String bookingId);

  /// Driver từ chối booking
  Future<ApiResponse<Booking>> rejectBooking(String bookingId);

  /// Driver hoàn thành ride
  Future<ApiResponse<Booking>> completeRide(String rideId);
}
