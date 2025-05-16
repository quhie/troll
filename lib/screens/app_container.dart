import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import '../services/preferences_service.dart';
import '../services/keyboard_service.dart';
import '../viewmodels/sound_viewmodel.dart';
import '../widgets/adaptive_navbar.dart';
import '../utils/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

/// Main container for the app that handles navigation
class AppContainer extends StatefulWidget {
  const AppContainer({Key? key}) : super(key: key);

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isNavExpanded = false;
  late AnimationController _animationController;
  
  // Use the NavDestination from adaptive_navbar.dart
  late List<NavDestination> _destinations;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Destinations will be initialized in didChangeDependencies
    _initializeDestinations();
  }
  
  // Khởi tạo destinations với các key ngôn ngữ
  void _initializeDestinations() {
    _destinations = [
      NavDestination(
        label: 'nav_home'.tr(),
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        badge: null,
      ),
      NavDestination(
        label: 'nav_search'.tr(),
        icon: Icons.search,
        selectedIcon: Icons.search,
        badge: null,
      ),
      NavDestination(
        label: 'nav_settings'.tr(),
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        badge: null,
      ),
    ];
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Cập nhật destinations khi ngôn ngữ thay đổi
    _initializeDestinations();
    
    // Rebuild UI nếu đang trong trạng thái mounted
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNavDestinationSelected(int index) {
    // Only update if we're changing tabs
    if (index != _currentIndex) {
      // Ẩn bàn phím khi chuyển tab
      // KeyboardService.hideKeyboard();
      
      setState(() {
        _currentIndex = index;
        // Auto-collapse nav on mobile when changing pages
        if (_isNavExpanded && MediaQuery.of(context).size.width < 600) {
          _isNavExpanded = false;
        }
      });
      
      // Đảm bảo bàn phím bị ẩn hoàn toàn trước khi chuyển tab
      FocusScope.of(context).unfocus();
    }
  }
  
  void _toggleNavExpanded() {
    setState(() {
      _isNavExpanded = !_isNavExpanded;
      if (_isNavExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final preferencesService = Provider.of<PreferencesService>(context);
    final soundViewModel = Provider.of<SoundViewModel>(context);
    final isDarkMode = preferencesService.darkModeEnabled;
    
    // Update system UI to match theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDarkMode 
            ? AppTheme.darkBackgroundColor 
            : AppTheme.lightBackgroundColor,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
    
    return WillPopScope(
      // Đảm bảo xử lý bàn phím khi back/thoát màn hình
      onWillPop: () async {
        // Ẩn bàn phím trước khi back
        // KeyboardService.hideKeyboard();
        return true;
      },
      child: GestureDetector(
        // Ẩn bàn phím khi tap ngoài các widget có focus
        // onTap: () => KeyboardService.hideKeyboardWithContext(context),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          body: Row(
            children: [
              // Navigation rail for large screens
              if (!isSmallScreen)
                AdaptiveNavbar(
                  selectedIndex: _currentIndex,
                  destinations: _destinations,
                  isExpanded: _isNavExpanded,
                  onDestinationSelected: _onNavDestinationSelected,
                  onExpandToggle: _toggleNavExpanded,
                  animationController: _animationController,
                ),
                
              // Main content area
              Expanded(
                child: Column(
                  children: [
                    // Main content view
                    Expanded(
                      child: _buildCurrentScreen(),
                    ),
                    
                    // Bottom sound player for small screens - show only if we have sounds
                    if (soundViewModel.currentPlayingSoundId != null)
                      Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Play/Pause button
                            IconButton(
                              icon: Icon(
                                Icons.stop_circle,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () {
                                soundViewModel.stopSound();
                              },
                            ),
                            
                            // Now playing text
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'Now Playing',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          // Bottom navigation for small screens
          bottomNavigationBar: isSmallScreen ? Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: BottomNavigationBar(
                elevation: 8,
                currentIndex: _currentIndex,
                onTap: _onNavDestinationSelected,
                items: _destinations.map((destination) => BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: destination.badge != null,
                    label: destination.badge?.label,
                    child: Icon(_currentIndex == _destinations.indexOf(destination) 
                        ? destination.selectedIcon 
                        : destination.icon),
                  ),
                  label: destination.label,
                )).toList(),
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: true,
              ),
            ),
          ) : null,
        ),
      ),
    );
  }

  // Xây dựng màn hình hiện tại dựa trên index
  Widget _buildCurrentScreen() {
    
    // Cách tiếp cận sử dụng PageStorage để lưu trữ trạng thái
    final pageStorageBucket = PageStorageBucket();
    
    switch (_currentIndex) {
      case 0:
        return PageStorage(
          bucket: pageStorageBucket,
          child: const HomeScreen(key: PageStorageKey('home_screen')),
        );
        
      case 1:
        // SearchScreen - Đây là trường hợp đặc biệt cần xử lý riêng
        // Không sử dụng UniqueKey để tránh tạo mới màn hình liên tục
        return PageStorage(
          bucket: pageStorageBucket,
          child: SearchScreen(
            key: const ValueKey('search_screen'), // Sử dụng ValueKey cố định
            fromBottomNav: true,
          ),
        );
        
      case 2:
        return PageStorage(
          bucket: pageStorageBucket,
          child: const SettingsScreen(key: PageStorageKey('settings_screen')),
        );
        
      default:
        return const HomeScreen();
    }
  }
} 