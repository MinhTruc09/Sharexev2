import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/ride.dart';
import 'package:sharexev2/data/repositories/ride_repository.dart';
import 'package:sharexev2/data/services/ride_service.dart';

class RideRepositoryImpl implements RideRepository {
  final RideService _rideService;

  RideRepositoryImpl(this._rideService);

  @override
  Future<ApiResponse<List<Ride>>> getAvailableRides() async {
    return await _rideService.getAvailableRides();
  }

  @override
  Future<ApiResponse<List<Ride>>> searchRides({
    String? departure,
    String? destination,
    DateTime? startTime,
    int? seats,
  }) async {
    return await _rideService.searchRides(
      departure: departure,
      destination: destination,
      startTime: startTime,
      seats: seats,
    );
  }

  @override
  Future<ApiResponse<Ride>> getRideById(String rideId) async {
    return await _rideService.getRideById(rideId);
  }

  @override
  Future<ApiResponse<Ride>> createRide(Map<String, dynamic> rideData) async {
    return await _rideService.createRide(rideData);
  }

  @override
  Future<ApiResponse<Ride>> updateRide(String rideId, Map<String, dynamic> rideData) async {
    return await _rideService.updateRide(rideId, rideData);
  }

  @override
  Future<ApiResponse<dynamic>> cancelRide(String rideId) async {
    return await _rideService.cancelRide(rideId);
  }

  @override
  Future<ApiResponse<List<Ride>>> getDriverRides() async {
    return await _rideService.getDriverRides();
  }
}
