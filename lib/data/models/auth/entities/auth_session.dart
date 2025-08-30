// Domain Entity: AuthSession
// Quản lý session và token lifecycle

/// Domain Entity: AuthSession
/// Chứa thông tin về phiên đăng nhập của user
class AuthSession {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final DateTime issuedAt;
  final String? deviceId;
  final String? ipAddress;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.issuedAt,
    this.deviceId,
    this.ipAddress,
  });

  // ===== Business Logic =====

  /// Kiểm tra token có hết hạn không
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Kiểm tra token sắp hết hạn (trong 5 phút)
  bool get isExpiringSoon {
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return fiveMinutesFromNow.isAfter(expiresAt);
  }

  /// Kiểm tra session có hợp lệ không
  bool get isValid {
    return accessToken.isNotEmpty && refreshToken.isNotEmpty && !isExpired;
  }

  /// Thời gian còn lại của session (seconds)
  int get remainingSeconds {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inSeconds;
  }

  /// Thời gian session đã tồn tại (seconds)
  int get ageInSeconds {
    return DateTime.now().difference(issuedAt).inSeconds;
  }

  /// Whether session can be refreshed (has refresh token and not too old)
  bool get canRefresh {
    return refreshToken.isNotEmpty && !isExpired;
  }

  // ===== Validation =====

  List<String> validate() {
    final errors = <String>[];

    if (accessToken.isEmpty) {
      errors.add('Access token không được để trống');
    }

    if (refreshToken.isEmpty) {
      errors.add('Refresh token không được để trống');
    }

    if (expiresAt.isBefore(issuedAt)) {
      errors.add('Thời gian hết hạn không thể trước thời gian tạo');
    }

    if (isExpired) {
      errors.add('Session đã hết hạn');
    }

    return errors;
  }

  // ===== Equality & Hash =====

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthSession &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => Object.hash(accessToken, refreshToken);

  // ===== Copy Methods =====

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    DateTime? issuedAt,
    String? deviceId,
    String? ipAddress,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      issuedAt: issuedAt ?? this.issuedAt,
      deviceId: deviceId ?? this.deviceId,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }

  /// Tạo session mới với token mới (khi refresh)
  AuthSession refreshWith({
    required String newAccessToken,
    required String newRefreshToken,
    required DateTime newExpiresAt,
  }) {
    return copyWith(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      expiresAt: newExpiresAt,
      issuedAt: DateTime.now(),
    );
  }

  // ===== JSON Serialization =====

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'issuedAt': issuedAt.toIso8601String(),
      if (deviceId != null) 'deviceId': deviceId,
      if (ipAddress != null) 'ipAddress': ipAddress,
    };
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken:
          json['accessToken'] as String? ??
          json['access_token'] as String? ??
          '',
      refreshToken:
          json['refreshToken'] as String? ??
          json['refresh_token'] as String? ??
          '',
      expiresAt: DateTime.parse(
        json['expiresAt'] as String? ?? json['expires_at'] as String,
      ),
      issuedAt: DateTime.parse(
        json['issuedAt'] as String? ?? json['issued_at'] as String,
      ),
      deviceId: json['deviceId'] as String? ?? json['device_id'] as String?,
      ipAddress: json['ipAddress'] as String? ?? json['ip_address'] as String?,
    );
  }

  @override
  String toString() {
    return 'AuthSession(expiresAt: $expiresAt, isExpired: $isExpired, deviceId: $deviceId)';
  }
}
