import 'package:equatable/equatable.dart';

/// Google Login Request DTO for API communication
class GoogleLoginRequestDto extends Equatable {
  final String idToken;
  final String role;
  final String? deviceId;
  final String? deviceName;

  const GoogleLoginRequestDto({
    required this.idToken,
    required this.role,
    this.deviceId,
    this.deviceName,
  });

  /// Create from JSON
  factory GoogleLoginRequestDto.fromJson(Map<String, dynamic> json) {
    return GoogleLoginRequestDto(
      idToken: json['idToken'] ?? '',
      role: json['role'] ?? 'passenger',
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      'role': role,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
    };
  }

  /// Copy with
  GoogleLoginRequestDto copyWith({
    String? idToken,
    String? role,
    String? deviceId,
    String? deviceName,
  }) {
    return GoogleLoginRequestDto(
      idToken: idToken ?? this.idToken,
      role: role ?? this.role,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
    );
  }

  /// Validation
  List<String> validate() {
    final errors = <String>[];
    
    if (idToken.isEmpty) {
      errors.add('ID token is required');
    }
    
    if (role.isEmpty) {
      errors.add('Role is required');
    }
    
    if (!['passenger', 'driver'].contains(role.toLowerCase())) {
      errors.add('Role must be either passenger or driver');
    }
    
    return errors;
  }

  /// Check if valid
  bool get isValid => validate().isEmpty;

  @override
  List<Object?> get props => [idToken, role, deviceId, deviceName];

  @override
  String toString() => 'GoogleLoginRequestDto(role: $role, hasToken: ${idToken.isNotEmpty})';
}
