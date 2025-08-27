import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/models/ride.dart';
import 'package:sharexev2/data/services/ride_service_impl.dart';

part 'home_passenger_state.dart';

class HomePassengerCubit extends Cubit<HomePassengerState> {
  final RideService _rideService = RideService();

  HomePassengerCubit() : super(const HomePassengerState());

  Future<void> init() async {
    emit(state.copyWith(status: HomePassengerStatus.loading));
    try {
      // Try load from API, fallback to local generated data
      List<Ride> rideHistory = [];
      try {
        final res = await _rideService.getRideHistory();
        rideHistory = (res.data ?? []).cast<Ride>();
      } catch (_) {
        // ignore and leave rideHistory empty
      }

      final nearbyTrips = await _loadNearbyTrips();

      emit(
        state.copyWith(
          status: HomePassengerStatus.ready,
          rideHistory: rideHistory,
          popularDestinations: [
            'Sân bay Nội Bài',
            'Hồ Gươm',
            'Trung tâm Lotte',
            'Vincom Mega Mall',
          ],
          recentSearches: ['Sân bay Nội Bài', 'Trung tâm Lotte'],
          nearbyTrips: nearbyTrips,
          hasActiveTrip: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: HomePassengerStatus.error, error: e.toString()),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _loadNearbyTrips() async {
    // Simulate loading nearby trips
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {
        'id': 'trip_1',
        'destination': 'Quận 7, TP.HCM',
        'origin': 'Quận 1, TP.HCM',
        'departureTime': '14:30 - Hôm nay',
        'price': 45,
        'availableSeats': 3,
        'driverName': 'Nguyễn Văn A',
        'driverInitials': 'NA',
        'driverAvatar': null,
        'rating': 4.8,
        'vehicleType': 'Xe hơi',
        'notes': 'Xe mới, điều hòa mát',
      },
      {
        'id': 'trip_2',
        'destination': 'Quận Thủ Đức, TP.HCM',
        'origin': 'Quận 3, TP.HCM',
        'departureTime': '15:00 - Hôm nay',
        'price': 35,
        'availableSeats': 2,
        'driverName': 'Trần Thị B',
        'driverInitials': 'TB',
        'driverAvatar': null,
        'rating': 4.9,
        'vehicleType': 'Xe van',
        'notes': 'Đi đúng giờ, an toàn',
      },
      {
        'id': 'trip_3',
        'destination': 'Quận Bình Thạnh, TP.HCM',
        'origin': 'Quận 5, TP.HCM',
        'departureTime': '16:30 - Hôm nay',
        'price': 25,
        'availableSeats': 4,
        'driverName': 'Lê Văn C',
        'driverInitials': 'LC',
        'driverAvatar': null,
        'rating': 4.7,
        'vehicleType': 'Xe hơi',
        'notes': 'Giá rẻ, thân thiện',
      },
    ];
  }

  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }

    emit(state.copyWith(isSearching: true));
    try {
      // TODO: replace with Places API call when available
      final results = await Future.value(
        [
          'Sân bay Nội Bài',
          'Trung tâm Lotte',
          'Vincom Mega Mall',
        ].where((p) => p.toLowerCase().contains(query.toLowerCase())).toList(),
      );
      emit(state.copyWith(searchResults: results, isSearching: false));
    } catch (e) {
      emit(state.copyWith(isSearching: false, error: 'Lỗi tìm kiếm: $e'));
    }
  }

  void setPickupLocation(String address, double lat, double lng) {
    emit(
      state.copyWith(pickupAddress: address, pickupLat: lat, pickupLng: lng),
    );
  }

  void setDropoffLocation(String address, double lat, double lng) {
    emit(
      state.copyWith(dropoffAddress: address, dropoffLat: lat, dropoffLng: lng),
    );
  }

  Future<void> bookRide() async {
    if (state.pickupAddress == null || state.dropoffAddress == null) {
      emit(state.copyWith(error: 'Vui lòng chọn điểm đón và điểm đến'));
      return;
    }

    emit(state.copyWith(status: HomePassengerStatus.booking));
    try {
      final ride = await _rideService.createRideLocal(
        pickupAddress: state.pickupAddress!,
        dropoffAddress: state.dropoffAddress!,
        pickupLat: state.pickupLat!,
        pickupLng: state.pickupLng!,
        dropoffLat: state.dropoffLat!,
        dropoffLng: state.dropoffLng!,
      );

      emit(
        state.copyWith(
          status: HomePassengerStatus.rideBooked,
          currentRide: ride,
        ),
      );

      // Simulate finding driver
      _simulateRideProgress(ride);
    } catch (e) {
      emit(
        state.copyWith(
          status: HomePassengerStatus.error,
          error: 'Lỗi đặt chuyến: $e',
        ),
      );
    }
  }

