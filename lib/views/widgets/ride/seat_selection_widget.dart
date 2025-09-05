import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Widget chọn chỗ ngồi cho chuyến đi ShareXe
class RideSeatSelectionWidget extends StatefulWidget {
  final int totalSeats;
  final int availableSeats;
  final List<int> reservedSeats;
  final double pricePerSeat;
  final Function(List<int> selectedSeats, double totalPrice) onSeatsSelected;
  
  const RideSeatSelectionWidget({
    super.key,
    required this.totalSeats,
    required this.availableSeats,
    this.reservedSeats = const [],
    required this.pricePerSeat,
    required this.onSeatsSelected,
  });

  @override
  State<RideSeatSelectionWidget> createState() => _RideSeatSelectionWidgetState();
}

class _RideSeatSelectionWidgetState extends State<RideSeatSelectionWidget> {
  List<RideSeat> seats = [];
  
  @override
  void initState() {
    super.initState();
    _initializeSeats();
  }

  void _initializeSeats() {
    seats = List.generate(widget.totalSeats, (index) {
      return RideSeat(
        seatNumber: index + 1,
        price: widget.pricePerSeat,
        isReserved: widget.reservedSeats.contains(index + 1),
        isAvailable: index < widget.availableSeats && !widget.reservedSeats.contains(index + 1),
      );
    });
  }

  void toggleSeatSelection(int index) {
    if (seats[index].isAvailable && !seats[index].isReserved) {
      setState(() {
        seats[index].isSelected = !seats[index].isSelected;
      });
      
      final selectedSeats = seats
          .where((seat) => seat.isSelected)
          .map((seat) => seat.seatNumber)
          .toList();
      final totalPrice = selectedSeats.length * widget.pricePerSeat;
      
      widget.onSeatsSelected(selectedSeats, totalPrice);
    }
  }

  int getSelectedSeatsCount() {
    return seats.where((seat) => seat.isSelected).length;
  }

  double getTotalPrice() {
    return getSelectedSeatsCount() * widget.pricePerSeat;
  }

  @override
  Widget build(BuildContext context) {
    int selectedSeatsCount = getSelectedSeatsCount();
    double totalPrice = getTotalPrice();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.airline_seat_recline_normal, 
                   color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Chọn chỗ ngồi',
                style: AppTextStyles.headingMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.availableSeats}/${widget.totalSeats} ghế trống',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Driver seat indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person, 
                     color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'Tài xế',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Cửa xe',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Seats grid - Layout giống xe thật
          _buildSeatsLayout(),
          
          const SizedBox(height: 20),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(
                color: AppColors.success,
                label: 'Có thể chọn',
                icon: Icons.check_circle_outline,
              ),
              _buildLegendItem(
                color: AppColors.error,
                label: 'Đã đặt',
                icon: Icons.cancel_outlined,
              ),
              _buildLegendItem(
                color: AppColors.primary,
                label: 'Đã chọn',
                icon: Icons.event_seat,
              ),
            ],
          ),
          
          if (selectedSeatsCount > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng cộng',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          text: '${totalPrice.toStringAsFixed(0)}₫',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: ' ($selectedSeatsCount ghế)',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Ghế: ${seats.where((s) => s.isSelected).map((s) => s.seatNumber).join(', ')}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeatsLayout() {
    // Layout cho xe 4-7 chỗ
    if (widget.totalSeats <= 4) {
      return _build4SeatLayout();
    } else if (widget.totalSeats <= 7) {
      return _build7SeatLayout();
    } else {
      return _buildGridLayout();
    }
  }

  Widget _build4SeatLayout() {
    return Column(
      children: [
        // Hàng ghế sau
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (seats.length > 1) _buildSeatWidget(1), // Ghế 2
            const SizedBox(width: 40), // Lối đi giữa
            if (seats.length > 0) _buildSeatWidget(0), // Ghế 1
          ],
        ),
        const SizedBox(height: 20),
        // Hàng ghế trước
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (seats.length > 3) _buildSeatWidget(3), // Ghế 4
            const SizedBox(width: 40),
            if (seats.length > 2) _buildSeatWidget(2), // Ghế 3
          ],
        ),
      ],
    );
  }

  Widget _build7SeatLayout() {
    return Column(
      children: [
        // Hàng ghế sau (3 ghế)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (seats.length > 4) _buildSeatWidget(4), // Ghế 5
            if (seats.length > 5) _buildSeatWidget(5), // Ghế 6
            if (seats.length > 6) _buildSeatWidget(6), // Ghế 7
          ],
        ),
        const SizedBox(height: 20),
        // Hàng ghế giữa (2 ghế)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (seats.length > 2) _buildSeatWidget(2), // Ghế 3
            const SizedBox(width: 60),
            if (seats.length > 3) _buildSeatWidget(3), // Ghế 4
          ],
        ),
        const SizedBox(height: 20),
        // Hàng ghế trước (2 ghế)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (seats.length > 1) _buildSeatWidget(1), // Ghế 2
            const SizedBox(width: 60),
            if (seats.length > 0) _buildSeatWidget(0), // Ghế 1
          ],
        ),
      ],
    );
  }

  Widget _buildGridLayout() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: seats.length,
      itemBuilder: (context, index) {
        return _buildSeatWidget(index);
      },
    );
  }

  Widget _buildSeatWidget(int index) {
    final seat = seats[index];
    Color seatColor;
    Color borderColor = Colors.transparent;
    
    if (seat.isSelected) {
      seatColor = AppColors.primary;
      borderColor = AppColors.primary;
    } else if (seat.isReserved) {
      seatColor = AppColors.error;
    } else if (seat.isAvailable) {
      seatColor = AppColors.success;
    } else {
      seatColor = AppColors.borderLight;
    }

    return GestureDetector(
      onTap: () => toggleSeatSelection(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: seatColor.withOpacity(seat.isSelected ? 1.0 : 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: seat.isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.airline_seat_recline_normal,
              color: seat.isSelected ? Colors.white : 
                     seat.isAvailable && !seat.isReserved ? Colors.white : 
                     Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              '${seat.seatNumber}',
              style: AppTextStyles.bodySmall.copyWith(
                color: seat.isSelected ? Colors.white : 
                       seat.isAvailable && !seat.isReserved ? Colors.white : 
                       Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Model cho ghế trong xe
class RideSeat {
  final int seatNumber;
  bool isAvailable;
  bool isSelected;
  bool isReserved;
  final double price;

  RideSeat({
    required this.seatNumber,
    this.isAvailable = true,
    this.isSelected = false,
    this.isReserved = false,
    required this.price,
  });
}
