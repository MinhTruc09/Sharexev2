part of 'trip_detail_cubit.dart';

enum TripDetailStatus {
  initial,
  loading,
  loaded,
  booking,
  bookingSuccess,
  navigateToReview,
  error,
}

class TripDetailState {
  final Map<String, dynamic> tripData;
  final TripDetailStatus status;
  final List<int> selectedSeats;
  final double totalPrice;
  final Map<String, dynamic>? bookingData;
  final String? error;

  const TripDetailState({
    this.tripData = const {},
    this.status = TripDetailStatus.initial,
    this.selectedSeats = const [],
    this.totalPrice = 0.0,
    this.bookingData,
    this.error,
  });

  TripDetailState copyWith({
    Map<String, dynamic>? tripData,
    TripDetailStatus? status,
    List<int>? selectedSeats,
    double? totalPrice,
    Map<String, dynamic>? bookingData,
    String? error,
  }) {
    return TripDetailState(
      tripData: tripData ?? this.tripData,
      status: status ?? this.status,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      totalPrice: totalPrice ?? this.totalPrice,
      bookingData: bookingData ?? this.bookingData,
      error: error ?? this.error,
    );
  }

  bool get isLoaded => status == TripDetailStatus.loaded;
  bool get isLoading => status == TripDetailStatus.loading;
  bool get isBooking => status == TripDetailStatus.booking;
  bool get isBookingSuccess => status == TripDetailStatus.bookingSuccess;
  bool get hasError => status == TripDetailStatus.error;
  bool get hasSelectedSeats => selectedSeats.isNotEmpty;
}
