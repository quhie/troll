import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sound_model.dart';

/// Service responsible for managing favorite sounds
class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;

  // SharedPreferences key
  static const String _favoritesKey = 'favorite_sounds';

  // List of favorite sounds
  List<SoundModel> _favorites = [];

  // Get all favorites
  List<SoundModel> get favorites => _favorites;

  // Private constructor
  FavoriteService._internal() {
    _loadFavorites();
  }

  /// Initialize by loading favorites
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      _favorites = favoritesJson.map((json) => SoundModel.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      // Error loading favorites
      _favorites = [];
    }
  }

  /// Get all favorites
  List<SoundModel> getFavorites() {
    return _favorites;
  }

  /// Check if a sound is favorited
  bool isFavorite(String soundId) {
    return _favorites.any((sound) => sound.id == soundId);
  }

  /// Toggle favorite status for a sound
  Future<void> toggleFavorite(SoundModel sound) async {
    final isFavorite = this.isFavorite(sound.id);

    if (isFavorite) {
      // Remove from favorites
      _favorites.removeWhere((s) => s.id == sound.id);
    } else {
      // Add to favorites if not already there
      if (!_favorites.any((s) => s.id == sound.id)) {
        _favorites.add(sound.copyWith(isFavorite: true));
      }
    }

    // Save to storage
    await _saveFavorites();
  }

  /// Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson =
          _favorites.map((sound) => jsonEncode(sound.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      // Handle error saving favorites
    }
  }

  /// Update favorite with latest data
  Future<void> updateFavorite(SoundModel sound) async {
    final index = _favorites.indexWhere((s) => s.id == sound.id);
    if (index != -1) {
      _favorites[index] = sound.copyWith(isFavorite: true);
      await _saveFavorites();
    }
  }

  /// Add a sound to favorites
  Future<void> addFavorite(SoundModel sound) async {
    if (!_favorites.any((s) => s.id == sound.id)) {
      _favorites.add(sound.copyWith(isFavorite: true));
      await _saveFavorites();
    }
  }
}
