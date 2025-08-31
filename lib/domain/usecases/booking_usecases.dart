import '../../data/models/booking/entities/booking_entity.dart';
import '../../data/repositories/booking/booking_repository_interface.dart';
import '../../core/network/api_response.dart';

/// Use Cases cho Booking - Business Logic Layer
class BookingUseCases {
  final BookingRepositoryInterface _bookingRepository;

  BookingUseCases(this._bookingRepository);

  /// Đặt chỗ với validation
  Future<ApiResponse<BookingEntity>> createBooking({
    required int rideId,
    required int seats,
    required int passengerId,
  }) async {
    // Business validation
    final validationErrors = _validateBooking(seats: seats);

    if (validationErrors.isNotEmpty) {
      return ApiResponse<BookingEntity>(
        message: validationErrors.first,
        statusCode: 400,
        data: null,
        success: false,
      );
    }

    return await _bookingRepository.createBooking(rideId, seats);
  }

  /// Hủy đặt chỗ với business rules
  Future<ApiResponse<BookingEntity>> cancelBooking({
    required int bookingId,
    required int rideId,
  }) async {
    // Get booking details first
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

    // Business rule: Cannot cancel if already in progress or completed
    if (booking!.status == BookingStatus.inProgress || 
        booking.status == BookingStatus.completed ||
        booking.status == BookingStatus.accepted) {
      return ApiResponse<BookingEntity>(
        message: 'Không thể hủy đặt chỗ đang diễn ra hoặc đã hoàn thành',
        statusCode: 400,
        data: null,
        success: false,
      );
    }

    // Business rule: Cannot cancel within 2 hours of start time
    final now = DateTime.now();
    final startTime = booking!.startTime;
    final timeDifference = startTime.difference(now);
    
    if (timeDifference.inHours < 2) {
      return ApiResponse<BookingEntity>(
        message: 'Không thể hủy đặt chỗ trong vòng 2 giờ trước giờ khởi hành',
        statusCode: 400,
        data: null,
        success: false,
      );
    }

    return await _bookingRepository.cancelBooking(rideId);
  }

  /// Xác nhận hoàn thành chuyến đi
  Future<ApiResponse<BookingEntity>> confirmRideCompletion({
    required int rideId,
    required int passengerId,
  }) async {
    // Business validation: Check if ride is actually completed
    // This would typically involve checking driver confirmation first
    
    return await _bookingRepository.passengerConfirmRide(rideId);
  }

  /// Lấy lịch sử đặt chỗ với filters
  Future<ApiResponse<List<BookingEntity>>> getBookingHistory({
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await _bookingRepository.getPassengerBookings();

    if (!response.success || response.data == null) {
      return response as ApiResponse<List<BookingEntity>>;
    }

    var bookings = response.data!;

    // Apply filters
    if (status != null) {
      bookings = bookings.where((b) => b.status == status).toList();
    }

    if (fromDate != null) {
      bookings = bookings
          .where((b) {
            final createdAt = b!.createdAt;
            return createdAt.isAfter(fromDate);
          })
          .toList();
    }

    if (toDate != null) {
      bookings = bookings
          .where((b) {
            final createdAt = b!.createdAt;
            return createdAt.isBefore(toDate);
          })
          .toList();
    }

    // Sort by creation date (newest first)
    bookings.sort((a, b) => b!.createdAt.compareTo(a!.createdAt));

    return ApiResponse<List<BookingEntity>>(
      message: response.message,
      statusCode: response.statusCode,
      data: bookings,
      success: response.success,
    );
  }

  /// Tính toán thống kê đặt chỗ
  Map<String, dynamic> calculateBookingStats(List<BookingEntity> bookings) {
    if (bookings.isEmpty) {
      return {
        'totalBookings': 0,
        'totalAmount': 0.0,
        'completedBookings': 0,
        'cancelledBookings': 0,
        'averageAmount': 0.0,
      };
    }

    final totalBookings = bookings.length;
    final totalAmount = bookings.fold<double>(
      0.0, 
      (sum, booking) => sum + booking.totalPrice,
    );
    
    final completedBookings = bookings
        .where((b) => b.status == BookingStatus.completed)
        .length;
    
    final cancelledBookings = bookings
        .where((b) => b.status == BookingStatus.cancelled)
        .length;
    
    final averageAmount = totalAmount / totalBookings;

    return {
      'totalBookings': totalBookings,
      'totalAmount': totalAmount,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'averageAmount': averageAmount,
      'completionRate': (completedBookings / totalBookings * 100).round(),
    };
  }

  /// Kiểm tra xem có thể đặt chỗ không
  Future<ApiResponse<bool>> canBookRide({
    required int rideId,
    required int requestedSeats,
    required int passengerId,
  }) async {
    // This would typically check:
    // 1. Ride availability
    // 2. Seat availability
    // 3. User's existing bookings for the same ride
    // 4. User's payment status
    // 5. Driver approval status

    // For now, basic validation
    if (requestedSeats <= 0 || requestedSeats > 4) {
      return ApiResponse<bool>(
        message: 'Số ghế đặt phải từ 1 đến 4',
        statusCode: 400,
        data: false,
        success: false,
      );
    }

    return ApiResponse<bool>(
      message: 'Có thể đặt chỗ',
      statusCode: 200,
      data: true,
      success: true,
    );
  }

  /// Validation cho việc đặt chỗ
  List<String> _validateBooking({required int seats}) {
    final errors = <String>[];

    if (seats <= 0) {
      errors.add('Số ghế phải lớn hơn 0');
    }

    if (seats > 4) {
      errors.add('Không thể đặt quá 4 ghế trong một lần');
    }

    return errors;
  }
}
