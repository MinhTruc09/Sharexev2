import '../models/ride.dart';

class MockDataService {
  static List<Ride> get sampleRides => [
    Ride(
      id: '1',
      pickupAddress: 'Sân bay Nội Bài, Hà Nội',
      dropoffAddress: 'Hồ Gươm, Hoàn Kiếm, Hà Nội',
      pickupLat: 21.2187,
      pickupLng: 105.8042,
      dropoffLat: 21.0285,
      dropoffLng: 105.8542,
      price: 250000,
      duration: 45,
      distance: 35.5,
      status: RideStatus.completed,
      driverId: 'driver1',
      driverName: 'Nguyễn Văn A',
      driverPhone: '0901234567',
      vehicleInfo: 'Toyota Vios - 30A-12345',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Ride(
      id: '2',
      pickupAddress: 'Trung tâm Lotte, Ba Đình, Hà Nội',
      dropoffAddress: 'Bệnh viện Bạch Mai, Hai Bà Trưng, Hà Nội',
      pickupLat: 21.0333,
      pickupLng: 105.8197,
      dropoffLat: 21.0031,
      dropoffLng: 105.8467,
      price: 85000,
      duration: 25,
      distance: 12.3,
      status: RideStatus.completed,
      driverId: 'driver2',
      driverName: 'Trần Thị B',
      driverPhone: '0912345678',
      vehicleInfo: 'Honda City - 29B-67890',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Ride(
      id: '3',
      pickupAddress: 'Đại học Bách Khoa Hà Nội',
      dropoffAddress: 'Vincom Mega Mall Royal City',
      pickupLat: 21.0069,
      pickupLng: 105.8438,
      dropoffLat: 21.0134,
      dropoffLng: 105.8044,
      price: 65000,
      duration: 20,
      distance: 8.7,
      status: RideStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static List<String> get popularDestinations => [
    'Sân bay Nội Bài',
    'Hồ Gươm',
    'Trung tâm Lotte',
    'Vincom Mega Mall',
    'Bệnh viện Bạch Mai',
    'Đại học Bách Khoa',
    'Chợ Đồng Xuân',
    'Nhà hát Lớn Hà Nội',
    'Văn Miếu - Quốc Tử Giám',
    'Hoàng Thành Thăng Long',
  ];

  static List<String> get recentSearches => [
    'Sân bay Nội Bài',
    'Trung tâm Lotte',
    'Vincom Mega Mall',
    'Bệnh viện Bạch Mai',
  ];

  // Simulate API delay
  static Future<List<Ride>> getRideHistory() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return sampleRides;
  }

  static Future<List<String>> searchPlaces(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (query.isEmpty) return [];
    
    final allPlaces = [
      ...popularDestinations,
      'Đại học Quốc gia Hà Nội',
      'Bưu điện Hà Nội',
      'Nhà ga Hà Nội',
      'Cầu Long Biên',
      'Phố cổ Hà Nội',
      'Tháp Rùa',
      'Đền Ngọc Sơn',
      'Chùa Một Cột',
      'Lăng Chủ tịch Hồ Chí Minh',
    ];
    
    return allPlaces
        .where((place) => place.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  static Future<Ride> createRide({
    required String pickupAddress,
    required String dropoffAddress,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Mock price calculation
    final distance = _calculateDistance(pickupLat, pickupLng, dropoffLat, dropoffLng);
    final price = (distance * 15000).round().toDouble(); // 15k per km
    final duration = (distance * 2.5).round(); // 2.5 minutes per km
    
    return Ride(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      price: price,
      duration: duration,
      distance: distance,
      status: RideStatus.searching,
      createdAt: DateTime.now(),
    );
  }

  // Simple distance calculation (not accurate, just for mock)
  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    final deltaLat = (lat2 - lat1).abs();
    final deltaLng = (lng2 - lng1).abs();
    return (deltaLat + deltaLng) * 111; // Rough km conversion
  }
}
