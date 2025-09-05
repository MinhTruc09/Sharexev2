import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/splash/splash_cubit.dart';
import 'package:sharexev2/logic/splash/splash_state.dart';
import 'package:sharexev2/routes/app_routes.dart';
import 'package:sharexev2/views/widgets/sharexe_background.dart';
import 'package:sharexev2/config/theme.dart';

/// Main Splash Screen - Kiểm tra first time và điều hướng
class MainSplashScreen extends StatefulWidget {
  const MainSplashScreen({super.key});

  @override
  State<MainSplashScreen> createState() => _MainSplashScreenState();
}

class _MainSplashScreenState extends State<MainSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstTimeAndNavigate();
  }

  /// Kiểm tra lần đầu mở app và điều hướng
  Future<void> _checkFirstTimeAndNavigate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstOpen') ?? true;
      
      await Future.delayed(const Duration(seconds: 2)); // Splash delay
      
      if (!mounted) return;
      
      if (isFirstTime) {
        // Lần đầu mở app -> Onboarding
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      } else {
        // Đã mở trước đó -> Kiểm tra login status
        context.read<SplashCubit>().checkLoginStatus();
      }
    } catch (e) {
      // Nếu lỗi, mặc định là first time
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return BlocProvider(
      create: (_) => SplashCubit(ServiceLocator.get()),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state.status == SplashStatus.success && state.route != null) {
            Navigator.pushReplacementNamed(context, state.route!);
          } else if (state.status == SplashStatus.error) {
            // Nếu lỗi, điều hướng về role selection
            Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
          }
        },
        child: SharexeBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo chính của ShareXe
                Image.asset(
                  'assets/icon/icon.png',
                  width: screenWidth * 0.4,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                
                // Tên app
                Text(
                  'ShareXe',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Slogan
                Text(
                  'Chia sẻ chuyến đi, kết nối yêu thương',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
