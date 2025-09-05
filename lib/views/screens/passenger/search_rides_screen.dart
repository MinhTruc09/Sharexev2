import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/search/search_rides_cubit.dart';
// SearchRidesState is imported via part directive in cubit
import 'package:sharexev2/logic/location/location_cubit.dart';
import 'package:sharexev2/logic/favorites/favorites_cubit.dart';
// import 'package:sharexev2/logic/favorites/favorites_state.dart'; // Part file
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/views/widgets/sharexe_widgets.dart';
import 'package:sharexev2/views/widgets/ride/ride_card_widget.dart';
import 'package:sharexev2/views/widgets/common/seat_counter_widget.dart';
import 'package:sharexev2/views/widgets/common/sharexe_date_picker.dart';
import 'package:sharexev2/services/location_service.dart';
import 'package:latlong2/latlong.dart';

/// Trang tìm kiếm chuyến đi
class SearchRidesScreen extends StatefulWidget {
  const SearchRidesScreen({super.key});

  @override
  State<SearchRidesScreen> createState() => _SearchRidesScreenState();
}

class _SearchRidesScreenState extends State<SearchRidesScreen>
    with SingleTickerProviderStateMixin {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _scrollController = ScrollController();
  
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  int _passengerCount = 1;
  LatLng? _fromCoordinates;
  LatLng? _toCoordinates;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Implement load more when available
      final state = context.read<SearchRidesCubit>().state;
      if (state.status == SearchRidesStatus.loaded && 
          state.rides.isNotEmpty) {
        context.read<SearchRidesCubit>().loadMoreRides();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SearchRidesCubit(
            rideRepository: ServiceLocator.get(),
          ),
        ),
        BlocProvider(
          create: (_) => LocationCubit(
            locationRepository: ServiceLocator.get(),
          ),
        ),
        BlocProvider(
          create: (_) => FavoritesCubit(
            locationRepository: ServiceLocator.get(),
          )..loadFavorites(),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchForm(),
            _buildFavoritesSection(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSearchResults(),
                  _buildMapView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.passengerPrimary,
      foregroundColor: Colors.white,
      title: const Text('Tìm kiếm chuyến đi'),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),
      ],
    );
  }

  Widget _buildFavoritesSection() {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        if (state.favorites.isEmpty) return const SizedBox.shrink();
        
        return Container(
          height: 120,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: AppColors.passengerPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Địa điểm yêu thích',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/favorites');
                    },
                    child: Text(
                      'Xem tất cả',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.passengerPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.favorites.take(5).length,
                  itemBuilder: (context, index) {
                    final favorite = state.favorites[index];
                    return _buildFavoriteChip(favorite);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoriteChip(favorite) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          _fromController.text = favorite.name;
          // Set coordinates for search
          _fromCoordinates = LatLng(favorite.latitude, favorite.longitude);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTypeIcon(favorite.type),
                size: 16,
                color: _getTypeColor(favorite.type),
              ),
              const SizedBox(width: 4),
              Text(
                favorite.name,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'home':
        return AppColors.success;
      case 'work':
        return AppColors.info;
      default:
        return AppColors.passengerPrimary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }

  Widget _buildSearchForm() {
    return Container(
      color: AppColors.passengerPrimary,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // From - To
            Row(
              children: [
                Expanded(
                  child: _buildLocationField(
                    controller: _fromController,
                    hint: 'Điểm đi',
                    icon: Icons.my_location,
                    onTap: () => _selectLocation(true),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    onPressed: _swapLocations,
                    icon: Icon(
                      Icons.swap_horiz,
                      color: AppColors.passengerPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildLocationField(
                    controller: _toController,
                    hint: 'Điểm đến',
                    icon: Icons.location_on,
                    onTap: () => _selectLocation(false),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Date and passenger count
            Row(
              children: [
                Expanded(
                  child: ShareXeCompactDatePicker(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    label: 'Ngày đi',
                  ),
                ),
                const SizedBox(width: 12),
                ShareXeCompactCounter(
                  count: _passengerCount,
                  minCount: 1,
                  maxCount: 8,
                  onCountChanged: (count) {
                    setState(() {
                      _passengerCount = count;
                    });
                  },
                  primaryColor: AppColors.passengerPrimary,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Search button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.passengerPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.search),
                label: const Text(
                  'Tìm chuyến đi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
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
            Icon(icon, color: AppColors.passengerPrimary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.text.isEmpty ? hint : controller.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: controller.text.isEmpty 
                      ? AppColors.textSecondary 
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.passengerPrimary,
        labelColor: AppColors.passengerPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(
            icon: Icon(Icons.list),
            text: 'Danh sách',
          ),
          Tab(
            icon: Icon(Icons.map),
            text: 'Bản đồ',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<SearchRidesCubit, SearchRidesState>(
      builder: (context, state) {
        if (state.status == SearchRidesStatus.loading && state.rides.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.passengerPrimary),
                const SizedBox(height: 16),
                Text(
                  'Đang tìm kiếm chuyến đi...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (state.rides.isEmpty && state.status != SearchRidesStatus.loading) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            _performSearch();
          },
          color: AppColors.passengerPrimary,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.rides.length,
            itemBuilder: (context, index) {
              if (index >= state.rides.length) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.passengerPrimary,
                    ),
                  ),
                );
              }

              final ride = state.rides[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: RideCardWidget(
                  ride: ride,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/ride-details',
                      arguments: {
                        'ride': ride,
                        'userRole': 'PASSENGER',
                      },
                    );
                  },
                  showBookButton: true,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMapView() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.passengerPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.map_outlined,
                size: 60,
                color: AppColors.passengerPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bản đồ chuyến đi',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tính năng bản đồ đang được phát triển',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _tabController.animateTo(0);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.passengerPrimary,
                side: BorderSide(color: AppColors.passengerPrimary),
              ),
              icon: const Icon(Icons.list),
              label: const Text('Xem danh sách'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.search_off,
                size: 50,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Không tìm thấy chuyến đi',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi điều kiện tìm kiếm hoặc chọn ngày khác',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _showFilterDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.passengerPrimary,
                  ),
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Bộ lọc'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.passengerPrimary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tìm lại'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectLocation(bool isFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLocationSelector(isFrom),
    );
  }

  Widget _buildLocationSelector(bool isFrom) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                Text(
                  isFrom ? 'Chọn điểm đi' : 'Chọn điểm đến',
                  style: AppTextStyles.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm địa điểm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // Implement location search
                if (value.isNotEmpty) {
                  _searchLocations(value);
                }
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildLocationItem(
                  icon: Icons.my_location,
                  title: 'Vị trí hiện tại',
                  subtitle: 'Sử dụng GPS',
                  onTap: () async {
                    Navigator.pop(context);
                    // Get current location
                    await _getCurrentLocation();
                  },
                ),
                _buildLocationItem(
                  icon: Icons.home,
                  title: 'Nhà',
                  subtitle: 'Thêm địa chỉ nhà',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildLocationItem(
                  icon: Icons.work,
                  title: 'Công ty',
                  subtitle: 'Thêm địa chỉ công ty',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                // Recent locations would go here
                ListTile(
                  leading: Icon(Icons.history, color: AppColors.textSecondary),
                  title: const Text('Địa điểm gần đây'),
                  subtitle: const Text('Chưa có địa điểm nào'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.passengerPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.passengerPrimary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  void _swapLocations() {
    final temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
  }

  void _performSearch() {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng chọn điểm đi và điểm đến'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<SearchRidesCubit>().searchRides(
      departure: _fromController.text,
      destination: _toController.text,
      startTime: _selectedDate,
      seats: _passengerCount,
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Bộ lọc tìm kiếm',
                    style: AppTextStyles.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khoảng giá',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Price range slider would go here
                    
                    const SizedBox(height: 24),
                    Text(
                      'Thời gian khởi hành',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Time range picker would go here
                    
                    const SizedBox(height: 24),
                    Text(
                      'Đánh giá tài xế',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Rating filter would go here
                    
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Reset filters
                            },
                            child: const Text('Đặt lại'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _performSearch();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.passengerPrimary,
                            ),
                            child: const Text('Áp dụng'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Search locations based on query
  void _searchLocations(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      debugPrint('Searching locations for: $query');
      
      // Use LocationService for geocoding search
      final locationService = LocationService();
      final results = await locationService.searchPlaces(query);
      
      if (results.isNotEmpty) {
        setState(() {
          _searchResults = results;
        });
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {
      debugPrint('Error searching locations: $e');
      setState(() {
        _searchResults = [];
      });
    }
  }

  /// Get current location using GPS
  Future<void> _getCurrentLocation() async {
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      if (position != null) {
        _fromCoordinates = LatLng(position.latitude, position.longitude);
        final address = await locationService.getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        _fromController.text = address ?? 'Vị trí hiện tại';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể lấy vị trí hiện tại: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
