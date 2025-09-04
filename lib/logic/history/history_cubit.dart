import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';
import 'package:sharexev2/core/auth/auth_manager.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final BookingRepositoryInterface _bookingRepository;

  HistoryCubit({required BookingRepositoryInterface bookingRepository})
    : _bookingRepository = bookingRepository,
      super(const HistoryState());

  Future<void> loadHistory() async {
    emit(state.copyWith(status: HistoryStatus.loading));

    try {
      final user = AuthManager().currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            status: HistoryStatus.error,
            error: 'User not authenticated',
          ),
        );
        return;
      }

      final response = await _bookingRepository.getPassengerBookings();

      if (response.success && response.data != null) {
        final bookings = response.data!;

        emit(
          state.copyWith(
            status: HistoryStatus.loaded,
            allBookings: bookings,
            filteredBookings: bookings,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: HistoryStatus.error,
            error: response.message ?? 'Failed to load booking history',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.error, error: e.toString()));
    }
  }

  void filterBookings(HistoryFilter filter) {
    List<BookingEntity> filteredBookings;

    switch (filter) {
      case HistoryFilter.all:
        filteredBookings = state.allBookings;
        break;
      case HistoryFilter.completed:
        filteredBookings =
            state.allBookings
                .where((booking) => booking.status == BookingStatus.completed)
                .toList();
        break;
      case HistoryFilter.cancelled:
        filteredBookings =
            state.allBookings
                .where((booking) => booking.status == BookingStatus.cancelled)
                .toList();
        break;
    }

    emit(
      state.copyWith(currentFilter: filter, filteredBookings: filteredBookings),
    );
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      final response = await _bookingRepository.cancelBooking(bookingId);

      if (response.success) {
        // Reload history to get updated data
        await loadHistory();
      } else {
        emit(
          state.copyWith(
            status: HistoryStatus.error,
            error: response.message ?? 'Failed to cancel booking',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.error, error: e.toString()));
    }
  }

  Future<void> rateTrip(int bookingId, double rating, String comment) async {
    try {
      // Rating API not yet available in backend
      emit(
        state.copyWith(
          status: HistoryStatus.error,
          error: 'Chức năng đánh giá đang được phát triển',
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.error, error: e.toString()));
    }
  }
}
