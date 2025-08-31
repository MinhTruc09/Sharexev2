import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/home/home_passenger_cubit.dart';

/// Passenger-specific search widget
class PassengerSearchWidget extends StatelessWidget {
  const PassengerSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePassengerCubit, HomePassengerState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // From location
              _buildLocationField(
                icon: Icons.radio_button_checked,
                iconColor: AppColors.grabGreen,
                hint: state.pickupAddress ?? 'Điểm đón',
                onTap: () => _selectPickupLocation(context),
              ),
              
              const SizedBox(height: 12),
              
              // Swap button
              Center(
                child: GestureDetector(
                  onTap: () => _swapLocations(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.passengerPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.swap_vert,
                      color: AppColors.passengerPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // To location
              _buildLocationField(
                icon: Icons.location_on,
                iconColor: AppColors.grabOrange,
                hint: state.dropoffAddress ?? 'Điểm đến',
                onTap: () => _selectDropoffLocation(context),
              ),
              
              const SizedBox(height: 16),
              
              // Search button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _canSearch(state) ? () => _searchRides(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.passengerPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.isSearching) ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Đang tìm...'),
                      ] else ...[
                        const Icon(Icons.search, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Tìm chuyến đi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationField({
    required IconData icon,
    required Color iconColor,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hint,
                style: TextStyle(
                  color: hint.contains('Điểm') ? Colors.grey.shade600 : AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  bool _canSearch(HomePassengerState state) {
    return state.pickupAddress != null && 
           state.dropoffAddress != null && 
           !state.isSearching;
  }

  void _selectPickupLocation(BuildContext context) {
    // Navigate to location picker or show bottom sheet
    _showLocationPicker(context, isPickup: true);
  }

  void _selectDropoffLocation(BuildContext context) {
    // Navigate to location picker or show bottom sheet
    _showLocationPicker(context, isPickup: false);
  }

  void _swapLocations(BuildContext context) {
    context.read<HomePassengerCubit>().swapLocations();
  }

  void _searchRides(BuildContext context) {
    context.read<HomePassengerCubit>().searchRides();
  }

  void _showLocationPicker(BuildContext context, {required bool isPickup}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationPickerBottomSheet(isPickup: isPickup),
    );
  }
}

class _LocationPickerBottomSheet extends StatefulWidget {
  final bool isPickup;

  const _LocationPickerBottomSheet({required this.isPickup});

  @override
  State<_LocationPickerBottomSheet> createState() => _LocationPickerBottomSheetState();
}

class _LocationPickerBottomSheetState extends State<_LocationPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentLocations = [
    'Sân bay Tân Sơn Nhất',
    'Bến xe Miền Đông',
    'Chợ Bến Thành',
    'Landmark 81',
    'Đại học Bách Khoa',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                Expanded(
                  child: Text(
                    widget.isPickup ? 'Chọn điểm đón' : 'Chọn điểm đến',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance the close button
              ],
            ),
          ),
          
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm địa điểm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.passengerPrimary),
                ),
              ),
              onChanged: (value) {
                // TODO: Implement search
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Current location
          ListTile(
            leading: Icon(
              Icons.my_location,
              color: AppColors.passengerPrimary,
            ),
            title: const Text('Vị trí hiện tại'),
            subtitle: const Text('Quận 1, TP. Hồ Chí Minh'),
            onTap: () => _selectLocation(context, 'Vị trí hiện tại'),
          ),
          
          const Divider(),
          
          // Recent locations
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Địa điểm gần đây',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ..._recentLocations.map((location) {
                  return ListTile(
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: Text(location),
                    onTap: () => _selectLocation(context, location),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectLocation(BuildContext context, String location) {
    final cubit = context.read<HomePassengerCubit>();
    
    if (widget.isPickup) {
      cubit.setPickupLocation(location, 10.762622, 106.660172);
    } else {
      cubit.setDropoffLocation(location, 10.762622, 106.660172);
    }
    
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
