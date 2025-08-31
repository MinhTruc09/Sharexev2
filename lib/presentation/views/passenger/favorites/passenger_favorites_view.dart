import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sharexev2/config/theme.dart';

/// Passenger Favorites View - Manages saved locations with SharedPreferences
class PassengerFavoritesView extends StatefulWidget {
  const PassengerFavoritesView({super.key});

  @override
  State<PassengerFavoritesView> createState() => _PassengerFavoritesViewState();
}

class _PassengerFavoritesViewState extends State<PassengerFavoritesView> {
  List<Map<String, dynamic>> _favoriteLocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteLocations();
  }

  Future<void> _loadFavoriteLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationsJson = prefs.getString('passenger_favorite_locations') ?? '[]';
      final locations = List<Map<String, dynamic>>.from(json.decode(locationsJson));
      
      // If no favorites exist, create some sample data
      if (locations.isEmpty) {
        locations.addAll(_generateSampleLocations());
        await _saveFavoriteLocations(locations);
      }
      
      setState(() {
        _favoriteLocations = locations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _favoriteLocations = _generateSampleLocations();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveFavoriteLocations(List<Map<String, dynamic>> locations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('passenger_favorite_locations', json.encode(locations));
  }

  List<Map<String, dynamic>> _generateSampleLocations() {
    return [
      {
        'id': 1,
        'name': 'Nhà',
        'address': '123 Nguyễn Văn Cừ, Quận 5, TP.HCM',
        'lat': 10.762622,
        'lng': 106.660172,
        'type': 'home',
        'icon': Icons.home,
        'color': AppColors.grabGreen,
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': 2,
        'name': 'Công ty',
        'address': '456 Lê Lợi, Quận 1, TP.HCM',
        'lat': 10.772622,
        'lng': 106.670172,
        'type': 'work',
        'icon': Icons.work,
        'color': AppColors.driverPrimary,
        'createdAt': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
      },
      {
        'id': 3,
        'name': 'Sân bay Tân Sơn Nhất',
        'address': 'Sân bay Tân Sơn Nhất, Tân Bình, TP.HCM',
        'lat': 10.818622,
        'lng': 106.651972,
        'type': 'airport',
        'icon': Icons.flight,
        'color': AppColors.grabOrange,
        'createdAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      },
      {
        'id': 4,
        'name': 'Trường đại học',
        'address': 'Đại học Bách Khoa, Quận 10, TP.HCM',
        'lat': 10.772822,
        'lng': 106.657172,
        'type': 'school',
        'icon': Icons.school,
        'color': AppColors.passengerSecondary,
        'createdAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header with add button
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Địa điểm yêu thích',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddLocationDialog,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Thêm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.passengerPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Favorites list
        Expanded(
          child: _favoriteLocations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadFavoriteLocations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favoriteLocations.length,
                    itemBuilder: (context, index) {
                      final location = _favoriteLocations[index];
                      return _buildLocationCard(location, index);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (location['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            location['icon'] as IconData,
            color: location['color'] as Color,
            size: 24,
          ),
        ),
        title: Text(
          location['name'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              location['address'],
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  '${location['lat']}, ${location['lng']}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'use_as_pickup':
                _useAsPickup(location);
                break;
              case 'use_as_destination':
                _useAsDestination(location);
                break;
              case 'edit':
                _editLocation(location, index);
                break;
              case 'delete':
                _deleteLocation(index);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'use_as_pickup',
              child: Row(
                children: [
                  Icon(Icons.radio_button_checked, color: AppColors.grabGreen),
                  SizedBox(width: 8),
                  Text('Dùng làm điểm đón'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'use_as_destination',
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.grabOrange),
                  SizedBox(width: 8),
                  Text('Dùng làm điểm đến'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
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
                  Text('Xóa'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showLocationDetail(location),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có địa điểm yêu thích',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm những địa điểm bạn thường xuyên đi đến',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddLocationDialog,
            icon: const Icon(Icons.add),
            label: const Text('Thêm địa điểm đầu tiên'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.passengerPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddLocationDialog(
        onAdd: (location) async {
          setState(() {
            _favoriteLocations.add(location);
          });
          await _saveFavoriteLocations(_favoriteLocations);
        },
      ),
    );
  }

  void _useAsPickup(Map<String, dynamic> location) {
    // Navigate back to home and set as pickup location
    Navigator.pop(context);
    // TODO: Set pickup location in home cubit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chọn "${location['name']}" làm điểm đón'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _useAsDestination(Map<String, dynamic> location) {
    // Navigate back to home and set as destination
    Navigator.pop(context);
    // TODO: Set destination in home cubit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chọn "${location['name']}" làm điểm đến'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _editLocation(Map<String, dynamic> location, int index) {
    showDialog(
      context: context,
      builder: (context) => _AddLocationDialog(
        location: location,
        onAdd: (updatedLocation) async {
          setState(() {
            _favoriteLocations[index] = updatedLocation;
          });
          await _saveFavoriteLocations(_favoriteLocations);
        },
      ),
    );
  }

  void _deleteLocation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa địa điểm'),
        content: Text('Bạn có chắc chắn muốn xóa "${_favoriteLocations[index]['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _favoriteLocations.removeAt(index);
              });
              await _saveFavoriteLocations(_favoriteLocations);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLocationDetail(Map<String, dynamic> location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (location['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          location['icon'] as IconData,
                          color: location['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              location['address'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _useAsPickup(location);
                          },
                          icon: const Icon(Icons.radio_button_checked, size: 20),
                          label: const Text('Điểm đón'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.grabGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _useAsDestination(location);
                          },
                          icon: const Icon(Icons.location_on, size: 20),
                          label: const Text('Điểm đến'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.grabOrange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddLocationDialog extends StatefulWidget {
  final Map<String, dynamic>? location;
  final Function(Map<String, dynamic>) onAdd;

  const _AddLocationDialog({this.location, required this.onAdd});

  @override
  State<_AddLocationDialog> createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<_AddLocationDialog> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  String _selectedType = 'other';
  
  final Map<String, Map<String, dynamic>> _locationTypes = {
    'home': {'name': 'Nhà', 'icon': Icons.home, 'color': AppColors.grabGreen},
    'work': {'name': 'Công ty', 'icon': Icons.work, 'color': AppColors.driverPrimary},
    'school': {'name': 'Trường học', 'icon': Icons.school, 'color': AppColors.passengerSecondary},
    'airport': {'name': 'Sân bay', 'icon': Icons.flight, 'color': AppColors.grabOrange},
    'other': {'name': 'Khác', 'icon': Icons.place, 'color': AppColors.info},
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.location?['name'] ?? '');
    _addressController = TextEditingController(text: widget.location?['address'] ?? '');
    _selectedType = widget.location?['type'] ?? 'other';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.location != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Chỉnh sửa địa điểm' : 'Thêm địa điểm mới'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên địa điểm',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Loại địa điểm',
                border: OutlineInputBorder(),
              ),
              items: _locationTypes.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(
                        entry.value['icon'] as IconData,
                        color: entry.value['color'] as Color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(entry.value['name'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _saveLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.passengerPrimary,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }

  void _saveLocation() {
    if (_nameController.text.trim().isEmpty || _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final typeInfo = _locationTypes[_selectedType]!;
    final location = {
      'id': widget.location?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim(),
      'lat': widget.location?['lat'] ?? 10.762622, // Default coordinates
      'lng': widget.location?['lng'] ?? 106.660172,
      'type': _selectedType,
      'icon': typeInfo['icon'],
      'color': typeInfo['color'],
      'createdAt': widget.location?['createdAt'] ?? DateTime.now().toIso8601String(),
    };

    widget.onAdd(location);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
