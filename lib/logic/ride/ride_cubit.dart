import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/domain/usecases/ride_usecases.dart';
import 'package:sharexev2/core/app_registry.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart';
import 'package:sharexev2/core/network/api_response.dart';

part 'ride_state.dart';

class RideCubit extends Cubit<RideState> {
  late final RideUseCases _rideUseCases;

  RideCubit() : super(const RideState()) {
    _rideUseCases = AppRegistry.I.rideUseCases;
  }

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
      final result = await _rideUseCases.createRide(
        departure: departure,
        destination: destination,
        startLat: 21.0285, // From location picker
        startLng: 105.8542,
        startAddress: 'Hà Nội',
        startWard: 'Phường 1',
        startDistrict: 'Quận Ba Đình',
        startProvince: 'Hà Nội',
        endLat: 10.8231,
        endLng: 106.6297,
        endAddress: 'TP.HCM',
        endWard: 'Phường 1',
        endDistrict: 'Quận 1',
        endProvince: 'TP.HCM',
        startTime: startTime,
        pricePerSeat: pricePerSeat,
        totalSeats: totalSeats,
        driverName: 'Current User Name',
        driverEmail: 'user@email.com',
      );
      
      if (result.success && result.data != null) {
        emit(state.copyWith(
          status: RideStatus.created,
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
      final result = await _rideUseCases.searchRides(
        departure: departure,
        destination: destination,
        startDate: startDate,
        minSeats: minSeats,
        maxPrice: maxPrice,
      );
      
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
      final result = await _rideUseCases.getRecommendedRides(
        userLocation: userLocation,
        preferredDestination: preferredDestination,
        requiredSeats: requiredSeats,
      );
      
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
      final result = await _rideUseCases.cancelRide(rideId);
      
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
      final result = await _rideUseCases.getRideById(rideId);
      
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
