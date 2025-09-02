import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Passenger History View - Pure UI component
class PassengerHistoryView extends StatelessWidget {
  const PassengerHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lịch sử chuyến đi',
              style: AppTheme.headingLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Filter tabs
            _buildFilterTabs(),
            const SizedBox(height: AppSpacing.lg),
            
            // History list
            Expanded(
              child: _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildFilterTab('Tất cả', true),
        const SizedBox(width: AppSpacing.md),
        _buildFilterTab('Đã hoàn thành', false),
        const SizedBox(width: AppSpacing.md),
        _buildFilterTab('Đã hủy', false),
      ],
    );
  }

  Widget _buildFilterTab(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.passengerPrimary 
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isSelected 
              ? AppColors.passengerPrimary 
              : AppColors.borderLight,
        ),
      ),
      child: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(
          color: isSelected 
              ? Colors.white 
              : AppColors.textSecondary,
          fontWeight: isSelected 
              ? FontWeight.w600 
              : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    // Mock data - replace with real data from cubit
    final mockHistory = [
      {
        'id': '1',
        'from': 'Quận 1, TP.HCM',
        'to': 'Quận 7, TP.HCM',
        'date': '15/12/2024',
        'time': '08:30',
        'price': '150',
        'status': 'completed',
        'driverName': 'Nguyễn Văn A',
        'rating': 4.8,
      },
      {
        'id': '2',
        'from': 'Quận 3, TP.HCM',
        'to': 'Quận 10, TP.HCM',
        'date': '14/12/2024',
        'time': '19:15',
        'price': '120',
        'status': 'completed',
        'driverName': 'Trần Thị B',
        'rating': 4.5,
      },
      {
        'id': '3',
        'from': 'Quận 5, TP.HCM',
        'to': 'Quận 2, TP.HCM',
        'date': '13/12/2024',
        'time': '14:20',
        'price': '200',
        'status': 'cancelled',
        'driverName': 'Lê Văn C',
        'rating': null,
      },
    ];

    if (mockHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Chưa có lịch sử chuyến đi',
              style: AppTheme.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: mockHistory.length,
      itemBuilder: (context, index) {
        final trip = mockHistory[index];
        return _buildHistoryItem(trip);
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> trip) {
    final isCompleted = trip['status'] == 'completed';
    final isCancelled = trip['status'] == 'cancelled';
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (isCompleted) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
      statusText = 'Hoàn thành';
    } else if (isCancelled) {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel;
      statusText = 'Đã hủy';
    } else {
      statusColor = AppColors.warning;
      statusIcon = Icons.schedule;
      statusText = 'Đang xử lý';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${trip['date']} - ${trip['time']}',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      statusText,
                      style: AppTheme.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Route info
          Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                color: AppColors.passengerPrimary,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  trip['from'],
                  style: AppTheme.bodyMedium,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xs),
          
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.grabOrange,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  trip['to'],
                  style: AppTheme.bodyMedium,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Driver and price info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.passengerPrimary.withOpacity(0.1),
                    child: Text(
                      trip['driverName'].substring(0, 2).toUpperCase(),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.passengerPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    trip['driverName'],
                    style: AppTheme.bodyMedium,
                  ),
                  if (trip['rating'] != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.star,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      trip['rating'].toString(),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '${trip['price']}k VNĐ',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppColors.passengerPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}