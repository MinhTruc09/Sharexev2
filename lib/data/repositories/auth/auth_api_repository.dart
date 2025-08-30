import 'package:sharexev2/core/auth/auth_manager.dart';
import 'package:sharexev2/data/models/auth/api/driver_dto.dart';
import 'package:sharexev2/data/models/auth/api/user_dto.dart';
import 'package:sharexev2/data/models/auth/app_user.dart';
import 'package:sharexev2/data/models/auth/dtos/auth_response_dto.dart';
import 'package:sharexev2/data/models/auth/mappers/app_user_mapper.dart';
import 'package:sharexev2/data/services/auth_service.dart';
import 'package:sharexev2/data/models/auth/api/login_request_dto.dart';
import 'package:sharexev2/data/repositories/auth/auth_repository.dart';

class AuthApiRepository implements AuthRepository {
  final AuthService _authService;
  final AuthManager _authManager;

  AuthApiRepository(this._authService, this._authManager);

  @override
  Future<bool> isLoggedIn() async {
    return _authManager.getToken() != null;
  }

  @override
  Future<String?> getAuthToken() async {
    return _authManager.getToken();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    return _authManager.currentUser;
  }

  @override
  Future<AppUser> loginWithEmail(String email, String password) async {
    final AuthResponseDto dto = await _authService.login(
      LoginRequestDTO(email: email, password: password),
    );

    final AppUser user = AppUserMapper.fromUserDto(dto.user as UserDTO);
    await _authManager.saveSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      user: user,
    );

    return user;
  }

  @override
  Future<AppUser> registerPassenger(
    String email,
    String password,
    String fullName,
  ) async {
    final AuthResponseDto dto = await _authService.registerPassenger({
      "email": email,
      "password": password,
      "fullName": fullName,
    });

    final AppUser user = AppUserMapper.fromUserDto(dto.user as UserDTO);
    await _authManager.saveSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      user: user,
    );

    return user;
  }

  @override
  Future<AppUser> registerDriver(
    String email,
    String password,
    String fullName,
    String licenseNumber,
  ) async {
    final dto = await _authService.registerDriver({
      "email": email,
      "password": password,
      "fullName": fullName,
      "licenseNumber": licenseNumber,
    });

    final user = AppUserMapper.fromDriverDto(dto.user as DriverDTO);

    await _authManager.saveSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      user: user,
    );

    return user;
  }

  @override
  Future<void> refreshToken() async {
    final token = _authManager.refreshToken;
    if (token == null) throw Exception("No refresh token found");

    final dto = await _authService.refreshToken(token);
    if (dto == null) {
      await logout();
      throw Exception("Refresh token failed");
    }

    final user = AppUserMapper.fromUserDto(dto.user as UserDTO);
    await _authManager.saveSession(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      user: user,
    );
  }

  @override
  Future<void> logout() async {
    await _authManager.clearSession();
  }
}
