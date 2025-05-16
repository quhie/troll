import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import '../models/sound_model.dart';
import '../models/sound_category.dart';
import '../services/sound_service.dart';
import '../services/myinstants_service.dart';
import '../services/preferences_service.dart';
import '../services/favorite_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';
import '../utils/toast_helper.dart';

class SoundViewModel extends ChangeNotifier {
  final SoundService _soundService;
  final MyInstantsService _myInstantsService;
  final PreferencesService _preferencesService;
  final FavoriteService _favoriteService = FavoriteService();
  final Dio _dio = Dio();
  
  // Sound state
  List<SoundModel> _localSounds = [];
  List<SoundModel> _onlineSounds = [];
  List<SoundModel> _favoriteSounds = [];
  String? _currentPlayingSoundId;
  bool _isLoading = false;
  bool _isDownloading = false;
  String _downloadProgress = '';
  String? _downloadingSoundId;
  Map<CategoryType, List<SoundModel>> _categorizedSounds = {};
  String _selectedCategory = '';
  String _searchQuery = '';
  
  // Danh sách danh mục chuẩn cho API
  final List<String> _apiCategories = [
    'Anime & Manga',
    'Games',
    'Memes',
    'Movies',
    'Music',
    'Politics',
    'Pranks',
    'Reactions',
    'Sound Effects',
    'Sports',
    'Television',
    'TikTok Trends',
    'Viral',
    'Whatsapp Audios'
  ];
  
  // Ánh xạ từ khóa ngôn ngữ sang danh mục API
  final Map<String, String> _categoryToApiMap = {
    'anime_manga': 'Anime & Manga',
    'games': 'Games',
    'memes': 'Memes',
    'movies': 'Movies',
    'music': 'Music',
    'politics': 'Politics',
    'pranks': 'Pranks',
    'reactions': 'Reactions',
    'sound_effects': 'Sound Effects',
    'sports': 'Sports',
    'television': 'Television',
    'tiktok_trends': 'TikTok Trends',
    'viral': 'Viral',
    'whatsapp_audios': 'Whatsapp Audios',
  };
  
  // Giu1edbi hu1ea1n ku00edch thu01b0u1edbc cache
  static const int MAX_CACHE_SIZE = 50;
  
  // Getters
  List<SoundModel> get localSounds => _localSounds;
  List<SoundModel> get onlineSounds => _onlineSounds;
  List<SoundModel> get favoriteSounds => _favoriteSounds;
  String? get currentPlayingSoundId => _currentPlayingSoundId;
  bool get isLoading => _isLoading;
  bool get isDownloading => _isDownloading;
  String get downloadProgress => _downloadProgress;
  String? get downloadingSoundId => _downloadingSoundId;
  Map<CategoryType, List<SoundModel>> get categorizedSounds => _categorizedSounds;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  
  SoundViewModel({
    required SoundService soundService,
    required MyInstantsService myInstantsService,
    required PreferencesService preferencesService,
  }) : _soundService = soundService,
       _myInstantsService = myInstantsService,
       _preferencesService = preferencesService {
    // Initialize the ViewModel
    _initialize();
  }
  
  /// Initialize the ViewModel by loading sounds and setting up listeners
  Future<void> _initialize() async {
    _setLoading(true);
    
    // Load local sounds
    await _loadLocalSounds();
    
    // Load favorites
    _loadFavoriteSounds();
    
    // Register for audio state changes
    _soundService.audioStateStream.listen(_handleAudioStateChange);
    
    _setLoading(false);
    
    // Load online sounds if we have network connectivity
    await _loadOnlineSounds();
    
    // Đảm bảo đồng bộ hóa dữ liệu
    syncRecentSearchResults();
  }
  
  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Set downloading state
  void _setDownloading(bool downloading, {String? soundId, String progress = ''}) {
    _isDownloading = downloading;
    _downloadingSoundId = soundId;
    _downloadProgress = progress;
    notifyListeners();
  }
  
  /// Handle audio state changes
  void _handleAudioStateChange(AudioState state) {
    _currentPlayingSoundId = state.currentSoundId;
    notifyListeners();
  }
  
