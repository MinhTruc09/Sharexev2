import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/splash/splash_cubit.dart';
import 'package:sharexev2/logic/splash/splash_state.dart';
import 'package:sharexev2/views/widgets/sharexe_background.dart';
import 'package:sharexev2/views/widgets/sharexe_background2.dart';
import 'package:sharexev2/config/theme.dart';

/// Role-specific Splash Screen - Sau khi chọn role
class RoleSplashScreen extends StatefulWidget {
  final String role; // 'PASSENGER' hoặc 'DRIVER'
  
  const RoleSplashScreen({
    super.key,
    required this.role,
  });

  @override
  State<RoleSplashScreen> createState() => _RoleSplashScreenState();
}

class _RoleSplashScreenState extends State<RoleSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auto navigate sau khi chọn role
    context.read<SplashCubit>().checkLoginStatus(overrideRole: widget.role);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPassenger = widget.role == 'PASSENGER';
    
    return BlocProvider(
      create: (_) => SplashCubit(ServiceLocator.get()),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state.status == SplashStatus.success && state.route != null) {
            Navigator.pushReplacementNamed(context, state.route!);
          }
        },
        child: isPassenger 
            ? SharexeBackground(
                child: _buildContent(context, screenWidth, isPassenger),
              )
            : SharexeBackground2(
                child: _buildContent(context, screenWidth, isPassenger),
              ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double screenWidth, bool isPassenger) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo theo role
          Image.asset(
            isPassenger 
                ? 'assets/images/logos/logo_passenger.png'
                : 'assets/images/logos/logo_driver.png',
            width: screenWidth * 0.3,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          
          // Welcome message
          Text(
            isPassenger 
                ? 'Chào mừng Hành khách!'
                : 'Chào mừng Tài xế!',
            style: AppTextStyles.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            isPassenger 
                ? 'Đang chuẩn bị chuyến đi cho bạn...'
                : 'Đang chuẩn bị hành trình cho bạn...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          // Loading indicator
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isPassenger ? Colors.white : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Passenger Splash Screen - Wrapper cho dễ sử dụng
class PassengerSplashScreen extends StatelessWidget {
  const PassengerSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleSplashScreen(role: 'PASSENGER');
  }
}

/// Driver Splash Screen - Wrapper cho dễ sử dụng  
class DriverSplashScreen extends StatelessWidget {
  const DriverSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleSplashScreen(role: 'DRIVER');
  }
}
