import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/home/home_passenger_cubit.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/presentation/widgets/common/custom_bottom_nav.dart';
import 'package:sharexev2/presentation/widgets/home/search_bottom_sheet.dart';
import 'package:sharexev2/presentation/widgets/home/trip_card.dart';
import 'package:sharexev2/routes/app_routes.dart';

class HomePassengerPage extends StatelessWidget {
  const HomePassengerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomePassengerCubit()..init(),
      child: const HomePassengerView(),
    );
  }
}

class HomePassengerView extends StatefulWidget {
  const HomePassengerView({super.key});

  @override
  State<HomePassengerView> createState() => _HomePassengerViewState();
}

class _HomePassengerViewState extends State<HomePassengerView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomePassengerCubit, HomePassengerState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Close',
                textColor: Colors.white,
                onPressed: () {
                  context.read<HomePassengerCubit>().clearError();
                },
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        body: BlocBuilder<HomePassengerCubit, HomePassengerState>(
          builder: (context, state) {
            if (state.status == HomePassengerStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<HomePassengerCubit>().refreshNearbyTrips();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBanner(),
                      _buildSearchSection(),
                      _buildTripStatusSection(state),
                      _buildNearbyTripsSection(state),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: CustomBottomNavBar(
          role: 'PASSENGER',
          currentIndex: _currentNavIndex,
          onTap: (index) {
            setState(() {
              _currentNavIndex = index;
            });
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.passengerPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Text(
            'ShareXe',
            style: AppTheme.headingMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'Hello, Passenger!',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.widgets),
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoute.bookingDemo,
              arguments: 'PASSENGER',
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Notifications')));
          },
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.passengerPrimary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    'P',
                    style: AppTheme.headingMedium.copyWith(
                      color: AppTheme.passengerPrimary,
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.spacingM),
                Text(
                  'Passenger',
                  style: AppTheme.headingSmall.copyWith(color: Colors.white),
                ),
                Text(
                  'passenger@example.com',
                  style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Trip History'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 200,
      margin: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.passengerPrimary,
            AppTheme.passengerPrimary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowMedium,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Discover Trips',
                  style: AppTheme.headingLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacingS),
                Text(
                  'Find and book trips easily',
                  style: AppTheme.bodyLarge.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: GestureDetector(
        onTap: _showSearchBottomSheet,
        child: Container(
          padding: EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(
              color: AppTheme.passengerPrimary.withOpacity(0.3),
            ),
            boxShadow: AppTheme.shadowLight,
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppTheme.passengerPrimary, size: 28),
              SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Trips',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Tap to find suitable trips',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripStatusSection(HomePassengerState state) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.hasActiveTrip) ...[
            Container(
              padding: EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.success),
                  SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Text(
                      'You have an active trip',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacingL),
          ],
          Divider(color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildNearbyTripsSection(HomePassengerState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearby Trips',
            style: AppTheme.headingMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppTheme.spacingM),
          if (state.isSearching)
            const Center(child: CircularProgressIndicator())
          else if (state.nearbyTrips.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingXl),
                child: Text(
                  'No trips found',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.nearbyTrips.length,
              itemBuilder: (context, index) {
                return TripCard(
                  tripData: state.nearbyTrips[index],
                  role: 'PASSENGER',
                  onTap: () {
                    _showBookingDialog(state.nearbyTrips[index]);
                  },
                );
              },
            ),
          SizedBox(height: AppTheme.spacingXl),
        ],
      ),
    );
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => SearchBottomSheet(
            role: 'PASSENGER',
            onSearch: (searchData) {
              context.read<HomePassengerCubit>().searchTrips(searchData);
            },
          ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> tripData) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Book Trip'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route: ${tripData['origin']} → ${tripData['destination']}',
                ),
                Text('Time: ${tripData['departureTime']}'),
                Text('Price: ${tripData['price']}k VND'),
                Text('Available: ${tripData['availableSeats']} seats'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<HomePassengerCubit>().bookTrip(tripData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trip booked successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.passengerPrimary,
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}
