import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';
import '../models/sound_category.dart';
import '../models/sound_model.dart';
import '../viewmodels/sound_viewmodel.dart';
import '../services/sound_service.dart';
import '../services/myinstants_service.dart';
import '../widgets/sound_card.dart';
import '../widgets/category_bar.dart';
import '../widgets/empty_state.dart';
import '../screens/search_screen.dart';
import '../widgets/custom_app_bar.dart';
import 'package:flutter/services.dart';
import '../services/connectivity_service.dart';
import '../widgets/network_error_state.dart';
import '../widgets/custom_tooltip.dart';

/// Home screen for displaying sound categories
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String? _currentPlayingSoundId;
  bool _isLoading = true;
  
  // Theo dõi ngôn ngữ hiện tại để tránh cập nhật không cần thiết
  Locale? _lastLocale;
  
  // Tab names
  late String tabLocal;
  late String tabOnline;
  
  // Categories
  final List<String> _categories = [
    'anime_manga'.tr(),
    'games'.tr(),
    'memes'.tr(),
    'movies'.tr(), 
    'music'.tr(),
    'politics'.tr(),
    'pranks'.tr(),
    'reactions'.tr(),
    'sound_effects'.tr(),
    'sports'.tr(),
    'television'.tr(),
    'tiktok_trends'.tr(),
    'viral'.tr(),
    'whatsapp_audios'.tr()
  ];
  
  @override
  void initState() {
    super.initState();
    // Register the observer for app lifecycle events
    WidgetsBinding.instance.addObserver(this);
    
    _tabController = TabController(length: 2, vsync: this);
    
    // Add listener to stop sounds when tab changes
    _tabController.addListener(_handleTabChange);
    
    // Add scroll listener for infinite scrolling
    _scrollController.addListener(_scrollListener);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Đảm bảo bàn phím luôn ẩn khi vào màn hình home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
    });
    
    // Chỉ cập nhật khi locale thực sự thay đổi
    final currentLocale = context.locale;
    if (_lastLocale != currentLocale) {
      _lastLocale = currentLocale;
      
      if (mounted && _tabController.index == 1) {
        // Cập nhật UI
        setState(() {});
        
        // Gọi refreshLanguage chỉ khi cần thiết và đang ở tab online
        Future.microtask(() {
          final viewModel = Provider.of<SoundViewModel>(context, listen: false);
          viewModel.refreshLanguage();
        });
      }
    }
  }
  
  @override
  void dispose() {
    // Stop any playing sound when the view is disposed
    _stopCurrentSound();
    
    // Remove observer and listeners
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Stop sound when app goes to background
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive || 
        state == AppLifecycleState.detached) {
      _stopCurrentSound();
    }
  }
  
  /// Handle tab changes - stop sound when changing tabs
  void _handleTabChange() {
    // We only need to stop sounds when the tab actually changes
    // This listener might be called for other reasons too
    if (!_tabController.indexIsChanging) return;
    
    _stopCurrentSound();
  }
  
  /// Stop the currently playing sound if any
  void _stopCurrentSound() {
    final soundViewModel = Provider.of<SoundViewModel>(context, listen: false);
    soundViewModel.stopSound();
  }
  
  // Scroll listener for infinite scrolling
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 
        && _tabController.index == 1) { // Only load more for Online tab
      // Load more sounds in the ViewModel
      // This would be implemented in the ViewModel
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final soundViewModel = Provider.of<SoundViewModel>(context);
    
    // Đảm bảo các tab names luôn được cập nhật khi ngôn ngữ thay đổi
    tabLocal = 'app_sounds'.tr();
    tabOnline = 'online_sounds'.tr();
    
    _isLoading = soundViewModel.isLoading;
    _currentPlayingSoundId = soundViewModel.currentPlayingSoundId;
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Ẩn bàn phím khi nhấn ra ngoài
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBar: CustomAppBar(
          title: 'home_title'.tr(),
          actions: [
            CustomTooltip(
              message: 'search_sounds'.tr(),
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Navigate to search screen with animation
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const SearchScreen(fromBottomNav: false),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
              ),
            ),
          ],
          centerTitle: true,
          showBackButton: false,
          elevation: 2,
          backgroundColor: theme.appBarTheme.backgroundColor,
          showThemeToggle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: const Icon(Icons.headphones),
                text: tabLocal,  // Sử dụng biến cục bộ thay vì static
              ),
              Tab(
                icon: const Icon(Icons.cloud_download),
                text: tabOnline,  // Sử dụng biến cục bộ thay vì static
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Local Sounds Tab
              _buildLocalSoundsTab(context, soundViewModel),
              
              // Online Sounds Tab
              _buildOnlineSoundsTab(context, soundViewModel),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build the local sounds tab with local sounds and favorites (without categories)
  Widget _buildLocalSoundsTab(BuildContext context, SoundViewModel viewModel) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        // Header section with quick filter options
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFilterButton(
                context,
                icon: Icons.download_done_rounded,
                label: 'downloaded_sounds'.tr(),
                backgroundColor: Colors.teal,
                onTap: () {
                  // Filter to show only downloaded sounds
                  viewModel.selectCategory('');
                  setState(() {
                    // Reset to show all local sounds
                  });
                },
                isDark: isDark,
              ),
              _buildFilterButton(
                context,
                icon: Icons.favorite,
                label: 'favorite_sounds'.tr(),
                backgroundColor: Colors.pink,
                onTap: () {
                  // Filter to show only favorite sounds
                  viewModel.selectCategory(CategoryType.favorite.name);
                },
                isDark: isDark,
              ),
            ],
          ),
        ),
        
        // Sound list for local sounds and favorites
        Expanded(
          child: _isLoading
              ? _buildShimmerList() // Use the same shimmer style as online tab
              : _buildLocalSoundsList(context, viewModel),
        ),
      ],
    );
  }
  
  // Build local sounds list with the same style as online sounds list
  Widget _buildLocalSoundsList(BuildContext context, SoundViewModel viewModel) {
    final sounds = _getFilteredLocalSounds(viewModel);
    
    if (sounds.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.music_off,
        message: 'no_sounds_found'.tr(),
        subMessage: 'download_or_favorite'.tr(),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic for local sounds
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('refreshing'.tr()),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Use the new public method to refresh local sounds
        await viewModel.refreshLocalSounds();
        
        return Future.value();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sounds.length,
        itemBuilder: (context, index) {
          final sound = sounds[index];
          final isPlaying = _currentPlayingSoundId == sound.id;
          
          // Use the same card style as online sounds
          return Padding(
            key: ValueKey('local_${sound.id}'),
            padding: const EdgeInsets.only(bottom: 12),
            child: SoundCard(
              sound: sound,
              isPlaying: isPlaying,
              showCategory: true,
              showDownloadButton: false, // No need for download button on local sounds
              onPlay: () => _playSound(sound),
              onFavorite: () => _toggleFavorite(sound),
            ).animate(
              // Only animate new items
              key: ValueKey('anim_local_${sound.id}'),
              autoPlay: true,
              onComplete: (controller) => controller.dispose(),
            ).fade(
              duration: 300.ms,
              delay: (50 * index).ms,
            ).moveY(
              begin: 20, 
              end: 0,
              duration: 300.ms, 
              delay: (50 * index).ms,
              curve: Curves.easeOutQuad,
            ),
          );
        },
      ),
    );
  }
  
  // Build the online sounds tab with categories from API
  Widget _buildOnlineSoundsTab(BuildContext context, SoundViewModel viewModel) {
    // Check if we're offline first - show network error state
    if (!viewModel.hasNetworkConnection) {
      return Center(
        child: NetworkErrorState(
          onRetry: () async {
            // Manually check connectivity
            await ConnectivityService().checkRealConnectivity();
            
            // Force UI refresh if we're connected now
            if (ConnectivityService().isConnected && mounted) {
              setState(() {});
              
              // Reload online sounds
              viewModel.loadTrendingSounds();
            }
          },
        ),
      );
    }
    
    // Sử dụng memoization để tránh xây dựng danh sách categories mỗi lần build
    // Danh sách categories sẽ được lưu cache trong widget và chỉ cập nhật khi locale thay đổi
    final categories = _getLocalizedCategories();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      children: [
        // Horizontal category bar for online categories - IMPROVED UI
        Container(
          height: 120,
          margin: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              ),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    // All category card
                    _buildCategoryCard(
                      context, 
                      'all'.tr(), 
                      Icons.apps,
                      isSelected: viewModel.selectedCategory.isEmpty,
                      onTap: () {
                        viewModel.clearSelectedCategory();
                      },
                      primaryColor: theme.colorScheme.primary,
                    ),
                    
                    // Category cards
                    ...categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      // Determine color based on index for variety
                      final color = _getCategoryColor(index, isDark);
                      final icon = _getCategoryIcon(category);
                      
                      return _buildCategoryCard(
                        context,
                        category,
                        icon,
                        isSelected: viewModel.selectedCategory == category,
                        onTap: () {
                          viewModel.selectCategory(category);
                        },
                        primaryColor: color,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Quick filter buttons
        _buildQuickFilterButtons(context, viewModel),
        
        // Sound list for online sounds
        Expanded(
          child: _isLoading
              ? _buildShimmerList()
              : _buildOnlineSoundsList(context, viewModel),
        ),
      ],
    );
  }
  
  // Helper method to build category card
  Widget _buildCategoryCard(
    BuildContext context, 
    String name, 
    IconData icon, 
    {required bool isSelected, 
    required VoidCallback onTap,
    required Color primaryColor}
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: isSelected 
                ? primaryColor
                : isDark ? Colors.grey.shade800 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                    ? primaryColor.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            width: 100,
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected 
                    ? Colors.white 
                    : primaryColor,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isSelected 
                        ? Colors.white 
                        : isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Get color based on category index
  Color _getCategoryColor(int index, bool isDark) {
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.red,
      Colors.amber,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lime,
      Colors.deepOrange,
      Colors.cyan,
    ];
    
    // Use modulo to prevent index out of range
    final color = colors[index % colors.length];
    
    // Return a slightly darker shade for dark mode
    return isDark ? color.shade600 : color;
  }
  
  // Get icon based on category name
  IconData _getCategoryIcon(String category) {
    final lowerCase = category.toLowerCase();
    
    if (lowerCase.contains('anime') || lowerCase.contains('manga')) return Icons.format_paint;
    if (lowerCase.contains('game')) return Icons.videogame_asset;
    if (lowerCase.contains('meme')) return Icons.sentiment_very_satisfied;
    if (lowerCase.contains('movie')) return Icons.movie;
    if (lowerCase.contains('music')) return Icons.music_note;
    if (lowerCase.contains('politic')) return Icons.gavel;
    if (lowerCase.contains('prank')) return Icons.mood;
    if (lowerCase.contains('reaction')) return Icons.emoji_emotions;
    if (lowerCase.contains('sound_effect') || lowerCase.contains('effects')) return Icons.surround_sound;
    if (lowerCase.contains('sport')) return Icons.sports_soccer;
    if (lowerCase.contains('television') || lowerCase.contains('tv')) return Icons.tv;
    if (lowerCase.contains('tiktok')) return Icons.music_video;
    if (lowerCase.contains('viral')) return Icons.trending_up;
    if (lowerCase.contains('whatsapp')) return Icons.chat;
    
    return Icons.category;
  }
  
  // Helper method to get localized categories
  List<String> _getLocalizedCategories() {
    // Danh sách categories đã được dịch
    return [
      'anime_manga'.tr(),
      'games'.tr(),
      'memes'.tr(),
      'movies'.tr(), 
      'music'.tr(),
      'politics'.tr(),
      'pranks'.tr(),
      'reactions'.tr(),
      'sound_effects'.tr(),
      'sports'.tr(),
      'television'.tr(),
      'tiktok_trends'.tr(),
      'viral'.tr(),
      'whatsapp_audios'.tr()
    ];
  }
  
  // Shimmer loading effect for list
  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8, // Hiển thị 8 card giả
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(height: 80),
            ),
          );
        },
      ),
    );
  }
  
  // Build quick filter buttons for online tab
  Widget _buildQuickFilterButtons(BuildContext context, SoundViewModel viewModel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterButton(
            context,
            icon: Icons.trending_up,
            label: 'trending'.tr(),  // Đảm bảo sử dụng tr()
            backgroundColor: Colors.redAccent,
            onTap: () => _loadTrendingSounds(context, viewModel),
            isDark: isDark,
          ),
          _buildFilterButton(
            context,
            icon: Icons.access_time,
            label: 'recent'.tr(),  // Đảm bảo sử dụng tr()
            backgroundColor: Colors.blueAccent,
            onTap: () => _loadRecentSounds(context, viewModel),
            isDark: isDark,
          ),
          _buildFilterButton(
            context,
            icon: Icons.star,
            label: 'best'.tr(),  // Đảm bảo sử dụng tr()
            backgroundColor: Colors.orangeAccent,
            onTap: () => _loadBestSounds(context, viewModel),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
  
  // Build a filter button
  Widget _buildFilterButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: backgroundColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Load trending sounds
  void _loadTrendingSounds(BuildContext context, SoundViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('loading_category'.tr() + ': ' + 'trending'.tr()),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Clear the selected category to reset the UI state
    viewModel.clearSelectedCategory();
    
    // Load trending sounds
    viewModel.loadTrendingSounds();
  }
  
  // Load recent sounds
  void _loadRecentSounds(BuildContext context, SoundViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('loading_category'.tr() + ': ' + 'recent'.tr()),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Clear the selected category to reset the UI state
    viewModel.clearSelectedCategory();
    
    // Load recent sounds
    viewModel.loadRecentSounds();
  }
  
  // Load best sounds
  void _loadBestSounds(BuildContext context, SoundViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('loading_category'.tr() + ': ' + 'best'.tr()),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Clear the selected category to reset the UI state
    viewModel.clearSelectedCategory();
    
    // Load best sounds
    viewModel.loadBestSounds();
  }
  
  // Get filtered local sounds based on selected category
  List<SoundModel> _getFilteredLocalSounds(SoundViewModel viewModel) {
    final selectedCategory = viewModel.selectedCategory;
    final categorizedSounds = viewModel.categorizedSounds;
    
    if (selectedCategory.isEmpty) {
      // Return all local sounds and favorites
      final allSounds = <SoundModel>[];
      
      // Add favorites first if they exist
      if (categorizedSounds.containsKey(CategoryType.favorite)) {
        allSounds.addAll(categorizedSounds[CategoryType.favorite]!);
      }
      
      // Add local sounds
      allSounds.addAll(viewModel.localSounds.where(
        (sound) => !allSounds.any((s) => s.id == sound.id)
      ));
      
      return allSounds;
    } else {
      // Find the matching category
      for (final entry in categorizedSounds.entries) {
        if (entry.key.name == selectedCategory) {
          return entry.value;
        }
      }
      
      return [];
    }
  }
  
  // Build online sounds list with pagination
  Widget _buildOnlineSoundsList(BuildContext context, SoundViewModel viewModel) {
    final sounds = viewModel.onlineSounds;
    
    if (sounds.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.cloud_off,
        message: 'no_online_sounds'.tr(),
        subMessage: 'check_connection'.tr(),
        onRefresh: () {
          // Refresh sounds based on selected category
          viewModel.loadTrendingSounds();
        },
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        // Hiển thị thông báo đang làm mới
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('refreshing'.tr()),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Tải lại âm thanh dựa trên tab đang chọn
        await viewModel.loadTrendingSounds();
        return Future.value();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sounds.length,
        itemBuilder: (context, index) {
          final sound = sounds[index];
          final isPlaying = _currentPlayingSoundId == sound.id;
          final isDownloading = viewModel.isDownloading && viewModel.downloadingSoundId == sound.id;
          
          // Use a key for better list recycling
          return Padding(
            key: ValueKey('sound_${sound.id}'),
            padding: const EdgeInsets.only(bottom: 12),
            child: SoundCard(
              sound: sound,
              isPlaying: isPlaying,
              showCategory: false,
              showDownloadButton: true,
              isDownloading: isDownloading,
              downloadProgress: viewModel.downloadProgress,
              onPlay: () => _playSound(sound),
              onDownload: () => _downloadSound(sound),
              onFavorite: () => _toggleFavorite(sound),
            ).animate(
              // Only animate new items
              key: ValueKey('anim_${sound.id}'),
              autoPlay: true,
              onComplete: (controller) => controller.dispose(),
            ).fade(
              duration: 300.ms,
              delay: (50 * index).ms,
            ).moveY(
              begin: 20, 
              end: 0,
              duration: 300.ms, 
              delay: (50 * index).ms,
              curve: Curves.easeOutQuad,
            ),
          );
        },
      ),
    );
  }
  
  // Play a sound
  void _playSound(SoundModel sound) {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    viewModel.playSound(sound);
  }
  
  // Download a sound
  Future<void> _downloadSound(SoundModel sound) async {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    final success = await viewModel.downloadSound(sound);
    
    if (mounted) {
      // Hiển thị thông báo dưới dạng SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'download_success'.tr() + ': ${sound.name}'
                : 'download_failed'.tr() + ': ' + 'try_again'.tr(),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  // Toggle favorite status
  void _toggleFavorite(SoundModel sound) {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    viewModel.toggleFavorite(sound);
  }
} 