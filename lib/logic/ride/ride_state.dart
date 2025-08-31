part of 'ride_cubit.dart';

enum RideStatus {
  initial,
  loading,
  loaded,
  created,
  cancelled,
  error,
}

class RideState {
  final RideStatus status;
  final String? error;
  final List<RideEntity> rides;
  final RideEntity? currentRide;

  const RideState({
    this.status = RideStatus.initial,
    this.error,
    this.rides = const [],
    this.currentRide,
  });

  RideState copyWith({
    RideStatus? status,
    String? error,
    List<RideEntity>? rides,
    RideEntity? currentRide,
  }) {
    return RideState(
      status: status ?? this.status,
      error: error ?? this.error,
      rides: rides ?? this.rides,
      currentRide: currentRide ?? this.currentRide,
    );
  }
}
