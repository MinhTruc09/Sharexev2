import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharexev2/data/repositories/location/location_repository_interface.dart';
import 'package:sharexev2/core/auth/auth_manager.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final LocationRepositoryInterface _locationRepository;

  FavoritesCubit({required LocationRepositoryInterface locationRepository})
    : _locationRepository = locationRepository,
      super(const FavoritesState());

  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavoritesStatus.loading));

    try {
      final user = AuthManager().currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            status: FavoritesStatus.error,
            error: 'User not authenticated',
          ),
        );
        return;
      }

      // Load favorites from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final favoritesKey = 'favorites_${user.email.value}';
      final favoritesJson = prefs.getStringList(favoritesKey) ?? [];

      final favorites =
          favoritesJson
              .map(
                (jsonString) =>
                    FavoriteLocation.fromJson(jsonDecode(jsonString)),
              )
              .toList();

      emit(
        state.copyWith(status: FavoritesStatus.loaded, favorites: favorites),
      );
    } catch (e) {
      emit(state.copyWith(status: FavoritesStatus.error, error: e.toString()));
    }
  }

  Future<void> addFavorite({
    required String name,
    required String address,
    required String type,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) async {
    emit(state.copyWith(status: FavoritesStatus.loading));

    try {
      final user = AuthManager().currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            status: FavoritesStatus.error,
            error: 'User not authenticated',
          ),
        );
        return;
      }

      final favorite = FavoriteLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        address: address,
        type: type,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        createdAt: DateTime.now(),
      );

      final updatedFavorites = [...state.favorites, favorite];

      // Save to SharedPreferences
      await _saveFavoritesToPrefs(user.email.value, updatedFavorites);

      emit(
        state.copyWith(
          status: FavoritesStatus.loaded,
          favorites: updatedFavorites,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: FavoritesStatus.error, error: e.toString()));
    }
  }

  Future<void> updateFavorite(FavoriteLocation favorite) async {
    emit(state.copyWith(status: FavoritesStatus.loading));

    try {
      final user = AuthManager().currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            status: FavoritesStatus.error,
            error: 'User not authenticated',
          ),
        );
        return;
      }

      final updatedFavorites =
          state.favorites
              .map((f) => f.id == favorite.id ? favorite : f)
              .toList();

      // Save to SharedPreferences
      await _saveFavoritesToPrefs(user.email.value, updatedFavorites);

      emit(
        state.copyWith(
          status: FavoritesStatus.loaded,
          favorites: updatedFavorites,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: FavoritesStatus.error, error: e.toString()));
    }
  }

  Future<void> deleteFavorite(String favoriteId) async {
    emit(state.copyWith(status: FavoritesStatus.loading));

    try {
      final user = AuthManager().currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            status: FavoritesStatus.error,
            error: 'User not authenticated',
          ),
        );
        return;
      }

      final updatedFavorites =
          state.favorites.where((f) => f.id != favoriteId).toList();

      // Save to SharedPreferences
      await _saveFavoritesToPrefs(user.email.value, updatedFavorites);

      emit(
        state.copyWith(
          status: FavoritesStatus.loaded,
          favorites: updatedFavorites,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: FavoritesStatus.error, error: e.toString()));
    }
  }

  Future<void> setAsDefault(String favoriteId) async {
    emit(state.copyWith(status: FavoritesStatus.loading));

    try {
      final user = AuthManager().currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            status: FavoritesStatus.error,
            error: 'User not authenticated',
          ),
        );
        return;
      }

      final updatedFavorites =
          state.favorites.map((f) {
            if (f.type ==
                state.favorites
                    .firstWhere((fav) => fav.id == favoriteId)
                    .type) {
              return f.copyWith(isDefault: f.id == favoriteId);
            }
            return f;
          }).toList();

      // Save to SharedPreferences
      await _saveFavoritesToPrefs(user.email.value, updatedFavorites);

      emit(
        state.copyWith(
          status: FavoritesStatus.loaded,
          favorites: updatedFavorites,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: FavoritesStatus.error, error: e.toString()));
    }
  }

  Future<List<LocationData>> searchLocations(String query) async {
    try {
      final response = await _locationRepository.searchPlaces(query);
      if (response.success) {
        return response.data ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Save favorites to SharedPreferences using user email as key
  Future<void> _saveFavoritesToPrefs(
    String userEmail,
    List<FavoriteLocation> favorites,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesKey = 'favorites_$userEmail';
    final favoritesJson =
        favorites.map((favorite) => jsonEncode(favorite.toJson())).toList();

    await prefs.setStringList(favoritesKey, favoritesJson);
  }
}
