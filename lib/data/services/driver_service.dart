import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/auth/dtos/driver_dto.dart';
import 'package:sharexev2/data/models/ride/dtos/ride_request_dto.dart';
import 'package:sharexev2/data/models/booking/dtos/booking_dto.dart';
import 'package:sharexev2/config/app_config.dart';

class DriverService {
  final ApiClient _api;

  DriverService(this._api);

  /// Lấy thông tin cá nhân tài xế
  /// GET /api/driver/profile
  Future<ApiResponse<DriverDto>> getProfile() async {
    final res = await _api.client.get(AppConfig.I.driver.profile);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => DriverDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Lấy danh sách chuyến đi của tài xế
  /// GET /api/driver/my-rides
  Future<ApiResponse<List<RideRequestDTO>>> getMyRides() async {
    final res = await _api.client.get(AppConfig.I.driver.myRides);
    return ApiResponse.listFromJson<RideRequestDTO>(
      res.data as Map<String, dynamic>,
      (json) => RideRequestDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Lấy danh sách chuyến đi của tài xế (alias for getMyRides)
  /// GET /api/driver/my-rides
  Future<ApiResponse<List<RideRequestDTO>>> getDriverRides() async {
    return getMyRides();
  }

  /// Lấy danh sách đặt chỗ của tài xế
  /// GET /api/driver/bookings
  Future<ApiResponse<List<BookingDto>>> getDriverBookings() async {
    final res = await _api.client.get(AppConfig.I.driver.bookings);
    return ApiResponse.listFromJson<BookingDto>(
      res.data as Map<String, dynamic>,
      (json) => BookingDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Chấp nhận đặt chỗ
  /// PUT /api/driver/accept/{bookingId}
  Future<ApiResponse<String>> acceptBooking(int bookingId) async {
    final res = await _api.client.put(
      "${AppConfig.I.driver.acceptBooking}$bookingId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => json.toString(),
    );
  }

  /// Từ chối đặt chỗ
  /// PUT /api/driver/reject/{bookingId}
  Future<ApiResponse<String>> rejectBooking(int bookingId) async {
    final res = await _api.client.put(
      "${AppConfig.I.driver.rejectBooking}$bookingId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => json.toString(),
    );
  }

  /// Xác nhận hoàn thành chuyến đi
  /// PUT /api/driver/complete/{rideId}
  Future<ApiResponse<String>> completeRide(int rideId) async {
    final res = await _api.client.put(
      "${AppConfig.I.driver.completeRide}$rideId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => json.toString(),
    );
  }
}
