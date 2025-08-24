import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/map/map_bloc.dart';
import 'package:sharexev2/logic/map/map_event.dart';
import 'package:sharexev2/logic/map/map_state.dart';
import 'package:sharexev2/logic/trip/trip_detail_cubit.dart';
import 'package:sharexev2/presentation/widgets/trip/driver_avatar_button.dart';
import 'package:sharexev2/presentation/widgets/trip/trip_map_section.dart';
import 'package:sharexev2/presentation/widgets/trip/trip_info_section.dart';
import 'package:sharexev2/presentation/widgets/trip/trip_seat_selection_section.dart';
import 'package:sharexev2/presentation/widgets/trip/trip_booking_button.dart';
import 'package:sharexev2/routes/app_routes.dart';
import 'package:latlong2/latlong.dart';

class TripDetailPage extends StatelessWidget {
  final Map<String, dynamic> tripData;

  const TripDetailPage({super.key, required this.tripData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripDetailCubit()..initializeTrip(tripData),
      child: TripDetailView(tripData: tripData),
    );
  }
}

class TripDetailView extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const TripDetailView({super.key, required this.tripData});

  @override
  State<TripDetailView> createState() => _TripDetailViewState();
}

class _TripDetailViewState extends State<TripDetailView> {
  @override
  void initState() {
    super.initState();
    // Load map data for this trip
    context.read<MapBloc>().add(LoadTripDetailMap(
      driverLocation: const LatLng(10.762622, 106.660172), // Mock driver location
      passengerLocation: const LatLng(10.776889, 106.700806), // Mock passenger location
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripDetailCubit, TripDetailState>(
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: const Color(0xFFE53E3E),
              action: SnackBarAction(
                label: 'Đóng',
                textColor: Colors.white,
                onPressed: () {
                  context.read<TripDetailCubit>().clearError();
                },
              ),
            ),
          );
        }
        
        if (state.isBookingSuccess) {
          _showSuccessDialog(context, state);
        }
        
        if (state.status == TripDetailStatus.navigateToReview) {
          Navigator.pushNamed(
            context,
            AppRoute.tripReview,
            arguments: {
              'tripData': {
                ...widget.tripData,
                'totalPrice': state.totalPrice,
                'duration': '45 phút',
              },
              'role': 'PASSENGER',
            },
          );
          context.read<TripDetailCubit>().resetStatus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TripMapSection(tripData: widget.tripData),
                  TripInfoSection(tripData: widget.tripData),
                  const Divider(height: 32),
                  TripSeatSelectionSection(tripData: widget.tripData),
                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
            // Driver avatar button
            DriverAvatarButton(
              driverName: widget.tripData['driverName'] ?? 'Tài xế',
              driverInitials: widget.tripData['driverInitials'] ?? 'TX',
              driverAvatar: null,
              rating: (widget.tripData['rating'] ?? 0.0).toDouble(),
            ),
          ],
        ),
        floatingActionButton: const TripBookingButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeManager.getPrimaryColorForRole('PASSENGER'),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Chi tiết chuyến đi',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chia sẻ chuyến đi')),
            );
          },
        ),
      ],
    );
  }

  void _showSuccessDialog(BuildContext context, TripDetailState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt chuyến thành công!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ghế: ${state.selectedSeats.join(', ')}'),
            Text('Tổng tiền: ${state.totalPrice.toStringAsFixed(0)}k VNĐ'),
            const SizedBox(height: 8),
            const Text('Tài xế sẽ liên hệ với bạn sớm nhất!'),
            const SizedBox(height: 16),
            const Text(
              'Sau khi hoàn thành chuyến đi, bạn có thể đánh giá để nhận ưu đãi!',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TripDetailCubit>().navigateToReview();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.passengerPrimary,
            ),
            child: const Text(
              'Đánh giá ngay',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
