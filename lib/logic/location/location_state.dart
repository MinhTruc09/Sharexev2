part of 'location_cubit.dart';

enum LocationStatus {
  initial,
  loading,
  loaded,
  error,
}

class LocationState {
  final LocationStatus status;
  final String? error;
  final LocationData? currentLocation;
  final LocationData? pickupLocation;
  final LocationData? destinationLocation;
  final RouteData? currentRoute;
  final List<LocationData> searchResults;
  final List<LocationData> nearbyDrivers;
  final bool isSearching;
  final bool isTracking;

  const LocationState({
    this.status = LocationStatus.initial,
    this.error,
    this.currentLocation,
    this.pickupLocation,
    this.destinationLocation,
    this.currentRoute,
    this.searchResults = const [],
    this.nearbyDrivers = const [],
    this.isSearching = false,
    this.isTracking = false,
  });

  LocationState copyWith({
    LocationStatus? status,
    String? error,
    LocationData? currentLocation,
    LocationData? pickupLocation,
    LocationData? destinationLocation,
    RouteData? currentRoute,
    List<LocationData>? searchResults,
    List<LocationData>? nearbyDrivers,
    bool? isSearching,
    bool? isTracking,
  }) {
    return LocationState(
      status: status ?? this.status,
      error: error,
      currentLocation: currentLocation ?? this.currentLocation,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      currentRoute: currentRoute ?? this.currentRoute,
      searchResults: searchResults ?? this.searchResults,
      nearbyDrivers: nearbyDrivers ?? this.nearbyDrivers,
      isSearching: isSearching ?? this.isSearching,
      isTracking: isTracking ?? this.isTracking,
    );
  }
}
