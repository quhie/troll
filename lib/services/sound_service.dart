import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import '../models/sound_model.dart';
import '../models/sound_category.dart';
import '../utils/app_config.dart';
import '../utils/constants.dart';
import '../utils/haptic_feedback_helper.dart';
import '../utils/string_utils.dart';
import '../utils/path_provider.dart';
import 'vibration_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../utils/message_constants.dart';
import 'favorite_service.dart';

/// Audio state for the currently playing sound
class AudioState {
  final String? currentSoundId;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final String? error;
  final String? message;
  
  AudioState({
    this.currentSoundId,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.error,
    this.message,
  });
}

/// Sound playback service that centralizes audio management
class SoundService extends ChangeNotifier {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  
  // Audio players instances
  final AudioPlayer _mainPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  
  // Sound collections
  final Map<CategoryType, List<SoundModel>> _categorizedSounds = {};
  List<SoundModel> _favoriteSounds = [];
  List<SoundCategory> _soundCategories = [];
  
  // Favorite service
  final FavoriteService _favoriteService = FavoriteService();
  
  // State tracking
  String? _currentPlayingSoundId;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isLoading = false;
  List<String> _recentlyPlayedSoundIds = [];
  String? _currentExternalUrl;
  
  // Event stream for audio state changes
  final _audioStateController = StreamController<AudioState>.broadcast();
  Stream<AudioState> get audioStateStream => _audioStateController.stream;
  
  // SharedPreferences key
  static const String _favoritesKey = 'favorite_sounds';
  static const String _recentlyPlayedKey = 'recently_played_sounds';
  static const int _maxRecentSounds = 20;
  
  // Getters for current audio state
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  bool get isLoading => _isLoading;
  String? get currentPlayingSoundId => _currentPlayingSoundId;
  
  // Get all sounds by category
  Map<CategoryType, List<SoundModel>> get categorizedSounds => _categorizedSounds;
  
  // Get favorite sounds
  List<SoundModel> get favoriteSounds => _favoriteService.favorites;
  
  // Get sound categories
  List<SoundCategory> get soundCategories => _soundCategories;
  
  // Cache u00e2m thanh u0111u00e3 tu1ea3i
  static final Map<String, String> _soundCache = {};
  
  // Getter cho cache
  Map<String, String> get soundCache => _soundCache;
  
