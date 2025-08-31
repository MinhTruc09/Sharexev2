part of 'home_passenger_cubit.dart';

enum HomePassengerStatus { initial, loading, ready, booking, rideBooked, error }

class HomePassengerState {
  final HomePassengerStatus status;
  final String? error;

  // Location data
  final String? pickupAddress;
  final double? pickupLat;
  final double? pickupLng;
  final String? dropoffAddress;
  final double? dropoffLat;
  final double? dropoffLng;

  // Search data
  final List<String> searchResults;
  final bool isSearching;
  final List<String> popularDestinations;
  final List<String> recentSearches;

  // Ride data
  final RideEntity? currentRide;
  final List<RideEntity> rideHistory;

  // New features for enhanced UI
  final List<Map<String, dynamic>> nearbyTrips;
  final bool hasActiveTrip;
  final Map<String, dynamic>? activeTripData;
  final int selectedPassengerCount;
  final double maxPrice;
  final DateTime? selectedDate;
  final String? selectedTime;
  final List<int> selectedSeats;
  final double totalBookingPrice;

  const HomePassengerState({
    this.status = HomePassengerStatus.initial,
    this.error,
    this.pickupAddress,
    this.pickupLat,
    this.pickupLng,
    this.dropoffAddress,
    this.dropoffLat,
    this.dropoffLng,
    this.searchResults = const [],
    this.isSearching = false,
    this.popularDestinations = const [],
    this.recentSearches = const [],
    this.currentRide,
    this.rideHistory = const [],
    this.nearbyTrips = const [],
    this.hasActiveTrip = false,
    this.activeTripData,
    this.selectedPassengerCount = 1,
    this.maxPrice = 200.0,
    this.selectedDate,
    this.selectedTime,
    this.selectedSeats = const [],
    this.totalBookingPrice = 0.0,
  });

  HomePassengerState copyWith({
    HomePassengerStatus? status,
    String? error,
    String? pickupAddress,
    double? pickupLat,
    double? pickupLng,
    String? dropoffAddress,
    double? dropoffLat,
    double? dropoffLng,
    List<String>? searchResults,
    bool? isSearching,
    List<String>? popularDestinations,
    List<String>? recentSearches,
    RideEntity? currentRide,
    List<RideEntity>? rideHistory,
    List<Map<String, dynamic>>? nearbyTrips,
    bool? hasActiveTrip,
    Map<String, dynamic>? activeTripData,
    int? selectedPassengerCount,
    double? maxPrice,
    DateTime? selectedDate,
    String? selectedTime,
    List<int>? selectedSeats,
    double? totalBookingPrice,
  }) {
    return HomePassengerState(
      status: status ?? this.status,
      error: error ?? this.error,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      popularDestinations: popularDestinations ?? this.popularDestinations,
      recentSearches: recentSearches ?? this.recentSearches,
      currentRide: currentRide ?? this.currentRide,
      rideHistory: rideHistory ?? this.rideHistory,
      nearbyTrips: nearbyTrips ?? this.nearbyTrips,
      hasActiveTrip: hasActiveTrip ?? this.hasActiveTrip,
      activeTripData: activeTripData ?? this.activeTripData,
      selectedPassengerCount:
          selectedPassengerCount ?? this.selectedPassengerCount,
      maxPrice: maxPrice ?? this.maxPrice,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      totalBookingPrice: totalBookingPrice ?? this.totalBookingPrice,
    );
  }
}
