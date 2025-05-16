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
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/sound_viewmodel.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'utils/app_config.dart';
import 'utils/toast_helper.dart';
import 'widgets/splash_screen.dart';
import 'package:audioplayers/audioplayers.dart';

// Cờ debug - đặt thành true để sử dụng màn hình debug
const bool USE_DEBUG_MODE = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  // Khởi tạo AudioPlayer cho phát âm thanh từ URL
  AudioCache.instance = AudioCache(prefix: '');
  
  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Request permissions
  final permissionsService = PermissionsService();
  await permissionsService.requestAllPermissions();
  
  // Initialize services
  final soundService = SoundService();
  final favoriteService = FavoriteService();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    EasyLocalization(
      supportedLocales: LocalizationService.supportedLocales,
      path: LocalizationService.path,
      fallbackLocale: LocalizationService.fallbackLocale,
      child: MultiProvider(
        providers: [
          // Basic services
          ChangeNotifierProvider<SoundService>(create: (_) => soundService),
          ChangeNotifierProvider<PreferencesService>(create: (_) => PreferencesService()),
          
          // Localization service
          ChangeNotifierProvider<LocalizationService>(create: (_) {
            final service = LocalizationService();
            service.init();
            return service;
          }),
          
          // ViewModels
          ChangeNotifierProvider<ThemeViewModel>(create: (_) => ThemeViewModel()),
          
          // MyInstants service (not a ChangeNotifier)
          Provider<MyInstantsService>(create: (_) => MyInstantsService()),
          
          // Favorite service
          Provider(create: (_) => favoriteService),
          
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Basic services
        ChangeNotifierProvider<SoundService>(create: (_) => SoundService()),
        ChangeNotifierProvider<PreferencesService>(create: (_) => PreferencesService()),
        
        // Localization service
        ChangeNotifierProvider<LocalizationService>(create: (_) {
          final service = LocalizationService();
          service.init();
          return service;
        }),
        
        // ViewModels
        ChangeNotifierProvider<ThemeViewModel>(create: (_) => ThemeViewModel()),
        
        // MyInstants service (not a ChangeNotifier)
        Provider<MyInstantsService>(create: (_) => MyInstantsService()),
        
        // Favorite service
        Provider<FavoriteService>(create: (_) => FavoriteService()),
        
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
    );
  }
}

class TrollApp extends StatelessWidget {
  const TrollApp({super.key});

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
