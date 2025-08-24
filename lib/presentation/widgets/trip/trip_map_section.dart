import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/map/map_bloc.dart';
import 'package:sharexev2/logic/map/map_state.dart';

class TripMapSection extends StatelessWidget {
  final Map<String, dynamic> tripData;

  const TripMapSection({super.key, required this.tripData});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapTripDetailLoaded) {
              return _buildInteractiveMap();
            } else if (state is MapLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return _buildStaticMap();
            }
          },
        ),
      ),
    );
  }

  Widget _buildInteractiveMap() {
    return Stack(
      children: [
        // Placeholder for interactive map
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeManager.getPrimaryColorForRole(
                  'PASSENGER',
                ).withValues(alpha: 0.1),
                ThemeManager.getPrimaryColorForRole(
                  'PASSENGER',
                ).withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 64,
                  color: ThemeManager.getPrimaryColorForRole('PASSENGER'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bản đồ tương tác',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Có thể zoom in/out và di chuyển',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Map controls
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                onPressed: () {},
                backgroundColor: Colors.white,
                child: Icon(Icons.add, color: AppTheme.passengerPrimary),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                onPressed: () {},
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.remove,
                  color: AppTheme.passengerPrimary,
                ),
              ),
            ],
          ),
        ),
        // Route info overlay
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              boxShadow: AppTheme.shadowLight,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Từ: ${tripData['origin']}',
                        style: AppTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Đến: ${tripData['destination']}',
                        style: AppTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.passengerPrimary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    '${tripData['price']}k',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticMap() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: Colors.grey.shade200),
              child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Bản đồ tĩnh', style: AppTheme.headingSmall),
              Text('Hiển thị tuyến đường cố định', style: AppTheme.bodyMedium),
            ],
          ),
        ),
    );
  }
}
