//map_event.dart
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

// khi passenger bấm vào ô tìm kiếm địa chỉ
class SearchNearbyPlaces extends MapEvent {
  final String query; // ví dụ : Trường đại học giao thông vận tải
  final LatLng currentLocation;

  const SearchNearbyPlaces({
    required this.currentLocation,
    required this.query,
  });

  @override
  List<Object?> get props => [query, currentLocation];
}

// khi mở chi tiết chuyến, load map tại vị trí tài xế chọn
class LoadTripDetailMap extends MapEvent {
  final LatLng driverLocation;
  final LatLng? passengerLocation;

  const LoadTripDetailMap({
    required this.driverLocation,
    this.passengerLocation,
  });

  @override
  List<Object?> get props => [driverLocation, passengerLocation];
}

// khi tracking hành trình (real-time location update)

class StartTrackingDriver extends MapEvent {
  final String tripId; // id của chuyến đi

  const StartTrackingDriver(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

// stop tracking khi chuyến kết thúc
class StopTrackingDriver extends MapEvent {}

class LoadMap extends MapEvent {
  final double lat;
  final double lng;
  LoadMap(this.lat, this.lng);
}

class UpdateTracker extends MapEvent {
  final double lat;
  final double lng;
  UpdateTracker(this.lat, this.lng);
}

class DrawPolyline extends MapEvent {
  final List<LatLng> polylinePoints;
  DrawPolyline(this.polylinePoints);
}
