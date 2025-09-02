import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sharexev2/config/theme.dart';

/// Unified Text Field Widget - Combines CustomTextField and AuthInputField
/// Supports role-based styling and multiple field types
class UnifiedTextField extends StatefulWidget {
  final String label;
  final String hint;
  final String role;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final FieldType type;
  final FieldSize size;

  const UnifiedTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.role,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isPassword = false,
    this.isRequired = true,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.type = FieldType.standard,
    this.size = FieldSize.medium,
  });

  @override
  State<UnifiedTextField> createState() => _UnifiedTextFieldState();
}

class _UnifiedTextFieldState extends State<UnifiedTextField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPassenger = widget.role.toUpperCase() == 'PASSENGER';
    final accentColor = isPassenger ? AppColors.passengerPrimary : AppColors.driverPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                widget.label,
                style: _getLabelStyle(theme),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Input Field
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            obscureText: widget.isPassword && _obscureText,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            onTap: widget.onTap,
            decoration: _getInputDecoration(theme, accentColor),
            style: _getTextStyle(theme),
          ),
        ),
      ],
    );
  }

  TextStyle _getLabelStyle(ThemeData theme) {
    switch (widget.size) {
      case FieldSize.small:
        return TextStyle(
          fontSize: 14,
          color: widget.type == FieldType.legacy ? const Color(0xFF00B7FF) : theme.textTheme.titleMedium?.color,
          fontWeight: FontWeight.w600,
        );
      case FieldSize.medium:
        return theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.textTheme.titleMedium?.color,
        ) ?? const TextStyle();
      case FieldSize.large:
        return theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.textTheme.titleLarge?.color,
        ) ?? const TextStyle();
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    switch (widget.type) {
      case FieldType.legacy:
        return TextStyle(
          color: const Color(0xFF003087),
          fontSize: 16,
        );
      case FieldType.standard:
        return theme.textTheme.bodyLarge?.copyWith(
          color: theme.textTheme.bodyLarge?.color,
        ) ?? const TextStyle();
    }
  }

  InputDecoration _getInputDecoration(ThemeData theme, Color accentColor) {
    final baseDecoration = InputDecoration(
      hintText: widget.hint,
      hintStyle: _getHintStyle(theme),
      prefixIcon: widget.prefixIcon,
      suffixIcon: _getSuffixIcon(theme),
      filled: widget.type == FieldType.standard,
      fillColor: _getFillColor(theme, accentColor),
      contentPadding: _getContentPadding(),
    );

    if (widget.type == FieldType.legacy) {
      return baseDecoration.copyWith(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF003087)),
        ),
      );
    } else {
      return baseDecoration.copyWith(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: _isFocused ? accentColor : AppColors.borderLight,
            width: _isFocused ? 2 : 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: accentColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      );
    }
  }

  TextStyle _getHintStyle(ThemeData theme) {
    switch (widget.type) {
      case FieldType.legacy:
        return TextStyle(
          color: const Color(0xFF003087).withOpacity(0.5),
        );
      case FieldType.standard:
        return theme.textTheme.bodyMedium?.copyWith(
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
        ) ?? const TextStyle();
    }
  }

  Widget? _getSuffixIcon(ThemeData theme) {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  Color _getFillColor(ThemeData theme, Color accentColor) {
    if (widget.type == FieldType.legacy) {
      return Colors.transparent;
    }
    return _isFocused 
        ? accentColor.withOpacity(0.05)
        : theme.inputDecorationTheme.fillColor ?? AppColors.surface;
  }

  EdgeInsetsGeometry _getContentPadding() {
    switch (widget.size) {
      case FieldSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case FieldSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md);
      case FieldSize.large:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg);
    }
  }
}

enum FieldType {
  standard,
  legacy,
}

enum FieldSize {
  small,
  medium,
  large,
}
