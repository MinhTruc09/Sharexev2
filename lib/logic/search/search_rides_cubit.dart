import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart';
import 'package:sharexev2/data/repositories/ride/ride_repository_interface.dart';

part 'search_rides_state.dart';

class SearchRidesCubit extends Cubit<SearchRidesState> {
  final RideRepositoryInterface _rideRepository;

  SearchRidesCubit({required RideRepositoryInterface rideRepository})
    : _rideRepository = rideRepository,
      super(const SearchRidesState());

  /// Search rides with criteria
  Future<void> searchRides({
    required String departure,
    required String destination,
    DateTime? startTime,
    int? seats,
  }) async {
    try {
      emit(state.copyWith(status: SearchRidesStatus.loading, error: null));

      final rides = await _rideRepository.searchRides(
        departure: departure,
        destination: destination,
        startTime: startTime,
        seats: seats,
      );

      emit(
        state.copyWith(
          status: SearchRidesStatus.loaded,
          rides: rides,
          hasSearched: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchRidesStatus.error,
          error: 'Lỗi khi tìm kiếm chuyến đi: ${e.toString()}',
          hasSearched: true,
        ),
      );
    }
  }

  /// Load all available rides
  Future<void> loadAvailableRides() async {
    try {
      emit(state.copyWith(status: SearchRidesStatus.loading, error: null));

      final rides = await _rideRepository.getAvailableRides();

      emit(
        state.copyWith(
          status: SearchRidesStatus.loaded,
          rides: rides,
          hasSearched: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchRidesStatus.error,
          error: 'Lỗi khi tải danh sách chuyến đi: ${e.toString()}',
        ),
      );
    }
  }

  /// Clear search results
  void clearResults() {
    emit(
      state.copyWith(
        status: SearchRidesStatus.initial,
        rides: [],
        hasSearched: false,
        error: null,
      ),
    );
  }

  /// Refresh current search or available rides
  Future<void> refresh() async {
    if (state.hasSearched) {
      // If we have searched before, we need to search again with the same criteria
      // For now, just reload available rides
      await loadAvailableRides();
    } else {
      await loadAvailableRides();
    }
  }
}
