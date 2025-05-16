import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as path;
import '../models/sound_model.dart';
import '../models/sound_category.dart';
import '../utils/string_utils.dart';

/// Abstract repository for fetching sounds from external sources
abstract class SoundRepository {
  /// Get trending sounds by region
  Future<List<SoundModel>> getTrending({String region = 'en'});

  /// Get best of all time sounds
  Future<List<SoundModel>> getBest();

  /// Get recently uploaded sounds
  Future<List<SoundModel>> getRecent();

  /// Search sounds by query
  Future<List<SoundModel>> search(String query);

  /// Get sound details by ID
  Future<SoundModel?> getSoundDetail(String id);

  /// Helper method to convert category to search query
  String getCategorySearchQuery(String category);
}

/// Repository that handles all data access for sounds
class SoundRepositoryImpl implements SoundRepository {
  static const String _myInstantsBaseUrl = 'https://www.myinstants.com';

  /// Fetch all sounds from assets
  Future<Map<CategoryType, List<SoundModel>>> fetchLocalSounds() async {
    try {
      // Get the assets sound directories
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Extract sound directory paths
      final soundPaths =
          manifestMap.keys
              .where(
                (key) => key.startsWith('assets/sounds/') && key.contains('.'),
              )
              .toList();

      // Create a map to organize sound files by category
      final Map<String, List<String>> categoryFiles = {};

      // Process each sound file
      for (final soundPath in soundPaths) {
        // Extract the category from the path (assuming format: assets/sounds/category/file.mp3)
        final pathParts = soundPath.split('/');
        if (pathParts.length >= 3) {
          final categoryPath =
              pathParts[2]; // e.g., "340178__quhie__phone-device-sounds" or "phone"

          // Add this file to its category
          categoryFiles.putIfAbsent(categoryPath, () => []).add(soundPath);
        }
      }

      // Map category directories to CategoryType
      final Map<String, CategoryType> categoryMapping = {
        // Original folder structure from requirements
        'phone': CategoryType.phone,
        'game': CategoryType.game,
        'horror': CategoryType.horror,
        'meme': CategoryType.meme,
        'social': CategoryType.social,

        // Actual folder names found in the assets directory
        '340178__quhie__phone-device-sounds': CategoryType.phone,
        '340179__quhie__game-troll-sounds': CategoryType.game,
        '340184__quhie__jumpscare-horror-sounds': CategoryType.horror,
        '340182__quhie__meme-funny-sounds': CategoryType.meme,
        '340180__quhie__social-alarm-sounds': CategoryType.social,
        'alarm': CategoryType.alarm,
        'fart': CategoryType.meme,
        'tensioner': CategoryType.horror,
        'mosquito': CategoryType.horror,
        'electric_gun': CategoryType.meme,
        'hair_clipper': CategoryType.social,
        'electric_sound': CategoryType.meme,
      };

      // Result map for categorized sounds
      final Map<CategoryType, List<SoundModel>> categorizedSounds = {};

      // Process each category and create SoundModel objects
      categoryFiles.forEach((categoryDir, filePaths) {
        // Determine the category type from the mapping
        final categoryType = categoryMapping[categoryDir] ?? CategoryType.meme;

        // If this is the first time seeing this category, initialize its list
        if (!categorizedSounds.containsKey(categoryType)) {
          categorizedSounds[categoryType] = [];
        }

        // Process each sound file in this category
        for (final filePath in filePaths) {
          // Skip .DS_Store and other hidden files
          if (path.basename(filePath).startsWith('.')) continue;

          // Extract filename without extension
          final fileName = path.basenameWithoutExtension(filePath);

          // Create a display name by formatting the filename
          final displayName = StringUtils.formatSoundName(fileName);

          // Create a unique ID for this sound
          final id = '${categoryType.name}_${fileName.hashCode}';

          // Create the SoundModel
          final soundModel = SoundModel(
            id: id,
            name: displayName,
            soundPath: filePath,
            iconName: _getIconNameForCategory(categoryType),
            category: categoryType,
            isFavorite: false, // Will be updated from preferences later
          );

          // Add to the categorized sounds map
          categorizedSounds[categoryType]!.add(soundModel);
        }
      });

      return categorizedSounds;
    } catch (e) {
      // Error loading sound categories
      return {};
    }
  }

