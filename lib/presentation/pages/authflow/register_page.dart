import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/services/mock_auth_service.dart';
import 'package:sharexev2/logic/registration/registration_cubit.dart';
import 'package:sharexev2/data/models/registration_models.dart';
import 'package:sharexev2/presentation/widgets/common/auth_container.dart';
import 'package:sharexev2/presentation/widgets/registration/registration_step_one.dart';
import 'package:sharexev2/presentation/widgets/registration/registration_step_two.dart';
import 'package:sharexev2/routes/app_routes.dart';

class RegisterPage extends StatelessWidget {
  final String role;

  const RegisterPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegistrationCubit(MockAuthService(), role),
      child: BlocConsumer<RegistrationCubit, RegistrationState>(
        listener: (context, state) {
          // Handle success
          if (state.status == RegistrationStatus.success) {
            if (role == 'DRIVER') {
              _showDriverApprovalDialog(context);
            } else {
              _showSuccessDialog(context);
            }
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
                    context.read<RegistrationCubit>().clearError();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return AuthContainer(
            role: role,
            title: _getTitle(state.currentStep),
            subtitle: _getSubtitle(state.currentStep, role),
            onBackPressed:
                state.currentStep == RegistrationStep.stepTwo
                    ? () => context.read<RegistrationCubit>().goBackToStepOne()
                    : () => Navigator.pop(context),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child:
                  state.currentStep == RegistrationStep.stepOne
                      ? RegistrationStepOne(
                        key: const ValueKey('step_one'),
                        role: role,
                      )
                      : RegistrationStepTwo(
                        key: const ValueKey('step_two'),
                        role: role,
                      ),
            ),
          );
        },
      ),
    );
  }

  String _getTitle(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.stepOne:
        return 'Tạo tài khoản';
      case RegistrationStep.stepTwo:
        return 'Thông tin bổ sung';
    }
  }

  String _getSubtitle(RegistrationStep step, String role) {
    switch (step) {
      case RegistrationStep.stepOne:
        return 'Nhập thông tin cơ bản để bắt đầu';
      case RegistrationStep.stepTwo:
        if (role == 'PASSENGER') {
          return 'Hoàn tất thông tin cá nhân';
        } else {
          return 'Upload giấy tờ để xét duyệt';
        }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Đăng ký thành công!'),
              ],
            ),
            content: const Text(
              'Tài khoản của bạn đã được tạo thành công. Bạn có thể đăng nhập ngay bây giờ.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoute.login,
                    arguments: role,
                  );
                },
                child: const Text('Đăng nhập ngay'),
              ),
            ],
          ),
    );
  }

  void _showDriverApprovalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.hourglass_empty, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text('Chờ xét duyệt'),
              ],
            ),
            content: const Text(
              'Tài khoản tài xế của bạn đã được gửi để xét duyệt. Admin sẽ kiểm tra và phê duyệt trong vòng 24-48 giờ. Bạn sẽ nhận được thông báo qua email.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoute.login,
                    arguments: role,
                  );
                },
                child: const Text('Đã hiểu'),
              ),
            ],
          ),
    );
  }
}
