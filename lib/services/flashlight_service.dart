import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:torch_light/torch_light.dart';
import '../utils/constants.dart';

class FlashlightService {
  bool _isFlickering = false;
  Timer? _flickerTimer;
  bool _flashAvailable = false;

  FlashlightService() {
    _checkFlashlightAvailability();
  }

  Future<void> _checkFlashlightAvailability() async {
    try {
      _flashAvailable = await TorchLight.isTorchAvailable();
    } catch (e) {
      _flashAvailable = false;
    }
  }

  // Check if device has flashlight
  Future<bool> hasFlashlight() async {
    if (!_flashAvailable) {
      await _checkFlashlightAvailability();
    }
    return _flashAvailable;
  }

  // Turn flashlight on
  Future<bool> turnOn() async {
    if (!await hasFlashlight()) return false;

    try {
      await TorchLight.enableTorch();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Turn flashlight off
  Future<bool> turnOff() async {
    if (!await hasFlashlight()) return false;

    try {
      await TorchLight.disableTorch();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Start flickering effect
  void startFlicker() async {
    if (_isFlickering || !await hasFlashlight()) return;

    _isFlickering = true;
    bool isOn = false;

    // Turn on flashlight initially
    await turnOn();

    _flickerTimer = Timer.periodic(Constants.flashlightFlickerDuration, (
      timer,
    ) async {
      isOn = !isOn;
      if (isOn) {
        await turnOn();
      } else {
        await turnOff();
      }
    });
  }

  // Stop flickering effect
  void stopFlicker() async {
    _flickerTimer?.cancel();
    _flickerTimer = null;
    _isFlickering = false;

    // Ensure flashlight is turned off when stopping
    await turnOff();
  }

  // Dispose
  void dispose() {
    stopFlicker();
  }

  bool get isFlickering => _isFlickering;
}
