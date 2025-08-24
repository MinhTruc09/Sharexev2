import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/constants.dart';
import 'package:sharexev2/core/utils/validators.dart';
import 'package:sharexev2/logic/auth/auth_cubit.dart';
import 'package:sharexev2/logic/auth/auth_state.dart';

import 'package:sharexev2/presentation/widgets/custom_text_field.dart';
import 'package:sharexev2/presentation/widgets/primary_button.dart';

class LoginContent extends StatefulWidget {
  final String role;
  final VoidCallback? onRegisterPressed;

  const LoginContent({super.key, required this.role, this.onRegisterPressed});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
          context.read<AuthCubit>().clearError();
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Đăng nhập',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.role == 'PASSENGER' ? 'Hành khách' : 'Tài xế',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Role icon
                    Icon(
                      widget.role == 'PASSENGER'
                          ? Icons.person
                          : Icons.directions_car,
                      size: 60,
                      color: PrimaryColor,
                    ),
                    const SizedBox(height: 24),

                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Nhập email của bạn',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.getEmailError,
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu của bạn',
                      prefixIcon: Icons.lock,
                      obscureText: _obscurePassword,
                      validator: Validators.getPasswordError,
                    ),
                    const SizedBox(height: 24),

                    // Additional fields for specific role
                    ...buildAdditionalFields(),

                    // Login button
                    CustomButton(
                      label: 'Đăng nhập',
                      loading: state.isLoading,
                      onPressed: state.isLoading ? null : _handleLogin,
                      fullWidth: true,
                    ),
                    const SizedBox(height: 16),

                    // Google Sign-In button
                    CustomButton(
                      label: 'Đăng nhập bằng Google',
                      loading: state.isGoogleSigningIn,
                      onPressed:
                          state.isGoogleSigningIn ? null : _handleGoogleLogin,
                      fullWidth: true,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      leading: Image.asset(
                        'assets/images/logos/drive_2.png',
                        height: 20,
                        width: 20,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.g_mobiledata, size: 20),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa có tài khoản? ',
                          style: TextStyle(color: TextHighlightColor3),
                        ),
                        TextButton(
                          onPressed: widget.onRegisterPressed,
                          child: const Text(
                            'Đăng ký ngay',
                            style: TextStyle(color: PrimaryColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Override this method to add role-specific fields
  List<Widget> buildAdditionalFields() {
    return [];
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        widget.role,
      );
    }
  }

  void _handleGoogleLogin() {
    context.read<AuthCubit>().loginWithGoogle(widget.role);
  }
}
