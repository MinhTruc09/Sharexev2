import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/ride/ride_repository_interface.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart' as ride_entity;
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';
import 'package:sharexev2/core/network/api_response.dart';

part 'ride_state.dart';

class RideCubit extends Cubit<RideState> {
  final dynamic _rideRepository; // TODO: Type as RideRepositoryInterface when DI is ready
  final dynamic _bookingRepository; // TODO: Type as BookingRepositoryInterface when DI is ready

  RideCubit({
    required dynamic rideRepository,
    required dynamic bookingRepository,
  }) : _rideRepository = rideRepository,
       _bookingRepository = bookingRepository,
       super(const RideState());

  /// Tạo chuyến đi mới
  Future<void> createRide({
    required String departure,
    required String destination,
    required DateTime startTime,
    required double pricePerSeat,
    required int totalSeats,
  }) async {
    emit(state.copyWith(status: RideStatus.loading));

    try {
      if (_rideRepository != null) {
        // TODO: Create proper RideRequestDTO and use service
        // final rideRequest = RideRequestDTO(
        //   departure: departure,
        //   destination: destination,
        //   startTime: startTime,
        //   pricePerSeat: pricePerSeat,
        //   totalSeat: totalSeats,
        //   ... other required fields
        // );
        // final result = await _rideRepository.createRide(rideRequest);
        
        emit(state.copyWith(
          status: RideStatus.error,
          error: 'Create ride API chưa được triển khai đầy đủ',
        ));
      } else {
        emit(state.copyWith(
          status: RideStatus.error,
          error: 'Ride repository không khả dụng',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RideStatus.error,
        error: 'Lỗi tạo chuyến đi: $e',
      ));
    }
  }

  /// Tìm kiếm chuyến đi
  Future<void> searchRides({
    String? departure,
    String? destination,
    DateTime? startDate,
    int? minSeats,
    double? maxPrice,
  }) async {
    emit(state.copyWith(status: RideStatus.loading));
    
    try {
      final result = _rideRepository != null
          ? await _rideRepository.searchRides(
              departure: departure,
              destination: destination,
              startTime: startDate?.toIso8601String(),
              seats: minSeats,
            )
          : ApiResponse<List<ride_entity.RideEntity>>(message: 'No repository', statusCode: 404, data: [], success: false);
      
      if (result.success && result.data != null) {
        emit(state.copyWith(
          status: RideStatus.loaded,
          rides: result.data!,
        ));
      } else {
        emit(state.copyWith(
          status: RideStatus.error,
          error: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RideStatus.error,
        error: 'Lỗi tìm kiếm chuyến đi: $e',
      ));
    }
  }

  /// Lấy chuyến đi được đề xuất
  Future<void> getRecommendedRides({
    required String userLocation,
    String? preferredDestination,
    int? requiredSeats,
  }) async {
    emit(state.copyWith(status: RideStatus.loading));
    
    try {
      final result = _rideRepository != null
          ? await _rideRepository.getAvailableRides()
          : ApiResponse<List<ride_entity.RideEntity>>(message: 'No repository', statusCode: 404, data: [], success: false);
      
      if (result.success && result.data != null) {
        emit(state.copyWith(
          status: RideStatus.loaded,
          rides: result.data!,
        ));
      } else {
        emit(state.copyWith(
          status: RideStatus.error,
          error: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RideStatus.error,
        error: 'Lỗi lấy chuyến đi đề xuất: $e',
      ));
    }
  }

  /// Hủy chuyến đi
  Future<void> cancelRide(int rideId) async {
    emit(state.copyWith(status: RideStatus.loading));
    
    try {
      final result = _rideRepository != null
          ? await _rideRepository.cancelRide(rideId)
          : ApiResponse<bool>(message: 'No repository', statusCode: 404, data: false, success: false);
      
      if (result.success) {
        emit(state.copyWith(
          status: RideStatus.cancelled,
          currentRide: null,
        ));
      } else {
        emit(state.copyWith(
          status: RideStatus.error,
          error: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RideStatus.error,
        error: 'Lỗi hủy chuyến đi: $e',
      ));
    }
  }

  /// Lấy chi tiết chuyến đi
  Future<void> getRideById(int rideId) async {
    emit(state.copyWith(status: RideStatus.loading));
    
    try {
      final result = _rideRepository != null
          ? await _rideRepository.getRideById(rideId)
          : ApiResponse<ride_entity.RideEntity>(message: 'No repository', statusCode: 404, data: null, success: false);
      
      if (result.success && result.data != null) {
        emit(state.copyWith(
          status: RideStatus.loaded,
          currentRide: result.data!,
        ));
      } else {
        emit(state.copyWith(
          status: RideStatus.error,
          error: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RideStatus.error,
        error: 'Lỗi lấy chi tiết chuyến đi: $e',
      ));
    }
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Reset state
  void reset() {
    emit(const RideState());
  }
}
