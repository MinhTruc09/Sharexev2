import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/booking/booking_cubit.dart';
import 'package:sharexev2/logic/booking/booking_state.dart';

class TripSummarySection extends StatelessWidget {
  const TripSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        // Show booking summary if booking data is available
        if (state.bookingData == null) {
          return const SizedBox.shrink();
        }

        final bookingData = state.bookingData!;
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeManager.getPrimaryColorForRole('PASSENGER'),
                ThemeManager.getPrimaryColorForRole('PASSENGER').withOpacity(0.8),
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
                          'Đặt chuyến thành công!',
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
                icon: Icons.event_seat,
                label: 'Ghế đã chọn',
                value: state.selectedSeats.join(', '),
                iconColor: Colors.white70,
              ),
              
              _buildSummaryRow(
                icon: Icons.attach_money,
                label: 'Tổng tiền',
                value: '${state.totalPrice.toStringAsFixed(0)}k VNĐ',
                iconColor: Colors.white70,
                valueColor: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
              
              if (bookingData['bookingTime'] != null)
                _buildSummaryRow(
                  icon: Icons.access_time,
                  label: 'Thời gian đặt',
                  value: _formatDateTime(bookingData['bookingTime']),
                  iconColor: Colors.white70,
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

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }
}
