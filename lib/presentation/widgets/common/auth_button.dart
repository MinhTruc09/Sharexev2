import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

class AuthButton extends StatefulWidget {
  final String text;
  final String role;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;

  const AuthButton({
    super.key,
    required this.text,
    required this.role,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              child: Container(
                width: widget.width ?? double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: widget.isOutlined 
                      ? null 
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ThemeManager.getPrimaryColorForRole(widget.role),
                            ThemeManager.getPrimaryColorForRole(widget.role).withOpacity(0.8),
                          ],
                        ),
                  color: widget.isOutlined ? Colors.transparent : null,
                  border: widget.isOutlined 
                      ? Border.all(
                          color: ThemeManager.getPrimaryColorForRole(widget.role),
                          width: 2,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: widget.isOutlined 
                      ? null 
                      : [
                          BoxShadow(
                            color: ThemeManager.getPrimaryColorForRole(widget.role).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.isLoading ? null : widget.onPressed,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading) ...[
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.isOutlined 
                                      ? ThemeManager.getPrimaryColorForRole(widget.role)
                                      : Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ] else if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.isOutlined 
                                  ? ThemeManager.getPrimaryColorForRole(widget.role)
                                  : Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 16),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ).copyWith(
                              color: widget.isOutlined 
                                  ? ThemeManager.getPrimaryColorForRole(widget.role)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AuthSocialButton extends StatelessWidget {
  final String text;
  final String role;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData icon;

  const AuthSocialButton({
    super.key,
    required this.text,
    required this.role,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeManager.getPrimaryColorForRole(role),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ] else ...[
                  Icon(
                    icon,
                    color: const Color(0xFF212121),
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
