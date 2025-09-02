import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Passenger Settings View - Pure UI component
class PassengerSettingsView extends StatelessWidget {
  const PassengerSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cài đặt',
              style: AppTheme.headingLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Profile section
            _buildProfileSection(),
            const SizedBox(height: AppSpacing.xl),
            
            // Account settings
            _buildSettingsSection(
              'Tài khoản',
              [
                _buildSettingsItem(
                  icon: Icons.person,
                  title: 'Thông tin cá nhân',
                  subtitle: 'Cập nhật thông tin tài khoản',
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.security,
                  title: 'Bảo mật',
                  subtitle: 'Mật khẩu và xác thực',
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.payment,
                  title: 'Phương thức thanh toán',
                  subtitle: 'Quản lý thẻ và ví điện tử',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // App settings
            _buildSettingsSection(
              'Ứng dụng',
              [
                _buildSettingsItem(
                  icon: Icons.notifications,
                  title: 'Thông báo',
                  subtitle: 'Cài đặt thông báo',
                  onTap: () {},
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.passengerPrimary,
                  ),
                ),
                _buildSettingsItem(
                  icon: Icons.language,
                  title: 'Ngôn ngữ',
                  subtitle: 'Tiếng Việt',
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.dark_mode,
                  title: 'Chế độ tối',
                  subtitle: 'Giao diện tối',
                  onTap: () {},
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                    activeColor: AppColors.passengerPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Support section
            _buildSettingsSection(
              'Hỗ trợ',
              [
                _buildSettingsItem(
                  icon: Icons.help,
                  title: 'Trung tâm trợ giúp',
                  subtitle: 'Câu hỏi thường gặp',
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.contact_support,
                  title: 'Liên hệ hỗ trợ',
                  subtitle: 'Gửi phản hồi',
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.info,
                  title: 'Về ứng dụng',
                  subtitle: 'Phiên bản 1.0.0',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Logout button
            _buildLogoutButton(context),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.passengerPrimary.withOpacity(0.1),
            child: Text(
              'KH',
              style: AppTheme.headingMedium.copyWith(
                color: AppColors.passengerPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khách hàng',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'khachhang@example.com',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.passengerPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'Hành khách',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.passengerPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.edit,
              color: AppColors.passengerPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.passengerPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          color: AppColors.passengerPrimary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: trailing ?? Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            Icons.logout,
            color: AppColors.error,
            size: 20,
          ),
        ),
        title: Text(
          'Đăng xuất',
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
        subtitle: Text(
          'Đăng xuất khỏi tài khoản',
          style: AppTheme.bodySmall.copyWith(
            color: AppColors.error.withOpacity(0.7),
          ),
        ),
        onTap: () => _showLogoutDialog(context),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đăng xuất')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}