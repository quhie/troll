import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../utils/haptic_feedback_helper.dart';

class TrollAlarmViewModel extends ChangeNotifier {
  final SoundService _soundService;

  DateTime? _alarmTime;
  String? _alarmSoundId;
  Timer? _alarmTimer;
  Timer? _countdownTimer;
  Duration _timeUntilAlarm = Duration.zero;
  bool _isAlarmSet = false;

  TrollAlarmViewModel(this._soundService);

  bool get isAlarmSet => _isAlarmSet;
  Duration get timeUntilAlarm => _timeUntilAlarm;
  DateTime? get alarmTime => _alarmTime;

  void setAlarm(DateTime time, String soundId) {
    if (_alarmTimer != null) {
      _alarmTimer!.cancel();
    }

    if (_countdownTimer != null) {
      _countdownTimer!.cancel();
    }

    _alarmTime = time;
    _alarmSoundId = soundId;
    _isAlarmSet = true;

    // Calculate duration between now and alarm time
    final now = DateTime.now();
    final difference = _alarmTime!.difference(now);

    // Set up the alarm timer
    _alarmTimer = Timer(difference, _triggerAlarm);

    // Set up countdown timer that updates every second
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });

    notifyListeners();
  }

  void _updateCountdown() {
    if (_alarmTime == null) return;

    final now = DateTime.now();
    _timeUntilAlarm = _alarmTime!.difference(now);

    // If time until alarm is negative, cancel the alarm
    if (_timeUntilAlarm.isNegative) {
      cancelAlarm();
    }

    notifyListeners();
  }

  void _triggerAlarm() {
    if (_alarmSoundId != null) {
      // Play the alarm sound
      _soundService.playSound(_alarmSoundId!);

      // Trigger haptic feedback
      HapticFeedbackHelper.heavyImpact();
    }

    // Cancel the countdown timer
    _countdownTimer?.cancel();
    _countdownTimer = null;

    // Reset alarm state
    _isAlarmSet = false;
    notifyListeners();
  }

  void cancelAlarm() {
    _alarmTimer?.cancel();
    _alarmTimer = null;

    _countdownTimer?.cancel();
    _countdownTimer = null;

    _alarmTime = null;
    _alarmSoundId = null;
    _timeUntilAlarm = Duration.zero;
    _isAlarmSet = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
