import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/auth/auth_cubit.dart';
import 'package:sharexev2/logic/profile/profile_cubit.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/views/widgets/sharexe_widgets.dart';

/// Main Settings Screen cho cả Passenger và Driver
class SettingsScreen extends StatefulWidget {
  final String userRole; // 'PASSENGER' hoặc 'DRIVER'

  const SettingsScreen({
    super.key,
    required this.userRole,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.userRole == 'DRIVER' 
        ? AppColors.driverPrimary 
        : AppColors.passengerPrimary;

    return BlocProvider(
      create: (_) => ProfileCubit(
        userRepository: ServiceLocator.get(),
        authRepository: ServiceLocator.get(),
      )..loadUserProfile(), // Call loadUserProfile when available
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(primaryColor),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildProfileSection(primaryColor),
                  const SizedBox(height: 20),
                  _buildSettingsSection(primaryColor),
                  const SizedBox(height: 20),
                  _buildSupportSection(primaryColor),
                  const SizedBox(height: 20),
                  _buildLogoutSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Color primaryColor) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Cài đặt',
          style: AppTextStyles.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/images/commons/cloud.png',
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Settings icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(Color primaryColor) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // Get user from real ProfileState
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowMedium,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        ShareXeUserAvatar(
                          imageUrl: state.avatarUrl.isNotEmpty ? state.avatarUrl : null,
                          name: state.userName.isNotEmpty ? state.userName : 'Người dùng ShareXe',
                          role: widget.userRole,
                          status: UserStatus.online,
                          radius: 50,
                          showRoleBadge: true,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _editProfile(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // User Info
                    Text(
                      state.userName.isNotEmpty ? state.userName : 'Người dùng ShareXe',
                      style: AppTextStyles.headingMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.userPhone.isNotEmpty ? state.userPhone : 'Chưa cập nhật số điện thoại',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.userRole == 'DRIVER' ? 'Tài xế' : 'Hành khách',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Quick Stats
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.directions_car,
                        label: 'Chuyến đi',
                        value: state.tripCount.toString(),
                        color: primaryColor,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.borderLight,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.star,
                        label: 'Đánh giá',
                        value: '${state.rating.toStringAsFixed(1)}★',
                        color: Colors.amber,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.borderLight,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.verified_user,
                        label: 'Trạng thái',
                        value: state.isVerified ? 'Đã xác minh' : 'Chưa xác minh',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Cài đặt tài khoản',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSettingItem(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            subtitle: 'Cập nhật thông tin và hình ảnh',
            onTap: () => _editProfile(),
            color: primaryColor,
          ),
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            subtitle: 'Thay đổi mật khẩu đăng nhập',
            onTap: () => _changePassword(),
            color: AppColors.warning,
          ),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            subtitle: 'Cài đặt thông báo và âm thanh',
            onTap: () => _notificationSettings(),
            color: AppColors.info,
          ),
          if (widget.userRole == 'DRIVER')
            _buildSettingItem(
              icon: Icons.directions_car_outlined,
              title: 'Thông tin xe',
              subtitle: 'Quản lý thông tin phương tiện',
              onTap: () => _vehicleSettings(),
              color: AppColors.driverPrimary,
            ),
          _buildSettingItem(
            icon: Icons.payment_outlined,
            title: 'Phương thức thanh toán',
            subtitle: 'Quản lý ví và thanh toán',
            onTap: () => _paymentSettings(),
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Hỗ trợ & Thông tin',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Hướng dẫn sử dụng',
            subtitle: 'Cách sử dụng ứng dụng ShareXe',
            onTap: () => _showUserGuide(),
            color: AppColors.info,
          ),
          _buildSettingItem(
            icon: Icons.support_agent,
            title: 'Hỗ trợ khách hàng',
            subtitle: 'Liên hệ đội ngũ hỗ trợ',
            onTap: () => _contactSupport(),
            color: AppColors.success,
          ),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: 'Về ShareXe',
            subtitle: 'Thông tin ứng dụng và phiên bản',
            onTap: () => _showAboutApp(),
            color: primaryColor,
          ),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Chính sách bảo mật',
            subtitle: 'Điều khoản và chính sách',
            onTap: () => _showPrivacyPolicy(),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildSettingItem(
        icon: Icons.logout,
        title: 'Đăng xuất',
        subtitle: 'Thoát khỏi tài khoản hiện tại',
        onTap: () => _showLogoutDialog(),
        color: AppColors.error,
        showArrow: false,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool showArrow = true,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: showArrow ? Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondary,
      ) : null,
    );
  }

  // Navigation methods
  void _editProfile() {
    Navigator.pushNamed(context, '/profile/edit');
  }

  void _changePassword() {
    Navigator.pushNamed(context, '/profile/change-password');
  }

  void _notificationSettings() {
    Navigator.pushNamed(context, '/settings/notifications');
  }

  void _vehicleSettings() {
    Navigator.pushNamed(context, '/settings/vehicle');
  }

  void _paymentSettings() {
    Navigator.pushNamed(context, '/settings/payment');
  }

  void _showUserGuide() {
    Navigator.pushNamed(context, '/help/guide');
  }

  void _contactSupport() {
    Navigator.pushNamed(context, '/support');
  }

  void _showAboutApp() {
    Navigator.pushNamed(context, '/about');
  }

  void _showPrivacyPolicy() {
    Navigator.pushNamed(context, '/privacy-policy');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Đăng xuất'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
            const SizedBox(height: 12),
            Text(
              'Bạn sẽ cần đăng nhập lại để sử dụng ứng dụng.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

}
