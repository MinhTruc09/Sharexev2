// DTO: Refresh Token Request
class RefreshTokenRequestDto {
  final String refreshToken;

  RefreshTokenRequestDto({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refresh_token': refreshToken, 'refreshToken': refreshToken};
  }

  factory RefreshTokenRequestDto.fromJson(Map<String, dynamic> json) {
    return RefreshTokenRequestDto(
      refreshToken:
          json['refresh_token'] as String? ?? json['refreshToken'] as String,
    );
  }
}
