import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/vibration_service.dart';
import '../utils/constants.dart';

class FakeErrorViewModel extends ChangeNotifier {
  final VibrationService _vibrationService = VibrationService();
  
  bool _isErrorShown = true;
  bool _isTrollComplete = false;
  double _loadingProgress = 0.0;
  Timer? _progressTimer;
  Timer? _completeTimer;
  
  bool get isErrorShown => _isErrorShown;
  bool get isTrollComplete => _isTrollComplete;
  double get loadingProgress => _loadingProgress;
  
  // Start the fake error process
  void startFakeError() {
    _isErrorShown = true;
    _isTrollComplete = false;
    _loadingProgress = 0.0;
    
    // Start loading bar animation
    _progressTimer = Timer.periodic(
      const Duration(milliseconds: 50), 
      (timer) {
        _loadingProgress += 0.01;
        if (_loadingProgress >= 1.0) {
          timer.cancel();
        }
        notifyListeners();
      }
    );
    
    // Start vibration
    _vibrationService.startVibration();
    
    // Show troll complete message after 5 seconds
    _completeTimer = Timer(
      Constants.errorScreenDuration, 
      () {
        _isTrollComplete = true;
        _vibrationService.vibrateOnce();  // Single strong vibration
        notifyListeners();
        
        // Auto close after 2 more seconds
        Timer(const Duration(seconds: 2), () {
          close();
        });
      }
    );
    
    notifyListeners();
  }
  
  // Close error screen
  void close() {
    _progressTimer?.cancel();
    _completeTimer?.cancel();
    _vibrationService.stopVibration();
    _isErrorShown = false;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _progressTimer?.cancel();
    _completeTimer?.cancel();
    _vibrationService.dispose();
    super.dispose();
  }
} 