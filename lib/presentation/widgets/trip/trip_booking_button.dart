import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/booking/booking_cubit.dart';
import 'package:sharexev2/logic/booking/booking_state.dart';

class TripBookingButton extends StatelessWidget {
  const TripBookingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        return FloatingActionButton.extended(
          onPressed: state.selectedSeats.isEmpty ? null : () {
            // TODO: Implement booking through BookingCubit
            // context.read<BookingCubit>().createBooking();
          },
          backgroundColor: state.selectedSeats.isEmpty 
              ? Colors.grey 
              : ThemeManager.getPrimaryColorForRole('PASSENGER'),
          label: Text(
            state.status == BookingStatus.selecting ? 'Đang đặt...' : 'Đặt chuyến',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          icon: state.status == BookingStatus.selecting 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.check, color: Colors.white),
        );
      },
    );
  }
}
