import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/routes/app_routes.dart';

/// Custom Bottom Navigation Bar cho ShareXe
class ShareXeBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int index) onTap;
  final String userRole; // 'PASSENGER' hoặc 'DRIVER'
  final int unreadChatCount;

  const ShareXeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
    this.unreadChatCount = 0,
  });

  @override
  State<ShareXeBottomNavBar> createState() => _ShareXeBottomNavBarState();
}

class _ShareXeBottomNavBarState extends State<ShareXeBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<ShareXeNavItem> _getNavItems() {
    if (widget.userRole == 'DRIVER') {
      return [
        ShareXeNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Trang chủ',
          route: AppRoutes.homeDriver,
        ),
        ShareXeNavItem(
          icon: Icons.directions_car_outlined,
          activeIcon: Icons.directions_car,
          label: 'Chuyến đi',
          route: '/driver/rides',
        ),
        ShareXeNavItem(
          icon: Icons.chat_bubble_outline,
          activeIcon: Icons.chat_bubble,
          label: 'Tin nhắn',
          route: AppRoutes.chatRooms,
          badgeCount: widget.unreadChatCount,
        ),
        ShareXeNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Tài khoản',
          route: AppRoutes.driverProfile,
        ),
      ];
    } else {
      return [
        ShareXeNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Trang chủ',
          route: AppRoutes.homePassenger,
        ),
        ShareXeNavItem(
          icon: Icons.search_outlined,
          activeIcon: Icons.search,
          label: 'Tìm kiếm',
          route: AppRoutes.searchRides,
        ),
        ShareXeNavItem(
          icon: Icons.chat_bubble_outline,
          activeIcon: Icons.chat_bubble,
          label: 'Tin nhắn',
          route: AppRoutes.chatRooms,
          badgeCount: widget.unreadChatCount,
        ),
        ShareXeNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Tài khoản',
          route: AppRoutes.passengerProfile,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _getNavItems();
    final primaryColor = widget.userRole == 'DRIVER' 
        ? AppColors.driverPrimary 
        : AppColors.passengerPrimary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Stack(
            children: [
              // Navigation items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isActive = widget.currentIndex == index;
                  final isMiddle = index == navItems.length ~/ 2;
                  
                  if (isMiddle && navItems.length % 2 == 1) {
                    // Space for FAB in the middle
                    return const SizedBox(width: 56);
                  }
                  
                  return _buildNavItem(
                    item: item,
                    isActive: isActive,
                    primaryColor: primaryColor,
                    onTap: () => widget.onTap(index),
                  );
                }).toList(),
              ),
              
              // Floating Action Button in center
              if (navItems.length % 2 == 1)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTapDown: (_) => _animationController.forward(),
                      onTapUp: (_) => _animationController.reverse(),
                      onTapCancel: () => _animationController.reverse(),
                      onTap: _onFabTapped,
                      child: AnimatedBuilder(
                        animation: _fabScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _fabScaleAnimation.value,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryColor,
                                    primaryColor.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.userRole == 'DRIVER' 
                                    ? Icons.add_road
                                    : Icons.search,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required ShareXeNavItem item,
    required bool isActive,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    key: ValueKey(isActive),
                    color: isActive ? primaryColor : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                
                // Badge for unread count
                if (item.badgeCount > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? primaryColor : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }

  void _onFabTapped() {
    if (widget.userRole == 'DRIVER') {
      // Navigate to create ride screen
      Navigator.pushNamed(context, '/driver/create-ride');
    } else {
      // Navigate to search rides screen
      Navigator.pushNamed(context, AppRoutes.searchRides);
    }
  }
}

/// Curved Bottom Navigation Bar (alternative design)
class ShareXeCurvedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onTap;
  final String userRole;
  final int unreadChatCount;

  const ShareXeCurvedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
    this.unreadChatCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = userRole == 'DRIVER' 
        ? AppColors.driverPrimary 
        : AppColors.passengerPrimary;

    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 80),
            painter: _CurvedNavPainter(backgroundColor: AppColors.surface),
          ),
          
          // FAB in center
          Center(
            heightFactor: 0.6,
            child: FloatingActionButton(
              onPressed: () => _onFabTapped(context),
              backgroundColor: primaryColor,
              elevation: 4,
              child: Icon(
                userRole == 'DRIVER' ? Icons.add_road : Icons.search,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          
          // Navigation items
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCurvedNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Trang chủ',
                  isActive: currentIndex == 0,
                  primaryColor: primaryColor,
                  onTap: () => onTap(0),
                ),
                _buildCurvedNavItem(
                  icon: userRole == 'DRIVER' 
                      ? Icons.directions_car_outlined 
                      : Icons.search_outlined,
                  activeIcon: userRole == 'DRIVER' 
                      ? Icons.directions_car 
                      : Icons.search,
                  label: userRole == 'DRIVER' ? 'Chuyến đi' : 'Tìm kiếm',
                  isActive: currentIndex == 1,
                  primaryColor: primaryColor,
                  onTap: () => onTap(1),
                ),
                const SizedBox(width: 56), // Space for FAB
                _buildCurvedNavItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: 'Tin nhắn',
                  isActive: currentIndex == 2,
                  primaryColor: primaryColor,
                  badgeCount: unreadChatCount,
                  onTap: () => onTap(2),
                ),
                _buildCurvedNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Tài khoản',
                  isActive: currentIndex == 3,
                  primaryColor: primaryColor,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurvedNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required Color primaryColor,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? primaryColor : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              
              if (badgeCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isActive ? primaryColor : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _onFabTapped(BuildContext context) {
    if (userRole == 'DRIVER') {
      Navigator.pushNamed(context, '/driver/create-ride');
    } else {
      Navigator.pushNamed(context, AppRoutes.searchRides);
    }
  }
}

/// Custom painter for curved navigation bar
class _CurvedNavPainter extends CustomPainter {
  final Color backgroundColor;

  _CurvedNavPainter({
    this.backgroundColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    Path path = Path()..moveTo(0, 12);

    const double insetRadius = 38;
    double insetCurveBeginningX = size.width / 2 - insetRadius;
    double insetCurveEndX = size.width / 2 + insetRadius;
    double transitionToInsetCurveWidth = size.width * 0.05;

    path.quadraticBezierTo(
      size.width * 0.20,
      0,
      insetCurveBeginningX - transitionToInsetCurveWidth,
      0,
    );
    path.quadraticBezierTo(
      insetCurveBeginningX,
      0,
      insetCurveBeginningX,
      insetRadius / 2,
    );

    path.arcToPoint(
      Offset(insetCurveEndX, insetRadius / 2),
      radius: const Radius.circular(10.0),
      clockwise: false,
    );

    path.quadraticBezierTo(
      insetCurveEndX,
      0,
      insetCurveEndX + transitionToInsetCurveWidth,
      0,
    );
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 12);
    path.lineTo(size.width, size.height + 56);
    path.lineTo(0, size.height + 56);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Data class cho navigation item
class ShareXeNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final int badgeCount;

  const ShareXeNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.badgeCount = 0,
  });
}
