import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Central configuration file for app-wide settings
class AppConfig {
  // App information
  static const String appName = "Troll Sounds";
  static const String appVersion = "2.0.0";

  // Feature flags
  static const bool enableAnalytics = false;
  static const bool enableErrorReporting = true;
  static const bool enableHapticFeedback = true;

  // Performance settings
  static const bool enableBackgroundBlur = true;
  static const bool enableAnimations = true;
  static const double animationSpeed = 1.0; // 1.0 = normal speed

  // Device capabilities
  static bool get isIOS =>
      Theme.of(navigatorKey.currentContext!).platform == TargetPlatform.iOS;
  static bool get isAndroid =>
      Theme.of(navigatorKey.currentContext!).platform == TargetPlatform.android;

  // Asset paths configuration
  static const String assetBasePath = "assets/";
  static const String soundsPath = "${assetBasePath}sounds/";
  static const String imagesPath = "${assetBasePath}images/";

  // Accessibility
  static const bool enableReducedMotion = false;
  static const bool enableHighContrast = false;
  static const bool enableLargeText = false;

  // Global app navigator key for accessing context anywhere
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // System UI configuration
  static void configureSystemUI() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
}
