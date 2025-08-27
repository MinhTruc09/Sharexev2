import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/booking/booking_dto.dart';

/// Interface cho BookingRepository
abstract class BookingRepository {
  /// Lấy danh sách bookings của passenger
  Future<ApiResponse<List<BookingDTO>>> getPassengerBookings();

  /// Lấy chi tiết booking theo ID
  Future<ApiResponse<BookingDTO>> getBookingDetail(String bookingId);

  /// Tạo booking mới
  Future<ApiResponse<BookingDTO>> createBooking(String rideId, int seats);

  /// Passenger xác nhận ride
  Future<ApiResponse<BookingDTO>> passengerConfirmRide(String rideId);

  /// Passenger hủy booking
  Future<ApiResponse<BookingDTO>> cancelBooking(String rideId);

  /// Driver lấy danh sách bookings
  Future<ApiResponse<List<BookingDTO>>> getDriverBookings();

  /// Driver chấp nhận booking
  Future<ApiResponse<String>> acceptBooking(String bookingId);

  /// Driver từ chối booking
  Future<ApiResponse<String>> rejectBooking(String bookingId);

  /// Driver hoàn thành ride
  Future<ApiResponse<String>> completeRide(String rideId);
}
