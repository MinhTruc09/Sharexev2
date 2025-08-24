part of 'ride_cubit.dart';

class RideState {
  final bool isLoading;
  final String? error;
  final List<dynamic> rides;

  const RideState({
    this.isLoading = false,
    this.error,
    this.rides = const [],
  });

  RideState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? rides,
  }) {
    return RideState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      rides: rides ?? this.rides,
    );
  }
}
