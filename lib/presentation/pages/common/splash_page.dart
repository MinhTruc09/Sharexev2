import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/services/auth_service.dart';
import 'package:sharexev2/routes/app_routes.dart';
import 'package:sharexev2/logic/splash/splash_cubit.dart';
import 'package:sharexev2/logic/splash/splash_state.dart';
import 'package:sharexev2/presentation/views/splash_view.dart';

class SplashPage extends StatefulWidget {
  final String?
  overrideRole; // 'PASSENGER' | 'DRIVER' nếu gọi từ Role Selection
  const SplashPage({super.key, this.overrideRole});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = SplashCubit(AuthService());
    // Bắt đầu kiểm tra, nếu có overrideRole thì bỏ qua kiểm tra đăng nhập
    _cubit.checkLoginStatus(overrideRole: widget.overrideRole);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SplashCubit, SplashState>(
        listenWhen:
            (prev, curr) => prev.route != curr.route && curr.route != null,
        listener: (context, state) {
          // Điều hướng khi có route
          if (state.route != null) {
            Navigator.pushReplacementNamed(context, state.route!);
          }
        },
        child: BlocBuilder<SplashCubit, SplashState>(
          builder: (context, state) {
            if (state.status == SplashStatus.loading ||
                state.status == SplashStatus.initial) {
              return SplashView(role: widget.overrideRole);
            }

            if (state.status == SplashStatus.success) {
              String? role;
              if (state.route == AppRoute.homePassenger) {
                role = 'PASSENGER';
              } else if (state.route == AppRoute.homeDriver) {
                role = 'DRIVER';
              } else {
                role = null;
              }
              return SplashView(role: role);
            }

            if (state.status == SplashStatus.error) {
              return Center(child: Text(state.message ?? 'Có lỗi xảy ra'));
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
