import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/onboarding/onboarding_cubit.dart';
import 'package:sharexev2/logic/onboarding/onboarding_state.dart';
import 'package:sharexev2/presentation/widgets/onboarding_content.dart';
import 'package:sharexev2/routes/app_routes.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.completed) {
          Navigator.pushReplacementNamed(context, AppRoute.roleSelection);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (index) {
                      context.read<OnboardingCubit>().setPage(index);
                    },
                    children: const [
                      OnboardingContent(
                        imagePath: 'assets/images/commons/car.png',
                        title: 'Chia sẻ chuyến đi',
                        description:
                            'Kết nối các chuyến đi cùng mục đích, tiết kiệm thời gian và chi phí...',
                      ),
                      OnboardingContent(
                        imagePath: 'assets/images/commons/carsmoke.png',
                        title: 'Tìm chuyến',
                        description:
                            'Tìm chuyến nhanh chóng trên toàn quốc với hệ thống bản đồ...',
                      ),
                      OnboardingContent(
                        imagePath: 'assets/images/logos/smokelogo.png',
                        title: 'Đặt xe ngay',
                        description:
                            'Mong bạn có trải nghiệm tốt nhất với dịch vụ của chúng tôi.',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nút Skip
                      TextButton(
                        onPressed: () {
                          context.read<OnboardingCubit>().completeOnboarding();
                        },
                        child: Text(
                          'Bỏ qua',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      // Nút Tiếp / Bắt đầu
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          if (state.pageIndex == 2) {
                            context
                                .read<OnboardingCubit>()
                                .completeOnboarding();
                          } else {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          state.pageIndex == 2 ? 'Bắt đầu' : 'Tiếp',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
