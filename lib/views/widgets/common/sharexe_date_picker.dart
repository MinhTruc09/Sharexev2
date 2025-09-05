import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Date picker timeline cho ShareXe
class ShareXeDatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime date) onDateSelected;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool showHeader;
  final String? headerTitle;

  const ShareXeDatePicker({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
    this.minDate,
    this.maxDate,
    this.showHeader = true,
    this.headerTitle,
  });

  @override
  State<ShareXeDatePicker> createState() => _ShareXeDatePickerState();
}

class _ShareXeDatePickerState extends State<ShareXeDatePicker> {
  late DateTime _currentDate;
  late DateTime _selectedDate;
  late PageController _pageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _pageController = PageController();
    _scrollController = ScrollController();
    
    // Auto scroll to selected date after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    final daysDifference = _selectedDate.difference(_currentDate).inDays;
    final scrollOffset = daysDifference * 70.0; // 70 is item width
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHeader) _buildHeader(),
          _buildDateTimeline(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            widget.headerTitle ?? 'Chọn ngày khởi hành',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _showFullCalendar(),
            icon: Icon(Icons.calendar_month, size: 18, color: AppColors.primary),
            label: Text(
              'Lịch',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeline() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 365, // Show next 365 days
        itemBuilder: (context, index) {
          final date = _currentDate.add(Duration(days: index));
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, DateTime.now());
          final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
          
          return _buildDateItem(
            date: date,
            isSelected: isSelected,
            isToday: isToday,
            isPast: isPast,
          );
        },
      ),
    );
  }

  Widget _buildDateItem({
    required DateTime date,
    required bool isSelected,
    required bool isToday,
    required bool isPast,
  }) {
    final isDisabled = isPast || 
        (widget.minDate != null && date.isBefore(widget.minDate!)) ||
        (widget.maxDate != null && date.isAfter(widget.maxDate!));

    return GestureDetector(
      onTap: isDisabled ? null : () {
        setState(() {
          _selectedDate = date;
        });
        widget.onDateSelected(date);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary
              : isToday 
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isToday && !isSelected 
              ? Border.all(color: AppColors.primary, width: 1)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getDayName(date),
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected 
                    ? Colors.white
                    : isDisabled
                        ? AppColors.textSecondary.withOpacity(0.5)
                        : isToday
                            ? AppColors.primary
                            : AppColors.textSecondary,
                fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isSelected 
                    ? Colors.white
                    : isDisabled
                        ? AppColors.textSecondary.withOpacity(0.5)
                        : isToday
                            ? AppColors.primary
                            : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'T${date.month}',
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected 
                    ? Colors.white.withOpacity(0.8)
                    : isDisabled
                        ? AppColors.textSecondary.withOpacity(0.5)
                        : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(DateTime date) {
    const dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return dayNames[date.weekday % 7];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _showFullCalendar() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.minDate ?? DateTime.now(),
      lastDate: widget.maxDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    ).then((date) {
      if (date != null) {
        setState(() {
          _selectedDate = date;
        });
        widget.onDateSelected(date);
        _scrollToSelectedDate();
      }
    });
  }
}

/// Compact date picker cho space nhỏ
class ShareXeCompactDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime date) onDateSelected;
  final String? label;

  const ShareXeCompactDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(
                      label!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  Text(
                    _formatDate(selectedDate),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    
    const weekdays = [
      'Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư',
      'Thứ năm', 'Thứ sáu', 'Thứ bảy'
    ];
    
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    
    if (_isSameDay(date, today)) {
      return 'Hôm nay, ${date.day} ${months[date.month - 1]}';
    } else if (_isSameDay(date, tomorrow)) {
      return 'Ngày mai, ${date.day} ${months[date.month - 1]}';
    } else {
      return '${weekdays[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    ).then((date) {
      if (date != null) {
        onDateSelected(date);
      }
    });
  }
}
