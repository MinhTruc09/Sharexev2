part of 'home_driver_cubit.dart';

enum HomeDriverStatus { initial, loading, ready, error }

class HomeDriverState {
  final HomeDriverStatus status;
  final String? error;
  final UserEntity? driverProfile;
  final List<ride_entity.RideEntity> myRides;
  final List<BookingEntity> pendingBookings;
  final double totalEarnings;
  final int completedTrips;

  // Earnings data
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;

  // Rides data
  final int todayRides;
  final int weeklyRides;
  final int monthlyRides;

  // Passengers data
  final int todayPassengers;
  final int weeklyPassengers;
  final int monthlyPassengers;

  // Drive time data
  final int todayDriveTime; // in minutes
  final int weeklyDriveTime; // in minutes
  final int monthlyDriveTime; // in minutes

  // Recent rides for home view
  final List<ride_entity.RideEntity> recentRides;

  // Filtered trips
  final List<ride_entity.RideEntity> allTrips;
  final List<ride_entity.RideEntity> activeTrips;
  final List<ride_entity.RideEntity> completedTripsList;
  final List<ride_entity.RideEntity> cancelledTrips;

  const HomeDriverState({
    this.status = HomeDriverStatus.initial,
    this.error,
    this.driverProfile,
    this.myRides = const [],
    this.pendingBookings = const [],
    this.totalEarnings = 0.0,
    this.completedTrips = 0,
    this.todayEarnings = 0.0,
    this.weeklyEarnings = 0.0,
    this.monthlyEarnings = 0.0,
    this.todayRides = 0,
    this.weeklyRides = 0,
    this.monthlyRides = 0,
    this.todayPassengers = 0,
    this.weeklyPassengers = 0,
    this.monthlyPassengers = 0,
    this.todayDriveTime = 0,
    this.weeklyDriveTime = 0,
    this.monthlyDriveTime = 0,
    this.recentRides = const [],
    this.allTrips = const [],
    this.activeTrips = const [],
    this.completedTripsList = const [],
    this.cancelledTrips = const [],
  });

  HomeDriverState copyWith({
    HomeDriverStatus? status,
    String? error,
    UserEntity? driverProfile,
    List<ride_entity.RideEntity>? myRides,
    List<BookingEntity>? pendingBookings,
    double? totalEarnings,
    int? completedTrips,
    double? todayEarnings,
    double? weeklyEarnings,
    double? monthlyEarnings,
    int? todayRides,
    int? weeklyRides,
    int? monthlyRides,
    int? todayPassengers,
    int? weeklyPassengers,
    int? monthlyPassengers,
    int? todayDriveTime,
    int? weeklyDriveTime,
    int? monthlyDriveTime,
    List<ride_entity.RideEntity>? recentRides,
    List<ride_entity.RideEntity>? allTrips,
    List<ride_entity.RideEntity>? activeTrips,
    List<ride_entity.RideEntity>? completedTripsList,
    List<ride_entity.RideEntity>? cancelledTrips,
  }) {
    return HomeDriverState(
      status: status ?? this.status,
      error: error ?? this.error,
      driverProfile: driverProfile ?? this.driverProfile,
      myRides: myRides ?? this.myRides,
      pendingBookings: pendingBookings ?? this.pendingBookings,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      completedTrips: completedTrips ?? this.completedTrips,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      todayRides: todayRides ?? this.todayRides,
      weeklyRides: weeklyRides ?? this.weeklyRides,
      monthlyRides: monthlyRides ?? this.monthlyRides,
      todayPassengers: todayPassengers ?? this.todayPassengers,
      weeklyPassengers: weeklyPassengers ?? this.weeklyPassengers,
      monthlyPassengers: monthlyPassengers ?? this.monthlyPassengers,
      todayDriveTime: todayDriveTime ?? this.todayDriveTime,
      weeklyDriveTime: weeklyDriveTime ?? this.weeklyDriveTime,
      monthlyDriveTime: monthlyDriveTime ?? this.monthlyDriveTime,
      recentRides: recentRides ?? this.recentRides,
      allTrips: allTrips ?? this.allTrips,
      activeTrips: activeTrips ?? this.activeTrips,
      completedTripsList: completedTripsList ?? this.completedTripsList,
      cancelledTrips: cancelledTrips ?? this.cancelledTrips,
    );
  }
}
