import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final double? width; // Thêm width tùy chọn
  final EdgeInsetsGeometry? padding; // Thêm padding tùy chọn

  const CustomButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity, // Sử dụng width nếu có, nếu không thì full width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 22), // Sử dụng padding nếu có
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}