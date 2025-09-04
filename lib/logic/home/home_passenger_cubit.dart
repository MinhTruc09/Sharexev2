import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart';
import 'package:sharexev2/data/repositories/ride/ride_repository_interface.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/repositories/location/location_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_passenger_state.dart';

class HomePassengerCubit extends Cubit<HomePassengerState> {
  // Repository Pattern - Clean Architecture
  final RideRepositoryInterface? _rideRepository;
  final BookingRepositoryInterface? _bookingRepository;
  final LocationRepositoryInterface? _locationRepository;

  HomePassengerCubit({
    required RideRepositoryInterface? rideRepository,
    required BookingRepositoryInterface? bookingRepository,
    required LocationRepositoryInterface? locationRepository,
  }) : _rideRepository = rideRepository,
       _bookingRepository = bookingRepository,
       _locationRepository = locationRepository,
       super(const HomePassengerState());

  Future<void> init() async {
    emit(state.copyWith(status: HomePassengerStatus.loading));
    try {
      // Load real data using Repository Pattern
      List<RideEntity> recommendedRides;

      if (_rideRepository != null) {
        recommendedRides = await _rideRepository.getAvailableRides();
      } else {
        recommendedRides = [];
      }

      // Load recommended rides for home display
      final nearbyRides =
          recommendedRides
              .map(
                (ride) => {
                  'id': ride.id,
                  'departure': ride.departure,
                  'destination': ride.destination,
                  'startTime': ride.startTime.toIso8601String(),
                  'pricePerSeat': ride.pricePerSeat,
                  'availableSeats': ride.availableSeats,
                  'driverName': ride.driverName,
                },
              )
              .toList();

      emit(
        state.copyWith(
          status: HomePassengerStatus.ready,
          rideHistory: recommendedRides,
          popularDestinations: await _loadPopularDestinations(),
          recentSearches: await _loadRecentSearches(),
          nearbyRides: nearbyRides,
          hasActiveTrip: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: HomePassengerStatus.error, error: e.toString()),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _loadNearbyRides() async {
    try {
      if (_rideRepository != null) {
        final response = await _rideRepository.getAvailableRides();
        if (response.isNotEmpty) {
          return response
              .map(
                (ride) => {
                  'id': ride.id.toString(),
                  'destination': ride.destination,
                  'origin': ride.departure,
                  'departureTime':
                      '${ride.startTime.hour.toString().padLeft(2, '0')}:${ride.startTime.minute.toString().padLeft(2, '0')} - ${ride.startTime.day}/${ride.startTime.month}/${ride.startTime.year}',
                  'price': ride.pricePerSeat,
                  'availableSeats': ride.availableSeats,
                  'driverName': ride.driverName,
                  'driverInitials': _getInitials(ride.driverName),
                  'driverAvatar':
                      ride.driverEmail.isNotEmpty
                          ? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(ride.driverName)}&background=random'
                          : null,
                  'rating': _calculateDriverRating(ride.driverEmail),
                  'vehicleType': _getVehicleType(ride.totalSeat),
                  'notes': _generateRideDescription(ride),
                },
              )
              .toList();
        }
      }

      // Fallback to empty list if API fails
      return [];
    } catch (e) {
      // Log error and return empty list
      print('Error loading nearby rides: $e');
      return [];
    }
  }

  Future<List<String>> _loadPopularDestinations() async {
    try {
      // Load from static config - could be moved to API in future
      return [
        'Sân bay Nội Bài',
        'Hồ Gươm',
        'Trung tâm Lotte',
        'Vincom Mega Mall',
        'Bến xe Mỹ Đình',
        'Trường Đại học Bách khoa Hà Nội',
      ];
    } catch (e) {
      print('Error loading popular destinations: $e');
      return [];
    }
  }

  Future<List<String>> _loadRecentSearches() async {
    try {
      // Load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final recentSearches = prefs.getStringList('recent_searches') ?? [];
      return recentSearches.take(5).toList(); // Limit to 5 recent searches
    } catch (e) {
      print('Error loading recent searches: $e');
      return [];
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'TX';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
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
          // Save successful search to recent searches
          await _saveRecentSearch(query);

          emit(
            state.copyWith(
              searchResults:
                  response.data!.map((location) => location.address).toList(),
              isSearching: false,
            ),
          );
        } else {
          emit(
            state.copyWith(
              searchResults: [],
              isSearching: false,
              error: response.message,
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            searchResults: [],
            isSearching: false,
            error: 'Location service không khả dụng',
          ),
        );
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
            startTime: DateTime.now(),
            seats: 1,
          );

          if (ridesResponse.isNotEmpty) {
            final selectedRide = ridesResponse.first;

            // Create booking using real repository
            final bookingResponse = await _bookingRepository.createBooking(
              selectedRide.id,
              1, // seats
            );

            if (bookingResponse.success && bookingResponse.data != null) {
              emit(
                state.copyWith(
                  status: HomePassengerStatus.rideBooked,
                  currentRide: selectedRide,
                ),
              );
            } else {
              emit(
                state.copyWith(
                  status: HomePassengerStatus.error,
                  error: bookingResponse.message,
                ),
              );
            }
          } else {
            emit(
              state.copyWith(
                status: HomePassengerStatus.error,
                error: 'Không tìm thấy chuyến đi phù hợp',
              ),
            );
          }
        } else {
          emit(
            state.copyWith(
              status: HomePassengerStatus.error,
              error: 'Ride service không khả dụng',
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            status: HomePassengerStatus.error,
            error: 'Booking service không khả dụng',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: HomePassengerStatus.error,
          error: 'Lỗi đặt chuyến: $e',
        ),
      );
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

  void showSearchBottomSheet() {
    // Update state to ready status - UI will handle showing bottom sheet
    emit(state.copyWith(status: HomePassengerStatus.ready));
  }

  void swapLocations() {
    final currentPickup = state.pickupAddress;
    final currentDropoff = state.dropoffAddress;

    emit(
      state.copyWith(
        pickupAddress: currentDropoff,
        dropoffAddress: currentPickup,
      ),
    );
  }

  Future<void> searchRides() async {
    if (state.pickupAddress == null || state.dropoffAddress == null) {
      emit(
        state.copyWith(
          status: HomePassengerStatus.error,
          error: 'Vui lòng chọn điểm đi và điểm đến',
        ),
      );
      return;
    }

    emit(state.copyWith(status: HomePassengerStatus.loading));

    try {
      if (_rideRepository != null) {
        final response = await _rideRepository.searchRides(
          departure: state.pickupAddress!,
          destination: state.dropoffAddress!,
          startTime: state.selectedDate ?? DateTime.now(),
          seats: state.selectedPassengerCount,
        );

        if (response.isNotEmpty) {
          final trips =
              response
                  .map(
                    (ride) => {
                      'id': ride.id,
                      'departure': ride.departure,
                      'destination': ride.destination,
                      'startTime': ride.startTime.toIso8601String(),
                      'pricePerSeat': ride.pricePerSeat,
                      'availableSeats': ride.availableSeats,
                      'driverName': ride.driverName,
                    },
                  )
                  .toList();

          emit(
            state.copyWith(
              status: HomePassengerStatus.ready,
              nearbyRides: trips,
              searchResults:
                  trips
                      .map(
                        (trip) =>
                            '${trip['departure']} → ${trip['destination']}',
                      )
                      .toList(),
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: HomePassengerStatus.ready,
              nearbyRides: [],
              searchResults: [],
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            status: HomePassengerStatus.error,
            error: 'Ride service không khả dụng',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: HomePassengerStatus.error,
          error: 'Lỗi tìm kiếm: $e',
        ),
      );
    }
  }

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

        if (response.isNotEmpty) {
          final trips =
              response
                  .map(
                    (ride) => {
                      'id': ride.id,
                      'departure': ride.departure,
                      'destination': ride.destination,
                      'startTime': ride.startTime.toIso8601String(),
                      'pricePerSeat': ride.pricePerSeat,
                      'availableSeats': ride.availableSeats,
                      'driverName': ride.driverName,
                    },
                  )
                  .toList();

          emit(state.copyWith(isSearching: false, nearbyRides: trips));
        } else {
          emit(state.copyWith(isSearching: false, nearbyRides: []));
        }
      } else {
        emit(
          state.copyWith(
            isSearching: false,
            nearbyRides: [],
            error: 'Ride service không khả dụng',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isSearching: false, error: 'Lỗi tìm kiếm: $e'));
    }
  }

  void selectSeats(List<int> seats, double totalPrice) {
    emit(state.copyWith(selectedSeats: seats, totalBookingPrice: totalPrice));
  }

  Future<void> bookRideWithData(Map<String, dynamic> rideData) async {
    emit(state.copyWith(status: HomePassengerStatus.booking));

    try {
      // Simulate booking API call
      await Future.delayed(const Duration(milliseconds: 1500));

      // Create a new ride from ride data
      final ride = RideEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        driverName: rideData['driverName'] ?? 'Tài xế',
        driverEmail: 'driver@example.com',
        departure: rideData['origin'] ?? '',
        startLat: 0.0, // Would be real coordinates
        startLng: 0.0,
        startAddress: rideData['origin'] ?? '',
        startWard: 'Phường',
        startDistrict: 'Quận',
        startProvince: 'Hà Nội',
        endLat: 0.0,
        endLng: 0.0,
        endAddress: rideData['destination'] ?? '',
        endWard: 'Phường đích',
        endDistrict: 'Quận đích',
        endProvince: 'Hà Nội',
        destination: rideData['destination'] ?? '',
        startTime: DateTime.now(),
        pricePerSeat:
            (rideData['price'] ?? 0).toDouble() * 1000, // Convert to VND
        totalSeat: 4,
        availableSeats: 4,
        status: RideStatus.active,
      );

      emit(
        state.copyWith(
          status: HomePassengerStatus.rideBooked,
          currentRide: ride,
          hasActiveTrip: true,
          activeTripData: rideData,
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

  void refreshNearbyRides() async {
    try {
      final nearbyRides = await _loadNearbyRides();
      emit(state.copyWith(nearbyRides: nearbyRides));
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi tải dữ liệu: $e'));
    }
  }

  Future<void> loadInitialData() async {
    await init();
  }

  // Helper methods for ride data generation
  double _calculateDriverRating(String driverEmail) {
    // Generate consistent rating based on driver email hash
    final hash = driverEmail.hashCode.abs();
    final rating = 3.5 + (hash % 15) / 10.0; // Rating between 3.5-5.0
    return double.parse(rating.toStringAsFixed(1));
  }

  String _getVehicleType(int totalSeats) {
    if (totalSeats <= 4) return 'Xe sedan';
    if (totalSeats <= 7) return 'Xe 7 chỗ';
    if (totalSeats <= 16) return 'Xe khách';
    return 'Xe bus';
  }

  String _generateRideDescription(RideEntity ride) {
    final descriptions = [
      'Xe mới, điều hòa mát',
      'Tài xế thân thiện, lái xe an toàn',
      'Xe sạch sẽ, wifi miễn phí',
      'Có nước uống miễn phí',
      'Xe máy lạnh, ghế da',
      'Lái xe êm ái, nhạc nhẹ',
    ];

    // Use ride ID to get consistent description
    final index = ride.id.hashCode.abs() % descriptions.length;
    return descriptions[index];
  }

  // Save search to recent searches
  Future<void> _saveRecentSearch(String searchTerm) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var recentSearches = prefs.getStringList('recent_searches') ?? [];

      // Remove if already exists and add to front
      recentSearches.remove(searchTerm);
      recentSearches.insert(0, searchTerm);

      // Keep only 10 recent searches
      if (recentSearches.length > 10) {
        recentSearches = recentSearches.take(10).toList();
      }

      await prefs.setStringList('recent_searches', recentSearches);
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }
}
