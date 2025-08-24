import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';
import 'dart:typed_data';
import 'dart:io';

class ProfileAvatarPicker extends StatefulWidget {
  final String? initialImageUrl;
  final String initials;
  final String role;
  final Function(Uint8List? imageBytes)? onImageSelected;
  final double size;

  const ProfileAvatarPicker({
    super.key,
    this.initialImageUrl,
    required this.initials,
    required this.role,
    this.onImageSelected,
    this.size = 120,
  });

  @override
  State<ProfileAvatarPicker> createState() => _ProfileAvatarPickerState();
}

class _ProfileAvatarPickerState extends State<ProfileAvatarPicker>
    with SingleTickerProviderStateMixin {
  Uint8List? _pickedImageBytes;
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main avatar container
                Container(
                  height: widget.size,
                  width: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _pickedImageBytes == null && widget.initialImageUrl == null
                        ? AppTheme.getGradient(widget.role)
                        : null,
                    color: _pickedImageBytes != null || widget.initialImageUrl != null
                        ? Colors.transparent
                        : null,
                    boxShadow: AppTheme.shadowMedium,
                  ),
                  child: ClipOval(
                    child: _buildAvatarContent(),
                  ),
                ),

                // Hover overlay
                AnimatedOpacity(
                  opacity: _isHovered ? _opacityAnimation.value : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    height: widget.size,
                    width: widget.size,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Camera icon
                GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: AnimatedOpacity(
                    opacity: _isHovered ? _opacityAnimation.value : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: AppTheme.getPrimaryColor(widget.role),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: widget.size * 0.2,
                      ),
                    ),
                  ),
                ),

                // Status indicator (online/offline)
                if (_pickedImageBytes != null || widget.initialImageUrl != null)
                  Positioned(
                    bottom: widget.size * 0.05,
                    right: widget.size * 0.05,
                    child: Container(
                      width: widget.size * 0.2,
                      height: widget.size * 0.2,
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (_pickedImageBytes != null) {
      return Image.memory(
        _pickedImageBytes!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    } else if (widget.initialImageUrl != null) {
      return Image.network(
        widget.initialImageUrl!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialsAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.getPrimaryColor(widget.role),
              ),
            ),
          );
        },
      );
    } else {
      return _buildInitialsAvatar();
    }
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      child: Text(
        widget.initials.toUpperCase(),
        style: AppTheme.headingLarge.copyWith(
          color: Colors.white,
          fontSize: widget.size * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusL),
            topRight: Radius.circular(AppTheme.radiusL),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: AppTheme.spacingM),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                children: [
                  Text(
                    'Chọn ảnh đại diện',
                    style: AppTheme.headingMedium,
                  ),
                  
                  SizedBox(height: AppTheme.spacingL),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPickerOption(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImageFromCamera();
                        },
                      ),
                      _buildPickerOption(
                        icon: Icons.photo_library,
                        label: 'Thư viện',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImageFromGallery();
                        },
                      ),
                      if (_pickedImageBytes != null || widget.initialImageUrl != null)
                        _buildPickerOption(
                          icon: Icons.delete,
                          label: 'Xóa',
                          onTap: () {
                            Navigator.pop(context);
                            _removeImage();
                          },
                        ),
                    ],
                  ),
                  
                  SizedBox(height: AppTheme.spacingL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(widget.role).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.getPrimaryColor(widget.role),
              size: 28,
            ),
          ),
          SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _pickImageFromCamera() async {
    // TODO: Implement camera picker
    // For now, show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng camera sẽ được thêm sau')),
    );
  }

  void _pickImageFromGallery() async {
    // TODO: Implement gallery picker
    // For now, show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng chọn từ thư viện sẽ được thêm sau')),
    );
  }

  void _removeImage() {
    setState(() {
      _pickedImageBytes = null;
    });
    widget.onImageSelected?.call(null);
  }
}

// Status Avatar Widget for displaying user status
class StatusAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final Color statusColor;
  final double size;
  final bool showStatus;

  const StatusAvatar({
    super.key,
    this.imageUrl,
    required this.initials,
    this.statusColor = Colors.green,
    this.size = 50,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: size,
          backgroundColor: AppTheme.passengerPrimary,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Text(
                  initials.toUpperCase(),
                  style: AppTheme.labelLarge.copyWith(
                    color: Colors.white,
                    fontSize: size * 0.4,
                  ),
                )
              : null,
        ),
        if (showStatus)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
