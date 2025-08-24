import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/services/mock_auth_service.dart';
import 'package:sharexev2/logic/auth/auth_cubit.dart';
import 'package:sharexev2/logic/auth/auth_state.dart';
import 'package:sharexev2/presentation/widgets/common/auth_container.dart';
import 'package:sharexev2/presentation/widgets/common/auth_button.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/routes/app_routes.dart';

class LoginPage extends StatelessWidget {
  final String role;

  const LoginPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(MockAuthService()),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            final route =
                role == 'PASSENGER'
                    ? AppRoute.homePassenger
                    : AppRoute.homeDriver;
            Navigator.pushReplacementNamed(context, route);
          }

          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: const Color(0xFFE53E3E),
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
          return AuthContainer(
            role: role,
            title: 'Chào mừng trở lại',
            subtitle: 'Đăng nhập để tiếp tục sử dụng dịch vụ',
            onBackPressed: () => Navigator.pop(context),
            child: LoginForm(role: role),
          );
        },
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final String role;

  const LoginForm({super.key, required this.role});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Email field
          AuthInputField(
            label: 'Email',
            hint: 'Nhập địa chỉ email của bạn',
            role: widget.role,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Password field
          AuthPasswordField(
            label: 'Mật khẩu',
            hint: 'Nhập mật khẩu của bạn',
            role: widget.role,
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chức năng quên mật khẩu sẽ được thêm sau'),
                  ),
                );
              },
              child: Text(
                'Quên mật khẩu?',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ).copyWith(
                  color: ThemeManager.getPrimaryColorForRole(widget.role),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Login button
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return AuthButton(
                text: 'Đăng nhập',
                role: widget.role,
                isLoading: state.status == AuthStatus.loading,
                onPressed: _handleLogin,
              );
            },
          ),

          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text('hoặc', style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                )),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),

          const SizedBox(height: 24),

          // Google login
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return AuthSocialButton(
                text: 'Đăng nhập với Google',
                role: widget.role,
                icon: Icons.g_mobiledata,
                isLoading: state.status == AuthStatus.loading,
                onPressed: _handleGoogleLogin,
              );
            },
          ),

          const SizedBox(height: 32),

          // Register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Chưa có tài khoản? ', style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              )),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoute.register,
                    arguments: widget.role,
                  );
                },
                child: Text(
                  'Đăng ký ngay',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ).copyWith(
                    color: ThemeManager.getPrimaryColorForRole(widget.role),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().loginWithEmail(
        _emailController.text,
        _passwordController.text,
        widget.role,
      );
    }
  }

  void _handleGoogleLogin() {
    context.read<AuthCubit>().loginWithGoogle(widget.role);
  }
}
