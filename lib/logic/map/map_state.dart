// map_state.dart

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

// state khi đã có kết quả tìm kiếm địa chỉ
class MapSearchResult extends MapState {
  final List<LatLng> results;

  const MapSearchResult(this.results);
  @override
  List<Object?> get props => [results];
}

// state khi mở chi tiết chuyến đi (Map tĩnh hoặc có thể zoom)

class MapTripDetailLoaded extends MapState {
  final LatLng driverLocation;
  final LatLng? passengerLocation;

  const MapTripDetailLoaded({
    required this.driverLocation,
    this.passengerLocation,
  });
  @override
  List<Object?> get props => [driverLocation, passengerLocation];
}

// khi có lỗi

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final double lat;
  final double lng;
  final List<LatLng> polylinePoints; // để show đường đi
  MapLoaded({
    required this.lat,
    required this.lng,
    required this.polylinePoints,
  });
}

class MapError extends MapState {
  final String message;
  MapError(this.message);
}

// State khi đang tracking driver
class MapTracking extends MapState {
  final LatLng driverLocation;
  final LatLng? passengerLocation;

  const MapTracking({
    required this.driverLocation,
    this.passengerLocation,
  });
  
  @override
  List<Object?> get props => [driverLocation, passengerLocation];
}
