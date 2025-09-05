import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/favorites/favorites_cubit.dart';
// import 'package:sharexev2/logic/favorites/favorites_state.dart'; // Part file
import 'package:sharexev2/logic/location/location_cubit.dart';
import 'package:sharexev2/config/theme.dart';
// import 'package:sharexev2/views/widgets/sharexe_widgets.dart'; // Unused
import 'package:geolocator/geolocator.dart';
import 'package:sharexev2/services/location_service.dart';

/// Địa điểm yêu thích của hành khách với location tracking
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _searchQuery = '';
  String _selectedType = 'other';
  Position? _currentPosition;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => FavoritesCubit(
            locationRepository: ServiceLocator.get(),
          )..loadFavorites(),
        ),
        BlocProvider(
          create: (_) => LocationCubit(
            locationRepository: ServiceLocator.get(),
          ),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildQuickAddSection(),
            Expanded(
              child: BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, state) {
                  return _buildFavoritesList(state);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddFavoriteDialog(),
          backgroundColor: AppColors.passengerPrimary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.passengerPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Địa điểm yêu thích',
        style: AppTextStyles.headingMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<FavoritesCubit>().loadFavorites();
          },
        ),
        IconButton(
          icon: const Icon(Icons.map),
          onPressed: () => _showMapView(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm địa điểm...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.passengerPrimary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: AppTextStyles.bodyMedium,
      ),
    );
  }

  Widget _buildQuickAddSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAddButton(
              'Thêm nhà',
              Icons.home,
              'home',
              () => _addCurrentLocationAsFavorite('home'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickAddButton(
              'Thêm cơ quan',
              Icons.work,
              'work',
              () => _addCurrentLocationAsFavorite('work'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickAddButton(
              'Vị trí hiện tại',
              Icons.my_location,
              'current',
              () => _addCurrentLocationAsFavorite('other'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(
    String label,
    IconData icon,
    String type,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.passengerPrimary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(FavoritesState state) {
    if (state.status == FavoritesStatus.loading) {
      return _buildLoadingState();
    }

    if (state.status == FavoritesStatus.error) {
      return _buildErrorState(state.error);
    }

    final filteredFavorites = _searchQuery.isEmpty
        ? state.favorites
        : state.favorites.where((favorite) {
            return favorite.name.toLowerCase().contains(_searchQuery) ||
                favorite.address.toLowerCase().contains(_searchQuery) ||
                favorite.type.toLowerCase().contains(_searchQuery);
          }).toList();

    if (filteredFavorites.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FavoritesCubit>().loadFavorites();
      },
      color: AppColors.passengerPrimary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredFavorites.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final favorite = filteredFavorites[index];
          return _buildFavoriteCard(favorite);
        },
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteLocation favorite) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _useFavoriteLocation(favorite),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon based on type
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getTypeColor(favorite.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(favorite.type),
                    color: _getTypeColor(favorite.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Location info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              favorite.name,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (favorite.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.success.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'Mặc định',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        favorite.address,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${favorite.latitude.toStringAsFixed(4)}, ${favorite.longitude.toStringAsFixed(4)}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Action buttons
                PopupMenuButton<String>(
                  onSelected: (value) => _handleFavoriteAction(value, favorite),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'use',
                      child: Row(
                        children: [
                          Icon(Icons.navigation),
                          SizedBox(width: 8),
                          Text('Sử dụng'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'set_default',
                      child: Row(
                        children: [
                          Icon(Icons.star),
                          SizedBox(width: 8),
                          Text('Đặt mặc định'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.passengerPrimary),
          const SizedBox(height: 16),
          Text(
            'Đang tải địa điểm yêu thích...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Không thể tải địa điểm yêu thích',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<FavoritesCubit>().loadFavorites();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.passengerPrimary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
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
            Icon(
              Icons.favorite_border,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có địa điểm yêu thích',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm địa điểm thường xuyên để tiện lợi hơn',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddFavoriteDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.passengerPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Thêm địa điểm'),
            ),
          ],
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

  void _addCurrentLocationAsFavorite(String type) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không thể lấy vị trí hiện tại'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Get address from coordinates
    try {
      final address = await _getAddressFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      final name = type == 'home' ? 'Nhà' : type == 'work' ? 'Cơ quan' : 'Vị trí hiện tại';

      context.read<FavoritesCubit>().addFavorite(
        name: name,
        address: address,
        type: type,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        isDefault: false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm $name vào yêu thích'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không thể lấy địa chỉ từ tọa độ'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final locationService = LocationService();
      final address = await locationService.getAddressFromCoordinates(lat, lng);
      return address ?? 'Vị trí tại $lat, $lng';
    } catch (e) {
      return 'Vị trí tại $lat, $lng';
    }
  }

  void _showAddFavoriteDialog() {
    _nameController.clear();
    _addressController.clear();
    _selectedType = 'other';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thêm địa điểm yêu thích'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên địa điểm',
                  hintText: 'Ví dụ: Nhà, Cơ quan, Trường học...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                  hintText: 'Nhập địa chỉ chi tiết...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Loại địa điểm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'home', child: Text('Nhà')),
                  DropdownMenuItem(value: 'work', child: Text('Cơ quan')),
                  DropdownMenuItem(value: 'other', child: Text('Khác')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value ?? 'other';
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _addFavoriteFromDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.passengerPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFavoriteFromDialog() async {
    if (_nameController.text.trim().isEmpty || _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập đầy đủ thông tin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Get coordinates from address using geocoding
    double lat = _currentPosition?.latitude ?? 21.0285; // Default to Hanoi
    double lng = _currentPosition?.longitude ?? 105.8542;
    
    try {
      final locationService = LocationService();
      final coordinates = await locationService.getCoordinatesFromAddress(_addressController.text.trim());
      if (coordinates != null) {
        lat = coordinates.latitude;
        lng = coordinates.longitude;
      }
    } catch (e) {
      // Use default coordinates if geocoding fails
      print('Geocoding failed: $e');
    }

    context.read<FavoritesCubit>().addFavorite(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      type: _selectedType,
      latitude: lat,
      longitude: lng,
      isDefault: false,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã thêm địa điểm yêu thích'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleFavoriteAction(String action, FavoriteLocation favorite) {
    switch (action) {
      case 'use':
        _useFavoriteLocation(favorite);
        break;
      case 'set_default':
        context.read<FavoritesCubit>().setAsDefault(favorite.id);
        break;
      case 'edit':
        _editFavorite(favorite);
        break;
      case 'delete':
        _deleteFavorite(favorite);
        break;
    }
  }

  void _useFavoriteLocation(FavoriteLocation favorite) {
    // Navigate to search screen with this location as destination
    Navigator.pop(context); // Go back to previous screen
    Navigator.pushNamed(
      context,
      '/passenger/search-rides',
      arguments: {
        'destination': favorite.address,
        'destinationName': favorite.name,
      },
    );
  }

  void _editFavorite(FavoriteLocation favorite) {
    _nameController.text = favorite.name;
    _addressController.text = favorite.address;
    _selectedType = favorite.type;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Chỉnh sửa địa điểm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên địa điểm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedFavorite = favorite.copyWith(
                name: _nameController.text.trim(),
                address: _addressController.text.trim(),
              );
              context.read<FavoritesCubit>().updateFavorite(updatedFavorite);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.passengerPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _deleteFavorite(FavoriteLocation favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa địa điểm yêu thích'),
        content: Text('Bạn có chắc chắn muốn xóa "${favorite.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FavoritesCubit>().deleteFavorite(favorite.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showMapView() {
    final favorites = context.read<FavoritesCubit>().state.favorites;
    if (favorites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Chưa có địa điểm yêu thích nào'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Navigate to a map screen showing all favorites
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Bản đồ địa điểm yêu thích'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.map,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hiển thị ${favorites.length} địa điểm yêu thích',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chức năng bản đồ chi tiết sẽ được phát triển',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
