import 'package:flutter/material.dart';
import 'package:sharexev2/presentation/widgets/shared/unified_text_field.dart';
import 'package:sharexev2/presentation/widgets/shared/unified_button.dart';
import 'package:sharexev2/presentation/widgets/shared/role_based_loading.dart';
import 'package:sharexev2/config/theme.dart';

/// Pure UI/UX view for login
class LoginView extends StatefulWidget {
  final String role;
  final bool isLoading;
  final String? error;
  final Function(String email, String password) onLogin;
  final VoidCallback onGoogleLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onRegister;

  const LoginView({
    super.key,
    required this.role,
    this.isLoading = false,
    this.error,
    required this.onLogin,
    required this.onGoogleLogin,
    required this.onForgotPassword,
    required this.onRegister,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() == true) {
      widget.onLogin(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return RoleBasedLoading(
        role: widget.role,
        message: 'Đang đăng nhập...',
        showBackground: false,
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),

          // Login form
          _buildLoginForm(),

          const SizedBox(height: AppSpacing.lg),

          // Error display
          if (widget.error != null) _buildErrorDisplay(),

          const SizedBox(height: AppSpacing.lg),

          // Login button
          _buildLoginButton(),

          const SizedBox(height: AppSpacing.lg),

          // Divider
          _buildDivider(),

          const SizedBox(height: AppSpacing.lg),

          // Google login button
          _buildGoogleLoginButton(),

          const SizedBox(height: AppSpacing.xl),

          // Forgot password
          _buildForgotPassword(),

          const Spacer(),

          // Register link
          _buildRegisterLink(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email field
        UnifiedTextField(
          label: 'Email',
          hint: 'Nhập địa chỉ email của bạn',
          role: widget.role,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          type: FieldType.standard,
          size: FieldSize.medium,
          prefixIcon: Icon(
            Icons.email_outlined,
            color: AppColors.textSecondary,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        // Password field
        UnifiedTextField(
          label: 'Mật khẩu',
          hint: 'Nhập mật khẩu của bạn',
          role: widget.role,
          controller: _passwordController,
          isPassword: true,
          type: FieldType.standard,
          size: FieldSize.medium,
          prefixIcon: Icon(
            Icons.lock_outlined,
            color: AppColors.textSecondary,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu';
            }
            if (value.length < 6) {
              return 'Mật khẩu phải có ít nhất 6 ký tự';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildErrorDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              widget.error!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return UnifiedButton(
      text: 'Đăng nhập',
      role: widget.role,
      onPressed: _handleLogin,
      isLoading: widget.isLoading,
      type: ButtonType.primary,
      size: ButtonSize.large,
      icon: Icons.login,
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.borderLight,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'hoặc',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.borderLight,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleLoginButton() {
    return UnifiedButton(
      text: 'Đăng nhập bằng Google',
      role: widget.role,
      onPressed: widget.isLoading ? null : widget.onGoogleLogin,
      type: ButtonType.outline,
      size: ButtonSize.large,
      icon: Icons.g_mobiledata,
    );
  }

  Widget _buildForgotPassword() {
    return Center(
      child: TextButton(
        onPressed: widget.isLoading ? null : widget.onForgotPassword,
        child: Text(
          'Quên mật khẩu?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chưa có tài khoản? ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: widget.isLoading ? null : widget.onRegister,
            child: Text(
              'Đăng ký ngay',
              style: TextStyle(
                color: widget.role.toUpperCase() == 'PASSENGER' 
                    ? AppColors.passengerPrimary 
                    : AppColors.driverPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
