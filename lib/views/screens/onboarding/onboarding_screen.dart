import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/onboarding/onboarding_cubit.dart';
import 'package:sharexev2/logic/onboarding/onboarding_state.dart';
import 'package:sharexev2/routes/app_routes.dart';
import 'package:sharexev2/views/widgets/sharexe_background.dart';
import 'package:sharexev2/config/theme.dart';

/// Onboarding Screen - Hiển thị lần đầu mở app
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.status == OnboardingStatus.completed) {
            // Sau khi hoàn thành onboarding -> Role selection
            Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
          }
        },
        child: const _OnboardingView(),
      ),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return SharexeBackground(
      child: SafeArea(
        child: BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            return Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 60), // Spacer
                      TextButton(
                        onPressed: () {
                          context.read<OnboardingCubit>().completeOnboarding();
                        },
                        child: Text(
                          'Bỏ qua',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content area
                Expanded(
                  child: PageView(
                    onPageChanged: (index) {
                      context.read<OnboardingCubit>().setPage(index);
                    },
                    children: [
                      _buildOnboardingPage(
                        context,
                        screenWidth,
                        screenHeight,
                        title: 'Chào mừng đến với ShareXe',
                        subtitle: 'Ứng dụng chia sẻ chuyến đi thông minh và tiện lợi',
                        imagePath: 'assets/images/logos/logo_passenger.png',
                        description: 'Kết nối hành khách và tài xế một cách dễ dàng, an toàn và tiết kiệm chi phí.',
                      ),
                      _buildOnboardingPage(
                        context,
                        screenWidth,
                        screenHeight,
                        title: 'Đặt chuyến dễ dàng',
                        subtitle: 'Tìm kiếm và đặt chuyến đi phù hợp chỉ với vài thao tác',
                        imagePath: 'assets/images/logos/logo_driver.png',
                        description: 'Hệ thống tự động ghép nối giúp bạn tìm được chuyến đi phù hợp nhất.',
                      ),
                      _buildOnboardingPage(
                        context,
                        screenWidth,
                        screenHeight,
                        title: 'An toàn và tin cậy',
                        subtitle: 'Hệ thống xác thực và đánh giá giúp đảm bảo an toàn cho mọi chuyến đi',
                        imagePath: 'assets/icon/icon.png',
                        description: 'Tất cả tài xế đều được xác thực và có hệ thống đánh giá từ cộng đồng.',
                      ),
                    ],
                  ),
                ),
                
                // Bottom navigation
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: state.pageIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: state.pageIndex == index 
                                  ? Colors.white 
                                  : Colors.white30,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      
                      // Navigation buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous button
                          if (state.pageIndex > 0)
                            TextButton(
                              onPressed: () {
                                context.read<OnboardingCubit>().prevPage();
                              },
                              child: Text(
                                'Trước',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 60),
                          
                          // Next/Get Started button
                          ElevatedButton(
                            onPressed: () {
                              if (state.pageIndex < 2) {
                                context.read<OnboardingCubit>().nextPage();
                              } else {
                                context.read<OnboardingCubit>().completeOnboarding();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              state.pageIndex < 2 ? 'Tiếp theo' : 'Bắt đầu',
                              style: AppTextStyles.labelLarge,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(
    BuildContext context,
    double screenWidth,
    double screenHeight, {
    required String title,
    required String subtitle,
    required String imagePath,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Image.asset(
            imagePath,
            width: screenWidth * 0.5,
            height: screenHeight * 0.25,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 48),
          
          // Title
          Text(
            title,
            style: AppTextStyles.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.headingSmall.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Description
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
