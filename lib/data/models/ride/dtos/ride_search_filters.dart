import 'package:latlong2/latlong.dart';

/// DTO for ride search filters
class RideSearchFilters {
  final String? departure;
  final String? destination;
  final DateTime? startDate;
  final DateTime? endDate;
  final int seats;
  final double? minPrice;
  final double? maxPrice;
  final List<TimeRange>? timeRanges;
  final List<VehicleType>? vehicleTypes;
  final bool? highRatedDriverOnly;
  final bool? verifiedDriverOnly;
  final bool? allowSmoking;
  final bool? allowPets;
  final double? maxDistance;
  final LatLng? centerLocation;
  final SortOption? sortBy;
  final bool? ascending;

  const RideSearchFilters({
    this.departure,
    this.destination,
    this.startDate,
    this.endDate,
    this.seats = 1,
    this.minPrice,
    this.maxPrice,
    this.timeRanges,
    this.vehicleTypes,
    this.highRatedDriverOnly,
    this.verifiedDriverOnly,
    this.allowSmoking,
    this.allowPets,
    this.maxDistance,
    this.centerLocation,
    this.sortBy,
    this.ascending,
  });

  /// Create a copy with updated fields
  RideSearchFilters copyWith({
    String? departure,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    int? seats,
    double? minPrice,
    double? maxPrice,
    List<TimeRange>? timeRanges,
    List<VehicleType>? vehicleTypes,
    bool? highRatedDriverOnly,
    bool? verifiedDriverOnly,
    bool? allowSmoking,
    bool? allowPets,
    double? maxDistance,
    LatLng? centerLocation,
    SortOption? sortBy,
    bool? ascending,
  }) {
    return RideSearchFilters(
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      seats: seats ?? this.seats,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      timeRanges: timeRanges ?? this.timeRanges,
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      highRatedDriverOnly: highRatedDriverOnly ?? this.highRatedDriverOnly,
      verifiedDriverOnly: verifiedDriverOnly ?? this.verifiedDriverOnly,
      allowSmoking: allowSmoking ?? this.allowSmoking,
      allowPets: allowPets ?? this.allowPets,
      maxDistance: maxDistance ?? this.maxDistance,
      centerLocation: centerLocation ?? this.centerLocation,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (departure != null) json['departure'] = departure;
    if (destination != null) json['destination'] = destination;
    if (startDate != null) json['startDate'] = startDate!.toIso8601String();
    if (endDate != null) json['endDate'] = endDate!.toIso8601String();
    json['seats'] = seats;
    if (minPrice != null) json['minPrice'] = minPrice;
    if (maxPrice != null) json['maxPrice'] = maxPrice;
    
    if (timeRanges != null && timeRanges!.isNotEmpty) {
      json['timeRanges'] = timeRanges!.map((e) => e.name).toList();
    }
    
    if (vehicleTypes != null && vehicleTypes!.isNotEmpty) {
      json['vehicleTypes'] = vehicleTypes!.map((e) => e.name).toList();
    }
    
    if (highRatedDriverOnly != null) json['highRatedDriverOnly'] = highRatedDriverOnly;
    if (verifiedDriverOnly != null) json['verifiedDriverOnly'] = verifiedDriverOnly;
    if (allowSmoking != null) json['allowSmoking'] = allowSmoking;
    if (allowPets != null) json['allowPets'] = allowPets;
    if (maxDistance != null) json['maxDistance'] = maxDistance;
    
    if (centerLocation != null) {
      json['centerLat'] = centerLocation!.latitude;
      json['centerLng'] = centerLocation!.longitude;
    }
    
    if (sortBy != null) json['sortBy'] = sortBy!.name;
    if (ascending != null) json['ascending'] = ascending;
    
    return json;
  }

  /// Create from JSON
  factory RideSearchFilters.fromJson(Map<String, dynamic> json) {
    return RideSearchFilters(
      departure: json['departure'] as String?,
      destination: json['destination'] as String?,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String) 
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String) 
          : null,
      seats: json['seats'] as int? ?? 1,
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      timeRanges: (json['timeRanges'] as List?)
          ?.map((e) => TimeRange.values.firstWhere(
                (range) => range.name == e,
                orElse: () => TimeRange.morning,
              ))
          .toList(),
      vehicleTypes: (json['vehicleTypes'] as List?)
          ?.map((e) => VehicleType.values.firstWhere(
                (type) => type.name == e,
                orElse: () => VehicleType.car4,
              ))
          .toList(),
      highRatedDriverOnly: json['highRatedDriverOnly'] as bool?,
      verifiedDriverOnly: json['verifiedDriverOnly'] as bool?,
      allowSmoking: json['allowSmoking'] as bool?,
      allowPets: json['allowPets'] as bool?,
      maxDistance: (json['maxDistance'] as num?)?.toDouble(),
      centerLocation: json['centerLat'] != null && json['centerLng'] != null
          ? LatLng(
              (json['centerLat'] as num).toDouble(),
              (json['centerLng'] as num).toDouble(),
            )
          : null,
      sortBy: json['sortBy'] != null
          ? SortOption.values.firstWhere(
              (option) => option.name == json['sortBy'],
              orElse: () => SortOption.departure,
            )
          : null,
      ascending: json['ascending'] as bool?,
    );
  }

  /// Check if filters are empty (default state)
  bool get isEmpty {
    return departure == null &&
        destination == null &&
        startDate == null &&
        endDate == null &&
        seats == 1 &&
        minPrice == null &&
        maxPrice == null &&
        (timeRanges == null || timeRanges!.isEmpty) &&
        (vehicleTypes == null || vehicleTypes!.isEmpty) &&
        highRatedDriverOnly != true &&
        verifiedDriverOnly != true &&
        allowSmoking != true &&
        allowPets != true &&
        maxDistance == null &&
        centerLocation == null &&
        sortBy == null;
  }

  /// Get filter summary for display
  String get filterSummary {
    final filters = <String>[];
    
    if (minPrice != null || maxPrice != null) {
      if (minPrice != null && maxPrice != null) {
        filters.add('${minPrice!.toInt()}k - ${maxPrice!.toInt()}k VNĐ');
      } else if (minPrice != null) {
        filters.add('Từ ${minPrice!.toInt()}k VNĐ');
      } else {
        filters.add('Đến ${maxPrice!.toInt()}k VNĐ');
      }
    }
    
    if (seats > 1) {
      filters.add('$seats chỗ');
    }
    
    if (timeRanges != null && timeRanges!.isNotEmpty) {
      filters.add('${timeRanges!.length} khung giờ');
    }
    
    if (vehicleTypes != null && vehicleTypes!.isNotEmpty) {
      filters.add('${vehicleTypes!.length} loại xe');
    }
    
    if (highRatedDriverOnly == true) {
      filters.add('Tài xế 4.5+ sao');
    }
    
    if (verifiedDriverOnly == true) {
      filters.add('Đã xác thực');
    }
    
    if (maxDistance != null) {
      filters.add('${maxDistance!.toInt()}km');
    }
    
    return filters.isEmpty ? 'Không có bộ lọc' : filters.join(' • ');
  }

  @override
  String toString() {
    return 'RideSearchFilters(departure: $departure, destination: $destination, seats: $seats)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RideSearchFilters &&
        other.departure == departure &&
        other.destination == destination &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.seats == seats &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice;
  }

  @override
  int get hashCode {
    return departure.hashCode ^
        destination.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        seats.hashCode ^
        minPrice.hashCode ^
        maxPrice.hashCode;
  }
}

/// Time ranges for filtering
enum TimeRange {
  earlyMorning,
  morning,
  afternoon,
  evening,
  night,
}

/// Vehicle types for filtering
enum VehicleType {
  car4,
  car7,
  van16,
  motorbike,
}

/// Sort options for search results
enum SortOption {
  departure,
  price,
  distance,
  rating,
  duration,
}
