import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/location/location_repository_interface.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepositoryInterface? _locationRepository;
  StreamSubscription<LocationData>? _locationSubscription;

  LocationCubit({
    required LocationRepositoryInterface? locationRepository,
  }) : _locationRepository = locationRepository,
       super(const LocationState());

  // ===== Location Services =====

  /// Get current location
  Future<void> getCurrentLocation() async {
    emit(state.copyWith(status: LocationStatus.loading));

    try {
      if (_locationRepository != null) {
        final response = await _locationRepository.getCurrentLocation();
        
        if (response.success && response.data != null) {
          emit(state.copyWith(
            status: LocationStatus.loaded,
            currentLocation: response.data!,
            error: null,
          ));
        } else {
          emit(state.copyWith(
            status: LocationStatus.error,
            error: response.message ?? 'Failed to get location',
          ));
        }
      } else {
        // Show error instead of mock data
        emit(state.copyWith(
          status: LocationStatus.error,
          error: 'Location service không khả dụng',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LocationStatus.error,
        error: 'Location error: $e',
      ));
    }
  }

  /// Search places
  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }

    emit(state.copyWith(isSearching: true));

    try {
      if (_locationRepository != null) {
        final response = await _locationRepository.searchPlaces(query);
        
        if (response.success && response.data != null) {
          emit(state.copyWith(
            searchResults: response.data!,
            isSearching: false,
          ));
        } else {
          emit(state.copyWith(
            searchResults: [],
            isSearching: false,
            error: response.message,
          ));
        }
      } else {
        // Show error instead of mock data
        emit(state.copyWith(
          searchResults: [],
          isSearching: false,
          error: 'Location service không khả dụng',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        searchResults: [],
        isSearching: false,
        error: 'Search error: $e',
      ));
    }
  }

  /// Get route between two points
  Future<void> getRoute({
    required LocationData origin,
    required LocationData destination,
  }) async {
    emit(state.copyWith(status: LocationStatus.loading));

    try {
      if (_locationRepository != null) {
        final response = await _locationRepository.getRoute(
          origin: origin,
          destination: destination,
        );
        
        if (response.success && response.data != null) {
          emit(state.copyWith(
            status: LocationStatus.loaded,
            currentRoute: response.data!,
            error: null,
          ));
        } else {
          emit(state.copyWith(
            status: LocationStatus.error,
            error: response.message ?? 'Failed to get route',
          ));
        }
      } else {
        emit(state.copyWith(
          status: LocationStatus.error,
          error: 'Location repository không khả dụng',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LocationStatus.error,
        error: 'Route error: $e',
      ));
    }
  }

  /// Start real-time location tracking
  Future<void> startLocationTracking() async {
    if (_locationRepository != null) {
      try {
        _locationSubscription?.cancel();
        _locationSubscription = _locationRepository
            .startLocationTracking()
            .listen(
          (location) {
            emit(state.copyWith(
              currentLocation: location,
              isTracking: true,
            ));
          },
          onError: (error) {
            emit(state.copyWith(
              status: LocationStatus.error,
              error: 'Tracking error: $error',
              isTracking: false,
            ));
          },
        );
      } catch (e) {
        emit(state.copyWith(
          status: LocationStatus.error,
          error: 'Failed to start tracking: $e',
        ));
      }
    }
  }

  /// Stop location tracking
  Future<void> stopLocationTracking() async {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    
    if (_locationRepository != null) {
      await _locationRepository.stopLocationTracking();
    }
    
    emit(state.copyWith(isTracking: false));
  }

  /// Get nearby drivers (for passengers)
  Future<void> getNearbyDrivers() async {
    if (state.currentLocation == null) {
      await getCurrentLocation();
    }

    if (state.currentLocation == null) return;

    try {
      if (_locationRepository != null) {
        final response = await _locationRepository.getNearbyDrivers(
          passengerLocation: state.currentLocation!,
          radiusKm: 5.0,
        );
        
        if (response.success && response.data != null) {
          emit(state.copyWith(nearbyDrivers: response.data!));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to get nearby drivers: $e',
      ));
    }
  }

  /// Set pickup and destination
  void setPickupLocation(LocationData location) {
    emit(state.copyWith(pickupLocation: location));
  }

  void setDestinationLocation(LocationData location) {
    emit(state.copyWith(destinationLocation: location));
    
    // Auto-calculate route if both locations are set
    if (state.pickupLocation != null) {
      getRoute(
        origin: state.pickupLocation!,
        destination: location,
      );
    }
  }

  /// Clear locations
  void clearLocations() {
    emit(state.copyWith(
      pickupLocation: null,
      destinationLocation: null,
      currentRoute: null,
      searchResults: [],
    ));
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
