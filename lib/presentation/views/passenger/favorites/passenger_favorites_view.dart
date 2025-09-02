import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Passenger Favorites View - Pure UI component
class PassengerFavoritesView extends StatelessWidget {
  const PassengerFavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Địa điểm yêu thích',
              style: AppTheme.headingLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Add favorite button
            _buildAddFavoriteButton(context),
            const SizedBox(height: AppSpacing.lg),
            
            // Favorites list
            Expanded(
              child: _buildFavoritesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFavoriteButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddFavoriteDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.passengerPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.passengerPrimary.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: AppColors.passengerPrimary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Thêm địa điểm yêu thích',
              style: AppTheme.bodyLarge.copyWith(
                color: AppColors.passengerPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    // Mock data - replace with real data from cubit
    final mockFavorites = [
      {
        'id': '1',
        'name': 'Nhà',
        'address': '123 Đường ABC, Quận 1, TP.HCM',
        'type': 'home',
        'isDefault': true,
      },
      {
        'id': '2',
        'name': 'Công ty',
        'address': '456 Đường XYZ, Quận 3, TP.HCM',
        'type': 'work',
        'isDefault': true,
      },
      {
        'id': '3',
        'name': 'Trung tâm thương mại',
        'address': '789 Đường DEF, Quận 7, TP.HCM',
        'type': 'other',
        'isDefault': false,
      },
      {
        'id': '4',
        'name': 'Sân bay Tân Sơn Nhất',
        'address': 'Sân bay Tân Sơn Nhất, Quận Tân Bình, TP.HCM',
        'type': 'other',
        'isDefault': false,
      },
    ];

    if (mockFavorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Chưa có địa điểm yêu thích nào',
              style: AppTheme.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Thêm địa điểm để dễ dàng đặt chuyến đi',
              style: AppTheme.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: mockFavorites.length,
      itemBuilder: (context, index) {
        final favorite = mockFavorites[index];
        return _buildFavoriteItem(favorite);
      },
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> favorite) {
    IconData icon;
    Color iconColor;
    
    switch (favorite['type']) {
      case 'home':
        icon = Icons.home;
        iconColor = AppColors.passengerPrimary;
        break;
      case 'work':
        icon = Icons.work;
        iconColor = AppColors.driverPrimary;
        break;
      default:
        icon = Icons.location_on;
        iconColor = AppColors.grabOrange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      favorite['name'],
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (favorite['isDefault']) ...[
                      const SizedBox(width: AppSpacing.sm),
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
                          'Mặc định',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColors.passengerPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  favorite['address'],
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          PopupMenuButton<String>(
            onSelected: (value) => _handleFavoriteAction(value, favorite),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Chỉnh sửa'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'set_default',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Đặt làm mặc định'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: AppSpacing.sm),
                    Text('Xóa', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: Icon(
              Icons.more_vert,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFavoriteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm địa điểm yêu thích'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tên địa điểm',
                hintText: 'Ví dụ: Nhà, Công ty',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                hintText: 'Nhập địa chỉ chi tiết',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Loại địa điểm',
              ),
              items: const [
                DropdownMenuItem(value: 'home', child: Text('Nhà')),
                DropdownMenuItem(value: 'work', child: Text('Công ty')),
                DropdownMenuItem(value: 'other', child: Text('Khác')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm địa điểm yêu thích')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.passengerPrimary,
            ),
            child: const Text(
              'Thêm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFavoriteAction(String action, Map<String, dynamic> favorite) {
    switch (action) {
      case 'edit':
        // TODO: Implement edit favorite
        break;
      case 'set_default':
        // TODO: Implement set as default
        break;
      case 'delete':
        // TODO: Implement delete favorite
        break;
    }
  }
}