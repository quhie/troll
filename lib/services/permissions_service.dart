import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling app permissions
class PermissionsService {
  /// Request camera permission for flashlight
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Request microphone permission for audio recording
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Check if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  /// Request all necessary permissions for the app
  Future<void> requestAllPermissions() async {
    await requestStoragePermission();
  }

  /// Request storage permission and return result
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13 (API 33) and above
      if (await _isAndroid13OrHigher()) {
        final photosStatus = await Permission.photos.request();
        final videosStatus = await Permission.videos.request();
        final audioStatus = await Permission.audio.request();

        return photosStatus.isGranted ||
            videosStatus.isGranted ||
            audioStatus.isGranted;
      } else {
        // For Android 12 and below
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit storage permission for app-specific directories
      return true;
    }

    // Other platforms
    return false;
  }

  /// Check if device is running Android 13 (API 33) or higher
  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;

    try {
      final sdkInt = await _getAndroidSdkVersion();
      return sdkInt >= 33; // Android 13 is API level 33
    } catch (e) {
      return false;
    }
  }

  /// Get Android SDK version
  Future<int> _getAndroidSdkVersion() async {
    try {
      // This would normally use platform channels or a plugin
      // For now, assume Android 13+ for proper permission handling
      return 33; // Assume Android 13
    } catch (e) {
      return 30; // Default to Android 11 if can't determine
    }
  }

  /// Check if storage permission is granted
  Future<bool> isStoragePermissionGranted() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        return await Permission.photos.isGranted ||
            await Permission.videos.isGranted ||
            await Permission.audio.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
      return true; // iOS doesn't need explicit storage permission for app-specific directories
    }

    return false;
  }

  /// Check the status of a specific permission
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  /// Show permission rationale dialog
  Future<bool> showPermissionRationaleDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Settings'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );

    if (result == true) {
      // Open app settings
      await openAppSettings();
    }

    return result ?? false;
  }
}
