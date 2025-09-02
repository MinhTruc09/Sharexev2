import 'package:flutter/material.dart';
import 'package:sharexev2/presentation/widgets/auth/role_selection_card.dart';
import 'package:sharexev2/presentation/widgets/shared/unified_button.dart';
import 'package:sharexev2/presentation/widgets/shared/role_based_loading.dart';
import 'package:sharexev2/config/theme.dart';

/// Pure UI/UX view for role selection
class RoleSelectionView extends StatefulWidget {
  final String? selectedRole;
  final Function(String) onRoleSelected;
  final VoidCallback onContinue;
  final bool isLoading;

  const RoleSelectionView({
    super.key,
    this.selectedRole,
    required this.onRoleSelected,
    required this.onContinue,
    this.isLoading = false,
  });

  @override
  State<RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<RoleSelectionView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return RoleBasedLoading(
        role: widget.selectedRole ?? 'PASSENGER',
        message: 'Đang chuyển đến màn hình đăng nhập...',
        showBackground: true,
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),

            // Welcome text
            _buildWelcomeText(),

            const SizedBox(height: AppSpacing.xxl),

            // Role selection cards
            _buildRoleCards(),

            const SizedBox(height: AppSpacing.xxl),

            // Continue button
            _buildContinueButton(),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          Text(
            'Chào mừng bạn đến với ShareXe',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Vui lòng chọn vai trò của bạn để tiếp tục',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Passenger card
          RoleSelectionCard(
            role: 'PASSENGER',
            title: 'Hành khách',
            description: 'Tìm kiếm và đặt chuyến xe đi lại thuận tiện, an toàn',
            icon: Icons.person,
            isSelected: widget.selectedRole == 'PASSENGER',
            onTap: () => widget.onRoleSelected('PASSENGER'),
            accentColor: AppColors.passengerPrimary,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Driver card
          RoleSelectionCard(
            role: 'DRIVER',
            title: 'Tài xế',
            description: 'Đăng ký làm tài xế, tạo chuyến xe và kiếm thu nhập',
            icon: Icons.drive_eta,
            isSelected: widget.selectedRole == 'DRIVER',
            onTap: () => widget.onRoleSelected('DRIVER'),
            accentColor: AppColors.driverPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: UnifiedButton(
        text: 'Tiếp tục',
        role: widget.selectedRole ?? 'PASSENGER',
        onPressed: widget.selectedRole != null ? widget.onContinue : null,
        isLoading: widget.isLoading,
        isEnabled: widget.selectedRole != null,
        type: ButtonType.primary,
        size: ButtonSize.large,
        icon: Icons.arrow_forward,
      ),
    );
  }
}
