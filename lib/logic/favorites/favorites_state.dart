part of 'favorites_cubit.dart';

enum FavoritesStatus { initial, loading, loaded, error }

class FavoritesState {
  final FavoritesStatus status;
  final List<FavoriteLocation> favorites;
  final String? error;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.error,
  });

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<FavoriteLocation>? favorites,
    String? error,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      error: error ?? this.error,
    );
  }
}

class FavoriteLocation {
  final String id;
  final String name;
  final String address;
  final String type; // 'home', 'work', 'other'
  final double latitude;
  final double longitude;
  final bool isDefault;
  final DateTime createdAt;

  const FavoriteLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    required this.createdAt,
  });

  FavoriteLocation copyWith({
    String? id,
    String? name,
    String? address,
    String? type,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return FavoriteLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FavoriteLocation.fromJson(Map<String, dynamic> json) {
    return FavoriteLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      type: json['type'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
