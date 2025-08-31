import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/repositories/ride/ride_repository_interface.dart';
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart' as ride_entity;

part 'trip_detail_state.dart';

class TripDetailCubit extends Cubit<TripDetailState> {
  final dynamic _bookingRepository; // TODO: Type as BookingRepositoryInterface when DI is ready
  final dynamic _rideRepository; // TODO: Type as RideRepositoryInterface when DI is ready

  TripDetailCubit({
    required dynamic bookingRepository,
    required dynamic rideRepository,
  }) : _bookingRepository = bookingRepository,
       _rideRepository = rideRepository,
       super(const TripDetailState());

  void initializeTrip(Map<String, dynamic> tripData) {
    emit(state.copyWith(
      tripData: tripData,
      status: TripDetailStatus.loaded,
    ));
  }

  void selectSeats(List<int> seats) {
    final pricePerSeat = (state.tripData['price'] ?? 0).toDouble();
    final totalPrice = (seats.length * pricePerSeat).toDouble();
    
    emit(state.copyWith(
      selectedSeats: seats,
      totalPrice: totalPrice,
    ));
  }

  void clearSeatSelection() {
    emit(state.copyWith(
      selectedSeats: [],
      totalPrice: 0.0,
    ));
  }

  Future<void> bookTrip() async {
    if (state.selectedSeats.isEmpty) {
      emit(state.copyWith(
        status: TripDetailStatus.error,
        error: 'Vui lòng chọn ít nhất một chỗ ngồi',
      ));
      return;
    }

    emit(state.copyWith(
      status: TripDetailStatus.booking,
      error: null,
    ));

    try {
      // Simulate booking API call
      await Future.delayed(const Duration(seconds: 2));
      
      emit(state.copyWith(
        status: TripDetailStatus.bookingSuccess,
        bookingData: {
          'tripId': state.tripData['id'],
          'selectedSeats': state.selectedSeats,
          'totalPrice': state.totalPrice,
          'bookingTime': DateTime.now().toIso8601String(),
        },
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TripDetailStatus.error,
        error: 'Lỗi đặt chuyến: $e',
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void resetStatus() {
    emit(state.copyWith(status: TripDetailStatus.loaded));
  }

  void navigateToReview() {
    emit(state.copyWith(status: TripDetailStatus.navigateToReview));
  }
}
