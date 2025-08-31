import '../../data/models/ride/entities/ride_entity.dart';
import '../../data/repositories/ride/ride_repository_interface.dart';
import '../../core/network/api_response.dart';

/// Use Cases cho Ride - Business Logic Layer
class RideUseCases {
  final RideRepositoryInterface _rideRepository;

  RideUseCases(this._rideRepository);

  /// Tạo chuyến đi mới với validation
  Future<ApiResponse<RideEntity>> createRide({
    required String departure,
    required String destination,
    required double startLat,
    required double startLng,
    required String startAddress,
    required String startWard,
    required String startDistrict,
    required String startProvince,
    required double endLat,
    required double endLng,
    required String endAddress,
    required String endWard,
    required String endDistrict,
    required String endProvince,
    required DateTime startTime,
    required double pricePerSeat,
    required int totalSeats,
    required String driverName,
    required String driverEmail,
  }) async {
    // Business validation
    final validationErrors = _validateRideCreation(
      departure: departure,
      destination: destination,
      startTime: startTime,
      pricePerSeat: pricePerSeat,
      totalSeats: totalSeats,
    );

    if (validationErrors.isNotEmpty) {
      return ApiResponse<RideEntity>(
        message: validationErrors.first,
        statusCode: 400,
        data: null,
        success: false,
      );
    }

    final ride = RideEntity(
      id: 0, // Will be set by backend
      departure: departure,
      destination: destination,
      startLat: startLat,
      startLng: startLng,
      startAddress: startAddress,
      startWard: startWard,
      startDistrict: startDistrict,
      startProvince: startProvince,
      endLat: endLat,
      endLng: endLng,
      endAddress: endAddress,
      endWard: endWard,
      endDistrict: endDistrict,
      endProvince: endProvince,
      startTime: startTime,
      pricePerSeat: pricePerSeat,
      totalSeat: totalSeats,
      availableSeats: totalSeats,
      status: RideStatus.active,
      driverName: driverName,
      driverEmail: driverEmail,
    );

    return await _rideRepository.createRide(ride);
  }

  /// Tìm kiếm chuyến đi với filters
  Future<ApiResponse<List<RideEntity>>> searchRides({
    String? departure,
    String? destination,
    DateTime? startDate,
    int? minSeats,
    double? maxPrice,
  }) async {
    final response = await _rideRepository.searchRides(
      departure: departure,
      destination: destination,
      startTime: startDate?.toIso8601String(),
      seats: minSeats,
    );

    if (!response.success || response.data == null) {
      return response;
    }

    // Apply additional business filters
    var filteredRides = response.data!;

    // Filter by max price
    if (maxPrice != null) {
      filteredRides = filteredRides
          .where((ride) => ride.pricePerSeat <= maxPrice)
          .toList();
    }

    // Filter by available seats
    if (minSeats != null) {
      filteredRides = filteredRides
          .where((ride) => (ride.availableSeats ?? 0) >= minSeats)
          .toList();
    }

    // Sort by start time (earliest first)
    filteredRides.sort((a, b) => a.startTime.compareTo(b.startTime));

    return ApiResponse<List<RideEntity>>(
      message: response.message,
      statusCode: response.statusCode,
      data: filteredRides,
      success: response.success,
    );
  }

  /// Lấy chuyến đi phù hợp cho hành khách
  Future<ApiResponse<List<RideEntity>>> getRecommendedRides({
    required String userLocation,
    String? preferredDestination,
    int? requiredSeats,
  }) async {
    final response = await _rideRepository.getAvailableRides();

    if (!response.success || response.data == null) {
      return response;
    }

    var rides = response.data!;

    // Business logic for recommendations
    // 1. Filter by available seats
    if (requiredSeats != null) {
      rides = rides
          .where((ride) => (ride.availableSeats ?? 0) >= requiredSeats)
          .toList();
    }

    // 2. Filter by preferred destination
    if (preferredDestination != null) {
      rides = rides
          .where((ride) => ride.destination
              .toLowerCase()
              .contains(preferredDestination.toLowerCase()))
          .toList();
    }

    // 3. Sort by price (cheapest first)
    rides.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));

    return ApiResponse<List<RideEntity>>(
      message: 'Tìm thấy ${rides.length} chuyến đi phù hợp',
      statusCode: 200,
      data: rides,
      success: true,
    );
  }

  /// Hủy chuyến đi với business rules
  Future<ApiResponse<void>> cancelRide(int rideId) async {
    // Get ride details first
    final rideResponse = await _rideRepository.getRideById(rideId);
    
    if (!rideResponse.success || rideResponse.data == null) {
      return ApiResponse<void>(
        message: 'Không tìm thấy chuyến đi',
        statusCode: 404,
        data: null,
        success: false,
      );
    }

    final ride = rideResponse.data!;

    // Business rule: Cannot cancel if ride is in progress or completed
    if (ride.status == RideStatus.inProgress || 
        ride.status == RideStatus.completed) {
      return ApiResponse<void>(
        message: 'Không thể hủy chuyến đi đang diễn ra hoặc đã hoàn thành',
        statusCode: 400,
        data: null,
        success: false,
      );
    }

    // Business rule: Cannot cancel within 30 minutes of start time
    final now = DateTime.now();
    final timeDifference = ride.startTime.difference(now);
    
    if (timeDifference.inMinutes < 30) {
      return ApiResponse<void>(
        message: 'Không thể hủy chuyến đi trong vòng 30 phút trước giờ khởi hành',
        statusCode: 400,
        data: null,
        success: false,
      );
    }

    return await _rideRepository.cancelRide(rideId);
  }

  /// Validation cho việc tạo chuyến đi
  List<String> _validateRideCreation({
    required String departure,
    required String destination,
    required DateTime startTime,
    required double pricePerSeat,
    required int totalSeats,
  }) {
    final errors = <String>[];

    if (departure.trim().isEmpty) {
      errors.add('Điểm đi không được để trống');
    }

    if (destination.trim().isEmpty) {
      errors.add('Điểm đến không được để trống');
    }

    if (departure.toLowerCase() == destination.toLowerCase()) {
      errors.add('Điểm đi và điểm đến không được giống nhau');
    }

    final now = DateTime.now();
    if (startTime.isBefore(now.add(const Duration(hours: 1)))) {
      errors.add('Thời gian khởi hành phải sau ít nhất 1 giờ');
    }

    if (pricePerSeat <= 0) {
      errors.add('Giá vé phải lớn hơn 0');
    }

    if (pricePerSeat > 1000000) {
      errors.add('Giá vé không được vượt quá 1,000,000đ');
    }

    if (totalSeats <= 0 || totalSeats > 8) {
      errors.add('Số ghế phải từ 1 đến 8');
    }

    return errors;
  }
}
