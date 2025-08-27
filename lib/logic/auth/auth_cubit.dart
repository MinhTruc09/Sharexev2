import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/services/navigation_service.dart';
import 'package:sharexev2/data/repositories/auth_repository.dart';
import 'package:sharexev2/logic/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authService;
  final NavigationService _navigationService = NavigationService();

  AuthCubit(this._authService) : super(const AuthState());

  // Kiểm tra trạng thái đăng nhập khi khởi động app
  Future<void> checkAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading, isLoading: true));

    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isLoading: false,
          ),
        );

        // Navigate to appropriate home screen based on user role
        _navigateToHome(user?.role ?? 'PASSENGER');
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
      final authResponse = await _authService.loginWithEmail(
        email,
        password,
        role,
        additionalData: additionalData,
      );

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: authResponse.user,
          isLoading: false,
        ),
      );

      // Navigate to home screen after successful login
      _navigateToHomeAndClear(role);
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
      final authResponse = await _authService.loginWithGoogle(role);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: authResponse.user,
          isGoogleSigningIn: false,
        ),
      );

      // Navigate to home screen after successful Google login
      _navigateToHomeAndClear(role);
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
    String role, {
    Map<String, dynamic>? additionalData,
  }) async {
    emit(state.copyWith(isRegistering: true, error: null));

    try {
      final authResponse = await _authService.register(
        email,
        password,
        name,
        role,
        additionalData: additionalData,
      );

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: authResponse.user,
          isRegistering: false,
        ),
      );

      // Navigate to home screen after successful registration
      _navigateToHomeAndClear(role);
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
      await _authService.logout();

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
      await _authService.refreshToken();

      // Lấy lại thông tin user sau khi refresh
      final user = await _authService.getCurrentUser();
      emit(state.copyWith(user: user));
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
}
