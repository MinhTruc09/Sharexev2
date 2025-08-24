import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final double? width;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;
  final bool loading;
  final bool enabled;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;
  final Widget? leading;
  final IconData? iconData; // Optional legacy convenience
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.width,
    this.height = 55,
    this.borderRadius = 12,
    this.textStyle,
    this.loading = false,
    this.enabled = true,
    this.fullWidth = true,
    this.padding,
    this.leading,
    this.iconData,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  void _handleHighlightChanged(bool isHighlighted) {
    setState(() => _isPressed = isHighlighted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBg = widget.backgroundColor ?? theme.primaryColor;
    final effectiveFg = widget.foregroundColor ?? Colors.black;

    final effectiveTextStyle =
        widget.textStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: effectiveFg,
          fontWeight: FontWeight.w700,
        );

    final bool canTap =
        widget.enabled && !widget.loading && widget.onPressed != null;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
            ),
          )
        else ...[
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: 8),
          ] else if (widget.iconData != null) ...[
            Icon(widget.iconData, color: effectiveFg),
            const SizedBox(width: 8),
          ],
          Text(widget.label, style: effectiveTextStyle),
        ],
      ],
    );

    final Widget button = Material(
      color: effectiveBg.withOpacity(widget.enabled ? 1 : 0.6),
      elevation: 5,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: InkWell(
        onTap: canTap ? widget.onPressed : null,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        onHighlightChanged: _handleHighlightChanged,
        child: Container(
          height: widget.height,
          width:
              widget.fullWidth
                  ? (widget.width ?? double.infinity)
                  : widget.width,
          alignment: Alignment.center,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: content,
        ),
      ),
    );

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: button,
    );
  }
}
