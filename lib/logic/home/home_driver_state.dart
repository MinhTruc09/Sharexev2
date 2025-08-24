part of 'home_driver_cubit.dart';

enum HomeDriverStatus { initial, loading, ready, error }

class HomeDriverState {
  final HomeDriverStatus status;
  final String? error;

  const HomeDriverState({
    this.status = HomeDriverStatus.initial,
    this.error,
  });

  HomeDriverState copyWith({
    HomeDriverStatus? status,
    String? error,
  }) {
    return HomeDriverState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

