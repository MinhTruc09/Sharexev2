import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/registration/registration_cubit.dart';
import 'package:sharexev2/presentation/widgets/common/auth_container.dart';
import 'package:sharexev2/presentation/widgets/common/auth_button.dart';

class RegistrationStepOne extends StatefulWidget {
  final String role;

  const RegistrationStepOne({super.key, required this.role});

  @override
  State<RegistrationStepOne> createState() => _RegistrationStepOneState();
}

class _RegistrationStepOneState extends State<RegistrationStepOne>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _slideController,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Progress indicator
              _buildProgressIndicator(),

              const SizedBox(height: 32),

              // Email field
              AuthInputField(
                label: 'Email',
                hint: 'Nhập địa chỉ email của bạn',
                role: widget.role,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  context.read<RegistrationCubit>().updateEmail(value);
                },
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

              const SizedBox(height: 20),

              // Full name field
              AuthInputField(
                label: 'Họ và tên',
                hint: 'Nhập họ và tên đầy đủ',
                role: widget.role,
                controller: _fullNameController,
                onChanged: (value) {
                  context.read<RegistrationCubit>().updateFullName(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  if (value.length < 2) {
                    return 'Họ và tên phải có ít nhất 2 ký tự';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Password field
              AuthPasswordField(
                label: 'Mật khẩu',
                hint: 'Nhập mật khẩu (ít nhất 6 ký tự)',
                role: widget.role,
                controller: _passwordController,
                onChanged: (value) {
                  context.read<RegistrationCubit>().updatePassword(value);
                },
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

              const SizedBox(height: 20),

              // Confirm password field
              AuthPasswordField(
                label: 'Xác nhận mật khẩu',
                hint: 'Nhập lại mật khẩu',
                role: widget.role,
                controller: _confirmPasswordController,
                onChanged: (value) {
                  context.read<RegistrationCubit>().updateConfirmPassword(
                    value,
                  );
                },
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

              const SizedBox(height: 32),

              // Continue button
              BlocBuilder<RegistrationCubit, RegistrationState>(
                builder: (context, state) {
                  return AuthButton(
                    text: 'Tiếp tục',
                    role: widget.role,
                    icon: Icons.arrow_forward,
                    onPressed:
                        state.canProceedToStepTwo ? _handleContinue : null,
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bước 1/2',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.5,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(
            context.read<RegistrationCubit>().role == 'PASSENGER'
                ? Colors.blue
                : Colors.green,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      context.read<RegistrationCubit>().goToStepTwo();
    }
  }
}