  /// Create SoundCategory objects from SoundModel lists
  List<SoundCategory> createSoundCategories(
    Map<CategoryType, List<SoundModel>> categorizedSounds,
  ) {
    final List<SoundCategory> categories = [];

    for (final entry in categorizedSounds.entries) {
      if (entry.value.isNotEmpty) {
        categories.add(
          SoundCategory(
            id: entry.key.name,
            name: entry.key.name,
            description: entry.key.description,
            icon: entry.key.icon,
            color: entry.key.color,
            sounds: entry.value,
          ),
        );
      }
    }

    return categories;
  }

  /// Fetch all sounds from MyInstants API
  Future<List<SoundModel>> fetchAllSoundsFromMyInstants(int page) async {
    try {
      final response = await http.get(
        Uri.parse('$_myInstantsBaseUrl/api/v1/instants/?page=$page'),
        headers: {'Accept': 'application/json', 'User-Agent': 'Mozilla/5.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        if (results.isEmpty) {
          return [];
        }

        return results.map((item) {
          final soundUrl = item['sound'] ?? '';
          return SoundModel(
            id: 'myinstants_${item['id'] ?? item['name']}',
            name: item['name'] ?? 'Unknown',
            soundPath:
                soundUrl.startsWith('http')
                    ? soundUrl
                    : '$_myInstantsBaseUrl$soundUrl',
            iconName: '0xe050', // music_note icon code
            category: CategoryType.meme,
            isFavorite: false,
          );
        }).toList();
      } else {
        throw Exception('Failed to load all sounds');
      }
    } catch (e) {
      // Error fetching all sounds
      throw Exception('Failed to load sounds: $e');
    }
  }

  /// Fetch sounds by category from MyInstants
  Future<List<SoundModel>> fetchSoundsByCategoryFromMyInstants(
    String category,
  ) async {
    if (category.isEmpty) {
      // For empty category (All), use the API
      return fetchAllSoundsFromMyInstants(1);
    }

    try {
      // Convert category to URL slug format
      final categorySlug = category.replaceAll(' ', '%20');
      final url = '$_myInstantsBaseUrl/en/categories/$categorySlug/';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final buttons = document.querySelectorAll('.instant-link');

        return buttons.map((element) {
          final title = element.text.trim();
          final onmousedown = element.attributes['onmousedown'] ?? '';
          String soundUrl = '';

          if (onmousedown.contains("'")) {
            soundUrl = onmousedown.split("'")[1];
          }

          return SoundModel(
            id: 'myinstants_$title',
            name: title,
            soundPath: '$_myInstantsBaseUrl$soundUrl',
            iconName: '0xe050', // music_note icon code
            category: CategoryType.meme,
            isFavorite: false,
          );
        }).toList();
      } else {
        throw Exception('Failed to load category sounds');
      }
    } catch (e) {
      // Error fetching category sounds
      throw Exception('Failed to load category sounds: $e');
    }
  }

  /// Get an appropriate icon name for the category (for sound model creation)
  String _getIconNameForCategory(CategoryType category) {
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
      case CategoryType.trending:
        return Icons.trending_up.codePoint.toString();
      case CategoryType.recent:
        return Icons.history.codePoint.toString();
      case CategoryType.best:
        return Icons.star.codePoint.toString();
    }
  }

  @override
  Future<List<SoundModel>> getTrending({String region = 'en'}) {
    // Implementation needed
    throw UnimplementedError();
  }

  @override
  Future<List<SoundModel>> getBest() {
    // Implementation needed
    throw UnimplementedError();
  }

  @override
  Future<List<SoundModel>> getRecent() {
    // Implementation needed
    throw UnimplementedError();
  }

  @override
  Future<List<SoundModel>> search(String query) {
    // Implementation needed
    throw UnimplementedError();
  }

  @override
  Future<SoundModel?> getSoundDetail(String id) {
    // Implementation needed
    throw UnimplementedError();
  }

  @override
  String getCategorySearchQuery(String category) {
    // Implementation needed
    throw UnimplementedError();
  }
}
