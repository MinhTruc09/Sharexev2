import '../../data/models/auth/entities/driver_entity.dart';
import '../../data/models/ride/entities/ride_entity.dart';
import '../../data/models/booking/entities/booking_entity.dart';
import '../../data/repositories/user/user_repository_interface.dart';
import '../../data/repositories/ride/ride_repository_interface.dart';
import '../../data/repositories/booking/booking_repository_interface.dart';
import '../../core/network/api_response.dart';

/// Use Cases cho Driver - Business Logic Layer
class DriverUseCases {
  final DriverRepositoryInterface _driverRepository;
  final RideRepositoryInterface _rideRepository;
  final BookingRepositoryInterface _bookingRepository;

  DriverUseCases(
    this._driverRepository,
    this._rideRepository,
    this._bookingRepository,
  );

  /// Lấy thông tin profile tài xế
  Future<ApiResponse<DriverEntity>> getProfile() async {
    return await _driverRepository.getProfile();
  }

  /// Lấy danh sách chuyến đi của tài xế
  Future<ApiResponse<List<RideEntity>>> getMyRides() async {
    try {
      // This would typically call a driver-specific rides endpoint
      // For now, we'll use the general rides endpoint
      final response = await _rideRepository.getAllRides();
      
      if (!response.success || response.data == null) {
        return response;
      }

      // Filter rides by current driver (would be done on backend)
      // For now, return all rides
      return response;
    } catch (e) {
      return ApiResponse<List<RideEntity>>(
        message: 'Lỗi lấy danh sách chuyến đi: $e',
        statusCode: 500,
        data: [],
        success: false,
      );
    }
  }

  /// Lấy danh sách đặt chỗ của tài xế
  Future<ApiResponse<List<BookingEntity>>> getDriverBookings() async {
    try {
      // This would call driver-specific bookings endpoint
      return await _bookingRepository.getDriverBookings();
    } catch (e) {
      return ApiResponse<List<BookingEntity>>(
        message: 'Lỗi lấy danh sách đặt chỗ: $e',
        statusCode: 500,
        data: [],
        success: false,
      );
    }
  }

