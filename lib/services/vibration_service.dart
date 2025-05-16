import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../utils/constants.dart';
import '../services/preferences_service.dart';

class VibrationService {
  bool _isVibrating = false;
  Timer? _vibrationTimer;
  bool _hasVibrator = false;

  VibrationService() {
    _checkVibrationCapability();
  }

  Future<void> _checkVibrationCapability() async {
    try {
      _hasVibrator = await Vibration.hasVibrator() ?? false;
    } catch (e) {
      _hasVibrator = false;
    }
  }

  // Check if device has vibration capability
  Future<bool> hasVibration() async {
    if (!_hasVibrator) {
      await _checkVibrationCapability();
    }
    return _hasVibrator;
  }

  // Start continuous vibration
  Future<bool> startVibration() async {
    if (_isVibrating) return true;

    final hasVibrator = await hasVibration();
    if (!hasVibrator) return false;

    _isVibrating = true;

    try {
      // Pattern of vibrations and pauses
      await Vibration.vibrate(
        pattern: [0, 300, 100, 300, 100, 300],
        intensities: [
          0,
          128,
          0,
          192,
          0,
          255,
        ], // Varies the intensity if supported
        repeat: 0, // Loop the pattern
      );
      return true;
    } catch (e) {
      // Fallback to simple vibration if pattern fails
      _startSimpleVibrationLoop();
      return false;
    }
  }

  void _startSimpleVibrationLoop() {
    if (!_isVibrating) return;

    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 700), (
      timer,
    ) async {
      if (_isVibrating) {
        try {
          await Vibration.vibrate(duration: 300);
        } catch (e) {
          // Simple vibration failed
        }
      } else {
        timer.cancel();
      }
    });
  }

  // Stop continuous vibration
  Future<void> stopVibration() async {
    if (!_isVibrating) return;

    try {
      await Vibration.cancel();
    } catch (e) {
      // Error stopping vibration
    }

    _isVibrating = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
  }

  // Single vibration
  Future<void> vibrateOnce() async {
    final hasVibrator = await hasVibration();
    if (!hasVibrator) return;

    try {
      await Vibration.vibrate(duration: Constants.vibrationDuration);
    } catch (e) {
      // Error with single vibration
    }
  }

  // Vibrate for button tap based on user preferences
  Future<void> vibrateForTap(BuildContext context) async {
    final preferencesService = Provider.of<PreferencesService>(
      context,
      listen: false,
    );
    if (preferencesService.vibrateOnTapEnabled) {
      await vibrateOnce();
    }
  }

  // Dispose
  void dispose() {
    stopVibration();
  }

  bool get isVibrating => _isVibrating;
}
