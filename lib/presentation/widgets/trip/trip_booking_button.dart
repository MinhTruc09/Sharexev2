import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/trip/trip_detail_cubit.dart';

class TripBookingButton extends StatelessWidget {
  const TripBookingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripDetailCubit, TripDetailState>(
      builder: (context, state) {
        return FloatingActionButton.extended(
          onPressed: !state.hasSelectedSeats ? null : () {
            context.read<TripDetailCubit>().bookTrip();
          },
          backgroundColor: !state.hasSelectedSeats 
              ? Colors.grey 
              : ThemeManager.getPrimaryColorForRole('PASSENGER'),
          label: Text(
            state.isBooking ? 'Đang đặt...' : 'Đặt chuyến',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          icon: state.isBooking 
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
