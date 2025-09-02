import 'package:flutter/material.dart';
import 'package:sharexev2/presentation/widgets/shared/unified_text_field.dart';
import 'package:sharexev2/presentation/widgets/shared/unified_button.dart';
import 'package:sharexev2/presentation/widgets/shared/role_based_loading.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/data/models/auth/entities/auth_credentials.dart';

/// Driver-specific registration view with additional fields
class DriverRegisterView extends StatefulWidget {
  final bool isLoading;
  final String? error;
  final Function(RegisterCredentials credentials) onRegister;
  final VoidCallback onGoogleRegister;
  final VoidCallback onLogin;

  const DriverRegisterView({
    super.key,
    this.isLoading = false,
    this.error,
    required this.onRegister,
    required this.onGoogleRegister,
    required this.onLogin,
  });

  @override
  State<DriverRegisterView> createState() => _DriverRegisterViewState();
}

class _DriverRegisterViewState extends State<DriverRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() == true) {
      final credentials = RegisterCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        licenseNumber: _licenseController.text.trim(), // Required for drivers
      );
      widget.onRegister(credentials);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return RoleBasedLoading(
        role: 'DRIVER',
        message: 'Đang tạo tài khoản tài xế...',
        showBackground: false,
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),

          // Driver-specific header
          _buildDriverHeader(),

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

  Widget _buildDriverHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.driverPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.driverPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.drive_eta,
            color: AppColors.driverPrimary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đăng ký tài khoản tài xế',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppColors.driverPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tạo chuyến đi và kiếm thu nhập',
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
          role: 'DRIVER',
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
          role: 'DRIVER',
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
          role: 'DRIVER',
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

        // License number field (Driver-specific)
        UnifiedTextField(
          label: 'Số giấy phép lái xe',
          hint: 'Nhập số giấy phép lái xe',
          role: 'DRIVER',
          controller: _licenseController,
          prefixIcon: Icons.card_membership_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số giấy phép lái xe';
            }
            if (value.trim().length < 8) {
              return 'Số giấy phép lái xe phải có ít nhất 8 ký tự';
            }
            return null;
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        // Password field
        UnifiedTextField(
          label: 'Mật khẩu',
          hint: 'Nhập mật khẩu',
          role: 'DRIVER',
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
          role: 'DRIVER',
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

        const SizedBox(height: AppSpacing.lg),

        // Driver notice
        _buildDriverNotice(),
      ],
    );
  }

  Widget _buildDriverNotice() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.driverPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.driverPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.driverPrimary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Tài khoản tài xế cần được xác minh. Chúng tôi sẽ liên hệ với bạn trong vòng 24h.',
              style: AppTheme.bodySmall.copyWith(
                color: AppColors.driverPrimary,
              ),
            ),
          ),
        ],
      ),
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
      text: 'Tạo tài khoản tài xế',
      role: 'DRIVER',
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
      role: 'DRIVER',
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
                color: AppColors.driverPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
