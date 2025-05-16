import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper class for persistent storage operations
class StorageHelper {
  // Keys for different types of data
  static const String favoritesKey = 'favorite_sounds';
  static const String recentlyPlayedKey = 'recently_played_sounds';
  static const String appSettingsKey = 'app_settings';

  /// Save a list of objects to shared preferences
  static Future<bool> saveList<T>(
    String key,
    List<T> items, {
    required Map<String, dynamic> Function(T item) toJson,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => jsonEncode(toJson(item))).toList();
      return await prefs.setStringList(key, jsonList);
    } catch (e) {
      // Error saving list to storage
      return false;
    }
  }

  /// Load a list of objects from shared preferences
  static Future<List<T>> loadList<T>(
    String key, {
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(key) ?? [];

      return jsonList
          .map((jsonString) => fromJson(jsonDecode(jsonString)))
          .toList();
    } catch (e) {
      // Error loading list from storage
      return [];
    }
  }

  /// Save a list of IDs (simple strings)
  static Future<bool> saveIdList(String key, List<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(key, ids);
    } catch (e) {
      // Error saving ID list to storage
      return false;
    }
  }

  /// Load a list of IDs (simple strings)
  static Future<List<String>> loadIdList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key) ?? [];
    } catch (e) {
      // Error loading ID list from storage
      return [];
    }
  }

  /// Save a complex object as JSON
  static Future<bool> saveObject<T>(
    String key,
    T object, {
    required Map<String, dynamic> Function(T object) toJson,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(toJson(object));
      return await prefs.setString(key, jsonString);
    } catch (e) {
      // Error saving object to storage
      return false;
    }
  }

  /// Load a complex object from JSON
  static Future<T?> loadObject<T>(
    String key, {
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);

      if (jsonString == null) return null;

      return fromJson(jsonDecode(jsonString));
    } catch (e) {
      // Error loading object from storage
      return null;
    }
  }

  /// Save a simple value (bool, int, double, string)
  static Future<bool> saveValue<T>(String key, T value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is String) {
        return await prefs.setString(key, value);
      } else if (value is bool) {
        return await prefs.setBool(key, value);
      } else if (value is int) {
        return await prefs.setInt(key, value);
      } else if (value is double) {
        return await prefs.setDouble(key, value);
      } else {
        throw ArgumentError('Unsupported type: ${value.runtimeType}');
      }
    } catch (e) {
      // Error saving value to storage
      return false;
    }
  }

  /// Load a simple value with a default
  static Future<T> loadValue<T>(String key, T defaultValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (defaultValue is String) {
        return (prefs.getString(key) ?? defaultValue) as T;
      } else if (defaultValue is bool) {
        return (prefs.getBool(key) ?? defaultValue) as T;
      } else if (defaultValue is int) {
        return (prefs.getInt(key) ?? defaultValue) as T;
      } else if (defaultValue is double) {
        return (prefs.getDouble(key) ?? defaultValue) as T;
      } else {
        throw ArgumentError('Unsupported type: ${defaultValue.runtimeType}');
      }
    } catch (e) {
      // Error loading value from storage
      return defaultValue;
    }
  }

  /// Clear all data for a specific key
  static Future<bool> clearData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      // Error clearing data
      return false;
    }
  }

  /// Clear all stored data
  static Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      // Error clearing all data
      return false;
    }
  }
}
