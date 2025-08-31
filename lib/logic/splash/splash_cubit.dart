import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_state.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';

class SplashCubit extends Cubit<SplashState> {
  final AuthService authService;
  SplashCubit(this.authService) : super(const SplashState());

  Future<void> checkLoginStatus({String? overrideRole}) async {
    emit(state.copyWith(status: SplashStatus.loading));

    try {
      // Giữ splash 2 giây
      await Future.delayed(const Duration(seconds: 2));

      // Nếu đã biết role từ luồng role selection thì bỏ qua kiểm tra đăng nhập
      if (overrideRole != null) {
        if (overrideRole == 'PASSENGER') {
          emit(state.copyWith(status: SplashStatus.success, route: AppRoute.homePassenger));
        } else {
          emit(state.copyWith(status: SplashStatus.success, route: AppRoute.homeDriver));
        }
        return;
      }

      bool isLoggedIn = await authService.isLoggedIn();

      if (isLoggedIn) {
        // TODO: Implement getCurrentUserRole in AuthService
        // String? role = await authService.getCurrentUserRole();

        // Mock user role for now
        String? role = 'PASSENGER';

        if (role == 'PASSENGER') {
          emit(
            state.copyWith(
              status: SplashStatus.success,
              route: AppRoute.homePassenger,
            ),
          );
        } else if (role == 'DRIVER') {
          emit(
            state.copyWith(
              status: SplashStatus.success,
              route: AppRoute.homeDriver,
            ),
          );
        } else {
          // Nếu không xác định role
          emit(
            state.copyWith(status: SplashStatus.success, route: AppRoute.roleSelection),
          );
        }
      } else {
        // Nếu chưa đăng nhập
        emit(
          state.copyWith(status: SplashStatus.success, route: AppRoute.roleSelection),
        );
      }
    } catch (e) {
      emit(state.copyWith(status: SplashStatus.error, message: e.toString()));
    }
  }
}
