import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/category_bar.dart';
import '../widgets/sound_card.dart';
import '../models/sound_model.dart';
import '../services/myinstants_service.dart';
import '../services/sound_service.dart';
import '../utils/message_constants.dart';

class MyInstantsScreen extends StatefulWidget {
  const MyInstantsScreen({Key? key}) : super(key: key);

  @override
  State<MyInstantsScreen> createState() => _MyInstantsScreenState();
}

class _MyInstantsScreenState extends State<MyInstantsScreen>
    with SingleTickerProviderStateMixin {
  // Service for fetching MyInstants sounds
  final MyInstantsService _myInstantsService = MyInstantsService();

  // Scroll controller for infinite scrolling
  final ScrollController _scrollController = ScrollController();

  // State variables
  List<SoundModel> _sounds = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  String _selectedCategory = '';
  String? _currentPlayingSoundId;
  String _currentLocale = 'en'; // Default locale

  // Fixed category list with localized names
  final List<String> _categories = [
    '', // Empty represents "All"
    'Âm Nhạc',
    'Anime',
    'Game',
    'Meme',
    'Phim',
    'Hiệu Ứng Âm Thanh',
    'Reactions',
    'Âm Thanh Thú Vị',
    'TikTok',
    'Trào Lưu',
    'Tiếng Động Vật',
    'Tiếng Kêu',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize the scroll controller with a listener for infinite scrolling
    _scrollController.addListener(_onScroll);
    
    // Load sounds when the screen is first shown
    _loadSounds();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll listener for infinite scrolling
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreSounds();
    }
  }

  // Handle category selection
  void _onCategorySelected(String category) {
    if (category != _selectedCategory) {
      setState(() {
        _selectedCategory = category;
        _sounds = [];
        _page = 1;
        _hasMore = true;
        _isLoading = false;
      });
      _loadSounds();
    }
  }

  // Load sounds based on selected category
  Future<void> _loadSounds() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      List<SoundModel> newSounds;

      if (_selectedCategory.isEmpty) {
        // Get all sounds using API
        newSounds = await _myInstantsService.fetchAllSounds(_page);
      } else {
        // Get category-specific sounds
        newSounds = await _myInstantsService.fetchSoundsByCategory(
          _selectedCategory,
        );
      }

      setState(() {
        _sounds = newSounds;
        _isLoading = false;
        _hasMore = newSounds.isNotEmpty;
        if (_selectedCategory.isEmpty) {
          _page++;
        }
      });
    } catch (e) {
      _handleError('${MessageConstants.api['error']?[_currentLocale]}: $e');
    }
  }

  // Load more sounds (only for API/All category)
  Future<void> _loadMoreSounds() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      List<SoundModel> newSounds = [];

      if (_selectedCategory.isEmpty) {
        // Only pagination for All category
        newSounds = await _myInstantsService.fetchAllSounds(_page);

        setState(() {
          _sounds.addAll(newSounds);
          _page++;
          _isLoading = false;
          _hasMore = newSounds.isNotEmpty;
        });
      } else {
        // For specific categories, load more from existing list
        final allSounds = await _myInstantsService.fetchSoundsByCategory(
          _selectedCategory,
        );
        // Filter out sounds already in _sounds
        final existingIds = _sounds.map((s) => s.id).toSet();
        final newUniqueSounds =
            allSounds.where((s) => !existingIds.contains(s.id)).toList();

        setState(() {
          _sounds.addAll(newUniqueSounds);
          _isLoading = false;
          _hasMore = newUniqueSounds.isNotEmpty;
        });
      }
    } catch (e) {
      _handleError('${MessageConstants.api['error']?[_currentLocale]}: $e');
    }
  }

  // Handle errors
  void _handleError(String message) {
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Pull-to-refresh
  Future<void> _refreshSounds() async {
    setState(() {
      if (_selectedCategory.isEmpty) {
        _page = 1;
      }
      _hasMore = true;
    });
    await _loadSounds();
  }

  // Play sound with proper logging
  void _playSound(SoundModel sound) {
    final soundService = Provider.of<SoundService>(context, listen: false);
    soundService.playSound(sound);
  }

  @override
  Widget build(BuildContext context) {
    // Get sound service for playing sounds
    final soundService = Provider.of<SoundService>(context);
    _currentPlayingSoundId = soundService.currentPlayingSoundId;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Set current locale based on device locale
    _currentLocale =
        Localizations.localeOf(context).languageCode == 'vi' ? 'vi' : 'en';

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Âm Thanh Online',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshSounds,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search dialog
              _showSearchDialog();
            },
            tooltip: 'Tìm kiếm',
          ),
        ],
      ),
      body: StreamBuilder<AudioState>(
        stream: soundService.audioStateStream,
        builder: (context, snapshot) {
          // Process audio state events from the sound service
          if (snapshot.hasData) {
            final audioState = snapshot.data!;

            // Handle error messages
            if (audioState.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(audioState.error!),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              });
            }

            // Handle success messages
            if (audioState.message != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(audioState.message!),
                    backgroundColor: Colors.green.shade700,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              });
            }

            // Update current playing sound ID
            if (_currentPlayingSoundId != audioState.currentSoundId) {
              _currentPlayingSoundId = audioState.currentSoundId;
            }
          }

          return Column(
            children: [
              // Category bar
              CategoryBar(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: _onCategorySelected,
              ),

              // Sound list
              Expanded(
                child:
                    _isLoading && _sounds.isEmpty
                        ? _buildLoadingState()
                        : _sounds.isEmpty
                        ? _buildEmptyState()
                        : _buildSoundsList(),
              ),
            ],
          );
        },
      ),
    );
  }

  // Show search dialog
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              MessageConstants.search['title']?[_currentLocale] ??
                  'Search Sounds',
            ),
            content: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText:
                    MessageConstants.search['hint']?[_currentLocale] ??
                    'Enter sound name...',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                // TODO: Implement search logic
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  MessageConstants.search['cancel']?[_currentLocale] ??
                      'Cancel',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement search action
                  Navigator.pop(context);
                },
                child: Text(
                  MessageConstants.search['search']?[_currentLocale] ??
                      'Search',
                ),
              ),
            ],
          ),
    );
  }

  // Loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            MessageConstants.api['loading']?[_currentLocale] ??
                'Loading sounds...',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off,
            size: 64,
            color: isDark ? Colors.white38 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            MessageConstants.api['no_results']?[_currentLocale] ??
                'No sounds found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            MessageConstants.api['try_other_category']?[_currentLocale] ??
                'Try selecting a different category',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshSounds,
            icon: const Icon(Icons.refresh),
            label: Text(
              MessageConstants.api['refresh']?[_currentLocale] ?? 'Refresh',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Build sounds list
  Widget _buildSoundsList() {
    return RefreshIndicator(
      onRefresh: _refreshSounds,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _sounds.length + 1, // +1 for loading indicator
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom
          if (index == _sounds.length) {
            return _isLoading && _hasMore
                ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
                : const SizedBox.shrink();
          }

          final sound = _sounds[index];
          final isPlaying = sound.id == _currentPlayingSoundId;

          if (isPlaying) {
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SoundCard(
              sound: sound,
              isPlaying: isPlaying,
              showCategory: false,
              showDownloadButton: true,
              onTap: () {
                _playSound(sound);
              },
            ),
          ).animate().fade(duration: 300.ms, delay: (50 * (index % 10)).ms);
        },
      ),
    );
  }
}
