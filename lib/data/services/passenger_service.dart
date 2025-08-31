import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/auth/dtos/user_dto.dart';
import 'package:sharexev2/data/models/booking/dtos/booking_dto.dart';
import 'package:sharexev2/config/app_config.dart';

class PassengerService {
  final ApiClient _api;

  PassengerService(this._api);

  /// Lấy thông tin cá nhân hành khách
  /// GET /api/passenger/profile
  Future<ApiResponse<UserDto>> getProfile() async {
    final res = await _api.client.get(AppConfig.I.passenger.profile);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => UserDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Lấy danh sách đặt chỗ của hành khách
  /// GET /api/passenger/bookings
  Future<ApiResponse<List<BookingDto>>> getPassengerBookings() async {
    final res = await _api.client.get(AppConfig.I.passenger.bookings);
    return ApiResponse.listFromJson<BookingDto>(
      res.data as Map<String, dynamic>,
      (json) => BookingDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Lấy chi tiết đặt chỗ
  /// GET /api/passenger/booking/{bookingId}
  Future<ApiResponse<BookingDto>> getBookingDetail(int bookingId) async {
    final res = await _api.client.get(
      "${AppConfig.I.passenger.bookingDetail}$bookingId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => BookingDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Đặt chỗ cho chuyến đi
  /// POST /api/passenger/booking/{rideId}
  Future<ApiResponse<BookingDto>> createBooking(
    int rideId,
    int seats,
  ) async {
    final res = await _api.client.post(
      "${AppConfig.I.passenger.createBooking}$rideId",
      queryParameters: {"seats": seats},
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => BookingDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Xác nhận hoàn thành chuyến đi
  /// PUT /api/passenger/passenger-confirm/{rideId}
  Future<ApiResponse<BookingDto>> confirmRide(int rideId) async {
    final res = await _api.client.put(
      "${AppConfig.I.passenger.confirmRide}$rideId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => BookingDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Hủy đặt chỗ
  /// PUT /api/passenger/cancel-bookings/{rideId}
  Future<ApiResponse<BookingDto>> cancelBooking(int rideId) async {
    final res = await _api.client.put(
      "${AppConfig.I.passenger.cancelBooking}$rideId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => BookingDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
