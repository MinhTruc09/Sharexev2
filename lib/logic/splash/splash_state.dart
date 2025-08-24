import 'package:equatable/equatable.dart';

enum SplashStatus { initial, loading, success, error }

class SplashState extends Equatable {
  final SplashStatus status;
  final String? message;
  final String? route;

  const SplashState({
    this.status = SplashStatus.initial,
    this.message,
    this.route,
  });

  SplashState copyWith({SplashStatus? status, String? message, String? route}) {
    return SplashState(
      status: status ?? this.status,
      message: message ?? this.message,
      route: route ?? this.route,
    );
  }

  @override
  List<Object?> get props => [status, message, route];
}