  /// Load local sounds from the device
  Future<void> _loadLocalSounds() async {
    try {
      final sounds = await _soundService.loadLocalSounds();
      _localSounds = sounds;
      _updateCategorizedSounds();
    } catch (e) {
      // Error loading local sounds
    }
  }
  
  /// Load favorite sounds from preferences
  void _loadFavoriteSounds() {
    _favoriteSounds = _favoriteService.getFavorites();
    _updateCategorizedSounds();
  }
  
  /// Load online sounds
  Future<void> _loadOnlineSounds() async {
    try {
      _setLoading(true);
      
      List<SoundModel> sounds;
      
      // Either fetch all sounds or by category
      if (_selectedCategory.isEmpty) {
        // No category selected, loading recent sounds
        sounds = await _myInstantsService.getRecent();
        // Loaded recent sounds
      } else {
        try {
          // Loading sounds for category
          sounds = await _myInstantsService.fetchSoundsByCategory(_selectedCategory);
          // Loaded sounds for category
          
          // If no sounds found for category, try trending sounds as fallback
          if (sounds.isEmpty) {
            // No sounds found for category, using trending as fallback
            sounds = await _myInstantsService.getTrending();
            // Loaded trending sounds as fallback
          }
        } catch (e) {
          // Error loading category sounds
          // Falling back to trending sounds due to error
          sounds = await _myInstantsService.getTrending();
          // Loaded trending sounds as fallback
        }
      }
      
      // Nếu vẫn không có sounds, sử dụng dữ liệu mẫu
      if (sounds.isEmpty) {
        // Still no sounds from API, using mock data
        sounds = _createMockSounds(_selectedCategory.isNotEmpty ? _selectedCategory : 'Recent');
        // Created mock sounds for display
      }
      
      // Mark favorites in online sounds
      int favoriteCount = 0;
      for (var i = 0; i < sounds.length; i++) {
        final soundId = sounds[i].id;
        final isFavorite = _favoriteService.isFavorite(soundId);
        if (isFavorite) favoriteCount++;
        sounds[i] = sounds[i].copyWith(isFavorite: isFavorite);
      }
      // Found favorites among sounds
      
      // Force UI update if no changes to online sounds
      bool hasChanges = _onlineSounds.length != sounds.length;
      if (!hasChanges) {
        for (int i = 0; i < _onlineSounds.length; i++) {
          if (i >= sounds.length || _onlineSounds[i].id != sounds[i].id) {
            hasChanges = true;
            break;
          }
        }
      }
      
      _onlineSounds = sounds;
      // Updated _onlineSounds with sounds
      
      if (_onlineSounds.isNotEmpty) {
      }
      
      _updateCategorizedSounds();
      
      // Always notify to ensure UI updates
      notifyListeners();
      // Notified listeners with updated sounds
    } catch (e) {
      // Error loading online sounds
      // Use mock data on error
      _onlineSounds = _createMockSounds(_selectedCategory.isNotEmpty ? _selectedCategory : 'Error');
      // Created mock sounds due to error
      _updateCategorizedSounds();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Update categorized sounds map
  void _updateCategorizedSounds() {
    // Updating categorized sounds
    final Map<CategoryType, List<SoundModel>> categorized = {};
    
    // Add local sounds
    int localCount = 0;
    for (final sound in _localSounds) {
      categorized.putIfAbsent(sound.category, () => []).add(sound);
      localCount++;
    }
    // Added local sounds to categorized map
    
    // Create a special category for favorites
    List<SoundModel> favoriteSoundsList = [];
    
    // Add all favorites to the favorites list
    for (final sound in _favoriteSounds) {
      favoriteSoundsList.add(sound);
    }
    
    // Add the favorites category if it has items
    if (favoriteSoundsList.isNotEmpty) {
      categorized[CategoryType.favorite] = favoriteSoundsList;
      // Added favorite sounds to special category
    }
    
    // Add favorite online sounds to their respective categories
    int onlineFavCount = 0;
    for (final sound in _favoriteSounds) {
      if (!_localSounds.any((localSound) => localSound.id == sound.id) && 
          sound.category != CategoryType.favorite) {
        categorized.putIfAbsent(sound.category, () => []).add(sound);
        onlineFavCount++;
      }
    }
    // Added online favorites to their respective categories
    
    // Log the categories we have
    // Categories in map
    for (var entry in categorized.entries) {
      // Category has sounds
    }
    
    _categorizedSounds = categorized;
    notifyListeners();
    // Called notifyListeners after updating categorized sounds
  }
  
  /// Play a sound
  Future<bool> playSound(SoundModel sound) async {
    // Attempting to play sound
    try {
      // Sound path
      
      // Kiểm tra xem âm thanh đã được tải xuống chưa
      if (sound.soundPath.startsWith('http://') || sound.soundPath.startsWith('https://')) {
        // External URL detected, using direct playback
        // Try to play from URL
        final result = await _soundService.playSound(sound);
        if (result) {
          // Sound played successfully from URL
          _currentPlayingSoundId = sound.id;
          notifyListeners();
        } else {
          // Failed to play from URL
        }
        return result;
      } else {
        // Playing sound from asset path
        final result = await _soundService.playSound(sound);
        if (result) {
          _currentPlayingSoundId = sound.id;
          notifyListeners();
        }
        return result;
      }
    } catch (e) {
      // Error playing sound
      return false;
    }
  }
  
  /// Stop the currently playing sound
  void stopSound() {
    _soundService.stopSound();
  }
  
  /// Toggle favorite status for a sound
  Future<void> toggleFavorite(SoundModel sound) async {
    await _favoriteService.toggleFavorite(sound);
    
    // Update local sounds favorite status
    final localIndex = _localSounds.indexWhere((s) => s.id == sound.id);
    if (localIndex != -1) {
      final isFavorite = _favoriteService.isFavorite(sound.id);
      _localSounds[localIndex] = _localSounds[localIndex].copyWith(
        isFavorite: isFavorite
      );
    }
    
    // Update online sounds favorite status
    final onlineIndex = _onlineSounds.indexWhere((s) => s.id == sound.id);
    if (onlineIndex != -1) {
      final isFavorite = _favoriteService.isFavorite(sound.id);
      _onlineSounds[onlineIndex] = _onlineSounds[onlineIndex].copyWith(
        isFavorite: isFavorite
      );
    }
    
    // Reload favorites
    _loadFavoriteSounds();
    
    // Notify listeners for UI update
    notifyListeners();
  }
  
  /// Select a category
  void selectCategory(String localizedCategory) {
    // Ghi nhớ localizedCategory để UI có thể hiển thị đúng
    if (_selectedCategory != localizedCategory) {
      _selectedCategory = localizedCategory;
      notifyListeners();
      
      // Nếu chọn danh mục từ danh sách mới thì tìm kiếm theo danh mục đó
      if (localizedCategory.isNotEmpty) {
        _fetchSoundsByCategory(localizedCategory);
      } else {
        _loadOnlineSounds();
      }
    }
  }
  
  /// Get API category name
  String _getApiCategoryName(String localizedCategory) {
    // Trường hợp 1: Nếu danh mục đã là danh mục API tiếng Anh
    if (_apiCategories.contains(localizedCategory)) {
      return localizedCategory;
    }
    
    // Trường hợp 2: Nếu danh mục là khóa ngôn ngữ (anime_manga, games, ...)
    if (_categoryToApiMap.containsKey(localizedCategory)) {
      return _categoryToApiMap[localizedCategory]!;
    }
    
    // Trường hợp 3: Nếu danh mục là tên đã dịch (tiếng Việt: "Âm nhạc", "Trò chơi", ...)
    // Tìm khóa ngôn ngữ tương ứng
    for (var entry in _categoryToApiMap.entries) {
      if (entry.key.tr() == localizedCategory) {
        return entry.value;
      }
    }
    
    // Trường hợp 4: Tìm theo từng phần của tên danh mục
    for (var apiCategory in _apiCategories) {
      // Tên danh mục trong API thường có dạng "Anime & Manga"
      // Trong khi tên đã dịch có thể là "Anime và Manga" hoặc tương tự
      // Kiểm tra xem danh mục API có chứa trong danh mục đã dịch không
      final mainPart = apiCategory.split(' & ')[0].toLowerCase();
      if (localizedCategory.toLowerCase().contains(mainPart.toLowerCase())) {
        return apiCategory;
      }
    }
    
    // Mặc định trả về danh mục gốc nếu không tìm thấy
    return localizedCategory;
  }
  
  /// Fetch sounds by category
  Future<void> _fetchSoundsByCategory(String localizedCategory) async {
    try {
      _setLoading(true);
      
      // Chuyển đổi tên danh mục đã dịch sang tên danh mục API
      final apiCategory = _getApiCategoryName(localizedCategory);
      
      // Lấy âm thanh dựa trên danh mục API
      final sounds = await _myInstantsService.fetchSoundsByCategory(apiCategory);
      
      // Nếu không có âm thanh, dùng dữ liệu mẫu
      if (sounds.isEmpty) {
        _onlineSounds = _createMockSounds(apiCategory);
      } else {
        // Đánh dấu những âm thanh yêu thích
        for (var i = 0; i < sounds.length; i++) {
          final isFavorite = _favoriteService.isFavorite(sounds[i].id);
          sounds[i] = sounds[i].copyWith(isFavorite: isFavorite);
        }
        
        _onlineSounds = sounds;
      }
      
      _updateCategorizedSounds();
      notifyListeners();
    } catch (e) {
      // Dùng dữ liệu mẫu khi có lỗi
      _onlineSounds = _createMockSounds(localizedCategory);
      _updateCategorizedSounds();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Search sounds
  Future<List<SoundModel>> searchSounds(String query) async {
    if (query.isEmpty) return [];
    
    _searchQuery = query;
    notifyListeners();
    
    try {
      // Quản lý cache trước khi tìm kiếm mới
      await manageSoundCache();
      
      final results = await _myInstantsService.search(query);
      
      // Mark favorites in search results
      for (var i = 0; i < results.length; i++) {
        final soundId = results[i].id;
        final isFavorite = _favoriteService.isFavorite(soundId);
        results[i] = results[i].copyWith(isFavorite: isFavorite);
      }
      
      // Cache search results if they're valid
      if (results.isNotEmpty) {
        // Lưu kết quả tìm kiếm vào cache để có thể dùng lại
        _lastSearchResults = List.from(results);
        
        // Nếu có nhiều hơn 50 kết quả, chỉ lưu 50 để đảm bảo hiệu suất
        if (_lastSearchResults.length > 50) {
          _lastSearchResults = _lastSearchResults.sublist(0, 50);
        }
        
        // Cached search results for query
      }
      
      return results;
    } catch (e) {
      // Error searching sounds
      return [];
    }
  }
  
  /// Download a sound from a URL to local storage
  Future<bool> downloadSound(SoundModel sound) async {
    try {
      _isDownloading = true;
      _downloadingSoundId = sound.id;
      _downloadProgress = '0%';
      notifyListeners();
      
      // 1. Kiểm tra quyền truy cập lưu trữ (chỉ cho Android)
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            // Sử dụng ToastHelper thay vì Fluttertoast
            // Không gọi ToastHelper ở đây vì không có context
            _isDownloading = false;
            _downloadingSoundId = null;
            notifyListeners();
            return false;
          }
        }
      }
      
      // 2. Xác định đường dẫn lưu trữ theo nền tảng
      String downloadPath;
      String fileExtension;
      
      // Xác định đuôi file từ URL nếu có thể
      if (sound.soundPath.toLowerCase().endsWith('.mp3')) {
        fileExtension = '.mp3';
      } else if (sound.soundPath.toLowerCase().endsWith('.m4a')) {
        fileExtension = '.m4a';
      } else if (sound.soundPath.toLowerCase().endsWith('.wav')) {
        fileExtension = '.wav';
      } else {
        // Mặc định
        fileExtension = '.mp3';
      }
      
      if (Platform.isAndroid) {
        // Android: lưu vào thư mục Download
        try {
          final directory = await getExternalStorageDirectory();
          if (directory == null) {
            throw Exception('Cannot access storage');
          }
          downloadPath = '${directory.path}/TrollProMax';
        } catch (e) {
          // Error getting download directory
          _isDownloading = false;
          _downloadingSoundId = null;
          notifyListeners();
          return false;
        }
      } else if (Platform.isIOS || Platform.isMacOS) {
        // iOS/macOS: lưu vào thư mục Documents
        final directory = await getApplicationDocumentsDirectory();
        downloadPath = '${directory.path}/TrollProMax';
        
        // iOS/macOS download path
      } else {
        // Nền tảng khác: sử dụng thư mục tạm
        final directory = await getTemporaryDirectory();
        downloadPath = directory.path;
      }
      
      // 3. Tạo thư mục nếu chưa tồn tại
      final directory = Directory(downloadPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      // 4. Chuẩn bị tên file
      final fileName = sound.name
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')  // Loại bỏ ký tự không hợp lệ
          .replaceAll(' ', '_')                      // Thay khoảng trắng bằng gạch dưới
          .toLowerCase();
          
      final fullPath = '$downloadPath/$fileName$fileExtension';
      // Full file path
      
      // 5. Kiểm tra file đã tồn tại chưa
      final file = File(fullPath);
      if (await file.exists()) {
        final fileSize = await file.length();
        // File already exists with size: $fileSize bytes
        
        if (fileSize > 0) {
          _isDownloading = false;
          _downloadingSoundId = null;
          notifyListeners();
          
          // Thêm âm thanh vào local sounds nếu chưa có
          _addToLocalSounds(sound, fullPath);
          
          // Trả về kết quả thành công để màn hình gọi hiển thị toast
          return true;
        } else {
          // Nếu file tồn tại nhưng rỗng, xóa và tải lại
          await file.delete();
          // Deleted empty file, will download again
        }
      }
      
      // 6. Tải xuống file sử dụng Dio
      final dio = Dio();
      try {
        // Starting download from URL
        await dio.download(
          sound.soundPath,
          fullPath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = (received / total * 100).toStringAsFixed(0);
              _downloadProgress = '$progress%';
              notifyListeners();
            }
          },
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            validateStatus: (status) {
              return status != null && status < 500;
            }
          )
        );
        
        // Kiểm tra file đã tải xuống
        if (await file.exists()) {
          final fileSize = await file.length();
          // Download completed. File size: $fileSize bytes
          
          if (fileSize <= 0) {
            // Downloaded file is empty
            _isDownloading = false;
            _downloadingSoundId = null;
            notifyListeners();
            return false;
          }
        } else {
          // File does not exist after download
          _isDownloading = false;
          _downloadingSoundId = null;
          notifyListeners();
          return false;
        }
        
        _isDownloading = false;
        _downloadingSoundId = null;
        _downloadProgress = '100%';
        notifyListeners();
        
        // Thêm âm thanh đã tải xuống vào danh sách local sounds
        _addToLocalSounds(sound, fullPath);
        
        // Trả về kết quả thành công để màn hình gọi hiển thị toast
        return true;
      } catch (downloadError) {
        // Download error
        _isDownloading = false;
        _downloadingSoundId = null;
        notifyListeners();
        
        // Trả về chi tiết lỗi cho màn hình gọi hiển thị
        return false;
      }
    } catch (e) {
      // Error downloading sound
      _isDownloading = false;
      _downloadingSoundId = null;
      notifyListeners();
      
      // Trả về chi tiết lỗi cho màn hình gọi hiển thị
      return false;
    }
  }
  
  /// Thêm âm thanh đã tải xuống vào danh sách local sounds
  void _addToLocalSounds(SoundModel originalSound, String localPath) {
    // Tạo SoundModel mới với đường dẫn local
    final localSound = SoundModel(
      id: 'local_${originalSound.id}',
      name: originalSound.name,
      soundPath: localPath,
      iconName: originalSound.iconName,
      category: originalSound.category,
      isFavorite: originalSound.isFavorite,
      isLocal: true
    );
    
    // Kiểm tra xem âm thanh đã có trong danh sách local chưa
    final existingIndex = _localSounds.indexWhere(
      (s) => s.soundPath == localPath || s.id == localSound.id
    );
    
    if (existingIndex == -1) {
      // Thêm vào đầu danh sách
      _localSounds.insert(0, localSound);
      // Added downloaded sound to local sounds
      
      // Cập nhật categorized sounds
      _updateCategorizedSounds();
      notifyListeners();
    } else {
      // Sound already exists in local sounds
    }
  }
  
  /// Request storage permission based on platform
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android, request storage permission
      var status = await Permission.storage.status;
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit storage permission for downloads
      return true;
    }
    
    // Default to true for other platforms
    return true;
  }
  
  /// Get platform-specific download path
  Future<String?> _getPlatformDownloadPath(String soundName) async {
    try {
      if (Platform.isAndroid) {
        // For Android, use the Downloads directory
        final Directory? directory = await getExternalStorageDirectory();
        if (directory == null) {
          return null;
        }
        
        // Create full path including subdirectories
        final String downloadPath = '${directory.path}/sounds';
        
        // Create directory if it doesn't exist
        final Directory dir = Directory(downloadPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        
        return downloadPath;
      } else if (Platform.isIOS) {
        // For iOS, use the Documents directory
        final Directory directory = await getApplicationDocumentsDirectory();
        
        // Create sounds subdirectory
        final String downloadPath = '${directory.path}/sounds';
        
        // Create directory if it doesn't exist
        final Directory dir = Directory(downloadPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        
        return downloadPath;
      }
      
      // For other platforms, use temp directory
      final tempDir = await getTemporaryDirectory();
      return tempDir.path;
    } catch (e) {
      // Error getting download path
      return null;
    }
  }
  
  /// Create a valid file name from sound name
  String _getDownloadFileName(String name) {
    // Replace invalid filename characters and spaces
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();
  }
  
  /// Clean up resources
  @override
  void dispose() {
    super.dispose();
  }
  
  /// Clear the selected category
  void clearSelectedCategory() {
    _selectedCategory = '';
    notifyListeners();
  }
  
  /// Load trending sounds
  Future<void> loadTrendingSounds() async {
    _setLoading(true);
    
    try {
      // Loading trending sounds
      
      final sounds = await _myInstantsService.getTrending();
      // Received trending sounds from API
      
      // Nếu không có âm thanh từ API, sử dụng dữ liệu mẫu
      List<SoundModel> finalSounds = sounds;
      if (sounds.isEmpty) {
        // Received empty list from API, creating mock data
        finalSounds = _createMockSounds('Trending');
      }
      
      // Mark favorites in sounds
      for (var i = 0; i < finalSounds.length; i++) {
        final soundId = finalSounds[i].id;
        final isFavorite = _favoriteService.isFavorite(soundId);
        finalSounds[i] = finalSounds[i].copyWith(isFavorite: isFavorite);
      }
      
      // Setting trending sounds to onlineSounds
      _onlineSounds = finalSounds;
      _updateCategorizedSounds();
      notifyListeners();
      
      if (finalSounds.isNotEmpty) {
        // First sound information
      }
    } catch (e) {
      // Error loading trending sounds
      // Sử dụng dữ liệu mẫu khi có lỗi
      _onlineSounds = _createMockSounds('Trending');
      _updateCategorizedSounds();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load recent sounds
  Future<void> loadRecentSounds() async {
    try {
      _setLoading(true);
      
      final sounds = await _myInstantsService.getRecent();
      
      // Nếu không có âm thanh từ API, sử dụng dữ liệu mẫu
      List<SoundModel> finalSounds = sounds;
      if (sounds.isEmpty) {
        finalSounds = _createMockSounds('Recent');
      }
      
      // Mark favorites in sounds
      for (var i = 0; i < finalSounds.length; i++) {
        final soundId = finalSounds[i].id;
        final isFavorite = _favoriteService.isFavorite(soundId);
        finalSounds[i] = finalSounds[i].copyWith(isFavorite: isFavorite);
      }
      
      // Luôn cập nhật UI
      _onlineSounds = finalSounds;
      _updateCategorizedSounds();
      notifyListeners();
    } catch (e) {
      // Sử dụng dữ liệu mẫu khi có lỗi
      _onlineSounds = _createMockSounds('Recent');
      _updateCategorizedSounds();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load best sounds
  Future<void> loadBestSounds() async {
    try {
      _setLoading(true);
      
      final sounds = await _myInstantsService.getBest();
      
      // Nếu không có âm thanh từ API, sử dụng dữ liệu mẫu
      List<SoundModel> finalSounds = sounds;
      if (sounds.isEmpty) {
        finalSounds = _createMockSounds('Best');
      }
      
      // Mark favorites in sounds
      for (var i = 0; i < finalSounds.length; i++) {
        final soundId = finalSounds[i].id;
        final isFavorite = _favoriteService.isFavorite(soundId);
        finalSounds[i] = finalSounds[i].copyWith(isFavorite: isFavorite);
      }
      
      // Luôn cập nhật UI
      _onlineSounds = finalSounds;
      _updateCategorizedSounds();
      notifyListeners();
    } catch (e) {
      // Sử dụng dữ liệu mẫu khi có lỗi
      _onlineSounds = _createMockSounds('Best');
      _updateCategorizedSounds();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Create mock sounds for testing
  List<SoundModel> _createMockSounds(String prefix) {
    final Uuid uuid = const Uuid();
    return List.generate(10, (index) => 
      SoundModel(
        id: uuid.v4(),
        name: '$prefix Sound ${index+1}',
        soundPath: 'https://www.myinstants.com/media/sounds/example${index+1}.mp3',
        iconName: Icons.music_note.codePoint.toString(),
        category: CategoryType.meme,
        isFavorite: index == 0, // Make first one favorite for testing
      )
    );
  }
  
  /// Force refresh UI
  void refreshUI() {
    notifyListeners();
  }
  
  /// Force loading mock sounds for testing
  Future<void> forceLoadMockSounds() async {
    _setLoading(true);
    
    try {
      // Tạo các mock sounds
      final mockSounds = _createMockSounds('Test');
      
      // Đánh dấu một số là favorites
      for (var i = 0; i < mockSounds.length; i++) {
        mockSounds[i] = mockSounds[i].copyWith(
          isFavorite: i % 3 == 0, // Mỗi sound thứ 3 là favorite
        );
      }
      
      // Cập nhật UI
      _onlineSounds = mockSounds;
      
      _updateCategorizedSounds();
      notifyListeners();
    } catch (e) {
      // Xử lý lỗi nếu có
    } finally {
      _setLoading(false);
    }
  }
  
  // Biến để lưu trữ kết quả tìm kiếm gần đây
  List<SoundModel> _lastSearchResults = [];
  
  /// Synchronize recent search results with online sounds if needed
  void syncRecentSearchResults() {
    if (_lastSearchResults.isEmpty) return;
    
    // Chỉ đồng bộ nếu không có online sounds hoặc số lượng quá ít
    if (_onlineSounds.isEmpty || _onlineSounds.length < 5) {
      // Sử dụng danh sách tìm kiếm gần đây nếu danh sách âm thanh trực tuyến trống
      _onlineSounds = List.from(_lastSearchResults);
      _updateCategorizedSounds();
      notifyListeners();
    }
  }
  
  /// Get recent search results
  List<SoundModel> getRecentSearchResults() {
    return _lastSearchResults;
  }
  
  /// Add sound to online sounds if not already present
  void addSoundToOnlineSounds(SoundModel sound) {
    // Kiểm tra xem âm thanh đã có trong danh sách chưa
    if (!_onlineSounds.any((s) => s.id == sound.id)) {
      // Thêm vào đầu danh sách để hiển thị trước
      _onlineSounds.insert(0, sound);
      // Giới hạn kích thước danh sách để đảm bảo hiệu suất
      if (_onlineSounds.length > 100) {
        _onlineSounds = _onlineSounds.sublist(0, 100);
      }
      _updateCategorizedSounds();
      notifyListeners();
    }
  }
  
  /// Update sync status after searching
  void updateAfterSearch() {
    // Đảm bảo các item đã được đồng bộ sau tìm kiếm
    syncRecentSearchResults();
  }
  
  /// Luu0301 luu01b0u01cec cache au0302m thanh
  Future<void> manageSoundCache() async {
    try {
      final cachedSounds = _soundService.soundCache.length;
      
      // Clear cache if too many sounds are cached
      if (cachedSounds > MAX_CACHE_SIZE) {
        await _soundService.clearSoundCache();
      }
    } catch (e) {
      // Xử lý lỗi cache nếu có
    }
  }
  
  /// Cập nhật UI khi ngôn ngữ thay đổi
  Future<void> refreshLanguage() async {
    // Only refresh UI, do not load data again
    notifyListeners();
  }
  
  /// Kiểm tra xem một âm thanh đã được tải về thiết bị chưa
  bool isLocalSound(String soundId) {
    return _localSounds.any((sound) => sound.id == soundId);
  }
} 