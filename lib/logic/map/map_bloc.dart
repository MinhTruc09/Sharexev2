import 'package:flutter_bloc/flutter_bloc.dart';
import 'map_event.dart';
import 'map_state.dart';
import 'package:latlong2/latlong.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/data/repositories/location/location_repository_interface.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationRepositoryInterface _locationRepository;
  
  MapBloc({LocationRepositoryInterface? locationRepository}) 
    : _locationRepository = locationRepository ?? ServiceLocator.get<LocationRepositoryInterface>(),
      super(MapInitial()) {
    on<SearchNearbyPlaces>(_onSearchNearbyPlaces);
    on<LoadTripDetailMap>(_onLoadTripDetailMap);
    on<StartTrackingDriver>(_onStartTrackingDriver);
    on<StopTrackingDriver>(_onStopTrackingDriver);
    on<LoadMap>(_onLoadMap);
    on<UpdateTracker>(_onUpdateTracker);
    on<DrawPolyline>(_onDrawPolyline);
  }

  /// Handle search address with real API
  Future<void> _onSearchNearbyPlaces(
    SearchNearbyPlaces event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());

    try {
      // Use real location repository
      final result = await _locationRepository.searchPlaces(event.query);
      
      if (result.success) {
        // Convert LocationData to LatLng for map display
        final latLngList = result.data?.map((location) => 
          LatLng(location.latitude, location.longitude)
        ).toList() ?? [];
        emit(MapSearchResult(latLngList));
      } else {
        emit(MapError(result.message));
      }
    } catch (e) {
      emit(MapError('Lỗi tìm kiếm địa điểm: $e'));
    }
  }

  /// Handle load trip detail
  void _onLoadTripDetailMap(LoadTripDetailMap event, Emitter<MapState> emit) {
    emit(
      MapTripDetailLoaded(
        driverLocation: event.driverLocation,
        passengerLocation: event.passengerLocation,
      ),
    );
  }

  /// Handle tracking driver with real-time updates
  Future<void> _onStartTrackingDriver(
    StartTrackingDriver event,
    Emitter<MapState> emit,
  ) async {
    try {
      // Start location tracking for driver
      final locationStream = _locationRepository.startLocationTracking();
      
      // Listen to real-time location updates
      locationStream.listen((locationData) {
        final driverLocation = LatLng(locationData.latitude, locationData.longitude);
        emit(MapTracking(
          driverLocation: driverLocation,
          passengerLocation: null, // Will be updated from trip data
        ));
      });
      
      // Initial location
      final currentLocation = await _locationRepository.getCurrentLocation();
      if (currentLocation.success) {
        emit(MapTracking(
          driverLocation: LatLng(
            currentLocation.data!.latitude, 
            currentLocation.data!.longitude
          ),
          passengerLocation: null,
        ));
      }
    } catch (e) {
      emit(MapError('Lỗi theo dõi tài xế: $e'));
    }
  }

  /// Handle stop tracking
  void _onStopTrackingDriver(StopTrackingDriver event, Emitter<MapState> emit) {
    // Stop listening to location updates
    _locationRepository.stopLocationTracking();
    emit(MapInitial());
  }

  /// Handle load map
  void _onLoadMap(LoadMap event, Emitter<MapState> emit) {
    emit(MapLoaded(
      lat: event.lat,
      lng: event.lng,
      polylinePoints: [],
    ));
  }

  /// Handle update tracker
  void _onUpdateTracker(UpdateTracker event, Emitter<MapState> emit) {
    if (state is MapTracking) {
      final currentState = state as MapTracking;
      emit(MapTracking(
        driverLocation: LatLng(event.lat, event.lng),
        passengerLocation: currentState.passengerLocation,
      ));
    }
  }

  /// Handle draw polyline
  void _onDrawPolyline(DrawPolyline event, Emitter<MapState> emit) {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(MapLoaded(
        lat: currentState.lat,
        lng: currentState.lng,
        polylinePoints: event.polylinePoints,
      ));
    }
  }
}
