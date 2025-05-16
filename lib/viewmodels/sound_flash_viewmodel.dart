import 'package:flutter/foundation.dart';
import '../models/sound_model.dart';
import '../services/sound_service.dart';
import '../services/flashlight_service.dart';
import '../services/vibration_service.dart';
import '../utils/constants.dart';

class SoundFlashViewModel extends ChangeNotifier {
  final SoundService _soundService = SoundService();
  final FlashlightService _flashlightService = FlashlightService();
  final VibrationService _vibrationService = VibrationService();

  bool _isActive = false;
  String? _currentSoundPath;
  bool _hasStartedServices = false;

  bool get isActive => _isActive;

  // Start all effects using just a sound path
  Future<void> startEffects(String soundPath) async {
    if (_isActive) return;

    _isActive = true;
    _currentSoundPath = soundPath;
    _hasStartedServices = false;

    // Start services in parallel for better performance
    await Future.wait([
      _startSoundService(soundPath),
      _startFlashlightService(),
      _startVibrationService(),
    ]);

    _hasStartedServices = true;
    notifyListeners();
  }

  // Overloaded method to handle SoundModel input
  Future<void> startEffectsWithModel(SoundModel soundModel) async {
    await startEffects(soundModel.soundPath);
  }

  Future<void> _startSoundService(String soundPath) async {
    try {
      // Start sound playback with path string
      await _soundService.playSound(soundPath);
    } catch (e) {
      // Xử lý lỗi khi phát âm thanh
    }
  }

  Future<void> _startFlashlightService() async {
    try {
      // Start flashlight if available
      if (await _flashlightService.hasFlashlight()) {
        _flashlightService.startFlicker();
      }
    } catch (e) {
      // Xử lý lỗi khi bật đèn flash
    }
  }

  Future<void> _startVibrationService() async {
    try {
      // Start vibration if available
      await _vibrationService.startVibration();
    } catch (e) {
      // Xử lý lỗi khi bật rung
    }
  }

  // Stop all effects
  Future<void> stopEffects() async {
    if (!_isActive) return;

    // Stop all services in parallel
    await Future.wait([
      _stopSoundService(),
      _stopFlashlightService(),
      _stopVibrationService(),
    ]);

    _isActive = false;
    notifyListeners();
  }

  Future<void> _stopSoundService() async {
    try {
      await _soundService.stopSound();
    } catch (e) {
      // Xử lý lỗi khi dừng âm thanh
    }
  }

  Future<void> _stopFlashlightService() async {
    try {
      if (_flashlightService.isFlickering) {
        _flashlightService.stopFlicker();
      }
    } catch (e) {
      // Xử lý lỗi khi tắt đèn flash
    }
  }

  Future<void> _stopVibrationService() async {
    try {
      if (await _vibrationService.hasVibration() &&
          _vibrationService.isVibrating) {
        await _vibrationService.stopVibration();
      }
    } catch (e) {
      // Xử lý lỗi khi tắt rung
    }
  }

  // Toggle between start and stop with string path
  Future<void> toggleEffects(String soundPath) async {
    if (_isActive) {
      await stopEffects();
    } else {
      await startEffects(soundPath);
    }
  }

  // Toggle between start and stop with SoundModel
  Future<void> toggleEffectsWithModel(SoundModel soundModel) async {
    if (_isActive) {
      await stopEffects();
    } else {
      await startEffectsWithModel(soundModel);
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
