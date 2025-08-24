import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/trip/trip_review_cubit.dart';

class TripSummarySection extends StatelessWidget {
  const TripSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripReviewCubit, TripReviewState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeManager.getPrimaryColorForRole(state.role),
                ThemeManager.getPrimaryColorForRole(state.role).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chuyến đi đã hoàn thành!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Cảm ơn bạn đã sử dụng ShareXe',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              const Divider(color: Colors.white30, height: 1),
              const SizedBox(height: 20),
              
              _buildSummaryRow(
                icon: Icons.location_on,
                label: 'Từ',
                value: state.tripOrigin,
                iconColor: Colors.white70,
              ),
              
              _buildSummaryRow(
                icon: Icons.location_on,
                label: 'Đến',
                value: state.tripDestination,
                iconColor: const Color(0xFF38A169),
              ),
              
              _buildSummaryRow(
                icon: Icons.access_time,
                label: 'Thời gian',
                value: state.tripDuration,
                iconColor: Colors.white70,
              ),
              
              _buildSummaryRow(
                icon: Icons.attach_money,
                label: 'Tổng tiền',
                value: '${state.tripPrice}k VNĐ',
                iconColor: Colors.white70,
                valueColor: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    Color? valueColor,
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ).copyWith(
                color: valueColor ?? Colors.white,
                fontWeight: fontWeight ?? FontWeight.normal,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