  /// Chấp nhận đặt chỗ với business validation
  Future<ApiResponse<BookingEntity>> acceptBooking(int bookingId) async {
    try {
      // Business validation: Check if booking is still pending
      final bookingResponse = await _bookingRepository.getBookingDetail(bookingId);
      
      if (!bookingResponse.success || bookingResponse.data == null) {
        return ApiResponse<BookingEntity>(
          message: 'Không tìm thấy đặt chỗ',
          statusCode: 404,
          data: null,
          success: false,
        );
      }

      final booking = bookingResponse.data!;

      // Business rule: Can only accept pending bookings
      if (booking.status != BookingStatus.pending) {
        return ApiResponse<BookingEntity>(
          message: 'Chỉ có thể chấp nhận đặt chỗ đang chờ xử lý',
          statusCode: 400,
          data: null,
          success: false,
        );
      }

      // Business rule: Check if ride is still available
      final rideResponse = await _rideRepository.getRideById(booking.rideId);
      if (!rideResponse.success || rideResponse.data == null) {
        return ApiResponse<BookingEntity>(
          message: 'Chuyến đi không còn khả dụng',
          statusCode: 400,
          data: null,
          success: false,
        );
      }

      final ride = rideResponse.data!;
      if (!ride.hasAvailableSeats) {
        return ApiResponse<BookingEntity>(
          message: 'Chuyến đi đã hết chỗ',
          statusCode: 400,
          data: null,
          success: false,
        );
      }

      return await _bookingRepository.acceptBooking(bookingId);
    } catch (e) {
      return ApiResponse<BookingEntity>(
        message: 'Lỗi chấp nhận đặt chỗ: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  /// Từ chối đặt chỗ với business validation
  Future<ApiResponse<BookingEntity>> rejectBooking(int bookingId) async {
    try {
      // Business validation: Check if booking can be rejected
      final bookingResponse = await _bookingRepository.getBookingDetail(bookingId);
      
      if (!bookingResponse.success || bookingResponse.data == null) {
        return ApiResponse<BookingEntity>(
          message: 'Không tìm thấy đặt chỗ',
          statusCode: 404,
          data: null,
          success: false,
        );
      }

      final booking = bookingResponse.data!;

      // Business rule: Can only reject pending or accepted bookings
      if (booking.status != BookingStatus.pending && 
          booking.status != BookingStatus.accepted) {
        return ApiResponse<BookingEntity>(
          message: 'Không thể từ chối đặt chỗ ở trạng thái này',
          statusCode: 400,
          data: null,
          success: false,
        );
      }

      return await _bookingRepository.rejectBooking(bookingId);
    } catch (e) {
      return ApiResponse<BookingEntity>(
        message: 'Lỗi từ chối đặt chỗ: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  /// Hoàn thành chuyến đi với business validation
  Future<ApiResponse<BookingEntity>> completeRide(int rideId) async {
    try {
      // Business validation: Check if ride can be completed
      final rideResponse = await _rideRepository.getRideById(rideId);
      
      if (!rideResponse.success || rideResponse.data == null) {
        return ApiResponse<BookingEntity>(
          message: 'Không tìm thấy chuyến đi',
          statusCode: 404,
          data: null,
          success: false,
        );
      }

      final ride = rideResponse.data!;

      // Business rule: Can only complete rides that are in progress
      if (ride.status != RideStatus.inProgress) {
        return ApiResponse<BookingEntity>(
          message: 'Chỉ có thể hoàn thành chuyến đi đang diễn ra',
          statusCode: 400,
          data: null,
          success: false,
        );
      }

      return await _bookingRepository.completeRide(rideId);
    } catch (e) {
      return ApiResponse<BookingEntity>(
        message: 'Lỗi hoàn thành chuyến đi: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

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
  }) async {
    try {
      // Get driver profile for validation
      final profileResponse = await getProfile();
      
      if (!profileResponse.success || profileResponse.data == null) {
        return ApiResponse<RideEntity>(
          message: 'Không thể lấy thông tin tài xế',
          statusCode: 400,
          data: null,
          success: false,
        );
      }

      final driver = profileResponse.data!;

      // Business validation: Driver must be approved
      if (!driver.isApproved) {
        return ApiResponse<RideEntity>(
          message: 'Tài xế chưa được duyệt, không thể tạo chuyến đi',
          statusCode: 403,
          data: null,
          success: false,
        );
      }

      // Business validation: Total seats cannot exceed vehicle capacity
      if (totalSeats > driver.numberOfSeats) {
        return ApiResponse<RideEntity>(
          message: 'Số ghế không được vượt quá sức chứa xe (${driver.numberOfSeats} ghế)',
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
        driverName: driver.fullName,
        driverEmail: driver.email,
      );

      return await _rideRepository.createRide(ride);
    } catch (e) {
      return ApiResponse<RideEntity>(
        message: 'Lỗi tạo chuyến đi: $e',
        statusCode: 500,
        data: null,
        success: false,
      );
    }
  }

  /// Lấy thống kê tài xế
  Map<String, dynamic> calculateDriverStats({
    required List<RideEntity> rides,
    required List<BookingEntity> bookings,
  }) {
    final totalRides = rides.length;
    final completedRides = rides.where((r) => r.isCompleted).length;
    final totalBookings = bookings.length;
    final acceptedBookings = bookings.where((b) => b.isAccepted).length;
    
    final totalEarnings = bookings
        .where((b) => b.isCompleted)
        .fold<double>(0.0, (sum, booking) => sum + booking.totalPrice);

    return {
      'totalRides': totalRides,
      'completedRides': completedRides,
      'totalBookings': totalBookings,
      'acceptedBookings': acceptedBookings,
      'totalEarnings': totalEarnings,
      'completionRate': totalRides > 0 ? (completedRides / totalRides * 100).round() : 0,
      'acceptanceRate': totalBookings > 0 ? (acceptedBookings / totalBookings * 100).round() : 0,
      'averageEarningsPerRide': completedRides > 0 ? totalEarnings / completedRides : 0.0,
    };
  }
}
