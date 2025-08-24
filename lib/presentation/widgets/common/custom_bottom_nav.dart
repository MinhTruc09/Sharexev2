import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

class BottomNavCurvePainter extends CustomPainter {
  final Color backgroundColor;
  final double insetRadius;
  
  BottomNavCurvePainter({
    this.backgroundColor = Colors.black, 
    this.insetRadius = 38
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 12);

    double insetCurveBeginnningX = size.width / 2 - insetRadius;
    double insetCurveEndX = size.width / 2 + insetRadius;
    double transitionToInsetCurveWidth = size.width * .05;
    
    path.quadraticBezierTo(size.width * 0.20, 0,
        insetCurveBeginnningX - transitionToInsetCurveWidth, 0);
    path.quadraticBezierTo(
        insetCurveBeginnningX, 0, insetCurveBeginnningX, insetRadius / 2);

    path.arcToPoint(Offset(insetCurveEndX, insetRadius / 2),
        radius: const Radius.circular(10.0), clockwise: false);

    path.quadraticBezierTo(
        insetCurveEndX, 0, insetCurveEndX + transitionToInsetCurveWidth, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 12);
    path.lineTo(size.width, size.height + 56);
    path.lineTo(0, size.height + 56);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CustomBottomNavBar extends StatefulWidget {
  final String role;
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.role,
    this.currentIndex = 0,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = 56;

    final primaryColor = AppTheme.getPrimaryColor(widget.role);
    final backgroundColor = AppTheme.surface;

    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size.width, height + 7),
            painter: BottomNavCurvePainter(backgroundColor: backgroundColor),
          ),
          Center(
            heightFactor: 0.6,
            child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0)
              ),
              backgroundColor: primaryColor,
              elevation: 0.1,
              onPressed: () {
                // Quick action - show search or booking
                _showQuickAction(context);
              },
              child: Icon(
                widget.role == 'PASSENGER' 
                    ? CupertinoIcons.car_detailed 
                    : CupertinoIcons.location,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavBarIcon(
                  text: "Trang chủ",
                  icon: CupertinoIcons.home,
                  selected: widget.currentIndex == 0,
                  onPressed: () => widget.onTap(0),
                  defaultColor: AppTheme.textSecondary,
                  selectedColor: primaryColor,
                ),
                NavBarIcon(
                  text: widget.role == 'PASSENGER' ? "Tìm kiếm" : "Chuyến đi",
                  icon: widget.role == 'PASSENGER' 
                      ? CupertinoIcons.search 
                      : CupertinoIcons.car,
                  selected: widget.currentIndex == 1,
                  onPressed: () => widget.onTap(1),
                  defaultColor: AppTheme.textSecondary,
                  selectedColor: primaryColor,
                ),
                const SizedBox(width: 56),
                NavBarIcon(
                  text: "Lịch sử",
                  icon: CupertinoIcons.time,
                  selected: widget.currentIndex == 2,
                  onPressed: () => widget.onTap(2),
                  defaultColor: AppTheme.textSecondary,
                  selectedColor: primaryColor,
                ),
                NavBarIcon(
                  text: "Cá nhân",
                  icon: CupertinoIcons.person,
                  selected: widget.currentIndex == 3,
                  onPressed: () => widget.onTap(3),
                  selectedColor: primaryColor,
                  defaultColor: AppTheme.textSecondary,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickAction(BuildContext context) {
    if (widget.role == 'PASSENGER') {
      // Show quick search
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tìm kiếm nhanh chuyến đi'),
          action: SnackBarAction(
            label: 'Tìm',
            onPressed: () {
              // Navigate to search
            },
          ),
        ),
      );
    } else {
      // Show quick trip creation for driver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tạo chuyến đi mới'),
          action: SnackBarAction(
            label: 'Tạo',
            onPressed: () {
              // Navigate to create trip
            },
          ),
        ),
      );
    }
  }
}

class NavBarIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final Function() onPressed;
  final Color defaultColor;
  final Color selectedColor;

  const NavBarIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.selected,
    required this.onPressed,
    this.selectedColor = const Color(0xffFF8527),
    this.defaultColor = Colors.black54
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingS,
          vertical: AppTheme.spacingXs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacingXs),
              decoration: BoxDecoration(
                color: selected ? selectedColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(
                icon,
                size: 24,
                color: selected ? selectedColor : defaultColor,
              ),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: AppTheme.bodySmall.copyWith(
                color: selected ? selectedColor : defaultColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
