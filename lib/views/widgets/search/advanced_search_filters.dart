import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../data/models/ride/dtos/ride_search_filters.dart';

/// Advanced search filters widget
class AdvancedSearchFilters extends StatefulWidget {
  final RideSearchFilters initialFilters;
  final Function(RideSearchFilters) onFiltersChanged;
  final bool isExpanded;

  const AdvancedSearchFilters({
    Key? key,
    required this.initialFilters,
    required this.onFiltersChanged,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<AdvancedSearchFilters> createState() => _AdvancedSearchFiltersState();
}

class _AdvancedSearchFiltersState extends State<AdvancedSearchFilters>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late RideSearchFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters.copyWith();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(AdvancedSearchFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _updateFilters() {
    widget.onFiltersChanged(_filters);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return SizeTransition(
                  sizeFactor: _animation,
                  child: child,
                );
              },
              child: _buildFiltersContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.tune,
          color: AppColors.passengerPrimary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Bộ lọc nâng cao',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: _resetFilters,
          child: Text(
            'Đặt lại',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        // Price range
        _buildPriceRangeFilter(),
        
        const SizedBox(height: 20),
        
        // Time filters
        _buildTimeFilters(),
        
        const SizedBox(height: 20),
        
        // Seats filter
        _buildSeatsFilter(),
        
        const SizedBox(height: 20),
        
        // Vehicle type filter
        _buildVehicleTypeFilter(),
        
        const SizedBox(height: 20),
        
        // Driver preferences
        _buildDriverPreferences(),
        
        const SizedBox(height: 20),
        
        // Distance filter
        _buildDistanceFilter(),
        
        const SizedBox(height: 20),
        
        // Sort options
        _buildSortOptions(),
        
        const SizedBox(height: 16),
        
        // Apply button
        _buildApplyButton(),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khoảng giá (VNĐ)',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Từ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _filters = _filters.copyWith(
                    minPrice: double.tryParse(value),
                  );
                  _updateFilters();
                },
              ),
            ),
            const SizedBox(width: 12),
            Text('đến', style: AppTextStyles.bodySmall),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Đến',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _filters = _filters.copyWith(
                    maxPrice: double.tryParse(value),
                  );
                  _updateFilters();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thời gian khởi hành',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildTimeChip('Sáng sớm (5-9h)', TimeRange.earlyMorning),
            _buildTimeChip('Buổi sáng (9-12h)', TimeRange.morning),
            _buildTimeChip('Buổi chiều (12-17h)', TimeRange.afternoon),
            _buildTimeChip('Buổi tối (17-21h)', TimeRange.evening),
            _buildTimeChip('Đêm muộn (21-5h)', TimeRange.night),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeChip(String label, TimeRange timeRange) {
    final isSelected = _filters.timeRanges?.contains(timeRange) ?? false;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _filters = _filters.copyWith(
              timeRanges: [...(_filters.timeRanges ?? []), timeRange],
            );
          } else {
            _filters = _filters.copyWith(
              timeRanges: (_filters.timeRanges ?? [])
                  .where((range) => range != timeRange)
                  .toList(),
            );
          }
        });
        _updateFilters();
      },
      selectedColor: AppColors.passengerPrimary.withOpacity(0.2),
      checkmarkColor: AppColors.passengerPrimary,
    );
  }

  Widget _buildSeatsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Số chỗ cần đặt',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: _filters.seats > 1 ? () {
                setState(() {
                  _filters = _filters.copyWith(seats: _filters.seats - 1);
                });
                _updateFilters();
              } : null,
              icon: const Icon(Icons.remove),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_filters.seats}',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: _filters.seats < 4 ? () {
                setState(() {
                  _filters = _filters.copyWith(seats: _filters.seats + 1);
                });
                _updateFilters();
              } : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại xe',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildVehicleChip('4 chỗ', VehicleType.car4),
            _buildVehicleChip('7 chỗ', VehicleType.car7),
            _buildVehicleChip('16 chỗ', VehicleType.van16),
            _buildVehicleChip('Xe máy', VehicleType.motorbike),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleChip(String label, VehicleType vehicleType) {
    final isSelected = _filters.vehicleTypes?.contains(vehicleType) ?? false;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _filters = _filters.copyWith(
              vehicleTypes: [...(_filters.vehicleTypes ?? []), vehicleType],
            );
          } else {
            _filters = _filters.copyWith(
              vehicleTypes: (_filters.vehicleTypes ?? [])
                  .where((type) => type != vehicleType)
                  .toList(),
            );
          }
        });
        _updateFilters();
      },
      selectedColor: AppColors.passengerPrimary.withOpacity(0.2),
      checkmarkColor: AppColors.passengerPrimary,
    );
  }

  Widget _buildDriverPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tùy chọn tài xế',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Tài xế có đánh giá cao (4.5+ sao)'),
          value: _filters.highRatedDriverOnly ?? false,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(highRatedDriverOnly: value);
            });
            _updateFilters();
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Tài xế đã xác thực'),
          value: _filters.verifiedDriverOnly ?? false,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(verifiedDriverOnly: value);
            });
            _updateFilters();
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('Cho phép hút thuốc'),
          value: _filters.allowSmoking ?? false,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(allowSmoking: value);
            });
            _updateFilters();
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bán kính tìm kiếm',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(_filters.maxDistance ?? 50).toInt()} km',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.passengerPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _filters.maxDistance ?? 50,
          min: 5,
          max: 200,
          divisions: 39,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(maxDistance: value);
            });
            _updateFilters();
          },
          activeColor: AppColors.passengerPrimary,
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sắp xếp theo',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<SortOption>(
          value: _filters.sortBy ?? SortOption.departure,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(
              value: SortOption.departure,
              child: Text('Thời gian khởi hành'),
            ),
            DropdownMenuItem(
              value: SortOption.price,
              child: Text('Giá thấp nhất'),
            ),
            DropdownMenuItem(
              value: SortOption.distance,
              child: Text('Khoảng cách gần nhất'),
            ),
            DropdownMenuItem(
              value: SortOption.rating,
              child: Text('Đánh giá cao nhất'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(sortBy: value);
            });
            _updateFilters();
          },
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _updateFilters();
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.passengerPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Áp dụng bộ lọc'),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _filters = RideSearchFilters();
    });
    _updateFilters();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
