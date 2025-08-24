import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/trip/trip_detail_cubit.dart';
import 'package:sharexev2/presentation/widgets/booking/vehicle_seat_selection.dart';

class TripSeatSelectionSection extends StatelessWidget {
  final Map<String, dynamic> tripData;

  const TripSeatSelectionSection({
    super.key,
    required this.tripData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripDetailCubit, TripDetailState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn chỗ ngồi',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              VehicleSeatSelection(
                vehicleType: _getVehicleType(tripData['vehicleType']),
                totalSeats: _getTotalSeats(tripData['vehicleType']),
                reservedSeats: _getReservedSeats(),
                pricePerSeat: (tripData['price'] ?? 0).toDouble(),
                onSeatsSelected: (seats, price) {
                  context.read<TripDetailCubit>().selectSeats(seats);
                },
              ),
              
              if (state.hasSelectedSeats) ...[
                const SizedBox(height: 16),
                _buildSelectionSummary(state),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectionSummary(TripDetailState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeManager.getPrimaryColorForRole('PASSENGER').withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeManager.getPrimaryColorForRole('PASSENGER').withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ghế đã chọn:',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Text(
                state.selectedSeats.join(', '),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ).copyWith(
                  fontWeight: FontWeight.bold,
                  color: ThemeManager.getPrimaryColorForRole('PASSENGER'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng tiền:',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Text(
                '${state.totalPrice.toStringAsFixed(0)}k VNĐ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ).copyWith(
                  color: ThemeManager.getPrimaryColorForRole('PASSENGER'),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getVehicleType(String? vehicleType) {
    switch (vehicleType?.toLowerCase()) {
      case 'xe van':
        return 'van';
      case 'xe bus':
        return 'bus';
      default:
        return 'car';
    }
  }

  int _getTotalSeats(String? vehicleType) {
    switch (vehicleType?.toLowerCase()) {
      case 'xe van':
        return 7;
      case 'xe bus':
        return 16;
      default:
        return 4;
    }
  }

  List<int> _getReservedSeats() {
    final totalSeats = _getTotalSeats(tripData['vehicleType']);
    final availableSeats = (tripData['availableSeats'] ?? 0) as int;
    final reservedSeats = totalSeats - availableSeats;
    
    return List.generate(reservedSeats, (index) => index + 1);
  }
}
