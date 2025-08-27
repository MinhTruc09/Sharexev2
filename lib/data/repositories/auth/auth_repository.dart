import 'package:sharexev2/data/models/auth/app_user.dart';

abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<String?> getAuthToken();
  Future<AppUser?> getCurrentUser();

  Future<AppUser> loginWithEmail(String email, String password);
  Future<AppUser> registerPassenger(
    String email,
    String password,
    String fullName,
  );
  Future<AppUser> registerDriver(
    String email,
    String password,
    String fullName,
    String licenseNumber,
  );

  Future<void> refreshToken();
  Future<void> logout();
}
