import 'package:flutter/material.dart';

/// Class containing bilingual messages (English and Vietnamese) for the app
class MessageConstants {
  // Sound playback related messages
  static const Map<String, Map<String, String>> playback = {
    'error': {'en': 'Could not play sound', 'vi': 'Không thể phát âm thanh'},
    'network_error': {
      'en': 'Network error. Please check your connection',
      'vi': 'Lỗi kết nối. Vui lòng kiểm tra lại mạng',
    },
    'cors_error': {
      'en': 'Server access error. This sound may not be available',
      'vi': 'Lỗi truy cập máy chủ. Âm thanh này có thể không khả dụng',
    },
    'not_found': {'en': 'Sound not found', 'vi': 'Không tìm thấy âm thanh'},
  };

  // API and loading related messages
  static const Map<String, Map<String, String>> api = {
    'loading': {'en': 'Loading sounds...', 'vi': 'Đang tải âm thanh...'},
    'error': {'en': 'Error loading sounds', 'vi': 'Lỗi tải âm thanh'},
    'no_results': {'en': 'No sounds found', 'vi': 'Không tìm thấy âm thanh'},
    'try_again': {'en': 'Try again', 'vi': 'Thử lại'},
    'refresh': {'en': 'Refresh', 'vi': 'Làm mới'},
    'category_empty': {
      'en': 'No sounds in this category',
      'vi': 'Không có âm thanh trong danh mục này',
    },
    'try_other_category': {
      'en': 'Try selecting a different category',
      'vi': 'Hãy thử chọn danh mục khác',
    },
  };

  // Download related messages
  static const Map<String, Map<String, String>> download = {
    'success': {
      'en': 'Sound downloaded successfully',
      'vi': 'Tải xuống âm thanh thành công',
    },
    'error': {
      'en': 'Could not download sound',
      'vi': 'Không thể tải xuống âm thanh',
    },
    'in_progress': {'en': 'Downloading...', 'vi': 'Đang tải xuống...'},
    'no_storage': {
      'en': 'Storage permission denied',
      'vi': 'Quyền truy cập bộ nhớ bị từ chối',
    },
    'completed': {'en': 'Download completed', 'vi': 'Tải xuống hoàn tất'},
  };

  // Favorites related messages
  static const Map<String, Map<String, String>> favorites = {
    'added': {'en': 'Added to favorites', 'vi': 'Đã thêm vào yêu thích'},
    'removed': {'en': 'Removed from favorites', 'vi': 'Đã xóa khỏi yêu thích'},
    'empty': {
      'en': 'No favorite sounds yet',
      'vi': 'Chưa có âm thanh yêu thích',
    },
  };

  // Search related messages
  static const Map<String, Map<String, String>> search = {
    'title': {'en': 'Search Sounds', 'vi': 'Tìm Kiếm Âm Thanh'},
    'hint': {'en': 'Enter sound name...', 'vi': 'Nhập tên âm thanh...'},
    'no_results': {
      'en': 'No matching sounds found',
      'vi': 'Không tìm thấy âm thanh phù hợp',
    },
    'cancel': {'en': 'Cancel', 'vi': 'Hủy'},
    'search': {'en': 'Search', 'vi': 'Tìm'},
  };

  // Category names
  static const Map<String, Map<String, String>> categories = {
    'all': {'en': 'All', 'vi': 'Tất cả'},
    'music': {'en': 'Music', 'vi': 'Âm Nhạc'},
    'anime': {'en': 'Anime', 'vi': 'Anime'},
    'game': {'en': 'Game', 'vi': 'Game'},
    'meme': {'en': 'Meme', 'vi': 'Meme'},
    'movie': {'en': 'Movie', 'vi': 'Phim'},
    'sound_effects': {'en': 'Sound Effects', 'vi': 'Hiệu Ứng Âm Thanh'},
    'reactions': {'en': 'Reactions', 'vi': 'Reactions'},
    'interesting': {'en': 'Interesting', 'vi': 'Âm Thanh Thú Vị'},
    'tiktok': {'en': 'TikTok', 'vi': 'TikTok'},
    'trends': {'en': 'Trends', 'vi': 'Trào Lưu'},
    'animal': {'en': 'Animal Sounds', 'vi': 'Tiếng Động Vật'},
    'sounds': {'en': 'Sounds', 'vi': 'Tiếng Kêu'},
  };

  // Helper function to get message in the current locale
  static String getMessage(
    Map<String, Map<String, String>> messageGroup,
    String key, {
    String locale = 'en',
  }) {
    if (messageGroup.containsKey(key)) {
      return messageGroup[key]![locale] ?? messageGroup[key]!['en'] ?? key;
    }
    return key;
  }

  // Helper function to get error message with details
  static String getErrorMessage(String error, {String locale = 'en'}) {
    final baseMessage = getMessage(playback, 'error', locale: locale);

    if (error.contains('CORS') || error.contains('Access')) {
      return getMessage(playback, 'cors_error', locale: locale);
    } else if (error.contains('network') || error.contains('connect')) {
      return getMessage(playback, 'network_error', locale: locale);
    } else if (error.contains('not found') || error.contains('404')) {
      return getMessage(playback, 'not_found', locale: locale);
    }

    // If no specific error identified, return general message with details
    return '$baseMessage: $error';
  }
}
