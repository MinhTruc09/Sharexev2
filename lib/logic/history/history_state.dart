part of 'history_cubit.dart';

enum HistoryStatus { initial, loading, loaded, error }

enum HistoryFilter { all, completed, cancelled }

class HistoryState {
  final HistoryStatus status;
  final List<BookingEntity> allBookings;
  final List<BookingEntity> filteredBookings;
  final HistoryFilter currentFilter;
  final String? error;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.allBookings = const [],
    this.filteredBookings = const [],
    this.currentFilter = HistoryFilter.all,
    this.error,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<BookingEntity>? allBookings,
    List<BookingEntity>? filteredBookings,
    HistoryFilter? currentFilter,
    String? error,
  }) {
    return HistoryState(
      status: status ?? this.status,
      allBookings: allBookings ?? this.allBookings,
      filteredBookings: filteredBookings ?? this.filteredBookings,
      currentFilter: currentFilter ?? this.currentFilter,
      error: error ?? this.error,
    );
  }
}
