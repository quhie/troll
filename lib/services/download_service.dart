import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../models/sound_model.dart';

/// Status of a download operation
enum DownloadStatus { notStarted, inProgress, completed, failed }

/// Download progress event
class DownloadProgress {
  final String id;
  final DownloadStatus status;
  final double progress;
  final String? filePath;
  final String? error;

  DownloadProgress({
    required this.id,
    required this.status,
    this.progress = 0.0,
    this.filePath,
    this.error,
  });
}

/// Service for downloading and managing sound files
class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;

  // Private constructor
  DownloadService._internal();

  // Download progress stream controller
  final _downloadProgressController =
      StreamController<DownloadProgress>.broadcast();
  Stream<DownloadProgress> get downloadProgressStream =>
      _downloadProgressController.stream;

  // Active downloads tracking
  final Map<String, DownloadStatus> _activeDownloads = {};
  final Map<String, String> _downloadedFilePaths = {};

  /// Check if storage permission is granted
  Future<bool> _checkStoragePermission() async {
    if (Platform.isIOS) {
      // iOS doesn't require explicit storage permission since iOS 13
      return true;
    } else {
      // For Android, we need storage permission
      final status = await Permission.storage.status;
      if (status.isGranted) {
        return true;
      } else {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
    }
  }

  /// Get the download directory
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isIOS) {
      // For iOS, we use the documents directory
      return await getApplicationDocumentsDirectory();
    } else {
      // For Android, we use the external storage directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not access external storage directory');
      }

      // Create a subdirectory for sounds if it doesn't exist
      final soundsDir = Directory('${directory.path}/sounds');
      if (!await soundsDir.exists()) {
        await soundsDir.create(recursive: true);
      }

      return soundsDir;
    }
  }

  /// Download a sound file from a URL
  Future<String?> downloadSound(SoundModel sound) async {
    final id = sound.id;

    // Skip if already downloading
    if (_activeDownloads[id] == DownloadStatus.inProgress) {
      return null;
    }

    // Return cached file if already downloaded
    if (_downloadedFilePaths.containsKey(id)) {
      final file = File(_downloadedFilePaths[id]!);
      if (await file.exists()) {
        return _downloadedFilePaths[id];
      }
    }

    // Check permissions
    final hasPermission = await _checkStoragePermission();
    if (!hasPermission) {
      _updateProgress(
        id: id,
        status: DownloadStatus.failed,
        error: 'Storage permission denied',
      );
      return null;
    }

    try {
      // Mark as in progress
      _activeDownloads[id] = DownloadStatus.inProgress;
      _updateProgress(id: id, status: DownloadStatus.inProgress);

      // Get download directory
      final downloadDir = await _getDownloadDirectory();

      // Create a safe filename
      final fileName = _sanitizeFileName('${sound.name}.mp3');
      final filePath = '${downloadDir.path}/$fileName';

      // Get the file from URL
      final uri = Uri.parse(sound.soundPath);
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'Mozilla/5.0'},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download sound: HTTP ${response.statusCode}',
        );
      }

      // Write to file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Update status and cache the path
      _activeDownloads[id] = DownloadStatus.completed;
      _downloadedFilePaths[id] = filePath;
      _updateProgress(
        id: id,
        status: DownloadStatus.completed,
        progress: 1.0,
        filePath: filePath,
      );

      return filePath;
    } catch (e) {
      // Error downloading sound
      throw Exception('Download failed: $e');
    }
  }

  /// Check if a sound is already downloaded
  Future<bool> isDownloaded(String soundId) async {
    if (_downloadedFilePaths.containsKey(soundId)) {
      final file = File(_downloadedFilePaths[soundId]!);
      return await file.exists();
    }
    return false;
  }

  /// Get the local file path for a downloaded sound
  String? getDownloadedFilePath(String soundId) {
    return _downloadedFilePaths[soundId];
  }

  /// Get the current status of a download
  DownloadStatus getDownloadStatus(String soundId) {
    return _activeDownloads[soundId] ?? DownloadStatus.notStarted;
  }

  /// Delete a downloaded sound
  Future<bool> deleteDownloadedSound(String soundId) async {
    if (_downloadedFilePaths.containsKey(soundId)) {
      try {
        final file = File(_downloadedFilePaths[soundId]!);
        if (await file.exists()) {
          await file.delete();
        }
        _downloadedFilePaths.remove(soundId);
        _activeDownloads.remove(soundId);
        return true;
      } catch (e) {
        // Error deleting sound
        return false;
      }
    }
    return false;
  }

  /// Update download progress and broadcast event
  void _updateProgress({
    required String id,
    required DownloadStatus status,
    double progress = 0.0,
    String? filePath,
    String? error,
  }) {
    _downloadProgressController.add(
      DownloadProgress(
        id: id,
        status: status,
        progress: progress,
        filePath: filePath,
        error: error,
      ),
    );
  }

  /// Create a safe filename from a potentially unsafe one
  String _sanitizeFileName(String fileName) {
    // Replace characters that are invalid in filenames
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Load cached download information
  Future<void> loadCachedDownloads() async {
    try {
      final directory = await _getDownloadDirectory();
      final dir = Directory(directory.path);

      if (await dir.exists()) {
        final files = await dir.list().toList();
        for (final file in files) {
          if (file is File &&
              path.extension(file.path).toLowerCase() == '.mp3') {
            final fileName = path.basenameWithoutExtension(file.path);
            final id = 'local_$fileName';
            _downloadedFilePaths[id] = file.path;
            _activeDownloads[id] = DownloadStatus.completed;
          }
        }
      }
    } catch (e) {
      // Error loading cached downloads
    }
  }

  /// Dispose resources
  void dispose() {
    _downloadProgressController.close();
  }
}
