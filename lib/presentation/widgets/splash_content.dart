import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

class SplashContent extends StatefulWidget {
  final String? thumbNail;
  final String imagePathLogo;
  final String imagePathRight;
  final String imagePathBot;
  final String imagePathLeft;
  final String? role;

  const SplashContent({
    super.key,
    required this.thumbNail,
    required this.imagePathLeft,
    required this.imagePathRight,
    required this.imagePathBot,
    required this.imagePathLogo,
    this.role,
  });

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _cloudsController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _leftCloudSlide;
  late Animation<Offset> _rightCloudSlide;
  late Animation<Offset> _bottomCloudSlide;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Clouds animations
    _cloudsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _leftCloudSlide = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cloudsController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _rightCloudSlide = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cloudsController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _bottomCloudSlide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cloudsController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutQuart),
    );

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _startAnimations() async {
    // Check if controllers are still mounted before using them
    if (!mounted) return;

    // Start clouds animation first
    if (!_cloudsController.isCompleted && !_cloudsController.isAnimating) {
      _cloudsController.forward();
    }

    // Start logo animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted &&
        !_logoController.isCompleted &&
        !_logoController.isAnimating) {
      _logoController.forward();
    }

    // Start text animation after logo
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted &&
        !_textController.isCompleted &&
        !_textController.isAnimating) {
      _textController.forward();
    }

    // Start loading animation
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted && !_loadingController.isAnimating) {
      _loadingController.repeat();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _cloudsController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Get role-based gradient
    final gradient =
        widget.role != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeManager.getPrimaryColorForRole(widget.role!),
                  ThemeManager.getPrimaryColorForRole(widget.role!).withValues(alpha: 0.8),
                ],
              )
            : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C63FF), Color(0xFF3F51B5)],
            );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SizedBox.expand(
            child: Stack(
              children: [
                // Left cloud with animation
                AnimatedBuilder(
                  animation: _leftCloudSlide,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _leftCloudSlide,
                      child: Positioned(
                        top: 0,
                        left: 0,
                        child: _buildAssetImage(
                          widget.imagePathLeft,
                          width: screenWidth * 0.5,
                          fallback: 'assets/images/widgets/cloud_left.png',
                        ),
                      ),
                    );
                  },
                ),

                // Right cloud with animation
                AnimatedBuilder(
                  animation: _rightCloudSlide,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _rightCloudSlide,
                      child: Positioned(
                        top: 0,
                        right: 0,
                        child: _buildAssetImage(
                          widget.imagePathRight,
                          width: screenWidth * 0.5,
                          fallback: 'assets/images/widgets/cloud_right.png',
                        ),
                      ),
                    );
                  },
                ),

                // Bottom cloud with animation
                AnimatedBuilder(
                  animation: _bottomCloudSlide,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _bottomCloudSlide,
                      child: Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildAssetImage(
                          widget.imagePathBot,
                          width: screenWidth,
                          fit: BoxFit.cover,
                          fallback: 'assets/images/widgets/cloud_bottom.png',
                        ),
                      ),
                    );
                  },
                ),

                // Center content with animations
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated logo
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: _buildAssetImage(
                                widget.imagePathLogo,
                                width: screenWidth * 0.4,
                                fallback: 'assets/images/logos/smokelogo.png',
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Animated text
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _textSlide,
                            child: Opacity(
                              opacity: _textOpacity.value,
                              child: Text(
                                widget.thumbNail ?? 'Chào mừng đến với ShareXe',
                                            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ).copyWith(
              fontWeight: FontWeight.bold,
            ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Loading indicator
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, child) {
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 3,
                              value: _loadingController.value,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetImage(
    String assetPath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    String? fallback,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to default image if asset not found
        if (fallback != null) {
          return Image.asset(
            fallback,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(width, height);
            },
          );
        }
        return _buildPlaceholder(width, height);
      },
    );
  }

  Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height ?? 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image,
        color: Colors.white.withOpacity(0.5),
        size: (width ?? 100) * 0.3,
      ),
    );
  }
}
