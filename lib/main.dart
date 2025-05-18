import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/app_container.dart';
import 'screens/onboarding_view.dart';
import 'screens/debug_screen.dart';
import 'services/permissions_service.dart';
import 'services/sound_service.dart';
import 'services/myinstants_service.dart';
import 'services/preferences_service.dart';
import 'services/localization_service.dart';
import 'services/favorite_service.dart';
import 'services/keyboard_service.dart';
import 'services/connectivity_service.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/sound_viewmodel.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'utils/app_config.dart';
import 'utils/toast_helper.dart';
import 'utils/connectivity_dialog.dart';
import 'widgets/splash_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'generated/codegen_loader.g.dart';
import 'dart:async';

/**
 * Các cải tiến để giảm lag và cải thiện hiệu suất:
 * 1. Tối ưu quá trình khởi động bằng cách hoãn các tác vụ nặng
 * 2. Giảm thiểu hoạt ảnh và hiệu ứng đồ họa phức tạp trong splash screen
 * 3. Giảm số lượng particle và các hiệu ứng vẽ nặng
 * 4. Sử dụng kỹ thuật RepaintBoundary để cô lập các vùng vẽ lại
 * 5. Phân tách quá trình khởi tạo thành các giai đoạn: cần thiết ngay và trì hoãn
 * 6. Yêu cầu quyền truy cập trong nền sau khi UI đã hiển thị
 * 7. Sử dụng lazy loading cho các service không cần thiết ngay lập tức
 */

// Cờ debug - đặt thành true để sử dụng màn hình debug
const bool USE_DEBUG_MODE = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  // Configure system UI immediately for smoother startup
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set preferred orientations early
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize audio cache with deferred setup
  AudioCache.instance = AudioCache(prefix: '');
  
  // Create essential services for immediate startup
  final preferencesService = PreferencesService();
  final soundService = SoundService();
  final connectivityService = ConnectivityService();
  connectivityService.initialize();
  
  // Start the app with minimal initialization
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      assetLoader: CodegenLoader(),
      child: MultiProvider(
        providers: [
          // Basic services
          ChangeNotifierProvider<SoundService>(create: (_) => soundService),
          ChangeNotifierProvider<PreferencesService>(
            create: (_) => preferencesService,
          ),
          
          // Localization service
          ChangeNotifierProvider<LocalizationService>(create: (_) {
            final service = LocalizationService();
            // Defer initialization
            Future.microtask(() => service.init());
            return service;
          }),
          
          // ViewModels
          ChangeNotifierProvider<ThemeViewModel>(
            create: (_) => ThemeViewModel(),
          ),
          
          // MyInstants service (not a ChangeNotifier)
          Provider<MyInstantsService>(create: (_) => MyInstantsService()),
          
          // Connectivity service
          Provider<ConnectivityService>(
            create: (_) => connectivityService,
          ),
          
          // Favorite service - lazy initialization
          Provider<FavoriteService>(
            create: (_) => FavoriteService(),
            lazy: true,
          ),
          
          // SoundViewModel that depends on other services
          ChangeNotifierProxyProvider3<SoundService, MyInstantsService, PreferencesService, SoundViewModel>(
            create: (ctx) => SoundViewModel(
              soundService: ctx.read<SoundService>(),
              myInstantsService: ctx.read<MyInstantsService>(),
              preferencesService: ctx.read<PreferencesService>(),
            ),
            update: (ctx, soundService, myInstantsService, preferencesService, previousViewModel) => 
              previousViewModel ?? SoundViewModel(
                soundService: soundService,
                myInstantsService: myInstantsService,
                preferencesService: preferencesService,
              ),
          ),
        ],
        child: const TrollApp(),
      ),
    ),
  );
  
  // Run heavy initialization tasks after UI is rendered
  Timer(const Duration(milliseconds: 100), () async {
    final permissionsService = PermissionsService();
    // Request permissions in background
    unawaited(permissionsService.requestAllPermissions());
    
    // Check storage permission
    unawaited(Permission.storage.request());
  });
}

class TrollApp extends StatefulWidget {
  const TrollApp({super.key});
  
  @override
  State<TrollApp> createState() => _TrollAppState();
}

class _TrollAppState extends State<TrollApp> with WidgetsBindingObserver {
  bool _isConnectivityListenerRegistered = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Defer connectivity listener setup to avoid startup lag
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupConnectivityListener();
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isConnectivityListenerRegistered && mounted) {
      _setupConnectivityListener();
    }
  }
  
  void _setupConnectivityListener() {
    if (_isConnectivityListenerRegistered || !mounted) return;
    
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    connectivityService.connectionStatus.listen((isConnected) {
      if (!mounted) return;
      
      if (!isConnected) {
        // Hiển thị thông báo mất kết nối
        ConnectivityDialog.showNoConnectionMessage(context);
      } else {
        // Ẩn thông báo mất kết nối nếu đang hiển thị
        ConnectivityDialog.hideNoConnectionMessage();
      }
    });
    
    _isConnectivityListenerRegistered = true;
  }
  
  @override
  Widget build(BuildContext context) {
    final preferencesService = Provider.of<PreferencesService>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    
    // Sync view model with preferences
    themeViewModel.setTheme(preferencesService.darkModeEnabled);
    
    // Get current theme data
    final isDarkMode = themeViewModel.isDarkMode;
    final themeData = themeViewModel.themeData;
    
    // Update system UI based on theme brightness
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
    
    // Determine the initial route based on onboarding status
    final Widget initialScreen = preferencesService.onboardingCompleted
        ? const AppContainer()
        : const OnboardingView();
    
    return MaterialApp(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: themeData,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      navigatorKey: AppConfig.navigatorKey,
      builder: (context, child) {
        // Khởi tạo ToastHelper
        ToastHelper().init(context);
        
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(
              physics: const BouncingScrollPhysics(),
              overscroll: false,
            ),
            child: child!,
          ),
        );
      },
      home: USE_DEBUG_MODE 
          ? const DebugScreen() 
          : SplashScreen(nextScreen: initialScreen),
    );
  }
}