  void _simulateRideProgress(Ride ride) async {
    // Simulate driver found after 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (state.currentRide?.id == ride.id) {
      final updatedRide = ride.copyWith(
        status: RideStatus.driverFound,
        driverId: 'driver_mock',
        driverName: 'Nguyễn Văn Tài',
        driverPhone: '0901234567',
        vehicleInfo: 'Toyota Vios - 30A-12345',
      );
      emit(state.copyWith(currentRide: updatedRide));
    }
  }

  void cancelRide() {
    if (state.currentRide != null) {
      final cancelledRide = state.currentRide!.copyWith(
        status: RideStatus.cancelled,
      );
      emit(
        state.copyWith(
          currentRide: cancelledRide,
          status: HomePassengerStatus.ready,
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void clearSearchResults() {
    emit(state.copyWith(searchResults: []));
  }

  // New methods for enhanced UI
  void updateSearchCriteria({
    String? from,
    String? to,
    DateTime? date,
    String? time,
    int? passengerCount,
    double? maxPrice,
  }) {
    emit(
      state.copyWith(
        pickupAddress: from,
        dropoffAddress: to,
        selectedDate: date,
        selectedTime: time,
        selectedPassengerCount: passengerCount,
        maxPrice: maxPrice,
      ),
    );
  }

  Future<void> searchTrips(Map<String, dynamic> searchData) async {
    emit(state.copyWith(isSearching: true));

    try {
      // Simulate search API call
      await Future.delayed(const Duration(milliseconds: 1000));

      // Filter nearby trips based on search criteria
      final filteredTrips =
          state.nearbyTrips.where((trip) {
            if (searchData['to'] != null && searchData['to'].isNotEmpty) {
              return trip['destination'].toString().toLowerCase().contains(
                searchData['to'].toString().toLowerCase(),
              );
            }
            return true;
          }).toList();

      emit(state.copyWith(isSearching: false, nearbyTrips: filteredTrips));
    } catch (e) {
      emit(state.copyWith(isSearching: false, error: 'Lỗi tìm kiếm: $e'));
    }
  }

  void selectSeats(List<int> seats, double totalPrice) {
    emit(state.copyWith(selectedSeats: seats, totalBookingPrice: totalPrice));
  }

  Future<void> bookTrip(Map<String, dynamic> tripData) async {
    emit(state.copyWith(status: HomePassengerStatus.booking));

    try {
      // Simulate booking API call
      await Future.delayed(const Duration(milliseconds: 1500));

      // Create a new ride from trip data
      final ride = Ride(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pickupAddress: tripData['origin'] ?? '',
        dropoffAddress: tripData['destination'] ?? '',
        pickupLat: 0.0, // Would be real coordinates
        pickupLng: 0.0,
        dropoffLat: 0.0,
        dropoffLng: 0.0,
        price: (tripData['price'] ?? 0).toDouble() * 1000, // Convert to VND
        duration: 30, // Estimated duration
        distance: 10.0, // Estimated distance
        status: RideStatus.searching,
        driverId: tripData['driverId'],
        driverName: tripData['driverName'],
        driverPhone: '0901234567',
        vehicleInfo: tripData['vehicleType'] ?? 'Xe hơi',
        createdAt: DateTime.now(),
      );

      emit(
        state.copyWith(
          status: HomePassengerStatus.rideBooked,
          currentRide: ride,
          hasActiveTrip: true,
          activeTripData: tripData,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomePassengerStatus.error,
          error: 'Lỗi đặt chuyến: $e',
        ),
      );
    }
  }

  void refreshNearbyTrips() async {
    try {
      final nearbyTrips = await _loadNearbyTrips();
      emit(state.copyWith(nearbyTrips: nearbyTrips));
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi tải dữ liệu: $e'));
    }
  }

  Future<void> loadInitialData() async {
    await init();
  }
}
