import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(const BookingState());

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
