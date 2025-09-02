import 'package:flutter/material.dart';
import 'package:sharexev2/presentation/widgets/shared/unified_text_field.dart';
import 'package:sharexev2/presentation/widgets/shared/unified_button.dart';
import 'package:sharexev2/presentation/widgets/shared/role_based_loading.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/data/models/auth/entities/auth_credentials.dart';

/// Passenger-specific registration view
class PassengerRegisterView extends StatefulWidget {
  final bool isLoading;
  final String? error;
  final Function(RegisterCredentials credentials) onRegister;
  final VoidCallback onGoogleRegister;
  final VoidCallback onLogin;

  const PassengerRegisterView({
    super.key,
    this.isLoading = false,
    this.error,
    required this.onRegister,
    required this.onGoogleRegister,
    required this.onLogin,
  });

  @override
  State<PassengerRegisterView> createState() => _PassengerRegisterViewState();
}

class _PassengerRegisterViewState extends State<PassengerRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() == true) {
      final credentials = RegisterCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        // No license number for passengers
      );
      widget.onRegister(credentials);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return RoleBasedLoading(
        role: 'PASSENGER',
        message: 'Đang tạo tài khoản hành khách...',
        showBackground: false,
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),

          // Passenger-specific header
          _buildPassengerHeader(),

          const SizedBox(height: AppSpacing.lg),

          // Registration form
          _buildRegistrationForm(),

          const SizedBox(height: AppSpacing.lg),

          // Error display
          if (widget.error != null) _buildErrorDisplay(),

          const SizedBox(height: AppSpacing.lg),

          // Register button
          _buildRegisterButton(),

          const SizedBox(height: AppSpacing.lg),

          // Divider
          _buildDivider(),

          const SizedBox(height: AppSpacing.lg),

          // Google register button
          _buildGoogleRegisterButton(),

          const SizedBox(height: AppSpacing.xl),

          // Login link
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildPassengerHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.passengerPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.passengerPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: AppColors.passengerPrimary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đăng ký tài khoản hành khách',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppColors.passengerPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tìm kiếm và đặt chuyến đi dễ dàng',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        // Name field
        UnifiedTextField(
          label: 'Họ và tên',
          hint: 'Nhập họ và tên của bạn',
          role: 'PASSENGER',
          controller: _nameController,
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập họ và tên';
            }
            if (value.trim().length < 2) {
              return 'Họ và tên phải có ít nhất 2 ký tự';
            }
            return null;
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        // Email field
        UnifiedTextField(
          label: 'Email',
          hint: 'Nhập địa chỉ email',
          role: 'PASSENGER',
          controller: _emailController,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        // Phone field
        UnifiedTextField(
          label: 'Số điện thoại',
          hint: 'Nhập số điện thoại',
          role: 'PASSENGER',
          controller: _phoneController,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số điện thoại';
            }
            if (!RegExp(r'^(\+84|0)[3|5|7|8|9][0-9]{8}$').hasMatch(value.replaceAll(' ', ''))) {
              return 'Số điện thoại không hợp lệ';
            }
            return null;
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        // Password field
        UnifiedTextField(
          label: 'Mật khẩu',
          hint: 'Nhập mật khẩu',
          role: 'PASSENGER',
          controller: _passwordController,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
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

        const SizedBox(height: AppSpacing.lg),

        // Confirm password field
        UnifiedTextField(
          label: 'Xác nhận mật khẩu',
          hint: 'Nhập lại mật khẩu',
          role: 'PASSENGER',
          controller: _confirmPasswordController,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng xác nhận mật khẩu';
            }
            if (value != _passwordController.text) {
              return 'Mật khẩu xác nhận không khớp';
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
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              widget.error!,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return UnifiedButton(
      text: 'Tạo tài khoản hành khách',
      role: 'PASSENGER',
      onPressed: _handleRegister,
      isLoading: widget.isLoading,
      type: ButtonType.primary,
      size: ButtonSize.large,
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.borderLight,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Hoặc',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.borderLight,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleRegisterButton() {
    return UnifiedButton(
      text: 'Đăng ký với Google',
      role: 'PASSENGER',
      onPressed: widget.onGoogleRegister,
      isLoading: widget.isLoading,
      type: ButtonType.outline,
      size: ButtonSize.large,
      icon: Icons.g_mobiledata,
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Đã có tài khoản? ',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: widget.onLogin,
            child: Text(
              'Đăng nhập ngay',
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.passengerPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
