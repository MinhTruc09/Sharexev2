import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Unified Button Widget - Combines CustomButton and PrimaryButton
/// Supports role-based styling and multiple button types
class UnifiedButton extends StatefulWidget {
  final String text;
  final String role;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final ButtonType type;
  final ButtonSize size;

  const UnifiedButton({
    super.key,
    required this.text,
    required this.role,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
  });

  @override
  State<UnifiedButton> createState() => _UnifiedButtonState();
}

class _UnifiedButtonState extends State<UnifiedButton> {
  bool _isPressed = false;

  void _handleHighlightChanged(bool isHighlighted) {
    setState(() => _isPressed = isHighlighted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPassenger = widget.role.toUpperCase() == 'PASSENGER';
    final accentColor = isPassenger ? AppColors.passengerPrimary : AppColors.driverPrimary;
    final isButtonEnabled = widget.isEnabled && !widget.isLoading && widget.onPressed != null;

    // Get button dimensions based on size
    final buttonHeight = widget.height ?? _getButtonHeight();
    final buttonPadding = widget.padding ?? _getButtonPadding();

    // Get button colors based on type
    final buttonColors = _getButtonColors(accentColor, isButtonEnabled);

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: buttonHeight,
      child: Material(
        color: buttonColors.backgroundColor,
        elevation: widget.type == ButtonType.primary ? 5 : 0,
        borderRadius: BorderRadius.circular(widget.borderRadius?.topLeft.x ?? 12),
        child: InkWell(
          onTap: isButtonEnabled ? widget.onPressed : null,
          borderRadius: BorderRadius.circular(widget.borderRadius?.topLeft.x ?? 12),
          onHighlightChanged: _handleHighlightChanged,
          child: Container(
            height: buttonHeight,
            alignment: Alignment.center,
            padding: buttonPadding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius?.topLeft.x ?? 12),
              border: widget.type == ButtonType.outline 
                  ? Border.all(color: accentColor, width: 1)
                  : null,
            ),
            child: AnimatedScale(
              scale: _isPressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: _buildButtonContent(theme, buttonColors.foregroundColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(ThemeData theme, Color foregroundColor) {
    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Đang xử lý...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            size: 20,
            color: foregroundColor,
          ),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: theme.textTheme.titleMedium?.copyWith(
        color: foregroundColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsetsGeometry _getButtonPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  _ButtonColors _getButtonColors(Color accentColor, bool isEnabled) {
    switch (widget.type) {
      case ButtonType.primary:
        return _ButtonColors(
          backgroundColor: isEnabled ? accentColor : AppColors.textTertiary,
          foregroundColor: Colors.white,
        );
      case ButtonType.secondary:
        return _ButtonColors(
          backgroundColor: isEnabled ? accentColor.withOpacity(0.1) : AppColors.textTertiary.withOpacity(0.1),
          foregroundColor: isEnabled ? accentColor : AppColors.textTertiary,
        );
      case ButtonType.outline:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: isEnabled ? accentColor : AppColors.textTertiary,
        );
      case ButtonType.ghost:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: isEnabled ? accentColor : AppColors.textTertiary,
        );
    }
  }
}

class _ButtonColors {
  final Color backgroundColor;
  final Color foregroundColor;

  _ButtonColors({
    required this.backgroundColor,
    required this.foregroundColor,
  });
}

enum ButtonType {
  primary,
  secondary,
  outline,
  ghost,
}

enum ButtonSize {
  small,
  medium,
  large,
}
