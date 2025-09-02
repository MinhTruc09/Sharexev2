import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/auth/auth_cubit.dart';
import 'package:sharexev2/logic/auth/auth_state.dart';
import 'package:sharexev2/presentation/views/auth/login_view.dart';
import 'package:sharexev2/presentation/widgets/shared/role_based_container.dart';
import 'package:sharexev2/routes/app_routes.dart';

/// Login Page with Cubit integration
class LoginPage extends StatelessWidget {
  final String role;

  const LoginPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(ServiceLocator.get()),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // Handle authentication success
          if (state.status == AuthStatus.authenticated) {
            final route = role.toUpperCase() == 'PASSENGER'
                ? AppRoute.homePassenger
                : AppRoute.homeDriver;
            Navigator.pushReplacementNamed(context, route);
          }

          // Handle errors
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Đóng',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<AuthCubit>().clearError();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return RoleBasedContainer(
            role: role,
            title: 'Chào mừng trở lại',
            subtitle: 'Đăng nhập để tiếp tục sử dụng dịch vụ',
            onBackPressed: () => Navigator.pop(context),
            type: ContainerType.auth,
            useBackground: false, // Use gradient instead of background
            child: LoginView(
              role: role,
              isLoading: state.isLoading || state.isGoogleSigningIn,
              error: state.error,
              onLogin: (email, password) {
                context.read<AuthCubit>().loginWithEmail(
                  email,
                  password,
                  role,
                );
              },
              onGoogleLogin: () {
                context.read<AuthCubit>().loginWithGoogle(role);
              },
              onForgotPassword: () {
                // TODO: Implement forgot password
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng quên mật khẩu đang được phát triển'),
                  ),
                );
              },
              onRegister: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoute.register,
                  arguments: role,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
