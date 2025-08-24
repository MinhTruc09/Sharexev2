import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

class AnimatedCounter extends StatefulWidget {
  final double borderRadius;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final String label;
  final Function(int)? onChanged;

  const AnimatedCounter({
    super.key, 
    this.borderRadius = 100,
    this.initialValue = 1,
    this.minValue = 1,
    this.maxValue = 8,
    this.label = 'Số lượng',
    this.onChanged,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  bool isAddHovered = false;
  bool isRemoveHovered = false;
  late int count;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    count = widget.initialValue;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.spacingS),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(
              icon: Icons.remove,
              isHovered: isRemoveHovered,
              onTap: decrement,
              onHover: (hover) {
                setState(() {
                  isRemoveHovered = hover;
                });
              },
            ),
            SizedBox(width: AppTheme.spacingM),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    height: 44,
                    width: 84,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      color: AppTheme.surface,
                      border: Border.all(
                        color: AppTheme.passengerPrimary.withOpacity(0.3),
                      ),
                      boxShadow: AppTheme.shadowLight,
                    ),
                    child: Text(
                      '$count',
                      style: AppTheme.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: AppTheme.spacingM),
            _buildButton(
              icon: Icons.add,
              isHovered: isAddHovered,
              onTap: increment,
              onHover: (hover) {
                setState(() {
                  isAddHovered = hover;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required bool isHovered,
    required VoidCallback onTap,
    required Function(bool) onHover,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 36,
          width: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: AppTheme.passengerPrimary,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: isHovered ? AppTheme.passengerPrimary : Colors.transparent,
            boxShadow: isHovered ? AppTheme.shadowLight : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isHovered ? Colors.white : AppTheme.passengerPrimary,
          ),
        ),
      ),
    );
  }

  void decrement() {
    if (count > widget.minValue) {
      setState(() {
        count--;
      });
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      widget.onChanged?.call(count);
    }
  }

  void increment() {
    if (count < widget.maxValue) {
      setState(() {
        count++;
      });
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      widget.onChanged?.call(count);
    }
  }
}

// Simple counter for inline use
class SimpleCounter extends StatefulWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;
  final Function(int)? onChanged;

  const SimpleCounter({
    super.key,
    this.initialValue = 1,
    this.minValue = 1,
    this.maxValue = 8,
    this.onChanged,
  });

  @override
  State<SimpleCounter> createState() => _SimpleCounterState();
}

class _SimpleCounterState extends State<SimpleCounter> {
  late int count;

  @override
  void initState() {
    super.initState();
    count = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.passengerPrimary),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: count > widget.minValue ? decrement : null,
            icon: Icon(
              Icons.remove,
              color: count > widget.minValue 
                  ? AppTheme.passengerPrimary 
                  : Colors.grey,
            ),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: Text(
              '$count',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: count < widget.maxValue ? increment : null,
            icon: Icon(
              Icons.add,
              color: count < widget.maxValue 
                  ? AppTheme.passengerPrimary 
                  : Colors.grey,
            ),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ],
      ),
    );
  }

  void decrement() {
    setState(() {
      count--;
    });
    widget.onChanged?.call(count);
  }

  void increment() {
    setState(() {
      count++;
    });
    widget.onChanged?.call(count);
  }
}
