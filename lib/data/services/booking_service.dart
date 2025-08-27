import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/booking/booking_dto.dart';
import 'package:sharexev2/config/app_config.dart';

class BookingService {
  final ApiClient _api = ApiClient();

  /// Lấy danh sách booking của passenger
  Future<ApiResponse<List<BookingDTO>>> getPassengerBookings() async {
    final res = await _api.client.get(AppConfig.I.passenger.bookings);
    return ApiResponse.listFromJson<BookingDTO>(
      res.data as Map<String, dynamic>,
      (e) => BookingDTO.fromJson(e as Map<String, dynamic>),
    );
  }

  /// Lấy chi tiết booking theo ID
  Future<ApiResponse<BookingDTO>> getBookingDetail(String bookingId) async {
    final res = await _api.client.get(
      '${AppConfig.I.passenger.bookingDetail}$bookingId',
    );
    return ApiResponse<BookingDTO>.fromJson(
      res.data as Map<String, dynamic>,
      (data) => BookingDTO.fromJson(data),
    );
  }

  /// Tạo booking mới
  Future<ApiResponse<BookingDTO>> createBooking(
    String rideId,
    int seats,
  ) async {
    final res = await _api.client.post(
      '${AppConfig.I.passenger.createBooking}$rideId',
      queryParameters: {'seats': seats},
    );
    return ApiResponse<BookingDTO>.fromJson(
      res.data as Map<String, dynamic>,
      (data) => BookingDTO.fromJson(data),
    );
  }

  /// Passenger xác nhận ride
  Future<ApiResponse<BookingDTO>> passengerConfirmRide(String rideId) async {
    final res = await _api.client.put(
      '${AppConfig.I.passenger.confirmRide}$rideId',
    );
    return ApiResponse<BookingDTO>.fromJson(
      res.data as Map<String, dynamic>,
      (data) => BookingDTO.fromJson(data),
    );
  }

  /// Passenger hủy booking
  Future<ApiResponse<BookingDTO>> cancelBooking(String rideId) async {
    final res = await _api.client.put(
      '${AppConfig.I.passenger.cancelBooking}$rideId',
    );
    return ApiResponse<BookingDTO>.fromJson(
      res.data as Map<String, dynamic>,
      (data) => BookingDTO.fromJson(data),
    );
  }

  /// Driver lấy danh sách bookings
  Future<ApiResponse<List<BookingDTO>>> getDriverBookings() async {
    final res = await _api.client.get(AppConfig.I.driver.bookings);
    return ApiResponse.listFromJson<BookingDTO>(
      res.data as Map<String, dynamic>,
      (e) => BookingDTO.fromJson(e as Map<String, dynamic>),
    );
  }

  /// Driver chấp nhận booking
  Future<ApiResponse<String>> acceptBooking(String bookingId) async {
    final res = await _api.client.put(
      '${AppConfig.I.driver.acceptBooking}$bookingId',
    );
    return ApiResponse<String>.fromJson(
      res.data as Map<String, dynamic>,
      (data) => data.toString(),
    );
  }

  /// Driver từ chối booking
  Future<ApiResponse<String>> rejectBooking(String bookingId) async {
    final res = await _api.client.put(
      '${AppConfig.I.driver.rejectBooking}$bookingId',
    );
    return ApiResponse<String>.fromJson(
      res.data as Map<String, dynamic>,
      (data) => data.toString(),
    );
  }

  /// Driver hoàn thành ride
  Future<ApiResponse<String>> completeRide(String rideId) async {
    final res = await _api.client.put(
      '${AppConfig.I.driver.completeRide}$rideId',
    );
    return ApiResponse<String>.fromJson(
      res.data as Map<String, dynamic>,
      (data) => data.toString(),
    );
  }
}
