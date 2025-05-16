import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_config.dart';

/// Service to handle app localization
class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  // Supported locales
  static final List<Locale> supportedLocales = [
    const Locale('en'),
    const Locale('vi'),
  ];
  
  // Default locale
  static const Locale fallbackLocale = Locale('en');
  
  // Path to language files
  static const String path = 'assets/translations';
  
  // Current app locale
  Locale _currentLocale = fallbackLocale;
  
  // Getter for current locale
  Locale get currentLocale => _currentLocale;
  
  /// Initialize the service
  Future<void> init() async {
    await loadSavedLocale();
  }
  
  /// Load the saved locale from SharedPreferences
  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null && languageCode.isNotEmpty) {
        _currentLocale = Locale(languageCode);
      }
      
      notifyListeners();
    } catch (e) {
      // Error loading saved locale
    }
  }
  
  /// Change the app locale
  Future<void> changeLocale(BuildContext context, Locale newLocale) async {
    try {
      // Make sure the locale is supported
      if (!supportedLocales.contains(newLocale) && 
          !supportedLocales.any((locale) => locale.languageCode == newLocale.languageCode)) {
        return;
      }
      
      // Update locale through EasyLocalization
      await context.setLocale(newLocale);
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, newLocale.languageCode);
      
      // Update current locale
      _currentLocale = newLocale;
      
      // Force UI update
      forceRebuild();
      
      notifyListeners();
    } catch (e) {
      // Error changing locale
    }
  }
  
  /// Force rebuild của toàn bộ ứng dụng khi đổi ngôn ngữ
  void forceRebuild() {
    try {
      // Lấy context từ navigatorKey của ứng dụng
      final context = AppConfig.navigatorKey.currentContext;
      if (context != null) {
        // Tìm tất cả các StatefulWidget trong cây widget và gọi setState
        _rebuildAllChildren(context);
      }
    } catch (e) {
      // Error forcing rebuild
    }
  }
  
  /// Rebuild tất cả các widget con
  void _rebuildAllChildren(BuildContext context) {
    try {
      void rebuild(Element element) {
        element.markNeedsBuild();
        element.visitChildren(rebuild);
      }
      
      (context as Element).visitChildren(rebuild);
    } catch (e) {
      // Error rebuilding children
    }
  }
  
  /// Get language name based on locale
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return 'English';
    }
  }
  
  /// Get all available languages
  List<Map<String, dynamic>> get availableLanguages {
    return supportedLocales.map((locale) {
      return {
        'locale': locale,
        'name': getLanguageName(locale),
      };
    }).toList();
  }
} 