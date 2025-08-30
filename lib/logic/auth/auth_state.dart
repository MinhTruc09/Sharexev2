import 'package:equatable/equatable.dart';
import 'package:sharexev2/data/models/auth/app_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isLoading;
  final bool isRegistering;
  final bool isGoogleSigningIn;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isLoading = false,
    this.isRegistering = false,
    this.isGoogleSigningIn = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isLoading,
    bool? isRegistering,
    bool? isGoogleSigningIn,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      isRegistering: isRegistering ?? this.isRegistering,
      isGoogleSigningIn: isGoogleSigningIn ?? this.isGoogleSigningIn,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    error,
    isLoading,
    isRegistering,
    isGoogleSigningIn,
  ];
}
