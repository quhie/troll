import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import '../models/sound_model.dart';
import '../models/sound_category.dart';
import '../repositories/sound_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import '../utils/string_utils.dart';
import 'package:html/dom.dart' as dom;

/// Service for interacting with the MyInstants API
class MyInstantsService implements SoundRepository {
  static final MyInstantsService _instance = MyInstantsService._internal();
  factory MyInstantsService() => _instance;

  // Base URL for API requests
  static const String _baseUrl = 'https://myinstants-api.vercel.app';

  // HTTP client
  final Dio _dio = Dio();

  // Category to search query mapping - updated with new categories
  final Map<String, String> _categoryToQuery = {
    'Anime & Manga': 'anime manga',
    'Games': 'game',
    'Memes': 'meme',
    'Movies': 'movie',
    'Music': 'music',
    'Politics': 'politics',
    'Pranks': 'prank joke',
    'Reactions': 'reaction',
    'Sound Effects': 'effect sfx',
    'Sports': 'sport',
    'Television': 'tv television',
    'TikTok Trends': 'tiktok viral',
    'Viral': 'viral popular',
    'Whatsapp Audios': 'whatsapp',
  };

  // Retry configuration
  static const int maxRetries = 2;

  MyInstantsService._internal() {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  @override
  Future<List<SoundModel>> getTrending({String region = 'en'}) async {
    return _fetchSounds('/trending', {'q': region});
  }

  @override
  Future<List<SoundModel>> getBest() async {
    return _fetchSounds('/best', {'q': 'all'});
  }

  @override
  Future<List<SoundModel>> getRecent() async {
    // 'recent' endpoint doesn't need the 'q' parameter, it works differently
    return _fetchSounds('/recent', {});
  }

  @override
  Future<List<SoundModel>> search(String query) async {
    if (query.isEmpty) {
      return [];
    }
    return _fetchSounds('/search', {'q': query});
  }

  @override
  Future<SoundModel?> getSoundDetail(String id) async {
    try {
      final response = await _dioGet('/detail', {'id': id});

      if (response.statusCode == 200) {
        final data = response.data;
        return _mapApiSoundToModel(data);
      }
    } catch (e) {
      // Error getting sound detail
      
      // Fallback sound data
      return SoundModel(
        id: id ?? 'unknown_fallback',
        name: 'Unknown Sound',
        soundPath: '',
        iconName: Icons.music_note.codePoint.toString(),
        category: CategoryType.meme,
      );
    }

    return null;
  }

  /// Get fallback sounds in case API fails
  List<SoundModel> getFallbackSounds() {
    // Tạo danh sách sounds giả
    final fallbackSounds = [
      SoundModel(
        id: 'fb1',
        name: 'Anime Wow',
        soundPath:
            'https://www.myinstants.com/media/sounds/anime-wow-sound-effect.mp3',
        iconName: Icons.music_note.codePoint.toString(),
        category: CategoryType.meme,
        isFavorite: false,
      ),
      SoundModel(
        id: 'fb2',
        name: 'MLG Air Horn',
        soundPath: 'https://www.myinstants.com/media/sounds/mlg-air-horn.mp3',
        iconName: Icons.music_note.codePoint.toString(),
        category: CategoryType.meme,
        isFavorite: false,
      ),
      SoundModel(
        id: 'fb3',
        name: 'Metal Gear Alert',
        soundPath:
            'https://www.myinstants.com/media/sounds/metalgearsolid.swf.mp3',
        iconName: Icons.music_note.codePoint.toString(),
        category: CategoryType.game,
        isFavorite: false,
      ),
      SoundModel(
        id: 'fb4',
        name: 'Minecraft Villager',
        soundPath: 'https://www.myinstants.com/media/sounds/villager.mp3',
        iconName: Icons.music_note.codePoint.toString(),
        category: CategoryType.game,
        isFavorite: false,
      ),
      SoundModel(
        id: 'fb5',
        name: 'Windows XP Error',
        soundPath: 'https://www.myinstants.com/media/sounds/error.mp3',
        iconName: Icons.music_note.codePoint.toString(),
        category: CategoryType.meme,
        isFavorite: false,
      ),
    ];

    return fallbackSounds;
  }

  /// Fetch sounds from a specific endpoint with parameters
  Future<List<SoundModel>> _fetchSounds(
    String endpoint,
    Map<String, dynamic> params,
  ) async {
    try {
      final url = '$_baseUrl$endpoint';
      // Check if the endpoint requires the 'q' parameter
      if (endpoint == '/trending' && !params.containsKey('q')) {
        params['q'] = 'en'; // Add default region parameter
      }
      if (endpoint == '/best' && !params.containsKey('q')) {
        params['q'] = 'all'; // Add default parameter for best sounds
      }

      final response = await _dio.get(url, queryParameters: params);

      if (response.statusCode == 200) {
        try {
          // Check if response contains data field - new API structure
          if (response.data is Map && response.data['data'] is List) {
            final data = response.data['data'] as List;
            
            List<SoundModel> sounds = [];
            for (final item in data) {
              try {
                if (item is Map<String, dynamic>) {
                  final sound = _mapApiSoundToModel(item);
                  sounds.add(sound);
                }
              } catch (e) {
                // Error mapping sound
              }
            }
            
            // If we got no sounds, return fallback
            if (sounds.isEmpty) {
              return getFallbackSounds();
            }
            
            // Return the mapped sounds
            return sounds;
          } 
          // Legacy API format support
          else if (response.data is List) {
            // Directly got a list of sounds
            final data = response.data as List;
            
            List<SoundModel> sounds = [];
            for (final item in data) {
              try {
                if (item is Map<String, dynamic>) {
                  final sound = _mapApiSoundToModel(item);
                  sounds.add(sound);
                }
              } catch (e) {
                // Error mapping sound
              }
            }
            
            // Return the mapped sounds
            return sounds;
          } else if (response.data is Map && response.data['results'] is List) {
            // Got a response with a "results" field containing the list
            final data = response.data['results'] as List;
            
            List<SoundModel> sounds = [];
            for (final item in data) {
              try {
                if (item is Map<String, dynamic>) {
                  final sound = _mapApiSoundToModel(item);
                  sounds.add(sound);
                }
              } catch (e) {
                // Error mapping sound
              }
            }
            
            // Return the mapped sounds
            return sounds;
          } else {
            // Unexpected response structure
            return getFallbackSounds();
          }
        } catch (e) {
          // Error parsing response
          return getFallbackSounds();
        }
      } else {
        // Error status code
        return getFallbackSounds();
      }
    } catch (e) {
      // Error fetching sounds
      return getFallbackSounds();
    }
  }

  /// Make a GET request with retry logic
  Future<Response> _dioGet(String endpoint, Map<String, dynamic> params) async {
    int retries = 0;

    while (true) {
      try {
        final url = '$_baseUrl$endpoint';
        // URL request with parameters

        final response = await _dio.get(url, queryParameters: params);
        return response;
      } catch (e) {
        retries++;
        if (retries > maxRetries) {
          rethrow;
        }

        // Exponential backoff
        final waitTime = Duration(milliseconds: 500 * (1 << retries));
        // Retrying request after waiting
        await Future.delayed(waitTime);
      }
    }
  }

  /// Map API response to SoundModel
  SoundModel _mapApiSoundToModel(Map<dynamic, dynamic> data) {
    // Đảm bảo rằng chúng ta trích xuất ID đúng cách
    final id = data['id'] != null ? data['id'].toString() : const Uuid().v4();
    
    // Sử dụng title hoặc mặc định
    final title = data['title'] != null ? data['title'].toString() : 'Unknown Sound';
    
    // Đảm bảo URL mp3 hoàn chỉnh
    String mp3Url = '';
    if (data['mp3'] != null) {
      mp3Url = data['mp3'].toString();
    } else if (data['sound'] != null) {
      // Support old API format
      mp3Url = data['sound'].toString();
    }

    // Make sure URL is not empty
    if (mp3Url.isEmpty) {
      mp3Url = 'https://example.com/no_sound.mp3';
    }
    
    // Make sure URL is absolute
    if (!mp3Url.startsWith('http')) {
      mp3Url = 'https://www.myinstants.com' + mp3Url;
    }

    // Extract tags
    List<String> tags = [];
    if (data['tags'] != null) {
      if (data['tags'] is List) {
        tags = (data['tags'] as List).map((e) => e.toString().toLowerCase()).toList();
      } else if (data['tags'] is String) {
        tags = [data['tags'].toString().toLowerCase()];
      }
    }

    // Define category from tags or title
    CategoryType category = CategoryType.meme; // Default

    // Keywords for category matching
    final Map<CategoryType, List<String>> categoryKeywords = {
      CategoryType.game: ['game', 'gaming', 'videogame', 'play'],
      CategoryType.horror: ['horror', 'scary', 'jumpscare', 'scream'],
      CategoryType.phone: ['phone', 'ringtone', 'call', 'dial'],
      CategoryType.social: ['social', 'notification', 'message', 'alert'],
      CategoryType.alarm: ['alarm', 'clock', 'timer', 'wake'],
    };

    // Check tags and title to determine category
    final String searchText = (tags.join(' ') + ' ' + title.toLowerCase());

    // Find most appropriate category
    for (var entry in categoryKeywords.entries) {
      for (var keyword in entry.value) {
        if (searchText.contains(keyword)) {
          category = entry.key;
          break;
        }
      }
    }

    return SoundModel(
      id: id,
      name: title,
      soundPath: mp3Url,
      iconName: _getIconForCategory(category),
      category: category,
      isFavorite: false,
    );
  }

  /// Get the appropriate icon code for a category
  String _getIconForCategory(CategoryType category) {
    switch (category) {
      case CategoryType.phone:
        return Icons.smartphone.codePoint.toString();
      case CategoryType.game:
        return Icons.videogame_asset.codePoint.toString();
      case CategoryType.horror:
        return Icons.nightlight.codePoint.toString();
      case CategoryType.meme:
        return Icons.sentiment_very_satisfied.codePoint.toString();
      case CategoryType.social:
        return Icons.notifications_active.codePoint.toString();
      case CategoryType.alarm:
        return Icons.notifications_active.codePoint.toString();
      case CategoryType.favorite:
        return Icons.favorite.codePoint.toString();
    }
  }

  @override
  String getCategorySearchQuery(String category) {
    // Tìm trực tiếp từ map theo tên danh mục
    return _categoryToQuery[category] ?? category;
  }

  /// Fetch all sounds (defaults to recent sounds)
  Future<List<SoundModel>> fetchAllSounds(int page) async {
    return getRecent();
  }

  /// Fetch sounds by category using search
  Future<List<SoundModel>> fetchSoundsByCategory(String category) async {
    final query = getCategorySearchQuery(category);
    return search(query);
  }

  /// Legacy search method for compatibility
  Future<List<SoundModel>> searchSounds(String query) async {
    return search(query);
  }

  /// Check API connection to verify if the API is working
  Future<bool> checkApiConnection() async {
    try {
      final response = await _dio.get('$_baseUrl/search', queryParameters: {'q': 'test'});
      return response.statusCode == 200 && 
             response.data is Map && 
             response.data['status'] == '200';
    } catch (e) {
      // Error connecting to API
      return false;
    }
  }
  
  /// Use this error handler to log API errors in production
  void logApiError(String method, String error) {
    // In a production app, this would log to a server or analytics service
    // For now, we just return the error without logging to debugPrint
  }
}
