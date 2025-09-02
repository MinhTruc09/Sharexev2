import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/ride/ride_cubit.dart';
import 'package:sharexev2/data/repositories/ride/ride_repository_interface.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';

class TripReviewPage extends StatelessWidget {
  final String rideId;

  const TripReviewPage({super.key, required this.rideId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RideCubit(
        rideRepository: context.read<RideRepositoryInterface>(),
        bookingRepository: context.read<BookingRepositoryInterface>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đánh giá chuyến đi'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đánh giá chuyến đi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Chuyến đi đã hoàn thành. Vui lòng đánh giá trải nghiệm của bạn.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 32),
              // TODO: Implement rating and review form
              Text('Form đánh giá sẽ được implement sau'),
            ],
          ),
        ),
      ),
    );
  }
}
