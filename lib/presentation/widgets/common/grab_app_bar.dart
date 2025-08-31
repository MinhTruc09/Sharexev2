import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Grab-like App Bar with role-specific styling
class GrabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String userRole;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final bool showBackButton;
  final List<Widget>? actions;

  const GrabAppBar({
    super.key,
    required this.title,
    required this.userRole,
    this.onProfileTap,
    this.onNotificationTap,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isPassenger = userRole == 'PASSENGER';
    final primaryColor = isPassenger ? AppColors.passengerPrimary : AppColors.driverPrimary;
    final gradient = isPassenger ? AppGradients.grabPrimary : AppGradients.driverPrimary;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: actions ??
            [
              // Notification button
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined, color: Colors.white),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.grabOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: onNotificationTap,
              ),
              // Profile button
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: GestureDetector(
                  onTap: onProfileTap,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Grab-like Bottom Navigation Bar
class GrabBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String userRole;
  final Function(int) onTap;

  const GrabBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.userRole,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPassenger = userRole == 'PASSENGER';
    final primaryColor = isPassenger ? AppColors.passengerPrimary : AppColors.driverPrimary;

    final passengerItems = [
      _NavItem(Icons.home_outlined, Icons.home, 'Trang chủ'),
      _NavItem(Icons.history_outlined, Icons.history, 'Lịch sử'),
      _NavItem(Icons.favorite_outline, Icons.favorite, 'Yêu thích'),
      _NavItem(Icons.settings_outlined, Icons.settings, 'Cài đặt'),
    ];

    final driverItems = [
      _NavItem(Icons.home_outlined, Icons.home, 'Trang chủ'),
      _NavItem(Icons.directions_car_outlined, Icons.directions_car, 'Chuyến đi'),
      _NavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Thu nhập'),
      _NavItem(Icons.settings_outlined, Icons.settings, 'Cài đặt'),
    ];

    final items = isPassenger ? passengerItems : driverItems;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;

              return GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected ? primaryColor : AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? primaryColor : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  _NavItem(this.icon, this.selectedIcon, this.label);
}

/// Grab-like Action Button
class GrabActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final String userRole;
  final double? width;
  final IconData? icon;

  const GrabActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.userRole = 'PASSENGER',
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isPassenger = userRole == 'PASSENGER';
    final primaryColor = isPassenger ? AppColors.passengerPrimary : AppColors.driverPrimary;
    final gradient = isPassenger ? AppGradients.grabPrimary : AppGradients.driverPrimary;

    return Container(
      width: width ?? double.infinity,
      height: AppSpacing.buttonHeight,
      decoration: BoxDecoration(
        gradient: isSecondary ? null : gradient,
        color: isSecondary ? Colors.white : null,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: isSecondary ? Border.all(color: primaryColor) : null,
        boxShadow: isSecondary
            ? null
            : [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.button),
          onTap: isLoading ? null : onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isSecondary ? primaryColor : Colors.white,
                      ),
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: isSecondary ? primaryColor : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: isSecondary ? primaryColor : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
