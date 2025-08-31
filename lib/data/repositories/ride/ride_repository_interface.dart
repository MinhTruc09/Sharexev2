import '../../models/ride/entities/ride_entity.dart';
import '../../../core/network/api_response.dart';

/// Interface cho Ride Repository
abstract class RideRepositoryInterface {
  /// Tạo chuyến đi mới
  Future<ApiResponse<RideEntity>> createRide(RideEntity ride);

  /// Cập nhật chuyến đi
  Future<ApiResponse<RideEntity>> updateRide(int rideId, RideEntity ride);

  /// Hủy chuyến đi
  Future<ApiResponse<void>> cancelRide(int rideId);

  /// Lấy chi tiết chuyến đi theo ID
  Future<ApiResponse<RideEntity>> getRideById(int rideId);

  /// Tìm kiếm chuyến đi
  Future<ApiResponse<List<RideEntity>>> searchRides({
    String? departure,
    String? destination,
    String? startTime,
    int? seats,
  });

  /// Lấy danh sách chuyến đi đang hoạt động
  Future<ApiResponse<List<RideEntity>>> getAvailableRides();

  /// Lấy tất cả chuyến đi
  Future<ApiResponse<List<RideEntity>>> getAllRides();
}
