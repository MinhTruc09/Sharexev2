import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Avatar người dùng với status indicator cho ShareXe
class ShareXeUserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final String role; // 'DRIVER' hoặc 'PASSENGER'
  final UserStatus status;
  final double radius;
  final bool showRoleBadge;
  final VoidCallback? onTap;

  const ShareXeUserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    required this.role,
    this.status = UserStatus.offline,
    this.radius = 30,
    this.showRoleBadge = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getRoleColor().withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getRoleColor().withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: _getRoleColor().withOpacity(0.1),
              backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                  ? NetworkImage(imageUrl!)
                  : null,
              child: imageUrl == null || imageUrl!.isEmpty
                  ? Icon(
                      _getRoleIcon(),
                      size: radius * 0.8,
                      color: _getRoleColor(),
                    )
                  : null,
            ),
          ),
          
          // Status indicator
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: status == UserStatus.driving
                  ? Icon(
                      Icons.directions_car,
                      size: radius * 0.2,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          
          // Role badge
          if (showRoleBadge)
            Positioned(
              top: -4,
              left: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getRoleColor(),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getRoleIcon(),
                      size: 10,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _getRoleText(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRoleColor() {
    return role == 'DRIVER' ? AppColors.driverPrimary : AppColors.passengerPrimary;
  }

  IconData _getRoleIcon() {
    return role == 'DRIVER' ? Icons.local_taxi : Icons.person;
  }

  String _getRoleText() {
    return role == 'DRIVER' ? 'TX' : 'HK';
  }

  Color _getStatusColor() {
    switch (status) {
      case UserStatus.online:
        return AppColors.success;
      case UserStatus.away:
        return Colors.orange;
      case UserStatus.busy:
        return AppColors.error;
      case UserStatus.driving:
        return Colors.blue;
      case UserStatus.offline:
        return Colors.grey;
    }
  }
}

/// Widget hiển thị danh sách avatar người dùng
class ShareXeUserAvatarList extends StatelessWidget {
  final List<UserAvatarData> users;
  final double avatarSize;
  final int maxVisible;
  final VoidCallback? onViewAll;

  const ShareXeUserAvatarList({
    super.key,
    required this.users,
    this.avatarSize = 25,
    this.maxVisible = 3,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final visibleUsers = users.take(maxVisible).toList();
    final remainingCount = users.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...visibleUsers.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          
          return Container(
            margin: EdgeInsets.only(left: index > 0 ? -avatarSize * 0.3 : 0),
            child: ShareXeUserAvatar(
              imageUrl: user.imageUrl,
              name: user.name,
              role: user.role,
              status: user.status,
              radius: avatarSize,
              showRoleBadge: false,
              onTap: user.onTap,
            ),
          );
        }),
        
        // Show remaining count
        if (remainingCount > 0)
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              margin: EdgeInsets.only(left: -avatarSize * 0.3),
              width: avatarSize * 2,
              height: avatarSize * 2,
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '+$remainingCount',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget hiển thị thông tin chi tiết người dùng với avatar
class ShareXeUserCard extends StatelessWidget {
  final UserAvatarData user;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showStatus;

  const ShareXeUserCard({
    super.key,
    required this.user,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ShareXeUserAvatar(
        imageUrl: user.imageUrl,
        name: user.name,
        role: user.role,
        status: user.status,
        radius: 25,
        showRoleBadge: true,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              user.name ?? 'Người dùng',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (showStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(user.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(user.status),
                style: AppTextStyles.labelSmall.copyWith(
                  color: _getStatusColor(user.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing,
    );
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.online:
        return AppColors.success;
      case UserStatus.away:
        return Colors.orange;
      case UserStatus.busy:
        return AppColors.error;
      case UserStatus.driving:
        return Colors.blue;
      case UserStatus.offline:
        return Colors.grey;
    }
  }

  String _getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.online:
        return 'Trực tuyến';
      case UserStatus.away:
        return 'Vắng mặt';
      case UserStatus.busy:
        return 'Bận';
      case UserStatus.driving:
        return 'Đang lái xe';
      case UserStatus.offline:
        return 'Ngoại tuyến';
    }
  }
}

/// Enum trạng thái người dùng
enum UserStatus {
  online,
  offline,
  away,
  busy,
  driving, // Đặc biệt cho tài xế
}

/// Model dữ liệu avatar người dùng
class UserAvatarData {
  final String? imageUrl;
  final String? name;
  final String role;
  final UserStatus status;
  final VoidCallback? onTap;

  const UserAvatarData({
    this.imageUrl,
    this.name,
    required this.role,
    this.status = UserStatus.offline,
    this.onTap,
  });
}
