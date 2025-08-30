import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/booking/dtos/booking_dto.dart';
import 'package:sharexev2/config/app_config.dart';

class BookingService {
  final ApiClient _api;

  BookingService(this._api);

  /// Lấy danh sách booking của passenger
  Future<ApiResponse<List<BookingDTO>>> getPassengerBookings() async {
    final res = await _api.client.get(AppConfig.I.passenger.bookings);
    return ApiResponse.listFromJson<BookingDTO>(
      res.data as Map<String, dynamic>,
      (json) => BookingDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Lấy chi tiết booking theo ID
  Future<ApiResponse<BookingDTO>> getBookingDetail(String bookingId) async {
    final res = await _api.client.get(
      "${AppConfig.I.passenger.bookingDetail}$bookingId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => BookingDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Tạo booking mới
  Future<ApiResponse<BookingDTO>> createBooking(
    String rideId,
    int seats,
  ) async {
    final res = await _api.client.post(
      "${AppConfig.I.passenger.createBooking}$rideId",
      queryParameters: {"seats": seats},
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => BookingDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Passenger xác nhận ride
  Future<ApiResponse<BookingDTO>> passengerConfirmRide(String rideId) async {
    final res = await _api.client.put(
      "${AppConfig.I.passenger.confirmRide}$rideId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => BookingDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Passenger hủy booking
  Future<ApiResponse<BookingDTO>> cancelBooking(String rideId) async {
    final res = await _api.client.put(
      "${AppConfig.I.passenger.cancelBooking}$rideId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => BookingDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Driver lấy danh sách bookings
  Future<ApiResponse<List<BookingDTO>>> getDriverBookings() async {
    final res = await _api.client.get(AppConfig.I.driver.bookings);
    return ApiResponse.listFromJson<BookingDTO>(
      res.data as Map<String, dynamic>,
      (json) => BookingDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Driver chấp nhận booking
  Future<ApiResponse<BookingDTO>> acceptBooking(String bookingId) async {
    final res = await _api.client.put(
      "${AppConfig.I.driver.acceptBooking}$bookingId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => BookingDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Driver từ chối booking
  Future<ApiResponse<BookingDTO>> rejectBooking(String bookingId) async {
    final res = await _api.client.put(
      "${AppConfig.I.driver.rejectBooking}$bookingId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => BookingDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Driver hoàn thành ride
  Future<ApiResponse<BookingDTO>> completeRide(String rideId) async {
    final res = await _api.client.put(
      "${AppConfig.I.driver.completeRide}$rideId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => BookingDTO.fromJson(json as Map<String, dynamic>),
    );
  }
}
