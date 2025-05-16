import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';

import '../models/sound_model.dart';
import '../viewmodels/sound_viewmodel.dart';
import '../widgets/sound_card.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/toast_helper.dart';
import '../utils/download_helper.dart';
import '../services/keyboard_service.dart';
import '../widgets/search_field.dart';
import '../widgets/search_results.dart';
import '../widgets/search_empty_state.dart';
import '../widgets/search_loading.dart';
import '../widgets/search_no_results.dart';
import '../utils/keyboard_utils.dart';
import '../utils/log_utils.dart';
import '../widgets/network_error_state.dart';
import '../services/connectivity_service.dart';

/// Tag for logging
const String _logTag = 'SearchScreen';

/// Màn hình tìm kiếm âm thanh online - đã tối ưu và modular
class SearchScreen extends StatefulWidget {
  final bool fromBottomNav;
  
  const SearchScreen({
    Key? key,
    this.fromBottomNav = false,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  List<SoundModel> _searchResults = [];
  bool _isLoading = false;
  String _lastSearchQuery = '';
  String? _currentPlayingSoundId;
  
  // Debounce timer cho tìm kiếm
  Timer? _debounceTimer;
  
  // Timer để ẩn bàn phím sau một khoảng thời gian
  Timer? _keyboardHideTimer;
  
  // Lịch sử tìm kiếm
  final List<String> _recentSearches = [];
  final int _maxRecentSearches = 5;
  
  // Gợi ý tìm kiếm phổ biến
  final List<String> _popularSearches = [
    'nature',
    'music',
    'animals',
    'funny',
    'notification'
  ];
  
  // Animation controllers
  bool _showSearchOptions = false;
  final GlobalKey _searchFieldKey = GlobalKey();
  
  // Kiểm soát việc hủy widget
  bool _isDisposed = false;

  // Biến đánh dấu đã xử lý focus change để tránh vòng lặp
  bool _isHandlingFocusChange = false;

  // Tracking network state
  bool _isOffline = false;
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addObserver(this);
    
    // Set up focus listener 
    _searchFocusNode.addListener(_simpleFocusListener);
    
    // Set up connectivity listener
    _connectivitySubscription = ConnectivityService().connectionStatus.listen(_handleConnectivityChange);
    
    // Initial network state check
    _isOffline = !ConnectivityService().isConnected;
    
    // Auto focus when screen opens from bottom nav
    if (widget.fromBottomNav) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted && !_isHandlingFocusChange) {
          _isHandlingFocusChange = true;
          FocusScope.of(context).requestFocus(_searchFocusNode);
          _isHandlingFocusChange = false;
        }
      });
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final soundViewModel = Provider.of<SoundViewModel>(context);
    _currentPlayingSoundId = soundViewModel.currentPlayingSoundId;
    
    // Check network state from ViewModel
    if (_isOffline != !soundViewModel.hasNetworkConnection) {
      setState(() {
        _isOffline = !soundViewModel.hasNetworkConnection;
      });
    }
    
    // Cập nhật trạng thái kết quả tìm kiếm
    _setupSearchResults();
    
    _checkForSavedSearchResults();
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    
    _stopCurrentSound();
    
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    viewModel.manageSoundCache();
    
    _debounceTimer?.cancel();
    _keyboardHideTimer?.cancel();
    _connectivitySubscription?.cancel();
    _searchFocusNode.removeListener(_simpleFocusListener);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Khi app vào background, ẩn bàn phím và hủy timer
    if (state != AppLifecycleState.resumed) {
      _cancelKeyboardHideTimer();
      _searchFocusNode.unfocus();
    }
  }
  
  // Simple focus listener để tránh logic phức tạp
  void _simpleFocusListener() {
    // Tránh xử lý đệ quy
    if (_isHandlingFocusChange) return;
    
    _isHandlingFocusChange = true;
    
    // Khi textfield được focus, set timer để tự động ẩn sau 5 giây
    if (_searchFocusNode.hasFocus) {
      _startKeyboardHideTimer();
    } else {
      _cancelKeyboardHideTimer();
    }
    
    _isHandlingFocusChange = false;
  }
  
  // Đơn giản hóa timer để ẩn bàn phím
  void _startKeyboardHideTimer() {
    _cancelKeyboardHideTimer();
    
    _keyboardHideTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && !_isHandlingFocusChange) {
        _isHandlingFocusChange = true;
        FocusScope.of(context).unfocus();
        _isHandlingFocusChange = false;
      }
    });
  }
  
  void _cancelKeyboardHideTimer() {
    if (_keyboardHideTimer != null) {
      _keyboardHideTimer!.cancel();
      _keyboardHideTimer = null;
    }
  }
  
  @override 
  void didUpdateWidget(SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Chỉ xử lý hiển thị bàn phím khi chuyển từ tab khác đến tab Search
    if (!oldWidget.fromBottomNav && widget.fromBottomNav && mounted) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_isHandlingFocusChange) {
          _isHandlingFocusChange = true;
          FocusScope.of(context).requestFocus(_searchFocusNode);
          _isHandlingFocusChange = false;
        }
      });
    }
  }
  
  // Load lịch sử tìm kiếm
  void _loadRecentSearches() {
    // Trong thực tế, bạn sẽ load từ local storage
    setState(() {
      _recentSearches.clear();
    });
  }
  
  // Lưu tìm kiếm gần đây
  void _saveRecentSearch(String query) {
    if (query.isEmpty) return;
    
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches.removeLast();
      }
    });
  }
  
  // Kiểm tra kết quả tìm kiếm đã lưu
  void _checkForSavedSearchResults() {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    final savedResults = viewModel.getRecentSearchResults();
    
    if (savedResults.isNotEmpty && _searchResults.isEmpty) {
      // Có thể khôi phục kết quả nếu cần
    }
  }
  
  // Dừng âm thanh đang phát
  void _stopCurrentSound() {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    viewModel.stopSound();
  }

  // Xử lý thay đổi text với debounce
  void _onSearchTextChanged(String text) {
    // Reset timer ẩn bàn phím mỗi khi có nhập liệu mới
    if (_searchFocusNode.hasFocus) {
      _startKeyboardHideTimer();
    }
    
    if ((text.isEmpty && _searchController.text.isNotEmpty) || 
        (text.isNotEmpty && _searchController.text.isEmpty)) {
      if (!_isDisposed && mounted) setState(() {});
    }
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (text.length >= 2 && !_isDisposed && mounted) {
        _searchSounds(text);
      }
    });
  }

  // Xử lý gửi tìm kiếm
  void _onSubmitSearch(String query) {
    _debounceTimer?.cancel();
    // Ẩn bàn phím khi người dùng chủ động gửi tìm kiếm
    FocusScope.of(context).unfocus();
    _searchSounds(query);
  }

  // Search for sounds with debounce
  Future<void> _searchSounds(String query) async {
    // Check if we're offline first
    if (_isOffline) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = [];
        });
      }
      return;
    }
    
    // Don't search if query is empty
    if (query.isEmpty) {
      return;
    }
    
    // Don't repeat the same search if results already exist and query is the same
    if (query == _lastSearchQuery && _searchResults.isNotEmpty) {
      return;
    }
    
    if (!_isDisposed && mounted) {
      setState(() {
        _isLoading = true;
        _lastSearchQuery = query;
      });
    
      _saveRecentSearch(query);
    }
    
    try {
      final viewModel = Provider.of<SoundViewModel>(context, listen: false);
      final results = await viewModel.search(query);
      
      if (!_isDisposed && mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
        
        // Cache top results in the viewModel for reuse
        if (results.isNotEmpty) {
          for (int i = 0; i < results.length && i < 5; i++) {
            viewModel.addSoundToOnlineSounds(results[i]);
          }
          viewModel.updateAfterSearch();
        }
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        _showErrorSnackbar('search_failed'.tr());
      }
    }
  }
  
  // Hiển thị thông báo lỗi
  void _showErrorSnackbar(String message) {
    if (!_isDisposed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  // Hiển thị thông báo thành công
  void _showSuccessSnackbar(String message, {Widget? action}) {
    if (!_isDisposed && mounted) {
      final theme = Theme.of(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.colorScheme.primary,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
          action: action != null ? SnackBarAction(
            label: 'stop'.tr(),
            textColor: Colors.white,
            onPressed: () {
              final viewModel = Provider.of<SoundViewModel>(context, listen: false);
              viewModel.stopSound();
            },
          ) : null,
        ),
      );
    }
  }
  
  // Phát âm thanh
  void _playSound(SoundModel sound) {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    final theme = Theme.of(context);
    
    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: theme.cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'play_preparing'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  sound.name,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ).animate().fade(duration: 300.ms),
          ),
        ),
      ),
    );
    
    // Phát âm thanh
    viewModel.playSound(sound).then((success) {
      if (!_isDisposed && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      
        if (success) {
          setState(() {
            _currentPlayingSoundId = sound.id;
          });
          
          _showSuccessSnackbar(
            'play_now'.tr() + ': ${sound.name}',
            action: SnackBarAction(
              label: 'stop'.tr(),
              textColor: Colors.white,
              onPressed: () {
                viewModel.stopSound();
              },
            ),
          );
        } else {
          _showErrorSnackbar('play_error'.tr());
        }
      }
    }).catchError((error) {
      if (!_isDisposed && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showErrorSnackbar('play_error'.tr());
      }
    });
  }
  
  // Tải xuống âm thanh
  Future<void> _downloadSound(SoundModel sound) async {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    
    try {
      // Hiển thị dialog tiến trình tải xuống
      DownloadHelper.showDownloadProgress(
        context: context,
        title: sound.name,
        downloadTask: () async {
          return await viewModel.downloadSound(sound);
        },
      );
      
      // Cập nhật lại danh sách kết quả tìm kiếm để hiển thị trạng thái mới
      if (mounted) {
        setState(() {
          final index = _searchResults.indexWhere((s) => s.id == sound.id);
          if (index != -1) {
            _searchResults[index] = _searchResults[index].copyWith(isLocal: true);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('download_failed'.tr());
      }
    }
  }
  
  // Thêm/xóa yêu thích
  void _toggleFavorite(SoundModel sound) {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    viewModel.toggleFavorite(sound);
    
    if (!_isDisposed && mounted) {
      setState(() {
        // Cập nhật trạng thái yêu thích trong danh sách kết quả
        final index = _searchResults.indexWhere((s) => s.id == sound.id);
        if (index != -1) {
          final isFavorite = viewModel.favoriteSounds.any((s) => s.id == sound.id);
          _searchResults[index] = _searchResults[index].copyWith(isFavorite: isFavorite);
        }
      });
      
      final isFavorite = viewModel.favoriteSounds.any((s) => s.id == sound.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? 'favorite_added'.tr() : 'favorite_removed'.tr()
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isFavorite ? Colors.pink : Colors.grey,
        ),
      );
    }
  }

  void _setupSearchResults() {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    
    // Cập nhật trạng thái yêu thích cho các kết quả tìm kiếm
    if (_searchResults.isNotEmpty) {
      final updatedResults = _searchResults.map((sound) {
        // Kiểm tra trạng thái yêu thích từ viewModel
        final isFavorite = viewModel.favoriteSounds.any((s) => s.id == sound.id);
        // Kiểm tra trạng thái đã tải về
        final isLocal = viewModel.isLocalSound(sound.id);
        
        // Cập nhật cả hai trạng thái
        return sound.copyWith(
          isFavorite: isFavorite,
          isLocal: isLocal,
        );
      }).toList();
      
      // Cập nhật danh sách kết quả nếu có thay đổi
      bool needsUpdate = false;
      for (int i = 0; i < updatedResults.length; i++) {
        if (updatedResults[i].isFavorite != _searchResults[i].isFavorite || 
            updatedResults[i].isLocal != _searchResults[i].isLocal) {
          needsUpdate = true;
          break;
        }
      }
      
      if (needsUpdate) {
        setState(() {
          _searchResults = updatedResults;
        });
      }
    }
  }

  // Handle connectivity changes
  void _handleConnectivityChange(bool isConnected) {
    if (_isOffline != !isConnected) {
      setState(() {
        _isOffline = !isConnected;
      });
      
      // If connection restored and we have a query, retry search
      if (isConnected && _searchController.text.isNotEmpty) {
        _searchSounds(_searchController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SoundViewModel>(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'search'.tr(),
        elevation: 0,
        showBackButton: !widget.fromBottomNav,
        centerTitle: true,
        leading: widget.fromBottomNav ? null : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        showThemeToggle: true,
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchTextChanged,
              onSubmitted: _onSubmitSearch,
              onTap: () {
                if (_searchFocusNode.hasFocus) {
                  _startKeyboardHideTimer();
                }
              },
              onClear: () {
                _searchController.clear();
                _onSearchTextChanged('');
              },
              autofocus: widget.fromBottomNav,
              disabled: _isOffline, // Disable search when offline
              hint: 'search_hint'.tr(),
            ),
          ),
          
          // Main content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent() {
    // Show offline state if network is unavailable
    if (_isOffline) {
      return NetworkErrorState(
        onRetry: () async {
          // Manually check connectivity
          await ConnectivityService().checkRealConnectivity();
          
          // If connected now, retry search if we have a query
          if (ConnectivityService().isConnected && 
              _searchController.text.isNotEmpty && 
              mounted) {
            setState(() {
              _isOffline = false;
            });
            _searchSounds(_searchController.text);
          }
        },
      );
    }
    
    // Loading indicator
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // Empty text field - show empty state
    if (_searchController.text.isEmpty) {
      return _buildEmptyState();
    }
    
    // Has search query but no results
    if (_searchController.text.isNotEmpty && _searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'no_results'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'try_different_keywords'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Display search results
    return SearchResults(
      results: _searchResults, 
      onSoundTap: _handleSoundTap,
      currentPlayingId: _currentPlayingSoundId,
      searchQuery: _lastSearchQuery,
    );
  }
  
  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'search_instruction'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
  
  void _handleSoundTap(SoundModel sound) {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    
    // Play or stop sound
    if (_currentPlayingSoundId == sound.id) {
      viewModel.stopSound();
    } else {
      viewModel.playSound(sound);
    }
    
    setState(() {
      _currentPlayingSoundId = viewModel.currentPlayingSoundId;
    });
  }
} 