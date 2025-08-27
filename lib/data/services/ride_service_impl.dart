import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/ride.dart';
import 'package:sharexev2/data/services/ride_service.dart';

class RideServiceImpl implements RideService {
  final ApiClient _api = ApiClient();

  @override
  Future<ApiResponse<List<Ride>>> getAvailableRides() async {
    final res = await _api.client.get('/ride/available');
    return ApiResponse.listFromJson<Ride>(res.data as Map<String, dynamic>, (e) {
      return _mapRideFromApi(e as Map<String, dynamic>);
    });
  }

  @override
  Future<ApiResponse<List<Ride>>> searchRides({
    String? departure,
    String? destination,
    DateTime? startTime,
    int? seats,
  }) async {
    final queryParams = <String, dynamic>{};
    if (departure != null) queryParams['departure'] = departure;
    if (destination != null) queryParams['destination'] = destination;
    if (startTime != null) queryParams['startTime'] = startTime.toIso8601String();
    if (seats != null) queryParams['seats'] = seats;

    final res = await _api.client.get('/ride/search', queryParameters: queryParams);
    return ApiResponse.listFromJson<Ride>(res.data as Map<String, dynamic>, (e) {
      return _mapRideFromApi(e as Map<String, dynamic>);
    });
  }

  @override
  Future<ApiResponse<Ride>> getRideById(String rideId) async {
    final res = await _api.client.get('/ride/$rideId');
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) {
      return _mapRideFromApi(data);
    });
  }

  @override
  Future<ApiResponse<Ride>> createRide(Map<String, dynamic> rideData) async {
    final res = await _api.client.post('/ride', data: rideData);
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) {
      return _mapRideFromApi(data);
    });
  }

  @override
  Future<ApiResponse<Ride>> updateRide(String rideId, Map<String, dynamic> rideData) async {
    final res = await _api.client.put('/ride/update/$rideId', data: rideData);
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) {
      return _mapRideFromApi(data);
    });
  }

  @override
  Future<ApiResponse<dynamic>> cancelRide(String rideId) async {
    final res = await _api.client.put('/ride/cancel/$rideId');
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) => data);
  }

  @override
  Future<ApiResponse<List<Ride>>> getDriverRides() async {
    final res = await _api.client.get('/driver/my-rides');
    return ApiResponse.listFromJson<Ride>(res.data as Map<String, dynamic>, (e) {
      return _mapRideFromApi(e as Map<String, dynamic>);
    });
  }

  /// Map dữ liệu từ API response sang Ride model
  Ride _mapRideFromApi(Map<String, dynamic> map) {
    return Ride(
      id: map['id']?.toString() ?? '',
      pickupAddress: map['startAddress'] ?? '',
      dropoffAddress: map['endAddress'] ?? '',
      pickupLat: (map['startLat'] ?? 0).toDouble(),
      pickupLng: (map['startLng'] ?? 0).toDouble(),
      dropoffLat: (map['endLat'] ?? 0).toDouble(),
      dropoffLng: (map['endLng'] ?? 0).toDouble(),
      price: (map['pricePerSeat'] ?? 0).toDouble(),
      duration: 0, // API không cung cấp duration, cần tính toán
      distance: 0, // API không cung cấp distance, cần tính toán
      status: _mapRideStatus(map['status']),
      driverId: map['driverId']?.toString(),
      driverName: map['driverName'] ?? '',
      driverPhone: '', // API không cung cấp
      vehicleInfo: '${map['brand'] ?? ''} ${map['model'] ?? ''} - ${map['licensePlate'] ?? ''}',
      createdAt: DateTime.tryParse(map['startTime'] ?? '') ?? DateTime.now(),
    );
  }

  /// Map trạng thái ride từ API
  RideStatus _mapRideStatus(String? status) {
    switch (status) {
      case 'ACTIVE':
        return RideStatus.searching;
      case 'IN_PROGRESS':
        return RideStatus.inProgress;
      case 'DRIVER_CONFIRMED':
        return RideStatus.driverFound;
      case 'DRIVER_ARRIVING':
        return RideStatus.driverArriving;
      case 'COMPLETED':
        return RideStatus.completed;
      case 'CANCELLED':
        return RideStatus.cancelled;
      default:
        return RideStatus.searching;
    }
  }
}
