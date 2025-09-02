import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';

import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepositoryInterface? _bookingRepository;

  BookingCubit(this._bookingRepository) : super(const BookingState());

  void initializeSeats({
    required String vehicleType,
    required int totalSeats,
    required List<int> reservedSeats,
    required double pricePerSeat,
  }) {
    final seats = List.generate(totalSeats, (index) {
      return VehicleSeat(
        seatNumber: index + 1,
        isReserved: reservedSeats.contains(index + 1),
        price: pricePerSeat,
      );
    });

    emit(state.copyWith(
      vehicleType: vehicleType,
      totalSeats: totalSeats,
      pricePerSeat: pricePerSeat,
      seats: seats,
      selectedSeats: [],
      totalPrice: 0.0,
    ));
  }

  void toggleSeatSelection(int seatIndex) {
    if (seatIndex < 0 || seatIndex >= state.seats.length) return;
    
    final seat = state.seats[seatIndex];
    if (seat.isReserved) return;

    final updatedSeats = List<VehicleSeat>.from(state.seats);
    updatedSeats[seatIndex] = seat.copyWith(
      isSelected: !seat.isSelected,
    );

    final selectedSeats = updatedSeats
        .where((seat) => seat.isSelected)
        .map((seat) => seat.seatNumber)
        .toList();

    final totalPrice = selectedSeats.length * state.pricePerSeat;

    emit(state.copyWith(
      seats: updatedSeats,
      selectedSeats: selectedSeats,
      totalPrice: totalPrice,
    ));
  }

  void clearSelection() {
    final updatedSeats = state.seats.map((seat) {
      return seat.copyWith(isSelected: false);
    }).toList();

    emit(state.copyWith(
      seats: updatedSeats,
      selectedSeats: [],
      totalPrice: 0.0,
    ));
  }

  // ===== Repository Integration Methods =====

  /// Load passenger bookings from repository
  Future<void> loadPassengerBookings() async {
    emit(state.copyWith(status: BookingStatus.selecting, error: null));

    try {
      final response = await _bookingRepository?.getPassengerBookings();

      if (response?.success == true && response?.data != null) {
        emit(state.copyWith(
          status: BookingStatus.initial,
          bookingData: {
            'bookings': response!.data!.length,
            'bookingsList': response.data,
          },
        ));
      } else {
        emit(state.copyWith(
          status: BookingStatus.error,
          error: response?.message ?? 'Failed to load bookings',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Create booking through repository
  Future<void> createBooking(int rideId) async {
    if (state.selectedSeats.isEmpty) {
      emit(state.copyWith(error: 'Please select at least one seat'));
      return;
    }

    emit(state.copyWith(status: BookingStatus.selecting, error: null));

    try {
      final response = await _bookingRepository?.createBooking(
        rideId,
        state.selectedSeats.length,
      );

      if (response?.success == true && response?.data != null) {
        emit(state.copyWith(
          status: BookingStatus.confirmed,
          bookingData: {
            'vehicleType': state.vehicleType,
            'selectedSeats': state.selectedSeats,
            'totalPrice': state.totalPrice,
            'pricePerSeat': state.pricePerSeat,
            'bookingTime': DateTime.now().toIso8601String(),
            'bookingEntity': response!.data!.id,
          },
        ));
      } else {
        emit(state.copyWith(
          status: BookingStatus.error,
          error: response?.message ?? 'Failed to create booking',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Cancel booking through repository
  Future<void> cancelBooking(int rideId) async {
    emit(state.copyWith(status: BookingStatus.selecting, error: null));

    try {
      final response = await _bookingRepository?.cancelBooking(rideId);

      if (response?.success == true) {
        emit(state.copyWith(
          status: BookingStatus.initial,
          bookingData: null,
        ));
      } else {
        emit(state.copyWith(
          status: BookingStatus.error,
          error: response?.message ?? 'Failed to cancel booking',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.error,
        error: e.toString(),
      ));
    }
  }

  // ===== Legacy UI Methods (for seat selection) =====

  void confirmBooking() {
    if (state.selectedSeats.isEmpty) {
      emit(state.copyWith(error: 'Please select at least one seat'));
      return;
    }

    emit(state.copyWith(
      status: BookingStatus.confirmed,
      bookingData: {
        'vehicleType': state.vehicleType,
        'selectedSeats': state.selectedSeats,
        'totalPrice': state.totalPrice,
        'pricePerSeat': state.pricePerSeat,
        'bookingTime': DateTime.now().toIso8601String(),
      },
    ));
  }

  void resetBooking() {
    emit(const BookingState());
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
