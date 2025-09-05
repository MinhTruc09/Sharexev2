import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Widget đếm số lượng ghế cho ShareXe
class ShareXeSeatCounter extends StatefulWidget {
  final int initialCount;
  final int minCount;
  final int maxCount;
  final Function(int count) onCountChanged;
  final String label;
  final bool showLabel;

  const ShareXeSeatCounter({
    super.key,
    this.initialCount = 1,
    this.minCount = 1,
    this.maxCount = 8,
    required this.onCountChanged,
    this.label = 'Số ghế',
    this.showLabel = true,
  });

  @override
  State<ShareXeSeatCounter> createState() => _ShareXeSeatCounterState();
}

class _ShareXeSeatCounterState extends State<ShareXeSeatCounter>
    with SingleTickerProviderStateMixin {
  late int _count;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _increment() {
    if (_count < widget.maxCount) {
      setState(() {
        _count++;
      });
      widget.onCountChanged(_count);
      _animateChange();
    }
  }

  void _decrement() {
    if (_count > widget.minCount) {
      setState(() {
        _count--;
      });
      widget.onCountChanged(_count);
      _animateChange();
    }
  }

  void _animateChange() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decrease button
            GestureDetector(
              onTap: _count > widget.minCount ? _decrement : null,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _count > widget.minCount 
                      ? AppColors.primary 
                      : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _count > widget.minCount ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Icon(
                  Icons.remove,
                  color: _count > widget.minCount 
                      ? Colors.white 
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
            
            // Count display
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 80,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.borderLight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$_count',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Increase button
            GestureDetector(
              onTap: _count < widget.maxCount ? _increment : null,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _count < widget.maxCount 
                      ? AppColors.primary 
                      : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _count < widget.maxCount ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Icon(
                  Icons.add,
                  color: _count < widget.maxCount 
                      ? Colors.white 
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        
        // Helper text
        const SizedBox(height: 4),
        Text(
          'Tối đa ${widget.maxCount} ghế',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Widget đếm hành khách với icon
class ShareXePassengerCounter extends StatelessWidget {
  final int count;
  final int maxCount;
  final Function(int count) onCountChanged;
  final String title;
  final String? subtitle;

  const ShareXePassengerCounter({
    super.key,
    required this.count,
    this.maxCount = 8,
    required this.onCountChanged,
    this.title = 'Số hành khách',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Icon and text
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          
          // Counter controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onTap: count > 1 ? () => onCountChanged(count - 1) : null,
                enabled: count > 1,
              ),
              
              Container(
                width: 50,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              _buildCounterButton(
                icon: Icons.add,
                onTap: count < maxCount ? () => onCountChanged(count + 1) : null,
                enabled: count < maxCount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    VoidCallback? onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.borderLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : AppColors.textSecondary,
          size: 18,
        ),
      ),
    );
  }
}

/// Widget compact counter cho space nhỏ
class ShareXeCompactCounter extends StatelessWidget {
  final int count;
  final int minCount;
  final int maxCount;
  final Function(int count) onCountChanged;
  final Color? primaryColor;

  const ShareXeCompactCounter({
    super.key,
    required this.count,
    this.minCount = 1,
    this.maxCount = 8,
    required this.onCountChanged,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? AppColors.primary;
    
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactButton(
            icon: Icons.remove,
            onTap: count > minCount ? () => onCountChanged(count - 1) : null,
            enabled: count > minCount,
            color: color,
          ),
          
          Container(
            width: 40,
            height: 32,
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          _buildCompactButton(
            icon: Icons.add,
            onTap: count < maxCount ? () => onCountChanged(count + 1) : null,
            enabled: count < maxCount,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({
    required IconData icon,
    VoidCallback? onTap,
    required bool enabled,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? color : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : color.withOpacity(0.5),
          size: 16,
        ),
      ),
    );
  }
}
