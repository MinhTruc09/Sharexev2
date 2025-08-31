import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/home/home_driver_cubit.dart';

class HomeDriverPage extends StatelessWidget {
  const HomeDriverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeDriverCubit(
        rideRepository: ServiceLocator.get(),
        bookingRepository: ServiceLocator.get(),
        userRepository: ServiceLocator.get(),
      )..init(),
      child: BlocBuilder<HomeDriverCubit, HomeDriverState>(
        builder: (context, state) {
          if (state.status == HomeDriverStatus.loading) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              body: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }
          if (state.status == HomeDriverStatus.error) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              appBar: AppBar(
                title: const Text('Lỗi'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error ?? 'Có lỗi xảy ra',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeDriverCubit>().init();
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              title: const Text('Trang chủ Tài xế'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.drive_eta,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chào mừng Tài xế!',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bạn đã sẵn sàng nhận chuyến đi mới',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to create ride
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Tạo chuyến đi'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Navigate to my rides
                          },
                          icon: const Icon(Icons.list),
                          label: const Text('Chuyến đi của tôi'),
                        ),
                      ),
                    ],
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
