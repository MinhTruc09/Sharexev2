import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';

enum BookingStatus { initial, selecting, confirmed, error, loading, loaded }

class VehicleSeat {
  final int seatNumber;
  final bool isSelected;
  final bool isReserved;
  final double price;

  const VehicleSeat({
    required this.seatNumber,
    this.isSelected = false,
    this.isReserved = false,
    required this.price,
  });

  VehicleSeat copyWith({
    int? seatNumber,
    bool? isSelected,
    bool? isReserved,
    double? price,
  }) {
    return VehicleSeat(
      seatNumber: seatNumber ?? this.seatNumber,
      isSelected: isSelected ?? this.isSelected,
      isReserved: isReserved ?? this.isReserved,
      price: price ?? this.price,
    );
  }
}

class BookingState {
  final BookingStatus status;
  final String? error;
  final String vehicleType;
  final int totalSeats;
  final double pricePerSeat;
  final List<VehicleSeat> seats;
  final List<int> selectedSeats;
  final double totalPrice;
  final Map<String, dynamic>? bookingData;
  final List<BookingEntity>? bookings;
  final bool isLoadingMore;
  final int currentPage;
  final bool hasMoreBookings;

  const BookingState({
    this.status = BookingStatus.initial,
    this.error,
    this.vehicleType = '',
    this.totalSeats = 0,
    this.pricePerSeat = 0.0,
    this.seats = const [],
    this.selectedSeats = const [],
    this.totalPrice = 0.0,
    this.bookingData,
    this.bookings,
    this.isLoadingMore = false,
    this.currentPage = 0,
    this.hasMoreBookings = true,
  });

  BookingState copyWith({
    BookingStatus? status,
    String? error,
    String? vehicleType,
    int? totalSeats,
    double? pricePerSeat,
    List<VehicleSeat>? seats,
    List<int>? selectedSeats,
    double? totalPrice,
    Map<String, dynamic>? bookingData,
    List<BookingEntity>? bookings,
    bool? isLoadingMore,
    int? currentPage,
    bool? hasMoreBookings,
  }) {
    return BookingState(
      status: status ?? this.status,
      error: error,
      vehicleType: vehicleType ?? this.vehicleType,
      totalSeats: totalSeats ?? this.totalSeats,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      seats: seats ?? this.seats,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      totalPrice: totalPrice ?? this.totalPrice,
      bookingData: bookingData ?? this.bookingData,
      bookings: bookings ?? this.bookings,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      hasMoreBookings: hasMoreBookings ?? this.hasMoreBookings,
    );
  }
}
