import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/services/navigation_service.dart';
import 'package:sharexev2/data/repositories/auth/auth_repository_interface.dart';
import 'package:sharexev2/data/models/auth/entities/auth_credentials.dart';
import 'package:sharexev2/data/models/auth/entities/user_role.dart';
import 'package:sharexev2/data/models/auth/app_user.dart';
import 'package:sharexev2/logic/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepositoryInterface? _authRepository;
  final NavigationService _navigationService = NavigationService();

  AuthCubit(this._authRepository) : super(const AuthState());

  // Kiểm tra trạng thái đăng nhập khi khởi động app
  Future<void> checkAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading, isLoading: true));

    try {
      final isLoggedIn = await _authRepository?.isLoggedIn() ?? false;

      if (isLoggedIn) {
        final currentUser = await _authRepository?.getCurrentUser();
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: currentUser,
            isLoading: false,
          ),
        );

        // Navigate to home screen based on user role
        final role = currentUser?.role.name ?? 'PASSENGER';
        _navigateToHome(role);
      } else {
        emit(
          state.copyWith(status: AuthStatus.unauthenticated, isLoading: false),
        );

        // Navigate to role selection if not logged in
        _navigationService.navigateToRoleSelection();
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: e.toString(),
          isLoading: false,
        ),
      );
    }
  }

  // Đăng nhập bằng email/password
  Future<void> loginWithEmail(
    String email,
    String password,
    String role, {
    Map<String, dynamic>? additionalData,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final credentials = AuthCredentials(email: email, password: password);
      final authResult = await _authRepository?.loginWithCredentials(
        credentials,
      );

      if (authResult?.isSuccess == true && authResult?.user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: authResult!.user,
            isLoading: false,
          ),
        );

        // Navigate to home screen based on user role
        _navigateToHomeAndClear(authResult.user!.role.name);
      } else {
        throw Exception(authResult?.failure?.message ?? 'Login failed');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: e.toString(),
          isLoading: false,
        ),
      );
    }
  }

  // Đăng nhập bằng Google
  Future<void> loginWithGoogle(String role) async {
    emit(state.copyWith(isGoogleSigningIn: true, error: null));

    try {
      // Google Sign In not yet fully implemented
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error:
              'Đăng nhập Google đang được phát triển, vui lòng sử dụng email/password',
          isGoogleSigningIn: false,
        ),
      );
      return;
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: e.toString(),
          isGoogleSigningIn: false,
        ),
      );
    }
  }

  // Đăng ký
  Future<void> register(
    String email,
    String password,
    String name,
    String phoneNumber,
    String role, {
    Map<String, dynamic>? additionalData,
  }) async {
    emit(state.copyWith(isRegistering: true, error: null));

    try {
      final userRole = UserRole.values.firstWhere(
        (r) => r.name.toLowerCase() == role.toLowerCase(),
        orElse: () => UserRole.passenger,
      );

      final registerCredentials = RegisterCredentials(
        email: email,
        password: password,
        fullName: name,
        phoneNumber: phoneNumber,
      );

      final authResult =
          userRole == UserRole.driver
              ? await _authRepository?.registerDriver(registerCredentials)
              : await _authRepository?.registerPassenger(registerCredentials);

      if (authResult?.isSuccess == true && authResult?.user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: authResult!.user,
            isRegistering: false,
          ),
        );

        // Navigate to home screen after successful registration
        _navigateToHomeAndClear(authResult.user!.role.name);
      } else {
        throw Exception(authResult?.failure?.message ?? 'Registration failed');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: e.toString(),
          isRegistering: false,
        ),
      );
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    emit(state.copyWith(isLoading: true));

    try {
      await _authRepository?.clearSession();

      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          isLoading: false,
        ),
      );

      // Navigate to login screen and clear navigation stack
      _navigationService.navigateToLoginAndClear();
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: e.toString(),
          isLoading: false,
        ),
      );
    }
  }

  // Refresh token
  Future<void> refreshToken() async {
    try {
      final authResult = await _authRepository?.refreshToken();

      if (authResult?.isSuccess == true && authResult?.user != null) {
        emit(state.copyWith(user: authResult!.user));
      } else {
        // Nếu refresh thất bại, đăng xuất
        await logout();
      }
    } catch (e) {
      // Nếu refresh thất bại, đăng xuất
      await logout();
    }
  }

  // Xóa lỗi
  void clearError() {
    emit(state.copyWith(error: null));
  }

  // Reset state về initial
  void reset() {
    emit(const AuthState());
  }

  // MARK: - Navigation Helper Methods

  /// Navigate to home screen based on user role
  void _navigateToHome(String role) {
    _navigationService.navigateToHome(role);
  }

  /// Navigate to home screen and clear navigation stack
  void _navigateToHomeAndClear(String role) {
    _navigationService.navigateToHomeAndClear(role);
  }

  /// Navigate to profile screen based on user role
  void navigateToProfile(String role) {
    _navigationService.navigateToProfile(role);
  }

  /// Navigate to chat rooms
  void navigateToChatRooms() {
    _navigationService.navigateToChatRooms();
  }

  /// Navigate to specific chat room
  void navigateToChat({
    required String roomId,
    required String participantName,
    String? participantEmail,
  }) {
    _navigationService.navigateToChat(
      roomId: roomId,
      participantName: participantName,
      participantEmail: participantEmail,
    );
  }

  /// Navigate to trip detail
  void navigateToTripDetail(Map<String, dynamic> tripData) {
    _navigationService.navigateToTripDetail(tripData: tripData);
  }

  /// Navigate to trip review
  void navigateToTripReview({
    required Map<String, dynamic> tripData,
    String role = 'PASSENGER',
  }) {
    _navigationService.navigateToTripReview(tripData: tripData, role: role);
  }

  // MARK: - Helper Methods
  // All DTO to Entity conversion is now handled by AuthRepository
}
