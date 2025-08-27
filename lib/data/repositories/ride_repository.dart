import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/ride.dart';

/// Interface cho RideRepository
abstract class RideRepository {
  /// Lấy danh sách rides có sẵn
  Future<ApiResponse<List<Ride>>> getAvailableRides();

  /// Tìm kiếm rides
  Future<ApiResponse<List<Ride>>> searchRides({
    String? departure,
    String? destination,
    DateTime? startTime,
    int? seats,
  });

  /// Lấy chi tiết ride theo ID
  Future<ApiResponse<Ride>> getRideById(String rideId);

  /// Tạo ride mới
  Future<ApiResponse<Ride>> createRide(Map<String, dynamic> rideData);

  /// Cập nhật ride
  Future<ApiResponse<Ride>> updateRide(String rideId, Map<String, dynamic> rideData);

  /// Hủy ride
  Future<ApiResponse<dynamic>> cancelRide(String rideId);

  /// Lấy lịch sử rides của driver
  Future<ApiResponse<List<Ride>>> getDriverRides();
}
