import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/ride/dtos/ride_request_dto.dart';
import 'package:sharexev2/config/app_config.dart';

class RideService {
  final ApiClient _api;

  RideService(this._api);

  /// Tạo chuyến đi mới
  /// POST /api/ride
  Future<ApiResponse<RideRequestDTO>> createRide(RideRequestDTO request) async {
    final res = await _api.client.post(
      AppConfig.I.rides.create,
      data: request.toJson(),
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => RideRequestDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Cập nhật chuyến đi
  /// PUT /api/ride/update/{id}
  Future<ApiResponse<RideRequestDTO>> updateRide(
    int rideId,
    RideRequestDTO request,
  ) async {
    final res = await _api.client.put(
      "${AppConfig.I.rides.update}$rideId",
      data: request.toJson(),
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => RideRequestDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Hủy chuyến đi
  /// PUT /api/ride/cancel/{id}
  Future<ApiResponse<dynamic>> cancelRide(int rideId) async {
    final res = await _api.client.put(
      "${AppConfig.I.rides.cancel}$rideId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => json,
    );
  }

  /// Lấy chi tiết chuyến đi theo ID
  /// GET /api/ride/{id}
  Future<ApiResponse<RideRequestDTO>> getRideById(int rideId) async {
    final res = await _api.client.get(
      "${AppConfig.I.rides.getRide}$rideId",
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (json) => RideRequestDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Tìm kiếm chuyến đi
  /// GET /api/ride/search
  Future<ApiResponse<List<RideRequestDTO>>> searchRides({
    String? departure,
    String? destination,
    String? startTime,
    int? seats,
  }) async {
    final queryParams = <String, dynamic>{};
    if (departure != null) queryParams['departure'] = departure;
    if (destination != null) queryParams['destination'] = destination;
    if (startTime != null) queryParams['startTime'] = startTime;
    if (seats != null) queryParams['seats'] = seats;

    final res = await _api.client.get(
      AppConfig.I.rides.search,
      queryParameters: queryParams,
    );
    return ApiResponse.listFromJson<RideRequestDTO>(
      res.data as Map<String, dynamic>,
      (json) => RideRequestDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Lấy danh sách chuyến đi đang hoạt động
  /// GET /api/ride/available
  Future<ApiResponse<List<RideRequestDTO>>> getAvailableRides() async {
    final res = await _api.client.get(AppConfig.I.rides.available);
    return ApiResponse.listFromJson<RideRequestDTO>(
      res.data as Map<String, dynamic>,
      (json) => RideRequestDTO.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Lấy tất cả chuyến đi
  /// GET /api/ride/all-rides
  Future<ApiResponse<List<RideRequestDTO>>> getAllRides() async {
    final res = await _api.client.get(AppConfig.I.rides.all);
    return ApiResponse.listFromJson<RideRequestDTO>(
      res.data as Map<String, dynamic>,
      (json) => RideRequestDTO.fromJson(json as Map<String, dynamic>),
    );
  }
}
