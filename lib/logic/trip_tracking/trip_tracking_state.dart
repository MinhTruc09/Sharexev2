part of 'trip_tracking_cubit.dart';

enum TripTrackingStatus {
  initial,
  loading,
  tracking,
  completed,
  cancelled,
  error,
}

enum TripPhase {
  driverEnRoute,    // Driver is coming to pickup
  arrived,          // Driver has arrived at pickup
  inProgress,       // Trip is in progress
  completed,        // Trip completed
  cancelled,        // Trip cancelled
}

class TripTrackingState {
  final TripTrackingStatus status;
  final String? error;
  final BookingEntity? currentBooking;
  final TripPhase tripPhase;
  final LocationData? driverLocation;
  final int? estimatedArrivalMinutes;
  final DateTime? pickupTime;
  final DateTime? completionTime;
  final DateTime? lastLocationUpdate;
  final String? cancellationReason;

  const TripTrackingState({
    this.status = TripTrackingStatus.initial,
    this.error,
    this.currentBooking,
    this.tripPhase = TripPhase.driverEnRoute,
    this.driverLocation,
    this.estimatedArrivalMinutes,
    this.pickupTime,
    this.completionTime,
    this.lastLocationUpdate,
    this.cancellationReason,
  });

  TripTrackingState copyWith({
    TripTrackingStatus? status,
    String? error,
    BookingEntity? currentBooking,
    TripPhase? tripPhase,
    LocationData? driverLocation,
    int? estimatedArrivalMinutes,
    DateTime? pickupTime,
    DateTime? completionTime,
    DateTime? lastLocationUpdate,
    String? cancellationReason,
  }) {
    return TripTrackingState(
      status: status ?? this.status,
      error: error,
      currentBooking: currentBooking ?? this.currentBooking,
      tripPhase: tripPhase ?? this.tripPhase,
      driverLocation: driverLocation ?? this.driverLocation,
      estimatedArrivalMinutes: estimatedArrivalMinutes ?? this.estimatedArrivalMinutes,
      pickupTime: pickupTime ?? this.pickupTime,
      completionTime: completionTime ?? this.completionTime,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  // Helper getters
  bool get isDriverEnRoute => tripPhase == TripPhase.driverEnRoute;
  bool get isDriverArrived => tripPhase == TripPhase.arrived;
  bool get isTripInProgress => tripPhase == TripPhase.inProgress;
  bool get isTripCompleted => tripPhase == TripPhase.completed;
  bool get isTripCancelled => tripPhase == TripPhase.cancelled;

  String get tripPhaseDisplayText {
    switch (tripPhase) {
      case TripPhase.driverEnRoute:
        return 'Tài xế đang đến';
      case TripPhase.arrived:
        return 'Tài xế đã đến';
      case TripPhase.inProgress:
        return 'Đang di chuyển';
      case TripPhase.completed:
        return 'Hoàn thành';
      case TripPhase.cancelled:
        return 'Đã hủy';
    }
  }

  String? get etaDisplayText {
    if (estimatedArrivalMinutes == null) return null;
    
    if (estimatedArrivalMinutes! < 1) {
      return 'Sắp đến';
    } else if (estimatedArrivalMinutes! == 1) {
      return '1 phút';
    } else {
      return '$estimatedArrivalMinutes phút';
    }
  }
}