  SoundService._internal() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Set up audio player listeners
    _mainPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _currentPlayingSoundId = null;
      _audioStateController.add(AudioState(isPlaying: false, currentSoundId: null));
      notifyListeners();
    });
    
    _mainPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        _isPlaying = false;
        _currentPlayingSoundId = null;
        _audioStateController.add(AudioState(isPlaying: false, currentSoundId: null));
        notifyListeners();
      }
    });
    
    // Load favorites from local storage
    await _loadFavorites();
    
    // Load recently played sounds
    await _loadRecentlyPlayed();
    
    // Initialize players and load sound categories
    await _initializeService();
  }

  /// Initialize the service by loading sound categories and sounds
  Future<void> _initializeService() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load all sound categories from the assets directory
      await _loadSoundCategories();
      
      // Load favorites from preferences
      await _loadFavorites();
      
      // Update favorite status for all loaded sounds
      _updateFavoritesStatus();
    } catch (e) {
      // Error initializing sound service
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load recently played sounds from shared preferences
  Future<void> _loadRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentlyPlayed = prefs.getStringList(_recentlyPlayedKey);
      
      if (recentlyPlayed != null) {
        _recentlyPlayedSoundIds.clear();
        _recentlyPlayedSoundIds.addAll(recentlyPlayed);
      }
    } catch (e) {
      // Error loading recently played
    }
  }
  
  /// Save recently played sounds to shared preferences
  Future<void> _saveRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentlyPlayedKey, _recentlyPlayedSoundIds);
    } catch (e) {
      // Error saving recently played
    }
  }
  
  /// Add a sound ID to recently played list
  void _addToRecentlyPlayed(String soundId) {
    // Remove if already in the list
    _recentlyPlayedSoundIds.remove(soundId);
    
    // Add to the beginning
    _recentlyPlayedSoundIds.insert(0, soundId);
    
    // Maintain maximum size
    if (_recentlyPlayedSoundIds.length > _maxRecentSounds) {
      _recentlyPlayedSoundIds.removeLast();
    }
    
    _saveRecentlyPlayed();
  }
  
  /// Load all sound categories by scanning the assets directory
  Future<void> _loadSoundCategories() async {
    try {
      // Get the assets sound directories
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      // Extract sound directory paths
      final soundPaths = manifestMap.keys
          .where((key) => key.startsWith('assets/sounds/') && key.contains('.'))
          .toList();
      
      // Create a map to organize sound files by category
      final Map<String, List<String>> categoryFiles = {};
      
      // Process each sound file
      for (final soundPath in soundPaths) {
        // Extract the category from the path (assuming format: assets/sounds/category/file.mp3)
        final pathParts = soundPath.split('/');
        if (pathParts.length >= 3) {
          final categoryPath = pathParts[2]; // e.g., "340178__quhie__phone-device-sounds" or "phone"
          
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
      
      // Clear existing categories
      _soundCategories = [];
      _categorizedSounds.clear();
      
      // Process each category and create SoundModel objects
      categoryFiles.forEach((categoryDir, filePaths) {
        // Determine the category type from the mapping
        final categoryType = categoryMapping[categoryDir] ?? CategoryType.meme;
        
        // If this is the first time seeing this category, initialize its list
        if (!_categorizedSounds.containsKey(categoryType)) {
          _categorizedSounds[categoryType] = [];
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
          _categorizedSounds[categoryType]!.add(soundModel);
        }
      });
      
      // Create SoundCategory objects for each category that has sounds
      for (final entry in _categorizedSounds.entries) {
        if (entry.value.isNotEmpty) {
          _soundCategories.add(SoundCategory(
            id: entry.key.name,
            name: entry.key.name,
            description: entry.key.description,
            icon: entry.key.icon,
            color: entry.key.color,
            sounds: entry.value,
          ));
        }
      }
    } catch (e) {
      // Error loading sound categories
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
    }
  }

  /// Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      _favoriteSounds = favoritesJson
          .map((json) => SoundModel.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      // Error loading favorites
      _favoriteSounds = [];
    }
  }
  
  /// Update favorite status for all sounds based on _favoriteSounds list
  void _updateFavoritesStatus() {
    // Get all favorite IDs for quick lookup
    final favoriteIds = _favoriteService.favorites.map((s) => s.id).toSet();
    
    // Update all sounds in each category
    for (final category in _categorizedSounds.entries) {
      for (int i = 0; i < category.value.length; i++) {
        final sound = category.value[i];
        final isFavorite = favoriteIds.contains(sound.id);
        
        if (sound.isFavorite != isFavorite) {
          // Update this sound to match favorite status
          category.value[i] = sound.copyWith(isFavorite: isFavorite);
        }
      }
    }
    
    // Update our local copy
    _favoriteSounds = _favoriteService.favorites;
  }
  
  /// Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favoriteService.favorites.map((sound) => 
          jsonEncode(sound.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      // Error saving favorites
    }
  }
  
  /// Play a sound from a SoundModel
  Future<bool> playSound(dynamic sound) async {
    try {
      // If the same sound is already playing, stop it
      if (isPlaying && _currentPlayingSoundId == (sound is SoundModel ? sound.id : sound)) {
        await stopSound();
        return false;
      }
      
      // Otherwise stop any currently playing sound
      if (isPlaying) {
        await _mainPlayer.stop();
      }
      
      // Apply haptic feedback if enabled
      if (AppConfig.enableHapticFeedback) {
        HapticFeedbackHelper.mediumImpact();
      }
      
      // Play the sound based on input type
      if (sound is SoundModel) {
        // Check if the sound is an external URL
        if (sound.soundPath.startsWith('http://') || sound.soundPath.startsWith('https://')) {
          // Reset player state first
          await _mainPlayer.stop();
          await _mainPlayer.release();
          
          // Play external sound
          final success = await playExternalSound(sound.soundPath);
          if (!success) {
            // Failed to play external sound
            return false;
          }
          
          // Update state for this sound
          _currentPlayingSoundId = sound.id;
          _audioStateController.add(
            AudioState(isPlaying: true, currentSoundId: sound.id)
          );
          
          // Add to recently played
          _addToRecentlyPlayed(sound.id);
          
          notifyListeners();
          return true;
        } 
        // Check if the sound is a device file (downloaded sound)
        else if (sound.soundPath.startsWith('/') || sound.isLocal) {
          try {
            // Kiểm tra xem file có tồn tại không
            final file = File(sound.soundPath);
            final exists = await file.exists();
            
            if (!exists) {
              throw Exception('File not found: ${sound.soundPath}');
            }
            
            // Kiểm tra kích thước file
            final fileSize = await file.length();
            
            if (fileSize <= 0) {
              throw Exception('File is empty: ${sound.soundPath}');
            }
            
            // Reset player state first
            await _mainPlayer.stop();
            await _mainPlayer.release();
            
            // Phương pháp 1: Sử dụng DeviceFileSource
            final source = DeviceFileSource(sound.soundPath);
            await _mainPlayer.play(source);
            
            // Update state
            _isPlaying = true;
            _currentPlayingSoundId = sound.id;
            _audioStateController.add(
              AudioState(isPlaying: true, currentSoundId: sound.id)
            );
            
            // Add to recently played
            _addToRecentlyPlayed(sound.id);
            
            notifyListeners();
            return true;
          } catch (fileError) {
            // Thử phương pháp thay thế
            try {
              await _mainPlayer.stop();
              await _mainPlayer.release();
              
              // Phương pháp 2: Đọc file vào bộ nhớ và tạo bản copy tạm thời
              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.mp3');
              
              // Copy file gốc sang file tạm
              await File(sound.soundPath).copy(tempFile.path);
              
              // Phát từ file tạm
              await _mainPlayer.setSourceDeviceFile(tempFile.path);
              await _mainPlayer.resume();
              
              // Update state
              _isPlaying = true;
              _currentPlayingSoundId = sound.id;
              _audioStateController.add(
                AudioState(isPlaying: true, currentSoundId: sound.id)
              );
              
              // Add to recently played
              _addToRecentlyPlayed(sound.id);
              
              notifyListeners();
              return true;
            } catch (alternativeError) {
              return false;
            }
          }
        }
        else {
          final formattedPath = PathProvider.formatSoundPath(sound.soundPath);
          
          // Kiểm tra xem file có tồn tại không
          try {
            await _mainPlayer.stop();
            await _mainPlayer.release(); // Reset player state
            
            // Play with asset source
            await _mainPlayer.play(AssetSource(formattedPath));
          } catch (playError) {
            return false;
          }
        }
        
        // Update state
        _isPlaying = true;
        _currentPlayingSoundId = sound.id;
        _audioStateController.add(
          AudioState(isPlaying: true, currentSoundId: sound.id)
        );
        
        // Add to recently played
        _addToRecentlyPlayed(sound.id);
      } else if (sound is String) {
        // Find the sound model by ID
        SoundModel? foundSound;
        
        // Look in all categories
        for (final entry in _categorizedSounds.entries) {
          final category = entry.key;
          final sounds = entry.value;
          
          // Find the matching sound in this category
          for (final s in sounds) {
            if (s.id == sound) {
              foundSound = s;
              break;
            }
          }
          
          if (foundSound != null) break;
        }
        
        // If sound not found in categories, check favorites
        if (foundSound == null) {
          for (final s in _favoriteService.favorites) {
            if (s.id == sound) {
              foundSound = s;
              break;
            }
          }
        }
        
        // If still not found, create a fallback sound
        if (foundSound == null) {
          foundSound = SoundModel(
            id: sound,
            name: 'Unknown Sound',
            soundPath: 'sounds/$sound.mp3',
            iconName: Constants.errorIcon.codePoint.toString(),
            category: CategoryType.meme,
          );
        }
        
        // Check if the sound is an external URL
        if (foundSound.soundPath.startsWith('http://') || foundSound.soundPath.startsWith('https://')) {
          // Gọi playExternalSound để xử lý âm thanh từ URL
          await playExternalSound(foundSound.soundPath);
          
          // Update state for this sound ID
          _currentPlayingSoundId = sound;
          _audioStateController.add(
            AudioState(isPlaying: true, currentSoundId: sound)
          );
          
          // Add to recently played
          _addToRecentlyPlayed(sound);
          
          notifyListeners();
          return true;
        } else {
          final formattedPath = PathProvider.formatSoundPath(foundSound.soundPath);
          await _mainPlayer.play(AssetSource(formattedPath));
        }
        
        // Update state
        _isPlaying = true;
        _currentPlayingSoundId = sound;
        _audioStateController.add(
          AudioState(isPlaying: true, currentSoundId: sound)
        );
        
        // Add to recently played
        _addToRecentlyPlayed(sound);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _audioStateController.add(AudioState(
        isPlaying: false,
        error: 'Could not play sound: ${e.toString()}',
      ));
      return false;
    }
  }
  
  /// Stop the currently playing sound
  Future<void> stopSound() async {
    try {
      await _mainPlayer.stop();
      _currentPlayingSoundId = null;
      _isPlaying = false;
      _isPaused = false;
      
      _audioStateController.add(AudioState(
        isPlaying: false,
        currentSoundId: null,
      ));
      
      notifyListeners();
    } catch (e) {
      // Error stopping sound
    }
  }
  
  /// Play a sound from an external URL
  Future<bool> playExternalSound(String dirtyUrl) async {
  try {
    // Clean the URL
    String url = dirtyUrl;
    if (url.contains("'")) {
      // Cut the URL at the first single quote
      url = url.split("'")[0];
    }
    
    // Stop any current playback
    await _mainPlayer.stop();
    await _mainPlayer.release();
    
    // Kiu1ec3m tra cache tru01b0u1edbc
    if (_soundCache.containsKey(url)) {
      final cachedPath = _soundCache[url]!;
      
      try {
        await _mainPlayer.setSourceDeviceFile(cachedPath);
        await _mainPlayer.resume();
        
        // Update state
        _isPlaying = true;
        _isPaused = false;
        _isLoading = false;
        _currentPlayingSoundId = 'external_${url.hashCode}';
        _currentExternalUrl = url;
        
        _audioStateController.add(AudioState(
          isPlaying: true,
          currentSoundId: _currentPlayingSoundId,
        ));
        
        notifyListeners();
        return true;
      } catch (cacheError) {
        // Xu00f3a file cache lu1ed7i vu00e0 tiu1ebfp tu1ee5c
        _soundCache.remove(url);
      }
    }
    
    // Uu tiu00ean tu1ea3i file vu1ec1 local tru01b0u1edbc, vu00ec u0111u00e2y thu01b0u1eddng lu00e0 cu00e1ch u0111u00e1ng tin cu1eady hu01a1n
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Download timed out after 10 seconds');
        },
      );
      
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'sound_${url.hashCode}.mp3';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        // Lu01b0u vu00e0o cache
        _soundCache[url] = file.path;
        
        await _mainPlayer.setSourceDeviceFile(file.path);
        await _mainPlayer.resume();
        
        // Update state
        _isPlaying = true;
        _isPaused = false;
        _isLoading = false;
        _currentPlayingSoundId = 'external_${url.hashCode}';
        _currentExternalUrl = url;
        
        _audioStateController.add(AudioState(
          isPlaying: true,
          currentSoundId: _currentPlayingSoundId,
        ));
        
        notifyListeners();
        return true;
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (downloadError) {
      // Nu1ebfu tu1ea3i vu1ec1 thu1ea5t bu1ea1i, thu1eed phu00e1t tru1ef1c tiu1ebfp
      try {
        await _mainPlayer.setSourceUrl(url).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException('Direct playback timed out after 5 seconds');
          },
        );
        await _mainPlayer.resume();
        
        // Update state
        _isPlaying = true;
        _isPaused = false;
        _isLoading = false;
        _currentPlayingSoundId = 'external_${url.hashCode}';
        _currentExternalUrl = url;
        
        _audioStateController.add(AudioState(
          isPlaying: true,
          currentSoundId: _currentPlayingSoundId,
        ));
        
        notifyListeners();
        return true;
      } catch (streamError) {
        throw streamError; // Re-throw to be caught by outer catch
      }
    }
  } catch (e) {
    _isLoading = false;
    _isPlaying = false;
    _isPaused = false;
    notifyListeners();
    
    _audioStateController.add(AudioState(
      isPlaying: false,
      error: "Error playing sound: $e",
    ));
    
    return false;
  }
}
  
  /// Toggle favorite status for a sound and update storage
  Future<void> toggleFavorite(SoundModel sound) async {
    try {
      // Toggle favorite in FavoriteService
      await _favoriteService.toggleFavorite(sound);
      
      // Update the sound in any category it exists in
      for (final category in _categorizedSounds.entries) {
        final index = category.value.indexWhere((s) => s.id == sound.id);
        if (index != -1) {
          final isFavorite = _favoriteService.isFavorite(sound.id);
          category.value[index] = category.value[index].copyWith(
            isFavorite: isFavorite
          );
        }
      }
      
      // Update our local copy
      _favoriteSounds = _favoriteService.favorites;
      
      // Notify listeners
      notifyListeners();
    } catch (e) {
      // Error toggling favorite
    }
  }
  
  /// Download a sound from URL to local storage
  Future<void> downloadSound(SoundModel sound) async {
    try {
      // Add to stream with "downloading" state
      _audioStateController.add(AudioState(
        message: "${MessageConstants.download['in_progress']?['en']} / ${MessageConstants.download['in_progress']?['vi']}",
      ));
      
      // Check if sound already exists in Downloads directory
      final dir = await getDownloadsDirectory();
      if (dir == null) {
        _audioStateController.add(AudioState(
          error: "${MessageConstants.download['no_storage']?['en']} / ${MessageConstants.download['no_storage']?['vi']}",
        ));
        return;
      }
      
      // Create sanitized filename (remove special characters)
      final sanitizedName = sound.name
          .replaceAll(RegExp(r'[^\w\s.-]'), '')
          .replaceAll(RegExp(r'\s+'), '_');
          
      final filePath = '${dir.path}/$sanitizedName.mp3';
      final file = File(filePath);
      
      // Check if file already exists
      if (await file.exists()) {
        _audioStateController.add(AudioState(
          message: "${MessageConstants.download['completed']?['en']}: $sanitizedName.mp3 / ${MessageConstants.download['completed']?['vi']}: $sanitizedName.mp3",
        ));
        return;
      }
      
      // Download from URL
      final response = await http.get(Uri.parse(sound.soundPath));
      
      if (response.statusCode != 200) {
        _audioStateController.add(AudioState(
          error: "${MessageConstants.download['error']?['en']} (${response.statusCode}) / ${MessageConstants.download['error']?['vi']} (${response.statusCode})",
        ));
        return;
      }
      
      // Write to file
      await file.writeAsBytes(response.bodyBytes);
      
      // Add success message to stream
      _audioStateController.add(AudioState(
        message: "${MessageConstants.download['success']?['en']}: $sanitizedName.mp3 / ${MessageConstants.download['success']?['vi']}: $sanitizedName.mp3",
      ));
      
    } catch (e) {
      _audioStateController.add(AudioState(
        error: "${MessageConstants.download['error']?['en']}: $e / ${MessageConstants.download['error']?['vi']}: $e",
      ));
    }
  }
  
  /// Get recently played sounds
  List<SoundModel> getRecentSounds() {
    if (_recentlyPlayedSoundIds.isEmpty) {
      return [];
    }
    
    final allSounds = <SoundModel>[];
    _categorizedSounds.forEach((_, sounds) {
      allSounds.addAll(sounds);
    });
    
    return _recentlyPlayedSoundIds.map((id) {
      return allSounds.firstWhere((sound) => sound.id == id, 
          orElse: () => SoundModel(
            id: 'unknown',
            name: 'Unknown Sound',
            soundPath: '',
            iconName: '0xe050',
            category: CategoryType.meme,
          ));
    }).where((sound) => sound.id != 'unknown').toList();
  }
  
  /// Clear all recently played sounds
  Future<void> clearRecentSounds() async {
    _recentlyPlayedSoundIds.clear();
    await _saveRecentlyPlayed();
    notifyListeners();
  }
  
  /// Get all sounds from all categories
  List<SoundModel> getAllSounds() {
    final result = <SoundModel>[];
    
    for (final category in _categorizedSounds.entries) {
      result.addAll(category.value);
    }
    
    return result;
  }

  // Add a dispose method to clean up resources
  @override
  void dispose() {
    // Clean up players
    _mainPlayer.dispose();
    _backgroundPlayer.dispose();
    
    // Close stream controller
    _audioStateController.close();
    
    super.dispose();
  }

  /// Load sounds from local storage directories
  Future<List<SoundModel>> loadLocalSounds() async {
    List<SoundModel> localSounds = [];
    
    try {
      // Get platform-specific download paths
      final List<String> directories = await _getLocalSoundDirectories();
      
      for (final dir in directories) {
        final directory = Directory(dir);
        
        if (await directory.exists()) {
          final files = directory.listSync()
            .where((file) => 
              file is File && 
              (file.path.endsWith('.mp3') || 
               file.path.endsWith('.m4a') || 
               file.path.endsWith('.wav')))
            .toList();
          
          // Convert files to SoundModel objects
          for (final file in files) {
            final fileName = path.basename(file.path);
            final nameWithoutExt = path.basenameWithoutExtension(file.path);
            
            // Create a SoundModel for this local file
            final sound = SoundModel(
              id: 'local_${fileName.hashCode}',
              name: _formatSoundName(nameWithoutExt),
              soundPath: file.path,
              iconName: '58826', // music_note icon
              category: _getCategoryFromFileName(fileName),
              isLocal: true,
              isFavorite: _favoriteService.isFavorite(nameWithoutExt),
            );
            
            localSounds.add(sound);
          }
        }
      }
    } catch (e) {
      // Error loading local sounds
    }
    
    return localSounds;
  }
  
  /// Get platform-specific directories for local sound files
  Future<List<String>> _getLocalSoundDirectories() async {
    final List<String> directories = [];
    
    // Android download directory
    if (Platform.isAndroid) {
      directories.add('/storage/emulated/0/Download/TrollProMax');
    }
    
    // iOS documents directory
    if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      directories.add('${dir.path}/TrollProMax');
    }
    
    // App's local directory (for all platforms)
    final appDir = await getApplicationDocumentsDirectory();
    directories.add('${appDir.path}/sounds');
    
    return directories;
  }
  
  /// Format a sound name from filename (convert snake/dash case to title case)
  String _formatSoundName(String filename) {
    // Replace underscores and dashes with spaces
    var name = filename.replaceAll(RegExp(r'[_-]'), ' ');
    
    // Convert to title case (capitalize first letter of each word)
    name = name.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    return name;
  }
  
  /// Determine the category type based on filename
  CategoryType _getCategoryFromFileName(String filename) {
    final lowerCase = filename.toLowerCase();
    
    if (lowerCase.contains('game') || lowerCase.contains('gaming')) 
      return CategoryType.game;
    if (lowerCase.contains('horror') || lowerCase.contains('scary')) 
      return CategoryType.horror;
    if (lowerCase.contains('meme') || lowerCase.contains('funny')) 
      return CategoryType.meme;
    if (lowerCase.contains('phone') || lowerCase.contains('ringtone')) 
      return CategoryType.phone;
    if (lowerCase.contains('social') || lowerCase.contains('notification')) 
      return CategoryType.social;
    if (lowerCase.contains('alarm') || lowerCase.contains('alert')) 
      return CategoryType.alarm;
    
    // Default to meme category
    return CategoryType.meme;
  }
  
  /// Add a downloaded sound to local storage
  Future<void> addLocalSound(SoundModel sound) async {
    try {
      // Add to categorized sounds
      _categorizedSounds.putIfAbsent(sound.category, () => []).add(sound);
      
      // If the sound is favorited, add to favorites
      if (sound.isFavorite) {
        _favoriteService.addFavorite(sound);
        await _saveFavorites();
      }
      
      notifyListeners();
    } catch (e) {
      // Error adding local sound
    }
  }

  /// Clear sound cache to free up memory
  Future<void> clearSoundCache() async {
    try {
      for (final path in _soundCache.values) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _soundCache.clear();
    } catch (e) {
      // Error clearing sound cache
    }
  }
} 