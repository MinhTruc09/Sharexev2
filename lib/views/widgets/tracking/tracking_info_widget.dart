import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/tracking/tracking_cubit.dart';
import '../../../config/theme.dart';

/// Widget to display tracking information like ETA, progress, etc.
class TrackingInfoWidget extends StatelessWidget {
  final bool isCompact;
  final VoidCallback? onTap;

  const TrackingInfoWidget({
    super.key,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingCubit, TrackingState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: onTap,
          child: Card(
            elevation: 4,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
            ),
            child: Container(
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              child: isCompact ? _buildCompactView(state) : _buildFullView(state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactView(TrackingState state) {
    return Row(
      children: [
        // Status indicator
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getStatusColor(state.status),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        
        // Status text and ETA
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getStatusText(state.status),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (state.eta != null)
                Text(
                  'ETA: ${_formatETA(state.eta!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        
        // Progress indicator
        if (state.progress != null)
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: state.progress,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.passengerPrimary,
              ),
              strokeWidth: 3,
            ),
          ),
        
        // Expand icon
        if (onTap != null) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.expand_more,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ],
    );
  }

  Widget _buildFullView(TrackingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with status
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getStatusColor(state.status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _getStatusText(state.status),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (state.lastUpdate != null)
              Text(
                _formatLastUpdate(state.lastUpdate!),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // ETA and Progress Row
        if (state.eta != null || state.progress != null)
          Row(
            children: [
              // ETA Section
              if (state.eta != null)
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.access_time,
                    title: 'Thời gian đến',
                    value: _formatETA(state.eta!),
                    color: AppColors.passengerPrimary,
                  ),
                ),
              
              if (state.eta != null && state.progress != null)
                const SizedBox(width: 12),
              
              // Progress Section
              if (state.progress != null)
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.trending_up,
                    title: 'Tiến độ',
                    value: '${(state.progress! * 100).toInt()}%',
                    color: AppColors.success,
                  ),
                ),
            ],
          ),
        
        // Distance and Time Row
        if (state.remainingDistance != null || state.remainingTime != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              // Distance Section
              if (state.remainingDistance != null)
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.straighten,
                    title: 'Khoảng cách',
                    value: '${state.remainingDistance!.toStringAsFixed(1)} km',
                    color: AppColors.warning,
                  ),
                ),
              
              if (state.remainingDistance != null && state.remainingTime != null)
                const SizedBox(width: 12),
              
              // Time Section
              if (state.remainingTime != null)
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.schedule,
                    title: 'Thời gian còn lại',
                    value: '${state.remainingTime!} phút',
                    color: AppColors.info,
                  ),
                ),
            ],
          ),
        ],
        
        // Progress Bar
        if (state.progress != null) ...[
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tiến độ chuyến đi',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(state.progress! * 100).toInt()}%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.passengerPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: state.progress,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.passengerPrimary,
                ),
                minHeight: 6,
              ),
            ],
          ),
        ],
        
        // Error display
        if (state.error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.error!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.active:
        return AppColors.success;
      case TrackingStatus.paused:
        return AppColors.warning;
      case TrackingStatus.completed:
        return AppColors.success;
      case TrackingStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.active:
        return 'Đang di chuyển';
      case TrackingStatus.paused:
        return 'Tạm dừng';
      case TrackingStatus.completed:
        return 'Đã hoàn thành';
      case TrackingStatus.cancelled:
        return 'Đã hủy';
      default:
        return 'Chưa bắt đầu';
    }
  }

  String _formatETA(DateTime eta) {
    final now = DateTime.now();
    final difference = eta.difference(now);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return '${hours}h ${minutes}m';
    }
  }

  String _formatLastUpdate(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    
    if (difference.inMinutes < 1) {
      return 'Vừa cập nhật';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else {
      return '${difference.inHours} giờ trước';
    }
  }
}
