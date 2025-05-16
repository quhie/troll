import 'package:flutter/foundation.dart';

/// Utility class for string operations
class StringUtils {
  /// Format a sound file name to display name
  /// Example: "534387__autellaem__bruh-sound-effect-1" -> "Bruh Sound Effect 1"
  /// Example: "emergency_meeting" -> "Emergency Meeting"
  static String formatSoundName(String fileName) {
    try {
      // Remove numbers with underscores that are common in sound libraries
      // Pattern: "534387__autellaem__bruh-sound-effect-1" -> "bruh-sound-effect-1"
      var name = fileName;
      final regexNumbersWithUnderscores = RegExp(r'^\d+__[^_]+__');
      if (regexNumbersWithUnderscores.hasMatch(name)) {
        name = name.replaceFirst(regexNumbersWithUnderscores, '');
      }

      // Replace underscores and hyphens with spaces
      name = name.replaceAll('_', ' ').replaceAll('-', ' ');

      // Split into words and capitalize each word
      final words = name.split(' ');
      final capitalizedWords =
          words.map((word) {
            if (word.isEmpty) return '';
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          }).toList();

      // Join back together
      return capitalizedWords.join(' ');
    } catch (e) {
      // Xử lý lỗi định dạng tên âm thanh
      return 'Sound Effect';
    }
  }
}
