import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/booking/booking_cubit.dart';
import 'package:sharexev2/logic/booking/booking_state.dart';

class VehicleSeatSelection extends StatelessWidget {
  final String vehicleType; // 'car', 'bus', 'van'
  final int totalSeats;
  final List<int> reservedSeats;
  final double pricePerSeat;
  final Function(List<int> selectedSeats, double totalPrice)? onSeatsSelected;

  const VehicleSeatSelection({
    super.key,
    required this.vehicleType,
    required this.totalSeats,
    required this.reservedSeats,
    required this.pricePerSeat,
    this.onSeatsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              BookingCubit()..initializeSeats(
                vehicleType: vehicleType,
                totalSeats: totalSeats,
                reservedSeats: reservedSeats,
                pricePerSeat: pricePerSeat,
              ),
      child: VehicleSeatSelectionView(
        vehicleType: vehicleType,
        onSeatsSelected: onSeatsSelected,
      ),
    );
  }
}

class VehicleSeatSelectionView extends StatefulWidget {
  final String vehicleType;
  final Function(List<int> selectedSeats, double totalPrice)? onSeatsSelected;

  const VehicleSeatSelectionView({
    super.key,
    required this.vehicleType,
    this.onSeatsSelected,
  });

  @override
  State<VehicleSeatSelectionView> createState() =>
      _VehicleSeatSelectionViewState();
}

class _VehicleSeatSelectionViewState extends State<VehicleSeatSelectionView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }

        // Notify parent when seats are selected
        if (widget.onSeatsSelected != null) {
          widget.onSeatsSelected!(state.selectedSeats, state.totalPrice);
        }
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: AppTheme.shadowMedium,
          ),
          child: BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(state),
                  SizedBox(height: AppTheme.spacingL),
                  _buildVehicleLayout(state),
                  SizedBox(height: AppTheme.spacingL),
                  _buildLegend(),
                  SizedBox(height: AppTheme.spacingL),
                  _buildSummary(state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BookingState state) {
    return Row(
      children: [
        Icon(_getVehicleIcon(), color: AppTheme.passengerPrimary, size: 28),
        SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Seats', style: AppTheme.headingMedium),
              Text(
                '${state.totalSeats} seats - ${state.pricePerSeat.toStringAsFixed(0)}k/seat',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleLayout(BookingState state) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Driver seat indicator
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(Icons.drive_eta, color: Colors.white, size: 20),
              ),
              SizedBox(width: AppTheme.spacingS),
              Text(
                'Driver',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingM),

          // Seats grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(),
              childAspectRatio: 1.0,
              crossAxisSpacing: AppTheme.spacingS,
              mainAxisSpacing: AppTheme.spacingS,
            ),
            itemCount: state.seats.length,
            itemBuilder: (context, index) {
              return VehicleSeatWidget(
                seat: state.seats[index],
                onTap: () {
                  context.read<BookingCubit>().toggleSeatSelection(index);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          color: AppTheme.success,
          label: 'Available',
          icon: Icons.event_seat,
        ),
        _buildLegendItem(
          color: AppTheme.error,
          label: 'Reserved',
          icon: Icons.event_seat,
        ),
        _buildLegendItem(
          color: AppTheme.passengerPrimary,
          label: 'Selected',
          icon: Icons.event_seat,
        ),
      ],
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
        SizedBox(width: AppTheme.spacingXs),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }

  Widget _buildSummary(BookingState state) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.passengerPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${state.totalPrice.toStringAsFixed(0)}k VND',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.passengerPrimary,
                ),
              ),
              Text(
                '${state.selectedSeats.length} seats selected',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          if (state.selectedSeats.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                context.read<BookingCubit>().confirmBooking();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.passengerPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
              ),
              child: Text(
                'Continue',
                style: AppTheme.labelMedium.copyWith(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon() {
    switch (widget.vehicleType.toLowerCase()) {
      case 'bus':
        return Icons.directions_bus;
      case 'van':
        return Icons.airport_shuttle;
      default:
        return Icons.directions_car;
    }
  }

  int _getCrossAxisCount() {
    switch (widget.vehicleType.toLowerCase()) {
      case 'bus':
        return 4; // 2+2 layout
      case 'van':
        return 3; // 2+1 layout
      default:
        return 2; // 1+1 layout for car
    }
  }
}

class VehicleSeatWidget extends StatefulWidget {
  final VehicleSeat seat;
  final VoidCallback onTap;

  const VehicleSeatWidget({super.key, required this.seat, required this.onTap});

  @override
  State<VehicleSeatWidget> createState() => _VehicleSeatWidgetState();
}

class _VehicleSeatWidgetState extends State<VehicleSeatWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get seatColor {
    if (widget.seat.isSelected) {
      return AppTheme.passengerPrimary;
    } else if (widget.seat.isReserved) {
      return AppTheme.error;
    } else {
      return AppTheme.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.seat.isReserved ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: seatColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                boxShadow: widget.seat.isSelected ? AppTheme.shadowLight : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_seat, color: Colors.white, size: 20),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.seat.seatNumber}',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
