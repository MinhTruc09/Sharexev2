import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/roleselection/role_selection_cubit.dart';
import 'package:sharexev2/logic/roleselection/role_selection_state.dart';
import 'package:sharexev2/routes/app_routes.dart';
import 'package:sharexev2/views/widgets/sharexe_background.dart';
import 'package:sharexev2/config/theme.dart';

/// Role Selection Screen - Chọn vai trò Hành khách hoặc Tài xế
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoleSelectionCubit(ServiceLocator.get()),
      child: BlocListener<RoleSelectionCubit, RoleSelectionState>(
        listener: (context, state) {
          if (state.status == RoleStatus.success && state.selectedRole != null) {
            // Navigate to role-specific splash screen
            final route = state.selectedRole == 'PASSENGER' 
                ? AppRoutes.passengerSplash 
                : AppRoutes.driverSplash;
            Navigator.pushReplacementNamed(context, route);
          }
        },
        child: SharexeBackground(
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.08),
          
          // Header
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildHeader(),
          ),
          
          SizedBox(height: screenHeight * 0.06),
          
          // Role selection cards
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildRoleCard(
                    role: 'PASSENGER',
                    title: 'Hành khách',
                    subtitle: 'Tìm kiếm và đặt chuyến đi',
                    description: 'Dễ dàng tìm kiếm chuyến đi phù hợp, đặt chỗ nhanh chóng và an toàn',
                    imagePath: 'assets/images/logos/logo_passenger.png',
                    color: AppColors.passengerPrimary,
                    benefits: [
                      'Tìm chuyến đi nhanh chóng',
                      'Giá cả hợp lý',
                      'An toàn và tiện lợi',
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildRoleCard(
                    role: 'DRIVER',
                    title: 'Tài xế',
                    subtitle: 'Chia sẻ chuyến đi và kiếm thêm thu nhập',
                    description: 'Tạo chuyến đi, nhận hành khách và tối ưu hóa lộ trình của bạn',
                    imagePath: 'assets/images/logos/logo_driver.png',
                    color: AppColors.driverPrimary,
                    benefits: [
                      'Kiếm thêm thu nhập',
                      'Tối ưu chi phí xăng',
                      'Kết nối cộng đồng',
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.04),
          
          // Continue button
          if (_selectedRole != null)
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContinueButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      children: [
        // App logo
        Image.asset(
          'assets/icon/icon.png',
          width: screenWidth * 0.2,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),
        
        Text(
          'Chào mừng đến ShareXe',
          style: AppTextStyles.displayMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        
        Text(
          'Bạn muốn sử dụng ShareXe với vai trò gì?',
          style: AppTextStyles.headingSmall.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String subtitle,
    required String description,
    required String imagePath,
    required Color color,
    required List<String> benefits,
  }) {
    final isSelected = _selectedRole == role;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isSelected ? 1.0 : 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected ? 0.15 : 0.08),
                blurRadius: isSelected ? 25 : 15,
                offset: Offset(0, isSelected ? 15 : 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Role icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.headingMedium.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Selection indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? color : AppColors.borderMedium,
                        width: 2,
                      ),
                      color: isSelected ? color : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              
              // Benefits
              Column(
                children: benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ElevatedButton(
        onPressed: () {
          if (_selectedRole != null) {
            // Update cubit and navigate
            context.read<RoleSelectionCubit>().selectRole(_selectedRole!);
            Navigator.pushNamed(context, AppRoutes.login, arguments: _selectedRole);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedRole == 'PASSENGER' 
              ? AppColors.passengerPrimary 
              : AppColors.driverPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tiếp tục với ${_selectedRole == 'PASSENGER' ? 'Hành khách' : 'Tài xế'}',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
