import 'package:flutter/foundation.dart';
import '../services/sound_service.dart';
import '../services/flashlight_service.dart';
import '../services/vibration_service.dart';

class SoundFlashViewModel extends ChangeNotifier {
  final SoundService _soundService = SoundService();
  final FlashlightService _flashlightService = FlashlightService();
  final VibrationService _vibrationService = VibrationService();
  
  bool _isActive = false;
  String? _currentSoundPath;
  bool _hasStartedServices = false;
  
  bool get isActive => _isActive;
  
  // Start all effects
  Future<void> startEffects(String soundPath) async {
    if (_isActive) return;
    
    _isActive = true;
    _currentSoundPath = soundPath;
    _hasStartedServices = false;
    
    // Start services in parallel for better performance
    await Future.wait([
      _startSoundService(soundPath),
      _startFlashlightService(),
      _startVibrationService()
    ]);
    
    _hasStartedServices = true;
    notifyListeners();
  }
  
  Future<void> _startSoundService(String soundPath) async {
    try {
      // Start sound playback
      await _soundService.playSound(soundPath);
    } catch (e) {
      debugPrint("Error starting sound: $e");
    }
  }
  
  Future<void> _startFlashlightService() async {
    try {
      // Start flashlight if available
      if (await _flashlightService.hasFlashlight()) {
        _flashlightService.startFlicker();
      }
    } catch (e) {
      debugPrint("Error starting flashlight: $e");
    }
  }
  
  Future<void> _startVibrationService() async {
    try {
      // Start vibration if available
      await _vibrationService.startVibration();
    } catch (e) {
      debugPrint("Error starting vibration: $e");
    }
  }
  
  // Stop all effects
  Future<void> stopEffects() async {
    if (!_isActive) return;
    
    // Stop all services in parallel
    await Future.wait([
      _stopSoundService(),
      _stopFlashlightService(),
      _stopVibrationService()
    ]);
    
    _isActive = false;
    notifyListeners();
  }
  
  Future<void> _stopSoundService() async {
    try {
      await _soundService.stopSound();
    } catch (e) {
      debugPrint("Error stopping sound: $e");
    }
  }
  
  Future<void> _stopFlashlightService() async {
    try {
      if (_flashlightService.isFlickering) {
        _flashlightService.stopFlicker();
      }
    } catch (e) {
      debugPrint("Error stopping flashlight: $e");
    }
  }
  
  Future<void> _stopVibrationService() async {
    try {
      if (await _vibrationService.hasVibration() && _vibrationService.isVibrating) {
        await _vibrationService.stopVibration();
      }
    } catch (e) {
      debugPrint("Error stopping vibration: $e");
    }
  }
  
  // Toggle between start and stop
  Future<void> toggleEffects(String soundPath) async {
    if (_isActive) {
      await stopEffects();
    } else {
      await startEffects(soundPath);
    }
  }
  
  // Restart effects with the same sound if active
  Future<void> restartEffects() async {
    if (_isActive && _currentSoundPath != null) {
      await stopEffects();
      await startEffects(_currentSoundPath!);
    }
  }
  
  @override
  void dispose() {
    _soundService.dispose();
    _flashlightService.dispose();
    _vibrationService.dispose();
    super.dispose();
  }
} 