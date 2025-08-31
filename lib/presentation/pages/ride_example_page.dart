import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/ride/ride_cubit.dart';

class RideExamplePage extends StatelessWidget {
  const RideExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RideCubit(
        rideRepository: ServiceLocator.get(),
        bookingRepository: ServiceLocator.get(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ride Example - Clean Architecture'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<RideCubit, RideState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Display
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${state.status.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (state.error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Error: ${state.error}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  ElevatedButton(
                    onPressed: state.status == RideStatus.loading
                        ? null
                        : () {
                            context.read<RideCubit>().searchRides(
                              departure: 'Hà Nội',
                              destination: 'TP.HCM',
                              startDate: DateTime.now().add(const Duration(days: 1)),
                              minSeats: 1,
                              maxPrice: 500000,
                            );
                          },
                    child: const Text('🔍 Tìm kiếm chuyến đi'),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  ElevatedButton(
                    onPressed: state.status == RideStatus.loading
                        ? null
                        : () {
                            context.read<RideCubit>().getRecommendedRides(
                              userLocation: 'Hà Nội',
                              preferredDestination: 'TP.HCM',
                              requiredSeats: 2,
                            );
                          },
                    child: const Text('⭐ Chuyến đi đề xuất'),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  ElevatedButton(
                    onPressed: state.status == RideStatus.loading
                        ? null
                        : () {
                            context.read<RideCubit>().createRide(
                              departure: 'Hà Nội',
                              destination: 'TP.HCM',
                              startTime: DateTime.now().add(const Duration(days: 1)),
                              pricePerSeat: 200000,
                              totalSeats: 4,
                            );
                          },
                    child: const Text('🚗 Tạo chuyến đi mới'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Results Display
                  if (state.rides.isNotEmpty) ...[
                    const Text(
                      'Kết quả tìm kiếm:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.rides.length,
                        itemBuilder: (context, index) {
                          final ride = state.rides[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text('${ride.departure} → ${ride.destination}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tài xế: ${ride.driverName}'),
                                  Text('Giá: ${ride.pricePerSeat.toStringAsFixed(0)} VNĐ/ghế'),
                                  Text('Ghế trống: ${ride.availableSeats}'),
                                  Text('Thời gian: ${ride.startTime.toString().substring(0, 16)}'),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  context.read<RideCubit>().getRideById(ride.id);
                                },
                                child: const Text('Chi tiết'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  
                  // Current Ride Display
                  if (state.currentRide != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chuyến đi hiện tại:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('ID: ${state.currentRide!.id}'),
                            Text('Từ: ${state.currentRide!.departure}'),
                            Text('Đến: ${state.currentRide!.destination}'),
                            Text('Tài xế: ${state.currentRide!.driverName}'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.read<RideCubit>().cancelRide(state.currentRide!.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Hủy chuyến đi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  // Loading Indicator
                  if (state.status == RideStatus.loading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
