import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Unified bottom navigation for both roles
class AppBottomNav extends StatelessWidget {
  final String role;
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.role,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPassenger = role == 'PASSENGER';
    final primaryColor = isPassenger ? AppColors.passengerPrimary : AppColors.driverPrimary;
    final items = isPassenger ? _passengerItems : _driverItems;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;

              return GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected ? primaryColor : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? primaryColor : Colors.grey,
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

  static const List<_NavItem> _passengerItems = [
    _NavItem(Icons.home_outlined, Icons.home, 'Trang chủ'),
    _NavItem(Icons.history_outlined, Icons.history, 'Lịch sử'),
    _NavItem(Icons.favorite_outline, Icons.favorite, 'Yêu thích'),
    _NavItem(Icons.settings_outlined, Icons.settings, 'Cài đặt'),
  ];

  static const List<_NavItem> _driverItems = [
    _NavItem(Icons.home_outlined, Icons.home, 'Trang chủ'),
    _NavItem(Icons.directions_car_outlined, Icons.directions_car, 'Chuyến đi'),
    _NavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Thu nhập'),
    _NavItem(Icons.settings_outlined, Icons.settings, 'Cài đặt'),
  ];
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}
