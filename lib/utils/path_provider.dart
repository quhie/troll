import 'package:flutter/foundation.dart';
import 'dart:io';

/// Utility class for handling file paths in the app
class PathProvider {
  
  /// Format a sound path for use with AudioPlayer
  /// Ensures the path is correctly formatted for the asset source
  static String formatSoundPath(String path) {
    // If path is a URL, return it as is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // If path is a device file path, return it as is
    if (path.startsWith('/')) {
      // Check if the file exists
      final file = File(path);
      if (file.existsSync()) {
        return path;
      }
    }
    
    // If path already contains 'assets/', remove it as AssetSource adds it
    if (path.startsWith('assets/')) {
      final formattedPath = path.substring(7); // Remove 'assets/' prefix
      return formattedPath;
    }
    
    // For any other path (likely already without 'assets/')
    return path;
  }
  
  /// Get a properly formatted asset path for any file
  static String getAssetPath(String path) {
    // If path doesn't start with 'assets/', add it
    if (!path.startsWith('assets/')) {
      return 'assets/$path';
    }
    return path;
  }
  
  /// Extract category from a sound path
  /// Example: assets/sounds/phone/ringtone.mp3 -> phone
  static String getCategoryFromPath(String path) {
    try {
      final parts = path.split('/');
      
      // Look for the category part which should be after "sounds" directory
      if (parts.length >= 3) {
        for (int i = 0; i < parts.length - 1; i++) {
          if (parts[i] == 'sounds' && i + 1 < parts.length) {
            return parts[i + 1];
          }
        }
      }
      
      // Default to 'unknown' if there's an error
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
  
  /// Check if a file exists at the given path
  static Future<bool> fileExists(String path) async {
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
} 