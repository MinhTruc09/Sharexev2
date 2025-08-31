import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache Manager for performance optimization
/// Handles caching of frequently accessed data
class CacheManager {
  static CacheManager? _instance;
  static CacheManager get I => _instance ??= CacheManager._internal();
  CacheManager._internal();

  SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Initialize cache manager
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Cache duration constants
  static const Duration shortCache = Duration(minutes: 5);
  static const Duration mediumCache = Duration(minutes: 30);
  static const Duration longCache = Duration(hours: 2);

  // ===== Memory Cache (Fast Access) =====

  /// Store data in memory cache
  void setMemory<T>(String key, T data, {Duration? duration}) {
    _memoryCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    
    // Auto-expire after duration
    if (duration != null) {
      Future.delayed(duration, () {
        _memoryCache.remove(key);
        _cacheTimestamps.remove(key);
      });
    }
  }

  /// Get data from memory cache
  T? getMemory<T>(String key, {Duration? maxAge}) {
    if (!_memoryCache.containsKey(key)) return null;
    
    // Check if expired
    if (maxAge != null && _cacheTimestamps[key] != null) {
      final age = DateTime.now().difference(_cacheTimestamps[key]!);
      if (age > maxAge) {
        _memoryCache.remove(key);
        _cacheTimestamps.remove(key);
        return null;
      }
    }
    
    return _memoryCache[key] as T?;
  }

  /// Clear memory cache
  void clearMemory([String? key]) {
    if (key != null) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    } else {
      _memoryCache.clear();
      _cacheTimestamps.clear();
    }
  }

  // ===== Persistent Cache (Disk Storage) =====

  /// Store data in persistent cache
  Future<void> setPersistent<T>(String key, T data) async {
    await initialize();
    try {
      final jsonString = jsonEncode({
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      await _prefs!.setString(key, jsonString);
    } catch (e) {
      // Handle serialization errors gracefully
      print('Cache serialization error for key $key: $e');
    }
  }

  /// Get data from persistent cache
  Future<T?> getPersistent<T>(String key, {Duration? maxAge}) async {
    await initialize();
    try {
      final jsonString = _prefs!.getString(key);
      if (jsonString == null) return null;

      final cached = jsonDecode(jsonString);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(cached['timestamp']);
      
      // Check if expired
      if (maxAge != null) {
        final age = DateTime.now().difference(timestamp);
        if (age > maxAge) {
          await _prefs!.remove(key);
          return null;
        }
      }
      
      return cached['data'] as T?;
    } catch (e) {
      // Handle deserialization errors gracefully
      print('Cache deserialization error for key $key: $e');
      await _prefs!.remove(key);
      return null;
    }
  }

  /// Clear persistent cache
  Future<void> clearPersistent([String? key]) async {
    await initialize();
    if (key != null) {
      await _prefs!.remove(key);
    } else {
      await _prefs!.clear();
    }
  }

  // ===== Smart Cache (Memory + Persistent) =====

  /// Store data in both memory and persistent cache
  Future<void> setSmartCache<T>(String key, T data, {Duration? duration}) async {
    setMemory(key, data, duration: duration);
    await setPersistent(key, data);
  }

  /// Get data from smart cache (memory first, then persistent)
  Future<T?> getSmartCache<T>(String key, {Duration? maxAge}) async {
    // Try memory cache first (fastest)
    final memoryData = getMemory<T>(key, maxAge: maxAge);
    if (memoryData != null) return memoryData;

    // Fallback to persistent cache
    final persistentData = await getPersistent<T>(key, maxAge: maxAge);
    if (persistentData != null) {
      // Store back in memory for faster future access
      setMemory(key, persistentData, duration: maxAge);
    }
    
    return persistentData;
  }

  /// Clear all caches
  Future<void> clearAll() async {
    clearMemory();
    await clearPersistent();
  }

  // ===== Cache Statistics =====

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'memoryKeys': _memoryCache.keys.length,
      'memorySize': _calculateMemorySize(),
      'oldestEntry': _getOldestEntry(),
      'newestEntry': _getNewestEntry(),
    };
  }

  int _calculateMemorySize() {
    try {
      final jsonString = jsonEncode(_memoryCache);
      return jsonString.length;
    } catch (e) {
      return 0;
    }
  }

  DateTime? _getOldestEntry() {
    if (_cacheTimestamps.isEmpty) return null;
    return _cacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime? _getNewestEntry() {
    if (_cacheTimestamps.isEmpty) return null;
    return _cacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b);
  }
}

/// Cache Keys for commonly cached data
class CacheKeys {
  static const String userProfile = 'user_profile';
  static const String driverProfile = 'driver_profile';
  static const String rideHistory = 'ride_history';
  static const String bookingHistory = 'booking_history';
  static const String nearbyRides = 'nearby_rides';
  static const String popularDestinations = 'popular_destinations';
  static const String recentSearches = 'recent_searches';
  static const String appConfig = 'app_config';
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
}

/// Cache Helper Extensions
extension CacheManagerExtensions on CacheManager {
  /// Cache user profile with medium duration
  Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    await setSmartCache(CacheKeys.userProfile, profile, duration: CacheManager.mediumCache);
  }

  /// Get cached user profile
  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    return await getSmartCache<Map<String, dynamic>>(
      CacheKeys.userProfile,
      maxAge: CacheManager.mediumCache,
    );
  }

  /// Cache ride history with long duration
  Future<void> cacheRideHistory(List<Map<String, dynamic>> rides) async {
    await setSmartCache(CacheKeys.rideHistory, rides, duration: CacheManager.longCache);
  }

  /// Get cached ride history
  Future<List<Map<String, dynamic>>?> getCachedRideHistory() async {
    return await getSmartCache<List<Map<String, dynamic>>>(
      CacheKeys.rideHistory,
      maxAge: CacheManager.longCache,
    );
  }

  /// Cache nearby rides with short duration (frequently changing)
  void cacheNearbyRides(List<Map<String, dynamic>> rides) {
    setMemory(CacheKeys.nearbyRides, rides, duration: CacheManager.shortCache);
  }

  /// Get cached nearby rides
  List<Map<String, dynamic>>? getCachedNearbyRides() {
    return getMemory<List<Map<String, dynamic>>>(
      CacheKeys.nearbyRides,
      maxAge: CacheManager.shortCache,
    );
  }
}
