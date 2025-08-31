import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/presentation/widgets/common/auth_button.dart';

class SettingsPage extends StatefulWidget {
  final String role;

  const SettingsPage({
    super.key,
    required this.role,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;
  String _language = 'vi';

  @override
  Widget build(BuildContext context) {
    final isPassenger = widget.role == 'PASSENGER';
    final primaryColor = isPassenger ? AppColors.passengerPrimary : AppColors.driverPrimary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          _buildProfileSection(context, primaryColor),
          const SizedBox(height: 24),

          // App Settings
          _buildSectionTitle('Cài đặt ứng dụng'),
          _buildSettingsCard([
            _buildSwitchTile(
              'Thông báo',
              'Nhận thông báo về chuyến đi',
              Icons.notifications_outlined,
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchTile(
              'Vị trí',
              'Cho phép truy cập vị trí',
              Icons.location_on_outlined,
              _locationEnabled,
              (value) => setState(() => _locationEnabled = value),
            ),
            _buildSwitchTile(
              'Chế độ tối',
              'Sử dụng giao diện tối',
              Icons.dark_mode_outlined,
              _darkModeEnabled,
              (value) => setState(() => _darkModeEnabled = value),
            ),
            _buildTile(
              'Ngôn ngữ',
              _language == 'vi' ? 'Tiếng Việt' : 'English',
              Icons.language_outlined,
              () => _showLanguageDialog(),
            ),
          ]),
          const SizedBox(height: 24),

          // Account Settings
          _buildSectionTitle('Tài khoản'),
          _buildSettingsCard([
            _buildTile(
              'Thông tin cá nhân',
              'Chỉnh sửa thông tin tài khoản',
              Icons.person_outline,
              () => _navigateToProfile(),
            ),
            _buildTile(
              'Đổi mật khẩu',
              'Thay đổi mật khẩu đăng nhập',
              Icons.lock_outline,
              () => _navigateToChangePassword(),
            ),
            if (widget.role == 'DRIVER') ...[
              _buildTile(
                'Thông tin xe',
                'Quản lý thông tin phương tiện',
                Icons.directions_car_outlined,
                () => _navigateToVehicleInfo(),
              ),
              _buildTile(
                'Tài khoản ngân hàng',
                'Quản lý thông tin thanh toán',
                Icons.account_balance_outlined,
                () => _navigateToBankAccount(),
              ),
            ],
          ]),
          const SizedBox(height: 24),

          // Support Section
          _buildSectionTitle('Hỗ trợ'),
          _buildSettingsCard([
            _buildTile(
              'Trung tâm trợ giúp',
              'Câu hỏi thường gặp và hướng dẫn',
              Icons.help_outline,
              () => _navigateToHelp(),
            ),
            _buildTile(
              'Liên hệ hỗ trợ',
              'Gửi phản hồi hoặc báo lỗi',
              Icons.support_agent_outlined,
              () => _navigateToSupport(),
            ),
            _buildTile(
              'Đánh giá ứng dụng',
              'Đánh giá ShareXe trên cửa hàng ứng dụng',
              Icons.star_outline,
              () => _rateApp(),
            ),
          ]),
          const SizedBox(height: 24),

          // Legal Section
          _buildSectionTitle('Pháp lý'),
          _buildSettingsCard([
            _buildTile(
              'Điều khoản sử dụng',
              'Xem điều khoản và điều kiện',
              Icons.description_outlined,
              () => _navigateToTerms(),
            ),
            _buildTile(
              'Chính sách bảo mật',
              'Xem chính sách bảo mật dữ liệu',
              Icons.privacy_tip_outlined,
              () => _navigateToPrivacy(),
            ),
          ]),
          const SizedBox(height: 32),

          // Logout Button
          AuthButton(
            text: 'Đăng xuất',
            role: widget.role,
            isOutlined: true,
            onPressed: () => _showLogoutDialog(),
          ),
          const SizedBox(height: 16),

          // App Version
          Center(
            child: Text(
              'ShareXe v1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 30,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nguyễn Văn A',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.role == 'PASSENGER' ? 'Hành khách' : 'Tài xế',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      const Text('4.8', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _navigateToProfile(),
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.grey.shade600),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    // TODO: Implement logout logic
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile', arguments: widget.role);
  }

  void _navigateToChangePassword() {
    // TODO: Navigate to change password page
  }

  void _navigateToVehicleInfo() {
    // TODO: Navigate to vehicle info page
  }

  void _navigateToBankAccount() {
    // TODO: Navigate to bank account page
  }

  void _navigateToHelp() {
    // TODO: Navigate to help center
  }

  void _navigateToSupport() {
    // TODO: Navigate to support page
  }

  void _rateApp() {
    // TODO: Open app store for rating
  }

  void _navigateToTerms() {
    // TODO: Navigate to terms page
  }

  void _navigateToPrivacy() {
    // TODO: Navigate to privacy policy page
  }
}
