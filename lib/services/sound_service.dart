import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  String? _currentSource;
  
  SoundService() {
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }
  
  void _setupAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isPlaying) {
        // If we're still in playing state but completed, loop by playing again
        _playCurrentSource();
      }
    });
  }
  
  // Play sound with looping
  Future<void> playSound(String soundPath) async {
    try {
      if (_isPlaying) {
        await stopSound();
      }
      
      _currentSource = soundPath;
      await _playCurrentSource();
      _isPlaying = true;
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }
  
  Future<void> _playCurrentSource() async {
    if (_currentSource != null) {
      try {
        // Strip the 'assets/' prefix for AssetSource
        String path = _currentSource!;
        if (path.startsWith('assets/')) {
          path = path.substring(7); // Remove 'assets/' prefix
        }
        debugPrint("Playing sound: $path");
        final source = AssetSource(path);
        await _audioPlayer.play(source);
      } catch (e) {
        debugPrint("Error in _playCurrentSource: $e");
      }
    }
  }
  
  // Stop sound playback
  Future<void> stopSound() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      _isPlaying = false;
    }
  }
  
  // Pause sound playback
  Future<void> pauseSound() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    }
  }
  
  // Resume sound playback
  Future<void> resumeSound() async {
    if (!_isPlaying) {
      await _audioPlayer.resume();
      _isPlaying = true;
    }
  }
  
  // Dispose audio player
  void dispose() {
    _audioPlayer.dispose();
  }
  
  // Check if sound is currently playing
  bool get isPlaying => _isPlaying;
} 