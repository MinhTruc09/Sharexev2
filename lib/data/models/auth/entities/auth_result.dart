// lib/data/models/auth/entities/auth_result.dart
// Domain Entity - Auth Operation Result

import 'package:equatable/equatable.dart';
import '../app_user.dart';
import 'auth_session.dart';

/// Result của auth operations
class AuthResult extends Equatable {
  final bool isSuccess;
  final User? user;
  final AuthSession? session;
  final AuthFailure? failure;

  const AuthResult._({
    required this.isSuccess,
    this.user,
    this.session,
    this.failure,
  });

  /// Success result
  factory AuthResult.success(User user, AuthSession session) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      session: session,
    );
  }

  /// Failure result
  factory AuthResult.failure(AuthFailure failure) {
    return AuthResult._(
      isSuccess: false,
      failure: failure,
    );
  }

  /// Check if result is failure
  bool get isFailure => !isSuccess;

  /// Get error message if failed
  String? get errorMessage => failure?.message;

  /// Get error code if failed
  String? get errorCode => failure?.code;

  @override
  List<Object?> get props => [isSuccess, user, session, failure];

  @override
  String toString() {
    if (isSuccess) {
      return 'AuthResult.success(user: ${user?.email}, session: ${session?.isValid})';
    } else {
      return 'AuthResult.failure(${failure?.message})';
    }
  }
}

/// Auth failure types
class AuthFailure extends Equatable {
  final String message;
  final String? code;
  final AuthFailureType type;
  final Map<String, dynamic>? details;

  const AuthFailure._({
    required this.message,
    this.code,
    required this.type,
    this.details,
  });

  /// Validation failure
  factory AuthFailure.validation(String message, {String? code}) {
    return AuthFailure._(
      message: message,
      code: code,
      type: AuthFailureType.validation,
    );
  }

  /// Network failure
  factory AuthFailure.network(String message, {String? code}) {
    return AuthFailure._(
      message: message,
      code: code,
      type: AuthFailureType.network,
    );
  }

  /// Server failure
  factory AuthFailure.server(String message, {String? code, Map<String, dynamic>? details}) {
    return AuthFailure._(
      message: message,
      code: code,
      type: AuthFailureType.server,
      details: details,
    );
  }

  /// Service failure
  factory AuthFailure.service(String message, {String? code, Map<String, dynamic>? details}) {
    return AuthFailure._(
      message: message,
      code: code,
      type: AuthFailureType.service,
      details: details,
    );
  }

  /// Session failure
  factory AuthFailure.session(String message, {String? code}) {
    return AuthFailure._(
      message: message,
      code: code,
      type: AuthFailureType.session,
    );
  }

  /// Unknown failure
  factory AuthFailure.unknown(String message, {String? code}) {
    return AuthFailure._(
      message: message,
      code: code,
      type: AuthFailureType.unknown,
    );
  }

  @override
  List<Object?> get props => [message, code, type, details];

  @override
  String toString() {
    return 'AuthFailure(type: $type, message: $message, code: $code)';
  }
}

/// Types of auth failures
enum AuthFailureType {
  validation,
  network,
  server,
  service,
  session,
  unknown,
}

extension AuthFailureTypeExtension on AuthFailureType {
  String get displayName {
    switch (this) {
      case AuthFailureType.validation:
        return 'Validation Error';
      case AuthFailureType.network:
        return 'Network Error';
      case AuthFailureType.server:
        return 'Server Error';
      case AuthFailureType.service:
        return 'Service Error';
      case AuthFailureType.session:
        return 'Session Error';
      case AuthFailureType.unknown:
        return 'Unknown Error';
    }
  }

  bool get isRetryable {
    switch (this) {
      case AuthFailureType.network:
      case AuthFailureType.server:
        return true;
      case AuthFailureType.validation:
      case AuthFailureType.service:
      case AuthFailureType.session:
      case AuthFailureType.unknown:
        return false;
    }
  }
}
