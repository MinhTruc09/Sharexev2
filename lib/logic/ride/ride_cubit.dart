import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/ride/ride_repository_interface.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart'
    as ride_entity;
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/core/auth/auth_manager.dart';

part 'ride_state.dart';

class RideCubit extends Cubit<RideState> {
  final RideRepositoryInterface? _rideRepository;
  final BookingRepositoryInterface? _bookingRepository; // ignore: unused_field

  RideCubit({
    required RideRepositoryInterface? rideRepository,
    required BookingRepositoryInterface? bookingRepository,
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
    required double startLat,
    required double startLng,
    required String startAddress,
    String? startWard,
    String? startDistrict,
    String? startProvince,
    required double endLat,
    required double endLng,
    required String endAddress,
    String? endWard,
    String? endDistrict,
    String? endProvince,
  }) async {
    emit(state.copyWith(status: RideStatus.loading));

    try {
      if (_rideRepository != null) {
        // Get current user info from AuthManager
        final currentUser = AuthManager.instance.currentUser;
        if (currentUser == null) {
          emit(
            state.copyWith(
              status: RideStatus.error,
              error: 'Vui lòng đăng nhập để tạo chuyến đi',
            ),
          );
          return;
        }

        // Create RideEntity for repository layer
        final rideEntity = ride_entity.RideEntity(
          id: 0, // Will be assigned by backend
          availableSeats: totalSeats,
          driverName: currentUser.fullName ?? 'Unknown Driver',
          driverEmail: currentUser.email.value,
          departure: departure,
          startLat: startLat,
          startLng: startLng,
          startAddress: startAddress,
          startWard: startWard ?? '',
          startDistrict: startDistrict ?? '',
          startProvince: startProvince ?? '',
          endLat: endLat,
          endLng: endLng,
          endAddress: endAddress,
          endWard: endWard ?? '',
          endDistrict: endDistrict ?? '',
          endProvince: endProvince ?? '',
          destination: destination,
          startTime: startTime,
          pricePerSeat: pricePerSeat,
          totalSeat: totalSeats,
          status: ride_entity.RideStatus.active,
        );

        // Use repository to create ride
        final result = await _rideRepository!.createRide(rideEntity);

        if (result.success && result.data != null) {
          emit(
            state.copyWith(
              status: RideStatus.success,
              message: 'Tạo chuyến đi thành công',
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: RideStatus.error,
              error: result.message ?? 'Không thể tạo chuyến đi',
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            status: RideStatus.error,
            error: 'Ride repository không khả dụng',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RideStatus.error,
          error: 'Lỗi tạo chuyến đi: $e',
        ),
      );
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
      final result =
          _rideRepository != null
              ? await _rideRepository.searchRides(
                departure: departure,
                destination: destination,
                startTime: startDate,
                seats: minSeats,
              )
              : <ride_entity.RideEntity>[];

      if (result.isNotEmpty) {
        emit(state.copyWith(status: RideStatus.loaded, rides: result));
      } else {
        emit(state.copyWith(status: RideStatus.loaded, rides: []));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RideStatus.error,
          error: 'Lỗi tìm kiếm chuyến đi: $e',
        ),
      );
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
      final result =
          _rideRepository != null
              ? await _rideRepository.getAvailableRides()
              : <ride_entity.RideEntity>[];

      if (result.isNotEmpty) {
        emit(state.copyWith(status: RideStatus.loaded, rides: result));
      } else {
        emit(state.copyWith(status: RideStatus.loaded, rides: []));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RideStatus.error,
          error: 'Lỗi lấy chuyến đi đề xuất: $e',
        ),
      );
    }
  }

  /// Hủy chuyến đi
  Future<void> cancelRide(int rideId) async {
    emit(state.copyWith(status: RideStatus.loading));

    try {
      final result =
          _rideRepository != null
              ? await _rideRepository.cancelRide(rideId)
              : ApiResponse<bool>(
                message: 'No repository',
                statusCode: 404,
                data: false,
                success: false,
              );

      if (result.success) {
        emit(state.copyWith(status: RideStatus.cancelled, currentRide: null));
      } else {
        emit(state.copyWith(status: RideStatus.error, error: result.message));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RideStatus.error,
          error: 'Lỗi hủy chuyến đi: $e',
        ),
      );
    }
  }

  /// Lấy chi tiết chuyến đi
  Future<void> getRideById(int rideId) async {
    emit(state.copyWith(status: RideStatus.loading));

    try {
      final result =
          _rideRepository != null
              ? await _rideRepository.getRideById(rideId)
              : ApiResponse<ride_entity.RideEntity>(
                message: 'No repository',
                statusCode: 404,
                data: null,
                success: false,
              );

      if (result.success && result.data != null) {
        emit(
          state.copyWith(status: RideStatus.loaded, currentRide: result.data!),
        );
      } else {
        emit(state.copyWith(status: RideStatus.error, error: result.message));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RideStatus.error,
          error: 'Lỗi lấy chi tiết chuyến đi: $e',
        ),
      );
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
