part of 'ride_cubit.dart';

enum RideStatus { initial, loading, loaded, created, success, cancelled, error }

class RideState {
  final RideStatus status;
  final String? error;
  final String? message;
  final List<ride_entity.RideEntity> rides;
  final ride_entity.RideEntity? currentRide;

  const RideState({
    this.status = RideStatus.initial,
    this.error,
    this.message,
    this.rides = const [],
    this.currentRide,
  });

  RideState copyWith({
    RideStatus? status,
    String? error,
    String? message,
    List<ride_entity.RideEntity>? rides,
    ride_entity.RideEntity? currentRide,
  }) {
    return RideState(
      status: status ?? this.status,
      error: error ?? this.error,
      message: message ?? this.message,
      rides: rides ?? this.rides,
      currentRide: currentRide ?? this.currentRide,
    );
  }
}
