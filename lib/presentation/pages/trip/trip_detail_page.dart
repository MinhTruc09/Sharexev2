import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/ride/ride_cubit.dart';
import 'package:sharexev2/data/repositories/ride/ride_repository_interface.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/models/ride/entities/ride_entity.dart' as ride_entity;

class TripDetailPage extends StatelessWidget {
  final String rideId;

  const TripDetailPage({super.key, required this.rideId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RideCubit(
        rideRepository: context.read<RideRepositoryInterface>(),
        bookingRepository: context.read<BookingRepositoryInterface>(),
      ),
      child: BlocBuilder<RideCubit, RideState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Chi tiết chuyến đi'),
            ),
            body: state.status == RideStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : state.status == RideStatus.error
                    ? Center(child: Text(state.error ?? 'Có lỗi xảy ra'))
                    : _buildTripDetails(context, state),
          );
        },
      ),
    );
  }

  Widget _buildTripDetails(BuildContext context, RideState state) {
    // For now, show sample data since we don't have loadRideDetails method
    final ride = ride_entity.RideEntity(
      id: int.parse(rideId),
      driverName: 'Tài xế mẫu',
      driverEmail: 'driver@example.com',
      departure: 'Điểm đi mẫu',
      startLat: 10.762622,
      startLng: 106.660172,
      startAddress: 'Điểm đi mẫu',
      startWard: 'Phường mẫu',
      startDistrict: 'Quận mẫu',
      startProvince: 'TP.HCM',
      endLat: 10.762622,
      endLng: 106.660172,
      endAddress: 'Điểm đến mẫu',
      endWard: 'Phường mẫu',
      endDistrict: 'Quận mẫu',
      endProvince: 'TP.HCM',
      destination: 'Điểm đến mẫu',
      startTime: DateTime.now(),
      pricePerSeat: 50000,
      totalSeat: 4,
      status: ride_entity.RideStatus.active,
    );
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin chuyến đi',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Điểm đi:', ride.departure),
                  _buildInfoRow('Điểm đến:', ride.destination),
                  _buildInfoRow('Thời gian:', ride.startTime.toString()),
                  _buildInfoRow('Trạng thái:', ride.status.name),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin tài xế',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Tên:', ride.driverName),
                  _buildInfoRow('Email:', ride.driverEmail),
                  _buildInfoRow('Số ghế:', '${ride.totalSeat}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
