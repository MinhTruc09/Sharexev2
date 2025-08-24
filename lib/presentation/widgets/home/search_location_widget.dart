import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/home/home_passenger_cubit.dart';

class SearchLocationWidget extends StatefulWidget {
  const SearchLocationWidget({super.key});

  @override
  State<SearchLocationWidget> createState() => _SearchLocationWidgetState();
}

class _SearchLocationWidgetState extends State<SearchLocationWidget> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final FocusNode _pickupFocus = FocusNode();
  final FocusNode _dropoffFocus = FocusNode();
  bool _isPickupFocused = false;

  @override
  void initState() {
    super.initState();
    _pickupFocus.addListener(() {
      setState(() {
        _isPickupFocused = _pickupFocus.hasFocus;
      });
    });
    _dropoffFocus.addListener(() {
      setState(() {
        _isPickupFocused = false;
      });
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _pickupFocus.dispose();
    _dropoffFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomePassengerCubit, HomePassengerState>(
      listener: (context, state) {
        if (state.pickupAddress != null && _pickupController.text.isEmpty) {
          _pickupController.text = state.pickupAddress!;
        }
        if (state.dropoffAddress != null && _dropoffController.text.isEmpty) {
          _dropoffController.text = state.dropoffAddress!;
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pickup field
            _buildLocationField(
              controller: _pickupController,
              focusNode: _pickupFocus,
              hintText: 'Điểm đón',
              icon: Icons.radio_button_checked,
              iconColor: Colors.green,
              onChanged: (value) {
                context.read<HomePassengerCubit>().searchPlaces(value);
              },
              onTap: () {
                setState(() {
                  _isPickupFocused = true;
                });
              },
            ),
            
            // Divider
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 1,
              color: Colors.grey.shade200,
            ),
            
            // Dropoff field
            _buildLocationField(
              controller: _dropoffController,
              focusNode: _dropoffFocus,
              hintText: 'Điểm đến',
              icon: Icons.location_on,
              iconColor: Colors.red,
              onChanged: (value) {
                context.read<HomePassengerCubit>().searchPlaces(value);
              },
              onTap: () {
                setState(() {
                  _isPickupFocused = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    required Color iconColor,
    required ValueChanged<String> onChanged,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            ),
        ],
      ),
    );
  }
}

class SearchResultsWidget extends StatelessWidget {
  const SearchResultsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePassengerCubit, HomePassengerState>(
      builder: (context, state) {
        if (state.isSearching) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.searchResults.isEmpty) {
          return _buildSuggestions(context, state);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.searchResults.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final place = state.searchResults[index];
              return ListTile(
                leading: const Icon(Icons.location_on, color: Colors.grey),
                title: Text(place),
                onTap: () {
                  // Mock coordinates for demo
                  final lat = 21.0285 + (index * 0.01);
                  final lng = 105.8542 + (index * 0.01);
                  
                  context.read<HomePassengerCubit>().setDropoffLocation(
                    place,
                    lat,
                    lng,
                  );
                  context.read<HomePassengerCubit>().clearSearchResults();
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSuggestions(BuildContext context, HomePassengerState state) {
    if (state.popularDestinations.isEmpty && state.recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.recentSearches.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tìm kiếm gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...state.recentSearches.map((place) => ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(place),
              onTap: () => _selectPlace(context, place),
            )),
          ],
          if (state.popularDestinations.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Địa điểm phổ biến',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...state.popularDestinations.take(5).map((place) => ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(place),
              onTap: () => _selectPlace(context, place),
            )),
          ],
        ],
      ),
    );
  }

  void _selectPlace(BuildContext context, String place) {
    // Mock coordinates
    final lat = 21.0285 + (place.hashCode % 100) * 0.001;
    final lng = 105.8542 + (place.hashCode % 100) * 0.001;
    
    context.read<HomePassengerCubit>().setDropoffLocation(place, lat, lng);
    context.read<HomePassengerCubit>().clearSearchResults();
  }
}
