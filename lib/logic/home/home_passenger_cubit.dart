import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart';
import 'package:sharexev2/data/models/booking/entities/booking_entity.dart';
import 'package:sharexev2/data/models/auth/entities/user_entity.dart';
import 'package:sharexev2/data/repositories/ride/ride_repository_interface.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/repositories/user/user_repository_interface.dart';
import 'package:sharexev2/data/repositories/location/location_repository_interface.dart';
import 'package:sharexev2/core/network/api_response.dart';

part 'home_passenger_state.dart';

class HomePassengerCubit extends Cubit<HomePassengerState> {
  // Repository Pattern - Clean Architecture
  final RideRepositoryInterface? _rideRepository;
  final BookingRepositoryInterface? _bookingRepository;
  final UserRepositoryInterface? _userRepository;
  final LocationRepositoryInterface? _locationRepository;

  HomePassengerCubit({
    required RideRepositoryInterface? rideRepository,
    required BookingRepositoryInterface? bookingRepository,
    required UserRepositoryInterface? userRepository,
    required LocationRepositoryInterface? locationRepository,
  }) : _rideRepository = rideRepository,
       _bookingRepository = bookingRepository,
       _userRepository = userRepository,
       _locationRepository = locationRepository,
       super(const HomePassengerState());

  Future<void> init() async {
    emit(state.copyWith(status: HomePassengerStatus.loading));
    try {
      // Load real data using Repository Pattern
      ApiResponse<List<BookingEntity>> bookingHistory;
      ApiResponse<UserEntity> userProfile;
      ApiResponse<List<RideEntity>> recommendedRides;

      if (_bookingRepository != null) {
        bookingHistory = await _bookingRepository.getPassengerBookings();
      } else {
        bookingHistory = ApiResponse<List<BookingEntity>>(message: 'No booking repository', statusCode: 404, data: [], success: false);
      }

      if (_userRepository != null) {
        userProfile = await _userRepository.getProfile();
      } else {
        userProfile = ApiResponse<UserEntity>(message: 'No user repository', statusCode: 404, data: null, success: false);
      }

      if (_rideRepository != null) {
        recommendedRides = await _rideRepository.getAvailableRides();
      } else {
        recommendedRides = ApiResponse<List<RideEntity>>(message: 'No ride repository', statusCode: 404, data: [], success: false);
      }

      // Booking history is handled separately in state

      final nearbyTrips = recommendedRides.data?.map((ride) => {
        'id': ride.id,
        'departure': ride.departure,
        'destination': ride.destination,
        'startTime': ride.startTime.toIso8601String(),
        'pricePerSeat': ride.pricePerSeat,
        'availableSeats': ride.availableSeats,
        'driverName': ride.driverName,
      }).toList() ?? [];

      emit(
        state.copyWith(
          status: HomePassengerStatus.ready,
          rideHistory: recommendedRides.data ?? [],
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

  RideStatus _mapBookingStatusToRideStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return RideStatus.active;
      case BookingStatus.accepted:
        return RideStatus.driverConfirmed;
      case BookingStatus.inProgress:
        return RideStatus.inProgress;
      case BookingStatus.completed:
        return RideStatus.completed;
      case BookingStatus.cancelled:
        return RideStatus.cancelled;
      default:
        return RideStatus.active;
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
      // Use real location repository for search
      if (_locationRepository != null) {
        final response = await _locationRepository.searchPlaces(query);
        if (response.success && response.data != null) {
          emit(state.copyWith(
            searchResults: response.data!.map((location) => location.address).toList(),
            isSearching: false,
          ));
        } else {
          emit(state.copyWith(
            searchResults: [],
            isSearching: false,
            error: response.message ?? 'Không tìm thấy địa điểm',
          ));
        }
      } else {
        emit(state.copyWith(
          searchResults: [],
          isSearching: false,
          error: 'Location service không khả dụng',
        ));
      }
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
      // Use real booking repository to create booking
      if (_bookingRepository != null) {
        // First, find available ride
        if (_rideRepository != null) {
          final ridesResponse = await _rideRepository.searchRides(
            departure: state.pickupAddress!,
            destination: state.dropoffAddress!,
            startTime: DateTime.now().toIso8601String(),
            seats: 1,
          );
          
          if (ridesResponse.success && ridesResponse.data != null && ridesResponse.data!.isNotEmpty) {
            final selectedRide = ridesResponse.data!.first;
            
            // Create booking using real repository
            final bookingResponse = await _bookingRepository.createBooking(
              selectedRide.id,
              1, // seats
            );
            
            if (bookingResponse.success && bookingResponse.data != null) {
              emit(state.copyWith(
                status: HomePassengerStatus.rideBooked,
                currentRide: selectedRide,
              ));
            } else {
              emit(state.copyWith(
                status: HomePassengerStatus.error,
                error: bookingResponse.message ?? 'Lỗi đặt chuyến',
              ));
            }
          } else {
            emit(state.copyWith(
              status: HomePassengerStatus.error,
              error: 'Không tìm thấy chuyến đi phù hợp',
            ));
          }
        } else {
          emit(state.copyWith(
            status: HomePassengerStatus.error,
            error: 'Ride service không khả dụng',
          ));
        }
      } else {
        emit(state.copyWith(
          status: HomePassengerStatus.error,
          error: 'Booking service không khả dụng',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: HomePassengerStatus.error,
        error: 'Lỗi đặt chuyến: $e',
      ));
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

  // Remove mock simulation function - use real booking flow instead

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void clearSearchResults() {
    emit(state.copyWith(searchResults: []));
  }

  // Add missing methods
  void showSearchBottomSheet() {
    // TODO: Implement search bottom sheet
    emit(state.copyWith(status: HomePassengerStatus.loading));
  }

  void swapLocations() {
    final currentPickup = state.pickupAddress;
    final currentDropoff = state.dropoffAddress;
    
    emit(state.copyWith(
      pickupAddress: currentDropoff,
      dropoffAddress: currentPickup,
    ));
  }

  Future<void> searchRides() async {
    if (state.pickupAddress == null || state.dropoffAddress == null) {
      emit(state.copyWith(
        status: HomePassengerStatus.error,
        error: 'Vui lòng chọn điểm đi và điểm đến',
      ));
      return;
    }

    emit(state.copyWith(status: HomePassengerStatus.loading));

    try {
      if (_rideRepository != null) {
        final response = await _rideRepository.searchRides(
          departure: state.pickupAddress!,
          destination: state.dropoffAddress!,
          startTime: state.selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
          seats: state.selectedPassengerCount ?? 1,
        );

        if (response.success && response.data != null) {
          final trips = response.data!.map((ride) => {
            'id': ride.id,
            'departure': ride.departure,
            'destination': ride.destination,
            'startTime': ride.startTime.toIso8601String(),
            'pricePerSeat': ride.pricePerSeat,
            'availableSeats': ride.availableSeats,
            'driverName': ride.driverName,
          }).toList();

          emit(state.copyWith(
            status: HomePassengerStatus.ready,
            nearbyTrips: trips,
            searchResults: trips.map((trip) => '${trip['departure']} → ${trip['destination']}').toList(),
          ));
        } else {
          emit(state.copyWith(
            status: HomePassengerStatus.error,
            error: response.message ?? 'Không tìm thấy chuyến đi',
          ));
        }
      } else {
        emit(state.copyWith(
          status: HomePassengerStatus.error,
          error: 'Ride service không khả dụng',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: HomePassengerStatus.error,
        error: 'Lỗi tìm kiếm: $e',
      ));
    }
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
      // Use real ride repository for search
      if (_rideRepository != null) {
        final response = await _rideRepository.searchRides(
          departure: searchData['from'],
          destination: searchData['to'],
          startTime: searchData['date'] ?? DateTime.now(),
          seats: searchData['passengerCount'] ?? 1,
        );
        
        if (response.success && response.data != null) {
          final trips = response.data!.map((ride) => {
            'id': ride.id,
            'departure': ride.departure,
            'destination': ride.destination,
            'startTime': ride.startTime.toIso8601String(),
            'pricePerSeat': ride.pricePerSeat,
            'availableSeats': ride.availableSeats,
            'driverName': ride.driverName,
          }).toList();
          
          emit(state.copyWith(
            isSearching: false,
            nearbyTrips: trips,
          ));
        } else {
          emit(state.copyWith(
            isSearching: false,
            nearbyTrips: [],
            error: response.message ?? 'Không tìm thấy chuyến đi',
          ));
        }
      } else {
        emit(state.copyWith(
          isSearching: false,
          nearbyTrips: [],
          error: 'Ride service không khả dụng',
        ));
      }
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
      final ride = RideEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        driverName: tripData['driverName'] ?? 'Tài xế',
        driverEmail: 'driver@example.com',
        departure: tripData['origin'] ?? '',
        startLat: 0.0, // Would be real coordinates
        startLng: 0.0,
        startAddress: tripData['origin'] ?? '',
        startWard: 'Phường',
        startDistrict: 'Quận',
        startProvince: 'Hà Nội',
        endLat: 0.0,
        endLng: 0.0,
        endAddress: tripData['destination'] ?? '',
        endWard: 'Phường đích',
        endDistrict: 'Quận đích',
        endProvince: 'Hà Nội',
        destination: tripData['destination'] ?? '',
        startTime: DateTime.now(),
        pricePerSeat: (tripData['price'] ?? 0).toDouble() * 1000, // Convert to VND
        totalSeat: 4,
        availableSeats: 4,
        status: RideStatus.active,
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
