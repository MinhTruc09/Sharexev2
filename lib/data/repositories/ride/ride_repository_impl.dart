import 'ride_repository_interface.dart';
import '../../models/ride/entities/ride_entity.dart';
import '../../models/ride/mappers/ride_mapper.dart';
import '../../services/ride_service.dart';
import '../../services/driver_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/network/api_response.dart';

/// Implementation của Ride Repository
class RideRepositoryImpl implements RideRepositoryInterface {
  final RideService _rideService;
  final DriverService _driverService;

  RideRepositoryImpl(this._rideService, this._driverService);

  /// Factory constructor sử dụng ServiceRegistry
  factory RideRepositoryImpl.fromRegistry() {
    return RideRepositoryImpl(
      ServiceLocator.get<RideService>(),
      ServiceLocator.get<DriverService>(),
    );
  }

  @override
  Future<ApiResponse<RideEntity>> createRide(RideEntity ride) async {
    try {
      // Convert entity to DTO
      final rideDto = RideMapper.toDto(ride);

      // Call service
      final response = await _rideService.createRide(rideDto);

      // Convert DTO back to entity
      final entity =
          response.data != null ? RideMapper.fromDto(response.data!) : null;

      return ApiResponse<RideEntity>(
        message: response.message,
        statusCode: response.statusCode,
        data: entity,
        success: response.success,
      );
    } catch (e) {
      return ApiResponse<RideEntity>(
        message: 'Lỗi tạo chuyến đi: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  @override
  Future<ApiResponse<RideEntity>> updateRide(
    int rideId,
    RideEntity ride,
  ) async {
    try {
      final rideDto = RideMapper.toDto(ride);
      final response = await _rideService.updateRide(rideId, rideDto);

      final entity =
          response.data != null ? RideMapper.fromDto(response.data!) : null;

      return ApiResponse<RideEntity>(
        message: response.message,
        statusCode: response.statusCode,
        data: entity,
        success: response.success,
      );
    } catch (e) {
      return ApiResponse<RideEntity>(
        message: 'Lỗi cập nhật chuyến đi: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  @override
  Future<ApiResponse<void>> cancelRide(int rideId) async {
    try {
      final response = await _rideService.cancelRide(rideId);

      return ApiResponse<void>(
        message: response.message,
        statusCode: response.statusCode,
        data: null,
        success: response.success,
      );
    } catch (e) {
      return ApiResponse<void>(
        message: 'Lỗi hủy chuyến đi: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  @override
  Future<ApiResponse<RideEntity>> getRideById(int rideId) async {
    try {
      final response = await _rideService.getRideById(rideId);

      final entity =
          response.data != null ? RideMapper.fromDto(response.data!) : null;

      return ApiResponse<RideEntity>(
        message: response.message,
        statusCode: response.statusCode,
        data: entity,
        success: response.success,
      );
    } catch (e) {
      return ApiResponse<RideEntity>(
        message: 'Lỗi lấy thông tin chuyến đi: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  @override
  Future<List<RideEntity>> searchRides({
    String? departure,
    String? destination,
    DateTime? startTime,
    int? seats,
  }) async {
    try {
      final response = await _rideService.searchRides(
        departure: departure,
        destination: destination,
        startTime:
            startTime?.toIso8601String().split(
              'T',
            )[0], // Convert to date string
        seats: seats,
      );

      if (response.success && response.data != null) {
        return RideMapper.fromDtoList(response.data!);
      } else {
        throw Exception(response.message ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Lỗi tìm kiếm chuyến đi: $e');
    }
  }

  @override
  Future<List<RideEntity>> getAvailableRides() async {
    try {
      final response = await _rideService.getAvailableRides();

      if (response.success && response.data != null) {
        return RideMapper.fromDtoList(response.data!);
      } else {
        throw Exception(response.message ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Lỗi lấy danh sách chuyến đi: $e');
    }
  }

  @override
  Future<ApiResponse<List<RideEntity>>> getAllRides() async {
    try {
      final response = await _rideService.getAllRides();

      final entities =
          response.data != null
              ? RideMapper.fromDtoList(response.data!)
              : <RideEntity>[];

      return ApiResponse<List<RideEntity>>(
        message: response.message,
        statusCode: response.statusCode,
        data: entities,
        success: response.success,
      );
    } catch (e) {
      return ApiResponse<List<RideEntity>>(
        message: 'Lỗi lấy tất cả chuyến đi: $e',
        statusCode: 500,
        data: <RideEntity>[],
        success: false,
      );
    }
  }

  @override
  Future<ApiResponse<List<RideEntity>>> getDriverRides() async {
    try {
      // Use DriverService to get driver-specific rides
      final response = await _driverService.getDriverRides();

      // Convert DTOs to entities
      final entities = response.data != null
          ? RideMapper.fromDtoList(response.data!)
          : <RideEntity>[];

      return ApiResponse<List<RideEntity>>(
        message: response.message,
        statusCode: response.statusCode,
        data: entities,
        success: response.success,
      );
    } catch (e) {
      return ApiResponse<List<RideEntity>>(
        message: 'Lỗi lấy chuyến đi của tài xế: $e',
        statusCode: 500,
        data: <RideEntity>[],
        success: false,
      );
    }
  }
}
