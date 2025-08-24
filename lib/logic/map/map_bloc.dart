import 'package:flutter_bloc/flutter_bloc.dart';
import 'map_event.dart';
import 'map_state.dart';
import 'package:latlong2/latlong.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapInitial()) {
    on<SearchNearbyPlaces>(_onSearchNearbyPlaces);
    on<LoadTripDetailMap>(_onLoadTripDetailMap);
    on<StartTrackingDriver>(_onStartTrackingDriver);
    on<StopTrackingDriver>(_onStopTrackingDriver);
  }

  /// Handle search address
  Future<void> _onSearchNearbyPlaces(
    SearchNearbyPlaces event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());

    try {
      // 🔥 TODO: Call API hoặc Firestore ở đây
      // Ví dụ: Google Places API hoặc Firestore "locations" collection
      // final results = await locationRepository.searchNearby(event.query, event.currentLocation);

      // fake data
      await Future.delayed(Duration(seconds: 1));
      emit(
        MapSearchResult([
          LatLng(
            event.currentLocation.latitude + 0.001,
            event.currentLocation.longitude + 0.001,
          ),
          LatLng(
            event.currentLocation.latitude - 0.001,
            event.currentLocation.longitude - 0.001,
          ),
        ]),
      );
    } catch (e) {
      emit(MapError(e.toString()));
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

  /// Handle tracking driver
  Future<void> _onStartTrackingDriver(
    StartTrackingDriver event,
    Emitter<MapState> emit,
  ) async {
    try {
      // 🔥 TODO: Subcribe real-time vị trí từ Firestore hoặc WebSocket
      // Firestore: collection("trips").doc(event.tripId).snapshots()

      // fake streaming location update
      LatLng driver = LatLng(10.762622, 106.660172); // HCM
      LatLng passenger = LatLng(10.776889, 106.700806);

      emit(MapTracking(driverLocation: driver, passengerLocation: passenger));
    } catch (e) {
      emit(MapError(e.toString()));
    }
  }

  /// Handle stop tracking
  void _onStopTrackingDriver(StopTrackingDriver event, Emitter<MapState> emit) {
    emit(MapInitial());
  }
}
