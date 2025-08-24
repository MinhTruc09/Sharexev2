import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

class ImageUploadWidget extends StatefulWidget {
  final String label;
  final String hint;
  final String role;
  final File? image;
  final ValueChanged<File?> onImageSelected;
  final bool isRequired;

  const ImageUploadWidget({
    super.key,
    required this.label,
    required this.hint,
    required this.role,
    this.image,
    required this.onImageSelected,
    this.isRequired = true,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            if (widget.isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                onTap: _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color:
                        widget.image != null
                            ? Colors.grey.shade100
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          widget.image != null
                              ? ThemeManager.getPrimaryColorForRole(widget.role)
                              : Colors.grey.shade300,
                      width: 2,
                      style:
                          widget.image != null
                              ? BorderStyle.solid
                              : BorderStyle.none,
                    ),
                  ),
                  child:
                      widget.image != null
                          ? _buildImagePreview()
                          : _buildUploadPlaceholder(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          widget.hint,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(widget.image!),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => widget.onImageSelected(null),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 32,
          color: ThemeManager.getPrimaryColorForRole(widget.role),
        ),
        const SizedBox(height: 8),
        Text(
          'Nhấn để chọn ảnh',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ).copyWith(
            color: ThemeManager.getPrimaryColorForRole(widget.role),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Chọn ảnh',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageSourceOption(
              context,
              Icons.camera_alt,
              'Chụp ảnh',
              () {
                Navigator.pop(context);
                _pickImage('camera');
              },
            ),
            _buildImageSourceOption(
              context,
              Icons.photo_library,
              'Chọn từ thư viện',
              () {
                Navigator.pop(context);
                _pickImage('gallery');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: ThemeManager.getPrimaryColorForRole(widget.role),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickImage(String source) async {
    // Simplified image picking for now
    // In a real app, you would implement proper image picking
    if (source == 'camera') {
      // Simulate camera capture
      await Future.delayed(const Duration(seconds: 1));
      // For now, just show a message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera functionality not implemented')),
        );
      }
    } else if (source == 'gallery') {
      // Simulate gallery selection
      await Future.delayed(const Duration(seconds: 1));
      // For now, just show a message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gallery functionality not implemented')),
        );
      }
    }
  }
}
