part of 'home_driver_cubit.dart';

enum HomeDriverStatus { initial, loading, ready, error }

class HomeDriverState {
  final HomeDriverStatus status;
  final String? error;
  final UserEntity? driverProfile;
  final List<RideEntity> myRides;
  final List<BookingEntity> pendingBookings;
  final double totalEarnings;
  final int completedTrips;

  const HomeDriverState({
    this.status = HomeDriverStatus.initial,
    this.error,
    this.driverProfile,
    this.myRides = const [],
    this.pendingBookings = const [],
    this.totalEarnings = 0.0,
    this.completedTrips = 0,
  });

  HomeDriverState copyWith({
    HomeDriverStatus? status,
    String? error,
    UserEntity? driverProfile,
    List<RideEntity>? myRides,
    List<BookingEntity>? pendingBookings,
    double? totalEarnings,
    int? completedTrips,
  }) {
    return HomeDriverState(
      status: status ?? this.status,
      error: error ?? this.error,
      driverProfile: driverProfile ?? this.driverProfile,
      myRides: myRides ?? this.myRides,
      pendingBookings: pendingBookings ?? this.pendingBookings,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      completedTrips: completedTrips ?? this.completedTrips,
    );
  }
}

