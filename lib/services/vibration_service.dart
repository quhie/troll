import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import '../utils/constants.dart';

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
      debugPrint("Vibration not available: $e");
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
  Future<void> startVibration() async {
    if (_isVibrating) return;
    
    final hasVibrator = await hasVibration();
    if (!hasVibrator) return;
    
    _isVibrating = true;
    
    try {
      // Pattern of vibrations and pauses
      await Vibration.vibrate(
        pattern: [0, 300, 100, 300, 100, 300],
        intensities: [0, 128, 0, 192, 0, 255], // Varies the intensity if supported
        repeat: 0, // Loop the pattern
      );
    } catch (e) {
      debugPrint("Error starting vibration: $e");
      // Fallback to simple vibration if pattern fails
      _startSimpleVibrationLoop();
    }
  }
  
  void _startSimpleVibrationLoop() {
    if (!_isVibrating) return;
    
    _vibrationTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) async {
      if (_isVibrating) {
        try {
          await Vibration.vibrate(duration: 300);
        } catch (e) {
          debugPrint("Simple vibration failed: $e");
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
      debugPrint("Error stopping vibration: $e");
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
      await Vibration.vibrate(duration: Constants.vibrationDuration.inMilliseconds);
    } catch (e) {
      debugPrint("Error with single vibration: $e");
    }
  }
  
  // Dispose
  void dispose() {
    stopVibration();
  }
  
  bool get isVibrating => _isVibrating;
} 