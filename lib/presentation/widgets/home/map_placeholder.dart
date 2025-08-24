import 'package:flutter/material.dart';

class MapPlaceholder extends StatelessWidget {
  final String? pickupAddress;
  final String? dropoffAddress;
  final VoidCallback? onMapTap;

  const MapPlaceholder({
    super.key,
    this.pickupAddress,
    this.dropoffAddress,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onMapTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Grid pattern to simulate map
            CustomPaint(
              size: Size.infinite,
              painter: GridPainter(),
            ),
            
            // Mock markers
            if (pickupAddress != null)
              const Positioned(
                top: 200,
                left: 100,
                child: MapMarker(
                  icon: Icons.location_on,
                  color: Colors.green,
                  label: 'Điểm đón',
                ),
              ),
            
            if (dropoffAddress != null)
              const Positioned(
                top: 300,
                right: 80,
                child: MapMarker(
                  icon: Icons.flag,
                  color: Colors.red,
                  label: 'Điểm đến',
                ),
              ),
            
            // Mock route line
            if (pickupAddress != null && dropoffAddress != null)
              CustomPaint(
                size: Size.infinite,
                painter: RoutePainter(),
              ),
            
            // Center location button
            Positioned(
              bottom: 120,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đang lấy vị trí hiện tại...')),
                  );
                },
                child: const Icon(Icons.my_location),
              ),
            ),
            
            // Map type button
            Positioned(
              bottom: 180,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chuyển loại bản đồ')),
                  );
                },
                child: const Icon(Icons.layers),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const MapMarker({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 4),
        Icon(
          icon,
          color: color,
          size: 32,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    const spacing = 50.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(100, 200); // Start at pickup
    path.quadraticBezierTo(
      size.width / 2, 150, // Control point
      size.width - 80, 300, // End at dropoff
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
